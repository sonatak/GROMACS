;#
;# $Id$
;#
;# Gromacs 4.0                         Copyright (c) 1991-2003 
;# David van der Spoel, Erik Lindahl
;#
;# This program is free software; you can redistribute it and/or
;# modify it under the terms of the GNU General Public License
;# as published by the Free Software Foundation; either version 2
;# of the License, or (at your option) any later version.
;#
;# To help us fund GROMACS development, we humbly ask that you cite
;# the research papers on the package. Check out http://www.gromacs.org
;# 
;# And Hey:
;# Gnomes, ROck Monsters And Chili Sauce
;#

;# These files require GNU binutils 2.10 or later, since we
;# use intel syntax for portability, or a recent version 
;# of NASM that understands Extended 3DNow and SSE2 instructions.
;# (NASM is normally only used with MS Visual C++).
;# Since NASM and gnu as disagree on some definitions and use 
;# completely different preprocessing options I have to introduce a
;# trick: NASM uses ';' for comments, while gnu as uses '#' on x86.
;# Gnu as treats ';' as a line break, i.e. ignores it. This is the
;# reason why all comments need both symbols...
;# The source is written for GNU as, with intel syntax. When you use
;# NASM we redefine a couple of things. The false if-statement around 
;# the following code is seen by GNU as, but NASM doesn't see it, so 
;# the code inside is read by NASM but not gcc.

; .if 0    # block below only read by NASM
%define .section	section
%define .long		dd
%define .align		align
%define .globl		global
;# NASM only wants 'dword', not 'dword ptr'.
%define ptr
.equiv          .equiv                  2
   %1 equ %2
%endmacro
; .endif                   # End of NASM-specific block
; .intel_syntax noprefix   # Line only read by gnu as

	
.globl nb_kernel302_x86_64_sse
.globl _nb_kernel302_x86_64_sse
nb_kernel302_x86_64_sse:	
_nb_kernel302_x86_64_sse:	
;#	Room for return address and rbp (16 bytes)
.equiv          nb302_fshift,           16
.equiv          nb302_gid,              24
.equiv          nb302_pos,              32
.equiv          nb302_faction,          40
.equiv          nb302_charge,           48
.equiv          nb302_p_facel,          56
.equiv          nb302_argkrf,           64
.equiv          nb302_argcrf,           72
.equiv          nb302_Vc,               80
.equiv          nb302_type,             88
.equiv          nb302_p_ntype,          96
.equiv          nb302_vdwparam,         104
.equiv          nb302_Vvdw,             112
.equiv          nb302_p_tabscale,       120
.equiv          nb302_VFtab,            128
.equiv          nb302_invsqrta,         136
.equiv          nb302_dvda,             144
.equiv          nb302_p_gbtabscale,     152
.equiv          nb302_GBtab,            160
.equiv          nb302_p_nthreads,       168
.equiv          nb302_count,            176
.equiv          nb302_mtx,              184
.equiv          nb302_outeriter,        192
.equiv          nb302_inneriter,        200
.equiv          nb302_work,             208
	;# stack offsets for local variables  
	;# bottom of stack is cache-aligned for sse use 
.equiv          nb302_ixO,              0
.equiv          nb302_iyO,              16
.equiv          nb302_izO,              32
.equiv          nb302_ixH1,             48
.equiv          nb302_iyH1,             64
.equiv          nb302_izH1,             80
.equiv          nb302_ixH2,             96
.equiv          nb302_iyH2,             112
.equiv          nb302_izH2,             128
.equiv          nb302_jxO,              144
.equiv          nb302_jyO,              160
.equiv          nb302_jzO,              176
.equiv          nb302_jxH1,             192
.equiv          nb302_jyH1,             208
.equiv          nb302_jzH1,             224
.equiv          nb302_jxH2,             240
.equiv          nb302_jyH2,             256
.equiv          nb302_jzH2,             272
.equiv          nb302_dxOO,             288
.equiv          nb302_dyOO,             304
.equiv          nb302_dzOO,             320
.equiv          nb302_dxOH1,            336
.equiv          nb302_dyOH1,            352
.equiv          nb302_dzOH1,            368
.equiv          nb302_dxOH2,            384
.equiv          nb302_dyOH2,            400
.equiv          nb302_dzOH2,            416
.equiv          nb302_dxH1O,            432
.equiv          nb302_dyH1O,            448
.equiv          nb302_dzH1O,            464
.equiv          nb302_dxH1H1,           480
.equiv          nb302_dyH1H1,           496
.equiv          nb302_dzH1H1,           512
.equiv          nb302_dxH1H2,           528
.equiv          nb302_dyH1H2,           544
.equiv          nb302_dzH1H2,           560
.equiv          nb302_dxH2O,            576
.equiv          nb302_dyH2O,            592
.equiv          nb302_dzH2O,            608
.equiv          nb302_dxH2H1,           624
.equiv          nb302_dyH2H1,           640
.equiv          nb302_dzH2H1,           656
.equiv          nb302_dxH2H2,           672
.equiv          nb302_dyH2H2,           688
.equiv          nb302_dzH2H2,           704
.equiv          nb302_qqOO,             720
.equiv          nb302_qqOH,             736
.equiv          nb302_qqHH,             752
.equiv          nb302_two,              768
.equiv          nb302_tsc,              784
.equiv          nb302_vctot,            800
.equiv          nb302_fixO,             816
.equiv          nb302_fiyO,             832
.equiv          nb302_fizO,             848
.equiv          nb302_fixH1,            864
.equiv          nb302_fiyH1,            880
.equiv          nb302_fizH1,            896
.equiv          nb302_fixH2,            912
.equiv          nb302_fiyH2,            928
.equiv          nb302_fizH2,            944
.equiv          nb302_fjxO,             960
.equiv          nb302_fjyO,             976
.equiv          nb302_fjzO,             992
.equiv          nb302_fjxH1,            1008
.equiv          nb302_fjyH1,            1024
.equiv          nb302_fjzH1,            1040
.equiv          nb302_fjxH2,            1056
.equiv          nb302_fjyH2,            1072
.equiv          nb302_fjzH2,            1088
.equiv          nb302_half,             1104
.equiv          nb302_three,            1120
.equiv          nb302_rsqOO,            1136
.equiv          nb302_rsqOH1,           1152
.equiv          nb302_rsqOH2,           1168
.equiv          nb302_rsqH1O,           1184
.equiv          nb302_rsqH1H1,          1200
.equiv          nb302_rsqH1H2,          1216
.equiv          nb302_rsqH2O,           1232
.equiv          nb302_rsqH2H1,          1248
.equiv          nb302_rsqH2H2,          1264
.equiv          nb302_rinvOO,           1280
.equiv          nb302_rinvOH1,          1296
.equiv          nb302_rinvOH2,          1312
.equiv          nb302_rinvH1O,          1328
.equiv          nb302_rinvH1H1,         1344
.equiv          nb302_rinvH1H2,         1360
.equiv          nb302_rinvH2O,          1376
.equiv          nb302_rinvH2H1,         1392
.equiv          nb302_rinvH2H2,         1408
.equiv          nb302_is3,              1424
.equiv          nb302_ii3,              1428
.equiv          nb302_nri,              1432
.equiv          nb302_iinr,             1440
.equiv          nb302_jindex,           1448
.equiv          nb302_jjnr,             1456
.equiv          nb302_shift,            1464
.equiv          nb302_shiftvec,         1472
.equiv          nb302_facel,            1480
.equiv          nb302_innerjjnr,        1488
.equiv          nb302_innerk,           1496
.equiv          nb302_n,                1500
.equiv          nb302_nn1,              1504
.equiv          nb302_nouter,           1508
.equiv          nb302_ninner,           1512

	push rbp
	mov  rbp, rsp
	push rbx

	femms
	sub rsp, 1528		;# local variable stack space (n*16+8)

	;# zero 32-bit iteration counters
	mov eax, 0
	mov [rsp + nb302_nouter], eax
	mov [rsp + nb302_ninner], eax

	mov edi, [rdi]
	mov [rsp + nb302_nri], edi
	mov [rsp + nb302_iinr], rsi
	mov [rsp + nb302_jindex], rdx
	mov [rsp + nb302_jjnr], rcx
	mov [rsp + nb302_shift], r8
	mov [rsp + nb302_shiftvec], r9
	mov rsi, [rbp + nb302_p_facel]
	movss xmm0, [rsi]
	movss [rsp + nb302_facel], xmm0

	mov rax, [rbp + nb302_p_tabscale]
	movss xmm3, [rax]
	shufps xmm3, xmm3, 0
	movaps [rsp + nb302_tsc], xmm3


	;# assume we have at least one i particle - start directly 
	mov   rcx, [rsp + nb302_iinr]       ;# rcx = pointer into iinr[] 	
	mov   ebx, [rcx]	    ;# ebx =ii 

	mov   rdx, [rbp + nb302_charge]
	movss xmm3, [rdx + rbx*4]	
	movss xmm4, xmm3	
	movss xmm5, [rdx + rbx*4 + 4]	
	mov rsi, [rbp + nb302_p_facel]
	movss xmm0, [rsi]
	movss xmm6, [rsp + nb302_facel]
	mulss  xmm3, xmm3
	mulss  xmm4, xmm5
	mulss  xmm5, xmm5
	mulss  xmm3, xmm6
	mulss  xmm4, xmm6
	mulss  xmm5, xmm6
	shufps xmm3, xmm3, 0
	shufps xmm4, xmm4, 0
	shufps xmm5, xmm5, 0
	movaps [rsp + nb302_qqOO], xmm3
	movaps [rsp + nb302_qqOH], xmm4
	movaps [rsp + nb302_qqHH], xmm5		

	;# create constant floating-point factors on stack
	mov eax, 0x3f000000     ;# half in IEEE (hex)
	mov [rsp + nb302_half], eax
	movss xmm1, [rsp + nb302_half]
	shufps xmm1, xmm1, 0    ;# splat to all elements
	movaps xmm2, xmm1       
	addps  xmm2, xmm2	;# one
	movaps xmm3, xmm2
	addps  xmm2, xmm2	;# two
	addps  xmm3, xmm2	;# three
	movaps [rsp + nb302_half],  xmm1
	movaps [rsp + nb302_two],  xmm2
	movaps [rsp + nb302_three],  xmm3

.nb302_threadloop:
        mov   rsi, [rbp + nb302_count]          ;# pointer to sync counter
        mov   eax, [rsi]
.nb302_spinlock:
        mov   ebx, eax                          ;# ebx=*count=nn0
        add   ebx, 1                           ;# ebx=nn1=nn0+10
        lock cmpxchg [rsi], ebx                 ;# write nn1 to *counter,
                                                ;# if it hasnt changed.
                                                ;# or reread *counter to eax.
        pause                                   ;# -> better p4 performance
        jnz .nb302_spinlock

        ;# if(nn1>nri) nn1=nri
        mov ecx, [rsp + nb302_nri]
        mov edx, ecx
        sub ecx, ebx
        cmovle ebx, edx                         ;# if(nn1>nri) nn1=nri
        ;# Cleared the spinlock if we got here.
        ;# eax contains nn0, ebx contains nn1.
        mov [rsp + nb302_n], eax
        mov [rsp + nb302_nn1], ebx
        sub ebx, eax                            ;# calc number of outer lists
	mov esi, eax				;# copy n to esi
        jg  .nb302_outerstart
        jmp .nb302_end
	
.nb302_outerstart:
	;# ebx contains number of outer iterations
	add ebx, [rsp + nb302_nouter]
	mov [rsp + nb302_nouter], ebx

.nb302_outer:
	mov   rax, [rsp + nb302_shift]      ;# rax = pointer into shift[] 
	mov   ebx, [rax + rsi*4]		;# rbx=shift[n] 
	
	lea   rbx, [rbx + rbx*2]    ;# rbx=3*is 
	mov   [rsp + nb302_is3],ebx    	;# store is3 

	mov   rax, [rsp + nb302_shiftvec]   ;# rax = base of shiftvec[] 

	movss xmm0, [rax + rbx*4]
	movss xmm1, [rax + rbx*4 + 4]
	movss xmm2, [rax + rbx*4 + 8] 

	mov   rcx, [rsp + nb302_iinr]       ;# rcx = pointer into iinr[] 	
	mov   ebx, [rcx + rsi*4]	    ;# ebx =ii 

	lea   rbx, [rbx + rbx*2]	;# rbx = 3*ii=ii3 
	mov   rax, [rbp + nb302_pos]    ;# rax = base of pos[]  
	mov   [rsp + nb302_ii3], ebx	
	
	movaps xmm3, xmm0
	movaps xmm4, xmm1
	movaps xmm5, xmm2
	addss xmm3, [rax + rbx*4]
	addss xmm4, [rax + rbx*4 + 4]
	addss xmm5, [rax + rbx*4 + 8]		
	shufps xmm3, xmm3, 0
	shufps xmm4, xmm4, 0
	shufps xmm5, xmm5, 0
	movaps [rsp + nb302_ixO], xmm3
	movaps [rsp + nb302_iyO], xmm4
	movaps [rsp + nb302_izO], xmm5

	movss xmm3, xmm0
	movss xmm4, xmm1
	movss xmm5, xmm2
	addss xmm0, [rax + rbx*4 + 12]
	addss xmm1, [rax + rbx*4 + 16]
	addss xmm2, [rax + rbx*4 + 20]		
	addss xmm3, [rax + rbx*4 + 24]
	addss xmm4, [rax + rbx*4 + 28]
	addss xmm5, [rax + rbx*4 + 32]		

	shufps xmm0, xmm0, 0
	shufps xmm1, xmm1, 0
	shufps xmm2, xmm2, 0
	shufps xmm3, xmm3, 0
	shufps xmm4, xmm4, 0
	shufps xmm5, xmm5, 0
	movaps [rsp + nb302_ixH1], xmm0
	movaps [rsp + nb302_iyH1], xmm1
	movaps [rsp + nb302_izH1], xmm2
	movaps [rsp + nb302_ixH2], xmm3
	movaps [rsp + nb302_iyH2], xmm4
	movaps [rsp + nb302_izH2], xmm5

	;# clear vctot and i forces 
	xorps xmm4, xmm4
	movaps [rsp + nb302_vctot], xmm4
	movaps [rsp + nb302_fixO], xmm4
	movaps [rsp + nb302_fiyO], xmm4
	movaps [rsp + nb302_fizO], xmm4
	movaps [rsp + nb302_fixH1], xmm4
	movaps [rsp + nb302_fiyH1], xmm4
	movaps [rsp + nb302_fizH1], xmm4
	movaps [rsp + nb302_fixH2], xmm4
	movaps [rsp + nb302_fiyH2], xmm4
	movaps [rsp + nb302_fizH2], xmm4
	
	mov   rax, [rsp + nb302_jindex]
	mov   ecx, [rax + rsi*4]	     ;# jindex[n] 
	mov   edx, [rax + rsi*4 + 4]	     ;# jindex[n+1] 
	sub   edx, ecx               ;# number of innerloop atoms 

	mov   rsi, [rbp + nb302_pos]
	mov   rdi, [rbp + nb302_faction]	
	mov   rax, [rsp + nb302_jjnr]
	shl   ecx, 2
	add   rax, rcx
	mov   [rsp + nb302_innerjjnr], rax     ;# pointer to jjnr[nj0] 
	mov   ecx, edx
	sub   edx,  4
	add   ecx, [rsp + nb302_ninner]
	mov   [rsp + nb302_ninner], ecx
	add   edx, 0
	mov   [rsp + nb302_innerk], edx    ;# number of innerloop atoms 
	jge   .nb302_unroll_loop
	jmp   .nb302_single_check
