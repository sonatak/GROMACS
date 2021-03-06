/* -*- mode: c; tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4; c-file-style: "stroustrup"; -*-
 *
 * 
 *                This source code is part of
 * 
 *                 G   R   O   M   A   C   S
 * 
 *          GROningen MAchine for Chemical Simulations
 * 
 *                        VERSION 3.2.0
 * Written by David van der Spoel, Erik Lindahl, Berk Hess, and others.
 * Copyright (c) 1991-2000, University of Groningen, The Netherlands.
 * Copyright (c) 2001-2004, The GROMACS development team,
 * check out http://www.gromacs.org for more information.

 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 * 
 * If you want to redistribute modifications, please consider that
 * scientific software is very special. Version control is crucial -
 * bugs must be traceable. We will be happy to consider code for
 * inclusion in the official distribution, but derived work must not
 * be called official GROMACS. Details are found in the README & COPYING
 * files - if they are missing, get the official version at www.gromacs.org.
 * 
 * To help us fund GROMACS development, we humbly ask that you cite
 * the papers on the package - you can find them in the top README file.
 * 
 * For more info, check our website at http://www.gromacs.org
 * 
 * And Hey:
 * Gallium Rubidium Oxygen Manganese Argon Carbon Silicon
 */
#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

#include <signal.h>
#include <stdlib.h>
#include "typedefs.h"
#include "smalloc.h"
#include "sysstuff.h"
#include "vec.h"
#include "statutil.h"
#include "vcm.h"
#include "mdebin.h"
#include "nrnb.h"
#include "calcmu.h"
#include "index.h"
#include "vsite.h"
#include "update.h"
#include "ns.h"
#include "trnio.h"
#include "xtcio.h"
#include "mdrun.h"
#include "confio.h"
#include "network.h"
#include "pull.h"
#include "xvgr.h"
#include "physics.h"
#include "names.h"
#include "xmdrun.h"
#include "ionize.h"
#include "disre.h"
#include "orires.h"
#include "dihre.h"
#include "pppm.h"
#include "pme.h"
#include "mdatoms.h"
#include "repl_ex.h"
#include "qmmm.h"
#include "mpelogging.h"
#include "domdec.h"
#include "partdec.h"
#include "topsort.h"
#include "coulomb.h"
#include "constr.h"
#include "shellfc.h"
#include "compute_io.h"
#include "mvdata.h"
#include "checkpoint.h"
#include "mtop_util.h"
#include "random.h"
#include "bondf.h" ///retirar

#ifdef GMX_LIB_MPI
#include <mpi.h>
#endif
#ifdef GMX_THREAD_MPI
#include "thread_mpi.h"
#endif

#ifdef GMX_FAHCORE
#include "corewrap.h"
#endif

/* The following two variables and the signal_handler function
 * is used from pme.c as well 
 */
extern bool bGotTermSignal, bGotUsr1Signal;

static RETSIGTYPE signal_handler(int n)
{
  switch (n) {
  case SIGTERM:
    bGotTermSignal = TRUE;
    break;
#ifdef HAVE_SIGUSR1
  case SIGUSR1:
    bGotUsr1Signal = TRUE;
    break;
#endif
  }
}

typedef struct { 
  gmx_integrator_t *func;
} gmx_intp_t;

/* The array should match the eI array in include/types/enums.h */
const gmx_intp_t integrator[eiNR] = { {do_md}, {do_steep}, {do_cg}, {do_md}, {do_md}, {do_nm}, {do_lbfgs}, {do_tpi}, {do_tpi}, {do_md}, {do_md} };

/* Static variables for temporary use with the deform option */
static int    init_step_tpx;
static matrix box_tpx;

int mdrunner(FILE *fplog,t_commrec *cr,int nfile,t_filenm fnm[],
             bool bVerbose,bool bCompact,int nstglobalcomm,
             ivec ddxyz,int dd_node_order,real rdd,real rconstr,
             const char *dddlb_opt,real dlb_scale,
             const char *ddcsx,const char *ddcsy,const char *ddcsz,
             int nstepout,gmx_edsam_t ed,int repl_ex_nst,int repl_ex_seed,
             real pforce,real cpt_period,real max_hours,
             unsigned long Flags)
{
    double     nodetime=0,realtime;
    t_inputrec *inputrec;
    t_state    *state=NULL;
    matrix     box;
    gmx_ddbox_t ddbox;
    int        npme_major;
    real       tmpr1,tmpr2;
    t_nrnb     *nrnb;
    gmx_mtop_t *mtop=NULL;
    t_mdatoms  *mdatoms=NULL;
    t_forcerec *fr=NULL;
    t_fcdata   *fcd=NULL;
    real       ewaldcoeff=0;
    gmx_pme_t  *pmedata=NULL;
    gmx_vsite_t *vsite=NULL;
    gmx_constr_t constr;
    int        i,m,nChargePerturbed=-1,status,nalloc;
    char       *gro;
    gmx_wallcycle_t wcycle;
    bool       bReadRNG,bReadEkin;
    int        list;
    gmx_runtime_t runtime;
    int        rc;
    gmx_step_t reset_counters;

    
    snew(inputrec,1);
    snew(mtop,1);
  	
    if (bVerbose && SIMMASTER(cr))
    {
        fprintf(stderr,"Getting Loaded...\n");
    }
    
    if (Flags & MD_APPENDFILES) 
    {
        fplog = NULL;
    }
	
    if (PAR(cr))
    {
        /* The master thread on the master node reads from disk, 
         * then distributes everything to the other processors.
         */
        
        list = (SIMMASTER(cr) && !(Flags & MD_APPENDFILES)) ?  (LIST_SCALARS | LIST_INPUTREC) : 0;
        
        snew(state,1);
        init_parallel(fplog, opt2fn_master("-s",nfile,fnm,cr),cr,
                      inputrec,mtop,state,list);
        
    }
    else
    {
        /* Read a file for a single processor */
        snew(state,1);
        init_single(fplog,inputrec,ftp2fn(efTPX,nfile,fnm),mtop,state);
    }
    
    if(inputrec->eI == eiMC) {
     Flags = Flags | MD_PARTDEC;
    }

    if (!EEL_PME(inputrec->coulombtype) || (Flags & MD_PARTDEC))
    {
        cr->npmenodes = 0;
    }
    
#ifdef GMX_FAHCORE
    fcRegisterSteps(inputrec->nsteps,inputrec->init_step);
  #endif
    
    /* NMR restraints must be initialized before load_checkpoint,
     * since with time averaging the history is added to t_state.
     * For proper consistency check we therefore need to extend
     * t_state here.
     * So the PME-only nodes (if present) will also initialize
     * the distance restraints.
     */
    snew(fcd,1);
    
    /* This needs to be called before read_checkpoint to extend the state */
    init_disres(fplog,mtop,inputrec,cr,Flags & MD_PARTDEC,fcd,state);
    
    if (gmx_mtop_ftype_count(mtop,F_ORIRES) > 0)
    {
        if (PAR(cr) && !(Flags & MD_PARTDEC))
        {
            gmx_fatal(FARGS,"Orientation restraints do not work (yet) with domain decomposition, use particle decomposition (mdrun option -pd)");
        }
        /* Orientation restraints */
        if (MASTER(cr))
        {
            init_orires(fplog,mtop,state->x,inputrec,cr->ms,&(fcd->orires),
                        state);
        }
    }
    
    if (DEFORM(*inputrec))
    {
        /* Store the deform reference box before reading the checkpoint */
        if (SIMMASTER(cr))
        {
            copy_mat(state->box,box);
        }
        if (PAR(cr))
        {
            gmx_bcast(sizeof(box),box,cr);
        }
        /* Because we do not have the update struct available yet
         * in which the reference values should be stored,
         * we store them temporarily in static variables.
         * This should be thread safe, since they are only written once
         * and with identical values.
         */
        init_step_tpx = inputrec->init_step;
        copy_mat(box,box_tpx);
    }
    
    if (opt2bSet("-cpi",nfile,fnm)) 
    {
        /* Check if checkpoint file exists before doing continuation.
         * This way we can use identical input options for the first and subsequent runs...
         */
        if( gmx_fexist_master(opt2fn_master("-cpi",nfile,fnm,cr),cr) )
        {
            load_checkpoint(opt2fn_master("-cpi",nfile,fnm,cr),fplog,
                            cr,Flags & MD_PARTDEC,ddxyz,
                            inputrec,state,&bReadRNG,&bReadEkin,
                            (Flags & MD_APPENDFILES));
            
            if (bReadRNG)
            {
                Flags |= MD_READ_RNG;
            }
            if (bReadEkin)
            {
                Flags |= MD_READ_EKIN;
            }
        }
    }
    
    if (MASTER(cr) && (Flags & MD_APPENDFILES))
    {
        fplog = gmx_log_open(ftp2fn(efLOG,nfile,fnm),cr,!(Flags & MD_SEPPOT),
                             Flags);
    }
    
    if (SIMMASTER(cr)) 
    {
        copy_mat(state->box,box);
    }
	
    if (PAR(cr)) 
    {
        gmx_bcast(sizeof(box),box,cr);
    }
	
    if (bVerbose && SIMMASTER(cr))
    {
        fprintf(stderr,"Loaded with Money\n\n");
    }
    
    if (PAR(cr) && !((Flags & MD_PARTDEC) || EI_TPI(inputrec->eI) || EI_MC(inputrec->eI)))
    {
        cr->dd = init_domain_decomposition(fplog,cr,Flags,ddxyz,rdd,rconstr,
                                           dddlb_opt,dlb_scale,
                                           ddcsx,ddcsy,ddcsz,
                                           mtop,inputrec,
                                           box,state->x,
                                           &ddbox,&npme_major);
        
        make_dd_communicators(fplog,cr,dd_node_order);
        
        /* Set overallocation to avoid frequent reallocation of arrays */
        set_over_alloc_dd(TRUE);
    }
    else
    {
        cr->duty = (DUTY_PP | DUTY_PME);
        npme_major = cr->nnodes;

        if (inputrec->ePBC == epbcSCREW)
        {
            gmx_fatal(FARGS,
                      "pbc=%s is only implemented with domain decomposition",
                      epbc_names[inputrec->ePBC]);
        }
    }
    
    if (PAR(cr))
    {
        /* After possible communicator splitting in make_dd_communicators.
         * we can set up the intra/inter node communication.
         */
            gmx_setup_nodecomm(fplog,cr);
    }
	
    wcycle = wallcycle_init(fplog,cr);
    if (PAR(cr))
    {
        /* Master synchronizes its value of reset_counters with all nodes 
         * including PME only nodes */
        reset_counters = wcycle_get_reset_counters(wcycle);
        gmx_bcast_sim(sizeof(reset_counters),&reset_counters,cr);
        wcycle_set_reset_counters(wcycle, reset_counters);
    }
        
    
    snew(nrnb,1);
    if (cr->duty & DUTY_PP)
    {
        /* For domain decomposition we allocate dynamically
         * in dd_partition_system.
         */
        if (DOMAINDECOMP(cr))
        {
            bcast_state_setup(cr,state);
        }
        else
        {
            if (PAR(cr))
            {
                if (!MASTER(cr))
                {
                    snew(state,1);
                }
                bcast_state(cr,state,TRUE);
            }
        }
    
        /* Dihedral Restraints */
        if (gmx_mtop_ftype_count(mtop,F_DIHRES) > 0)
        {
            init_dihres(fplog,mtop,inputrec,fcd);
        }
        
        /* Initiate forcerecord */
        fr = mk_forcerec();
        
        init_forcerec(fplog,fr,fcd,inputrec,mtop,cr,box,FALSE,
                      opt2fn("-table",nfile,fnm),
                      opt2fn("-tablep",nfile,fnm),
                      opt2fn("-tableb",nfile,fnm),FALSE,pforce);
                      
        /* version for PCA_NOT_READ_NODE (see md.c) */
        /*init_forcerec(fplog,fr,fcd,inputrec,mtop,cr,box,FALSE,
                              "nofile","nofile","nofile",FALSE,pforce);
        */        
        fr->bSepDVDL = ((Flags & MD_SEPPOT) == MD_SEPPOT);
        
        /* Initialize QM-MM */
        if(fr->bQMMM)
        {
            init_QMMMrec(cr,box,mtop,inputrec,fr);
        }
        
        /* Initialize the mdatoms structure.
         * mdatoms is not filled with atom data,
         * as this can not be done now with domain decomposition.
         */
        mdatoms = init_mdatoms(fplog,mtop,inputrec->efep!=efepNO);
        
        /* Initialize the virtual site communication */
        vsite = init_vsite(mtop,cr);
        
        calc_shifts(box,fr->shift_vec);
        
        /* With periodic molecules the charge groups should be whole at start up
         * and the virtual sites should not be far from their proper positions.
         */
        if (!inputrec->bContinuation && MASTER(cr) &&
            !(inputrec->ePBC != epbcNONE && inputrec->bPeriodicMols))
        {
            /* Make molecules whole at start of run */
            if (fr->ePBC != epbcNONE)
            {
                do_pbc_first_mtop(fplog,inputrec->ePBC,box,mtop,state->x);
            }
            if (vsite)
            {
                /* Correct initial vsite positions are required
                 * for the initial distribution in the domain decomposition
                 * and for the initial shell prediction.
                 */
                construct_vsites_mtop(fplog,vsite,mtop,state->x);
            }
        }
        
        /* Initiate PPPM if necessary */
        if (fr->eeltype == eelPPPM)
        {
            if (mdatoms->nChargePerturbed)
            {
                gmx_fatal(FARGS,"Free energy with %s is not implemented",
                          eel_names[fr->eeltype]);
            }
            status = gmx_pppm_init(fplog,cr,FALSE,TRUE,box,
                                   getenv("GMXGHAT"),inputrec, (Flags & MD_REPRODUCIBLE));
            if (status != 0)
            {
                gmx_fatal(FARGS,"Error %d initializing PPPM",status);
            }
        }
        
        if (EEL_PME(fr->eeltype))
        {
            ewaldcoeff = fr->ewaldcoeff;
            pmedata = &fr->pmedata;
        }
        else
        {
            pmedata = NULL;
        }
    }
    else
    {
        /* This is a PME only node */
        
        /* We don't need the state */
        done_state(state);
        
        ewaldcoeff = calc_ewaldcoeff(inputrec->rcoulomb, inputrec->ewald_rtol);
        snew(pmedata,1);
    }
    
    /* Initiate PME if necessary,
     * either on all nodes or on dedicated PME nodes only. */
    if (EEL_PME(inputrec->coulombtype))
    {
        if (mdatoms)
        {
            nChargePerturbed = mdatoms->nChargePerturbed;
        }
        if (cr->npmenodes > 0)
        {
            /* The PME only nodes need to know nChargePerturbed */
            gmx_bcast_sim(sizeof(nChargePerturbed),&nChargePerturbed,cr);
        }
        if (cr->duty & DUTY_PME)
        {
            status = gmx_pme_init(pmedata,cr,npme_major,inputrec,
                                  mtop ? mtop->natoms : 0,nChargePerturbed,
                                  (Flags & MD_REPRODUCIBLE));
            if (status != 0)
                gmx_fatal(FARGS,"Error %d initializing PME",status);
        }
    }
    
    
    if (integrator[inputrec->eI].func == do_md)
    {
        /* Turn on signal handling on all nodes */
        /*
         * (A user signal from the PME nodes (if any)
         * is communicated to the PP nodes.
         */
        if (getenv("GMX_NO_TERM") == NULL)
        {
            if (debug)
            {
                fprintf(debug,"Installing signal handler for SIGTERM\n");
            }
            signal(SIGTERM,signal_handler);
        }
#ifdef HAVE_SIGUSR1
        if (getenv("GMX_NO_USR1") == NULL)
        {
            if (debug)
            {
                fprintf(debug,"Installing signal handler for SIGUSR1\n");
            }
            signal(SIGUSR1,signal_handler);
        }
#endif
    }
    
    if (cr->duty & DUTY_PP)
    {
        if (inputrec->ePull != epullNO)
        {
            /* Initialize pull code */
            init_pull(fplog,inputrec,nfile,fnm,mtop,cr,
                      EI_DYNAMICS(inputrec->eI) && MASTER(cr),Flags);
        }
        
        constr = init_constraints(fplog,mtop,inputrec,ed,state,cr);
        
        if (DOMAINDECOMP(cr))
        {
            dd_init_bondeds(fplog,cr->dd,mtop,vsite,constr,inputrec,
                            Flags & MD_DDBONDCHECK,fr->cginfo_mb);
            
            set_dd_parameters(fplog,cr->dd,dlb_scale,inputrec,fr,&ddbox);
            
            setup_dd_grid(fplog,cr->dd);
        }
        
        /* Now do whatever the user wants us to do (how flexible...) */
        integrator[inputrec->eI].func(fplog,cr,nfile,fnm,
                                      bVerbose,bCompact,
                                      nstglobalcomm,
                                      vsite,constr,
                                      nstepout,inputrec,mtop,
                                      fcd,state,
                                      mdatoms,nrnb,wcycle,ed,fr,
                                      repl_ex_nst,repl_ex_seed,
                                      cpt_period,max_hours,
                                      Flags,
                                      &runtime);
        
        if (inputrec->ePull != epullNO)
        {
            finish_pull(fplog,inputrec->pull);
        }
    }
    else
    {
        /* do PME only */
        gmx_pmeonly(*pmedata,cr,nrnb,wcycle,ewaldcoeff,FALSE,inputrec);
    }

    if (EI_DYNAMICS(inputrec->eI) || EI_TPI(inputrec->eI))
    {
        /* Some timing stats */  
        if (MASTER(cr))
        {
            if (runtime.proc == 0)
            {
                runtime.proc = runtime.real;
            }
        }
        else
        {
            runtime.real = 0;
        }
    }

    wallcycle_stop(wcycle,ewcRUN);
    
    /* Finish up, write some stuff
     * if rerunMD, don't write last frame again 
     */
    finish_run(fplog,cr,ftp2fn(efSTO,nfile,fnm),
               inputrec,nrnb,wcycle,&runtime,
               EI_DYNAMICS(inputrec->eI) && !MULTISIM(cr));
    
    /* Does what it says */  
    print_date_and_time(fplog,cr->nodeid,"Finished mdrun",&runtime);
    
	/* Close logfile already here if we were appending to it */
	if (MASTER(cr) && (Flags & MD_APPENDFILES))
	{
		gmx_log_close(fplog);
	}	
    
    if(bGotTermSignal)
    {
        rc = 1;
    }
    else if(bGotUsr1Signal)
    {
        rc = 2;
    }
    else
    {
        rc = 0;
    }
	
    return rc;
}

