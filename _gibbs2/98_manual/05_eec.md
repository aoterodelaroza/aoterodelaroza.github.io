---
layout: single
title: "Empirical Energy Corrections"
permalink: /gibbs2/manual/eec/
excerpt: "Empirical Energy Corrections."
sidebar:
  - repo: "gibbs2"
    nav: "gibbs2_manual"
toc: false
toc_label: "Empirical Energy Corrections"
toc_sticky: true
---

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