.nb302_unroll_loop:	
	;# quad-unroll innerloop here 
	mov   rdx, [rsp + nb302_innerjjnr]     ;# pointer to jjnr[k] 

	mov   eax, [rdx]	
	mov   ebx, [rdx + 4] 
	mov   ecx, [rdx + 8]
	mov   edx, [rdx + 12]         ;# eax-edx=jnr1-4 
	
	add qword ptr [rsp + nb302_innerjjnr],  16 ;# advance pointer (unrolled 4) 

	mov rsi, [rbp + nb302_pos]       ;# base of pos[] 

	lea   rax, [rax + rax*2]     ;# replace jnr with j3 
	lea   rbx, [rbx + rbx*2]	
	lea   rcx, [rcx + rcx*2]     ;# replace jnr with j3 
	lea   rdx, [rdx + rdx*2]	
	
	;# move j coordinates to local temp variables 
	movlps xmm2, [rsi + rax*4]
	movlps xmm3, [rsi + rax*4 + 12]
	movlps xmm4, [rsi + rax*4 + 24]

	movlps xmm5, [rsi + rbx*4]
	movlps xmm6, [rsi + rbx*4 + 12]
	movlps xmm7, [rsi + rbx*4 + 24]

	movhps xmm2, [rsi + rcx*4]
	movhps xmm3, [rsi + rcx*4 + 12]
	movhps xmm4, [rsi + rcx*4 + 24]

	movhps xmm5, [rsi + rdx*4]
	movhps xmm6, [rsi + rdx*4 + 12]
	movhps xmm7, [rsi + rdx*4 + 24]

	;# current state: 	
	;# xmm2= jxOa  jyOa  jxOc  jyOc 
	;# xmm3= jxH1a jyH1a jxH1c jyH1c 
	;# xmm4= jxH2a jyH2a jxH2c jyH2c 
	;# xmm5= jxOb  jyOb  jxOd  jyOd 
	;# xmm6= jxH1b jyH1b jxH1d jyH1d 
	;# xmm7= jxH2b jyH2b jxH2d jyH2d 
	
	movaps xmm0, xmm2
	movaps xmm1, xmm3
	unpcklps xmm0, xmm5	;# xmm0= jxOa  jxOb  jyOa  jyOb 
	unpcklps xmm1, xmm6	;# xmm1= jxH1a jxH1b jyH1a jyH1b 
	unpckhps xmm2, xmm5	;# xmm2= jxOc  jxOd  jyOc  jyOd 
	unpckhps xmm3, xmm6	;# xmm3= jxH1c jxH1d jyH1c jyH1d 
	movaps xmm5, xmm4
	movaps   xmm6, xmm0
	unpcklps xmm4, xmm7	;# xmm4= jxH2a jxH2b jyH2a jyH2b 		
	unpckhps xmm5, xmm7	;# xmm5= jxH2c jxH2d jyH2c jyH2d 
	movaps   xmm7, xmm1
	movlhps  xmm0, xmm2	;# xmm0= jxOa  jxOb  jxOc  jxOd 
	movaps [rsp + nb302_jxO], xmm0
	movhlps  xmm2, xmm6	;# xmm2= jyOa  jyOb  jyOc  jyOd 
	movaps [rsp + nb302_jyO], xmm2
	movlhps  xmm1, xmm3
	movaps [rsp + nb302_jxH1], xmm1
	movhlps  xmm3, xmm7
	movaps   xmm6, xmm4
	movaps [rsp + nb302_jyH1], xmm3
	movlhps  xmm4, xmm5
	movaps [rsp + nb302_jxH2], xmm4
	movhlps  xmm5, xmm6
	movaps [rsp + nb302_jyH2], xmm5

	movss  xmm0, [rsi + rax*4 + 8]
	movss  xmm1, [rsi + rax*4 + 20]
	movss  xmm2, [rsi + rax*4 + 32]

	movss  xmm3, [rsi + rcx*4 + 8]
	movss  xmm4, [rsi + rcx*4 + 20]
	movss  xmm5, [rsi + rcx*4 + 32]

	movhps xmm0, [rsi + rbx*4 + 4]
	movhps xmm1, [rsi + rbx*4 + 16]
	movhps xmm2, [rsi + rbx*4 + 28]
	
	movhps xmm3, [rsi + rdx*4 + 4]
	movhps xmm4, [rsi + rdx*4 + 16]
	movhps xmm5, [rsi + rdx*4 + 28]
	
	shufps xmm0, xmm3, 204  ;# 11001100
	shufps xmm1, xmm4, 204  ;# 11001100
	shufps xmm2, xmm5, 204  ;# 11001100
	movaps [rsp + nb302_jzO],  xmm0
	movaps [rsp + nb302_jzH1],  xmm1
	movaps [rsp + nb302_jzH2],  xmm2

	movaps xmm0, [rsp + nb302_ixO]
	movaps xmm1, [rsp + nb302_iyO]
	movaps xmm2, [rsp + nb302_izO]
	movaps xmm3, [rsp + nb302_ixO]
	movaps xmm4, [rsp + nb302_iyO]
	movaps xmm5, [rsp + nb302_izO]
	subps  xmm0, [rsp + nb302_jxO]
	subps  xmm1, [rsp + nb302_jyO]
	subps  xmm2, [rsp + nb302_jzO]
	subps  xmm3, [rsp + nb302_jxH1]
	subps  xmm4, [rsp + nb302_jyH1]
	subps  xmm5, [rsp + nb302_jzH1]
	movaps [rsp + nb302_dxOO], xmm0
	movaps [rsp + nb302_dyOO], xmm1
	movaps [rsp + nb302_dzOO], xmm2
	mulps  xmm0, xmm0
	mulps  xmm1, xmm1
	mulps  xmm2, xmm2
	movaps [rsp + nb302_dxOH1], xmm3
	movaps [rsp + nb302_dyOH1], xmm4
	movaps [rsp + nb302_dzOH1], xmm5
	mulps  xmm3, xmm3
	mulps  xmm4, xmm4
	mulps  xmm5, xmm5
	addps  xmm0, xmm1
	addps  xmm0, xmm2
	addps  xmm3, xmm4
	addps  xmm3, xmm5
	movaps [rsp + nb302_rsqOO], xmm0
	movaps [rsp + nb302_rsqOH1], xmm3

	movaps xmm0, [rsp + nb302_ixO]
	movaps xmm1, [rsp + nb302_iyO]
	movaps xmm2, [rsp + nb302_izO]
	movaps xmm3, [rsp + nb302_ixH1]
	movaps xmm4, [rsp + nb302_iyH1]
	movaps xmm5, [rsp + nb302_izH1]
	subps  xmm0, [rsp + nb302_jxH2]
	subps  xmm1, [rsp + nb302_jyH2]
	subps  xmm2, [rsp + nb302_jzH2]
	subps  xmm3, [rsp + nb302_jxO]
	subps  xmm4, [rsp + nb302_jyO]
	subps  xmm5, [rsp + nb302_jzO]
	movaps [rsp + nb302_dxOH2], xmm0
	movaps [rsp + nb302_dyOH2], xmm1
	movaps [rsp + nb302_dzOH2], xmm2
	mulps  xmm0, xmm0
	mulps  xmm1, xmm1
	mulps  xmm2, xmm2
	movaps [rsp + nb302_dxH1O], xmm3
	movaps [rsp + nb302_dyH1O], xmm4
	movaps [rsp + nb302_dzH1O], xmm5
	mulps  xmm3, xmm3
	mulps  xmm4, xmm4
	mulps  xmm5, xmm5
	addps  xmm0, xmm1
	addps  xmm0, xmm2
	addps  xmm3, xmm4
	addps  xmm3, xmm5
	movaps [rsp + nb302_rsqOH2], xmm0
	movaps [rsp + nb302_rsqH1O], xmm3

	movaps xmm0, [rsp + nb302_ixH1]
	movaps xmm1, [rsp + nb302_iyH1]
	movaps xmm2, [rsp + nb302_izH1]
	movaps xmm3, [rsp + nb302_ixH1]
	movaps xmm4, [rsp + nb302_iyH1]
	movaps xmm5, [rsp + nb302_izH1]
	subps  xmm0, [rsp + nb302_jxH1]
	subps  xmm1, [rsp + nb302_jyH1]
	subps  xmm2, [rsp + nb302_jzH1]
	subps  xmm3, [rsp + nb302_jxH2]
	subps  xmm4, [rsp + nb302_jyH2]
	subps  xmm5, [rsp + nb302_jzH2]
	movaps [rsp + nb302_dxH1H1], xmm0
	movaps [rsp + nb302_dyH1H1], xmm1
	movaps [rsp + nb302_dzH1H1], xmm2
	mulps  xmm0, xmm0
	mulps  xmm1, xmm1
	mulps  xmm2, xmm2
	movaps [rsp + nb302_dxH1H2], xmm3
	movaps [rsp + nb302_dyH1H2], xmm4
	movaps [rsp + nb302_dzH1H2], xmm5
	mulps  xmm3, xmm3
	mulps  xmm4, xmm4
	mulps  xmm5, xmm5
	addps  xmm0, xmm1
	addps  xmm0, xmm2
	addps  xmm3, xmm4
	addps  xmm3, xmm5
	movaps [rsp + nb302_rsqH1H1], xmm0
	movaps [rsp + nb302_rsqH1H2], xmm3

	movaps xmm0, [rsp + nb302_ixH2]
	movaps xmm1, [rsp + nb302_iyH2]
	movaps xmm2, [rsp + nb302_izH2]
	movaps xmm3, [rsp + nb302_ixH2]
	movaps xmm4, [rsp + nb302_iyH2]
	movaps xmm5, [rsp + nb302_izH2]
	subps  xmm0, [rsp + nb302_jxO]
	subps  xmm1, [rsp + nb302_jyO]
	subps  xmm2, [rsp + nb302_jzO]
	subps  xmm3, [rsp + nb302_jxH1]
	subps  xmm4, [rsp + nb302_jyH1]
	subps  xmm5, [rsp + nb302_jzH1]
	movaps [rsp + nb302_dxH2O], xmm0
	movaps [rsp + nb302_dyH2O], xmm1
	movaps [rsp + nb302_dzH2O], xmm2
	mulps  xmm0, xmm0
	mulps  xmm1, xmm1
	mulps  xmm2, xmm2
	movaps [rsp + nb302_dxH2H1], xmm3
	movaps [rsp + nb302_dyH2H1], xmm4
	movaps [rsp + nb302_dzH2H1], xmm5
	mulps  xmm3, xmm3
	mulps  xmm4, xmm4
	mulps  xmm5, xmm5
	addps  xmm0, xmm1
	addps  xmm0, xmm2
	addps  xmm4, xmm3
	addps  xmm4, xmm5
	movaps [rsp + nb302_rsqH2O], xmm0
	movaps [rsp + nb302_rsqH2H1], xmm4

	movaps xmm0, [rsp + nb302_ixH2]
	movaps xmm1, [rsp + nb302_iyH2]
	movaps xmm2, [rsp + nb302_izH2]
	subps  xmm0, [rsp + nb302_jxH2]
	subps  xmm1, [rsp + nb302_jyH2]
	subps  xmm2, [rsp + nb302_jzH2]
	movaps [rsp + nb302_dxH2H2], xmm0
	movaps [rsp + nb302_dyH2H2], xmm1
	movaps [rsp + nb302_dzH2H2], xmm2
	mulps xmm0, xmm0
	mulps xmm1, xmm1
	mulps xmm2, xmm2
	addps xmm0, xmm1
	addps xmm0, xmm2
	movaps [rsp + nb302_rsqH2H2], xmm0
	
	;# start doing invsqrt use rsq values in xmm0, xmm4 
	rsqrtps xmm1, xmm0
	rsqrtps xmm5, xmm4
	movaps  xmm2, xmm1
	movaps  xmm6, xmm5
	mulps   xmm1, xmm1
	mulps   xmm5, xmm5
	movaps  xmm3, [rsp + nb302_three]
	movaps  xmm7, xmm3
	mulps   xmm1, xmm0
	mulps   xmm5, xmm4
	subps   xmm3, xmm1
	subps   xmm7, xmm5
	mulps   xmm3, xmm2
	mulps   xmm7, xmm6
	mulps   xmm3, [rsp + nb302_half] ;# rinvH2H2 
	mulps   xmm7, [rsp + nb302_half] ;# rinvH2H1 
	movaps  [rsp + nb302_rinvH2H2], xmm3
	movaps  [rsp + nb302_rinvH2H1], xmm7
	
	rsqrtps xmm1, [rsp + nb302_rsqOO]
	rsqrtps xmm5, [rsp + nb302_rsqOH1]
	movaps  xmm2, xmm1
	movaps  xmm6, xmm5
	mulps   xmm1, xmm1
	mulps   xmm5, xmm5
	movaps  xmm3, [rsp + nb302_three]
	movaps  xmm7, xmm3
	mulps   xmm1, [rsp + nb302_rsqOO]
	mulps   xmm5, [rsp + nb302_rsqOH1]
	subps   xmm3, xmm1
	subps   xmm7, xmm5
	mulps   xmm3, xmm2
	mulps   xmm7, xmm6
	mulps   xmm3, [rsp + nb302_half] 
	mulps   xmm7, [rsp + nb302_half]
	movaps  [rsp + nb302_rinvOO], xmm3
	movaps  [rsp + nb302_rinvOH1], xmm7
	
	rsqrtps xmm1, [rsp + nb302_rsqOH2]
	rsqrtps xmm5, [rsp + nb302_rsqH1O]
	movaps  xmm2, xmm1
	movaps  xmm6, xmm5
	mulps   xmm1, xmm1
	mulps   xmm5, xmm5
	movaps  xmm3, [rsp + nb302_three]
	movaps  xmm7, xmm3
	mulps   xmm1, [rsp + nb302_rsqOH2]
	mulps   xmm5, [rsp + nb302_rsqH1O]
	subps   xmm3, xmm1
	subps   xmm7, xmm5
	mulps   xmm3, xmm2
	mulps   xmm7, xmm6
	mulps   xmm3, [rsp + nb302_half] 
	mulps   xmm7, [rsp + nb302_half]
	movaps  [rsp + nb302_rinvOH2], xmm3
	movaps  [rsp + nb302_rinvH1O], xmm7
	
	rsqrtps xmm1, [rsp + nb302_rsqH1H1]
	rsqrtps xmm5, [rsp + nb302_rsqH1H2]
	movaps  xmm2, xmm1
	movaps  xmm6, xmm5
	mulps   xmm1, xmm1
	mulps   xmm5, xmm5
	movaps  xmm3, [rsp + nb302_three]
	movaps  xmm7, xmm3
	mulps   xmm1, [rsp + nb302_rsqH1H1]
	mulps   xmm5, [rsp + nb302_rsqH1H2]
	subps   xmm3, xmm1
	subps   xmm7, xmm5
	mulps   xmm3, xmm2
	mulps   xmm7, xmm6
	mulps   xmm3, [rsp + nb302_half] 
	mulps   xmm7, [rsp + nb302_half]
	movaps  [rsp + nb302_rinvH1H1], xmm3
	movaps  [rsp + nb302_rinvH1H2], xmm7
	
	rsqrtps xmm1, [rsp + nb302_rsqH2O]
	movaps  xmm2, xmm1
	mulps   xmm1, xmm1
	movaps  xmm3, [rsp + nb302_three]
	mulps   xmm1, [rsp + nb302_rsqH2O]
	subps   xmm3, xmm1
	mulps   xmm3, xmm2
	mulps   xmm3, [rsp + nb302_half] 
	movaps  [rsp + nb302_rinvH2O], xmm3

	;# start with OO interaction 
	movaps xmm0, [rsp + nb302_rinvOO]
	movaps xmm1, xmm0
	mulps  xmm1, [rsp + nb302_rsqOO] ;# xmm1=r 
	mulps  xmm1, [rsp + nb302_tsc]
	
	movhlps xmm2, xmm1
	cvttps2pi mm6, xmm1
	cvttps2pi mm7, xmm2 	;# mm6/mm7 contain lu indices 
	cvtpi2ps xmm3, mm6
	cvtpi2ps xmm2, mm7
	movlhps  xmm3, xmm2
	subps    xmm1, xmm3	;# xmm1=eps 
	movaps xmm2, xmm1
	mulps  xmm2, xmm2   	;# xmm2=eps2 
	pslld   mm6, 2
	pslld   mm7, 2
	
	movd mm0, eax
	movd mm1, ebx
	movd mm2, ecx
	movd mm3, edx

	mov  rsi, [rbp + nb302_VFtab]
	movd eax, mm6
	psrlq mm6, 32
	movd ecx, mm7
	psrlq mm7, 32
	movd ebx, mm6
	movd edx, mm7

	movlps xmm5, [rsi + rax*4]
	movlps xmm7, [rsi + rcx*4]
	movhps xmm5, [rsi + rbx*4]
	movhps xmm7, [rsi + rdx*4] ;# got half coulomb table 

	movaps xmm4, xmm5
	shufps xmm4, xmm7, 136  ;# 10001000
	shufps xmm5, xmm7, 221  ;# 11011101

	movlps xmm7, [rsi + rax*4 + 8]
	movlps xmm3, [rsi + rcx*4 + 8]
	movhps xmm7, [rsi + rbx*4 + 8]
	movhps xmm3, [rsi + rdx*4 + 8] ;# other half of coulomb table  
	movaps xmm6, xmm7
	shufps xmm6, xmm3, 136  ;# 10001000
	shufps xmm7, xmm3, 221  ;# 11011101
	;# coulomb table ready, in xmm4-xmm7  

	mulps  xmm6, xmm1   	;# xmm6=Geps 
	mulps  xmm7, xmm2   	;# xmm7=Heps2 
	addps  xmm5, xmm6
	addps  xmm5, xmm7   	;# xmm5=Fp 
	mulps  xmm7, [rsp + nb302_two]   	;# two*Heps2 
	movaps xmm3, [rsp + nb302_qqOO]
	addps  xmm7, xmm6
	addps  xmm7, xmm5 ;# xmm7=FF 
	mulps  xmm5, xmm1 ;# xmm5=eps*Fp 
	addps  xmm5, xmm4 ;# xmm5=VV 
	mulps  xmm5, xmm3 ;# vcoul=qq*VV  
	mulps  xmm3, xmm7 ;# fijC=FF*qq 
	;# at this point mm5 contains vcoul and mm3 fijC 
	;# increment vcoul - then we can get rid of mm5 
	;# update vctot 
	addps  xmm5, [rsp + nb302_vctot]
	xorps  xmm2, xmm2
	movaps [rsp + nb302_vctot], xmm5
	mulps  xmm3, [rsp + nb302_tsc]
	
	subps  xmm2, xmm3
	mulps  xmm0, xmm2
	
	movaps xmm1, xmm0
	movaps xmm2, xmm0		

	xorps xmm3, xmm3
	movaps xmm4, xmm3
	movaps xmm5, xmm3
	mulps xmm0, [rsp + nb302_dxOO]
	mulps xmm1, [rsp + nb302_dyOO]
	mulps xmm2, [rsp + nb302_dzOO]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [rsp + nb302_fixO]
	addps xmm1, [rsp + nb302_fiyO]
	addps xmm2, [rsp + nb302_fizO]
	movaps [rsp + nb302_fjxO], xmm3
	movaps [rsp + nb302_fjyO], xmm4
	movaps [rsp + nb302_fjzO], xmm5
	movaps [rsp + nb302_fixO], xmm0
	movaps [rsp + nb302_fiyO], xmm1
	movaps [rsp + nb302_fizO], xmm2

	;# O-H1 interaction 
	movaps xmm0, [rsp + nb302_rinvOH1]
	movaps xmm1, xmm0
	mulps  xmm1, [rsp + nb302_rsqOH1] ;# xmm1=r 
	mulps  xmm1, [rsp + nb302_tsc]	
	movhlps xmm2, xmm1
	cvttps2pi mm6, xmm1
	cvttps2pi mm7, xmm2 	;# mm6/mm7 contain lu indices 
	cvtpi2ps xmm3, mm6
	cvtpi2ps xmm2, mm7
	movlhps  xmm3, xmm2
	subps    xmm1, xmm3	;# xmm1=eps 
	movaps xmm2, xmm1
	mulps  xmm2, xmm2   	;# xmm2=eps2 

	pslld   mm6, 2
	pslld   mm7, 2
	
	movd eax, mm6
	psrlq mm6, 32
	movd ecx, mm7
	psrlq mm7, 32
	movd ebx, mm6
	movd edx, mm7

	movlps xmm5, [rsi + rax*4]
	movlps xmm7, [rsi + rcx*4]
	movhps xmm5, [rsi + rbx*4]
	movhps xmm7, [rsi + rdx*4] ;# got half coulomb table 

	movaps xmm4, xmm5
	shufps xmm4, xmm7, 136  ;# 10001000
	shufps xmm5, xmm7, 221  ;# 11011101

	movlps xmm7, [rsi + rax*4 + 8]
	movlps xmm3, [rsi + rcx*4 + 8]
	movhps xmm7, [rsi + rbx*4 + 8]
	movhps xmm3, [rsi + rdx*4 + 8] ;# other half of coulomb table  
	movaps xmm6, xmm7
	shufps xmm6, xmm3, 136  ;# 10001000
	shufps xmm7, xmm3, 221  ;# 11011101
	;# coulomb table ready, in xmm4-xmm7  

	mulps  xmm6, xmm1   	;# xmm6=Geps 
	mulps  xmm7, xmm2   	;# xmm7=Heps2 
	addps  xmm5, xmm6
	addps  xmm5, xmm7   	;# xmm5=Fp 
	mulps  xmm7, [rsp + nb302_two]   	;# two*Heps2 
	movaps xmm3, [rsp + nb302_qqOH]
	addps  xmm7, xmm6
	addps  xmm7, xmm5 ;# xmm7=FF 
	mulps  xmm5, xmm1 ;# xmm5=eps*Fp 
	addps  xmm5, xmm4 ;# xmm5=VV 
	mulps  xmm5, xmm3 ;# vcoul=qq*VV  
	mulps  xmm3, xmm7 ;# fijC=FF*qq 
	;# at this point mm5 contains vcoul and mm3 fijC 

	addps  xmm5, [rsp + nb302_vctot]
	movaps [rsp + nb302_vctot], xmm5
	xorps  xmm1, xmm1
	mulps  xmm3,  [rsp + nb302_tsc]
	mulps  xmm3, xmm0
	subps  xmm1, xmm3

	movaps xmm0, xmm1
	movaps xmm2, xmm1
	
	xorps xmm3, xmm3
	movaps xmm4, xmm3
	movaps xmm5, xmm3
	mulps xmm0, [rsp + nb302_dxOH1]
	mulps xmm1, [rsp + nb302_dyOH1]
	mulps xmm2, [rsp + nb302_dzOH1]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [rsp + nb302_fixO]
	addps xmm1, [rsp + nb302_fiyO]
	addps xmm2, [rsp + nb302_fizO]
	movaps [rsp + nb302_fjxH1], xmm3
	movaps [rsp + nb302_fjyH1], xmm4
	movaps [rsp + nb302_fjzH1], xmm5
	movaps [rsp + nb302_fixO], xmm0
	movaps [rsp + nb302_fiyO], xmm1
	movaps [rsp + nb302_fizO], xmm2

	;# O-H2 interaction  
	movaps xmm0, [rsp + nb302_rinvOH2]
	movaps xmm1, xmm0
	mulps  xmm1, [rsp + nb302_rsqOH2] ;# xmm1=r 
	mulps  xmm1, [rsp + nb302_tsc]	
	movhlps xmm2, xmm1
	cvttps2pi mm6, xmm1
	cvttps2pi mm7, xmm2 	;# mm6/mm7 contain lu indices 
	cvtpi2ps xmm3, mm6
	cvtpi2ps xmm2, mm7
	movlhps  xmm3, xmm2
	subps    xmm1, xmm3	;# xmm1=eps 
	movaps xmm2, xmm1
	mulps  xmm2, xmm2   	;# xmm2=eps2 

	pslld   mm6, 2
	pslld   mm7, 2

	movd eax, mm6
	psrlq mm6, 32
	movd ecx, mm7
	psrlq mm7, 32
	movd ebx, mm6
	movd edx, mm7

	movlps xmm5, [rsi + rax*4]
	movlps xmm7, [rsi + rcx*4]
	movhps xmm5, [rsi + rbx*4]
	movhps xmm7, [rsi + rdx*4] ;# got half coulomb table 

	movaps xmm4, xmm5
	shufps xmm4, xmm7, 136  ;# 10001000
	shufps xmm5, xmm7, 221  ;# 11011101

	movlps xmm7, [rsi + rax*4 + 8]
	movlps xmm3, [rsi + rcx*4 + 8]
	movhps xmm7, [rsi + rbx*4 + 8]
	movhps xmm3, [rsi + rdx*4 + 8] ;# other half of coulomb table  
	movaps xmm6, xmm7
	shufps xmm6, xmm3, 136  ;# 10001000
	shufps xmm7, xmm3, 221  ;# 11011101
	;# coulomb table ready, in xmm4-xmm7  

	mulps  xmm6, xmm1   	;# xmm6=Geps 
	mulps  xmm7, xmm2   	;# xmm7=Heps2 
	addps  xmm5, xmm6
	addps  xmm5, xmm7   	;# xmm5=Fp 
	mulps  xmm7, [rsp + nb302_two]   	;# two*Heps2 
	movaps xmm3, [rsp + nb302_qqOH]
	addps  xmm7, xmm6
	addps  xmm7, xmm5 ;# xmm7=FF 
	mulps  xmm5, xmm1 ;# xmm5=eps*Fp 
	addps  xmm5, xmm4 ;# xmm5=VV 
	mulps  xmm5, xmm3 ;# vcoul=qq*VV  
	mulps  xmm3, xmm7 ;# fijC=FF*qq 
	;# at this point mm5 contains vcoul and mm3 fijC 

	addps  xmm5, [rsp + nb302_vctot]
	movaps [rsp + nb302_vctot], xmm5
	xorps  xmm1, xmm1
	mulps  xmm3,  [rsp + nb302_tsc]
	mulps  xmm3, xmm0
	subps  xmm1, xmm3

	movaps xmm0, xmm1
	movaps xmm2, xmm1
	
	xorps xmm3, xmm3
	movaps xmm4, xmm3
	movaps xmm5, xmm3
	mulps xmm0, [rsp + nb302_dxOH2]
	mulps xmm1, [rsp + nb302_dyOH2]
	mulps xmm2, [rsp + nb302_dzOH2]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [rsp + nb302_fixO]
	addps xmm1, [rsp + nb302_fiyO]
	addps xmm2, [rsp + nb302_fizO]
	movaps [rsp + nb302_fjxH2], xmm3
	movaps [rsp + nb302_fjyH2], xmm4
	movaps [rsp + nb302_fjzH2], xmm5
	movaps [rsp + nb302_fixO], xmm0
	movaps [rsp + nb302_fiyO], xmm1
	movaps [rsp + nb302_fizO], xmm2

	;# H1-O interaction 
	movaps xmm0, [rsp + nb302_rinvH1O]
	movaps xmm1, xmm0
	mulps  xmm1, [rsp + nb302_rsqH1O] ;# xmm1=r 
	mulps  xmm1, [rsp + nb302_tsc]	
	movhlps xmm2, xmm1
	cvttps2pi mm6, xmm1
	cvttps2pi mm7, xmm2 	;# mm6/mm7 contain lu indices 
	cvtpi2ps xmm3, mm6
	cvtpi2ps xmm2, mm7
	movlhps  xmm3, xmm2
	subps    xmm1, xmm3	;# xmm1=eps 
	movaps xmm2, xmm1
	mulps  xmm2, xmm2   	;# xmm2=eps2 

	pslld   mm6, 2
	pslld   mm7, 2

	movd eax, mm6
	psrlq mm6, 32
	movd ecx, mm7
	psrlq mm7, 32
	movd ebx, mm6
	movd edx, mm7

	movlps xmm5, [rsi + rax*4]
	movlps xmm7, [rsi + rcx*4]
	movhps xmm5, [rsi + rbx*4]
	movhps xmm7, [rsi + rdx*4] ;# got half coulomb table 

	movaps xmm4, xmm5
	shufps xmm4, xmm7, 136  ;# 10001000
	shufps xmm5, xmm7, 221  ;# 11011101

	movlps xmm7, [rsi + rax*4 + 8]
	movlps xmm3, [rsi + rcx*4 + 8]
	movhps xmm7, [rsi + rbx*4 + 8]
	movhps xmm3, [rsi + rdx*4 + 8] ;# other half of coulomb table  
	movaps xmm6, xmm7
	shufps xmm6, xmm3, 136  ;# 10001000
	shufps xmm7, xmm3, 221  ;# 11011101
	;# coulomb table ready, in xmm4-xmm7  

	mulps  xmm6, xmm1   	;# xmm6=Geps 
	mulps  xmm7, xmm2   	;# xmm7=Heps2 
	addps  xmm5, xmm6
	addps  xmm5, xmm7   	;# xmm5=Fp 
	mulps  xmm7, [rsp + nb302_two]   	;# two*Heps2 
	movaps xmm3, [rsp + nb302_qqOH]
	addps  xmm7, xmm6
	addps  xmm7, xmm5 ;# xmm7=FF 
	mulps  xmm5, xmm1 ;# xmm5=eps*Fp 
	addps  xmm5, xmm4 ;# xmm5=VV 
	mulps  xmm5, xmm3 ;# vcoul=qq*VV  
	mulps  xmm3, xmm7 ;# fijC=FF*qq 
	;# at this point mm5 contains vcoul and mm3 fijC 

	addps  xmm5, [rsp + nb302_vctot]
	movaps [rsp + nb302_vctot], xmm5
	xorps  xmm1, xmm1
	mulps  xmm3,  [rsp + nb302_tsc]
	mulps  xmm3, xmm0
	subps  xmm1, xmm3

	movaps xmm0, xmm1
	movaps xmm2, xmm1
	
	movaps xmm3, [rsp + nb302_fjxO]
	movaps xmm4, [rsp + nb302_fjyO]
	movaps xmm5, [rsp + nb302_fjzO]
	mulps xmm0, [rsp + nb302_dxH1O]
	mulps xmm1, [rsp + nb302_dyH1O]
	mulps xmm2, [rsp + nb302_dzH1O]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [rsp + nb302_fixH1]
	addps xmm1, [rsp + nb302_fiyH1]
	addps xmm2, [rsp + nb302_fizH1]
	movaps [rsp + nb302_fjxO], xmm3
	movaps [rsp + nb302_fjyO], xmm4
	movaps [rsp + nb302_fjzO], xmm5
	movaps [rsp + nb302_fixH1], xmm0
	movaps [rsp + nb302_fiyH1], xmm1
	movaps [rsp + nb302_fizH1], xmm2

	;# H1-H1 interaction 
	movaps xmm0, [rsp + nb302_rinvH1H1]
	movaps xmm1, xmm0
	mulps  xmm1, [rsp + nb302_rsqH1H1] ;# xmm1=r 
	mulps  xmm1, [rsp + nb302_tsc]	
	movhlps xmm2, xmm1
	cvttps2pi mm6, xmm1
	cvttps2pi mm7, xmm2 	;# mm6/mm7 contain lu indices 
	cvtpi2ps xmm3, mm6
	cvtpi2ps xmm2, mm7
	movlhps  xmm3, xmm2
	subps    xmm1, xmm3	;# xmm1=eps 
	movaps xmm2, xmm1
	mulps  xmm2, xmm2   	;# xmm2=eps2 

	pslld   mm6, 2
	pslld   mm7, 2

	movd eax, mm6
	psrlq mm6, 32
	movd ecx, mm7
	psrlq mm7, 32
	movd ebx, mm6
	movd edx, mm7

	movlps xmm5, [rsi + rax*4]
	movlps xmm7, [rsi + rcx*4]
	movhps xmm5, [rsi + rbx*4]
	movhps xmm7, [rsi + rdx*4] ;# got half coulomb table 

	movaps xmm4, xmm5
	shufps xmm4, xmm7, 136  ;# 10001000
	shufps xmm5, xmm7, 221  ;# 11011101

	movlps xmm7, [rsi + rax*4 + 8]
	movlps xmm3, [rsi + rcx*4 + 8]
	movhps xmm7, [rsi + rbx*4 + 8]
	movhps xmm3, [rsi + rdx*4 + 8] ;# other half of coulomb table  
	movaps xmm6, xmm7
	shufps xmm6, xmm3, 136  ;# 10001000
	shufps xmm7, xmm3, 221  ;# 11011101
	;# coulomb table ready, in xmm4-xmm7  

	mulps  xmm6, xmm1   	;# xmm6=Geps 
	mulps  xmm7, xmm2   	;# xmm7=Heps2 
	addps  xmm5, xmm6
	addps  xmm5, xmm7   	;# xmm5=Fp 
	mulps  xmm7, [rsp + nb302_two]   	;# two*Heps2 
	movaps xmm3, [rsp + nb302_qqHH]
	addps  xmm7, xmm6
	addps  xmm7, xmm5 ;# xmm7=FF 
	mulps  xmm5, xmm1 ;# xmm5=eps*Fp 
	addps  xmm5, xmm4 ;# xmm5=VV 
	mulps  xmm5, xmm3 ;# vcoul=qq*VV  
	mulps  xmm3, xmm7 ;# fijC=FF*qq 
	;# at this point mm5 contains vcoul and mm3 fijC 

	addps  xmm5, [rsp + nb302_vctot]
	movaps [rsp + nb302_vctot], xmm5
	xorps  xmm1, xmm1
	mulps  xmm3,  [rsp + nb302_tsc]
	mulps  xmm3, xmm0
	subps  xmm1, xmm3

	movaps xmm0, xmm1
	movaps xmm2, xmm1
	
	movaps xmm3, [rsp + nb302_fjxH1]
	movaps xmm4, [rsp + nb302_fjyH1]
	movaps xmm5, [rsp + nb302_fjzH1]
	mulps xmm0, [rsp + nb302_dxH1H1]
	mulps xmm1, [rsp + nb302_dyH1H1]
	mulps xmm2, [rsp + nb302_dzH1H1]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [rsp + nb302_fixH1]
	addps xmm1, [rsp + nb302_fiyH1]
	addps xmm2, [rsp + nb302_fizH1]
	movaps [rsp + nb302_fjxH1], xmm3
	movaps [rsp + nb302_fjyH1], xmm4
	movaps [rsp + nb302_fjzH1], xmm5
	movaps [rsp + nb302_fixH1], xmm0
	movaps [rsp + nb302_fiyH1], xmm1
	movaps [rsp + nb302_fizH1], xmm2

	;# H1-H2 interaction 
	movaps xmm0, [rsp + nb302_rinvH1H2]
	movaps xmm1, xmm0
	mulps  xmm1, [rsp + nb302_rsqH1H2] ;# xmm1=r 
	mulps  xmm1, [rsp + nb302_tsc]
	movhlps xmm2, xmm1
	cvttps2pi mm6, xmm1
	cvttps2pi mm7, xmm2 	;# mm6/mm7 contain lu indices 
	cvtpi2ps xmm3, mm6
	cvtpi2ps xmm2, mm7
	movlhps  xmm3, xmm2
	subps    xmm1, xmm3	;# xmm1=eps 
	movaps xmm2, xmm1
	mulps  xmm2, xmm2   	;# xmm2=eps2 

	pslld   mm6, 2
	pslld   mm7, 2

	movd eax, mm6
	psrlq mm6, 32
	movd ecx, mm7
	psrlq mm7, 32
	movd ebx, mm6
	movd edx, mm7

	movlps xmm5, [rsi + rax*4]
	movlps xmm7, [rsi + rcx*4]
	movhps xmm5, [rsi + rbx*4]
	movhps xmm7, [rsi + rdx*4] ;# got half coulomb table 

	movaps xmm4, xmm5
	shufps xmm4, xmm7, 136  ;# 10001000
	shufps xmm5, xmm7, 221  ;# 11011101

	movlps xmm7, [rsi + rax*4 + 8]
	movlps xmm3, [rsi + rcx*4 + 8]
	movhps xmm7, [rsi + rbx*4 + 8]
	movhps xmm3, [rsi + rdx*4 + 8] ;# other half of coulomb table  
	movaps xmm6, xmm7
	shufps xmm6, xmm3, 136  ;# 10001000
	shufps xmm7, xmm3, 221  ;# 11011101
	;# coulomb table ready, in xmm4-xmm7  

	mulps  xmm6, xmm1   	;# xmm6=Geps 
	mulps  xmm7, xmm2   	;# xmm7=Heps2 
	addps  xmm5, xmm6
	addps  xmm5, xmm7   	;# xmm5=Fp 
	mulps  xmm7, [rsp + nb302_two]   	;# two*Heps2 
	movaps xmm3, [rsp + nb302_qqHH]
	addps  xmm7, xmm6
	addps  xmm7, xmm5 ;# xmm7=FF 
	mulps  xmm5, xmm1 ;# xmm5=eps*Fp 
	addps  xmm5, xmm4 ;# xmm5=VV 
	mulps  xmm5, xmm3 ;# vcoul=qq*VV  
	mulps  xmm3, xmm7 ;# fijC=FF*qq 
	;# at this point mm5 contains vcoul and mm3 fijC 

	addps  xmm5, [rsp + nb302_vctot]
	movaps [rsp + nb302_vctot], xmm5
	xorps  xmm1, xmm1
	mulps  xmm3,  [rsp + nb302_tsc]
	mulps  xmm3, xmm0
	subps  xmm1, xmm3

	movaps xmm0, xmm1
	movaps xmm2, xmm1
	
	movaps xmm3, [rsp + nb302_fjxH2]
	movaps xmm4, [rsp + nb302_fjyH2]
	movaps xmm5, [rsp + nb302_fjzH2]
	mulps xmm0, [rsp + nb302_dxH1H2]
	mulps xmm1, [rsp + nb302_dyH1H2]
	mulps xmm2, [rsp + nb302_dzH1H2]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [rsp + nb302_fixH1]
	addps xmm1, [rsp + nb302_fiyH1]
	addps xmm2, [rsp + nb302_fizH1]
	movaps [rsp + nb302_fjxH2], xmm3
	movaps [rsp + nb302_fjyH2], xmm4
	movaps [rsp + nb302_fjzH2], xmm5
	movaps [rsp + nb302_fixH1], xmm0
	movaps [rsp + nb302_fiyH1], xmm1
	movaps [rsp + nb302_fizH1], xmm2

	;# H2-O interaction 
	movaps xmm0, [rsp + nb302_rinvH2O]
	movaps xmm1, xmm0
	mulps  xmm1, [rsp + nb302_rsqH2O] ;# xmm1=r 
	mulps  xmm1, [rsp + nb302_tsc]	
	movhlps xmm2, xmm1
	cvttps2pi mm6, xmm1
	cvttps2pi mm7, xmm2 	;# mm6/mm7 contain lu indices 
	cvtpi2ps xmm3, mm6
	cvtpi2ps xmm2, mm7
	movlhps  xmm3, xmm2
	subps    xmm1, xmm3	;# xmm1=eps 
	movaps xmm2, xmm1
	mulps  xmm2, xmm2   	;# xmm2=eps2 

	pslld   mm6, 2
	pslld   mm7, 2

	movd eax, mm6
	psrlq mm6, 32
	movd ecx, mm7
	psrlq mm7, 32
	movd ebx, mm6
	movd edx, mm7

	movlps xmm5, [rsi + rax*4]
	movlps xmm7, [rsi + rcx*4]
	movhps xmm5, [rsi + rbx*4]
	movhps xmm7, [rsi + rdx*4] ;# got half coulomb table 

	movaps xmm4, xmm5
	shufps xmm4, xmm7, 136  ;# 10001000
	shufps xmm5, xmm7, 221  ;# 11011101

	movlps xmm7, [rsi + rax*4 + 8]
	movlps xmm3, [rsi + rcx*4 + 8]
	movhps xmm7, [rsi + rbx*4 + 8]
	movhps xmm3, [rsi + rdx*4 + 8] ;# other half of coulomb table  
	movaps xmm6, xmm7
	shufps xmm6, xmm3, 136  ;# 10001000
	shufps xmm7, xmm3, 221  ;# 11011101
	;# coulomb table ready, in xmm4-xmm7  

	mulps  xmm6, xmm1   	;# xmm6=Geps 
	mulps  xmm7, xmm2   	;# xmm7=Heps2 
	addps  xmm5, xmm6
	addps  xmm5, xmm7   	;# xmm5=Fp 
	mulps  xmm7, [rsp + nb302_two]   	;# two*Heps2 
	movaps xmm3, [rsp + nb302_qqOH]
	addps  xmm7, xmm6
	addps  xmm7, xmm5 ;# xmm7=FF 
	mulps  xmm5, xmm1 ;# xmm5=eps*Fp 
	addps  xmm5, xmm4 ;# xmm5=VV 
	mulps  xmm5, xmm3 ;# vcoul=qq*VV  
	mulps  xmm3, xmm7 ;# fijC=FF*qq 
	;# at this point mm5 contains vcoul and mm3 fijC 

	addps  xmm5, [rsp + nb302_vctot]
	movaps [rsp + nb302_vctot], xmm5
	xorps  xmm1, xmm1
	mulps  xmm3,  [rsp + nb302_tsc]
	mulps  xmm3, xmm0
	subps  xmm1, xmm3

	movaps xmm0, xmm1
	movaps xmm2, xmm1

	movaps xmm3, [rsp + nb302_fjxO]
	movaps xmm4, [rsp + nb302_fjyO]
	movaps xmm5, [rsp + nb302_fjzO]
	mulps xmm0, [rsp + nb302_dxH2O]
	mulps xmm1, [rsp + nb302_dyH2O]
	mulps xmm2, [rsp + nb302_dzH2O]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [rsp + nb302_fixH2]
	addps xmm1, [rsp + nb302_fiyH2]
	addps xmm2, [rsp + nb302_fizH2]
	movaps [rsp + nb302_fjxO], xmm3
	movaps [rsp + nb302_fjyO], xmm4
	movaps [rsp + nb302_fjzO], xmm5
	movaps [rsp + nb302_fixH2], xmm0
	movaps [rsp + nb302_fiyH2], xmm1
	movaps [rsp + nb302_fizH2], xmm2

	;# H2-H1 interaction 
	movaps xmm0, [rsp + nb302_rinvH2H1]
	movaps xmm1, xmm0
	mulps  xmm1, [rsp + nb302_rsqH2H1] ;# xmm1=r 
	mulps  xmm1, [rsp + nb302_tsc]
	movhlps xmm2, xmm1
	cvttps2pi mm6, xmm1
	cvttps2pi mm7, xmm2 	;# mm6/mm7 contain lu indices 
	cvtpi2ps xmm3, mm6
	cvtpi2ps xmm2, mm7
	movlhps  xmm3, xmm2
	subps    xmm1, xmm3	;# xmm1=eps 
	movaps xmm2, xmm1
	mulps  xmm2, xmm2   	;# xmm2=eps2 

	pslld   mm6, 2
	pslld   mm7, 2

	movd eax, mm6
	psrlq mm6, 32
	movd ecx, mm7
	psrlq mm7, 32
	movd ebx, mm6
	movd edx, mm7

	movlps xmm5, [rsi + rax*4]
	movlps xmm7, [rsi + rcx*4]
	movhps xmm5, [rsi + rbx*4]
	movhps xmm7, [rsi + rdx*4] ;# got half coulomb table 

	movaps xmm4, xmm5
	shufps xmm4, xmm7, 136  ;# 10001000
	shufps xmm5, xmm7, 221  ;# 11011101

	movlps xmm7, [rsi + rax*4 + 8]
	movlps xmm3, [rsi + rcx*4 + 8]
	movhps xmm7, [rsi + rbx*4 + 8]
	movhps xmm3, [rsi + rdx*4 + 8] ;# other half of coulomb table  
	movaps xmm6, xmm7
	shufps xmm6, xmm3, 136  ;# 10001000
	shufps xmm7, xmm3, 221  ;# 11011101
	;# coulomb table ready, in xmm4-xmm7  

	mulps  xmm6, xmm1   	;# xmm6=Geps 
	mulps  xmm7, xmm2   	;# xmm7=Heps2 
	addps  xmm5, xmm6
	addps  xmm5, xmm7   	;# xmm5=Fp 
	mulps  xmm7, [rsp + nb302_two]   	;# two*Heps2 
	movaps xmm3, [rsp + nb302_qqHH]
	addps  xmm7, xmm6
	addps  xmm7, xmm5 ;# xmm7=FF 
	mulps  xmm5, xmm1 ;# xmm5=eps*Fp 
	addps  xmm5, xmm4 ;# xmm5=VV 
	mulps  xmm5, xmm3 ;# vcoul=qq*VV  
	mulps  xmm3, xmm7 ;# fijC=FF*qq 
	;# at this point mm5 contains vcoul and mm3 fijC 

	addps  xmm5, [rsp + nb302_vctot]
	movaps [rsp + nb302_vctot], xmm5
	xorps  xmm1, xmm1
	mulps  xmm3,  [rsp + nb302_tsc]
	mulps  xmm3, xmm0
	subps  xmm1, xmm3

	movaps xmm0, xmm1
	movaps xmm2, xmm1
	
	movaps xmm3, [rsp + nb302_fjxH1]
	movaps xmm4, [rsp + nb302_fjyH1]
	movaps xmm5, [rsp + nb302_fjzH1]
	mulps xmm0, [rsp + nb302_dxH2H1]
	mulps xmm1, [rsp + nb302_dyH2H1]
	mulps xmm2, [rsp + nb302_dzH2H1]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [rsp + nb302_fixH2]
	addps xmm1, [rsp + nb302_fiyH2]
	addps xmm2, [rsp + nb302_fizH2]
	movaps [rsp + nb302_fjxH1], xmm3
	movaps [rsp + nb302_fjyH1], xmm4
	movaps [rsp + nb302_fjzH1], xmm5
	movaps [rsp + nb302_fixH2], xmm0
	movaps [rsp + nb302_fiyH2], xmm1
	movaps [rsp + nb302_fizH2], xmm2

	;# H2-H2 interaction 
	movaps xmm0, [rsp + nb302_rinvH2H2]
	movaps xmm1, xmm0
	mulps  xmm1, [rsp + nb302_rsqH2H2] ;# xmm1=r 
	mulps  xmm1, [rsp + nb302_tsc]	
	movhlps xmm2, xmm1
	cvttps2pi mm6, xmm1
	cvttps2pi mm7, xmm2 	;# mm6/mm7 contain lu indices 
	cvtpi2ps xmm3, mm6
	cvtpi2ps xmm2, mm7
	movlhps  xmm3, xmm2
	subps    xmm1, xmm3	;# xmm1=eps 
	movaps xmm2, xmm1
	mulps  xmm2, xmm2   	;# xmm2=eps2 

	pslld   mm6, 2
	pslld   mm7, 2

	movd eax, mm6
	psrlq mm6, 32
	movd ecx, mm7
	psrlq mm7, 32
	movd ebx, mm6
	movd edx, mm7

	movlps xmm5, [rsi + rax*4]
	movlps xmm7, [rsi + rcx*4]
	movhps xmm5, [rsi + rbx*4]
	movhps xmm7, [rsi + rdx*4] ;# got half coulomb table 

	movaps xmm4, xmm5
	shufps xmm4, xmm7, 136  ;# 10001000
	shufps xmm5, xmm7, 221  ;# 11011101

	movlps xmm7, [rsi + rax*4 + 8]
	movlps xmm3, [rsi + rcx*4 + 8]
	movhps xmm7, [rsi + rbx*4 + 8]
	movhps xmm3, [rsi + rdx*4 + 8] ;# other half of coulomb table  
	movaps xmm6, xmm7
	shufps xmm6, xmm3, 136  ;# 10001000
	shufps xmm7, xmm3, 221  ;# 11011101
	;# coulomb table ready, in xmm4-xmm7  

	mulps  xmm6, xmm1   	;# xmm6=Geps 
	mulps  xmm7, xmm2   	;# xmm7=Heps2 
	addps  xmm5, xmm6
	addps  xmm5, xmm7   	;# xmm5=Fp 
	mulps  xmm7, [rsp + nb302_two]   	;# two*Heps2 
	movaps xmm3, [rsp + nb302_qqHH]
	addps  xmm7, xmm6
	addps  xmm7, xmm5 ;# xmm7=FF 
	mulps  xmm5, xmm1 ;# xmm5=eps*Fp 
	addps  xmm5, xmm4 ;# xmm5=VV 
	mulps  xmm5, xmm3 ;# vcoul=qq*VV  
	mulps  xmm3, xmm7 ;# fijC=FF*qq 
	;# at this point mm5 contains vcoul and mm3 fijC 

	addps  xmm5, [rsp + nb302_vctot]
	movaps [rsp + nb302_vctot], xmm5
	xorps  xmm1, xmm1
	mulps  xmm3,  [rsp + nb302_tsc]
	mulps  xmm3, xmm0
	subps  xmm1, xmm3

	movaps xmm0, xmm1
	movaps xmm2, xmm1
	
	movaps xmm3, [rsp + nb302_fjxH2]
	movaps xmm4, [rsp + nb302_fjyH2]
	movaps xmm5, [rsp + nb302_fjzH2]
	mulps xmm0, [rsp + nb302_dxH2H2]
	mulps xmm1, [rsp + nb302_dyH2H2]
	mulps xmm2, [rsp + nb302_dzH2H2]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [rsp + nb302_fixH2]
	addps xmm1, [rsp + nb302_fiyH2]
	addps xmm2, [rsp + nb302_fizH2]
	movaps [rsp + nb302_fjxH2], xmm3
	movaps [rsp + nb302_fjyH2], xmm4
	movaps [rsp + nb302_fjzH2], xmm5
	movaps [rsp + nb302_fixH2], xmm0
	movaps [rsp + nb302_fiyH2], xmm1
	movaps [rsp + nb302_fizH2], xmm2

	mov rdi, [rbp + nb302_faction]

	movd eax, mm0
	movd ebx, mm1
	movd ecx, mm2
	movd edx, mm3
	
	;# Did all interactions - now update j forces 
	;# At this stage forces are still on the stack, in positions:
	;# fjxO, fjyO, fjzO, ... , fjzH2.
	;# Each position is a quadruplet of forces for the four 
	;# corresponding j waters, so we need to transpose them before
	;# adding to the memory positions.
	;# 
	;# This _used_ to be a simple transpose, but the resulting high number
	;# of unaligned 128-bit load/stores might trigger a possible hardware 
	;# bug on Athlon and Opteron chips, so I have worked around it
	;# to use 64-bit load/stores instead. The performance hit should be
	;# very modest, since the 128-bit unaligned memory instructions were
	;# slow anyway. 
	
	
	;# 4 j waters with three atoms each - first do Oxygen X & Y forces for 4 j particles 
	movaps xmm0, [rsp + nb302_fjxO] ;# xmm0= fjxOa  fjxOb  fjxOc  fjxOd 
	movaps xmm2, [rsp + nb302_fjyO] ;# xmm1= fjyOa  fjyOb  fjyOc  fjyOd
	movlps xmm3, [rdi + rax*4]
	movlps xmm4, [rdi + rcx*4]
	movaps xmm1, xmm0
	unpcklps xmm0, xmm2    	   ;# xmm0= fjxOa  fjyOa  fjxOb  fjyOb
	unpckhps xmm1, xmm2        ;# xmm1= fjxOc  fjyOc  fjxOd  fjyOd
	movhps xmm3, [rdi + rbx*4]
	movhps xmm4, [rdi + rdx*4]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	movlps [rdi + rax*4], xmm3
	movlps [rdi + rcx*4], xmm4
	movhps [rdi + rbx*4], xmm3
	movhps [rdi + rdx*4], xmm4
	
	;# Oxygen Z & first hydrogen X forces for 4 j particles 
	movaps xmm0, [rsp + nb302_fjzO]  ;# xmm0= fjzOa   fjzOb   fjzOc   fjzOd 
	movaps xmm2, [rsp + nb302_fjxH1] ;# xmm1= fjxH1a  fjxH1b  fjxH1c  fjxH1d
	movlps xmm3, [rdi + rax*4 + 8]
	movlps xmm4, [rdi + rcx*4 + 8]
	movaps xmm1, xmm0
	unpcklps xmm0, xmm2    	   ;# xmm0= fjzOa  fjxH1a  fjzOb  fjxH1b
	unpckhps xmm1, xmm2        ;# xmm1= fjzOc  fjxH1c  fjzOd  fjxH1d
	movhps xmm3, [rdi + rbx*4 + 8]
	movhps xmm4, [rdi + rdx*4 + 8]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	movlps [rdi + rax*4 + 8], xmm3
	movlps [rdi + rcx*4 + 8], xmm4
	movhps [rdi + rbx*4 + 8], xmm3
	movhps [rdi + rdx*4 + 8], xmm4

	
	;# First hydrogen Y & Z forces for 4 j particles 
	movaps xmm0, [rsp + nb302_fjyH1]  ;# xmm0= fjyH1a  fjyH1b  fjyH1c  fjyH1d 
	movaps xmm2, [rsp + nb302_fjzH1] ;# xmm1= fjzH1a  fjzH1b  fjzH1c  fjzH1d
	movlps xmm3, [rdi + rax*4 + 16]
	movlps xmm4, [rdi + rcx*4 + 16]
	movaps xmm1, xmm0
	unpcklps xmm0, xmm2		;# xmm0= fjyH1a  fjzH1a  fjyH1b  fjzH1b
	unpckhps xmm1, xmm2		;# xmm1= fjyH1c  fjzH1c  fjyH1d  fjzH1d
	movhps xmm3, [rdi + rbx*4 + 16]
	movhps xmm4, [rdi + rdx*4 + 16]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	movlps [rdi + rax*4 + 16], xmm3
	movlps [rdi + rcx*4 + 16], xmm4
	movhps [rdi + rbx*4 + 16], xmm3
	movhps [rdi + rdx*4 + 16], xmm4

	
	;# Second hydrogen X & Y forces for 4 j particles 
	movaps xmm0, [rsp + nb302_fjxH2]  ;# xmm0= fjxH2a  fjxH2b  fjxH2c  fjxH2d 
	movaps xmm2, [rsp + nb302_fjyH2] ;# xmm1= fjyH2a  fjyH2b  fjyH2c  fjyH2d
	movlps xmm3, [rdi + rax*4 + 24]
	movlps xmm4, [rdi + rcx*4 + 24]
	movaps xmm1, xmm0
	unpcklps xmm0, xmm2		;# xmm0= fjxH2a  fjyH2a  fjxH2b  fjyH2b
	unpckhps xmm1, xmm2		;# xmm1= fjxH2c  fjyH2c  fjxH2d  fjyH2d
	movhps xmm3, [rdi + rbx*4 + 24]
	movhps xmm4, [rdi + rdx*4 + 24]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	movlps [rdi + rax*4 + 24], xmm3
	movlps [rdi + rcx*4 + 24], xmm4
	movhps [rdi + rbx*4 + 24], xmm3
	movhps [rdi + rdx*4 + 24], xmm4

	
	;# Second hydrogen Z forces for 4 j particles 
	;# Just load the four Z coords into one reg. each
	movss xmm4, [rdi + rax*4 + 32]
	movss xmm5, [rdi + rbx*4 + 32]
	movss xmm6, [rdi + rcx*4 + 32]
	movss xmm7, [rdi + rdx*4 + 32]
	;# add what we have on the stack
	addss xmm4, [rsp + nb302_fjzH2] 
	addss xmm5, [rsp + nb302_fjzH2 + 4] 
	addss xmm6, [rsp + nb302_fjzH2 + 8] 
	addss xmm7, [rsp + nb302_fjzH2 + 12]
	;# store back
	movss [rdi + rax*4 + 32], xmm4
	movss [rdi + rbx*4 + 32], xmm5
	movss [rdi + rcx*4 + 32], xmm6
	movss [rdi + rdx*4 + 32], xmm7
	
	;# should we do one more iteration? 
	sub dword ptr [rsp + nb302_innerk],  4
	jl    .nb302_single_check
	jmp   .nb302_unroll_loop
