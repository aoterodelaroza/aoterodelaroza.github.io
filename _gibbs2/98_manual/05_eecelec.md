---
layout: single
title: "Empirical Energy Corrections and Miscellaneous Topics"
permalink: /gibbs2/manual/eecelec/
excerpt: "Empirical Energy Corrections and Miscellaneous Topics."
sidebar:
  - repo: "gibbs2"
    nav: "gibbs2_manual"
toc: true
toc_label: "Empirical Energy Corrections and Miscellaneous Topics"
toc_sticky: true
---

## Empirical Energy Corrections {#g2-eec}

The thermodynamic properties resulting from a density functional
calculation most of the time depend dramatically on the
exchange-correlation density functional employed. This is the main
source of error in the calculation of thermodynamic properties
provided a good temperature model is used. In order to correct these
discrepancies, empirical energy corrections (EEC) have been
proposed. See
[Phys. Rev. B **84** (2011) 024109](https://doi.org/10.1103/PhysRevB.84.024109)
and 
[Phys. Rev. B **84** (2011) 184103](https://doi.org/10.1103/PhysRevB.84.184103).

The EEC are corrections are applied to the static energy curve and are
designed to correct the E(V) curve in such a way that one or two
experimental data are exactly reproduced. In the current
implementation, the data may be the experimental equilibrium volume at
ambient conditions alone and, possibly, the experimental bulk modulus
at ambient conditions. Several EECs have been implemented:

* PSHIFT: shift the energy with a constant pressure term.

* APBAF: add a constant times 1/V.

* BPSCAL: corrects the energy using the observation that $$p/B_0$$
  versus $$V/V_0$$ is similar for all functionals and experimental
  data.

Empirical energy corrections are applied to a phase using the EEC
option to the PHASE keyword:
~~~
PHASE ... [EEC NOSCAL|PSHIFT vexp.r|BPSCAL vexp.r bexp.r|APBAF vexp.r|USE phase.i]
          [EEC_P pext.r] [EEC_T text.r] 
~~~
The EEC option is followed by the type of EEC to be applied. The
additional keyword following EEC can be one of:

* NOSCAL: do not use any correction. This is the default.

* PSHIFT: use a correction of the type $$E_{\rm corr} = E + \Delta p *
  V$$, with empirical parameter $$\Delta p$$ determined to make the
  ambient temperature and pressure volume equal to `vexp.r`.

* BPSCAL: use a correction of the type 

  $$E_{\rm corr} = E + \frac{B_{\rm exp}V_{\rm exp}}{B_0V_0} \times \left[E\left(\frac{V\times V_0}{V_{\rm exp}}\right)-E(V_0)\right]$$
  
  with parameters $$V_{\rm exp}$$ and $$B_{\rm exp}$$ chosen to
  reproduce the experimental volume `vexp.r` and bulk modulus `bexp.r`
  at ambient conditions. 

* APBAF: use a correction of the type:

  $$E_{\rm corr} = E + \frac{\alpha}{V}$$

  with the parameter $$\alpha$$ chosen to reproduce the volume at
  ambient conditions (`vexp.r`).

* USE: if the current phase is not stable at ambient conditions, it is
  not possible to calculate the equilibrium volume and bulk modulus
  and apply the EEC. The USE keyword copies the EEC applied to a
  different phase with index `phase.i`. This is useful in the context
  of calculating phase transitions, where an EEC is applied to all
  phases involved..

Sometimes, the experimental data are available only under pressure and
temperature that are different from ambient conditions. In that case,
the pressure and temperature of the EEC can be changed to match the
experimental data with the EEC_P and EEC_T options to PHASE:
~~~
EEC_P pext.r
~~~
The EEC_P option specifies the external pressure (in GPa) of the
experimental data from which the EEC parameters obtained. The default
is zero.
~~~
EEC_T text.r
~~~
The EEC_T option specifies the temperature (in K) of the experimental
data from which the EEC parameters obtanied. The default is room
temperature (298.15 K).

## Electronic Contribution to the Free Energy {#g2-electronic}

Metals possess electronic degrees of freedom that contribute to the
free energy and the heat capacity, in addition to the vibrational
contributions described above. These electronic contributions arise
from their band structure: the electrons are relatively free to move
through the metal because there are empty states at small energies
above the Fermi level. Usually, the electronic contribution to the
free energy is negligible compared to the vibrational one. However,
due to its simplicity, gibbs2 provides a means for including the
electronic free energy using two different models: the Sommerfeld
model of free and independent electrons (SOMMERFELD) and a model that
reads the coefficients of a polynomial fitted to results of finite
temperature DFT calculations (see Mermin, 1965). The option for
including the electronic contribution in a given PHASE is ELEC:
~~~
PHASE ... [ELEC {SOMMERFELD [FREE|icol.i|]| POL4 [icol1.i]}] [NELEC nelec.i]
~~~
The ELEC is followed by the type of electronic contribution:

* SOMMERFELD: the Sommerfeld model of free and independent electrons
  is used. If the additional FREE keyword is used, the free electron
  model is used. If SOMMERFELD is followed by an integer `icol.i`,
  then the occupation at the Fermi level is read from an additional
  column in the data file. Note that SOMMERFELD requires giving the
  number of conduction electrons using the NELEC keyword.

* POL4: reads the result of a finite-temperature DFT calculation. When
  POL4 is used, gibbs2 rads eight columns starting at `icol.i` (first
  column is `icol.i`, second column is `icol.i`+1, etc.). The first
  four columns are the coefficients of a fourth-degree polynomial fit
  to the electronic free energy ($$F_{\rm el}$$) with respect to
  temperature:

  $$F_{\rm el} = i_4 \times T^4 + i_3 \times T^3 + i_2 \times T^2 + i_1 \times T$$

  Columns 5 to 8 represent a fourth-degree polynomial fit to
  $$-T*S_{\rm el}$$ as a function of temperature: 

  $$-TS_{\rm el} = i_8 \times T^4 + i_7 \times T^3 + i_6 \times T^2 + i_5 \times T$$

  Both $$F_{\rm el}$$ and $$-T*S_{\rm el}$$ can be calculated using an
  electronic structure program. The fitted free energy and entropy
  contributions must correspond to NAT times Z atoms.

By default, no electronic contribution is added. The SOMMERFELD
keyword requires:
~~~
NELEC nelec.i
~~~
The NELEC keyword gives the number of conduction electrons in the
solid. This value is appropriate only in combination with
SOMMERFELD. Note this keyword is not related to NELECTRONS, used for
the AP2 fits. Default: zero.

## Interpolation of Satellite Data and Extrapolation
~~~
PHASE ... [INTERPOLATE f1.i [f2.i ...]]
~~~
In the definition of a phase, it is possible to declare satellite data
(e.g. internal atomic coordinates, cell parameters,...) using the
optional INTERPOLATE keyword. The `f1.i`, `f2.i`, etc. integers are
the columns in the external data file that contain the data to be
interpolated. 

The points at which the satellite data are interpolated can be
specified with the global INTERPOLATE keyword:
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
~~~
The values at which the interpolation takes place are enclosed in a
INTERPOLATE...ENDINTERPOLATE environment. If P is used as the first
line in the INTERPOLATE environment, then the values (p1, p2, ...) are
interpreted as static pressures. If V is used, then the values are
interpreted as volumes. Lastly, if PT is used, values are read in
pairs: first the pressure and then the temperature. 

Interpolation can also be applied using the command:
~~~
INTERPOLATE INPUT [STATIC]
~~~
When the INPUT keyword is used, the pressure and temperature range
used in the calculation of thermodynamic properties is also used for
the interpolation. If the additional STATIC keyword is used, use the
volumes of the static energy-volume grid.

The number of points in the energy-volume grid can be increased using
the optional PHASE keyword:
~~~
PHASE ... EXTEND
~~~
Each phase has a maximum calculable pressure, determined by the slope
of the energy-volume curve at the first (smallest) volume. If the
maximum pressure of any phase is smaller than the requested pressure
range, then the pressure range is automatically reduced. In some
cases, this behavior is undesirable. A phase with the EXTEND
keyword will not reduce the user-input pressure range.

## Additional Options to PHASE

### Changing the Default Units

By default, gibbs2 understands all the input quantities are in atomic
units: Hartree for the energies and frequencies, bohr^3 for the
volume, etc. This behavior can be changed with the UNITS option to
PHASE: 
~~~
PHASE ... [UNITS {VOLUME {BOHR|BOHR3|BOHR^3|ANG|ANG3|ANG^3}}
                 {ENERGY {HY|HARTREE|HA|EV|EVOLT|ELECTRONVOLT|RY|RYDBERG}}
                 {PRESSURE {AU|A.U.|GPA}} 
                 { {FREQ|FREQUENCY} {HARTREE|HY|HA|CM-1|CM^-1|CM_1|THZ}}
		 {EDOS {HY|HARTREE|HA|EV|EVOLT|ELECTRONVOLT|RY|RYDBERG}}]
~~~
The UNITS option to PHASE selects the units for the input volume
(VOLUME), energy (ENERGY), pressure (PRESSURE), frequency (FREQ or
FREQUENCY) and Fermi energy (EDOS). For instance, if your electronic
structure program uses angstrom^3 units for the volume and eV for the
energy, then it is convenient to use:
~~~
PHASE ... UNITS VOLUME ANG3 ENERGY EV
~~~
All data is converted to atomic units internally, and the output is
always in atomic units, except where explicitly noted.

### Input of pressure-volume data

The PVDATA option to PHASE can be used to indicate that the input data
is pressure-volume instead of energy-volume:
~~~
PHASE ... PVDATA
~~~
The equation of state, in its p(V) form, is fit to the data and then
an E(V) curve is generated by integration. 

Because p(V) data do not contain points in the negative pressure
region, the volume grid needs to be extended somewhat by adding points
with $$V > V_0$$, where $$V_0$$ is the zero-pressure volume. The global
keyword NEWPTS is used to control the number of points added in the
$$V > V_0$$ zone:
~~~
SET NEWPTS newpts.i
~~~
where `newpts.i` is the number of points added (default =
20). Likewise, the extent of the expansion in the negative pressure
range can be controlled using:
~~~
SET FACEXPAND fac.r
~~~
The original range [$$V_1$$,$$V_0$$] is expanded to
[$$V_1$$,$$V_0'$$], where:

$$V_0' = V_1 + (V_1 - V_0) \times $$ `fac.r`

By default, `fac.r` is 0.40.

### Energy Shift

~~~
PHASE ... [ESHIFT eshift.r]
~~~

The ESHIFT option to phase displaces the static energy by
`eshift.r`. The units are the same as in input. By default, there is
no shift in the energy.


