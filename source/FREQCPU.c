/* FREQCPU.c - DosEstimateFreqCPU() dynalink library, public release 1.1.1 (build 4)
     Copyright (c) 2001 Takayuki 'January June' Suwa

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Library General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.

   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU Library General Public
   License along with this library; if not, write to the
   Free Software Foundation, Inc., 59 Temple Place - Suite 330,
   Boston, MA 02111-1307, USA. */

#pragma strings(readonly)
#define INCL_BASE
#define INCL_ERRORS
#include <os2.h>
#include "FREQCPU.h"

#if !defined(CMD_KI_RDCNT)

/* constants for DosPerfSysCall() */
#define ORD_DOS32PERFSYSCALL 976
#define CMD_KI_RDCNT 0x63

/* structures for DosPerfSysCall() */
typedef struct _CPUUTIL
{
    QWORD qwTime;  /* time stamp     */
    QWORD qwIdle;  /* idle time      */
    QWORD qwBusy;  /* busy time      */
    QWORD qwIntr;  /* interrupt time */
} CPUUTIL, * PCPUUTIL;

#endif

/* constants for DosTmrQuery*() */
#if !defined(ORD_DOS32TMRQUERYFREQ)
#define ORD_DOS32TMRQUERYFREQ 362
#endif
#if !defined(ORD_DOS32TMRQUERYTIME)
#define ORD_DOS32TMRQUERYTIME 363
#endif

/* constants for DosQuerySysInfo() */
#if !defined(QSV_NUMPROCESSORS)
#define QSV_NUMPROCESSORS 26
#endif

/* internal per-process variables */
APIRET (* APIENTRY G_pfDosPerfSysCall)(ULONG, ULONG, ULONG, ULONG);  /* pointer to DosPerfSysCall() if exists */
APIRET (* APIENTRY G_pfDosTmrQueryTime)(PQWORD);                     /* pointer to DosTmrQueryTime() if exists */
ULONG G_ulFrequency8254;                                             /* i8254 timer frequency */
ULONG G_ulNumCPUs;                                                   /* # of available CPUs */

/* DLL entrypoint for initialization/termination */
ULONG APIENTRY os2entry(HMODULE hmodLibrary,
                        BOOL bTerminate)
{
    HMODULE hmodDOSCALLS;
    APIRET (* APIENTRY pfDosTmrQueryFreq)(PULONG);
    if(bTerminate == (BOOL)FALSE)
    {
        if(DosQueryModuleHandle((PSZ)"DOSCALLS",
                                &hmodDOSCALLS) == NO_ERROR &&
           DosQueryProcAddr(hmodDOSCALLS,
                            ORD_DOS32TMRQUERYFREQ,
                            (PSZ)NULL,
                            (PFN*)&pfDosTmrQueryFreq) == NO_ERROR &&
           DosQueryProcAddr(hmodDOSCALLS,
                            ORD_DOS32PERFSYSCALL,
                            (PSZ)NULL,
                            (PFN*)&G_pfDosPerfSysCall) == NO_ERROR &&
           DosQueryProcAddr(hmodDOSCALLS,
                            ORD_DOS32TMRQUERYTIME,
                            (PSZ)NULL,
                            (PFN*)&G_pfDosTmrQueryTime) == NO_ERROR &&
           pfDosTmrQueryFreq(&G_ulFrequency8254) == NO_ERROR)
        {
            G_ulNumCPUs = (ULONG)1;
            (VOID)DosQuerySysInfo(QSV_NUMPROCESSORS,
                                  QSV_NUMPROCESSORS,
                                  (PVOID)&G_ulNumCPUs,
                                  (ULONG)sizeof(G_ulNumCPUs));
        }
    }
    else
    {
    }
    return (ULONG)-1;
}