.nb302_single_check:
	add dword ptr [rsp + nb302_innerk],  4
	jnz   .nb302_single_loop
	jmp   .nb302_updateouterdata
.nb302_single_loop:
	mov   rdx, [rsp + nb302_innerjjnr] 	;# pointer to jjnr[k] 
	mov   eax, [rdx]	
	add qword ptr [rsp + nb302_innerjjnr],  4	

	mov rsi, [rbp + nb302_pos]
	lea   rax, [rax + rax*2]  

	;# fetch j coordinates 
	xorps xmm3, xmm3
	xorps xmm4, xmm4
	xorps xmm5, xmm5
	
	movss xmm3, [rsi + rax*4]		;# jxO  -  -  -
	movss xmm4, [rsi + rax*4 + 4]		;# jyO  -  -  -
	movss xmm5, [rsi + rax*4 + 8]		;# jzO  -  -  -  

	movlps xmm6, [rsi + rax*4 + 12]		;# xmm6 = jxH1 jyH1   -    -
	movss  xmm7, [rsi + rax*4 + 20]		;# xmm7 = jzH1   -    -    - 
	movhps xmm6, [rsi + rax*4 + 24]		;# xmm6 = jxH1 jyH1 jxH2 jyH2
	movss  xmm2, [rsi + rax*4 + 32]		;# xmm2 = jzH2   -    -    -
	
	;# have all coords, time for some shuffling.

	shufps xmm6, xmm6, 216 ;# 11011000	;# xmm6 = jxH1 jxH2 jyH1 jyH2 
	unpcklps xmm7, xmm2			;# xmm7 = jzH1 jzH2   -    -
	movaps  xmm0, [rsp + nb302_ixO]     
	movaps  xmm1, [rsp + nb302_iyO]
	movaps  xmm2, [rsp + nb302_izO]	
	movlhps xmm3, xmm6			;# xmm3 = jxO   0   jxH1 jxH2 
	shufps  xmm4, xmm6, 228 ;# 11100100	;# xmm4 = jyO   0   jyH1 jyH2 
	shufps  xmm5, xmm7, 68  ;# 01000100	;# xmm5 = jzO   0   jzH1 jzH2

	;# store all j coordinates in jO  
	movaps [rsp + nb302_jxO], xmm3
	movaps [rsp + nb302_jyO], xmm4
	movaps [rsp + nb302_jzO], xmm5
	subps  xmm0, xmm3
	subps  xmm1, xmm4
	subps  xmm2, xmm5
	movaps [rsp + nb302_dxOO], xmm0
	movaps [rsp + nb302_dyOO], xmm1
	movaps [rsp + nb302_dzOO], xmm2
	mulps xmm0, xmm0
	mulps xmm1, xmm1
	mulps xmm2, xmm2
	addps xmm0, xmm1
	addps xmm0, xmm2	;# have rsq in xmm0 
	
	;# do invsqrt 
	rsqrtps xmm1, xmm0
	movaps  xmm2, xmm1	
	mulps   xmm1, xmm1
	movaps  xmm3, [rsp + nb302_three]
	mulps   xmm1, xmm0
	subps   xmm3, xmm1
	mulps   xmm3, xmm2							
	mulps   xmm3, [rsp + nb302_half] ;# rinv iO - j water 

	movaps  xmm1, xmm3
	mulps   xmm1, xmm0	;# xmm1=r 
	movaps  xmm0, xmm3	;# xmm0=rinv 
	mulps  xmm1, [rsp + nb302_tsc]
	
	movhlps xmm2, xmm1	
	cvttps2pi mm6, xmm1
	cvttps2pi mm7, xmm2 	;# mm6/mm7 contain lu indices 
	cvtpi2ps xmm3, mm6
	cvtpi2ps xmm2, mm7
	movlhps  xmm3, xmm2
	subps    xmm1, xmm3	;# xmm1=eps 
	movaps xmm2, xmm1
	mulps  xmm2, xmm2   	;# xmm2=eps2 
	pslld   mm6, 2
	pslld   mm7, 2
	
	movd ebx, mm6
	movd ecx, mm7
	psrlq mm7, 32
	movd edx, mm7		;# table indices in ebx,ecx,edx 

	mov rsi, [rbp + nb302_VFtab]
	
	movlps xmm5, [rsi + rbx*4]
	movlps xmm7, [rsi + rcx*4]
	movhps xmm7, [rsi + rdx*4] ;# got half coulomb table 
	movaps xmm4, xmm5
	shufps xmm4, xmm7, 136  ;# 10001000
	shufps xmm5, xmm7, 221  ;# 11011101

	movlps xmm7, [rsi + rbx*4 + 8]
	movlps xmm3, [rsi + rcx*4 + 8]
	movhps xmm3, [rsi + rdx*4 + 8] ;# other half of coulomb table  
	movaps xmm6, xmm7
	shufps xmm6, xmm3, 136  ;# 10001000
	shufps xmm7, xmm3, 221  ;# 11011101
	;# coulomb table ready, in xmm4-xmm7  
	mulps  xmm6, xmm1   	;# xmm6=Geps 
	mulps  xmm7, xmm2   	;# xmm7=Heps2 
	addps  xmm5, xmm6
	addps  xmm5, xmm7   	;# xmm5=Fp 
	mulps  xmm7, [rsp + nb302_two]   	;# two*Heps2 

	xorps  xmm3, xmm3
	;# fetch charges to xmm3 (temporary) 
	movss   xmm3, [rsp + nb302_qqOO]
	movhps  xmm3, [rsp + nb302_qqOH]
	
	addps  xmm7, xmm6
	addps  xmm7, xmm5 ;# xmm7=FF 
	mulps  xmm5, xmm1 ;# xmm5=eps*Fp 
	addps  xmm5, xmm4 ;# xmm5=VV 
	mulps  xmm5, xmm3 ;# vcoul=qq*VV  
	mulps  xmm3, xmm7 ;# fijC=FF*qq 
	;# at this point xmm5 contains vcoul and xmm3 fijC 
	
	addps  xmm5, [rsp + nb302_vctot]
	movaps [rsp + nb302_vctot], xmm5
	xorps  xmm2, xmm2
	mulps  xmm3, [rsp + nb302_tsc]

	subps  xmm2, xmm3
	mulps  xmm0, xmm2
	
	movaps xmm1, xmm0
	movaps xmm2, xmm0			

	mulps   xmm0, [rsp + nb302_dxOO]
	mulps   xmm1, [rsp + nb302_dyOO]
	mulps   xmm2, [rsp + nb302_dzOO]
	;# initial update for j forces 
	xorps   xmm3, xmm3
	xorps   xmm4, xmm4
	xorps   xmm5, xmm5
	subps   xmm3, xmm0
	subps   xmm4, xmm1
	subps   xmm5, xmm2
	movaps  [rsp + nb302_fjxO], xmm3
	movaps  [rsp + nb302_fjyO], xmm4
	movaps  [rsp + nb302_fjzO], xmm5
	addps   xmm0, [rsp + nb302_fixO]
	addps   xmm1, [rsp + nb302_fiyO]
	addps   xmm2, [rsp + nb302_fizO]
	movaps  [rsp + nb302_fixO], xmm0
	movaps  [rsp + nb302_fiyO], xmm1
	movaps  [rsp + nb302_fizO], xmm2

	
	;# done with i O Now do i H1 & H2 simultaneously first get i particle coords: 
	movaps  xmm0, [rsp + nb302_ixH1]
	movaps  xmm1, [rsp + nb302_iyH1]
	movaps  xmm2, [rsp + nb302_izH1]	
	movaps  xmm3, [rsp + nb302_ixH2] 
	movaps  xmm4, [rsp + nb302_iyH2] 
	movaps  xmm5, [rsp + nb302_izH2] 
	subps   xmm0, [rsp + nb302_jxO]
	subps   xmm1, [rsp + nb302_jyO]
	subps   xmm2, [rsp + nb302_jzO]
	subps   xmm3, [rsp + nb302_jxO]
	subps   xmm4, [rsp + nb302_jyO]
	subps   xmm5, [rsp + nb302_jzO]
	movaps [rsp + nb302_dxH1O], xmm0
	movaps [rsp + nb302_dyH1O], xmm1
	movaps [rsp + nb302_dzH1O], xmm2
	movaps [rsp + nb302_dxH2O], xmm3
	movaps [rsp + nb302_dyH2O], xmm4
	movaps [rsp + nb302_dzH2O], xmm5
	mulps xmm0, xmm0
	mulps xmm1, xmm1
	mulps xmm2, xmm2
	mulps xmm3, xmm3
	mulps xmm4, xmm4
	mulps xmm5, xmm5
	addps xmm0, xmm1
	addps xmm4, xmm3
	addps xmm0, xmm2	;# have rsqH1 in xmm0 
	addps xmm4, xmm5	;# have rsqH2 in xmm4 

	;# start with H1, save H2 data 
	movaps [rsp + nb302_rsqH2O], xmm4
	
	;# do invsqrt 
	rsqrtps xmm1, xmm0
	rsqrtps xmm5, xmm4
	movaps  xmm2, xmm1
	movaps  xmm6, xmm5
	mulps   xmm1, xmm1
	mulps   xmm5, xmm5
	movaps  xmm3, [rsp + nb302_three]
	movaps  xmm7, xmm3
	mulps   xmm1, xmm0
	mulps   xmm5, xmm4
	subps   xmm3, xmm1
	subps   xmm7, xmm5
	mulps   xmm3, xmm2
	mulps   xmm7, xmm6
	mulps   xmm3, [rsp + nb302_half] ;# rinv H1 - j water 
	mulps   xmm7, [rsp + nb302_half] ;# rinv H2 - j water  

	;# start with H1, save H2 data 
	movaps [rsp + nb302_rinvH2O], xmm7

	movaps xmm1, xmm3
	mulps  xmm1, xmm0	;# xmm1=r 
	movaps xmm0, xmm3	;# xmm0=rinv 
	mulps  xmm1, [rsp + nb302_tsc]
	
	movhlps xmm2, xmm1	
	cvttps2pi mm6, xmm1
	cvttps2pi mm7, xmm2 	;# mm6/mm7 contain lu indices 
	cvtpi2ps xmm3, mm6
	cvtpi2ps xmm2, mm7
	movlhps  xmm3, xmm2
	subps    xmm1, xmm3	;# xmm1=eps 
	movaps xmm2, xmm1
	mulps  xmm2, xmm2   	;# xmm2=eps2 
	pslld   mm6, 2
	pslld   mm7, 2

	movd ebx, mm6
	movd ecx, mm7
	psrlq mm7, 32
	movd edx, mm7		;# table indices in ebx,ecx,edx 

	movlps xmm5, [rsi + rbx*4]
	movlps xmm7, [rsi + rcx*4]
	movhps xmm7, [rsi + rdx*4] ;# got half coulomb table 
	movaps xmm4, xmm5
	shufps xmm4, xmm7, 136  ;# 10001000
	shufps xmm5, xmm7, 221  ;# 11011101

	movlps xmm7, [rsi + rbx*4 + 8]
	movlps xmm3, [rsi + rcx*4 + 8]
	movhps xmm3, [rsi + rdx*4 + 8] ;# other half of coulomb table  
	movaps xmm6, xmm7
	shufps xmm6, xmm3, 136  ;# 10001000
	shufps xmm7, xmm3, 221  ;# 11011101
	;# coulomb table ready, in xmm4-xmm7  
	mulps  xmm6, xmm1   	;# xmm6=Geps 
	mulps  xmm7, xmm2   	;# xmm7=Heps2 
	addps  xmm5, xmm6
	addps  xmm5, xmm7   	;# xmm5=Fp 
	mulps  xmm7, [rsp + nb302_two]   	;# two*Heps2 

	xorps  xmm3, xmm3
	;# fetch charges to xmm3 (temporary) 
	movss   xmm3, [rsp + nb302_qqOH]
	movhps  xmm3, [rsp + nb302_qqHH]
	
	addps  xmm7, xmm6
	addps  xmm7, xmm5 ;# xmm7=FF 
	mulps  xmm5, xmm1 ;# xmm5=eps*Fp 
	addps  xmm5, xmm4 ;# xmm5=VV 
	mulps  xmm5, xmm3 ;# vcoul=qq*VV  
	mulps  xmm3, xmm7 ;# fijC=FF*qq 
	;# at this point xmm5 contains vcoul and xmm3 fijC 
	addps  xmm5, [rsp + nb302_vctot]
	movaps [rsp + nb302_vctot], xmm5	

    xorps  xmm1, xmm1

	mulps xmm3, [rsp + nb302_tsc]
	mulps xmm3, xmm0
	subps  xmm1, xmm3
	
	movaps  xmm0, xmm1
	movaps  xmm2, xmm1
	mulps   xmm0, [rsp + nb302_dxH1O]
	mulps   xmm1, [rsp + nb302_dyH1O]
	mulps   xmm2, [rsp + nb302_dzH1O]
	;# update forces H1 - j water 
	movaps  xmm3, [rsp + nb302_fjxO]
	movaps  xmm4, [rsp + nb302_fjyO]
	movaps  xmm5, [rsp + nb302_fjzO]
	subps   xmm3, xmm0
	subps   xmm4, xmm1
	subps   xmm5, xmm2
	movaps  [rsp + nb302_fjxO], xmm3
	movaps  [rsp + nb302_fjyO], xmm4
	movaps  [rsp + nb302_fjzO], xmm5
	addps   xmm0, [rsp + nb302_fixH1]
	addps   xmm1, [rsp + nb302_fiyH1]
	addps   xmm2, [rsp + nb302_fizH1]
	movaps  [rsp + nb302_fixH1], xmm0
	movaps  [rsp + nb302_fiyH1], xmm1
	movaps  [rsp + nb302_fizH1], xmm2
	;# do table for H2 - j water interaction 
	movaps xmm0, [rsp + nb302_rinvH2O]
	movaps xmm1, [rsp + nb302_rsqH2O]
	mulps  xmm1, xmm0	;# xmm0=rinv, xmm1=r 
	mulps  xmm1, [rsp + nb302_tsc]
	
	movhlps xmm2, xmm1	
	cvttps2pi mm6, xmm1
	cvttps2pi mm7, xmm2 	;# mm6/mm7 contain lu indices 
	cvtpi2ps xmm3, mm6
	cvtpi2ps xmm2, mm7
	movlhps  xmm3, xmm2
	subps    xmm1, xmm3	;# xmm1=eps 
	movaps xmm2, xmm1
	mulps  xmm2, xmm2   	;# xmm2=eps2 
	pslld   mm6, 2
	pslld   mm7, 2

	movd ebx, mm6
	movd ecx, mm7
	psrlq mm7, 32
	movd edx, mm7		;# table indices in ebx,ecx,edx 

	movlps xmm5, [rsi + rbx*4]
	movlps xmm7, [rsi + rcx*4]
	movhps xmm7, [rsi + rdx*4] ;# got half coulomb table 
	movaps xmm4, xmm5
	shufps xmm4, xmm7, 136  ;# 10001000
	shufps xmm5, xmm7, 221  ;# 11011101

	movlps xmm7, [rsi + rbx*4 + 8]
	movlps xmm3, [rsi + rcx*4 + 8]
	movhps xmm3, [rsi + rdx*4 + 8] ;# other half of coulomb table  
	movaps xmm6, xmm7
	shufps xmm6, xmm3, 136  ;# 10001000
	shufps xmm7, xmm3, 221  ;# 11011101
	;# coulomb table ready, in xmm4-xmm7  
	mulps  xmm6, xmm1   	;# xmm6=Geps 
	mulps  xmm7, xmm2   	;# xmm7=Heps2 
	addps  xmm5, xmm6
	addps  xmm5, xmm7   	;# xmm5=Fp 
	mulps  xmm7, [rsp + nb302_two]   	;# two*Heps2 

	xorps  xmm3, xmm3
	;# fetch charges to xmm3 (temporary) 
	movss   xmm3, [rsp + nb302_qqOH]
	movhps  xmm3, [rsp + nb302_qqHH]
	
	addps  xmm7, xmm6
	addps  xmm7, xmm5 ;# xmm7=FF 
	mulps  xmm5, xmm1 ;# xmm5=eps*Fp 
	addps  xmm5, xmm4 ;# xmm5=VV 
	mulps  xmm5, xmm3 ;# vcoul=qq*VV  
	mulps  xmm3, xmm7 ;# fijC=FF*qq 
	;# at this point xmm5 contains vcoul and xmm3 fijC 
	addps  xmm5, [rsp + nb302_vctot]
	movaps [rsp + nb302_vctot], xmm5	

    xorps  xmm1, xmm1

	mulps xmm3, [rsp + nb302_tsc]
	mulps xmm3, xmm0
	subps  xmm1, xmm3
	
	movaps  xmm0, xmm1
	movaps  xmm2, xmm1
	
	mulps   xmm0, [rsp + nb302_dxH2O]
	mulps   xmm1, [rsp + nb302_dyH2O]
	mulps   xmm2, [rsp + nb302_dzH2O]
	movaps  xmm3, [rsp + nb302_fjxO]
	movaps  xmm4, [rsp + nb302_fjyO]
	movaps  xmm5, [rsp + nb302_fjzO]
	subps   xmm3, xmm0
	subps   xmm4, xmm1
	subps   xmm5, xmm2
	mov     rsi, [rbp + nb302_faction]
	movaps  [rsp + nb302_fjxO], xmm3
	movaps  [rsp + nb302_fjyO], xmm4
	movaps  [rsp + nb302_fjzO], xmm5
	addps   xmm0, [rsp + nb302_fixH2]
	addps   xmm1, [rsp + nb302_fiyH2]
	addps   xmm2, [rsp + nb302_fizH2]
	movaps  [rsp + nb302_fixH2], xmm0
	movaps  [rsp + nb302_fiyH2], xmm1
	movaps  [rsp + nb302_fizH2], xmm2

	;# update j water forces from local variables 
	movlps  xmm0, [rsi + rax*4]
	movlps  xmm1, [rsi + rax*4 + 12]
	movhps  xmm1, [rsi + rax*4 + 24]
	movaps  xmm3, [rsp + nb302_fjxO]
	movaps  xmm4, [rsp + nb302_fjyO]
	movaps  xmm5, [rsp + nb302_fjzO]
	movaps  xmm6, xmm5
	movaps  xmm7, xmm5
	shufps  xmm6, xmm6, 2 ;# 00000010
	shufps  xmm7, xmm7, 3 ;# 00000011
	addss   xmm5, [rsi + rax*4 + 8]
	addss   xmm6, [rsi + rax*4 + 20]
	addss   xmm7, [rsi + rax*4 + 32]
	movss   [rsi + rax*4 + 8], xmm5
	movss   [rsi + rax*4 + 20], xmm6
	movss   [rsi + rax*4 + 32], xmm7
	movaps   xmm5, xmm3
	unpcklps xmm3, xmm4
	unpckhps xmm5, xmm4
	addps    xmm0, xmm3
	addps    xmm1, xmm5
	movlps  [rsi + rax*4], xmm0 
	movlps  [rsi + rax*4 + 12], xmm1 
	movhps  [rsi + rax*4 + 24], xmm1 
	
	dec dword ptr [rsp + nb302_innerk]
	jz    .nb302_updateouterdata
	jmp   .nb302_single_loop
