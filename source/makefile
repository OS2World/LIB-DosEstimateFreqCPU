# makefile - DosEstimateFreqCPU() dynalink library, public release 1.1.1 (build 4)
#   Copyright (c) 2001 Takayuki 'January June' Suwa
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Library General Public
# License as published by the Free Software Foundation; either
# version 2 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Library General Public License for more details.
#
# You should have received a copy of the GNU Library General Public
# License along with this library; if not, write to the
# Free Software Foundation, Inc., 59 Temple Place - Suite 330,
# Boston, MA 02111-1307, USA.

..\FREQCPU.lib : ..\FREQCPU.dll
    implib ..\FREQCPU.lib ..\FREQCPU.dll

..\FREQCPU.dll : _FREQCPU.obj FREQCPU.obj FREQCPU.def
    ilink /nofree /optfunc /packcode /packdata /nologo _FREQCPU.obj+FREQCPU.obj, ..\FREQCPU.dll, , , FREQCPU.def;
    eautil ..\FREQCPU.dll nul /s
    lxlite ..\FREQCPU.dll /b- /c+ /i- /l- /mr3 /ml1 /mf1 /s+ /t: /v- /yur /ydd /yxs /ynl /zs:1024

_FREQCPU.obj : _FREQCPU.asm
    alp _FREQCPU.asm

FREQCPU.obj : FREQCPU.c ..\FREQCPU.h
    icc /I.. /G5 /Gs+ /Gi+ /Gf+ /Gu- /O+ /Oc+ /Oi- /Ol+ /Rn /Q+ /C+ FREQCPU.c

