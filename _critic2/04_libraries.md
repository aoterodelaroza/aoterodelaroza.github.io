---
layout: single
classes: wide
title: "Critic2---Interfacing with External Libraries"
permalink: /critic2/libraries/
excerpt: "Enhancing critic2's capabilities by interfacing with external libraries ."
sidebar:
  nav: "critic2"
---

This is one of critic2's pages. This site is in construction. Go away.

## Compiling and using external libraries

Critic2 can be compiled with [libxc](http://octopus-code.org/wiki/Libxc) and
[libcint](https://github.com/sunqm/libcint) support. Libxc is a
library that implements the calculation of exchange-correlation
energies and potentials for a number of different functionals. It is
used in critic2 to calculate exchange and correlation energy densities
via the xc() function in arithmetic expressions. See 'Use of LIBXC in
arithmetic expressions' in the user's guide for instructions on how to
use libxc in critic2. 

To compile critic2 with libxc support, two --with-libxc options must
be passed to configure:

    ./configure --with-libxc-prefix=/opt/libxc --with-libxc-include=/opt/libxc/include

Here the /opt/libxc directory is the target for the libxc installation
(use --prefix=/opt/libxc when you configure libxc). 

libcint is a library for molecular integrals between GTOs. It is used
for testing and in some options to the MOLCALC keyword. To compile
critic2 with libcint support, do either of these two:

    ./configure --with-cint-shared=/opt/libcint/build 
    ./configure --with-cint-static=/opt/libcint/build

The first will use the libcint.so file in that directory and
dynamically link to it. The libcint.so path needs to be available when
critic2 is executed through the LD_LIBRARY_PATH environment
variable. The second option will include a copy of the static
libcint.a library into the critic2 binary, located in the indicated
path. 

Make sure that you use the same compiler for the libraries and for
critic2; otherwise the compilation will fail.

Use of LIBXC in arithmetic expressions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If critic2 is linked to the libxc library (see the README for
instructions on how to do this) then the xc() function can be used in
arithmetic expressions. xc() calculates the exchange and/or
correlation energy density for one of the functionals in the libxc
library. The number of arguments to xc() depends on the type of
functional invoked, which is selected using an integer index. The list
of functionals available and their corresponding indices should be
consulted in the libxc documentation. The integer index that selects
the functional always appears *last* in the calling sequence of
xc(). For ease of reference, the files libxc_funcs_*.txt, specifying
the list of functionals in several versions of libxc, is included in
the doc/ directory.

The arguments to xc(...,idx) depend on the type of functional
specified by the idx integer, which can be:

* LDA: xc(rho,idx)

* GGA: xc(rho,grad,idx)

* meta-GGA: xc(rho,grad,lapl,tau,idx)

where rho is the electron density expression, grad is its gradient,
lapl is its Laplacian and tau is the kinetic energy density. Note that
rho, grad, lalp, and tau are *expressions*, not field identifiers like
in the chemical functions above. For instance, the expression for LDA
using the electron density loaded in field number 1 would be:

::

  xc($1,1)+xc($1,9)

because idx=1 is Slater's exchange and idx=9 is Perdew-Zunger
correlation. PBE (a GGA) would be:

::

  xc($1,$2,101)+xc($1,$2,130)

Here 101 is PBE exchange and 130 is PBE correlation. Field $1 contains
the electron density and $2 is its gradient, which can be determined
using, for instance:

::

  LOAD AS GRAD 1

or, if the field is not a grid, in direct way by doing:

::

  xc($1,$1:g,101)+xc($1,$1:g,130)