.nb302_updateouterdata:
	mov   ecx, [rsp + nb302_ii3]
	mov   rdi, [rbp + nb302_faction]
	mov   rsi, [rbp + nb302_fshift]
	mov   edx, [rsp + nb302_is3]

	;# accumulate  Oi forces in xmm0, xmm1, xmm2 
	movaps xmm0, [rsp + nb302_fixO]
	movaps xmm1, [rsp + nb302_fiyO] 
	movaps xmm2, [rsp + nb302_fizO]

	movhlps xmm3, xmm0
	movhlps xmm4, xmm1
	movhlps xmm5, xmm2
	addps  xmm0, xmm3
	addps  xmm1, xmm4
	addps  xmm2, xmm5 ;# sum is in 1/2 in xmm0-xmm2 

	movaps xmm3, xmm0	
	movaps xmm4, xmm1	
	movaps xmm5, xmm2	

	shufps xmm3, xmm3, 1
	shufps xmm4, xmm4, 1
	shufps xmm5, xmm5, 1
	addss  xmm0, xmm3
	addss  xmm1, xmm4
	addss  xmm2, xmm5	;# xmm0-xmm2 has single force in pos0 

	;# increment i force 
	movss  xmm3, [rdi + rcx*4]
	movss  xmm4, [rdi + rcx*4 + 4]
	movss  xmm5, [rdi + rcx*4 + 8]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [rdi + rcx*4],     xmm3
	movss  [rdi + rcx*4 + 4], xmm4
	movss  [rdi + rcx*4 + 8], xmm5

	;# accumulate force in xmm6/xmm7 for fshift 
	movaps xmm6, xmm0
	movss xmm7, xmm2
	movlhps xmm6, xmm1
	shufps  xmm6, xmm6, 8 ;# 00001000	

	;# accumulate H1i forces in xmm0, xmm1, xmm2 
	movaps xmm0, [rsp + nb302_fixH1]
	movaps xmm1, [rsp + nb302_fiyH1]
	movaps xmm2, [rsp + nb302_fizH1]

	movhlps xmm3, xmm0
	movhlps xmm4, xmm1
	movhlps xmm5, xmm2
	addps  xmm0, xmm3
	addps  xmm1, xmm4
	addps  xmm2, xmm5 ;# sum is in 1/2 in xmm0-xmm2 

	movaps xmm3, xmm0	
	movaps xmm4, xmm1	
	movaps xmm5, xmm2	

	shufps xmm3, xmm3, 1
	shufps xmm4, xmm4, 1
	shufps xmm5, xmm5, 1
	addss  xmm0, xmm3
	addss  xmm1, xmm4
	addss  xmm2, xmm5	;# xmm0-xmm2 has single force in pos0 

	;# increment i force 
	movss  xmm3, [rdi + rcx*4 + 12]
	movss  xmm4, [rdi + rcx*4 + 16]
	movss  xmm5, [rdi + rcx*4 + 20]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [rdi + rcx*4 + 12], xmm3
	movss  [rdi + rcx*4 + 16], xmm4
	movss  [rdi + rcx*4 + 20], xmm5

	;# accumulate force in xmm6/xmm7 for fshift 
	addss xmm7, xmm2
	movlhps xmm0, xmm1
	shufps  xmm0, xmm0, 8 ;# 00001000	
	addps   xmm6, xmm0

	;# accumulate H2i forces in xmm0, xmm1, xmm2 
	movaps xmm0, [rsp + nb302_fixH2]
	movaps xmm1, [rsp + nb302_fiyH2]
	movaps xmm2, [rsp + nb302_fizH2]

	movhlps xmm3, xmm0
	movhlps xmm4, xmm1
	movhlps xmm5, xmm2
	addps  xmm0, xmm3
	addps  xmm1, xmm4
	addps  xmm2, xmm5 ;# sum is in 1/2 in xmm0-xmm2 

	movaps xmm3, xmm0	
	movaps xmm4, xmm1	
	movaps xmm5, xmm2	

	shufps xmm3, xmm3, 1
	shufps xmm4, xmm4, 1
	shufps xmm5, xmm5, 1
	addss  xmm0, xmm3
	addss  xmm1, xmm4
	addss  xmm2, xmm5	;# xmm0-xmm2 has single force in pos0 

	;# increment i force 
	movss  xmm3, [rdi + rcx*4 + 24]
	movss  xmm4, [rdi + rcx*4 + 28]
	movss  xmm5, [rdi + rcx*4 + 32]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [rdi + rcx*4 + 24], xmm3
	movss  [rdi + rcx*4 + 28], xmm4
	movss  [rdi + rcx*4 + 32], xmm5

	;# accumulate force in xmm6/xmm7 for fshift 
	addss xmm7, xmm2
	movlhps xmm0, xmm1
	shufps  xmm0, xmm0, 8 ;# 00001000	
	addps   xmm6, xmm0

	;# increment fshift force  
	movlps  xmm3, [rsi + rdx*4]
	movss  xmm4, [rsi + rdx*4 + 8]
	addps  xmm3, xmm6
	addss  xmm4, xmm7
	movlps  [rsi + rdx*4],    xmm3
	movss  [rsi + rdx*4 + 8], xmm4

	;# get n from stack
	mov esi, [rsp + nb302_n]
        ;# get group index for i particle 
        mov   rdx, [rbp + nb302_gid]      	;# base of gid[]
        mov   edx, [rdx + rsi*4]		;# ggid=gid[n]

	;# accumulate total potential energy and update it 
	movaps xmm7, [rsp + nb302_vctot]
	;# accumulate 
	movhlps xmm6, xmm7
	addps  xmm7, xmm6	;# pos 0-1 in xmm7 have the sum now 
	movaps xmm6, xmm7
	shufps xmm6, xmm6, 1
	addss  xmm7, xmm6		

	;# add earlier value from mem 
	mov   rax, [rbp + nb302_Vc]
	addss xmm7, [rax + rdx*4] 
	;# move back to mem 
	movss [rax + rdx*4], xmm7 
	
        ;# finish if last 
        mov ecx, [rsp + nb302_nn1]
	;# esi already loaded with n
	inc esi
        sub ecx, esi
        jecxz .nb302_outerend

        ;# not last, iterate outer loop once more!  
        mov [rsp + nb302_n], esi
        jmp .nb302_outer
