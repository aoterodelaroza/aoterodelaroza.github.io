---
layout: single
title: "Basic Keywords"
permalink: /gibbs2/manual/basickeywords/
excerpt: "Basic keywords for gibbs2."
sidebar:
  - repo: "gibbs2"
    nav: "gibbs2_manual"
toc: true
toc_label: "Basic Keywords"
toc_sticky: true
---

## Overview {#g2-overview}

The input syntax for gibbs2 is free-format and
keyword-driven. Comments are preceded by the `#` symbol, and they can
be used at any point in the input file. Lines are continued using the
`\` symbol:
~~~
# this is a comment
this is \
  a long \
  long \
  line
~~~
Each command starts with a unique keyword that modifies the behavior
of gibbs2. The most important keyword is PHASE, which specifies a new
system for the calculation of thermodynamic properties (see
[here](/gibbs2/manual/inputoutput/#g2-inputdesc) for a complete but
simple example).

The rest of the manual describes the gibbs2 keywords. In the syntax
specification, integer, real and string values are denoted by i, r
and s suffixes, respectively. Optional arguments are enclosed in
brackets ([]). Alternative keywords are grouped by curly braces and
separated using a bar (|).

## Mandatory keywords {#g2-mandatory}

Every gibbs2 input must contain at least three keywords: NAT (or
VFREE, they are the same), MM, and PHASE. 
~~~
NAT nat.i
VFREE nat.i
~~~
The NAT and VFREE keywords give the number of atoms in the system (NAT
and VFREE are equivalent). Typically, the easiest choice is to set NAT
to be the same as the number of atoms in the unit cell but another
common choice is to use the number of atoms per formula unit. See
[below](#g2-vfreehow) for an explanation of how to pick NAT for your
system.

The MM keyword is also mandatory:
~~~
MM mm.r
~~~
This keyword gives the mass per NAT atoms, in atomic mass units (amu).

The third mandatory keyword is PHASE. PHASE defines a new phase for
which thermodynamic properties will be calculated. In most cases,
PHASE corresponds to an actual phase of a solid (e.g. the B2 phase of
NaCl). However, PHASE is more general. For instance, two different
phases can be defined using the same data but different temperature
models to incorporate vibrational effects. 

The full syntax of PHASE is:
~~~
PHASE name.s [FILE file.s [U|USING a:b[:c]]] [Z z.r] ...
  # comment
  v1.r e1.r [td1.r nef1.r f1.r f2.r f3.r f4.r ts1.r ts2.r ts3.r ts4.r phdos1.s
             int1.r int2.r ...]
  ...
ENDPHASE
PHASE ... [FIT {POLYGIBBS|BM2|BM3|BM4|PT2|PT3|PT4|PT5|MURN|ANTONS|VINET|AP2|
                STRAIN {EULERIAN|BM|NATURAL|PT|LAGRANGIAN|LAGR|INFINITESIMAL|
                        INF|QUOTIENT|X1|X3|XINV3|X3INV|V} [order.i|0]}]
          [REG {LAD|LSQ}] [FIX i1.i v1.r i2.i v2.r ...]
PHASE ... [TMODEL {STATIC|DEBYE_INPUT|DEBYE_POISSON_INPUT|DEBYE|
                   DEBYE_EINSTEIN [FREQG0 file.s]|
                   DEBYE_GRUNEISEN {SLATER|DM|VZ|MFV|a.r b.r}|
                   {QHAFULL|QHA}}]
          [PHFIELD ifield.i] [DOSFIELD i1.i i2.i]|}] [PREFIX prefix.s]
          [POISSON sigma.r] [FSTEP step.r]
PHASE ... [EEC NOSCAL|PSHIFT vexp.r|BPSCAL vexp.r bexp.r|APBAF vexp.r|USE phase.i]
          [EEC_P pext.r] [EEC_T text.r] 
PHASE ... [ELEC SOMMERFELD FREE SOMMERFELD [icol.i] POL4 [icol1.i]] [NELEC nelec.i]
PHASE ... [INTERPOLATE f1.i [f2.i ...]] [EXTEND]
PHASE ... [ESHIFT eshift.r] [PVDATA] [UNITS {VOLUME {BOHR|BOHR3|BOHR^3|ANG|ANG3|ANG^3}}
          {ENERGY {HY|HARTREE|HA|EV|EVOLT|ELECTRONVOLT|RY|RYDBERG}}
          {PRESSURE {AU|A.U.|GPA}} { {FREQ|FREQUENCY} {HARTREE|HY|HA|CM-1|CM^-1|CM_1|THZ}}
          {EDOS {HY|HARTREE|HA|EV|EVOLT|ELECTRONVOLT|RY|RYDBERG}}]
~~~
However intimidating, most of these keywords are optional and not used
very often. They are described in detail in the rest of the
manual. For now, we focus on the basic options to PHASE, which are:
~~~
PHASE name.s [FILE file.s [U|USING a:b[:c]]] [Z z.r] ...
  # comment
  v1.r e1.r [td1.r nef1.r f1.r f2.r f3.r f4.r ts1.r ts2.r ts3.r ts4.r phdos1.s
             int1.r int2.r ...]
  ...
ENDPHASE
~~~
The PHASE keyword must be followed by the name of the phase
(`name.s`), which can be any arbitrary name of your choice. This name
will be used in the output and in the plots to identify the
phase. 

The fundamental data for a given phase is the energy-volume curve. For
each phase, at least a list of volume-energy data pairs must be
provided corresponding to a set of volumes and the corresponding
energies obtained from a constant-volume or constant-pressure geometry
relaxation. In many cases, additional information, such as the Debye
temperatures or the location of the phonon densities of states, must
be provided as well. There are two ways to pass this information to
gibbs2: either inline or using an external file. In the inline method,
you simply list the information after the PHASE keyword, and finish
the input of data with ENDPHASE:
~~~
PHASE mgo
 81.8883583665837   -73.5171659350000
[...]
160.0000000000000   -73.5662512150000
ENDPHASE
~~~
If a external file is used, then the same information is written to a
file (say, `mgo.dat`) and then passed to gibbs2 using the FILE
keyword:
~~~
PHASE FILE mgo.dat USING 2:3
~~~
The USING keyword (equivalently, "U") indicates in which columns of
the data file gibbs2 can find the volume (default: first column) and
the energy (default: second). In the example above, the volume is
found in the second column and the energy in the third column.

The last important optional keyword to PHASE is Z. The volumes and
energies in the input must correspond to a number of atoms equal to Z
times NAT atoms. By default, Z is 1. A simple example illustrating the
use of NAT and Z is given below.

### Additional PHASE options {#g2-additional}

The following is an overview of the other optional keywords to
PHASE. A more lengthy explanation of these keywords can be found in
the corresponding keywords:

* The FIT keyword controls the type of equation of state used to fit
  the static and free energy versus volume data. Additional controls
  for FIT are provided by REG and FIX.

* The TMODEL keyword selects the temperature model, i.e., the way in
  which gibbs2 incorporates the vibrational effects into the
  calculation of the free energy. Additional options for TMODEL are
  provided by the PREFIX, POISSON, LAUE, and FSTEP keywords.

* The ELEC keyword allows incorporating (in a rough way) the
  electronic contribution to the free energy, which is only important
  in metals and at very low temperatures.

* The EEC keyword activates the use of empirical energy
  corrections. These are corrections designed to improve the
  calculation of thermodynamic properties by using experimental data
  to correct the shortcomings of approximate density-functional
  theory.

* It is possible to interpolate satellite data, such as the cell
  parameters or the atomic positions, with the INTERPOLATE keyword.

* Finally, there are a number of optional keywords to change the
  units, interpret pressure-volume data, and other ancillary
  functions.

### How many atoms are there in my system? {#g2-vfreehow}

The use of NAT, MM, Z, and the input volumes and energies is often a
source of confusion. The following rules apply:

* NAT can be chosen as any multiple of the system's formula unit. In
  the output, all extensive thermodynamic properties (energy, free
  energies, entropy,...) are given per NAT atoms.

* MM is the mass of NAT atoms. 

* The volumes and energies for a given phase must correspond to NAT
  times Z atoms, where Z is the value that applies to that phase.

For example, if we are studying the benzene crystal, we could choose
an NAT of 12, corresponding to a benzene molecule (C6H6). The
primitive cell of the benzene crystal structure at ambient conditions
(with space group Pbca) contains 48 atoms. Therefore, NAT could also be
set to 48. Another option is to use the asymmetric unit of the crystal
(with 6 atoms, NAT = 6) or the formula unit (CH, with
NAT=2). Ultimately, any NAT value that is a multiple of the number of
atoms in the formula unit (2) is valid.

Once NAT is set, MM is the mass corresponding to NAT atoms, in amu (or
the molar mass in g/mol). For instance, if we used the formula unit as
reference in the benzene example (CH, NAT = 2), then MM would be 
$$m_C + m_H = 13.01864$$ amu. If, instead, we use a benzene molecule as our
reference, then NAT = 12 (C6H6) and MM = $$6 m_C + 6 m_H = 78.1118$$
amu.

Benzene can crystallize in a number of different (metastable)
polymorphs. The aforementioned Pbca phase has 48 atoms in the unit
cell but the P21/c polymorph has 24 atoms in the primitive cell
only. Whatever the choice of NAT, Z*NAT must be equal to 48 for the
Pbca phase and 24 for the P21/c phase. The following inputs for the
study of the two phases would be valid. Per formula unit (CH)
~~~
NAT 2
MM 13.01864
PHASE Pbca Z 24 FILE Pbca.dat 
PHASE P21c Z 12 FILE P21c.dat 
~~~
Per molecule (C6H6):
~~~
NAT 12
MM 78.1118
PHASE Pbca Z 4 FILE Pbca.dat 
PHASE P21c Z 2 FILE P21c.dat 
~~~
Per two molecules (C24H24):
~~~
NAT 24
MM 78.1118
PHASE Pbca Z 2 FILE Pbca.dat 
PHASE P21c Z 1 FILE P21c.dat 
~~~
In this last case the "Z 1" in the P21c phase can be omitted, since
one is the default value. In the output, extensive properties are
given per formula unit in the first case, per molecule in the second,
and per two molecules in the third cases. In all three cases,
`Pbca.dat` and `P21c.dat` contain the volumes and energies
corresponding to a unit cell (48 atoms in Pbca and 24 atoms in
P21c). This a natural choice, since they can be extracted without
modification from the output of the electronic structure calculation.

## Optional keywords {#g2-optional}

This section lists basic keywords that modify the conditions of the
run but are not required for gibbs2 to operate.
~~~
TITLE title.s
~~~
The TITLE keyword sets the title of the gibbs2 run. This only affects
the output.
~~~
EOUTPUT [vini.r vstep.r vend.r]
~~~
The EOUTPUT keyword prints the static energy of each phase to external
files (with extension `.edat`). Without any options, the volume grid
in input is used. This option can be used to print the corrected
static energies when using empirical energy corrections.

In addition, a new volume grid can be chosen by indicating an initial
(`vini.r`), final (`vend.r`) and volume step (`vstep.r`). This is
useful when extrapolating the input static energy or when generating
more energy-volume points for other purposes. Please note that it is
important to use an EOS with few parameters to extrapolate
(e.g. BM3). The default averages of strain polynomials behave badly on
extrapolation.
~~~
END
~~~
Ends the run. This keyword is not necessary for a correct
termination of gibbs2.

### Choosing the pressure and temperature ranges {#g2-vpt}

Gibbs2 calculates thermodynamic quantities at arbitrary pressure and
temperature. The following keywords control the list of pressure and
temperature points on which these properties are computed.
~~~
PRESSURE pini.r pstep.r pend.r
PRESSURE pstep.r
PRESSURE npres.i
PRESSURE
 p1.r p2.r p3.r ...
 p4.r ...
ENDPRESSURE
PRESSURE 0
~~~
The PRESSURE keyword gives the list of pressures where the
thermodynamic properties are calculated. If three real numbers are
passed (`pini.r`, `pstep.r`, `pend.r`), then they determine the
pressure range: from `pini.r` to `pend.r` with a step of `pstep.r`.
If only a real number is given (`pstep.r`) then the default pressure
range is used: `pini.r` is assumed to be zero and `pend.r` is the
highest pressure calculable from the input data. If a single integer
is passed to PRESSURE (`npres.i`), then use `npres.i` pressure points
in the same default range.

In addition, an explicitly list of pressures can be given in the form
of a PRESSURE/ENDPRESSURE environment. This environment can span any
number of lines with an arbitrary number of fields per line, and
comments are allowed. Finally, a single `0` in the PRESSURE keyword
tells gibbs2 to use only zero pressure.

By default, 100 pressure points are calculate from zero up to the
maximum pressure calculable from the input data or up to 500 GPa,
whichever is lowest.
~~~
VOLUME vini.r vstep.r vend.r
VOLUME vstep.r
VOLUME nvols.i
VOLUME
 v1.r v2.r v3.r ...
 v4.r ...
ENDVOLUME
VOLUME INPUT
~~~
In addition to using a pressure list, properties can be calculated
at points given temperature and volume. The VOLUME keyword
gives the list of volumes where properties are calculated. The
syntax is equivalent to the PRESSURE keyword. Using VOLUME INPUT, the
volumes of the input grid are used.
~~~
TEMPERATURE tini.r tstep.r tend.r
TEMPERATURE tstep.r
TEMPERATURE ntemp.i
TEMPERATURE
 t1.r t2.r t3.r ...
 t4.r ...
ENDTEMPERATURE
TEMPERATURE 0
TEMPERATURE -1
~~~
The TEMPERATURE keyword gives the list of temperatures where the
thermodynamic properties are calculated. If three real numbers are
passed (`tini.r`, `tstep.r`, `tend.r`), then they determine the
temperature range: from `tini.r` to `tend.r` with a step of `tstep.r`.
If only a real number is given (`tstep.r`) then the default
temperature range is used: `tini.r` is assumed to be zero and `tend.r`
is the lowest Debye temperature calculated using Slater's formula
times 1.5. If a single integer is passed to TEMPERATURE (`ntemp.i`),
then use `ntemp.i` temperature points in the same default range.

In addition, an explicity list of temperatures can be given in the form
of a TEMPERATURE/ENDTEMPERATURE environment. This environment can span any
number of lines with an arbitrary number of fields per line, and
comments are allowed. Finally, a single `0` in the TEMPERATURE keyword
tells gibbs2 to use only zero temperature. A single `-1` in the
TEMPERATURE keyword tells gibbs2 to use only room temperature (298.15
K).

By default, if no TEMPERATURE keyword is given, 100 temperature points
are calculated from zero up to a maximum temperature. The maximum
temperature is 1.5 times the minimum Debye temperature, if the thermal
model is based on the Debye model. Otherwise, tha maximum temperature
is room temperature (298.15 K).
