/* FREQCPU.h - DosEstimateFreqCPU() dynalink library, public release 1.1.1 (build 4)
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

#if !defined(__FREQCPU)
#define __FREQCPU

#if defined(__cplusplus)
extern "C" {
#endif

/* CPU frequency information structure */
typedef struct _CPUFREQUENCY
{
    ULONG ulNumCPUs;            /* # of available CPUs */
    FIXED afxFrequencyMHz[64];  /* frequency of each CPUs in FIXED MHz (65536 means 1.0) */
} CPUFREQUENCY, * PCPUFREQUENCY;

/* estimates clock frequency of all CPUs
   return : !NO_ERROR -> error occurred
            NO_ERROR  -> successful completion */
extern APIRET APIENTRY DosEstimateFreqCPU(PCPUFREQUENCY pxCPUFrequency  /* (output) pointer to structure that estimated clock frequencies will be set to */);

#if defined(__cplusplus)
}
#endif

#endif

