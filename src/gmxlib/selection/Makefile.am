# Convenience library for selection routines - not installed

AM_YFLAGS=-d
AM_CPPFLAGS= -I$(top_srcdir)/include 

noinst_LTLIBRARIES = libselection.la

libselection_la_SOURCES =	\
	compiler.c	evaluate.c	evaluate.h	keywords.h	\
	params.c 	parser.c	parser.h	parsetree.c	\
	parsetree.h	\
	scanner.c	scanner.h	selcollection.h	selection.c	\
	selelem.c 	selelem.h 	selmethod.c	selvalue.c	\
	sm_compare.c	sm_distance.c 	sm_insolidangle.c	\
	sm_keywords.c	sm_permute.c	sm_position.c	sm_simple.c	\
	symrec.c	symrec.h

LDADD = ../libgmx@LIBSUFFIX@.la ../../mdlib/libmd@LIBSUFFIX@.la

EXTRA_PROGRAMS = test_selection

CLEANFILES     = *.la *~ \\\#* 
