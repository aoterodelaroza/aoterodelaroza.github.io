---
layout: single
title: "Gibbs2"
permalink: /gibbs2/
excerpt: >-
  Calculation of thermodynamic properties in periodic solids as a
  function of temperature and pressure in the quasiharmonic
  approximation.
sidebar:
  - repo: "gibbs2"
    nav: "gibbs2" 
search: true
---

Gibbs2 is a program for the calculation of thermodynamic properties in
periodic solids under arbitrary conditions of temperature and
pressure. Gibbs2 uses the results of periodic solid-state
quantum-mechanical calculations, specifically the energy-volume curve
and possibly the harmonic phonon frequencies, to compute the
thermodynamic properties of the solid within the framework of the
quasiharmonic approximation.

* You can download the **current version** of the gibbs2 program from:\\
  [gibbs2-1.0.zip](/assets/gibbs2/versions/gibbs2-1.0.zip).

Alternatively, clone the git repository for the **latest version** of the code:
~~~
git clone git@github.com:aoterodelaroza/gibbs2.git
~~~
or visit the [github page](https://github.com/aoterodelaroza/gibbs2).

## Features

- Predict thermodynamic properties of periodic solids from
  energy-volume curves calculated using first-principles methods.

- Various equations of state can be used to fit the calculated E(V)
  points and obtain the pressure and the enthalpy.

- Different thermal models can be used to incorporate the effects of
  temperature: From the simple Debye model, which requires only the
  E(V) curve, to the full quasiharmonic approximation that uses the
  phonon density of states at each volume.

- Computes all relevant thermodynamic properties: bulk moduli, heat
  capacities, entropies, free energies, thermal expansivity
  coefficients, etc. All of them as a function of pressure and
  temperature.

- Can be used on multiple phases. When more than one phase is input,
  gibbs2 calculates phase stability based on G(p,T) and predicts the
  phase diagram.

## Files

* `LICENSE`: a copy of the licence. Gibbs2 is distributed under the
  GNU/GPL license v3.
* `src/`: source code. The `gibbs2` binary is generated in here.
* `tests/`: a few examples that also serve as regression tests for the
  program.

## Citation

The basic references for gibbs2 are:

* A. Otero-de-la-Roza and V. Luaña, 
  Comput. Phys. Commun. **182**, 1708-1720 (2011)
  <https://doi.org/10.1016/j.cpc.2011.04.016> 
* A. Otero-de-la-Roza, D. Abbasi-Pérez, and V. Luaña, 
  Comput. Phys. Commun. **182**, 2232-2248 (2011)
  <https://doi.org/10.1016/j.cpc.2011.05.009>

Please cite these if you find this program useful. See the outputs and
the manual for references pertaining particular keywords.

## Copyright

Gibbs2 is distributed under the GNU/GPL v3 license. The LICENSE file
in the root of the distribution contains a copy of the license.