static void md_print_warning(const t_commrec *cr,FILE *fplog,const char *buf)
{
    if (MASTER(cr))
    {
        fprintf(stderr,"\n%s\n",buf);
    }
    if (fplog)
    {
        fprintf(fplog,"\n%s\n",buf);
    }
}

static void check_nst_param(FILE *fplog,t_commrec *cr,
                            const char *desc_nst,int nst,
                            const char *desc_p,int *p)
{
    char buf[STRLEN];

    if (*p > 0 && *p % nst != 0)
    {
        /* Round up to the next multiple of nst */
        *p = ((*p)/nst + 1)*nst;
        sprintf(buf,"NOTE: %s changes %s to %d\n",desc_nst,desc_p,*p);
        md_print_warning(cr,fplog,buf);
    }
}

static void reset_all_counters(FILE *fplog,t_commrec *cr,
                               gmx_step_t step,
                               gmx_step_t *step_rel,t_inputrec *ir,
                               gmx_wallcycle_t wcycle,t_nrnb *nrnb,
                               gmx_runtime_t *runtime)
{
    char buf[STRLEN],sbuf[22];

    /* Reset all the counters related to performance over the run */
    sprintf(buf,"Step %s: resetting all time and cycle counters\n",
            gmx_step_str(step,sbuf));
    md_print_warning(cr,fplog,buf);

    wallcycle_stop(wcycle,ewcRUN);
    wallcycle_reset_all(wcycle);
    if (DOMAINDECOMP(cr))
    {
        reset_dd_statistics_counters(cr->dd);
    }
    init_nrnb(nrnb);
    ir->init_step += *step_rel;
    ir->nsteps    -= *step_rel;
    *step_rel = 0;
    wallcycle_start(wcycle,ewcRUN);
    runtime_start(runtime);
    print_date_and_time(fplog,cr->nodeid,"Restarted time",runtime);
}
    
static int check_nstglobalcomm(FILE *fplog,t_commrec *cr,
                               int nstglobalcomm,t_inputrec *ir)
{
    char buf[STRLEN];

    if (!EI_DYNAMICS(ir->eI))
    {
        nstglobalcomm = 1;
    }

    if (nstglobalcomm == -1)
    {
        if (ir->nstcalcenergy == 0 && ir->nstlist == 0)
        {
            nstglobalcomm = 10;
            if (ir->nstenergy > 0 && ir->nstenergy < nstglobalcomm)
            {
                nstglobalcomm = ir->nstenergy;
            }
        }
        else
        {
            /* We assume that if nstcalcenergy > nstlist,
             * nstcalcenergy is a multiple of nstlist.
             */
            if (ir->nstcalcenergy == 0 ||
                (ir->nstlist > 0 && ir->nstlist < ir->nstcalcenergy))
            {
                nstglobalcomm = ir->nstlist;
            }
            else
            {
                nstglobalcomm = ir->nstcalcenergy;
            }
        }
    }
    else
    {
        if (ir->nstlist > 0 &&
            nstglobalcomm > ir->nstlist && nstglobalcomm % ir->nstlist != 0)
        {
            nstglobalcomm = (nstglobalcomm / ir->nstlist)*ir->nstlist;
            sprintf(buf,"WARNING: nstglobalcomm is larger than nstlist, but not a multiple, setting it to %d\n",nstglobalcomm);
            md_print_warning(cr,fplog,buf);
        }
        if (nstglobalcomm > ir->nstcalcenergy)
        {
            check_nst_param(fplog,cr,"-gcom",nstglobalcomm,
                            "nstcalcenergy",&ir->nstcalcenergy);
        }

        check_nst_param(fplog,cr,"-gcom",nstglobalcomm,
                        "nstenergy",&ir->nstenergy);
        
        check_nst_param(fplog,cr,"-gcom",nstglobalcomm,
                        "nstlog",&ir->nstlog);
    }

    if (ir->comm_mode != ecmNO && ir->nstcomm < nstglobalcomm)
    {
        sprintf(buf,"WARNING: Changing nstcomm from %d to %d\n",
                ir->nstcomm,nstglobalcomm);
        md_print_warning(cr,fplog,buf);
        ir->nstcomm = nstglobalcomm;
    }
    
    return nstglobalcomm;
}

