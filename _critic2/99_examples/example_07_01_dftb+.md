---
layout: single
title: "Working with DFTB+ Files"
permalink: /critic2/examples/example_07_01_dftb+/
excerpt: "Working with DFTB+ Files"
sidebar:
  - repo: "critic2"
    nav: "critic2_examples"
toc: true
toc_label: "Working with DFTB+ Files"
---

### Introduction

[DFTB+](https://dftbplus.org/) is a program that implements a variety
of density-functional tight binding methods. The DFTB wavefunction
calculated by DFTB+ has an linear combination of atomic orbitals
(LCAO) expression using Slater-type orbitals. For instructions on
setting up the program as well as the different calculation levels and
how to run a calculation, please refer to the package documentation.

### Reading and Writing Structures

Critic2 understands molecular and crystal geometries read and written
by DFTB+, in its `.gen` format. A gen file looks like this:
```
16 F
 C O N H
1 1 0.000000000000       0.500000000000       0.326000000000
[...]
0.000000000000       0.000000000000       0.000000000000
5.565000000001       0.000000000000       0.000000000000
0.000000000000       5.565000000001       0.000000000000
0.000000000000       0.000000000000       4.684000000002
```
where the system is treated as a molecule or a crystal depending on
whether the final four lines (the lattice vectors) are present. A
gen file can be used as input for DFTB+ and it can also be written
during a geometry optimization using the `OutputPrefix` keyword in
`Driver`. On the other hand, critic2 can also write arbitrary
crystal structures in gen format:
~~~
crystal library urea
write urea.gen
~~~
as well as molecular structures:
~~~
molecule library benzene
write benzene.gen
~~~
This is useful for setting up new DFTB+ calculations.

### Reading DFTB+ Wavefunctions

Three files are required to read a wavefunction calculated by DFTB+
files:

* A `detailed.xml` file, which is written by activating the
  `WriteDetailedXML` keyword in the DFTB+ input.

* The `eigenvec.bin` file, which is written by DFTB+ when the
  `WriteEigenVectors` keyword is used.

* The `.hsd` file containing the STO coefficients corresponding to the
  parametrization used in the calculation. These are provided
  by the DFTB+ authors and can be [obtained online](https://dftb.org/parameters/download).

The kinetic energy density can be calculated from a DFTB+
wavefunction.

Two different types of systems can be run in DFTB+: crystals under
periodic boundary conditions, and molecules in the gas-phase. In the
first case, if using k-points other than Gamma, the wavefunction is
complex, and the evaluation of the density is relatively
slow. Molecules use real wavefunctions and they tend to be less
crowded than crystals, so using molecular DFTB fields should be
considerably faster.

### Examples

Two complete examples are given in the package below: a molecule
(benzene) and a solid (graphite). To run them, execute `dftb+` in the
corresponding directories. Output files are already provided.

A critic2 example input for reading the DFTB+ structure and
wavefunction of a molecule is:
~~~
# Read the benzene molecule from the gen file
molecule benzene.gen 2

# Load the DFTB+ wavefunction
# In DFTB+, only valence electrons are used. Hence, we need core-augmentation
# to account for the missing core density. Set ZPSP to the number
# of valence electrons associated with a given atom (4 for carbon,
# 5 for nitrogen, 6 for oxygen,...)
load detailed.xml eigenvec.bin ../3ob-3-1/wfc.3ob-3-1.hsd zpsp c 4

# Find the critical points
auto

# Write a vmd file with the critical points
cpreport benzene.vmd cell molcell graph

# Calculate the electron density on a plane
plane 0 -3 -3  0 3 -3  0 -3 3  101 101 contour log 41 relief 0 1
~~~

For a crystal:
~~~
# Read the graphite crystal from the gen file
crystal graphite.gen

# Load the DFTB+ wavefunction
# In DFTB+, only valence electrons are used. Hence, we need core-augmentation
# to account for the missing core density. Set ZPSP to the number
# of valence electrons associated with a given atom (4 for carbon,
# 5 for nitrogen, 6 for oxygen,...)
load detailed.xml eigenvec.bin ../3ob-3-1/wfc.3ob-3-1.hsd zpsp c 4

# Calculate the electron density on a plane
plane 0 0 1/4  1 0 1/4  0 1 1/4  101 101  contour log 41 file plane
~~~

### Example Files Package

Files: [example_07_01.tar.xz](/assets/critic2/example_07_01/example_07_01_dftb+.tar.xz).
