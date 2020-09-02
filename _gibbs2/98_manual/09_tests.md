---
layout: single
title: "Test Cases and Examples"
permalink: /gibbs2/manual/tests/
excerpt: "Test Cases and Examples"
sidebar:
  - repo: "gibbs2"
    nav: "gibbs2_manual"
toc: false
toc_label: "Test Cases and Examples"
toc_sticky: true
---

Some test cases that can also serve as templates are provided together
with gibbs2. They can be found in the `tests/` directory. The
`tests/dat` subdirectory contains the datasets, calculated using
Quantum ESPRESSO. The data are:

* `al_lda`, `al_pbe`: fcc aluminium using the named xc functionals, 43
  volume points.

* `c_lda`, `c_pbe`: diamond, 31 volume points.

* `mgo_lda`, `mgo_pbe`: MgO, B1 phase, 174 volume points.

* `mgob2_lda`, `mgob2_pbe`: MgO, B2 phase, 174 volume points.
 
The test cases are:

* `01_simple.ing`: a simple example.

* `02_fits.ing`: comparison of energy fit expressions.

* `03_tmodels.ing`: different temperature models. 

* `04_eec.ing`: empirical corrections of the energy.

* `05_elec.ing`: electronic contribution to the free energy.

* `06_phases.ing`: MgO phase transition.

To run them, simply go into the corresponding directory and do:
~~~
gibbs2 xx.ing xx.out
~~~