.nb302_outerend:
        ;# check if more outer neighborlists remain
        mov   ecx, [rsp + nb302_nri]
	;# esi already loaded with n above
        sub   ecx, esi
        jecxz .nb302_end
        ;# non-zero, do one more workunit
        jmp   .nb302_threadloop
.nb302_end:

	mov eax, [rsp + nb302_nouter]
	mov ebx, [rsp + nb302_ninner]
	mov rcx, [rbp + nb302_outeriter]
	mov rdx, [rbp + nb302_inneriter]
	mov [rcx], eax
	mov [rdx], ebx

	add rsp, 1528
	femms

	pop rbx
	pop	rbp
	ret



	

	
.globl nb_kernel302nf_x86_64_sse
.globl _nb_kernel302nf_x86_64_sse
nb_kernel302nf_x86_64_sse:	
_nb_kernel302nf_x86_64_sse:	
;#	Room for return address and rbp (16 bytes)
.equiv          nb302nf_fshift,         16
.equiv          nb302nf_gid,            24
.equiv          nb302nf_pos,            32
.equiv          nb302nf_faction,        40
.equiv          nb302nf_charge,         48
.equiv          nb302nf_p_facel,        56
.equiv          nb302nf_argkrf,         64
.equiv          nb302nf_argcrf,         72
.equiv          nb302nf_Vc,             80
.equiv          nb302nf_type,           88
.equiv          nb302nf_p_ntype,        96
.equiv          nb302nf_vdwparam,       104
.equiv          nb302nf_Vvdw,           112
.equiv          nb302nf_p_tabscale,     120
.equiv          nb302nf_VFtab,          128
.equiv          nb302nf_invsqrta,       136
.equiv          nb302nf_dvda,           144
.equiv          nb302nf_p_gbtabscale,   152
.equiv          nb302nf_GBtab,          160
.equiv          nb302nf_p_nthreads,     168
.equiv          nb302nf_count,          176
.equiv          nb302nf_mtx,            184
.equiv          nb302nf_outeriter,      192
.equiv          nb302nf_inneriter,      200
.equiv          nb302nf_work,           208
	;# stack offsets for local variables  
	;# bottom of stack is cache-aligned for sse use 
