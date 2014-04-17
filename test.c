#pragma strings(readonly)
#include <stdio.h>
#define INCL_BASE
#define INCL_ERRORS
#include <os2.h>
#include "FREQCPU.h"

int main(void)
{
    CPUFREQUENCY xFrequency;
    ULONG ulIndex;

    (VOID)DosEstimateFreqCPU(&xFrequency);

    for(ulIndex = (ULONG)0;
        ulIndex < xFrequency.ulNumCPUs;
        ulIndex++)
        (void)printf("CPU %u : %3.3lf MHz\n",
                     (unsigned int)ulIndex,
                     xFrequency.afxFrequencyMHz[ulIndex] / (double)65536);

    return 0;
}