static void check_ir_old_tpx_versions(t_commrec *cr,FILE *fplog,
                                      t_inputrec *ir,gmx_mtop_t *mtop)
{
    /* Check required for old tpx files */
    if (IR_TWINRANGE(*ir) && ir->nstlist > 1 &&
        ir->nstcalcenergy % ir->nstlist != 0)
    {
        md_print_warning(cr,fplog,"Old tpr file with twin-range settings: modifiying energy calculation and/or T/P-coupling frequencies");

        if (gmx_mtop_ftype_count(mtop,F_CONSTR) +
            gmx_mtop_ftype_count(mtop,F_CONSTRNC) > 0 &&
            ir->eConstrAlg == econtSHAKE)
        {
            md_print_warning(cr,fplog,"With twin-range cut-off's and SHAKE the virial and pressure are incorrect");
            if (ir->epc != epcNO)
            {
                gmx_fatal(FARGS,"Can not do pressure coupling with twin-range cut-off's and SHAKE");
            }
        }
        check_nst_param(fplog,cr,"nstlist",ir->nstlist,
                        "nstcalcenergy",&ir->nstcalcenergy);
    }
    check_nst_param(fplog,cr,"nstcalcenergy",ir->nstcalcenergy,
                    "nstenergy",&ir->nstenergy);
    check_nst_param(fplog,cr,"nstcalcenergy",ir->nstcalcenergy,
                    "nstlog",&ir->nstlog);
    if (ir->efep != efepNO)
    {
        check_nst_param(fplog,cr,"nstdhdl",ir->nstdhdl,
                        "nstenergy",&ir->nstenergy);
    }
}

typedef struct {
    bool       bGStatEveryStep;
    gmx_step_t step_ns;
    gmx_step_t step_nscheck;
    gmx_step_t nns;
    matrix     scale_tot;
    int        nabnsb;
    double     s1;
    double     s2;
    double     ab;
    double     lt_runav;
    double     lt_runav2;
} gmx_nlheur_t;

static void reset_nlistheuristics(gmx_nlheur_t *nlh,gmx_step_t step)
{
    nlh->lt_runav  = 0;
    nlh->lt_runav2 = 0;
    nlh->step_nscheck = step;
}

static void init_nlistheuristics(gmx_nlheur_t *nlh,
                                 bool bGStatEveryStep,gmx_step_t step)
{
    nlh->bGStatEveryStep = bGStatEveryStep;
    nlh->nns       = 0;
    nlh->nabnsb    = 0;
    nlh->s1        = 0;
    nlh->s2        = 0;
    nlh->ab        = 0;

    reset_nlistheuristics(nlh,step);
}

static void update_nliststatistics(gmx_nlheur_t *nlh,gmx_step_t step)
{
    gmx_step_t nl_lt;
    char sbuf[22],sbuf2[22];

    /* Determine the neighbor list life time */
    nl_lt = step - nlh->step_ns;
    if (debug)
    {
        fprintf(debug,"%d atoms beyond ns buffer, updating neighbor list after %s steps\n",nlh->nabnsb,gmx_step_str(nl_lt,sbuf));
    }
    nlh->nns++;
    nlh->s1 += nl_lt;
    nlh->s2 += nl_lt*nl_lt;
    nlh->ab += nlh->nabnsb;
    if (nlh->lt_runav == 0)
    {
        nlh->lt_runav  = nl_lt;
        /* Initialize the fluctuation average
         * such that at startup we check after 0 steps.
             */
        nlh->lt_runav2 = sqr(nl_lt/2.0);
    }
    /* Running average with 0.9 gives an exp. history of 9.5 */
    nlh->lt_runav2 = 0.9*nlh->lt_runav2 + 0.1*sqr(nlh->lt_runav - nl_lt);
    nlh->lt_runav  = 0.9*nlh->lt_runav  + 0.1*nl_lt;
    if (nlh->bGStatEveryStep)
    {
        /* Always check the nlist validity */
        nlh->step_nscheck = step;
    }
    else
    {
        /* We check after:  <life time> - 2*sigma
         * The factor 2 is quite conservative,
         * but we assume that with nstlist=-1 the user
         * prefers exact integration over performance.
         */
        nlh->step_nscheck = step
            + (int)(nlh->lt_runav - 2.0*sqrt(nlh->lt_runav2)) - 1;
    }
    if (debug)
    {
        fprintf(debug,"nlist life time %s run av. %4.1f sig %3.1f check %s check with -gcom %d\n",
                gmx_step_str(nl_lt,sbuf),nlh->lt_runav,sqrt(nlh->lt_runav2),
                gmx_step_str(nlh->step_nscheck-step+1,sbuf2),
                (int)(nlh->lt_runav - 2.0*sqrt(nlh->lt_runav2)));
    }
}