.equiv          nb302nf_ixO,            0
.equiv          nb302nf_iyO,            16
.equiv          nb302nf_izO,            32
.equiv          nb302nf_ixH1,           48
.equiv          nb302nf_iyH1,           64
.equiv          nb302nf_izH1,           80
.equiv          nb302nf_ixH2,           96
.equiv          nb302nf_iyH2,           112
.equiv          nb302nf_izH2,           128
.equiv          nb302nf_jxO,            144
.equiv          nb302nf_jyO,            160
.equiv          nb302nf_jzO,            176
.equiv          nb302nf_jxH1,           192
.equiv          nb302nf_jyH1,           208
.equiv          nb302nf_jzH1,           224
.equiv          nb302nf_jxH2,           240
.equiv          nb302nf_jyH2,           256
.equiv          nb302nf_jzH2,           272
.equiv          nb302nf_qqOO,           288
.equiv          nb302nf_qqOH,           304
.equiv          nb302nf_qqHH,           320
.equiv          nb302nf_tsc,            336
.equiv          nb302nf_vctot,          352
.equiv          nb302nf_half,           368
.equiv          nb302nf_three,          384
.equiv          nb302nf_rsqOO,          400
.equiv          nb302nf_rsqOH1,         416
.equiv          nb302nf_rsqOH2,         432
.equiv          nb302nf_rsqH1O,         448
.equiv          nb302nf_rsqH1H1,        464
.equiv          nb302nf_rsqH1H2,        480
.equiv          nb302nf_rsqH2O,         496
.equiv          nb302nf_rsqH2H1,        512
.equiv          nb302nf_rsqH2H2,        528
.equiv          nb302nf_rinvOO,         544
.equiv          nb302nf_rinvOH1,        560
.equiv          nb302nf_rinvOH2,        576
.equiv          nb302nf_rinvH1O,        592
.equiv          nb302nf_rinvH1H1,       608
.equiv          nb302nf_rinvH1H2,       624
.equiv          nb302nf_rinvH2O,        640
.equiv          nb302nf_rinvH2H1,       656
.equiv          nb302nf_rinvH2H2,       672
.equiv          nb302nf_is3,            688
.equiv          nb302nf_ii3,            692
.equiv          nb302nf_nri,            696
.equiv          nb302nf_iinr,           704
.equiv          nb302nf_jindex,         712
.equiv          nb302nf_jjnr,           720
.equiv          nb302nf_shift,          728
.equiv          nb302nf_shiftvec,       736
.equiv          nb302nf_facel,          744
.equiv          nb302nf_innerjjnr,      752
.equiv          nb302nf_innerk,         760
.equiv          nb302nf_n,              764
.equiv          nb302nf_nn1,            768
.equiv          nb302nf_nouter,         772
.equiv          nb302nf_ninner,         776
	push rbp
	mov  rbp, rsp
	push rbx

	femms
	sub rsp, 792		;# local variable stack space (n*16+8)

	;# zero 32-bit iteration counters
	mov eax, 0
	mov [rsp + nb302nf_nouter], eax
	mov [rsp + nb302nf_ninner], eax

	mov edi, [rdi]
	mov [rsp + nb302nf_nri], edi
	mov [rsp + nb302nf_iinr], rsi
	mov [rsp + nb302nf_jindex], rdx
	mov [rsp + nb302nf_jjnr], rcx
	mov [rsp + nb302nf_shift], r8
	mov [rsp + nb302nf_shiftvec], r9
	mov rsi, [rbp + nb302nf_p_facel]
	movss xmm0, [rsi]
	movss [rsp + nb302nf_facel], xmm0

	mov rax, [rbp + nb302nf_p_tabscale]
	movss xmm3, [rax]
	shufps xmm3, xmm3, 0
	movaps [rsp + nb302nf_tsc], xmm3


	;# assume we have at least one i particle - start directly 
	mov   rcx, [rsp + nb302nf_iinr]   	;# rcx = pointer into iinr[] 	
	mov   ebx, [rcx]		;# ebx =ii 

	mov   rdx, [rbp + nb302nf_charge]
	movss xmm3, [rdx + rbx*4]	
	movss xmm4, xmm3	
	movss xmm5, [rdx + rbx*4 + 4]	
	mov rsi, [rbp + nb302nf_p_facel]
	movss xmm0, [rsi]
	movss xmm6, [rsp + nb302nf_facel]
	mulss  xmm3, xmm3
	mulss  xmm4, xmm5
	mulss  xmm5, xmm5
	mulss  xmm3, xmm6
	mulss  xmm4, xmm6
	mulss  xmm5, xmm6
	shufps xmm3, xmm3, 0
	shufps xmm4, xmm4, 0
	shufps xmm5, xmm5, 0
	movaps [rsp + nb302nf_qqOO], xmm3
	movaps [rsp + nb302nf_qqOH], xmm4
	movaps [rsp + nb302nf_qqHH], xmm5		

	;# create constant floating-point factors on stack
	mov eax, 0x3f000000     ;# half in IEEE (hex)
	mov [rsp + nb302nf_half], eax
	movss xmm1, [rsp + nb302nf_half]
	shufps xmm1, xmm1, 0    ;# splat to all elements
	movaps xmm2, xmm1       
	addps  xmm2, xmm2	;# one
	movaps xmm3, xmm2
	addps  xmm2, xmm2	;# two
	addps  xmm3, xmm2	;# three
	movaps [rsp + nb302nf_half],  xmm1
	movaps [rsp + nb302nf_three],  xmm3

.nb302nf_threadloop:
        mov   rsi, [rbp + nb302nf_count]          ;# pointer to sync counter
        mov   eax, [rsi]
.nb302nf_spinlock:
        mov   ebx, eax                          ;# ebx=*count=nn0
        add   ebx, 1                           ;# ebx=nn1=nn0+10
        lock cmpxchg [rsi], ebx                 ;# write nn1 to *counter,
                                                ;# if it hasnt changed.
                                                ;# or reread *counter to eax.
        pause                                   ;# -> better p4 performance
        jnz .nb302nf_spinlock

        ;# if(nn1>nri) nn1=nri
        mov ecx, [rsp + nb302nf_nri]
        mov edx, ecx
        sub ecx, ebx
        cmovle ebx, edx                         ;# if(nn1>nri) nn1=nri
        ;# Cleared the spinlock if we got here.
        ;# eax contains nn0, ebx contains nn1.
        mov [rsp + nb302nf_n], eax
        mov [rsp + nb302nf_nn1], ebx
        sub ebx, eax                            ;# calc number of outer lists
	mov esi, eax				;# copy n to esi
        jg  .nb302nf_outerstart
        jmp .nb302nf_end
	
.nb302nf_outerstart:
	;# ebx contains number of outer iterations
	add ebx, [rsp + nb302nf_nouter]
	mov [rsp + nb302nf_nouter], ebx

.nb302nf_outer:
	mov   rax, [rsp + nb302nf_shift]  	;# rax = pointer into shift[] 
	mov   ebx, [rax + rsi*4]		;# rbx=shift[n] 
	
	lea   rbx, [rbx + rbx*2]	;# rbx=3*is 
	mov   [rsp + nb302nf_is3],ebx    	;# store is3 

	mov   rax, [rsp + nb302nf_shiftvec]   ;# rax = base of shiftvec[] 

	movss xmm0, [rax + rbx*4]
	movss xmm1, [rax + rbx*4 + 4]
	movss xmm2, [rax + rbx*4 + 8] 

	mov   rcx, [rsp + nb302nf_iinr]   	;# rcx = pointer into iinr[] 	
	mov   ebx, [rcx + rsi*4]		;# ebx =ii 

	lea   rbx, [rbx + rbx*2]	;# rbx = 3*ii=ii3 
	mov   rax, [rbp + nb302nf_pos]	;# rax = base of pos[]  
	mov   [rsp + nb302nf_ii3], ebx	
	
	movaps xmm3, xmm0
	movaps xmm4, xmm1
	movaps xmm5, xmm2
	addss xmm3, [rax + rbx*4]
	addss xmm4, [rax + rbx*4 + 4]
	addss xmm5, [rax + rbx*4 + 8]		
	shufps xmm3, xmm3, 0
	shufps xmm4, xmm4, 0
	shufps xmm5, xmm5, 0
	movaps [rsp + nb302nf_ixO], xmm3
	movaps [rsp + nb302nf_iyO], xmm4
	movaps [rsp + nb302nf_izO], xmm5

	movss xmm3, xmm0
	movss xmm4, xmm1
	movss xmm5, xmm2
	addss xmm0, [rax + rbx*4 + 12]
	addss xmm1, [rax + rbx*4 + 16]
	addss xmm2, [rax + rbx*4 + 20]		
	addss xmm3, [rax + rbx*4 + 24]
	addss xmm4, [rax + rbx*4 + 28]
	addss xmm5, [rax + rbx*4 + 32]		

	shufps xmm0, xmm0, 0
	shufps xmm1, xmm1, 0
	shufps xmm2, xmm2, 0
	shufps xmm3, xmm3, 0
	shufps xmm4, xmm4, 0
	shufps xmm5, xmm5, 0
	movaps [rsp + nb302nf_ixH1], xmm0
	movaps [rsp + nb302nf_iyH1], xmm1
	movaps [rsp + nb302nf_izH1], xmm2
	movaps [rsp + nb302nf_ixH2], xmm3
	movaps [rsp + nb302nf_iyH2], xmm4
	movaps [rsp + nb302nf_izH2], xmm5

	;# clear vctot and i forces 
	xorps xmm4, xmm4
	movaps [rsp + nb302nf_vctot], xmm4
	
	mov   rax, [rsp + nb302nf_jindex]
	mov   ecx, [rax + rsi*4]	 	;# jindex[n] 
	mov   edx, [rax + rsi*4 + 4]	 	;# jindex[n+1] 
	sub   edx, ecx           	;# number of innerloop atoms 

	mov   rsi, [rbp + nb302nf_pos]
	mov   rax, [rsp + nb302nf_jjnr]
	shl   ecx, 2
	add   rax, rcx
	mov   [rsp + nb302nf_innerjjnr], rax 	;# pointer to jjnr[nj0] 
	mov   ecx, edx
	sub   edx,  4
	add   ecx, [rsp + nb302nf_ninner]
	mov   [rsp + nb302nf_ninner], ecx
	add   edx, 0
	mov   [rsp + nb302nf_innerk], edx	;# number of innerloop atoms 
	jge   .nb302nf_unroll_loop
	jmp   .nb302nf_single_check
