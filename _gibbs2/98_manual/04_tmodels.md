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
each of the volumes. In many cases, this is unfeasible due to
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
PHASE ... [TMODEL {STATIC|DEBYE_INPUT|DEBYE_POISSON_INPUT|DEBYE|
                   DEBYE_EINSTEIN [FREQG0 file.s]|
                   DEBYE_GRUNEISEN {SLATER|DM|VZ|MFV|a.r b.r}|
                   {QHAFULL|QHA}}]
          [PHFIELD ifield.i] [DOSFIELD i1.i i2.i]|}] [PREFIX prefix.s]
          [POISSON sigma.r] [FSTEP step.r]
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
  only for the acoustic branches.

  This model requires the frequencies at the Brillouin zone center
  (the Gamma point). There are two options two give them to gibbs2. If
  the FREQG0 option is used followed by a file name, the 3n-3
  frequencies at Gamma at the equlibrium volume are read from the
  file. Otherwise, an additional column from the external data file is
  read. The column must contain the path of the file containing the
  frequencies at Gamma at the corresponding volumes.

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

  It is often the case that some points in the energy-volume grid have
  a substantial amount of their phonon density of states in the
  negative-frequency region. This could be due to numerical error in
  the calculation (if the phDOS decays exponentially below zero) but
  more often it indicates that those points are dynamically unstable
  (i.e. a symmetry-breaking relaxation starting at that point would
  decrease the enthalpy). By default, gibbs2 eliminates
  ("deactivates") the points with substantial negative-frequency phDOS
  from the energy-volume grid so they do not interfere with the
  calculation of thermodynamic properties.

In absence of a TMODEL keyword, the default is DEBYE.

## Optional PHASE options  {#g2-optional}
The following optional keywords can be used in PHASE to control how gibbs2
carries out the equation of state fitting for a particular phase.

### Debye model {#g2-debye}
~~~
[POISSON sigma.r]
~~~
The Poisson ratio of the phase. This value is used in the calculation
of the Debye temperature when using the Debye model. The default value
is 0.25, the Poisson ratio of a Cauchy solid.

### Debye-Einstein model {#g2-debeins}
~~~
PRINTFREQ|PRINTFREQS
~~~
Print the calculated frequencies in the Debye-Einstein model for
all static volumes in input. Writes a file with extension
`.gammafreq`. Only valid when FREQG0 is used.

### Full QHA model {#g2-qha}
~~~
PHASE ... [PREFIX prefix.s]
~~~
Indicates the prefix used to find files containing the vibrational
density of states or frequencies. For instance, this input:
~~~
PHASE MgO FILE mgo.dat PREFIX ../mgo-b1 TMODEL QHA [...]
~~~
reads the energy-volume data and the location of the phonon density of
states files from the external file `mgo.dat`. This file may contain:
~~~
81.8883583665837   -73.5171659350000 001/001.phdos
86.0358791612784   -73.5360133400000 002/002.phdos
[...]
~~~
The path to the phDOS files is build by concatenating the prefix
(`../mgo-b1`) with the names of the files
(`001/001.phdos`). In this case, gibbs2 expects the phDOS files to be
at `../mgo-b1/001/001.phdos`,  `../mgo-b1/002/002.phdos`, etc. An
absolute path may also be used in PREFIX. By default, PREFIX is the
current directory (`.`).
~~~
PHASE ... [PHFIELD ifield.i]
~~~
Indicates which column in the external data file contains the location
of the phDOS files. By default, they assumed to be in the third column
(as in the example above).
~~~
PHASE ... [DOSFIELD i1.i i2.i]
~~~
Indicates which columns gibbs2 reads from each individual phDOS
file. By default, the first column (`i1.i`) is interpreted as the
frequencies and the second column (`i2.i`) as the density of states.
~~~
PHASE ... [FSTEP step.r]
~~~
In the QHA thermal model, gibbs2 needs to interpolate the phonon DOS
at arbitrary volumes. To do this, all phDOS read from input need to be
expressed on the same frequency grid. By default, the step of this
grid is the difference in frequency between the two highest
frequencies at the first volume in the grid. By using FSTEP, the user
can set an explicit value for the phDOS step, equal to `step.r`.

## Optional global keywords {#g2-optionalglobal}
The following optional keywords can be used in the gibbs2 input to
control the EOS fitting for all phases. All the following keywords
apply to the QHA model.
~~~
ACTIVATE {ALL|v1.i v2.i v3.i...}
~~~
In the QHA temperature model, gibbs2 automatically deactivates
a volume when the phonon density of states in input contains
negative frequencies. However, because of numerical errors in the
DFPT calculation and posterior Fourier interpolation, it is
possible to have a small region of negative frequencies. In such 
cases, it is possible to activate manually the use of those volumes
in the dynamic calculation with ACTIVATE. With the ALL keyword, all
the volumes become active. Alternatively, the user can input the
volume integer identifier (the position of the volume in the input
grid). This identifier is written to the output when a volume is
deactivated because of negative frequencies.
~~~
SET PHONFIT {LINEAR|SPLINE}
~~~
Type of interpolation of the phDOS with volume. It can be either
linear (LINEAR) or a cubic not-a-knot spline (SPLINE). Linear
interpolation is almost equivalent to the spline for a reasonably fine
volume grid, and much faster, so LINEAR is the default.
~~~
SET IGNORE_NEG_CUTOFF inegcut.r
~~~
When negative phonon frequencies are passed to gibbs2, the program
assumes that the point does not correspond to a stable structure and
deactivates its use in the calculation of thermodynamic properties. A
deactivated volume is dropped from the energy-volume grid, as if it
had not been given in the input.

Sometimes, small negative frequencies can be the result of numerical
errors in the program used to calculate the phonon frequencies. This
keyword sets a cutoff for the negative frequencies. If a frequency is
less than -abs(`inegcut.r`), the point is deactivated. If a frequency
is between -abs(`inegcut.r`) and 0, the point remains active, but that
frequency is discarded (and the phDOS renormalized to the correct
value). The units of `inegcut.r` are cm-1. The default value is 1000
cm-1.
~~~
SET NORENORMALIZE
~~~
In the QHA thermal model, eliminate the negative frequencies from the
phonon density of states but do not renormalize. This is used for
testing purposes only.
