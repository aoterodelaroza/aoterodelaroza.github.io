---
layout: single
title: "Quick Start Guide"
permalink: /gibbs2/quickstart/
excerpt: "Basic usage of gibbs2."
sidebar:
  - repo: "gibbs2"
    nav: "gibbs2" 
---

Gibbs2 reads the user commands from a single input file (the `.ing`
file). A simple input (`mgo.ing`) is:
~~~
NAT 2
MM 40.3044
PHASE mgo
 81.8883583665837   -73.5171659350000
 90.1833999559730   -73.5508544000000
 98.4784415453624   -73.5712754950000
106.7734831347517   -73.5826963000000
115.0685247241411   -73.5878968050000
123.3635663135304   -73.5887555350000
131.6586079029198   -73.5865593900000
139.9536494923091   -73.5822069800000
148.2486910816984   -73.5763274850000
156.5437326710878   -73.5693791200000
160.0000000000000   -73.5662512150000
ENDPHASE
~~~
This input gives the data for a simple calculation of the
thermodynamic properties in MgO. The keywords are:

* [NAT](/gibbs2/manual/basickeywords/#g2-mandatory): the number of
  atoms in the system. Typically, this value is
  the number of atoms per formula unit but it can also be per unit
  cell, per molecule, etc. All extensive quantities in output are
  given per NAT atoms.

* [MM](/gibbs2/manual/basickeywords/#g2-mandatory): the molar mass per
  NAT atoms.

* [PHASE](/gibbs2/manual/basickeywords/#g2-mandatory): the definition
  of a new phase. In this case, the rocksalt-type phase of MgO. A
  number of lines follow containing pairs of volume/energy data (in
  bohr^3 and Hartree). The volume and energy correspond to NAT
  atoms. The input of data for this phase ends with the keyword
  ENDPHASE.

To run an input, do:
~~~
gibbs2 mgo.ing
~~~
This will write to the standard output. Redirect the output to a file
with either of:
~~~
gibbs2 mgo.ing > mgo.outg
gibbs2 mgo.ing mgo.outg
~~~
In addition to the output, gibbs2 generates a number of auxiliary
files (plots, tables, etc.). The output files typically have the same
root (that is, the name up to the last `.`) as the input file.

Gibbs2 accepts many keywords and commands. For a full description, see
the [manual](/gibbs2/manual/). A summary of all available keywords can
be found in the [syntax page](/gibbs2/syntax/). Some examples can be
found in the [list of tests](/gibbs2/manual/tests/).

