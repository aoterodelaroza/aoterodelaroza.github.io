---
layout: single
title: "Critic2---Interfacing with External Libraries"
permalink: /critic2/libraries/
excerpt: "Enhancing critic2's capabilities by interfacing with external libraries ."
sidebar:
  nav: "critic2"
toc: true
toc_label: "External Libraries"
toc_sticky: true
---

## Libxc

[Libxc](http://octopus-code.org/wiki/Libxc) is a library that
implements exchange-correlation energies and potentials for many
semilocal functionals (LDA, GGA and meta-GGA). In critic2, it is used
to calculate exchange and correlation energy densities via de `xc()`
arithmetic expressions (see below).

To compile critic2 with libxc support, you must pass the location of
the library via `configure`:

    ./configure --with-libxc=/opt/libxc

where `/opt/libxc/` is the directory that was the target for the libxc
installation (i.e. you used `--prefix=/opt/libxc` when you configured
the libxc library). The code in critic2 is not compatible with
versions of libxc older than 3.0.

The libxc library is used in critic2 to create new scalar fields from
the exchange and correlation energy density definitions in the library
using a density, gradient, or kinetic energy density already available
to critic2 as a scalar field. For instance, if `urea.rho.cube`
contains the electron density in the urea crystal, then:
~~~
CRYSTAL urea.rho.cube
LOAD urea.rho.cube
LOAD AS "xc($1,1)+xc($1,9)"
~~~
defines a scalar field (number 2, `$2`) as the LDA
exchange-correlation density. In the output, the cell integral of
the second field:
~~~
  Cell integral (grid SUM) = -23.30215685
~~~
is the LDA exchange-correlation energy in this system. GGA and
meta-GGA exchange-correlation energy densities can be constructed in a
similar way, but they require additional arguments to `xc()`.

Another example: if we have a molecular wavefunction for benzene in
`benzene.wfx`, we can build a field containing the PBE energy density
and then integrate the PBE exchange-correlation energy with: 
~~~
MOLECULE benzene.wfx
LOAD benzene.wfx
MOLCALC "xc($1,$1:g,101)+xc($1,$1:g,130)"
~~~
In this case, `xc()` takes two arguments: the density and the
gradient. Since the gradient from a molecular wavefunction is
calculated analytical (and therefore with no significant error), we
can use the `:g` field modifier to pass the gradient of the first
field as the second argument to `xc()`. The MOLCALC keyword performs a
numerical integration in a molecular mesh.

See the [complete example](/critic2/examplenoexist/) and the
[manual](/critic2/examplenoexist) for more information.

## Libcint

[Libcint](https://github.com/sunqm/libcint) is a library for
calculating molecular integrals between Gaussian-Type Orbitals
(GTOs). In critic2, this library is used mostly for testing but some
options to the MOLCALC keyword and some functions in arithmetic
expressions require it. To compile critic2 with libcint support, do
either of these two:
~~~
./configure --with-cint-shared=/opt/libcint/lib
./configure --with-cint-static=/opt/libcint/lib
~~~
where `/opt/libcint/lib` is the location of the libcint static (`.a`)
or shared (`.so`) libraries prefix where libcint was installed.  If
compiled with the shared option, the same path needs to be available
when critic2 is executed (for instance, through the LD_LIBRARY_PATH
environment variable).

The libcint library is used with molecular wavefunctions that provide
the basis set information (at present, this is only for fields read
from a Gaussian fchk file, but more will implemented). The `mep()`,
`uslater()`, and `nheff()` chemical functions use the molecular
integrals calculated by libcint, as well as the `MOLCALC HF`
keyword. See the [complete example](/critic2/examplenoexist/) and the
[manual](/critic2/examplenoexist) for more information.

## Libqhull

The qhull library calculates convex hulls, Delaunay triangulations,
Voronoi diagrams, and other geometry computations. In critic2, the
qhull library is used to calculate the Wigner-Seitz (WS) cell. The
lattice vectors that correspond to each of the WS faces are used in
critic2 to calculate the shortest lattice translation of a given
vector as well as in the YT integration method and other
parts. 

Critic2 ships a static (and probably old) copy of qhull but if you
want to compile against your own, you can do so via configure:
~~~
./configure --with-qhull-inc=/usr/include/qhull/ --with-qhull-lib=/usr/lib/x86_64-linux-gnu
~~~
where the two directories are the location of the `libqhull.h` header
file (with-qhull-inc) and the `libqhull.so` library file
(with-qhull-lib).

