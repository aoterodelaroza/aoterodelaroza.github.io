---
layout: single
title: "List of Keywords"
permalink: /gibbs2/syntax/
excerpt: "List of commands used in gibbs2."
sidebar:
  - repo: "gibbs2"
    nav: "gibbs2" 
classes: wide
toc: false
toc_label: "List of keywords"
---

{:center: style="text-align: center"}
**Keywords**
{:center}

| [ACTIVATE](#key-activate)       | [END](#key-end)     | [EOUTPUT](#key-eoutput)   | [INTERPOLATE](#key-interpolate) | [MM](#key-mm)   | [NAT](#key-nat)     |
| [NELECTRONS](#key-nelectrons)   | [PHASE](#key-phase) | [PRESSURE](#key-pressure) | [PRINTFREQ](#key-printfreq)     | [SET](#key-set) | [TITLE](#key-title) |
| [TEMPERATURE](#key-temperature) | [VFREE](#key-vfree) | [VOLUME](#key-volume)     |                                 |                 |                     |

## List of Keywords

<a id="key-activate"></a>
[ACTIVATE](/gibbs2/manual/tmodels/#g2-optionalglobal)
: Activate points with negative frequencies in QHA
~~~
ACTIVATE {ALL|v1.i v2.i v3.i...}
~~~

<a id="key-end"></a>
[END](/gibbs2/manual/basickeywords/#g2-optional)
: Ends the gibbs2 run
~~~
END
~~~

<a id="key-eoutput"></a>
[EOUTPUT](/gibbs2/manual/basickeywords/#g2-optional)
: Write the static energy to a file
~~~
EOUTPUT [vini.r vstep.r vend.r]
~~~

<a id="key-interpolate"></a>
[INTERPOLATE](/gibbs2/manual/interpolation/)
: Interpolate satellite data
~~~
INTERPOLATE
 [P]
 p1.r p2.r ..
 p3.r ..
 V
 v1.r v2.r ..
 PT
 p1.r t1.r p2.r t2.r ...
ENDINTERPOLATE
INTERPOLATE INPUT [STATIC]
~~~

<a id="key-mm"></a>
[MM](/gibbs2/manual/basickeywords/#g2-mandatory)
: Molar mass of the system
~~~
MM mm.r
~~~

<a id="key-nat"></a>
[NAT](/gibbs2/manual/basickeywords/#g2-mandatory)
: Number of atoms in the system (same as VFREE)
~~~
NAT nat.i
~~~

<a id="key-nelectrons"></a>
[NELECTRONS](/gibbs2/manual/eos/#g2-optionalglobal)
: Number of electrons (for the AP2 EOS)
~~~
NELECTRONS nelec.i
~~~

<a id="key-phase"></a>
PHASE
: Define a new phase 
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
Subtopics of PHASE:
* [Introduction to the PHASE keyword](/gibbs2/manual/basickeywords/#g2-mandatory)
* [The FIT option](/gibbs2/manual/eos/#g2-eos); [REG and FIX options to FIT](/gibbs2/manual/eos/#g2-optionalphase)
* [The TMODEL option](/gibbs2/manual/tmodels/#g2-tmodels); 
  [POISSON keyword (Debye)](/gibbs2/manual/tmodels/#g2-debye); 
  [PREFIX, PHFIELD, DOSFIELD, FSTEP keywords (QHA)](/gibbs2/manual/tmodels/#g2-qha)
* [Empirical energy corrections (EEC, EEC_P, EEC_T)](/gibbs2/manual/eec/) 
* [Electronic contributions to the free energy (ELEC, NELEC)](/gibbs2/manual/elec/)
* [Interpolation (INTERPOLATE) and extrapolation (EXTEND)](/gibbs2/manual/interpolation/)
* [Changing default units (UNITS)](/gibbs2/manual/misc/#g2-units)
* [Pressure-volume input data (PVDATA)](/gibbs2/manual/misc/#g2-pvdata)
* [Energy shifts (ESHIFT)](/gibbs2/manual/misc/#g2-eshift)

<a id="key-pressure"></a>
[PRESSURE](/gibbs2/manual/basickeywords/#g2-vpt)
: Define the list of pressures
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

<a id="key-printfreq"></a>
[PRINTFREQ](/gibbs2/manual/tmodels/#g2-debeins)
: Print frequencies at Gamma at all volumes (Debye-Einstein model)
~~~
PRINTFREQ|PRINTFREQS
~~~

<a id="key-set"></a>
SET
: Global behavior control options for gibbs2
~~~
SET ROOT root.s
SET NOEFIT
SET NOPLOTDH
SET NOTRANS
SET ERRORBAR|ERROR_BAR|ERRORBARS|ERROR_BARS
SET WRITELEVEL {0|1|2}
SET MPAR mpar.i
SET MPARMIN mparmin.i
SET NDEL ndel.i
SET PFIT_MODE {GAUSS|SLATEC}
SET PWEIGH_MODE {GIBBS1|GIBBS2|SLATEC}
SET PHONFIT {LINEAR|SPLINE}
SET IGNORE_NEG_CUTOFF inegcut.r
SET NORENORMALIZE
SET NEWPTS newpts.i
SET FACEXPAND fac.r
~~~
Subtopics of SET:
* [Global options (ROOT, NOEFIT, NOPLOTDH, NOTRANS, ERRORBAR, WRITELEVEL)](/gibbs2/manual/inputoutput/#g2-setoptions)
* [EOS options (MPAR, MPARMIN, NDEL, PFIT_MODE, PWEIGH_MODE)](/gibbs2/manual/eos/#g2-optionalglobal)
* [TMODEL QHA options (PHONFIT, IGNORE_NEG_CUTOFF, NORENORMALIZE)](/gibbs2/manual/tmodels/#g2-optionalglobal)
* [Control of pressure-volume input data (NEWPTS, FACEXPAND)](/gibbs2/manual/misc/#g2-pvdata)

<a id="key-title"></a>
[TITLE](/gibbs2/manual/basickeywords/#g2-optional)
: Title of the gibbs2 run
~~~
TITLE title.s
~~~

<a id="key-temperature"></a>
[TEMPERATURE](/gibbs2/manual/basickeywords/#g2-vpt)
: Define the list of temperatures
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

<a id="key-vfree"></a>
[VFREE](/gibbs2/manual/basickeywords/#g2-mandatory)
: Number of atoms in the system (same as NAT)
~~~
VFREE nat.i
~~~

<a id="key-volume"></a>
[VOLUME](/gibbs2/manual/basickeywords/#g2-vpt)
: Define the list of volumes
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
