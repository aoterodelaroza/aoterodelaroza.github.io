---
layout: single
title: "Miscellaneous Phase Options"
permalink: /gibbs2/manual/misc/
excerpt: "Miscellaneous Phase Options."
sidebar:
  - repo: "gibbs2"
    nav: "gibbs2_manual"
toc: true
toc_label: "Miscellaneous Phase Options"
toc_sticky: true
---

### Changing the Default Units {#g2-units}

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

### Input of pressure-volume data {#g2-pvdata}

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

### Energy Shift {#g2-eshift}

~~~
PHASE ... [ESHIFT eshift.r]
~~~

The ESHIFT option to phase displaces the static energy by
`eshift.r`. The units are the same as in input. By default, there is
no shift in the energy.