.nb302nf_unroll_loop:	
	;# quad-unroll innerloop here 
	mov   rdx, [rsp + nb302nf_innerjjnr] 	;# pointer to jjnr[k] 

	mov   eax, [rdx]	
	mov   ebx, [rdx + 4] 
	mov   ecx, [rdx + 8]
	mov   edx, [rdx + 12]     	;# eax-edx=jnr1-4 
	
	add qword ptr [rsp + nb302nf_innerjjnr],  16 ;# advance pointer (unrolled 4) 

	mov rsi, [rbp + nb302nf_pos]   	;# base of pos[] 

	lea   rax, [rax + rax*2] 	;# replace jnr with j3 
	lea   rbx, [rbx + rbx*2]	
	lea   rcx, [rcx + rcx*2] 	;# replace jnr with j3 
	lea   rdx, [rdx + rdx*2]	
	
	;# move j coordinates to local temp variables 
	movlps xmm2, [rsi + rax*4]
	movlps xmm3, [rsi + rax*4 + 12]
	movlps xmm4, [rsi + rax*4 + 24]

	movlps xmm5, [rsi + rbx*4]
	movlps xmm6, [rsi + rbx*4 + 12]
	movlps xmm7, [rsi + rbx*4 + 24]

	movhps xmm2, [rsi + rcx*4]
	movhps xmm3, [rsi + rcx*4 + 12]
	movhps xmm4, [rsi + rcx*4 + 24]

	movhps xmm5, [rsi + rdx*4]
	movhps xmm6, [rsi + rdx*4 + 12]
	movhps xmm7, [rsi + rdx*4 + 24]

	;# current state: 	
	;# xmm2= jxOa  jyOa  jxOc  jyOc 
	;# xmm3= jxH1a jyH1a jxH1c jyH1c 
	;# xmm4= jxH2a jyH2a jxH2c jyH2c 
	;# xmm5= jxOb  jyOb  jxOd  jyOd 
	;# xmm6= jxH1b jyH1b jxH1d jyH1d 
	;# xmm7= jxH2b jyH2b jxH2d jyH2d 
	
	movaps xmm0, xmm2
	movaps xmm1, xmm3
	unpcklps xmm0, xmm5	;# xmm0= jxOa  jxOb  jyOa  jyOb 
	unpcklps xmm1, xmm6	;# xmm1= jxH1a jxH1b jyH1a jyH1b 
	unpckhps xmm2, xmm5	;# xmm2= jxOc  jxOd  jyOc  jyOd 
	unpckhps xmm3, xmm6	;# xmm3= jxH1c jxH1d jyH1c jyH1d 
	movaps xmm5, xmm4
	movaps   xmm6, xmm0
	unpcklps xmm4, xmm7	;# xmm4= jxH2a jxH2b jyH2a jyH2b 		
	unpckhps xmm5, xmm7	;# xmm5= jxH2c jxH2d jyH2c jyH2d 
	movaps   xmm7, xmm1
	movlhps  xmm0, xmm2	;# xmm0= jxOa  jxOb  jxOc  jxOd 
	movaps [rsp + nb302nf_jxO], xmm0
	movhlps  xmm2, xmm6	;# xmm2= jyOa  jyOb  jyOc  jyOd 
	movaps [rsp + nb302nf_jyO], xmm2
	movlhps  xmm1, xmm3
	movaps [rsp + nb302nf_jxH1], xmm1
	movhlps  xmm3, xmm7
	movaps   xmm6, xmm4
	movaps [rsp + nb302nf_jyH1], xmm3
	movlhps  xmm4, xmm5
	movaps [rsp + nb302nf_jxH2], xmm4
	movhlps  xmm5, xmm6
	movaps [rsp + nb302nf_jyH2], xmm5

	movss  xmm0, [rsi + rax*4 + 8]
	movss  xmm1, [rsi + rax*4 + 20]
	movss  xmm2, [rsi + rax*4 + 32]

	movss  xmm3, [rsi + rcx*4 + 8]
	movss  xmm4, [rsi + rcx*4 + 20]
	movss  xmm5, [rsi + rcx*4 + 32]

	movhps xmm0, [rsi + rbx*4 + 4]
	movhps xmm1, [rsi + rbx*4 + 16]
	movhps xmm2, [rsi + rbx*4 + 28]
	
	movhps xmm3, [rsi + rdx*4 + 4]
	movhps xmm4, [rsi + rdx*4 + 16]
	movhps xmm5, [rsi + rdx*4 + 28]
	
	shufps xmm0, xmm3, 204  ;# 11001100
	shufps xmm1, xmm4, 204  ;# 11001100
	shufps xmm2, xmm5, 204  ;# 11001100
	movaps [rsp + nb302nf_jzO],  xmm0
	movaps [rsp + nb302nf_jzH1],  xmm1
	movaps [rsp + nb302nf_jzH2],  xmm2

	movaps xmm0, [rsp + nb302nf_ixO]
	movaps xmm1, [rsp + nb302nf_iyO]
	movaps xmm2, [rsp + nb302nf_izO]
	movaps xmm3, [rsp + nb302nf_ixO]
	movaps xmm4, [rsp + nb302nf_iyO]
	movaps xmm5, [rsp + nb302nf_izO]
	subps  xmm0, [rsp + nb302nf_jxO]
	subps  xmm1, [rsp + nb302nf_jyO]
	subps  xmm2, [rsp + nb302nf_jzO]
	subps  xmm3, [rsp + nb302nf_jxH1]
	subps  xmm4, [rsp + nb302nf_jyH1]
	subps  xmm5, [rsp + nb302nf_jzH1]
	mulps  xmm0, xmm0
	mulps  xmm1, xmm1
	mulps  xmm2, xmm2
	mulps  xmm3, xmm3
	mulps  xmm4, xmm4
	mulps  xmm5, xmm5
	addps  xmm0, xmm1
	addps  xmm0, xmm2
	addps  xmm3, xmm4
	addps  xmm3, xmm5
	movaps [rsp + nb302nf_rsqOO], xmm0
	movaps [rsp + nb302nf_rsqOH1], xmm3

	movaps xmm0, [rsp + nb302nf_ixO]
	movaps xmm1, [rsp + nb302nf_iyO]
	movaps xmm2, [rsp + nb302nf_izO]
	movaps xmm3, [rsp + nb302nf_ixH1]
	movaps xmm4, [rsp + nb302nf_iyH1]
	movaps xmm5, [rsp + nb302nf_izH1]
	subps  xmm0, [rsp + nb302nf_jxH2]
	subps  xmm1, [rsp + nb302nf_jyH2]
	subps  xmm2, [rsp + nb302nf_jzH2]
	subps  xmm3, [rsp + nb302nf_jxO]
	subps  xmm4, [rsp + nb302nf_jyO]
	subps  xmm5, [rsp + nb302nf_jzO]
	mulps  xmm0, xmm0
	mulps  xmm1, xmm1
	mulps  xmm2, xmm2
	mulps  xmm3, xmm3
	mulps  xmm4, xmm4
	mulps  xmm5, xmm5
	addps  xmm0, xmm1
	addps  xmm0, xmm2
	addps  xmm3, xmm4
	addps  xmm3, xmm5
	movaps [rsp + nb302nf_rsqOH2], xmm0
	movaps [rsp + nb302nf_rsqH1O], xmm3

	movaps xmm0, [rsp + nb302nf_ixH1]
	movaps xmm1, [rsp + nb302nf_iyH1]
	movaps xmm2, [rsp + nb302nf_izH1]
	movaps xmm3, [rsp + nb302nf_ixH1]
	movaps xmm4, [rsp + nb302nf_iyH1]
	movaps xmm5, [rsp + nb302nf_izH1]
	subps  xmm0, [rsp + nb302nf_jxH1]
	subps  xmm1, [rsp + nb302nf_jyH1]
	subps  xmm2, [rsp + nb302nf_jzH1]
	subps  xmm3, [rsp + nb302nf_jxH2]
	subps  xmm4, [rsp + nb302nf_jyH2]
	subps  xmm5, [rsp + nb302nf_jzH2]
	mulps  xmm0, xmm0
	mulps  xmm1, xmm1
	mulps  xmm2, xmm2
	mulps  xmm3, xmm3
	mulps  xmm4, xmm4
	mulps  xmm5, xmm5
	addps  xmm0, xmm1
	addps  xmm0, xmm2
	addps  xmm3, xmm4
	addps  xmm3, xmm5
	movaps [rsp + nb302nf_rsqH1H1], xmm0
	movaps [rsp + nb302nf_rsqH1H2], xmm3

	movaps xmm0, [rsp + nb302nf_ixH2]
	movaps xmm1, [rsp + nb302nf_iyH2]
	movaps xmm2, [rsp + nb302nf_izH2]
	movaps xmm3, [rsp + nb302nf_ixH2]
	movaps xmm4, [rsp + nb302nf_iyH2]
	movaps xmm5, [rsp + nb302nf_izH2]
	subps  xmm0, [rsp + nb302nf_jxO]
	subps  xmm1, [rsp + nb302nf_jyO]
	subps  xmm2, [rsp + nb302nf_jzO]
	subps  xmm3, [rsp + nb302nf_jxH1]
	subps  xmm4, [rsp + nb302nf_jyH1]
	subps  xmm5, [rsp + nb302nf_jzH1]
	mulps  xmm0, xmm0
	mulps  xmm1, xmm1
	mulps  xmm2, xmm2
	mulps  xmm3, xmm3
	mulps  xmm4, xmm4
	mulps  xmm5, xmm5
	addps  xmm0, xmm1
	addps  xmm0, xmm2
	addps  xmm4, xmm3
	addps  xmm4, xmm5
	movaps [rsp + nb302nf_rsqH2O], xmm0
	movaps [rsp + nb302nf_rsqH2H1], xmm4

	movaps xmm0, [rsp + nb302nf_ixH2]
	movaps xmm1, [rsp + nb302nf_iyH2]
	movaps xmm2, [rsp + nb302nf_izH2]
	subps  xmm0, [rsp + nb302nf_jxH2]
	subps  xmm1, [rsp + nb302nf_jyH2]
	subps  xmm2, [rsp + nb302nf_jzH2]
	mulps xmm0, xmm0
	mulps xmm1, xmm1
	mulps xmm2, xmm2
	addps xmm0, xmm1
	addps xmm0, xmm2
	movaps [rsp + nb302nf_rsqH2H2], xmm0
	
	;# start doing invsqrt use rsq values in xmm0, xmm4 
	rsqrtps xmm1, xmm0
	rsqrtps xmm5, xmm4
	movaps  xmm2, xmm1
	movaps  xmm6, xmm5
	mulps   xmm1, xmm1
	mulps   xmm5, xmm5
	movaps  xmm3, [rsp + nb302nf_three]
	movaps  xmm7, xmm3
	mulps   xmm1, xmm0
	mulps   xmm5, xmm4
	subps   xmm3, xmm1
	subps   xmm7, xmm5
	mulps   xmm3, xmm2
	mulps   xmm7, xmm6
	mulps   xmm3, [rsp + nb302nf_half] ;# rinvH2H2 
	mulps   xmm7, [rsp + nb302nf_half] ;# rinvH2H1 
	movaps  [rsp + nb302nf_rinvH2H2], xmm3
	movaps  [rsp + nb302nf_rinvH2H1], xmm7
	
	rsqrtps xmm1, [rsp + nb302nf_rsqOO]
	rsqrtps xmm5, [rsp + nb302nf_rsqOH1]
	movaps  xmm2, xmm1
	movaps  xmm6, xmm5
	mulps   xmm1, xmm1
	mulps   xmm5, xmm5
	movaps  xmm3, [rsp + nb302nf_three]
	movaps  xmm7, xmm3
	mulps   xmm1, [rsp + nb302nf_rsqOO]
	mulps   xmm5, [rsp + nb302nf_rsqOH1]
	subps   xmm3, xmm1
	subps   xmm7, xmm5
	mulps   xmm3, xmm2
	mulps   xmm7, xmm6
	mulps   xmm3, [rsp + nb302nf_half] 
	mulps   xmm7, [rsp + nb302nf_half]
	movaps  [rsp + nb302nf_rinvOO], xmm3
	movaps  [rsp + nb302nf_rinvOH1], xmm7
	
	rsqrtps xmm1, [rsp + nb302nf_rsqOH2]
	rsqrtps xmm5, [rsp + nb302nf_rsqH1O]
	movaps  xmm2, xmm1
	movaps  xmm6, xmm5
	mulps   xmm1, xmm1
	mulps   xmm5, xmm5
	movaps  xmm3, [rsp + nb302nf_three]
	movaps  xmm7, xmm3
	mulps   xmm1, [rsp + nb302nf_rsqOH2]
	mulps   xmm5, [rsp + nb302nf_rsqH1O]
	subps   xmm3, xmm1
	subps   xmm7, xmm5
	mulps   xmm3, xmm2
	mulps   xmm7, xmm6
	mulps   xmm3, [rsp + nb302nf_half] 
	mulps   xmm7, [rsp + nb302nf_half]
	movaps  [rsp + nb302nf_rinvOH2], xmm3
	movaps  [rsp + nb302nf_rinvH1O], xmm7
	
	rsqrtps xmm1, [rsp + nb302nf_rsqH1H1]
	rsqrtps xmm5, [rsp + nb302nf_rsqH1H2]
	movaps  xmm2, xmm1
	movaps  xmm6, xmm5
	mulps   xmm1, xmm1
	mulps   xmm5, xmm5
	movaps  xmm3, [rsp + nb302nf_three]
	movaps  xmm7, xmm3
	mulps   xmm1, [rsp + nb302nf_rsqH1H1]
	mulps   xmm5, [rsp + nb302nf_rsqH1H2]
	subps   xmm3, xmm1
	subps   xmm7, xmm5
	mulps   xmm3, xmm2
	mulps   xmm7, xmm6
	mulps   xmm3, [rsp + nb302nf_half] 
	mulps   xmm7, [rsp + nb302nf_half]
	movaps  [rsp + nb302nf_rinvH1H1], xmm3
	movaps  [rsp + nb302nf_rinvH1H2], xmm7
	
	rsqrtps xmm1, [rsp + nb302nf_rsqH2O]
	movaps  xmm2, xmm1
	mulps   xmm1, xmm1
	movaps  xmm3, [rsp + nb302nf_three]
	mulps   xmm1, [rsp + nb302nf_rsqH2O]
	subps   xmm3, xmm1
	mulps   xmm3, xmm2
	mulps   xmm3, [rsp + nb302nf_half] 
	movaps  [rsp + nb302nf_rinvH2O], xmm3

	;# start with OO interaction 
	movaps xmm0, [rsp + nb302nf_rinvOO]
	movaps xmm1, xmm0
	mulps  xmm1, [rsp + nb302nf_rsqOO] ;# xmm1=r 
	mulps  xmm1, [rsp + nb302nf_tsc]
	
	movhlps xmm2, xmm1
	cvttps2pi mm6, xmm1
	cvttps2pi mm7, xmm2 	;# mm6/mm7 contain lu indices 
	cvtpi2ps xmm3, mm6
	cvtpi2ps xmm2, mm7
	movlhps  xmm3, xmm2
	subps    xmm1, xmm3	;# xmm1=eps 
	movaps xmm2, xmm1
	mulps  xmm2, xmm2   	;# xmm2=eps2 
	pslld   mm6, 2
	pslld   mm7, 2
	
	movd mm0, eax
	movd mm1, ebx
	movd mm2, ecx
	movd mm3, edx

	mov  rsi, [rbp + nb302nf_VFtab]
	movd eax, mm6
	psrlq mm6, 32
	movd ecx, mm7
	psrlq mm7, 32
	movd ebx, mm6
	movd edx, mm7

	movlps xmm5, [rsi + rax*4]
	movlps xmm7, [rsi + rcx*4]
	movhps xmm5, [rsi + rbx*4]
	movhps xmm7, [rsi + rdx*4] ;# got half coulomb table 

	movaps xmm4, xmm5
	shufps xmm4, xmm7, 136  ;# 10001000
	shufps xmm5, xmm7, 221  ;# 11011101

	movlps xmm7, [rsi + rax*4 + 8]
	movlps xmm3, [rsi + rcx*4 + 8]
	movhps xmm7, [rsi + rbx*4 + 8]
	movhps xmm3, [rsi + rdx*4 + 8] ;# other half of coulomb table  
	movaps xmm6, xmm7
	shufps xmm6, xmm3, 136  ;# 10001000
	shufps xmm7, xmm3, 221  ;# 11011101
	;# coulomb table ready, in xmm4-xmm7  

	mulps  xmm6, xmm1   	;# xmm6=Geps 
	mulps  xmm7, xmm2   	;# xmm7=Heps2 
	addps  xmm5, xmm6
	addps  xmm5, xmm7   	;# xmm5=Fp 
	movaps xmm3, [rsp + nb302nf_qqOO]
	mulps  xmm5, xmm1 ;# xmm5=eps*Fp 
	addps  xmm5, xmm4 ;# xmm5=VV 
	mulps  xmm5, xmm3 ;# vcoul=qq*VV  
	;# at this point mm5 contains vcoul 
	;# increment vcoul - then we can get rid of mm5 
	;# update vctot 
	addps  xmm5, [rsp + nb302nf_vctot]
	movaps [rsp + nb302nf_vctot], xmm5

	;# O-H1 interaction 
	movaps xmm0, [rsp + nb302nf_rinvOH1]
	movaps xmm1, xmm0
	mulps  xmm1, [rsp + nb302nf_rsqOH1] ;# xmm1=r 
	mulps  xmm1, [rsp + nb302nf_tsc]	
	movhlps xmm2, xmm1
	cvttps2pi mm6, xmm1
	cvttps2pi mm7, xmm2 	;# mm6/mm7 contain lu indices 
	cvtpi2ps xmm3, mm6
	cvtpi2ps xmm2, mm7
	movlhps  xmm3, xmm2
	subps    xmm1, xmm3	;# xmm1=eps 
	movaps xmm2, xmm1
	mulps  xmm2, xmm2   	;# xmm2=eps2 

	pslld   mm6, 2
	pslld   mm7, 2
	
	movd eax, mm6
	psrlq mm6, 32
	movd ecx, mm7
	psrlq mm7, 32
	movd ebx, mm6
	movd edx, mm7

	movlps xmm5, [rsi + rax*4]
	movlps xmm7, [rsi + rcx*4]
	movhps xmm5, [rsi + rbx*4]
	movhps xmm7, [rsi + rdx*4] ;# got half coulomb table 

	movaps xmm4, xmm5
	shufps xmm4, xmm7, 136  ;# 10001000
	shufps xmm5, xmm7, 221  ;# 11011101

	movlps xmm7, [rsi + rax*4 + 8]
	movlps xmm3, [rsi + rcx*4 + 8]
	movhps xmm7, [rsi + rbx*4 + 8]
	movhps xmm3, [rsi + rdx*4 + 8] ;# other half of coulomb table  
	movaps xmm6, xmm7
	shufps xmm6, xmm3, 136  ;# 10001000
	shufps xmm7, xmm3, 221  ;# 11011101
	;# coulomb table ready, in xmm4-xmm7  

	mulps  xmm6, xmm1   	;# xmm6=Geps 
	mulps  xmm7, xmm2   	;# xmm7=Heps2 
	addps  xmm5, xmm6
	addps  xmm5, xmm7   	;# xmm5=Fp 
	movaps xmm3, [rsp + nb302nf_qqOH]
	mulps  xmm5, xmm1 ;# xmm5=eps*Fp 
	addps  xmm5, xmm4 ;# xmm5=VV 
	mulps  xmm5, xmm3 ;# vcoul=qq*VV  
	;# at this point mm5 contains vcoul 

	addps  xmm5, [rsp + nb302nf_vctot]
	movaps [rsp + nb302nf_vctot], xmm5
	
	;# O-H2 interaction  
	movaps xmm0, [rsp + nb302nf_rinvOH2]
	movaps xmm1, xmm0
	mulps  xmm1, [rsp + nb302nf_rsqOH2] ;# xmm1=r 
	mulps  xmm1, [rsp + nb302nf_tsc]	
	movhlps xmm2, xmm1
	cvttps2pi mm6, xmm1
	cvttps2pi mm7, xmm2 	;# mm6/mm7 contain lu indices 
	cvtpi2ps xmm3, mm6
	cvtpi2ps xmm2, mm7
	movlhps  xmm3, xmm2
	subps    xmm1, xmm3	;# xmm1=eps 
	movaps xmm2, xmm1
	mulps  xmm2, xmm2   	;# xmm2=eps2 

	pslld   mm6, 2
	pslld   mm7, 2

	movd eax, mm6
	psrlq mm6, 32
	movd ecx, mm7
	psrlq mm7, 32
	movd ebx, mm6
	movd edx, mm7

	movlps xmm5, [rsi + rax*4]
	movlps xmm7, [rsi + rcx*4]
	movhps xmm5, [rsi + rbx*4]
	movhps xmm7, [rsi + rdx*4] ;# got half coulomb table 

	movaps xmm4, xmm5
	shufps xmm4, xmm7, 136  ;# 10001000
	shufps xmm5, xmm7, 221  ;# 11011101

	movlps xmm7, [rsi + rax*4 + 8]
	movlps xmm3, [rsi + rcx*4 + 8]
	movhps xmm7, [rsi + rbx*4 + 8]
	movhps xmm3, [rsi + rdx*4 + 8] ;# other half of coulomb table  
	movaps xmm6, xmm7
	shufps xmm6, xmm3, 136  ;# 10001000
	shufps xmm7, xmm3, 221  ;# 11011101
	;# coulomb table ready, in xmm4-xmm7  

	mulps  xmm6, xmm1   	;# xmm6=Geps 
	mulps  xmm7, xmm2   	;# xmm7=Heps2 
	addps  xmm5, xmm6
	addps  xmm5, xmm7   	;# xmm5=Fp 
	movaps xmm3, [rsp + nb302nf_qqOH]
	mulps  xmm5, xmm1 ;# xmm5=eps*Fp 
	addps  xmm5, xmm4 ;# xmm5=VV 
	mulps  xmm5, xmm3 ;# vcoul=qq*VV  
	;# at this point mm5 contains vcoul  

	addps  xmm5, [rsp + nb302nf_vctot]
	movaps [rsp + nb302nf_vctot], xmm5

	;# H1-O interaction 
	movaps xmm0, [rsp + nb302nf_rinvH1O]
	movaps xmm1, xmm0
	mulps  xmm1, [rsp + nb302nf_rsqH1O] ;# xmm1=r 
	mulps  xmm1, [rsp + nb302nf_tsc]	
	movhlps xmm2, xmm1
	cvttps2pi mm6, xmm1
	cvttps2pi mm7, xmm2 	;# mm6/mm7 contain lu indices 
	cvtpi2ps xmm3, mm6
	cvtpi2ps xmm2, mm7
	movlhps  xmm3, xmm2
	subps    xmm1, xmm3	;# xmm1=eps 
	movaps xmm2, xmm1
	mulps  xmm2, xmm2   	;# xmm2=eps2 

	pslld   mm6, 2
	pslld   mm7, 2

	movd eax, mm6
	psrlq mm6, 32
	movd ecx, mm7
	psrlq mm7, 32
	movd ebx, mm6
	movd edx, mm7

	movlps xmm5, [rsi + rax*4]
	movlps xmm7, [rsi + rcx*4]
	movhps xmm5, [rsi + rbx*4]
	movhps xmm7, [rsi + rdx*4] ;# got half coulomb table 

	movaps xmm4, xmm5
	shufps xmm4, xmm7, 136  ;# 10001000
	shufps xmm5, xmm7, 221  ;# 11011101

	movlps xmm7, [rsi + rax*4 + 8]
	movlps xmm3, [rsi + rcx*4 + 8]
	movhps xmm7, [rsi + rbx*4 + 8]
	movhps xmm3, [rsi + rdx*4 + 8] ;# other half of coulomb table  
	movaps xmm6, xmm7
	shufps xmm6, xmm3, 136  ;# 10001000
	shufps xmm7, xmm3, 221  ;# 11011101
	;# coulomb table ready, in xmm4-xmm7  

	mulps  xmm6, xmm1   	;# xmm6=Geps 
	mulps  xmm7, xmm2   	;# xmm7=Heps2 
	addps  xmm5, xmm6
	addps  xmm5, xmm7   	;# xmm5=Fp 
	movaps xmm3, [rsp + nb302nf_qqOH]
	mulps  xmm5, xmm1 ;# xmm5=eps*Fp 
	addps  xmm5, xmm4 ;# xmm5=VV 
	mulps  xmm5, xmm3 ;# vcoul=qq*VV  
	;# at this point mm5 contains vcoul  

	addps  xmm5, [rsp + nb302nf_vctot]
	movaps [rsp + nb302nf_vctot], xmm5
	
	;# H1-H1 interaction 
	movaps xmm0, [rsp + nb302nf_rinvH1H1]
	movaps xmm1, xmm0
	mulps  xmm1, [rsp + nb302nf_rsqH1H1] ;# xmm1=r 
	mulps  xmm1, [rsp + nb302nf_tsc]	
	movhlps xmm2, xmm1
	cvttps2pi mm6, xmm1
	cvttps2pi mm7, xmm2 	;# mm6/mm7 contain lu indices 
	cvtpi2ps xmm3, mm6
	cvtpi2ps xmm2, mm7
	movlhps  xmm3, xmm2
	subps    xmm1, xmm3	;# xmm1=eps 
	movaps xmm2, xmm1
	mulps  xmm2, xmm2   	;# xmm2=eps2 

	pslld   mm6, 2
	pslld   mm7, 2

	movd eax, mm6
	psrlq mm6, 32
	movd ecx, mm7
	psrlq mm7, 32
	movd ebx, mm6
	movd edx, mm7

	movlps xmm5, [rsi + rax*4]
	movlps xmm7, [rsi + rcx*4]
	movhps xmm5, [rsi + rbx*4]
	movhps xmm7, [rsi + rdx*4] ;# got half coulomb table 

	movaps xmm4, xmm5
	shufps xmm4, xmm7, 136  ;# 10001000
	shufps xmm5, xmm7, 221  ;# 11011101

	movlps xmm7, [rsi + rax*4 + 8]
	movlps xmm3, [rsi + rcx*4 + 8]
	movhps xmm7, [rsi + rbx*4 + 8]
	movhps xmm3, [rsi + rdx*4 + 8] ;# other half of coulomb table  
	movaps xmm6, xmm7
	shufps xmm6, xmm3, 136  ;# 10001000
	shufps xmm7, xmm3, 221  ;# 11011101
	;# coulomb table ready, in xmm4-xmm7  

	mulps  xmm6, xmm1   	;# xmm6=Geps 
	mulps  xmm7, xmm2   	;# xmm7=Heps2 
	addps  xmm5, xmm6
	addps  xmm5, xmm7   	;# xmm5=Fp 
	movaps xmm3, [rsp + nb302nf_qqHH]
	mulps  xmm5, xmm1 ;# xmm5=eps*Fp 
	addps  xmm5, xmm4 ;# xmm5=VV 
	mulps  xmm5, xmm3 ;# vcoul=qq*VV 
	;# at this point mm5 contains vcoul  

	addps  xmm5, [rsp + nb302nf_vctot]
	movaps [rsp + nb302nf_vctot], xmm5
	;# H1-H2 interaction 
	movaps xmm0, [rsp + nb302nf_rinvH1H2]
	movaps xmm1, xmm0
	mulps  xmm1, [rsp + nb302nf_rsqH1H2] ;# xmm1=r 
	mulps  xmm1, [rsp + nb302nf_tsc]
	movhlps xmm2, xmm1
	cvttps2pi mm6, xmm1
	cvttps2pi mm7, xmm2 	;# mm6/mm7 contain lu indices 
	cvtpi2ps xmm3, mm6
	cvtpi2ps xmm2, mm7
	movlhps  xmm3, xmm2
	subps    xmm1, xmm3	;# xmm1=eps 
	movaps xmm2, xmm1
	mulps  xmm2, xmm2   	;# xmm2=eps2 

	pslld   mm6, 2
	pslld   mm7, 2

	movd eax, mm6
	psrlq mm6, 32
	movd ecx, mm7
	psrlq mm7, 32
	movd ebx, mm6
	movd edx, mm7

	movlps xmm5, [rsi + rax*4]
	movlps xmm7, [rsi + rcx*4]
	movhps xmm5, [rsi + rbx*4]
	movhps xmm7, [rsi + rdx*4] ;# got half coulomb table 

	movaps xmm4, xmm5
	shufps xmm4, xmm7, 136  ;# 10001000
	shufps xmm5, xmm7, 221  ;# 11011101

	movlps xmm7, [rsi + rax*4 + 8]
	movlps xmm3, [rsi + rcx*4 + 8]
	movhps xmm7, [rsi + rbx*4 + 8]
	movhps xmm3, [rsi + rdx*4 + 8] ;# other half of coulomb table  
	movaps xmm6, xmm7
	shufps xmm6, xmm3, 136  ;# 10001000
	shufps xmm7, xmm3, 221  ;# 11011101
	;# coulomb table ready, in xmm4-xmm7  

	mulps  xmm6, xmm1   	;# xmm6=Geps 
	mulps  xmm7, xmm2   	;# xmm7=Heps2 
	addps  xmm5, xmm6
	addps  xmm5, xmm7   	;# xmm5=Fp 
	movaps xmm3, [rsp + nb302nf_qqHH]
	mulps  xmm5, xmm1 ;# xmm5=eps*Fp 
	addps  xmm5, xmm4 ;# xmm5=VV 
	mulps  xmm5, xmm3 ;# vcoul=qq*VV 
	;# at this point mm5 contains vcoul  

	addps  xmm5, [rsp + nb302nf_vctot]
	movaps [rsp + nb302nf_vctot], xmm5

	;# H2-O interaction 
	movaps xmm0, [rsp + nb302nf_rinvH2O]
	movaps xmm1, xmm0
	mulps  xmm1, [rsp + nb302nf_rsqH2O] ;# xmm1=r 
	mulps  xmm1, [rsp + nb302nf_tsc]	
	movhlps xmm2, xmm1
	cvttps2pi mm6, xmm1
	cvttps2pi mm7, xmm2 	;# mm6/mm7 contain lu indices 
	cvtpi2ps xmm3, mm6
	cvtpi2ps xmm2, mm7
	movlhps  xmm3, xmm2
	subps    xmm1, xmm3	;# xmm1=eps 
	movaps xmm2, xmm1
	mulps  xmm2, xmm2   	;# xmm2=eps2 

	pslld   mm6, 2
	pslld   mm7, 2

	movd eax, mm6
	psrlq mm6, 32
	movd ecx, mm7
	psrlq mm7, 32
	movd ebx, mm6
	movd edx, mm7

	movlps xmm5, [rsi + rax*4]
	movlps xmm7, [rsi + rcx*4]
	movhps xmm5, [rsi + rbx*4]
	movhps xmm7, [rsi + rdx*4] ;# got half coulomb table 

	movaps xmm4, xmm5
	shufps xmm4, xmm7, 136  ;# 10001000
	shufps xmm5, xmm7, 221  ;# 11011101

	movlps xmm7, [rsi + rax*4 + 8]
	movlps xmm3, [rsi + rcx*4 + 8]
	movhps xmm7, [rsi + rbx*4 + 8]
	movhps xmm3, [rsi + rdx*4 + 8] ;# other half of coulomb table  
	movaps xmm6, xmm7
	shufps xmm6, xmm3, 136  ;# 10001000
	shufps xmm7, xmm3, 221  ;# 11011101
	;# coulomb table ready, in xmm4-xmm7  

	mulps  xmm6, xmm1   	;# xmm6=Geps 
	mulps  xmm7, xmm2   	;# xmm7=Heps2 
	addps  xmm5, xmm6
	addps  xmm5, xmm7   	;# xmm5=Fp 
	movaps xmm3, [rsp + nb302nf_qqOH]
	mulps  xmm5, xmm1 ;# xmm5=eps*Fp 
	addps  xmm5, xmm4 ;# xmm5=VV 
	mulps  xmm5, xmm3 ;# vcoul=qq*VV  
	;# at this point mm5 contains vcoul  

	addps  xmm5, [rsp + nb302nf_vctot]
	movaps [rsp + nb302nf_vctot], xmm5
	
	;# H2-H1 interaction 
	movaps xmm0, [rsp + nb302nf_rinvH2H1]
	movaps xmm1, xmm0
	mulps  xmm1, [rsp + nb302nf_rsqH2H1] ;# xmm1=r 
	mulps  xmm1, [rsp + nb302nf_tsc]
	movhlps xmm2, xmm1
	cvttps2pi mm6, xmm1
	cvttps2pi mm7, xmm2 	;# mm6/mm7 contain lu indices 
	cvtpi2ps xmm3, mm6
	cvtpi2ps xmm2, mm7
	movlhps  xmm3, xmm2
	subps    xmm1, xmm3	;# xmm1=eps 
	movaps xmm2, xmm1
	mulps  xmm2, xmm2   	;# xmm2=eps2 

	pslld   mm6, 2
	pslld   mm7, 2

	movd eax, mm6
	psrlq mm6, 32
	movd ecx, mm7
	psrlq mm7, 32
	movd ebx, mm6
	movd edx, mm7

	movlps xmm5, [rsi + rax*4]
	movlps xmm7, [rsi + rcx*4]
	movhps xmm5, [rsi + rbx*4]
	movhps xmm7, [rsi + rdx*4] ;# got half coulomb table 

	movaps xmm4, xmm5
	shufps xmm4, xmm7, 136  ;# 10001000
	shufps xmm5, xmm7, 221  ;# 11011101

	movlps xmm7, [rsi + rax*4 + 8]
	movlps xmm3, [rsi + rcx*4 + 8]
	movhps xmm7, [rsi + rbx*4 + 8]
	movhps xmm3, [rsi + rdx*4 + 8] ;# other half of coulomb table  
	movaps xmm6, xmm7
	shufps xmm6, xmm3, 136  ;# 10001000
	shufps xmm7, xmm3, 221  ;# 11011101
	;# coulomb table ready, in xmm4-xmm7  

	mulps  xmm6, xmm1   	;# xmm6=Geps 
	mulps  xmm7, xmm2   	;# xmm7=Heps2 
	addps  xmm5, xmm6
	addps  xmm5, xmm7   	;# xmm5=Fp 
	movaps xmm3, [rsp + nb302nf_qqHH]
	mulps  xmm5, xmm1 ;# xmm5=eps*Fp 
	addps  xmm5, xmm4 ;# xmm5=VV 
	mulps  xmm5, xmm3 ;# vcoul=qq*VV  
	;# at this point mm5 contains vcoul  

	addps  xmm5, [rsp + nb302nf_vctot]
	movaps [rsp + nb302nf_vctot], xmm5
	
	;# H2-H2 interaction 
	movaps xmm0, [rsp + nb302nf_rinvH2H2]
	movaps xmm1, xmm0
	mulps  xmm1, [rsp + nb302nf_rsqH2H2] ;# xmm1=r 
	mulps  xmm1, [rsp + nb302nf_tsc]	
	movhlps xmm2, xmm1
	cvttps2pi mm6, xmm1
	cvttps2pi mm7, xmm2 	;# mm6/mm7 contain lu indices 
	cvtpi2ps xmm3, mm6
	cvtpi2ps xmm2, mm7
	movlhps  xmm3, xmm2
	subps    xmm1, xmm3	;# xmm1=eps 
	movaps xmm2, xmm1
	mulps  xmm2, xmm2   	;# xmm2=eps2 

	pslld   mm6, 2
	pslld   mm7, 2

	movd eax, mm6
	psrlq mm6, 32
	movd ecx, mm7
	psrlq mm7, 32
	movd ebx, mm6
	movd edx, mm7

	movlps xmm5, [rsi + rax*4]
	movlps xmm7, [rsi + rcx*4]
	movhps xmm5, [rsi + rbx*4]
	movhps xmm7, [rsi + rdx*4] ;# got half coulomb table 

	movaps xmm4, xmm5
	shufps xmm4, xmm7, 136  ;# 10001000
	shufps xmm5, xmm7, 221  ;# 11011101

	movlps xmm7, [rsi + rax*4 + 8]
	movlps xmm3, [rsi + rcx*4 + 8]
	movhps xmm7, [rsi + rbx*4 + 8]
	movhps xmm3, [rsi + rdx*4 + 8] ;# other half of coulomb table  
	movaps xmm6, xmm7
	shufps xmm6, xmm3, 136  ;# 10001000
	shufps xmm7, xmm3, 221  ;# 11011101
    	;# coulomb table ready, in xmm4-xmm7  

	mulps  xmm6, xmm1   	;# xmm6=Geps 
	mulps  xmm7, xmm2   	;# xmm7=Heps2 
	addps  xmm5, xmm6
	addps  xmm5, xmm7   	;# xmm5=Fp 
	movaps xmm3, [rsp + nb302nf_qqHH]
	mulps  xmm5, xmm1 ;# xmm5=eps*Fp 
	addps  xmm5, xmm4 ;# xmm5=VV 
	mulps  xmm5, xmm3 ;# vcoul=qq*VV  
    	;# at this point mm5 contains vcoul  

	addps  xmm5, [rsp + nb302nf_vctot]
	movaps [rsp + nb302nf_vctot], xmm5
	
	;# should we do one more iteration? 
	sub dword ptr [rsp + nb302nf_innerk],  4
	jl    .nb302nf_single_check
	jmp   .nb302nf_unroll_loop
