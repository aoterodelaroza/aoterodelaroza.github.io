---
layout: single
classes: wide
title: "Critic2"
permalink: /critic2/
excerpt: >-
  Analysis of the results of quantum chemical calculations in
  molecules and solids. Critic2 implements crystallographic
  computations, input and output format conversion, Bader analysis,
  critical point search, NCI plots, and much, much more.
sidebar:
  nav: "critic2"
categories: critic2
search: true
---

Critic2 is a program for the analysis of the results of quantum
mechanical calculations in molecules and periodic solids. 

* The **development version** works only with recent compilers (see
  [here](/critic2/examplenoexist/)) but has the latest features.
  Current version is **1.0**.\\
Download:
<a href="https://github.com/aoterodelaroza/critic2/archive/1.0dev.zip" class="btn btn--success">zip</a>
<a href="https://github.com/aoterodelaroza/critic2/archive/1.0dev.tar.gz" class="btn btn--success">tar.gz</a>

* The **stable version** works with almost any f90/f03 Fortran
  compiler. Only serious bugs will be fixed in the stable version.
  Current version is **1.0**.\\
Download:
<a href="https://github.com/aoterodelaroza/critic2/archive/1.0stable.zip" class="btn btn--success">zip</a>
<a href="https://github.com/aoterodelaroza/critic2/archive/1.0stable.tar.gz" class="btn btn--success">tar.gz</a>

Alternatively, *clone the git repository* for the latest version of the code:
~~~
git clone git@github.com:aoterodelaroza/critic2.git
~~~
or visit the [github page](https://github.com/aoterodelaroza/critic2).

## Features

Critic2 can be used to read and transform between file formats, and
read, analyze, and manipulate scalar fields such as the ELF or the
electron density.  An important part of critic2 is the topological
anaylisis of real-space scalar fields, which includes the
implementation of Bader's atoms in molecules theory (QTAIM): critical
point search, basin integration, basin plotting, etc. Other related
techniques, such as non-covalent interaction plots (NCIplots), are
also implemented. New scalar fields can be computed using critic2's
powerful arithmetic expressions.

Critic2 is designed to provide an abstraction layer on top of the
underlying electronic structure calculation. Different electronic
structure methods (FPLAPW, pseudopotentials, local orbitals,...)
represent the electron density, and other fields, in different
ways. The program interfaces to many of these and applies common
techniques and algorithms to them. At present, critic2 can interface
to WIEN2k, elk, PI, Quantum ESPRESSO, abinit, VASP, DFTB+, Gaussian,
psi4, siesta, and to any other program capable of writing the scalar
field of interest to a grid. Many more structural file formats are
supported, and critic2 provides crystallographic and structural
computing tools: crystal structure comparison, molecular environment
generation, file conversion, and more.
