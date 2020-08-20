---
layout: single
title: "Installation"
permalink: /gibbs2/installation/
excerpt: "Installation of the gibbs2 program."
sidebar:
  - repo: "gibbs2"
    nav: "gibbs2" 
toc: true
toc_label: "Installation of gibbs2"
toc_sticky: true
---

## Using cmake

The easiest way to compile gibbs2 is by using cmake. Change to the
gibbs2 root directory and make a subdirectory for the compilation:
~~~
mkdir build
cd build
~~~
Then do:
~~~
cmake ..
make
~~~
This creates the binary in `build/src/gibbs2`. You can copy this
binary to a location in your PATH or create a symlink. 

You can tweak the compilation options using one of the multiple cmake
interfaces, like ccmake (use `ccmake ..` from the `build`
directory). To compile a static version of gibbs2, use:
~~~
cmake .. -DBUILD_STATIC=ON
~~~
This version can be copied to a different computer (with the same
architecture), even if it does not have the compiler libraries.  To
compile a version with debug flags,
~~~
cmake .. -DCMAKE_BUILD_TYPE=Debug
~~~
This version gives more informative errors when a bug is found.

## Using make

Alternatively, you can compile the program using the provided
`Makefile` in the source directory. To do this, enter the `src/`
directory and edit the `Makefile.inc` file. This file is included in the
actual Makefile and contains the description of the compiler and its
options. By default, the GNU fortran compiler (gfortran) is
used. Uncomment the sections of the `Makefile.inc` file corresponding
to your compiler (or create your own):
~~~
# The GNU fortran compiler (gfortran)
ifeq ($(DEBUG),1)
  FC = gfortran
  FCFLAGS = -g -fbounds-check -Wall -Wunused-parameter -ffpe-trap=invalid -fbacktrace -fdump-core
  LDFLAGS = 
  AR = ar
  EXE =
else
  FC = gfortran
  FCFLAGS = -O3
  LDFLAGS = 
  AR = ar
  EXE =
endif
~~~
The variable `FC` is the name of the fortran90 compiler, `FCFLAGS` are
the compiler flags and `LDFLAGS` are the linker flags. (The first part
of the `ifeq` corresponds to the debug compilation.)

Once the `Makefile.inc` is ready, compile gibbs2 using:
~~~
make
~~~
This generates a `gibbs2` binary in `src/` that can be moved into a
PATH location or symlinked. To compile the debug version, do:
~~~
make debug
~~~
The name of the debug binary file is `gibbs2_dbg`. Other make options
are:
~~~
make clean
make veryclean
make mrproper
~~~
These remove the objects (`clean`), objects and static libraries
(`veryclean`) and objects, libraries and binaries (`mrproper`).