.nb302nf_single_check:
	add dword ptr [rsp + nb302nf_innerk],  4
	jnz   .nb302nf_single_loop
	jmp   .nb302nf_updateouterdata
.nb302nf_single_loop:
	mov   rdx, [rsp + nb302nf_innerjjnr] 	;# pointer to jjnr[k] 
	mov   eax, [rdx]	
	add qword ptr [rsp + nb302nf_innerjjnr],  4	

	mov rsi, [rbp + nb302nf_pos]
	lea   rax, [rax + rax*2]  

	;# fetch j coordinates 
	xorps xmm3, xmm3
	xorps xmm4, xmm4
	xorps xmm5, xmm5
	
	movss xmm3, [rsi + rax*4]		;# jxO  -  -  -
	movss xmm4, [rsi + rax*4 + 4]		;# jyO  -  -  -
	movss xmm5, [rsi + rax*4 + 8]		;# jzO  -  -  -  

	movlps xmm6, [rsi + rax*4 + 12]		;# xmm6 = jxH1 jyH1   -    -
	movss  xmm7, [rsi + rax*4 + 20]		;# xmm7 = jzH1   -    -    - 
	movhps xmm6, [rsi + rax*4 + 24]		;# xmm6 = jxH1 jyH1 jxH2 jyH2
	movss  xmm2, [rsi + rax*4 + 32]		;# xmm2 = jzH2   -    -    -
	
	;# have all coords, time for some shuffling.

	shufps xmm6, xmm6, 216 ;# 11011000	;# xmm6 = jxH1 jxH2 jyH1 jyH2 
	unpcklps xmm7, xmm2			;# xmm7 = jzH1 jzH2   -    -
	movaps  xmm0, [rsp + nb302nf_ixO]     
	movaps  xmm1, [rsp + nb302nf_iyO]
	movaps  xmm2, [rsp + nb302nf_izO]	
	movlhps xmm3, xmm6			;# xmm3 = jxO   0   jxH1 jxH2 
	shufps  xmm4, xmm6, 228 ;# 11100100	;# xmm4 = jyO   0   jyH1 jyH2 
	shufps  xmm5, xmm7, 68  ;# 01000100	;# xmm5 = jzO   0   jzH1 jzH2

	;# store all j coordinates in jO  
	movaps [rsp + nb302nf_jxO], xmm3
	movaps [rsp + nb302nf_jyO], xmm4
	movaps [rsp + nb302nf_jzO], xmm5
	subps  xmm0, xmm3
	subps  xmm1, xmm4
	subps  xmm2, xmm5
	mulps xmm0, xmm0
	mulps xmm1, xmm1
	mulps xmm2, xmm2
	addps xmm0, xmm1
	addps xmm0, xmm2	;# have rsq in xmm0 
	
	;# do invsqrt 
	rsqrtps xmm1, xmm0
	movaps  xmm2, xmm1	
	mulps   xmm1, xmm1
	movaps  xmm3, [rsp + nb302nf_three]
	mulps   xmm1, xmm0
	subps   xmm3, xmm1
	mulps   xmm3, xmm2							
	mulps   xmm3, [rsp + nb302nf_half] ;# rinv iO - j water 

	movaps  xmm1, xmm3
	mulps   xmm1, xmm0	;# xmm1=r 
	movaps  xmm0, xmm3	;# xmm0=rinv 
	mulps  xmm1, [rsp + nb302nf_tsc]
	
	movhlps xmm2, xmm1	
	cvttps2pi mm6, xmm1
	cvttps2pi mm7, xmm2 	;# mm6/mm7 contain lu indices 
	cvtpi2ps xmm3, mm6
	cvtpi2ps xmm2, mm7
	movlhps  xmm3, xmm2
	subps    xmm1, xmm3	;# xmm1=eps 
	movaps xmm2, xmm1
	mulps  xmm2, xmm2   	;# xmm2=eps2 
	pslld   mm6, 2
	pslld   mm7, 2
	
	movd ebx, mm6
	movd ecx, mm7
    	psrlq mm7, 32
	movd edx, mm7		;# table indices in ebx,ecx,edx 

	mov rsi, [rbp + nb302nf_VFtab]
	
	movlps xmm5, [rsi + rbx*4]
	movlps xmm7, [rsi + rcx*4]
	movhps xmm7, [rsi + rdx*4] ;# got half coulomb table 
	movaps xmm4, xmm5
	shufps xmm4, xmm7, 136  ;# 10001000
	shufps xmm5, xmm7, 221  ;# 11011101

	movlps xmm7, [rsi + rbx*4 + 8]
	movlps xmm3, [rsi + rcx*4 + 8]
	movhps xmm3, [rsi + rdx*4 + 8] ;# other half of coulomb table  
	movaps xmm6, xmm7
	shufps xmm6, xmm3, 136  ;# 10001000
	shufps xmm7, xmm3, 221  ;# 11011101
    	;# coulomb table ready, in xmm4-xmm7  
	mulps  xmm6, xmm1   	;# xmm6=Geps 
	mulps  xmm7, xmm2   	;# xmm7=Heps2 
	addps  xmm5, xmm6
	addps  xmm5, xmm7   	;# xmm5=Fp 

	xorps  xmm3, xmm3
	;# fetch charges to xmm3 (temporary) 
	movss   xmm3, [rsp + nb302nf_qqOO]
	movhps  xmm3, [rsp + nb302nf_qqOH]
	
	mulps  xmm5, xmm1 ;# xmm5=eps*Fp 
	addps  xmm5, xmm4 ;# xmm5=VV 
	mulps  xmm5, xmm3 ;# vcoul=qq*VV  
    	;# at this point xmm5 contains vcoul 
	
	addps  xmm5, [rsp + nb302nf_vctot]
	movaps [rsp + nb302nf_vctot], xmm5
	
	;# done with i O Now do i H1 & H2 simultaneously first get i particle coords: 
	movaps  xmm0, [rsp + nb302nf_ixH1]
	movaps  xmm1, [rsp + nb302nf_iyH1]
	movaps  xmm2, [rsp + nb302nf_izH1]	
	movaps  xmm3, [rsp + nb302nf_ixH2] 
	movaps  xmm4, [rsp + nb302nf_iyH2] 
	movaps  xmm5, [rsp + nb302nf_izH2] 
	subps   xmm0, [rsp + nb302nf_jxO]
	subps   xmm1, [rsp + nb302nf_jyO]
	subps   xmm2, [rsp + nb302nf_jzO]
	subps   xmm3, [rsp + nb302nf_jxO]
	subps   xmm4, [rsp + nb302nf_jyO]
	subps   xmm5, [rsp + nb302nf_jzO]
	mulps xmm0, xmm0
	mulps xmm1, xmm1
	mulps xmm2, xmm2
	mulps xmm3, xmm3
	mulps xmm4, xmm4
	mulps xmm5, xmm5
	addps xmm0, xmm1
	addps xmm4, xmm3
	addps xmm0, xmm2	;# have rsqH1 in xmm0 
	addps xmm4, xmm5	;# have rsqH2 in xmm4 

	;# start with H1, save H2 data 
	movaps [rsp + nb302nf_rsqH2O], xmm4
	
	;# do invsqrt 
	rsqrtps xmm1, xmm0
	rsqrtps xmm5, xmm4
	movaps  xmm2, xmm1
	movaps  xmm6, xmm5
	mulps   xmm1, xmm1
	mulps   xmm5, xmm5
	movaps  xmm3, [rsp + nb302nf_three]
	movaps  xmm7, xmm3
	mulps   xmm1, xmm0
	mulps   xmm5, xmm4
	subps   xmm3, xmm1
	subps   xmm7, xmm5
	mulps   xmm3, xmm2
	mulps   xmm7, xmm6
	mulps   xmm3, [rsp + nb302nf_half] ;# rinv H1 - j water 
	mulps   xmm7, [rsp + nb302nf_half] ;# rinv H2 - j water  

	;# start with H1, save H2 data 
	movaps [rsp + nb302nf_rinvH2O], xmm7

	movaps xmm1, xmm3
	mulps  xmm1, xmm0	;# xmm1=r 
	movaps xmm0, xmm3	;# xmm0=rinv 
	mulps  xmm1, [rsp + nb302nf_tsc]
	
	movhlps xmm2, xmm1	
	cvttps2pi mm6, xmm1
	cvttps2pi mm7, xmm2 	;# mm6/mm7 contain lu indices 
	cvtpi2ps xmm3, mm6
	cvtpi2ps xmm2, mm7
	movlhps  xmm3, xmm2
	subps    xmm1, xmm3	;# xmm1=eps 
	movaps xmm2, xmm1
	mulps  xmm2, xmm2   	;# xmm2=eps2 
	pslld   mm6, 2
	pslld   mm7, 2

	movd ebx, mm6
	movd ecx, mm7
    	psrlq mm7, 32
	movd edx, mm7		;# table indices in ebx,ecx,edx 

	movlps xmm5, [rsi + rbx*4]
	movlps xmm7, [rsi + rcx*4]
	movhps xmm7, [rsi + rdx*4] ;# got half coulomb table 
	movaps xmm4, xmm5
	shufps xmm4, xmm7, 136  ;# 10001000
	shufps xmm5, xmm7, 221  ;# 11011101

	movlps xmm7, [rsi + rbx*4 + 8]
	movlps xmm3, [rsi + rcx*4 + 8]
	movhps xmm3, [rsi + rdx*4 + 8] ;# other half of coulomb table  
	movaps xmm6, xmm7
	shufps xmm6, xmm3, 136  ;# 10001000
	shufps xmm7, xmm3, 221  ;# 11011101
    	;# coulomb table ready, in xmm4-xmm7  
	mulps  xmm6, xmm1   	;# xmm6=Geps 
	mulps  xmm7, xmm2   	;# xmm7=Heps2 
	addps  xmm5, xmm6
	addps  xmm5, xmm7   	;# xmm5=Fp 
	
	xorps  xmm3, xmm3
	;# fetch charges to xmm3 (temporary) 
	movss   xmm3, [rsp + nb302nf_qqOH]
	movhps  xmm3, [rsp + nb302nf_qqHH]
	
	mulps  xmm5, xmm1 ;# xmm5=eps*Fp 
	addps  xmm5, xmm4 ;# xmm5=VV 
	mulps  xmm5, xmm3 ;# vcoul=qq*VV  
    	;# at this point xmm5 contains vcoul 
	addps  xmm5, [rsp + nb302nf_vctot]
	movaps [rsp + nb302nf_vctot], xmm5	

	;# do table for H2 - j water interaction 
	movaps xmm0, [rsp + nb302nf_rinvH2O]
	movaps xmm1, [rsp + nb302nf_rsqH2O]
	mulps  xmm1, xmm0	;# xmm0=rinv, xmm1=r 
	mulps  xmm1, [rsp + nb302nf_tsc]
	
	movhlps xmm2, xmm1	
	cvttps2pi mm6, xmm1
	cvttps2pi mm7, xmm2 	;# mm6/mm7 contain lu indices 
	cvtpi2ps xmm3, mm6
	cvtpi2ps xmm2, mm7
	movlhps  xmm3, xmm2
	subps    xmm1, xmm3	;# xmm1=eps 
	movaps xmm2, xmm1
	mulps  xmm2, xmm2   	;# xmm2=eps2 
	pslld   mm6, 2
	pslld   mm7, 2

	movd ebx, mm6
	movd ecx, mm7
    	psrlq mm7, 32
	movd edx, mm7		;# table indices in ebx,ecx,edx 

	movlps xmm5, [rsi + rbx*4]
	movlps xmm7, [rsi + rcx*4]
	movhps xmm7, [rsi + rdx*4] ;# got half coulomb table 
	movaps xmm4, xmm5
	shufps xmm4, xmm7, 136  ;# 10001000
	shufps xmm5, xmm7, 221  ;# 11011101

	movlps xmm7, [rsi + rbx*4 + 8]
	movlps xmm3, [rsi + rcx*4 + 8]
	movhps xmm3, [rsi + rdx*4 + 8] ;# other half of coulomb table  
	movaps xmm6, xmm7
	shufps xmm6, xmm3, 136  ;# 10001000
	shufps xmm7, xmm3, 221  ;# 11011101
	;# coulomb table ready, in xmm4-xmm7  
	mulps  xmm6, xmm1   	;# xmm6=Geps 
	mulps  xmm7, xmm2   	;# xmm7=Heps2 
	addps  xmm5, xmm6
	addps  xmm5, xmm7   	;# xmm5=Fp 

	xorps  xmm3, xmm3
	;# fetch charges to xmm3 (temporary) 
	movss   xmm3, [rsp + nb302nf_qqOH]
	movhps  xmm3, [rsp + nb302nf_qqHH]
	
    	mulps  xmm5, xmm1 ;# xmm5=eps*Fp 
    	addps  xmm5, xmm4 ;# xmm5=VV 
    	mulps  xmm5, xmm3 ;# vcoul=qq*VV  
    	;# at this point xmm5 contains vcoul 
    	addps  xmm5, [rsp + nb302nf_vctot]
    	movaps [rsp + nb302nf_vctot], xmm5	

	dec dword ptr [rsp + nb302nf_innerk]
	jz    .nb302nf_updateouterdata
	jmp   .nb302nf_single_loop
.nb302nf_updateouterdata:
	;# get n from stack
	mov esi, [rsp + nb302nf_n]
    	;# get group index for i particle 
    	mov   rdx, [rbp + nb302nf_gid]      	;# base of gid[]
    	mov   edx, [rdx + rsi*4]		;# ggid=gid[n]

	;# accumulate total potential energy and update it 
	movaps xmm7, [rsp + nb302nf_vctot]
	;# accumulate 
	movhlps xmm6, xmm7
	addps  xmm7, xmm6	;# pos 0-1 in xmm7 have the sum now 
	movaps xmm6, xmm7
	shufps xmm6, xmm6, 1
	addss  xmm7, xmm6		

	;# add earlier value from mem 
	mov   rax, [rbp + nb302nf_Vc]
	addss xmm7, [rax + rdx*4] 
	;# move back to mem 
	movss [rax + rdx*4], xmm7 
	
    	;# finish if last 
    	mov ecx, [rsp + nb302nf_nn1]
	;# esi already loaded with n
	inc esi
    	sub ecx, esi
        jecxz .nb302nf_outerend

    	;# not last, iterate outer loop once more!  
    	mov [rsp + nb302nf_n], esi
        jmp .nb302nf_outer
.nb302nf_outerend:
    	;# check if more outer neighborlists remain
    	mov   ecx, [rsp + nb302nf_nri]
	;# esi already loaded with n above
    	sub   ecx, esi
        jecxz .nb302nf_end
    	;# non-zero, do one more workunit
        jmp   .nb302nf_threadloop
.nb302nf_end:

	mov eax, [rsp + nb302nf_nouter]
	mov ebx, [rsp + nb302nf_ninner]
	mov rcx, [rbp + nb302nf_outeriter]
	mov rdx, [rbp + nb302nf_inneriter]
	mov [rcx], eax
	mov [rdx], ebx

	add rsp, 792
	femms

	pop rbx
	pop	rbp
	ret

