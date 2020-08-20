---
layout: single
title: "Reference Manual"
permalink: /gibbs2/manual/
excerpt: "The gibbs2 reference manual."
sidebar:
  - repo: "gibbs2"
    nav: "gibbs2_manual"
toc: true
toc_label: "Reference Manual"
toc_sticky: true
---

## Overview

Gibbs2 is a program for the calculation of thermodynamic properties in
periodic solids under arbitrary conditions of pressure and
temperature, within the quasiharmonic approximation. Gibbs2 is
designed to work with data obtained from periodic solid-state
quantum-mechanical calculations. At the most basic level, the only
required information about a given solid is the number of atoms in the
unit cell, the molar mass, and the energy-volume curve. 

In a typical calculation the user selects a grid of volumes
encompassing the equilibrium geometry of the system. At those volumes,
the rest of the structural parameters are relaxed and an E(V) curve is
obtained, called the static equation of state (static because no
vibrations are involved). In the simplest possible use of gibbs2, the
static equation of state is all that is needed to estimate
thermodynamic properties via the Debye model. In more complex cases,
vibrational information is also read, and the full quasiharmonic
approximation is used. In general, better (more accurate) results are
obtained if more information is passed to gibbs2.

The effect of pressure in gibbs2 is accounted for by simply adding a
pV term to the energy. The effect of temperature, however, requires a
thermal model: an approximate way of including the contribution to the
free energy from the crystal degrees of freedom. In general, these
contributions are dominated by the vibrational free energy, so thermal
models are actually approximate methods to incorporate this
contribution. Several thermal models with increasing complexity are
available:

* Static: no vibrational effects (i.e. no temperature).

* Debye and Debye-Gruneisen: these thermal models treat all the
  phonons in the solid as long-wavelength stationary vibrations. They
  required require only the static energy-volume curve. Optionally,
  the Poisson ratio and the Grüneisen gamma can also be input.

* Debye-Einstein: this model treats the acoustic modes using the Debye
  model and the optical modes with the Einstein model (i.e. a single
  frequency for a whole optical band). In addition to the E(V) curve,
  it requires vibrational frequencies at the Brillouin zone center.

* Full quasiharmonic approximation (QHA): together with the static
  energy curve, either the phonon density of states or the vibrational
  frequencies on a grid sampling the 1BZ are required at each volume.

Once the thermal model is chosen, the vibrational Helmholtz free
energy (Fvib) is calculated as a function of temperature at every
volume in the grid. The equilibrium volume at a given T and
p ($$V(p,T)$$) is calculated by minimizing:

$$
\begin{equation}
G(V;p,T) = E(V) + pV + F_{\rm vib}(V;T)
\end{equation}
$$

The value of V(p,T) is then used to compute the rest of the
thermodynamic properties. Note that, in this formulation, the internal
degrees of freedom (i.e. those that determine the geometry besides the
volume) are assumed to be unchanged by the vibrational effects.

In order to calculate the volume derivatives of the energy and the
free energy, which are necessary for the thermodynamic calculations,
an analytical expression for the E(V) and F(V;T) curves is required,
called the equation of state (EOS). Using a least-squares fit, the EOS
parameters for E(V) or F(V;T) at a given T are determined, and
analytical differentiation used to compute the required
derivatives. Gibbs2 implements a few methods for robust EOS fitting.
The recommended (and default) procedure involves performing successive
linear least-squares fits of polynomials in a chosen strain
(Birch-Murnaghan, Poirier-Tarantola,...) with increasing degree. Then,
an average polynomial is obtained. This averaging procedure provides a
statistical measure of the goodness of the fit in the form of
calculated error bars of the calculated thermodynamic properties.
Gibbs2 is also to use traditional EOS like the Vinet or Murnaghan
expressions using a non-linear minimization algorithm. 

The temperature and pressure ranges accessible with a given data set
is determined by the input E(V) grid. In general, the first (most
compressed) volume in the grid determines the maximum pressure
achievable while the last (most expanded) volume determines the
maximum temperature.

Gibbs2 can be used to calculate the thermodynamic properties of
multiple phases for the same system. When more than one phase is
input, gibbs2 will determine the thermodynamically stable phase at
each temperature and pressure, i.e. the phase diagram. In addition,
temperature-dependent transition pressures are also calculated. 

Finally, the gibbs2 code is the successor of the [gibbs
program](https://doi.org/10.1016/j.comphy.2003.12.001) by
M. A. Blanco, E. Francisco and V. Luaña.

## Command-line options

The following command line options can be passed to gibbs2. Some of
them correspond to options that can also be passed in the input file
with a `SET` keyword (this is indicated in parentheses).

* `-n`, `--noplot`:
         Inhibits the creation auxiliary files. The only output written
         by gibbs2 goes to the standard output and error.
         (`SET WRITELEVEL 0`)

* `-q`, `--quiet`:
	 Do not print timing information to the output.

* `-e`, `--eos`:
         Same as `-n`, but the `.eos` (thermal equation of state) and
         `.eos_static` (static equation of state) files are also
         written.
         (`SET WRITELEVEL 1`)

* `-b`, `--errorbar`:
         Calculate and output the error bars for each thermodynamic
         property. The error values are marked by an ''e'' at the
         beginning of the line in the `.eos` file.
         (`SET ERRORBAR`)

* `-t`, `--notrans`:
         Do not compute transition pressures.
         (`SET NOTRANS`)

* `-d`, `--noplotdh`:
         Do not write enthalpy difference plots.
         (`SET NOPLOTDH`)

* `-f`, `--noefit`:
         Do not write static energy plots.
         (`SET NOEFIT`)

* `-h`, `--help`, `-?`:
         Command-line help.

