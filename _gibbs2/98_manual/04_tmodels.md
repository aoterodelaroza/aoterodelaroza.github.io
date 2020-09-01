---
layout: single
title: "Temperature Models"
permalink: /gibbs2/manual/tmodels/
excerpt: "Choosing a Temperature Model to Incorporate Vibrational Effects."
sidebar:
  - repo: "gibbs2"
    nav: "gibbs2_manual"
toc: true
toc_label: "Temperature Models"
toc_sticky: true
---

## Temperature Models {#g2-tmodels}

The effect of temperature on the thermodynamic properties of a solid
mostly manifests through vibrations. An exact treatment of the
vibrational contributions to the free energy is not possible. Instead,
gibbs2 uses the quasiharmonic approximation (QHA), which applies the
harmonic approximation at every volume, thus including some degree of
anharmonicity. Another further approximation is that the system is
constrained to move on the static minimum-energy path, i.e., the
effect of temperature on thermodynamic properties and internal
parameters such as atomic positions is modeled only indirectly via the
change in volume.

A complete statically constrained QHA calculation requires the
energy-volume curve and the phonon density of states calculated at
each of the volumes. In many cases, this is unfeasable due to
computational limitations. Simpler temperature models can be used in
this case. It is important to note that these simplified thermal
models have their limitations, so it is fundamental to check whether
they can be applied to your system by comparing their predictions with
experimental results.

Gibbs2 implements several models for the inclusion of vibrational
effects. These models cover a range of complexity (and accuracy), with
the Debye model in Slater's implementation being the simplest and the
full quasiharmonic approximation being the most complex.  More complex
temperature models require more data. For instance, the Debye model
with Slater's formula for the Debye temperature requires only the
static E(V) curve in the input (and optionally the experimental
Poisson ratio). In contrast, the full QHA model requires the phonon
spectrum calculated at each grid volume, which is much more
computationally expensive.

The different temperature models are accessed using the TMODEL option
to the PHASE keyword:
~~~
PHASE ... [TMODEL {STATIC|DEBYE_INPUT|DEBYE_POISSON_INPUT|DEBYE|DEBYE_EINSTEIN|
                   DEBYE_GRUNEISEN {SLATER|DM|VZ|MFV|a.r b.r}|
                   {QHAFULL|QHA} [PHFIELD ifield.i] [DOSFIELD i1.i i2.i]|
                   QHA_ESPRESSO [PHFIELD ifield.i]]
          [PREFIX prefix.s] [POISSON sigma.r] [LAUE laue.s] [FSTEP step.r]
~~~
The temperature model is selected with one of the following keywords:

* STATIC: do not calculate thermal properties of this phase.

* DEBYE: Debye model. The Debye temperature at each volume is
  calculated from the bulk modulus and the Poisson ratio using
  Slater's formula. By default, the Poisson ratio is assumed to be
  constant and equal to 1/4. Its value can be changed using the 
  [POISSON keyword](#g2-optional). Besides the Poisson ratio, this
  model requires only the static energy-volume curve.

* DEBYE_INPUT: Debye model where the Debye temperatures are read
  from the input. Each line in the energy-volume data must contain an
  additional field with the Debye temperature at the corresponding
  volume.

* DEBYE_POISSON_INPUT: Debye model where the Poisson ratio at each
  volume is read from the input. Each line in the energy-volume data
  must contain an additional field with the Poisson ratio at the
  corresponding volume.

* DEBYE_GRUNEISEN: Debye model where the Debye temperature is
  calculated for the equilibrium volume as in DEBYE but the
  evolution with volume of the Debye temperature is given by an
  approximate formula chosen by the user. The Grüneisen gamma is given
  by:

  $$\gamma_D = -\frac{\partial\ln\Theta_D}{\partial\ln V} = a - b\frac{d\ln B_{\text{sta}}}{d\ln V}$$

  where $$a$$ and $$b$$ are parameters chosen by the user with a
  keyword following DEBYE_GRUNEISEN. The available keywords are:

  | Keyword | Name              | a     | b   |
  |-------------------------------------------|
  | SLATER  | Slater            | -1/6  | 1/2 |
  | DM      | Dugdale-McDonald  | -1/2  | 1/2 |
  | VZ      | Vaschenko-Zubarev | -5/6  | 1/2 |
  | MFV     | Mean free volume  | -0.95 | 1/2 |

  The DEBYE_GRUNEISEN SLATER temperature model is the same as
  DEBYE. Alternatively, the user can also follow the DEBYE_GRUNEISEN
  keyword with two numbers (`a.r` and `b.r`). In that case, the first
  number is interpreted as $$a$$ and the second as $$b$$ in the
  formula above.

* DEBYE_EINSTEIN: Debye model for the acoustic branches and 3n-3 Dirac
  deltas representing the optical part of the phonon spectrum. The
  Debye model is applied as in DEBYE, including Slater's formula, but
  only for the acoustic branches. This model requires the frequencies
  at the Brillouine zone center (the Gamma point) at the equilibrium
  or experimental geometry. These are input using the FREQG0
  keyword.

* QHAFULL or QHA: full quasiharmonic approximation. This model
  implements the statically constrained quasiharmonic
  approximation. It is the most accurate temperature model in
  gibbs2. It requires the phonon density of states (phDOS) at each
  volume, which makes it also the most expensive temperature
  model. Each line in the energy-volume data must contain an
  additional field with the location of file containing the phDOS. The
  phDOS files must contain two columns. The first column is the
  frequency (default units: Hartree) and the second column is the DOS
  (default units: 1/Hartree). The default column from which the phDOS
  file is read as well as the various units can be changed with
  additional [optional keywords](#g2-optional).