static void set_nlistheuristics(gmx_nlheur_t *nlh,bool bReset,gmx_step_t step)
{
    int d;

    if (bReset)
    {
        reset_nlistheuristics(nlh,step);
    }
    else
    {
        update_nliststatistics(nlh,step);
    }

    nlh->step_ns = step;
    /* Initialize the cumulative coordinate scaling matrix */
    clear_mat(nlh->scale_tot);
    for(d=0; d<DIM; d++)
    {
        nlh->scale_tot[d][d] = 1.0;
    }
}
bool accept_mc(real deltaH,real bolt,real t,gmx_mc_move *mc_move)
{
 bool ok=FALSE;
 real prob=1;
 //if(mc_move->bias)
 //mc_move->bias=1;
 //prob = mc_move->bias*exp(-deltaH/(BOLTZ*t));
 prob = mc_move->bias;
 printf("prob %f bolt %f bias %f delta %f\n",prob,bolt,mc_move->bias,deltaH);
 if(prob >= 1)
 {
  ok = TRUE;
 }
 else if( prob > bolt)
 {
  ok = TRUE;
 }
 return ok;
}
double do_md(FILE *fplog,t_commrec *cr,int nfile,t_filenm fnm[],
             bool bVerbose,bool bCompact,int nstglobalcomm,
             gmx_vsite_t *vsite,gmx_constr_t constr,
             int stepout,t_inputrec *ir,
             gmx_mtop_t *top_global,
             t_fcdata *fcd,
             t_state *state_global,
             t_mdatoms *mdatoms,
             t_nrnb *nrnb,gmx_wallcycle_t wcycle,
             gmx_edsam_t ed,t_forcerec *fr,
             int repl_ex_nst,int repl_ex_seed,
             real cpt_period,real max_hours,
             unsigned long Flags,
             gmx_runtime_t *runtime)
{
  int        fp_ene=0,fp_trn=0,fp_xtc=0;
  gmx_step_t step,step_rel;
  char       *fn_cpt;
  FILE       *fp_dhdl=NULL,*fp_field=NULL;
  double     run_time;
  double     t,t0,lam0;
  bool       bGStatEveryStep,bGStat,bNstEner,bCalcEner;
  bool       bNS,bNStList,bSimAnn,bStopCM,bRerunMD,bNotLastFrame=FALSE,
             bFirstStep,bStateFromTPX,bLastStep,bBornRadii;
  bool       bDoDHDL=FALSE;
  bool       bNEMD,do_ene,do_log,do_vir,do_verbose,bRerunWarnNoV=TRUE,
	         bForceUpdate=FALSE,bX,bV,bF,bXTC,bCPT;
  bool       bMasterState;
  bool       bMC,ok;
  gmx_mc_move *mc_move;
  real       forcex=0,pos=0,pos0=0,forcey=0;  //apagar!
  int        force_flags;
  tensor     force_vir,force_vircopy,shake_vir,total_vir,av_vir,pres,ekin;
  int        i,m,status,nflex;
  rvec       mu_tot;
  t_vcm      *vcm;
  gmx_nlheur_t nlh;
  t_trxframe rerun_fr;
  gmx_repl_ex_t repl_ex=NULL;
  int        nchkpt=1;
  /* Booleans (disguised as a reals) to checkpoint and terminate mdrun */  
  real       chkpt=0,terminate=0,terminate_now=0;

  gmx_localtop_t *top;	
  t_mdebin *mdebin=NULL;
  t_state    *state=NULL;
  rvec       *f_global=NULL;
  int        n_xtc=-1;
  rvec       *x_xtc=NULL;
  gmx_enerdata_t *enerd,*enerdcopy,*enerd2;
  rvec       *f;
  gmx_global_stat_t gstat;
  gmx_update_t upd=NULL;
  t_graph    *graph=NULL;

  bool        bFFscan;
  gmx_groups_t *groups;
  gmx_ekindata_t *ekind;
  gmx_shellfc_t shellfc;
  int         count,nconverged=0;
  real        timestep=0;
  double      tcount=0;
  bool        bIonize=FALSE;
  bool        bTCR=FALSE,bConverged=TRUE,bOK,bSumEkinhOld,bExchanged;
  bool        bAppend;
  real        temp0,mu_aver=0,dvdl;
  int         a0,a1,gnx=0,ii;
  atom_id     *grpindex=NULL;
  char        *grpname;
  t_coupl_rec *tcr=NULL;
  rvec        *xcopy=NULL,*vcopy=NULL;
  matrix      boxcopy,lastbox;
  double      cycles;
  int         reset_counters=-1;
  char        sbuf[22],sbuf2[22];
  bool        bHandledSignal=FALSE;
  real        epot_delta=0,volume_delta,deltaH;
  bool        update_box=FALSE,bBOXok=TRUE;
  rvec        box_size;
  int         seed,ai,aj,ak,a,b,c,d;
  int         jj;
  real        deltax;
  gmx_rng_t   rng;
  gmx_rng_t   rng2;
  real        bolt;
  real        deltadih; //teste
#ifdef GMX_FAHCORE
  /* Temporary addition for FAHCORE checkpointing */
  int chkpt_ret;
#endif

  
    /* Check for special mdrun options */
    bRerunMD = (Flags & MD_RERUN);
    bIonize  = (Flags & MD_IONIZE);
    bFFscan  = (Flags & MD_FFSCAN);
    bAppend  = (Flags & MD_APPENDFILES);

    bMC = (ir->eI == eiMC);
    if(bMC) 
    {
     seed = make_seed();
     //seed = 24030;  ///*******************
     seed = 1226842470;
     rng=gmx_rng_init(seed);
     seed = make_seed();
     //seed = 24030;  ///*******************
     rng2=gmx_rng_init(seed);
    } 
    if (bRerunMD)
    {
        /* Since we don't know if the frames read are related in any way,
         * rebuild the neighborlist at every step.
         */
        ir->nstlist       = 1;
        ir->nstcalcenergy = 1;
        nstglobalcomm     = 1;
    }

    check_ir_old_tpx_versions(cr,fplog,ir,top_global);

    nstglobalcomm = check_nstglobalcomm(fplog,cr,nstglobalcomm,ir);
    bGStatEveryStep = (nstglobalcomm == 1);

    if (!bGStatEveryStep && ir->nstlist == -1 && fplog != NULL)
    {
        fprintf(fplog,
                "To reduce the energy communication with nstlist = -1\n"
                "the neighbor list validity should not be checked at every step,\n"
                "this means that exact integration is not guaranteed.\n"
                "The neighbor list validity is checked after:\n"
                "  <n.list life time> - 2*std.dev.(n.list life time)  steps.\n"
                "In most cases this will result in exact integration.\n"
                "This reduces the energy communication by a factor of 2 to 3.\n"
                "If you want less energy communication, set nstlist > 3.\n\n");
    }

    if (bRerunMD || bFFscan)
    {
        ir->nstxtcout = 0;
    }

    groups = &top_global->groups;

    /* Initial values */
    init_md(fplog,cr,ir,&t,&t0,&state_global->lambda,&lam0,
            nrnb,top_global,&upd,
            nfile,fnm,&fp_trn,&fp_xtc,&fp_ene,&fn_cpt,
            &fp_dhdl,&fp_field,&mdebin,
            force_vir,shake_vir,mu_tot,&bNEMD,&bSimAnn,&vcm,Flags);

    /* Energy terms and groups */
    snew(enerd,1);
    init_enerdata(top_global->groups.grps[egcENER].nr,ir->n_flambda,enerd);

    if(bMC)
    {
     snew(enerdcopy,1);
     init_enerdata(top_global->groups.grps[egcENER].nr,ir->n_flambda,enerdcopy);
     snew(enerd2,1);
     init_enerdata(top_global->groups.grps[egcENER].nr,ir->n_flambda,enerd2);
    }
    if (DOMAINDECOMP(cr))
    {
        f = NULL;
    }
    else
    {
        snew(f,top_global->natoms);
    }
    /* Kinetic energy data */
    snew(ekind,1);
    init_ekindata(fplog,top_global,&(ir->opts),ekind);
    /* Copy the cos acceleration to the groups struct */
    ekind->cosacc.cos_accel = ir->cos_accel;
    
    gstat = global_stat_init(ir);

    debug_gmx();

    /* Check for polarizable models and flexible constraints */
    shellfc = init_shell_flexcon(fplog,
                                 top_global,n_flexible_constraints(constr),
                                 (ir->bContinuation || 
                                  (DOMAINDECOMP(cr) && !MASTER(cr))) ?
                                 NULL : state_global->x);
    
    if (DEFORM(*ir))
    {
        set_deform_reference_box(upd,init_step_tpx,box_tpx);
    }

  {
    double io = compute_io(ir,top_global->natoms,groups,mdebin->ebin->nener,1);
    if ((io > 2000) && MASTER(cr))
      fprintf(stderr,
	      "\nWARNING: This run will generate roughly %.0f Mb of data\n\n",
	      io);
  }
 
  if (DOMAINDECOMP(cr)) {
    top = dd_init_local_top(top_global);

    snew(state,1);
    dd_init_local_state(cr->dd,state_global,state);

    if (DDMASTER(cr->dd) && ir->nstfout) {
      snew(f_global,state_global->natoms);
    }
  } else {
    if (PAR(cr) && !bMC) {
      /* Initialize the particle decomposition and split the topology */
      top = split_system(fplog,top_global,ir,cr);

      pd_cg_range(cr,&fr->cg0,&fr->hcg);
      pd_at_range(cr,&a0,&a1);
    } else {
      top = gmx_mtop_generate_local_top(top_global,ir);

      a0 = 0;
      a1 = top_global->natoms;
    }

    state = partdec_init_local_state(cr,state_global);
    f_global = f;

    atoms2md(top_global,ir,0,NULL,a0,a1-a0,mdatoms);

    if (vsite) {
      set_vsite_top(vsite,top,mdatoms,cr);
    }


    if ((ir->ePBC != epbcNONE && !ir->bPeriodicMols) || bMC) {
      graph = mk_graph(fplog,&(top->idef),0,top_global->natoms,FALSE,FALSE);
    }


    if (shellfc) {
      make_local_shells(cr,mdatoms,shellfc);
    }

    if (ir->pull && PAR(cr)) {
      dd_make_local_pull_groups(NULL,ir->pull,mdatoms);
    }
  }

    if (DOMAINDECOMP(cr))
    {
        /* Distribute the charge groups over the nodes from the master node */
        dd_partition_system(fplog,ir->init_step,cr,TRUE,1,
                            state_global,top_global,ir,
                            state,&f,mdatoms,top,fr,
                            vsite,shellfc,constr,
                            nrnb,wcycle,FALSE);
    }
	
	/* If not DD, copy gb data */
    if(ir->implicit_solvent && !DOMAINDECOMP(cr))
    {
        make_local_gb(cr,fr->born,ir->gb_algorithm);
    }
	
    update_mdatoms(mdatoms,state->lambda);

  if (MASTER(cr))
  {
    /* Update mdebin with energy history if appending to output files */
    if ( Flags & MD_APPENDFILES )
    {
      restore_energyhistory_from_state(mdebin,&state_global->enerhist);
    }
    /* Set the initial energy history in state to zero by updating once */
    update_energyhistory(&state_global->enerhist,mdebin);
  }	
	
	
  if ((state->flags & (1<<estLD_RNG)) && (Flags & MD_READ_RNG)) {
    /* Set the random state if we read a checkpoint file */
    set_stochd_state(upd,state);
  }

  /* Initialize constraints */
  if (constr) {
    if (!DOMAINDECOMP(cr))
		set_constraints(constr,top,ir,mdatoms,cr);
  }

  /* Check whether we have to GCT stuff */
  bTCR = ftp2bSet(efGCT,nfile,fnm);
  if (bTCR) {
    if (MASTER(cr)) {
      fprintf(stderr,"Will do General Coupling Theory!\n");
    }
    gnx = top_global->mols.nr;
    snew(grpindex,gnx);
    for(i=0; (i<gnx); i++) {
      grpindex[i] = i;
    }
  }
  
  if (repl_ex_nst > 0 && MASTER(cr))
    repl_ex = init_replica_exchange(fplog,cr->ms,state_global,ir,
				    repl_ex_nst,repl_ex_seed);

    if (!ir->bContinuation && !bRerunMD)
    {
        if (mdatoms->cFREEZE && (state->flags & (1<<estV)))
        {
            /* Set the velocities of frozen particles to zero */
            for(i=mdatoms->start; i<mdatoms->homenr; i++)
            {
                for(m=0; m<DIM; m++)
                {
                    if (ir->opts.nFreeze[mdatoms->cFREEZE[i]][m])
                    {
                        state->v[i][m] = 0;
                    }
                }
            }
        }
        if (constr)
        {
            /* Constrain the initial coordinates and velocities */
            do_constrain_first(fplog,constr,ir,mdatoms,state,
                               graph,cr,nrnb,fr,&top->idef);
        }
        if (vsite)
        {
            /* Construct the virtual sites for the initial configuration */
            construct_vsites(fplog,vsite,state->x,nrnb,ir->delta_t,NULL,
                             top->idef.iparams,top->idef.il,
                             fr->ePBC,fr->bMolPBC,graph,cr,state->box);
        }
    }
    
    debug_gmx();
	
  if (Flags & MD_READ_EKIN)
  {
      restore_ekinstate_from_state(cr,ekind,&state_global->ekinstate);
  }
  else
  {
      /* Compute initial EKin for all.. */
      calc_ke_part(state,&(ir->opts),mdatoms,ekind,nrnb);
      debug_gmx();

      if (PAR(cr) && !bMC)
      {
	  GMX_MPE_LOG(ev_global_stat_start);
	  
	  global_stat(fplog,gstat,cr,enerd,force_vir,shake_vir,mu_tot,
		      ir,ekind,FALSE,constr,vcm,NULL,NULL,&terminate,
		      top_global,state);
	  
	  GMX_MPE_LOG(ev_global_stat_finish);
      }
       debug_gmx();
  }

  /* Calculate the initial half step temperature */
  temp0 = sum_ekin(TRUE,&(ir->opts),ekind,ekin,NULL);

  debug_gmx();
   
  /* Initiate data for the special cases */
  if (bFFscan || bMC) {
    snew(xcopy,state->natoms);
    if(!bMC)
    {
     snew(vcopy,state->natoms);
    }
    for(ii=0; (ii<state->natoms); ii++) {
      copy_rvec(state->x[ii],xcopy[ii]);
      if (!bMC)
      {
       copy_rvec(state->v[ii],vcopy[ii]);
      }
    }
    copy_mat(state->box,boxcopy);
  } 

  if(bMC) {
   snew(state->mc_move,1);
   mc_move = state->mc_move;
   init_enerd_mc(mc_move,top,mdatoms->homenr);
   snew(mc_move->group,MC_NR);
   snew(mc_move->bNS,top->cgs.nr+1);
   snew(mc_move->xcm,top_global->mols.nr);
   mc_move->n_mc = FALSE;
   mc_move->cgsnr = top->cgs.nr;
   mc_move->homenr = mdatoms->homenr;
   init_ns_mc(&fr->ns,top,mdatoms,mc_move);

   for(ii=0;ii<top->cgs.nr;ii++)
    mc_move->bNS[ii]=TRUE;

   mc_move->group[MC_BONDS].ilist = &top_global->moltype[0].mc_bonds;
   mc_move->group[MC_ANGLES].ilist = &top_global->moltype[0].mc_angles;
   mc_move->group[MC_DIHEDRALS].ilist = &top_global->moltype[0].mc_dihedrals;
   mc_move->group[MC_CRA].ilist = &top_global->moltype[0].mc_cra;
  
   mc_move->xprev = xcopy;
   fr->n_mc = FALSE;
  }
    if (MASTER(cr))
    {
        if (constr && !ir->bContinuation && ir->eConstrAlg == econtLINCS)
        {
            fprintf(fplog,
                    "RMS relative constraint deviation after constraining: %.2e\n",
                    constr_rmsd(constr,FALSE));
        }
        fprintf(fplog,"Initial temperature: %g K\n",temp0);
        if (bRerunMD)
        {
            fprintf(stderr,"starting md rerun '%s', reading coordinates from"
                    " input trajectory '%s'\n\n",
                    *(top_global->name),opt2fn("-rerun",nfile,fnm));
            if (bVerbose)
            {
                fprintf(stderr,"Calculated time to finish depends on nsteps from "
                        "run input file,\nwhich may not correspond to the time "
                        "needed to process input trajectory.\n\n");
            }
        }
        else
        {
            fprintf(stderr,"starting mdrun '%s'\n",
                    *(top_global->name));
            if (ir->init_step > 0)
            {
                fprintf(stderr,"%s steps, %8.1f ps (continuing from step %s, %8.1f ps).\n",
                        gmx_step_str(ir->init_step+ir->nsteps,sbuf),
                        (ir->init_step+ir->nsteps)*ir->delta_t,
                        gmx_step_str(ir->init_step,sbuf2),
                        ir->init_step*ir->delta_t);
            }
            else
            {
                fprintf(stderr,"%s steps, %8.1f ps.\n",
                        gmx_step_str(ir->nsteps,sbuf),ir->nsteps*ir->delta_t);
            }
        }
        fprintf(fplog,"\n");
    }

  /* Set and write start time */
  runtime_start(runtime);
  print_date_and_time(fplog,cr->nodeid,"Started mdrun",runtime);
  wallcycle_start(wcycle,ewcRUN);
  if (fplog)
    fprintf(fplog,"\n");
  /* safest point to do file checkpointing is here.  More general point would be immediately before integrator call */
  #ifdef GMX_FAHCORE
	chkpt_ret=fcCheckPointParallel( (MASTER(cr)==0),
             NULL,0);
  if ( chkpt_ret == 0 ) 
        gmx_fatal( 3,__FILE__,__LINE__, "Checkpoint error on step %d\n", 0 );
  #endif
			 
  debug_gmx();
  /***********************************************************
   *
   *             Loop over MD steps 
   *
   ************************************************************/
  
    /* if rerunMD then read coordinates and velocities from input trajectory */
    if (bRerunMD)
    {
        if (getenv("GMX_FORCE_UPDATE"))
        {
            bForceUpdate = TRUE;
        }

        bNotLastFrame = read_first_frame(&status,opt2fn("-rerun",nfile,fnm),
                                         &rerun_fr,TRX_NEED_X | TRX_READ_V);
        if (rerun_fr.natoms != top_global->natoms)
        {
            gmx_fatal(FARGS,
                      "Number of atoms in trajectory (%d) does not match the "
                      "run input file (%d)\n",
                      rerun_fr.natoms,top_global->natoms);
        }
        if (ir->ePBC != epbcNONE)
        {
            if (!rerun_fr.bBox)
            {
                gmx_fatal(FARGS,"Rerun trajectory frame step %d time %f does not contain a box, while pbc is used",rerun_fr.step,rerun_fr.time);
            }
            if (max_cutoff2(ir->ePBC,rerun_fr.box) < sqr(fr->rlistlong))
            {
                gmx_fatal(FARGS,"Rerun trajectory frame step %d time %f has too small box dimensions",rerun_fr.step,rerun_fr.time);
            }

            /* Set the shift vectors.
             * Necessary here when have a static box different from the tpr box.
             */
            calc_shifts(rerun_fr.box,fr->shift_vec);
        }
    }

    /* loop over MD steps or if rerunMD to end of input trajectory */
    bFirstStep = TRUE;
    /* Skip the first Nose-Hoover integration when we get the state from tpx */
    bStateFromTPX = !opt2bSet("-cpi",nfile,fnm);
    bLastStep = FALSE;
    bSumEkinhOld = FALSE;
    bExchanged = FALSE;
    
    step = ir->init_step;
    step_rel = 0;
    
    if (ir->nstlist == -1)
    {
        init_nlistheuristics(&nlh,bGStatEveryStep,step);
    }
    bLastStep = (bRerunMD || step_rel > ir->nsteps);

     real dih1,dih2;
     rvec v1,v2,v3,v4,v5;
     real f1,f2,f3;
     int i1,i2,i3;
     int hey1,hey2,hey3,hey4;

    while (!bLastStep || (bRerunMD && bNotLastFrame)) {
        
        wallcycle_start(wcycle,ewcSTEP);
        
        GMX_MPE_LOG(ev_timestep1);
        
        if (bRerunMD) {
            if (rerun_fr.bStep) {
                step = rerun_fr.step;
                step_rel = step - ir->init_step;
            }
            if (rerun_fr.bTime)
                t = rerun_fr.time;
            else
                t = step;
        } else {
            bLastStep = (step_rel == ir->nsteps);
            
            t = t0 + step*ir->delta_t;
        }

        if (ir->efep != efepNO)
        {
            if (bRerunMD && rerun_fr.bLambda && (ir->delta_lambda!=0))
            {
                state_global->lambda = rerun_fr.lambda;
            }
            else
            {
                state_global->lambda = lam0 + step*ir->delta_lambda;
            }
            state->lambda = state_global->lambda;
            bDoDHDL = do_per_step(step,ir->nstdhdl);
        }
        
        if (bSimAnn) 
        {
            update_annealing_target_temp(&(ir->opts),t);
        }
        
        if (bRerunMD)
        {
            if (!(DOMAINDECOMP(cr) && !MASTER(cr)))
            {
                for(i=0; i<state_global->natoms; i++)
                {
                    copy_rvec(rerun_fr.x[i],state_global->x[i]);
                }
                if (rerun_fr.bV)
                {
                    for(i=0; i<state_global->natoms; i++)
                    {
                        copy_rvec(rerun_fr.v[i],state_global->v[i]);
                    }
                }
                else
                {
                    for(i=0; i<state_global->natoms; i++)
                    {
                        clear_rvec(state_global->v[i]);
                    }
                    if (bRerunWarnNoV)
                    {
                        fprintf(stderr,"\nWARNING: Some frames do not contain velocities.\n"
                                "         Ekin, temperature and pressure are incorrect,\n"
                                "         the virial will be incorrect when constraints are present.\n"
                                "\n");
                        bRerunWarnNoV = FALSE;
                    }
                }
            }
            copy_mat(rerun_fr.box,state_global->box);
            copy_mat(state_global->box,state->box);

            if (vsite && (Flags & MD_RERUN_VSITE))
            {
                if (DOMAINDECOMP(cr))
                {
                    gmx_fatal(FARGS,"Vsite recalculation with -rerun is not implemented for domain decomposition, use particle decomposition");
                }
                if (graph)
                {
                    /* Following is necessary because the graph may get out of sync
                     * with the coordinates if we only have every N'th coordinate set
                     */
                    mk_mshift(fplog,graph,fr->ePBC,state->box,state->x);
                    shift_self(graph,state->box,state->x);
                }
                construct_vsites(fplog,vsite,state->x,nrnb,ir->delta_t,state->v,
                                 top->idef.iparams,top->idef.il,
                                 fr->ePBC,fr->bMolPBC,graph,cr,state->box);
                if (graph)
                {
                    unshift_self(graph,state->box,state->x);
                }
            }
        }
        
        /* Stop Center of Mass motion */
        bStopCM = (ir->comm_mode != ecmNO && do_per_step(step,ir->nstcomm));
        
        /* Copy back starting coordinates in case we're doing a forcefield scan */
        if (bFFscan)
        {
            for(ii=0; (ii<state->natoms); ii++)
            {
                copy_rvec(xcopy[ii],state->x[ii]);
                copy_rvec(vcopy[ii],state->v[ii]);
            }
            copy_mat(boxcopy,state->box);
        }
        
        if (bRerunMD)
        {
            /* for rerun MD always do Neighbour Searching */
            bNS = (bFirstStep || ir->nstlist != 0);
            bNStList = bNS;
        }
        else
        {
            /* Determine whether or not to do Neighbour Searching and LR */
            if(bMC)
            {
             ir->nstlist = 1000;
             //ir->nst_p= 1000;
            }
            bNStList = (ir->nstlist > 0  && step % ir->nstlist == 0);

            bNS = (bFirstStep || bExchanged || bNStList ||
                   (ir->nstlist == -1 && nlh.nabnsb > 0));
            
            if (bNS && ir->nstlist == -1)
            {
                set_nlistheuristics(&nlh,bFirstStep || bExchanged,step);
            }
        } 
        
        if (terminate_now > 0 || (terminate_now < 0 && bNS))
        {
            bLastStep = TRUE;
        }

        /* Determine whether or not to update the Born radii if doing GB */
        bBornRadii=bFirstStep;
        if(ir->implicit_solvent && (step % ir->nstgbradii==0))
        {
            bBornRadii=TRUE;
        }
		
        do_log = do_per_step(step,ir->nstlog) || bFirstStep || bLastStep;
        do_verbose = bVerbose &&
            (step % stepout == 0 || bFirstStep || bLastStep);
        
        if (bNS && !(bFirstStep && ir->bContinuation && !bRerunMD))
        {
            if (bRerunMD)
            {
                bMasterState = TRUE;
            }
            else
            {
                bMasterState = FALSE;
                /* Correct the new box if it is too skewed */
                if (DYNAMIC_BOX(*ir))
                {
                    if (correct_box(fplog,step,state->box,graph))
                    {
                        bMasterState = TRUE;
                    }
                }
                if (DOMAINDECOMP(cr) && bMasterState)
                {
                    dd_collect_state(cr->dd,state,state_global);
                }
            }
            
            if (DOMAINDECOMP(cr))
            {
                /* Repartition the domain decomposition */
                wallcycle_start(wcycle,ewcDOMDEC);
                dd_partition_system(fplog,step,cr,
                                    bMasterState,nstglobalcomm,
                                    state_global,top_global,ir,
                                    state,&f,mdatoms,top,fr,
                                    vsite,shellfc,constr,
                                    nrnb,wcycle,do_verbose);
                wallcycle_stop(wcycle,ewcDOMDEC);
            }
        }
        
        if (MASTER(cr) && do_log && !bFFscan)
        {
            print_ebin_header(fplog,step,t,state->lambda);
            if(bMC) {
             print_mc_ratio(fplog,state->step_ac,state->step_tot,state->vol_ac,state->vol_tot);
            }
        }
        
        if (ir->efep != efepNO)
        {
            update_mdatoms(mdatoms,state->lambda); 
        }

        if (bRerunMD && rerun_fr.bV)
        {
            /* We need the kinetic energy at minus the half step for determining
             * the full step kinetic energy and possibly for T-coupling.
             */
            calc_ke_part(state,&(ir->opts),mdatoms,ekind,nrnb);
            if (PAR(cr) && !bMC)
            {
                global_stat(fplog,gstat,cr,enerd,force_vir,shake_vir,mu_tot,
                            ir,ekind,FALSE,constr,vcm,NULL,NULL,&terminate,
                            top_global,state);
            }
            sum_ekin(FALSE,&(ir->opts),ekind,ekin,NULL);
        }
        
        clear_mat(force_vir);
        
        /* Ionize the atoms if necessary */
        if (bIonize)
        {
            ionize(fplog,mdatoms,top_global,t,ir,state->x,state->v,
                   mdatoms->start,mdatoms->start+mdatoms->homenr,state->box,cr);
        }
        
        /* Update force field in ffscan program */
        if (bFFscan)
        {
            if (update_forcefield(fplog,
                                  nfile,fnm,fr,
                                  mdatoms->nr,state->x,state->box)) {
                if (gmx_parallel_env)
                {
                    gmx_finalize();
                }
                exit(0);
            }
        }
        
        GMX_MPE_LOG(ev_timestep2);
        
        if ((bNS || bLastStep) && (step > ir->init_step) && !bRerunMD)
        {
            bCPT = (chkpt > 0 || (bLastStep && (Flags & MD_CONFOUT)));
            if (bCPT)
            {
                chkpt = 0;
            }
        }
        else
        {
            bCPT = FALSE;
        }

        /* Determine the pressure:
         * always when we want exact averages in the energy file,
         * at ns steps when we have pressure coupling,
         * otherwise only at energy output steps (set below).
         */
        bNstEner = (bGStatEveryStep || do_per_step(step,ir->nstcalcenergy));
        bCalcEner = bNstEner;
        
        /* Do we need global communication ? */
        bGStat = (bCalcEner || bStopCM ||
                  (ir->nstlist == -1 && !bRerunMD && step >= nlh.step_nscheck));
        
        do_ene = (do_per_step(step,ir->nstenergy) || bLastStep);

        if(bMC) {
         do_vir = (do_per_step(step,ir->nstvir) || bLastStep);
        }
        
        if (do_ene || do_log || do_vir)
        {
            bCalcEner = TRUE;
            bGStat    = TRUE;
        }
        
        if(!bMC || do_vir) 
        {
         force_flags = (GMX_FORCE_STATECHANGED |
                       GMX_FORCE_ALLFORCES |
                       (bNStList ? GMX_FORCE_DOLR : 0) |
                       GMX_FORCE_SEPLRF |
                       (bCalcEner ? GMX_FORCE_VIRIAL : 0) |
                       (bDoDHDL ? GMX_FORCE_DHDL : 0));
        }
        else
        {
         force_flags = (GMX_FORCE_STATECHANGED |
                       GMX_FORCE_NONBONDED | GMX_FORCE_BONDED |
                       (bNStList ? GMX_FORCE_DOLR : 0) |
                       GMX_FORCE_SEPLRF);
        }
        if (shellfc)
        {
            /* Now is the time to relax the shells */
            count=relax_shell_flexcon(fplog,cr,bVerbose,bFFscan ? step+1 : step,
                                      ir,bNS,force_flags,
                                      bStopCM,top,top_global,
                                      constr,enerd,fcd,
                                      state,f,force_vir,mdatoms,
                                      nrnb,wcycle,graph,groups,
                                      shellfc,fr,bBornRadii,t,mu_tot,
                                      state->natoms,&bConverged,vsite,
                                      fp_field);
            tcount+=count;
            
            if (bConverged)
            {
                nconverged++;
            }
        }
        else
        {
            /* The coordinates (x) are shifted (to get whole molecules)
             * in do_force.
             * This is parallellized as well, and does communication too. 
             * Check comments in sim_util.c
             */
     hey1=127;hey2=129;hey3=144;hey4=146;
     dih1 = dih_angle(state->x[hey1],state->x[hey2],state->x[hey3],state->x[hey4],NULL,v1,v2,v3,v4,v5,&f1,&f2,&i1,&i2,&i3);
     printf("\ndih1_0 %f\n\n",dih1*180/M_PI);
            if(bMC)
            {
              if(step_rel && !update_box && !do_ene && !do_vir) {
               set_bexclude_mc(top,mc_move,fr,FALSE);
              }
              else
              {
               mc_move->cgs = top->cgs.nr;
               mc_move->start = mdatoms->start;
               mc_move->end = mdatoms->homenr;
              }
              if(!fr->n_mc || bNS)
              {
               for(ii=0;ii<top->cgs.nr+1;ii++)
                mc_move->bNS[ii]=TRUE;
              }
              
            }
            //printf("step %d\n",(int)step_rel);
            do_force(fplog,cr,ir,step,nrnb,wcycle,top,top_global,groups,
                     state->box,state->x,&state->hist,bMC ? mc_move : NULL,
                     f,force_vir,mdatoms,enerd,fcd,
                     state->lambda,graph,
                     fr,vsite,mu_tot,t,fp_field,ed,bBornRadii,
                     (bNS ? GMX_FORCE_NS : 0) | force_flags);
            if(bMC) {
             if(step_rel) {

              //epot_delta = delta_enerd_mc(enerd,enerdcopy,top,mc_move,&top->idef,fr,mdatoms->homenr);

              sub_enerdata(enerd,enerdcopy,enerd2);
              epot_delta = enerd2->term[F_EPOT];
              for(ii=0;ii<F_NRE;ii++) {
               if(enerd->term[ii] && 1 == 2)
               printf("enerdp %f  %f %d %d %d\n",enerd2->term[ii],enerdcopy->term[ii],ii,(int)step_rel,mc_move->mvgroup);
              }
            //printf("to aki %d %f\n",(int)step_rel,epot_delta);
              //if(!update_box)
               //sum_enerdata(enerd2,enerd,enerd);

            //printf("enerd1 %f\n",enerd->term[F_EPOT]);
             }
             else 
             {
              copy_enerdata(enerd,enerdcopy);
              //mc_move->bNS[mc_move->cgs] = FALSE;
             }

             deltaH = epot_delta;
             if(update_box) {
              volume_delta    = det(state->box) - det(boxcopy);
              deltaH += ir->ref_p[XX][XX]*volume_delta/PRESFAC;
              deltaH -= top_global->mols.nr*BOLTZ*ir->opts.ref_t[0]*log(det(state->box)/det(boxcopy));
             }

             bolt = gmx_rng_uniform_real(rng);
             if(fr->bEwald && bMC && 1 == 2) 
             {
              if (step_rel && !update_box && 1 == 2 && !(deltaH <= 0 || (deltaH > 0 && exp(-deltaH/(BOLTZ*ir->opts.ref_t[0])) > 0.4*bolt)))
              {
               bolt = 2;  /* Preliminary energy check (without recip PME) */
              }
              else
              {
               do_recip_mc(fplog,step,fr,ir,&(top->idef),
                      cr,nrnb,wcycle,mdatoms,&(ir->opts),
                      state->x,&state->hist,f,enerd,fcd,fr->born,
                      &(top->atomtypes),bBornRadii,state->box,
                      state->lambda,graph,&(top->excls),fr->mu_tot,
                      force_flags,NULL,mc_move);
              
        if (force_flags & GMX_FORCE_VIRIAL)
        {
            virial_mc(fr,mdatoms,f,force_vir);
        }
               deltaH += enerd->term[F_COUL_RECIP] - mc_move->enerd_prev[F_COUL_RECIP][0];
               //deltaH += enerd->term[F_COUL_RECIP];
               enerd->term[F_EPOT] += enerd->term[F_COUL_RECIP];
              for(ii=0;ii<F_NRE;ii++) {
               if(enerd->term[ii] && 1 == 2)
               printf("enerd %f %f %d %d %d %f\n",enerd->term[ii],enerdcopy->term[ii],ii,mc_move->mvgroup,(int)step_rel,state->x[0][0]);
              }
              }
             }
 printf("bias md %f\n",mc_move->bias);
             if(bBOXok) {
              /*if (accept_mc(deltaH,bolt,ir->opts.ref_t[0],mc_move)) {
                printf("\n\n\nto aki\n\n\n");
                for(ii=mdatoms->start; ii<(mdatoms->start+mdatoms->homenr); ii++) {
                 copy_rvec(xcopy[ii],state->x[ii]);
                }
                state->step_ac[mc_move->mvgroup]++;
                copy_mat(boxcopy,state->box);
                copy_enerdata(enerdcopy,enerd);
                copy_mat(force_vircopy,force_vir);
              }*/
              if (!step_rel || accept_mc(deltaH,bolt,ir->opts.ref_t[0],mc_move)) {
               mc_move->bNS[mc_move->cgs] = TRUE;
     dih1 = dih_angle(xcopy[hey1],xcopy[hey2],xcopy[hey3],xcopy[hey4],NULL,v1,v2,v3,v4,v5,&f1,&f2,&i1,&i2,&i3);
     dih2 = dih_angle(state->x[hey1],state->x[hey2],state->x[hey3],state->x[hey4],NULL,v1,v2,v3,v4,v5,&f1,&f2,&i1,&i2,&i3);
     deltadih = dih2-dih1;
     enerd->term[F_EPOT]=deltadih*180/M_PI;
     enerd->term[F_BONDS]=mc_move->gauss;
     enerd->term[F_ANGLES]=mc_move->d2;
     printf("deltadih %f %f %f\n",deltadih,dih1,dih2);
     if(dih2-dih1 < 0)
     printf("\n\n\ntatatatata %f %f %f\n\n\n",(dih2-dih1),dih1,dih2);
               if(update_box) {
                state->vol_ac++;
               }
               else 
               {
                state->step_ac[mc_move->mvgroup]++;
               }

               for(ii=mdatoms->start; ii<(mdatoms->start+mdatoms->homenr); ii++) {
                copy_rvec(state->x[ii],xcopy[ii]);
               }
               copy_mat(state->box,boxcopy);
               /*if((!update_box && do_ene) || do_vir) {
                do_force(fplog,cr,ir,step,nrnb,wcycle,top,top_global,groups,
                     state->box,state->x,&state->hist,mc_move,
                     f,force_vir,mdatoms,enerd,fcd,
                     state->lambda,graph,
                     fr,vsite,mu_tot,t,fp_field,ed,bBornRadii,
                     (bNS ? GMX_FORCE_NS : 0) | force_flags);
               }*/
               copy_enerdata(enerd,enerdcopy);
               //clean_enerd_mc(mc_move,top,fr,mdatoms->homenr,TRUE);
               if(do_vir)
               {
                copy_mat(force_vir,force_vircopy);
               }
               else
               {
                copy_mat(force_vircopy,force_vir);
               }
              }
              else {
               //clean_enerd_mc(mc_move,top,fr,mdatoms->homenr,FALSE);
               if (DOMAINDECOMP(cr)) {
               }
               else {
                for(ii=mdatoms->start; ii<(mdatoms->start+mdatoms->homenr); ii++) {
                 copy_rvec(xcopy[ii],state->x[ii]);
                }
                copy_mat(boxcopy,state->box);
                copy_enerdata(enerdcopy,enerd);
                copy_mat(force_vircopy,force_vir);
               }
              }
             }
             else
             {
             // clean_enerd_mc(mc_move,top,fr,mdatoms->homenr,FALSE);
                for(ii=mdatoms->start; ii<(mdatoms->start+mdatoms->homenr); ii++) {
                 copy_rvec(xcopy[ii],state->x[ii]);
                }
                copy_mat(boxcopy,state->box);
                copy_enerdata(enerdcopy,enerd);
                copy_mat(force_vircopy,force_vir);
             }
             if(PAR(cr))
             {
              gmx_bcast(sizeof(boxcopy),boxcopy,cr);
              gmx_bcast(sizeof(xcopy),xcopy,cr);
             }
            
             if(update_box) {
              state->vol_tot++;
             }
             else
             {
              state->step_tot[mc_move->mvgroup]++;
             }
            }
        }
              if(bMC && !update_box && !do_ene && !do_vir) {
               set_bexclude_mc(top,mc_move,fr,FALSE);
              }
        GMX_BARRIER(cr->mpi_comm_mygroup);
        
        if (bTCR)
        {
            mu_aver = calc_mu_aver(cr,state->x,mdatoms->chargeA,
                                   mu_tot,&top_global->mols,mdatoms,gnx,grpindex);
        }
        
        if (bTCR && bFirstStep)
        {
            tcr=init_coupling(fplog,nfile,fnm,cr,fr,mdatoms,&(top->idef));
            fprintf(fplog,"Done init_coupling\n"); 
            fflush(fplog);
        }
        
        /* Now we have the energies and forces corresponding to the 
         * coordinates at time t. We must output all of this before
         * the update.
         * for RerunMD t is read from input trajectory
         */
        GMX_MPE_LOG(ev_output_start);
        
        bX   = do_per_step(step,ir->nstxout);
        bV   = do_per_step(step,ir->nstvout);
        bF   = do_per_step(step,ir->nstfout);
        bXTC = do_per_step(step,ir->nstxtcout);
        
#ifdef GMX_FAHCORE
        bX = bX || bLastStep; /*enforce writing positions and velocities at end of run */
        bV = bV || bLastStep;
        bCPT = bCPT || fcCheckPointPending();  
        if (bCPT)
            fcRequestCheckPoint(); /* sync bCPT and fc record-keeping */
        
        if (MASTER(cr))
            fcReportProgress( ir->nsteps, step );
#endif
        
        if (bX || bV || bF || bXTC || bCPT)
        {
            wallcycle_start(wcycle,ewcTRAJ);
            if (bCPT)
            {
                if (state->flags & (1<<estLD_RNG))
                {
                    get_stochd_state(upd,state);
                }
                if (MASTER(cr))
                {
                    if (bSumEkinhOld)
                    {
                        state_global->ekinstate.bUpToDate = FALSE;
                    }
                    else
                    {
                        update_ekinstate(&state_global->ekinstate,ekind);
                        state_global->ekinstate.bUpToDate = TRUE;
                    }
                    update_energyhistory(&state_global->enerhist,mdebin);
                }
            }
     rvec v1,v2,v3,v4,v5;
     real f1,f2;
     int i1,i2,i3;
     real dih1;
     dih1 = dih_angle(state->x[hey1],state->x[hey2],state->x[hey3],state->x[hey4],NULL,v1,v2,v3,v4,v5,&f1,&f2,&i1,&i2,&i3);
     printf("\ndih1_2 %f\n\n",dih1*180/M_PI);
            write_traj(fplog,cr,fp_trn,bX,bV,bF,fp_xtc,bXTC,ir->xtcprec,fn_cpt,bCPT,
                       top_global,ir->eI,ir->simulation_part,step,t,state,state_global,f,f_global,&n_xtc,&x_xtc);
     dih1 = dih_angle(state->x[4],state->x[19],state->x[17],state->x[18],NULL,v1,v2,v3,v4,v5,&f1,&f2,&i1,&i2,&i3);
     //printf("dih1 %f\n",dih1*180/M_PI);
            debug_gmx();
            if (bLastStep && step_rel == ir->nsteps &&
                (Flags & MD_CONFOUT) && MASTER(cr) &&
                !bRerunMD && !bFFscan)
            {
                /* x and v have been collected in write_traj */
                fprintf(stderr,"\nWriting final coordinates.\n");
                if (ir->ePBC != epbcNONE && !ir->bPeriodicMols &&
                    DOMAINDECOMP(cr))
                {
                    /* Make molecules whole only for confout writing */
                    do_pbc_mtop(fplog,ir->ePBC,state->box,top_global,state_global->x);
                }
                write_sto_conf_mtop(ftp2fn(efSTO,nfile,fnm),
                                    *top_global->name,top_global,
                                    state_global->x,state_global->v,
                                    ir->ePBC,state->box);
                debug_gmx();
            }
            wallcycle_stop(wcycle,ewcTRAJ);
        }
        GMX_MPE_LOG(ev_output_finish);
        
        clear_mat(shake_vir);
        
        /* Box is changed in update() when we do pressure coupling,
         * but we should still use the old box for energy corrections and when
         * writing it to the energy file, so it matches the trajectory files for
         * the same timestep above. Make a copy in a separate array.
         */
        copy_mat(state->box,lastbox);
        
        GMX_MPE_LOG(ev_update_start);
        /* This is also parallellized, but check code in update.c */
        /* bOK = update(nsb->natoms,START(nsb),HOMENR(nsb),step,state->lambda,&ener[F_DVDL], */
        bOK = TRUE;
        if (!bRerunMD || rerun_fr.bV || bForceUpdate || bMC)
        {
            wallcycle_start(wcycle,ewcUPDATE);
            dvdl = 0;
            /* We can only do Berendsen coupling after we have summed
             * the kinetic energy or virial.
             * Since the happens in global_state after update,
             * we should only do it at step % nstlist = 1
             * with bGStatEveryStep=FALSE.
             */
            if(bMC) 
            {
             do {
              ii=(int)(gmx_rng_uniform_real(rng)*top_global->mols.nr);
             } while(ii >= top_global->mols.nr);
             mc_move->mol = ii;
             mc_move->start = top_global->mols.index[ii];
             mc_move->end = top_global->mols.index[ii+1];
             mc_move->nr = mc_move->end - mc_move->start;


             if (ir->nst_p && step_rel && !(step_rel % ir->nst_p)) {
              update_box = TRUE;
              mc_move->delta_v = (2.0*gmx_rng_uniform_real(rng)-1.0)*ir->volume;
             }
             else
              update_box = FALSE;

             mc_move->update_box = update_box;
             
 
            ok=FALSE;
            do
            {
             if(mc_move->nr > 1)
             {
              mc_move->mvgroup = uniform_int(rng,MC_NR);
             }
             else
             {
              mc_move->mvgroup = MC_TRANSLATE;
             }
              //mc_move->mvgroup = MC_CRA;

             switch (mc_move->mvgroup)  
             {
              case MC_TRANSLATE:
               if(ir->cm_translate)
               {
                for (ii=0;ii<DIM;ii++) {
                 mc_move->delta_x[ii] = (2.0*gmx_rng_uniform_real(rng)-1.0)*ir->cm_translate;
                }
                ok=TRUE;
               }
              break;
              case MC_ROTATEX:
               if(ir->cm_rot)
               {
                mc_move->delta_phi[XX] = M_PI*(2.0*gmx_rng_uniform_real(rng)-1.0)*ir->cm_rot/180.0;
                mc_move->delta_phi[YY] = 0.0;
                mc_move->delta_phi[ZZ] = 0.0;
                ok=TRUE;
               }
              break;
              case MC_ROTATEY:
               if(ir->cm_rot)
               {
                mc_move->delta_phi[YY] = M_PI*(2.0*gmx_rng_uniform_real(rng)-1.0)*ir->cm_rot/180.0;
                mc_move->delta_phi[XX] = 0.0;
                mc_move->delta_phi[ZZ] = 0.0;
                ok=TRUE;
               }
              break;
              case MC_ROTATEZ:
               if(ir->cm_rot)
               {
                mc_move->delta_phi[ZZ] = M_PI*(2.0*gmx_rng_uniform_real(rng)-1.0)*ir->cm_rot/180.0;
                mc_move->delta_phi[YY] = 0.0;
                mc_move->delta_phi[XX] = 0.0;
                ok=TRUE;
               }
              break;
              case MC_BONDS:
               if((mc_move->group[MC_BONDS].ilist)->nr > 0 && ir->bond_stretch)  
               {
                jj = uniform_int(rng,(mc_move->group[MC_BONDS].ilist)->nr/2);
                deltax=(2*gmx_rng_uniform_real(rng)-1.0)*ir->bond_stretch;
                set_mcmove(&(mc_move->group[MC_BONDS]),rng,deltax,2,mc_move->start,jj);
                ok=TRUE;
               }
               break;
              case MC_ANGLES:
               if((mc_move->group[MC_ANGLES].ilist)->nr > 0 && ir->angle_bend) 
               {
                jj = uniform_int(rng,(mc_move->group[MC_ANGLES].ilist)->nr/3);
                deltax=(2*gmx_rng_uniform_real(rng)-1.0)*ir->angle_bend*M_PI/180.0;
                set_mcmove(&(mc_move->group[MC_ANGLES]),rng,deltax,3,mc_move->start,jj);
                ok=TRUE;
               }
               break;
              case MC_DIHEDRALS:
               if((mc_move->group[MC_DIHEDRALS].ilist)->nr > 0 && ir->dihedral_rot) 
               {
             printf("step2 %d\n",step_rel);
                jj = uniform_int(rng,(mc_move->group[MC_DIHEDRALS].ilist)->nr/2);
                deltax=(2*gmx_rng_uniform_real(rng)-1.0)*ir->dihedral_rot*M_PI/180.0;
                //deltax=30*M_PI/180.0;
                set_mcmove(&(mc_move->group[MC_DIHEDRALS]),rng,deltax,2,mc_move->start,jj);
                ok=TRUE;
               }
               break;
              case MC_CRA:
               if((mc_move->group[MC_CRA].ilist)->nr > 0) 
               {
                ok=TRUE;
               }
               break;
            }
           } while(!ok);
           }
           mc_move->bias = 1;
            update(fplog,step,&dvdl,ir,mdatoms,state,graph,
                   f,fr->bTwinRange && bNStList,fr->f_twin,fcd,
                   &top->idef,ekind,ir->nstlist==-1 ? &nlh.scale_tot : NULL,
                   cr,fr,nrnb,&top_global->mols,wcycle,upd,constr,bCalcEner,shake_vir,
                   bNEMD,bFirstStep && bStateFromTPX,rng,rng2,mc_move);
            //rvec_sub(state->x[73],state->x[75],v1);
            //printf("heyb %f\n",norm(v1));
            if(mc_move->bias == 0)
            {
             printf("step %d\n",step_rel);
            }
             printf("step %d\n",step_rel);
            if(bMC) 
            {
             if(update_box) {
              bBOXok=TRUE;
              for(m=0; (m<DIM); m++)
              {
               box_size[m] = state->box[m][m];
              }
              if (fr->ePBC != epbcNONE)
              {
               if (sqr(fr->rlistlong) >= max_cutoff2(fr->ePBC,state->box))
               {
                bBOXok = FALSE;
               }
               if (!fr->bGrid)
               {
               if (2*fr->rlistlong >= min(box_size[XX],min(box_size[YY],box_size[ZZ])))
                 bBOXok = FALSE;
               }
              }
              if (!bBOXok) {
               for(ii=0; (ii<state->natoms); ii++) {
                copy_rvec(xcopy[ii],state->x[ii]);
               }
               copy_mat(boxcopy,state->box);
              }
             }
            }
            if (fr->bSepDVDL && fplog && do_log)
            {
                fprintf(fplog,sepdvdlformat,"Constraint",0.0,dvdl);
            }
            enerd->term[F_DHDL_CON] += dvdl;
            wallcycle_stop(wcycle,ewcUPDATE);
        }
        else if (graph)
        {
            /* Need to unshift here */
            unshift_self(graph,state->box,state->x);
        }
        
        GMX_BARRIER(cr->mpi_comm_mygroup);
        GMX_MPE_LOG(ev_update_finish);
        
        if (!bOK && !bFFscan)
        {
            gmx_fatal(FARGS,"Constraint error: Shake, Lincs or Settle could not solve the constrains");
        }
        
        if (vsite != NULL)
        {
            wallcycle_start(wcycle,ewcVSITECONSTR);
            if (graph != NULL)
            {
                shift_self(graph,state->box,state->x);
            }
            construct_vsites(fplog,vsite,state->x,nrnb,ir->delta_t,state->v,
                             top->idef.iparams,top->idef.il,
                             fr->ePBC,fr->bMolPBC,graph,cr,state->box);
            
            if (graph != NULL)
            {
                unshift_self(graph,state->box,state->x);
            }
            wallcycle_stop(wcycle,ewcVSITECONSTR);
        }
        
        /* Non-equilibrium MD:  this is parallellized,
         * but only does communication when there really is NEMD.
         */
        if (PAR(cr) && bNEMD) 
        {
            accumulate_u(cr,&(ir->opts),ekind);
        }
        
        debug_gmx();
        if(!bMC)
        {
         calc_ke_part(state,&(ir->opts),mdatoms,ekind,nrnb);
        }
        
        /* since we use the new coordinates in calc_ke_part_visc, we should use
         * the new box too. Still, won't this be offset by one timestep in the
         * energy file? / EL 20040121
         */ 
        
        debug_gmx();
        /* Calculate center of mass velocity if necessary, also parallellized */
        if (bStopCM && !bFFscan && !bRerunMD)
        {
            calc_vcm_grp(fplog,mdatoms->start,mdatoms->homenr,mdatoms,
                         state->x,state->v,vcm);
        }
        
        /* Determine the wallclock run time up till now */
        run_time = (double)time(NULL) - (double)runtime->real;
        
        /* Check whether everything is still allright */    
        if ((bGotTermSignal || bGotUsr1Signal) && !bHandledSignal)
        {
            if (bGotTermSignal || ir->nstlist == 0)
            {
                terminate = 1;
            }
            else
            {
                terminate = -1;
            }
            if (!PAR(cr))
            {
                terminate_now = terminate;
            }
            if (fplog)
            {
                fprintf(fplog,
                        "\n\nReceived the %s signal, stopping at the next %sstep\n\n",
                        bGotTermSignal ? "TERM" : "USR1",
                        terminate==-1 ? "NS " : "");
                fflush(fplog);
            }
            fprintf(stderr,
                    "\n\nReceived the %s signal, stopping at the next %sstep\n\n",
                    bGotTermSignal ? "TERM" : "USR1",
                    terminate==-1 ? "NS " : "");
            fflush(stderr);
            bHandledSignal=TRUE;
        }
        else if (MASTER(cr) && (bNS || ir->nstlist <= 0) &&
                 (max_hours > 0 && run_time > max_hours*60.0*60.0*0.99) &&
                 terminate == 0)
        {
            /* Signal to terminate the run */
            terminate = (ir->nstlist == 0 ? 1 : -1);
            if (!PAR(cr))
            {
                terminate_now = terminate;
            }
            if (fplog)
            {
                fprintf(fplog,"\nStep %s: Run time exceeded %.3f hours, will terminate the run\n",gmx_step_str(step,sbuf),max_hours*0.99);
            }
            fprintf(stderr, "\nStep %s: Run time exceeded %.3f hours, will terminate the run\n",gmx_step_str(step,sbuf),max_hours*0.99);
        }
        
        if (ir->nstlist == -1 && !bRerunMD)
        {
            /* When bGStatEveryStep=FALSE, global_stat is only called
             * when we check the atom displacements, not at NS steps.
             * This means that also the bonded interaction count check is not
             * performed immediately after NS. Therefore a few MD steps could
             * be performed with missing interactions.
             * But wrong energies are never written to file,
             * since energies are only written after global_stat
             * has been called.
             */
            if (step >= nlh.step_nscheck)
            {
                nlh.nabnsb = natoms_beyond_ns_buffer(ir,fr,&top->cgs,
                                                     nlh.scale_tot,state->x);
            }
            else
            {
                /* This is not necessarily true,
                 * but step_nscheck is determined quite conservatively.
                 */
                nlh.nabnsb = 0;
            }
        }
        
        /* In parallel we only have to check for checkpointing in steps
         * where we do global communication,
         *  otherwise the other nodes don't know.
         */
        if (MASTER(cr) && ((bGStat || !PAR(cr)) &&
                           cpt_period >= 0 &&
                           (cpt_period == 0 || 
                            run_time >= nchkpt*cpt_period*60.0)))
        {
            if (chkpt == 0)
            {
                nchkpt++;
            }
            chkpt = 1;
        }
        
        if (!bGStat)
        {
            /* We will not sum ekinh_old,
             * so signal that we still have to do it.
             */
            bSumEkinhOld = TRUE;
        }
        else
        {
            if (PAR(cr) && !bMC)
            {
                wallcycle_start(wcycle,ewcMoveE);
                /* Globally (over all NODEs) sum energy, virial etc. 
                 * This includes communication 
                 */
                global_stat(fplog,gstat,cr,enerd,force_vir,shake_vir,mu_tot,
                            ir,ekind,bSumEkinhOld,constr,vcm,
                            ir->nstlist==-1 ? &nlh.nabnsb : NULL,
                            &chkpt,&terminate,
                            top_global, state);
                if (terminate != 0)
                {
                    terminate_now = terminate;
                    terminate = 0;
                }
                
                wallcycle_stop(wcycle,ewcMoveE);
                bSumEkinhOld = FALSE;
            }
            
            /* This is just for testing. Nothing is actually done to Ekin
             * since that would require extra communication.
             */
            if (!bNEMD && debug && (vcm->nr > 0))
            {
                correct_ekin(debug,
                             mdatoms->start,mdatoms->start+mdatoms->homenr,
                             state->v,vcm->group_p[0],
                             mdatoms->massT,mdatoms->tmass,ekin);
            }
            
            /* Do center of mass motion removal */
            if (bStopCM && !bFFscan && !bRerunMD)
            {
                check_cm_grp(fplog,vcm,ir,1);
                do_stopcm_grp(fplog,mdatoms->start,mdatoms->homenr,mdatoms->cVCM,
                              state->x,state->v,vcm);
                inc_nrnb(nrnb,eNR_STOPCM,mdatoms->homenr);
                /*
                  calc_vcm_grp(fplog,START(nsb),HOMENR(nsb),mdatoms->massT,x,v,vcm);
                  check_cm_grp(fplog,vcm,ir);
                  do_stopcm_grp(fplog,START(nsb),HOMENR(nsb),x,v,vcm);
                  check_cm_grp(fplog,vcm,ir);
                */
            }

            if(bMC) 
            {
             /*m_add(force_vir,av_vir,av_vir);
             copy_mat(av_vir,total_vir);
             msmul(total_vir,1/(step_rel+1),total_vir);*/
             clear_mat(shake_vir);
             m_add(force_vir,shake_vir,total_vir);
            }
            else 
            {
             /* Add force and shake contribution to the virial */
             m_add(force_vir,shake_vir,total_vir);
             //copy_mat(force_vir,total_vir);
            }
            
            /* Calculate the amplitude of the cosine velocity profile */
            ekind->cosacc.vcos = ekind->cosacc.mvcos/mdatoms->tmass;
            if (bMC)
            {
             for (i=0;i<DIM;i++) {
              for(m=0;m<DIM;m++) {
               ekin[i][m]=((top_global->moltype[0].atoms.nr*top_global->mols.nr)*BOLTZ*ir->opts.ref_t[0])/(2.0);
               //ekin[i][m]=0.0;
              } 
             }
            }
            else 
            {
             /* Sum the kinetic energies of the groups & calc temp */
             enerd->term[F_TEMP] = sum_ekin((bRerunMD && !rerun_fr.bV),
                                           &(ir->opts),ekind,ekin,
                                           &(enerd->term[F_DKDL]));
            }
            enerd->term[F_EKIN] = trace(ekin);
            
            /* Calculate pressure and apply LR correction if PPPM is used.
             * Use the box from last timestep since we already called update().
             */
            if(!bMC || do_vir) 
            {
             enerd->term[F_PRES] =
                calc_pres(fr->ePBC,ir->nwall,lastbox,ekin,total_vir,pres,
                          (fr->eeltype==eelPPPM)?enerd->term[F_COUL_RECIP]:0.0);
            }
            /* Calculate long range corrections to pressure and energy */
            if (bTCR || bFFscan)
            {
                set_avcsixtwelve(fplog,fr,top_global);
            }
            
            /* Calculate long range corrections to pressure and energy */
            calc_dispcorr(fplog,ir,fr,step,top_global->natoms,
                          lastbox,state->lambda,pres,total_vir,enerd);
            
            sum_dhdl(enerd,state->lambda,ir);
            
            enerd->term[F_ETOT] = enerd->term[F_EPOT] + enerd->term[F_EKIN];
            
            switch (ir->etc) {
            case etcNO:
            case etcBERENDSEN:
                break;
            case etcNOSEHOOVER:
                enerd->term[F_ECONSERVED] =
                    enerd->term[F_ETOT] +
                    nosehoover_energy(&(ir->opts),ekind,
                                      state->nosehoover_xi,
                                      state->therm_integral);
                break;
            case etcVRESCALE:
                enerd->term[F_ECONSERVED] =
                    enerd->term[F_ETOT] +
                    vrescale_energy(&(ir->opts),
                                    state->therm_integral);
                break;
            }
            
            /* We can not just use bCalcEner, since then the simulation results
             * would depend on nstenergy and nstlog or step_nscheck.
             */
            if (((state->flags & (1<<estPRES_PREV)) && bNstEner) || (bMC && do_vir))
            {
                /* Store the pressure in t_state for pressure coupling
                 * at the next MD step.
                 */
                copy_mat(pres,state->pres_prev);
            }
            
            /* Check for excessively large energies */
            if (bIonize)
            {
#ifdef GMX_DOUBLE
                real etot_max = 1e200;
#else
                real etot_max = 1e30;
#endif
                if (fabs(enerd->term[F_ETOT]) > etot_max)
                {
                    fprintf(stderr,"Energy too large (%g), giving up\n",
                            enerd->term[F_ETOT]);
                    break;
                }
            }
        }
        
        /* The coordinates (x) were unshifted in update */
        if (bFFscan && (shellfc==NULL || bConverged))
        {
            if (print_forcefield(fplog,enerd->term,mdatoms->homenr,
                                 f,NULL,xcopy,
                                 &(top_global->mols),mdatoms->massT,pres))
            {
                if (gmx_parallel_env)
                    gmx_finalize();
                fprintf(stderr,"\n");
                exit(0);
            }
        }
        if (bTCR)
        {
            /* Only do GCT when the relaxation of shells (minimization) has converged,
             * otherwise we might be coupling to bogus energies. 
             * In parallel we must always do this, because the other sims might
             * update the FF.
             */
            
            /* Since this is called with the new coordinates state->x, I assume
             * we want the new box state->box too. / EL 20040121
             */
            do_coupling(fplog,nfile,fnm,tcr,t,step,enerd->term,fr,
                        ir,MASTER(cr),
                        mdatoms,&(top->idef),mu_aver,
                        top_global->mols.nr,cr,
                        state->box,total_vir,pres,
                        mu_tot,state->x,f,bConverged);
            debug_gmx();
        }
        
        /* Time for performance */
        if (((step % stepout) == 0) || bLastStep)
        {
            runtime_upd_proc(runtime);
        }
        /* Output stuff */
        if (MASTER(cr))
        {
            bool do_dr,do_or;
            
            if (bNstEner)
            {
                upd_mdebin(mdebin,bDoDHDL ? fp_dhdl : NULL,TRUE,
                           t,mdatoms->tmass,enerd,state,lastbox,
                           shake_vir,force_vir,total_vir,bMC ? state->pres_prev : pres,
                           ekind,mu_tot,constr);
            }
            else
            {
                upd_mdebin_step(mdebin);
            }
            
            do_dr  = do_per_step(step,ir->nstdisreout);
            do_or  = do_per_step(step,ir->nstorireout);
            print_ebin(fp_ene,do_ene,do_dr,do_or,do_log?fplog:NULL,step,t,
                       eprNORMAL,bCompact,mdebin,fcd,groups,&(ir->opts));
      
            if (ir->ePull != epullNO)
            {
                pull_print_output(ir->pull,step,t);
            }
            
            if (do_per_step(step,ir->nstlog))
            {
                if(fflush(fplog) != 0)
                {
                    gmx_fatal(FARGS,"Cannot flush logfile - maybe you are out of quota?");
                }
            }
        }
        
    
        /* Remaining runtime */
        if (MULTIMASTER(cr) && do_verbose)
        {
            if (shellfc)
            {
                fprintf(stderr,"\n");
            }
            print_time(stderr,runtime,step,ir);
        }
        
        /* Replica exchange */
        bExchanged = FALSE;
        if ((repl_ex_nst > 0) && (step > 0) && !bLastStep &&
            do_per_step(step,repl_ex_nst))
        {
            bExchanged = replica_exchange(fplog,cr,repl_ex,
                                          state_global,enerd->term,
                                          state,step,t);
        }
        if (bExchanged && PAR(cr))
        {
            if (DOMAINDECOMP(cr))
            {
                dd_partition_system(fplog,step,cr,TRUE,1,
                                    state_global,top_global,ir,
                                    state,&f,mdatoms,top,fr,
                                    vsite,shellfc,constr,
                                    nrnb,wcycle,FALSE);
            }
            else
            {
                bcast_state(cr,state,FALSE);
            }
        }
        
        bFirstStep = FALSE;
        
        if (bRerunMD) 
        {
            /* read next frame from input trajectory */
            bNotLastFrame = read_next_frame(status,&rerun_fr);
        }
        
        if (!bRerunMD || !rerun_fr.bStep)
        {
            /* increase the MD step number */
            step++;
            step_rel++;
        }
        
        cycles = wallcycle_stop(wcycle,ewcSTEP);
        if (DOMAINDECOMP(cr) && wcycle)
        {
            dd_cycles_add(cr->dd,cycles,ddCyclStep);
        }

        if (step_rel == wcycle_get_reset_counters(wcycle))
        {
            /* Reset all the counters related to performance over the run */
            reset_all_counters(fplog,cr,step,&step_rel,ir,wcycle,nrnb,runtime);
            wcycle_set_reset_counters(wcycle, 0);
        }
    }
    /* End of main MD loop */
    debug_gmx();

    /* Stop the time */
    runtime_end(runtime);
    if (bRerunMD)
    {
        close_trj(status);
    }
    
    if (!(cr->duty & DUTY_PME))
    {
        /* Tell the PME only node to finish */
        gmx_pme_finish(cr);
    }
    
    if (MASTER(cr))
    {
        print_ebin(fp_ene,FALSE,FALSE,FALSE,fplog,step,t,
                   eprAVER,FALSE,mdebin,fcd,groups,&(ir->opts));

        close_enx(fp_ene);
        if (ir->nstxtcout)
        {
            close_xtc(fp_xtc);
        }
        close_trn(fp_trn);
        if (fp_dhdl)
        {
            gmx_fio_fclose(fp_dhdl);
        }
        if (fp_field)
        {
            gmx_fio_fclose(fp_field);
        }
    }
    debug_gmx();
        
    if (ir->nstlist == -1 && nlh.nns > 0 && fplog)
    {
        fprintf(fplog,"Average neighborlist lifetime: %.1f steps, std.dev.: %.1f steps\n",nlh.s1/nlh.nns,sqrt(nlh.s2/nlh.nns - sqr(nlh.s1/nlh.nns)));
        fprintf(fplog,"Average number of atoms that crossed the half buffer length: %.1f\n\n",nlh.ab/nlh.nns);
    }
    
    if (shellfc && fplog)
    {
        fprintf(fplog,"Fraction of iterations that converged:           %.2f %%\n",
                (nconverged*100.0)/step_rel);
        fprintf(fplog,"Average number of force evaluations per MD step: %.2f\n\n",
                tcount/step_rel);
    }
        if(bMC) 
        {
         print_mc_ratio(stderr,state->step_ac,state->step_tot,state->vol_ac,state->vol_tot);
        }
    
    if (repl_ex_nst > 0 && MASTER(cr))
    {
        print_replica_exchange_statistics(fplog,repl_ex);
    }
    
    runtime->nsteps_done = step_rel;
    
    return 0;
}

