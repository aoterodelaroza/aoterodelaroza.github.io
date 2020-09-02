---
layout: single
title: "Electronic Contributions to the Free Energy"
permalink: /gibbs2/manual/elec/
excerpt: "Electronic Contributions to the Free Energy."
sidebar:
  - repo: "gibbs2"
    nav: "gibbs2_manual"
toc: false
toc_label: "Electronic Contributions"
toc_sticky: true
---

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

