---
layout: single
title: "Building from Source"
permalink: /critic2/installation/
excerpt: "Compiling and installing critic2 from its source code."
sidebar:
  - repo: "critic2"
    nav: "critic2"
toc: true
toc_label: "Building critic2"
toc_sticky: true
---

**Most users do not need to compile critic2.** Ready-to-run packages
for Windows, macOS, and Linux, including the graphical interface, are
on the [download page](/critic2/download/). Build critic2 from source
if you want the development version, need to tune it for a particular
machine (e.g. a computing cluster), or use a system for which there is
no package.

## Requirements

To build critic2, you will need:

* A [relatively modern](#whichcompilerswork) Fortran compiler.

* A C compiler (and a C++ compiler for the graphical interface).

* The [cmake](https://cmake.org/) build system and the make program.

* Optionally, a few [additional libraries](#c2-libraries).

These tools may already be available on your machine but, if they are
not, they can be typically installed using a software package
manager (`apt`, `dnf`, etc. on Linux; [homebrew](https://brew.sh/) on
macOS; [MSYS2](https://www.msys2.org/) on Windows).

## Build Using cmake {#c2-usecmake}

Change to the critic2 root directory and make a subdirectory for the
compilation:
~~~
mkdir build
cd build
~~~
Then do:
~~~
cmake ..
~~~
There are a number of compilation options that can be passed to cmake,
the most relevant of which is `-DCMAKE_INSTALL_PREFIX=prefix`, which
sets the installation directory. You can tweak this and other
compilation options using one of the multiple cmake interfaces, like
ccmake (use `ccmake ..` from the `build` directory). To build the
program, do:
~~~
make
~~~
You can use `make -j n` to use `n` cores for the compilation. Running
make creates the `critic2` binary in `build/src/`.

Some build options for advanced users: If you need to compile a static
version of critic2, use:
~~~
cmake .. -DBUILD_STATIC=ON
~~~
The binary generated using this option can be copied to a different
computer (with the same architecture), even if it does not have the
compiler libraries, but you will need static versions of all the
libraries (with extension `.a`) for the static build to work.
To compile a version with debug flags,
~~~
cmake .. -DCMAKE_BUILD_TYPE=Debug
~~~
This version gives more informative errors when the program crashes,
but it is slower.

## Installing and Setting up the Environment {#c2-install}

Critic2 can be installed to the `prefix` directory by doing:
~~~
make install
~~~
However, the binary can be used directly from the build directory by
setting the `CRITIC_HOME` environment variable. It must point to the
root directory of the distribution:
~~~
export CRITIC_HOME=/home/alberto/programs/critic2
~~~
This variable is necessary for critic2 to find the atomic densities
and other files. These files should be in `${CRITIC_HOME}/dat/`.
An installed critic2 finds its data files by itself, even if the
installation directory is moved somewhere else afterwards.

Critic2 is parallelized with OpenMP for shared-memory architectures
(unless disabled during compilation). You change the number of
parallel threads by setting the `OMP_NUM_THREADS` environment
variable.

## macOS {#c2-homebrew}

The [homebrew](https://brew.sh/) recipe for critic2 can compile the
current development version on your Mac:
~~~
brew install --HEAD aoterodelaroza/critic2/critic2
~~~
This installs the compilers and libraries critic2 needs and builds it
with the graphical interface (see the
[download page](/critic2/download/#c2-macos) for how to set up
homebrew). To rebuild it later with the latest version of the code,
use `brew upgrade --fetch-HEAD critic2`. Alternatively, install the compilers
(`brew install gcc cmake`) and the optional libraries with homebrew and
build critic2 with cmake as indicated above.

## Windows {#c2-windows}

The Windows packages are cross-compiled from Linux with the MinGW-w64
compilers. The procedure, including a script that downloads and builds
all the dependencies, is in the "Windows builds" section of the
`INSTALL` file in the critic2 distribution. Critic2 can also be built
natively in an [MSYS2](https://www.msys2.org/) UCRT64 shell with cmake,
as on Linux.

## Which Compilers Work? {#whichcompilerswork}

Critic2 uses features from the modern Fortran standards (2008 and
later) that are not correctly implemented in some compilers. The
current version can be compiled with gfortran 6 and later and with
Intel Fortran (ifort 2019 or later, and ifx). Some recent versions of
Intel Fortran may cause problems if aggressive optimization is used.
Other compilers (older gfortran and ifort, the Portland Group
compiler, ...) fail to produce a working binary. If your compiler
throws an internal compiler error while trying to build critic2, you
may want to consider submitting a bug report to the compiler
developers.

You can choose the compiler by setting the FC and CC environment
variables to the path of your preferred compiler and then building in
the usual way:
~~~
export FC=/usr/bin/gfortran-14 CC=/usr/bin/gcc-14
mkdir build
cd build
cmake ..
~~~
Once cmake generates the cache variables, the variables need not be
set again, unless you delete the build directory.

## Graphical User Interface {#c2-gui}

To build the critic2 graphical user interface, use:
~~~
cmake -DENABLE_GUI=ON ..
~~~
and then compile as indicated above. Compiling the GUI requires the
[GLFW library](https://www.glfw.org/) and, optionally, also the
[freetype library](http://freetype.org/) if you want the fonts to look
nice. On Linux, you can typically get both of them from the software
repository.

Once compiled, the GUI will be enabled in the generated `critic2`
binary. You can open any number of files with the GUI using:
~~~
critic2 -g *.*
~~~
See the [download page](/critic2/download/#c2-gui) for some notes on
using the graphical interface, including how to change its size on
HiDPI displays.

## External Libraries {#c2-libraries}

### Readline {#c2-readline}

When critic2 is built using cmake, it is possible to link against the
readline library. This library enables shell-like features for
critic2's command line interface such as keyboard shortcuts, history,
and autocompletion. On linux, you can typically find it in the
repository of your chosen distribution.

### NLOPT {#c2-nlopt}

[NLOPT](https://github.com/stevengj/nlopt) is a library implementing
many local and global optimization algorithms. This library is used by
the [COMPAREVC](/critic2/manual/structure/#c2-comparevc) keyword,
which compares either two crystal structures or a structure and a
diffraction patterns allowing for cell deformations. On linux, you can
typically find it in the repository of your chosen distribution. To
use a non-standard installation directory, make the
`NLOPT_INCLUDE_DIRS` variable point to the NLOPT include directory
(where the `nlopt.f` file can be found) and `NLOPT_LIBRARIES` point to
the location of the shared library:
~~~
cmake -DNLOPT_INCLUDE_DIRS=/usr/include/ \
      -DNLOPT_LIBRARIES=/usr/lib/x86_64-linux-gnu/libnlopt.so ..
~~~

### Libxc {#c2-libxc}

[Libxc](https://gitlab.com/libxc/libxc) is a library that implements
exchange-correlation energies and potentials for many semilocal
functionals (LDA, GGA and meta-GGA). In critic2, it is used to
calculate exchange and correlation energy densities via de `xc()`
arithmetic expressions. Critic2 is not compatible with
versions of libxc older than 5.0.

If you compile using cmake, libxc should be found automatically by the
build system if it installed in a standard location. Otherwise, you
can indicate the location of the include directory with the
`LIBXC_INCLUDE_DIRS` variable and the location of the `libxc.so` and
`libxcf03.so` with the `LIBXC_xc_LIBRARY` and `LIBXC_xcf03_LIBRARY`
variables, respectively. For instance:
~~~
cmake -DLIBXC_INCLUDE_DIRS=/usr/include \
      -DLIBXC_xc_LIBRARY=/usr/lib/x86_64-linux-gnu/libxc.so \
      -DLIBXC_xcf03_LIBRARY=/usr/lib/x86_64-linux-gnu/libxcf03.so ..
~~~

The libxc library is used in critic2 to create new scalar fields from
the exchange and correlation energy density definitions in the library
using a density, gradient, or kinetic energy density already available
to critic2 as a scalar field. See the
[manual](/critic2/manual/arithmetics/#libxc) for more information.

### Libcint {#c2-libcint}

[Libcint](https://github.com/sunqm/libcint) is a library for
calculating molecular integrals between Gaussian-Type Orbitals
(GTOs). In critic2, this library is used mostly for testing but some
options to the `MOLCALC` keyword and some functions in arithmetic
expressions require it (e.g. the molecular electrostatic potential, `mep`).

To build critic2 with libcint support, you need to indicate the
directory where the include directory (`LIBCINT_INCLUDE_DIRS`) and the
location of the library file (`LIBCINT_LIBRARY`). For instance:
~~~
cmake -DLIBCINT_INCLUDE_DIRS=/home/alberto/git/libcint/build/include/ \
      -DLIBCINT_LIBRARY=/home/alberto/git/libcint/build/libcint.a ..
~~~
The shared library (`libcint.so`) can be also used.

See the [chemical
functions](/critic2/manual/arithmetics/#availchemfun) and the
[MOLCALC](/critic2/manual/misc/#c2-molcalc) sections of the manual for
usage.

### tblite {#c2-tblite}

[tblite](https://github.com/tblite/tblite) is a library implementing
the GFN-xTB family of semiempirical tight-binding methods. In critic2,
it provides the `gfn2` (GFN2-xTB) and `gfn1` (GFN1-xTB) energies,
forces, and stresses used for geometry relaxation
([EDIT RELAX](/critic2/manual/structure/#c2-edit)), molecular-dynamics
sampling ([WRITE BULK MD](/critic2/manual/write/#c2-writebulk)), and
the interactive dynamics window of the graphical user interface. This
library is optional; if critic2 is built without it, these two methods
are simply unavailable.

To build critic2 with tblite support, compile it and install it (its
meson build installs a `tblite.pc` pkg-config file) and then configure
critic2. `USE_TBLITE` defaults to ON if the library is found at
configure time, so usually nothing has to be passed; give
`-DUSE_TBLITE=OFF` to build without it even when it is installed, or
`-DUSE_TBLITE=ON` to make the build fail loudly if it cannot be found:
~~~
cmake -DUSE_TBLITE=ON ..
~~~
The build system locates the library through pkg-config
(`tblite.pc` on your `PKG_CONFIG_PATH`) or the `TBLITE_DIR` environment
variable. If it is installed in a non-standard location, you can point
critic2 at it directly with the `TBLITE_INCLUDE_DIRS` and
`TBLITE_LIBRARIES` variables:
~~~
cmake -DUSE_TBLITE=ON \
      -DTBLITE_INCLUDE_DIRS=/home/user/git/tblite/_install/include \
      -DTBLITE_LIBRARIES=/home/user/git/tblite/_install/lib/libtblite.so ..
~~~

### xtb {#c2-xtb}

[xtb](https://github.com/grimme-lab/xtb) is the semiempirical extended
tight-binding program package from the Grimme group. In critic2, its
library is used to provide the `gfnff` (GFN-FF) general force field for
energies and forces of **molecules** (see the
[force fields](/critic2/manual/structure/#c2-forcefields) section for
why crystals are excluded), available in the same places as the
tblite methods above
([EDIT RELAX](/critic2/manual/structure/#c2-edit),
[WRITE BULK MD](/critic2/manual/write/#c2-writebulk), and the
interactive dynamics GUI window). This library is optional; without it,
the `gfnff` force field is unavailable.

To build critic2 with xtb support, compile and install xtb (its build
installs an `xtb.pc` pkg-config file) and then configure critic2. As
with tblite, `USE_XTB` defaults to ON if the library is found at
configure time; on Debian and derivatives, installing the `libxtb-dev`
package is enough. Pass `-DUSE_XTB=OFF` to build without it:
~~~
cmake -DUSE_XTB=ON ..
~~~
As with tblite, the library is found through pkg-config (`xtb.pc`) or
the `XTB_DIR` environment variable, and a non-standard installation can
be pointed to directly with the `XTB_INCLUDE_DIRS` and `XTB_LIBRARIES`
variables:
~~~
cmake -DUSE_XTB=ON \
      -DXTB_INCLUDE_DIRS=/home/user/git/xtb/_install/include \
      -DXTB_LIBRARIES=/home/user/git/xtb/_install/lib/libxtb.so ..
~~~

