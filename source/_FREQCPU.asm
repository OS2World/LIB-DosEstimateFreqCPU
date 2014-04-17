; _FREQCPU.asm - DosEstimateFreqCPU() dynalink library, public release 1.1.1 (build 4)
;   Copyright (c) 2001 Takayuki 'January June' Suwa
;
; This library is free software; you can redistribute it and/or
; modify it under the terms of the GNU Library General Public
; License as published by the Free Software Foundation; either
; version 2 of the License, or (at your option) any later version.
;
; This library is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
; Library General Public License for more details.
;
; You should have received a copy of the GNU Library General Public
; License along with this library; if not, write to the
; Free Software Foundation, Inc., 59 Temple Place - Suite 330,
; Boston, MA 02111-1307, USA.

  .386

CODE32  segment  dword use32 public 'CODE'
CODE32  ends
DATA32  segment  dword use32 public 'DATA'
DATA32  ends
CONST32_RO  segment  dword use32 public 'CONST'
CONST32_RO  ends
BSS32  segment  dword use32 public 'BSS'
BSS32  ends
STACK  segment dword use32 stack 'STACK'
STACK  ends
DGROUP  group  BSS32, DATA32

  assume  cs:FLAT, ds:FLAT, ss:FLAT, es:FLAT, fs:nothing, gs:nothing

  extrn  Dos32SetPriority:near
  extrn  Dos32Sleep:near
  extrn  os2entry:near
  extrn  G_pfDosPerfSysCall:dword
  extrn  G_pfDosTmrQueryTime:dword
  extrn  G_ulFrequency8254:dword
  extrn  G_ulNumCPUs:dword

; constants
CONST32_RO  segment

dScaleFactor  dq  6.5536000000000000e-02  ; 65536/1000000

CONST32_RO  ends

; codes
CODE32  segment

TIB2  struc
tib2_ultid         dd  ?
tib2_ulpri         dd  ?
tib2_version       dd  ?
tib2_usMCCount     dw  ?
tib2_fMCForceFlag  dw  ?
TIB2  ends

TIB  struc
tib_pexchain     dd  ?
tib_pstack       dd  ?
tib_pstacklimit  dd  ?
tib_ptib2        dd  ?
tib_version      dd  ?
tib_ordinal      dd  ?
TIB  ends

CPUUTIL  struc
qwTime  dq  ?
qwIdle  dq  ?
qwBusy  dq  ?
qwIntr  dq  ?
CPUUTIL  ends

CPUFREQUENCY  struc
ulNumCPUs        dd  ?
afxFrequencyMHz  dd  64 dup(?)
CPUFREQUENCY  ends

CMD_KI_RDCNT  equ  63h

ERROR_INVALID_FUNCTION  equ  1

; APIRET APIENTRY DosEstimateFreqCPU(PCPUFREQUENCY pxCPUFrequency)
  public  DosEstimateFreqCPU
DosEstimateFreqCPU  proc  near
ARGLIST  struc
pxCPUFrequency  dd  ?  ; (PCPUFREQUENCY)
ARGLIST  ends
VARLIST  struc
axPerformanceAfter   CPUUTIL  64 dup(<>)  ; (CPUUTIL[64])
axPerformanceBefore  CPUUTIL  64 dup(<>)  ; (CPUUTIL[64])
qwTimerCountAfter    dq       ?           ; (QWORD)
qwTimerCountBefore   dq       ?           ; (QWORD)
VARLIST  ends
  enter size VARLIST, 0
ARG  equ  ARGLIST[ebp+8]
VAR  equ  VARLIST[ebp-size VARLIST]
  push  ebx
  push  esi
  push  edi

  mov  ebx, ERROR_INVALID_FUNCTION
  cmp  FLAT:G_ulNumCPUs, 0
  je  near ptr BLBL2

  mov  eax, fs:[offset TIB.tib_ptib2]
  push  0
  push  31
  push  3
  push  2
  mov  esi, TIB2[eax].tib2_ulpri
  call  Dos32SetPriority
;  add  esp, 4*4

  lea  eax, VAR.qwTimerCountBefore
  push  eax
  call  FLAT:G_pfDosTmrQueryTime
;  add  esp, 4*1
  add  esp, 4*5
  test  eax, eax
  xchg  eax, ebx
  jnz  near ptr BLBL1

  push  0
  lea  eax, VAR.axPerformanceBefore
  push  0
  push  eax
  push  CMD_KI_RDCNT
  call  FLAT:G_pfDosPerfSysCall
  add  esp, 4*4
  test  eax, eax
  xchg  eax, ebx
  jnz  near ptr BLBL1

  push  100
  call  Dos32Sleep
;  add  esp, 4*1

  lea  eax, VAR.qwTimerCountAfter
  push  eax
  call  FLAT:G_pfDosTmrQueryTime
;  add  esp, 4*1

  push  0
  lea  eax, VAR.axPerformanceAfter
  push  0
  push  eax
  push  CMD_KI_RDCNT
  call  FLAT:G_pfDosPerfSysCall
;  add  esp, 4*4

  mov  edx, 255
  push  0
  and  edx, esi
  shr  esi, 8
  push  edx
  push  esi
  push  2
  call  Dos32SetPriority
;  add  esp, 4*4
  add  esp, 4*10

  mov  eax, dword ptr VAR.qwTimerCountAfter[0]
  mov  edx, dword ptr VAR.qwTimerCountAfter[4]
  sub  eax, dword ptr VAR.qwTimerCountBefore[0]
  sbb  edx, dword ptr VAR.qwTimerCountBefore[4]
  mov  dword ptr VAR.qwTimerCountAfter[0], eax
  mov  dword ptr VAR.qwTimerCountAfter[4], edx
  fild  FLAT:G_ulFrequency8254
  fild  VAR.qwTimerCountAfter
  fdivp  st(1), st(0)
  mov  ebx, ARG.pxCPUFrequency
  lea  esi, VAR.axPerformanceBefore
  lea  edi, VAR.axPerformanceAfter
  mov  ecx, FLAT:G_ulNumCPUs
  mov  CPUFREQUENCY[ebx].ulNumCPUs, ecx
  lea  ebx, CPUFREQUENCY[ebx].afxFrequencyMHz
  fmul  FLAT:dScaleFactor

BLBL0:
  mov  eax, dword ptr CPUUTIL[edi].qwTime[0]
  mov  edx, dword ptr CPUUTIL[edi].qwTime[4]
  sub  eax, dword ptr CPUUTIL[esi].qwTime[0]
  sbb  edx, dword ptr CPUUTIL[esi].qwTime[4]
  mov  dword ptr CPUUTIL[edi].qwTime[0], eax
  mov  dword ptr CPUUTIL[edi].qwTime[4], edx
  fild  CPUUTIL[edi].qwTime
  fmul  st(0), st(1)
  fistp  dword ptr [ebx]
  add  esi, size CPUUTIL
  add  edi, size CPUUTIL
  add  ebx, size dword
  dec  ecx
  jnz  short BLBL0

  fstp  st(0)
  xor  ebx, ebx
  jmp  short BLBL2

BLBL1:
  mov  edx, 255
  push  0
  and  edx, esi
  shr  esi, 8
  push  edx
  push  esi
  push  2
  call  Dos32SetPriority
  add  esp, 4*4

BLBL2:
  xchg  eax, ebx
  pop  edi
  pop  esi
  pop  ebx
  leave
  ret
DosEstimateFreqCPU  endp

CODE32  ends

  end  os2entry

