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

To build critic2, you will need:

* A [relatively modern](#whichcompilerswork) Fortran compiler.

* A C compiler.

* The [cmake](#c2-usecmake) build system.

* The make program.

* Optionally, a few [additional libraries](#c2-libraries).

These tools may already be available on your machine but, if they are
not, they can be typically installed using a software package
manager (`apt`, `rpm`, etc. on Linux; [homebrew](https://brew.sh/) on macOS).

### Build Using cmake {#c2-usecmake}

Using cmake is the recommended installation procedure, and the only
way to build critic2 in recent versions. Change to the critic2 root
directory and make a subdirectory for the compilation:
~~~
mkdir build
cd build
~~~
Then do:
~~~
cmake ..
~~~
There are a number of
compilation options that can be passed to cmake, the most relevant of
which is `-DCMAKE_INSTALL_PREFIX=prefix`, which sets the installation
directory. You can tweak this and other compilation options using one
of the multiple cmake interfaces, like ccmake (use `ccmake ..` from
the `build` directory). To compile a static version of critic2, use:
~~~
cmake .. -DBUILD_STATIC=ON
~~~
This version can be copied to a different computer (with the same
architecture), even if it does not have the compiler libraries. To
compile a version with debug flags,
~~~
cmake .. -DCMAKE_BUILD_TYPE=Debug
~~~
This version gives more informative errors when the program crashes.

To build the program, do:
~~~
make
~~~
You can use `make -j n` to use `n` cores for the compilation. Running
make creates the `critic2` binary in `build/src/`.

### Build Using configure/make {#c2-useconfigure}

**These instructions only apply to old versions of critic2; the
configure/make build system has been removed from the development
version.** You need to run:
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
subdirectory.

### Installing and Setting up the Environment

Critic2 can be installed to the `prefix` directory by doing:
~~~
make install
~~~
However, the binary can be used directly from the source directory by
setting the `CRITIC_HOME` environment variable. It must point to the
root directory of the distribution:
~~~
export CRITIC_HOME=/home/alberto/programs/critic2dir
~~~
This variable is necessary for critic2 to find the atomic densities
and other files. These files should be in `${CRITIC_HOME}/dat/`.

Critic2 is parallelized with OpenMP for shared-memory architectures
(unless disabled during compilation). You change the number of
parallel threads by setting the `OMP_NUM_THREADS` environment
variable. Note that the parallelization flags for compilers other than
ifort and gfortran may not be correct.

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
4.9. All Intel fortran compiler versions from 2011 onwards also
compile the stable code.

The development version can be compiled with gfortran-6 and later and
with Intel fortran 2019 and later, although some recent versions of
Intel fortran may cause problems if aggressive optimization is
used. All other compilers tested have issues, and fail to produce a
working binary. This is the list of compilers tested:

* gfortran 4.8: critic2 cannot be compiled because allocatable
  components in user-defined types are not supported in this and older
  versions.
* gfortran 4.9 through 5.4 (and possibly older and newer gfortran-5):
  the code compiles correctly but there are errors allocating and
  deallocating the global field array (`sy%f`) and other complex
  user-defined types. The program is usable, but problems will arise
  if more than one crystal structure or more than 10 scalar fields are
  loaded.
* gfortran 6.x and above: no errors.
* ifort, all versions from 12.1 up to 18.0.3: catastrophic internal
  compiler errors of unknown origin.
* ifort, version 2019.0.3.199: it compiles but inexplicable segmentation
  faults with nonsensical tracebacks are thrown when using YT or
  BADER and when loading and unloading fields.
* ifort, version 2019.0.5.281: if aggressive optimization is used (`-O2`
  and `-O3` flags), the compiler may freeze while compiling
  `systemmod@proc.f90`.
* Portland Group Fortran compiler (pgfortran), version 17.3. There are
  two important compiler problems: i) passing subroutines and
  functions whose interface includes multidimensional arrays as
  arguments or function results does not work, and ii) internal
  compiler error when compiling meshmod.f90.

In summary: **Only recent versions of gfortran and ifort are
guaranteed to work with the development version. If you cannot use
gfortran 6 or newer or ifort 2019 or newer, download the stable
version.** I do not think this is because of errors in the critic2
code (though if you find that it is, please let me know). If you paid
for a recent version of your compiler and it throws an internal
compiler error while trying to build critic2, you may want to consider
submitting a bug report to the compiler developers.

You can choose the compiler by setting the FC and CC environment
variables to the path of your preferred compiler and then building in
the usual way:
~~~
export FC=/usr/bin/gfortran-6 CC=/usr/bin/gcc-6
mkdir build
cd build
cmake ..
~~~
Once camke generates the cache variables, the variables need not be
set again, unless you delete the build directory.

## External Libraries {#c2-libraries}

### Readline {#c2-readline}

When critic2 is built using cmake, it is possible to link against the
readline library. This library enables shell-like features for
critic2's command line interface such as keyboard shortcuts, history,
and autocompletion.

### Libxc {#c2-libxc}

[Libxc](https://gitlab.com/libxc/libxc) is a library that implements
exchange-correlation energies and potentials for many semilocal
functionals (LDA, GGA and meta-GGA). In critic2, it is used to
calculate exchange and correlation energy densities via de `xc()`
arithmetic expressions (see below). The code in critic2 is not
compatible with versions of libxc older than 5.0.

If compiling with autoconf/automake, to compile critic2 with libxc
support, you must pass the location of the library via `configure`:

    ./configure --with-libxc=/opt/libxc

where `/opt/libxc/` is the directory that was the target for the libxc
installation (i.e. you used `--prefix=/opt/libxc` when you configured
the libxc library). If you use cmake, you can indicate the location of
the include dir with the `LIBXC_INCLUDE_DIRS` variable and the
location of the `libxc.so` and `libxcf90.so` with the
`LIBXC_xc_LIBRARY` and `LIBXC_xcf90_LIBRARY` variables.

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
expressions require it.

If you are using autoconf/automake, compile critic2 with libcint
support by doing either of:
~~~
./configure --with-cint-shared=/opt/libcint/lib
./configure --with-cint-static=/opt/libcint/lib
~~~
where `/opt/libcint/lib` is the location of the libcint static (`.a`)
or shared (`.so`) libraries prefix where libcint was installed.  If
compiled with the shared option, the same path needs to be available
when critic2 is executed (for instance, through the `LD_LIBRARY_PATH`
environment variable). If using CMAKE, you need to indicate the
directory where the includes (`LIBCINT_INCLUDE_DIRS`) and the library
(`LIBCINT_LIBRARY`) reside.

The libcint library is used with molecular wavefunctions that provide
the basis set information (at present, this is only for fields read
from a Gaussian-style fchk file, but more will be implemented). The `mep()`,
`uslater()`, and `nheff()` chemical functions use the molecular
integrals calculated by libcint, as well as the `MOLCALC HF`
keyword. See the
[chemical functions](/critic2/manual/arithmetics/#availchemfun) and the
[MOLCALC](/critic2/manual/misc/#c2-molcalc) sections of the manual.
