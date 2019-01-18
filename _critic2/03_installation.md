---
layout: single
classes: wide
title: "Critic2---Installation"
permalink: /critic2/installation/
excerpt: "Installation of the critic2 program."
sidebar:
  nav: "critic2"
---

Download the code [here](/critic2/).

If you downloaded the code from the git repository, you will need to run:
~~~
autoreconf
~~~
Prepare for compilation by doing:
~~~
./configure
~~~
Use `configure --help` for information about the
compilation options. The `--prefix` option sets the
installation path; more details about configure can be found in the
INSTALL file included in the distribution. Once critic2 is configured,
compile the program using:
~~~
make
~~~
This should create the critic2 executable inside the src/
subdirectory. The binary can be used directly (after setting the
`CRITIC_HOME` variable) or the entire critic2 distribution can be
installed to the "prefix" path by doing:
~~~
make install
~~~
Critic2 is parallelized for shared-memory architectures (unless
compiled with `--disable-openmp`). You change the number of
parallel threads by setting the `OMP_NUM_THREADS`
environment variable. Note that the parallelization flags for
compilers other than ifort and gfortran may not be correct.

In the case of ifort (and maybe other compilers), sometimes it may be
necessary to increase the stack size using, for instance:
~~~
export OMP_STACKSIZE=128M
~~~
This applies in particular to integrations using YT in large systems.

The environment variable `CRITIC_HOME` is necessary if critic2 was not
installed with 'make install'. It must point to the root directory of
the distribution:
~~~
export CRITIC_HOME=/home/alberto/programs/critic2dir
~~~
This variable is necessary for critic2 to find the atomic densities,
the cif dictionary, and other files. These should be in
${CRITIC_HOME}/dat/.

## Which compilers work?

Critic2 uses some features from the more modern Fortran standards,
which may not be available in some (most) compilers. In consequence,
not all compilers may be able to generate the binary and, even if they
do, it may be broken. Two versions of critic2 are distributed. The
**development** version, corresponding to the master branch of the
repository, and the **stable** version, in the stable branch. Only
patches addressing serious bugs will be introduced in the stable
version; all new development happens in the development version.  The
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
  deallocating the global field array (sy%f) and other complex
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
may want to consider submitting a bug report.

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

