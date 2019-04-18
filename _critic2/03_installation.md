---
layout: single
title: "Installation"
permalink: /critic2/installation/
excerpt: "Installation of the critic2 program."
sidebar:
  - repo: "critic2"
    nav: "critic2" 
toc: true
toc_label: "Installation of Critic2"
toc_sticky: true
---

## Installation Instructions

If you downloaded the code from the git repository, you will need to run:
~~~
autoreconf
~~~
Prepare for compilation by doing:
~~~
./configure
~~~
Use `configure --help` for information about the different
compilation options. The `--prefix` option to `configure` sets the
installation path. More details about `configure` can be found in the
`INSTALL` file included in the distribution. Once critic2 is configured,
compile the program using:
~~~
make
~~~
This should create the critic2 executable inside the `src/`
subdirectory. The binary can be used directly after setting the
`CRITIC_HOME` variable (see below) or the entire critic2 distribution can be
installed to the `prefix` directory by doing:
~~~
make install
~~~
Critic2 is parallelized with OpenMP for shared-memory architectures (unless
compiled with `--disable-openmp`). You change the number of
parallel threads by setting the `OMP_NUM_THREADS`
environment variable. Note that the parallelization flags for
compilers other than ifort and gfortran may not be correct.

In the case of ifort (and maybe other compilers), sometimes it may be
necessary to increase the stack size using, for instance:
~~~
export OMP_STACKSIZE=128M
~~~
This applies in particular to integrations using YT in very large
systems.

The environment variable `CRITIC_HOME` is necessary if critic2 was not
installed with `make install`. It must point to the root directory of
the distribution:
~~~
export CRITIC_HOME=/home/alberto/programs/critic2dir
~~~
This variable is necessary for critic2 to find the atomic densities,
the cif dictionary, and other files. These files should be in
`${CRITIC_HOME}/dat/`.

## Which Compilers Work? {#whichcompilerswork}

Critic2 uses some features from the more modern Fortran standards,
which may not be available in some (most) compilers. In consequence,
not all compilers may be able to generate the binary and, even if they
do, it may be broken. Two versions of critic2 are distributed. The
**development** version, corresponding to the master branch of the
repository, and the **stable** version, in the stable branch. Only
patches addressing serious bugs will be introduced in the stable
version; all new development happens in the development version. The
stable version is compilable with all versions of gfortran starting at
4.9. All intel fortran compiler versions from 2011 onwards also
compile the stable code.

The development version can be compiled with gfortran-6 and later. All
other compilers tested have issues, and fail to produce a working
binary. This is the list of compilers tested:

* gfortran 4.8: critic2 cannot be compiled with this version because
  allocatable components in user-defined types are not supported.
* gfortran 4.9 through 5.4 (and possibly older and newer gfortran-5):
  the code compiles correctly but there are errors allocating and
  deallocating the global field array (`sy%f`) and other complex
  user-defined types. The program is usable, but problems will arise
  if more than one crystal structure or more than 10 scalar fields are
  loaded.
* gfortran 6.x, 7.x, 8.x: no errors.
* ifort, all versions from 12.1 up to 18.0.3: catastrophic internal
  compiler errors of unknown origin.
* Portland Group Fortran compiler (pgfortran), version 17.3. There are
  two important compiler problems: i) passing subroutines and
  functions whose interface includes multidimensional arrays as
  arguments or function results does not work, and ii) internal
  compiler error when compiling meshmod.f90.

In summary: **Only recent versions of gfortran are guaranteed to work
with the development version. If you cannot use gfortran 6 or newer,
download the stable version.** I do not think this is because of
errors in the critic2 code (though if you find that it is, please let
me know). If you paid for a recent version of your compiler and it
throws an internal compiler error while trying to build critic2, you
may want to consider submitting a bug report to the compiler
developers.

If a recent compiler is not available, an alternative is to compile
the program elsewhere with the static linking option:
~~~
LDFLAGS='-static -Wl,--whole-archive -lpthread -Wl,--no-whole-archive' ./configure ...
~~~
provided the machine has the same architecture. (The part between the
-Wl is there to prevent statically-linked gfortran executables from
segfaulting.) You can choose the compiler by changing the FC and F77
flags before configure:
~~~
FC=gfortran F77=gfortran ./configure ...
~~~

## External Libraries

### Libxc {#c2-libxc}

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
gradient. The `:g` field modifier is used to pass the gradient of the
first field as the second argument to `xc()`. The MOLCALC keyword
performs a numerical integration in a molecular mesh.

See the [manual](/critic2/manual/arithmetics/#libxc) for more
information.

### Libcint {#c2-libcint}

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
when critic2 is executed (for instance, through the `LD_LIBRARY_PATH`
environment variable).

The libcint library is used with molecular wavefunctions that provide
the basis set information (at present, this is only for fields read
from a Gaussian fchk file, but more will be implemented). The `mep()`,
`uslater()`, and `nheff()` chemical functions use the molecular
integrals calculated by libcint, as well as the `MOLCALC HF`
keyword. See the 
[chemical functions](/critic2/manual/arithmetics/#availchemfun) and the
[MOLCALC](/critic2/manual/misc/#c2-molcalc) sections of the manual.

### Libqhull

The qhull library calculates convex hulls, Delaunay triangulations,
Voronoi diagrams, and other geometry computations. In critic2, the
qhull library is used to calculate the Wigner-Seitz (WS) cell. The
lattice vectors that correspond to each of the WS faces are used in
critic2 to calculate the shortest lattice translation of a given
vector as well as in the YT integration method and other
tasks. 

Critic2 ships a static (and probably old) copy of qhull but if you
want to compile against your own, you can do so via configure:
~~~
./configure --with-qhull-inc=/usr/include/qhull/ --with-qhull-lib=/usr/lib/x86_64-linux-gnu
~~~
where the two directories are the location of the `libqhull.h` header
file (with-qhull-inc) and the `libqhull.so` library file
(with-qhull-lib). However, since critic2 uses qhull for very basic
calculations only, it is recommended that you use the critic2's
copy of the library.
