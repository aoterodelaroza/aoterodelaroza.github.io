---
layout: single
title: "Writing Makefiles for Modern Fortran"
permalink: /devnotes/modern-fortran-makefiles/
excerpt: "Notes on how to write Makefiles for (modern) fortran programs. Modules, submodules, and automatic dependency generation."
class: wide
sidebar:
  - nav: "devnotes" 
toc: true
toc_label: "Fortran Makefiles"
toc_sticky: true
---

These notes show how to write portable Makefiles for large modern
Fortran (2018 standard) programs. 

*tl;dr Put the [Makefile](/assets/devnotes/02_fortran_makefiles/Makefile)
and the [dependency generator](/assets/devnotes/02_fortran_makefiles/makedepf08.awk)
in the root of your project. Run `make`.*

With a few restrictions, this solution permits:

- Fully automatic dependency generation.

- Parallelization using with make's `-j` or `-l` command-line options.

- Using modules, submodules, and includes with arbitrary dependencies
  among them, even across different subdirectories in the project
  tree.

- Packing more than one module and submodule inside the same file.

- Nested includes. Includes that include modules and submodules.

## On modules and headaches

Fortran submodules were introduced in the 2008 Fortran standard and
only recently implemented in modern Fortran compilers (this is early
2019, `gfortran` has had them for a long time and `ifort` has only
recently fixed important submodule-related bugs). The two ideas behind
submodules are: i) separate the interface of a module from its
implementation, and ii) prevent circular dependencies between
modules. 

Consider module `one` contained in source file `one.f90`:
~~~ fortran
module onemod
  implicit none
contains
  subroutine addone(msg,n)
    character(len=:), allocatable, intent(inout) :: msg
    integer, intent(inout) :: n

    msg = msg // "1"
    if (n > 1) then
       n = n - 1
    end if
  end subroutine addone
end module onemod
~~~
This is straightforward: Module `onemod` defines subroutine
`addone`. When other parts of the program use `onemod`, the routine
`addone` is available to them through host association. When `one.f90`
is compiled, it generates a file containing the interface of the
module. In all Fortran compilers I have access to (sadly, the list is
pretty short: `gfortran` and `ifort`), this interface file has the
name of the module and extension `.mod` (`onemod.mod` in this
case). The catch is that the `onemod.mod` file must be available to
all the other subprograms that use that module. Therefore the module
must be compiled before them. 

Now consider what happens if we make a change to the
module. Recompilation of the source changes the `.mod` file and all
other files that use it must be recompiled as well. However, the
change may affect the internals of the `addone` routine only and leave
the interface unchanged, so there may be no need to recompile the
dependant files. In large projects, this causes painful compilation
cascades whenever you need to work on a module that is very basic to
the program.

The second problem with modules are circular dependencies. Consider
that we now have two modules with subroutines that call each other:
~~~ fortran
module onemod
  implicit none
contains
  recursive subroutine addone(msg,n)
    use twomod, only: addtwo
    character(len=:), allocatable, intent(inout) :: msg
    integer, intent(inout) :: n

    msg = msg // "1"
    if (n > 1) then
       n = n - 1
       call addtwo(msg,n)
    end if
  end subroutine addone
end module onemod

module twomod
  implicit none
contains
  recursive subroutine addtwo(msg,n)
    use onemod, only: addone
    character(len=:), allocatable, intent(inout) :: msg
    integer, intent(inout) :: n

    msg = msg // "2"
    if (n > 1) then
       n = n - 1
       call addone(msg,n)
    end if
  end subroutine addtwo
end module twomod
~~~
It is not possible to compile this code as-is. Trying to
compile `two.f90` fails (missing `onemod.mod`) and the same thing
happens if you compile `one.f90` (missing `twomod.mod`). However, this
should not be the case because it is the implementation of both
routines that use the other module, not the interface, so there is no
reason why this should not be possible.

## Introducing submodules

To address these two issues, *submodules* were introduced in the 2008
Fortran standard. Submodules are designed to contain the
implementation of the routines whose interface is in the module
itself. For instance, in the example above, we would split `one.f90`
into two files: a module containing the interface (`one.f90`) and a
submodule of that module containing the implementation of the `addone`
routine (I tend to use `@proc` for the submodules, for no particular
reason, so that would be `one@proc.f90`). The module is:
~~~ fortran
module onemod
  implicit none
  interface
     recursive module subroutine addone(msg,n)
       character(len=:), allocatable, intent(inout) :: msg
       integer, intent(inout) :: n
     end subroutine addone
  end interface
end module onemod
~~~
and the submodule:
~~~ fortran
submodule (twomod) twoproc
  implicit none
contains
  recursive module subroutine addtwo(msg,n)
    use onemod, only: addone
    character(len=:), allocatable, intent(inout) :: msg
    integer, intent(inout) :: n

    msg = msg // "2"
    if (n > 1) then
       n = n - 1
       call addone(msg,n)
    end if
  end subroutine addtwo
end submodule twoproc
~~~
Only the module file generates the `.mod` file necessary to compile
all the dependencies and so changes to the implementation in the
submodule do not trigger a compilation cascade. Furthermore, routines
in the submodule can use whatever module is available as long as the
parent module of the submodule is not used in its interface. In this
case, the `two` submodule can use `addone` from the `onemod` module
and likewise the `one` submodule can use `addtwo` from the `twomod`
module. 

How does the compilation of submodules work? In this example,
compilation of the module file (`one.f90`) generates two files: the
module interface `onemod.mod` and the submodule interface
`onemod.smod`. As before, the `.mod` file is required to compile any
code that uses the module. The `.smod` file is required to compile all
submodules whose parent is `onemod`. Therefore, first we compile the
modules:
~~~
gfortran -c one.f90
gfortran -c two.f90
~~~
which do not have any requirements because they do not use anyone
else. On top of the object files, this generates the module interface
files (`onemod.mod` and `twomod.mod`) and the submodule interface
files (`onemod.smod` and `twomod.smod`). (Fun fact: `onemod.mod` and
`onemod.smod` are the gzip packages that are exactly equal byte by
byte, at least with `gfortran`.) Once we have these prerequisite
files, we compile the children submodules:
~~~
gfortran -c one@proc.f90
gfortran -c two@proc.f90
~~~
And, if we have a main program file that looks like this:
~~~ fortran
program main
  use onemod, only: addone
  implicit none
  character(len=:), allocatable :: msg
  integer :: n

  msg = "hello, world! "
  n = 10
  call addone(msg,n)
  write (*,*) msg
end program main
~~~
then we can compile it and link it because its module prerequisite
(`onemod.mod`) has already been generated:
~~~
gfortran -c main.f90
gfortran -o main main.o two.o two@proc.o one.o one@proc.o
~~~
To make matters worse, submodules can depend on other submodules,
which makes writing the Makefile rules a bit tricky. Let us
start with a simple example.

## A simple Makefile for a simple program

For now, let us make the simplifying assumption that file names and
module/submodule names coincide, so we rename the modules names from
`onemod` to `one` and from `twomod` to `two`. A simple Makefile that
compiles this program begins with the usual things: a compiler, the
program target and linking recipe, and the `clean` phony target.
~~~ make
.SUFFIXES:
FC=gfortran
COMPILE.f08 = $(FC) $(FCFLAGS) $(TARGET_ARCH) -c

SOURCES=main.f90 one.f90 one@proc.f90 two.f90 two@proc.f90

main: $(subst .f90,.o,$(SOURCES))
	$(FC) -o $@ $+

.PHONY: clean
clean:
	-rm -f *.o *.mod *.smod main
~~~
The first line serves to deactivate all implicit rules. `.mod` files
are implicitly understood by make to be modula-2 source files, which
can occasionally lead to confusing errors when it tries to generate an
object file from a `.mod` file using `m2c`.

The object, module, and submodule files are all created or updated by
compiling the source. Depending on the compiler version, if the module
or submodule file already exists its date may or may not change if
the interface does not change. Therefore, to prevent any problems with
`make`, we touch the target at the end of the rule to make sure its date
is set correctly. Since we assumed that the module and submodule names
are the same as the file name of the source, the compilation is easily
handled by three pattern rules:
~~~ make
%.o %.mod %.smod: %.f90
	$(COMPILE.f08) -o $*.o $<
	@touch $@
~~~

To complete the makefile, we need to establish the dependencies
between objects, module, and submodule files. We do this by adding to
the above recipe the pre-requisites discussed in the previous
section. Specifically:
1. Creating the object file `target.o` requires having the `.mod`
   files of all the module it uses. If the source corresponds to a
   module, then the `target.mod` file also depends on the used
   `.mod`. Furthermore, if the source corresponds to a module or
   submodule that is a parent to another submodule, then the
   `target.smod` also depends on the `.mod` file of the used module.
   In our case, only three files use modules: `main.f90` (uses `one`),
   `one@proc.f90` (uses `two`), and `two@proc.f90` (uses
   `one`), and none of them are modules or parents of
   submodules. Therefore, the additional rules are:
~~~ make
main.o: one.mod
one@proc.o: two.mod
two@proc.o: one.mod
~~~

2. Creating the `target.o` of a submodule depends on the `.smod` of
   the parent module or submodule. In addition, if the `target`
   submodule is itself a parent to another submodule, then the
   corresponding `target.smod` also depends on the `.smod` of the
   parent. In our case, we have two submodules: `one@proc.f90` and
   `two@proc.f90` whose parents are `one.f90` and `two.f90`,
   respectively. None of the two submodules have children, therefore
   the additional prerequisites are simply:
~~~ make
one@proc.o: one.smod
two@proc.o: two.smod
~~~

Example package: [example-01.tar.xz](/assets/devnotes/02_fortran_makefiles/example-01.tar.xz).

## Separating compilation from .mod and .smod generation

The previous Makefile works, but one thing that needs to be improved
is how it handles parallelization. `make` has the option of using more
than one thread to carry out the build if the dependency graph
branches out. To do this, we use the command-line options `-j` or
(more rarely) `-l`. The command:
~~~
make -j 2
~~~
runs `make` with at most two threads. Parallelized builds are
important in large programs where a single build from scratch can
from minutes to hours.

Although our last example works with `make -j` (i.e. it has no race
conditions), it was not parallelizable. The most usual layout of a
large fortran program is a sequence of module file dependencies that
implement from complex to simple tasks. Module A implements the
highest-level routines and depends on module B, module B on module C,
C on D, and so on. With our previous Makefile, compiling a program
laid out like this would require following this chain of modules
backwards one by one, which would preclude any parallelization.

An elegant solution to this problem was proposed by Dr. Joost
VandeVondele: separate the compilation step from the generation of the
`.mod` and `.smod` files. The idea is to run make in two passes. In a
first pass, we generate all the `.mod` and `.smod` files using a
special compiler flag that generates the interfaces but not the object
file. This flag is `-fsyntax-only` in `gfortran` and `-syntax-only` in
`ifort`. In the second pass, we compile the object file from the
source as usual. The first pass is quick and cheap, and it is the
second pass that takes most of the time. The dependencies between
different sources are handled in the first pass so that, when we start
the second pass, all necessary `.mod` and `.smod` files have been
generated and we can take full advantage of `make`'s parallelization.

To generate the `.mod` and `.smod` files in the first pass, we define
the `MAKEMOD.f08` variable, where we use the syntax-only flag:
~~~ make
MAKEMOD.f08 = $(FC) $(FCFLAGS) $(TARGET_ARCH) -fsyntax-only -c
~~~
Now we introduce the two rules: (slow) compilation and (fast)
`.mod` and `.smod` file generation:
~~~ make
%.o: %.f90
        $(COMPILE.f08) -o $*.o $(<:.mod=.f90)
        @touch $@

%.smod %.mod: %.f90
        $(MAKEMOD.f08) $<
~~~
And the prerequisites are the same as before:
~~~ make
main.o: one.mod
one@proc.o: two.mod
two@proc.o: one.mod

one@proc.o: one.smod
two@proc.o: two.smod
~~~
This approach, however, fails. The resulting Makefile does work in
single-thread mode but when trying to use it with `-j 2` it gives the
following error:
~~~
gfortran   -fsyntax-only -c one.f90
gfortran   -c -o one.o one.f90
f951: Fatal Error: Can't rename module file ‘one.mod0’ to ‘one.mod’: No such file or directory
compilation terminated.
~~~
You can see that the error is the result of a race condition: `make`
used the first-stage and the second-stage step on the same source
file, and the two threads stepped on each other's toes.

## Anchor files

To solve this problem, we introduce the concept of an *anchor file*,
with extension `.anc`. Each `.f90` source file has a corresponding
anchor file with the same name. The anchor file is an empty file whose
sole purpose is to manage the dependencies in which the source file is
involved. A given source file can generate zero, one or more `.mod`
files and zero, one, or more `.smod` files. All these files are
generated at the same time using the `MAKEMOD` command. To signify
that all the `.mod` and `.smod` files have been generated correctly,
the anchor file is touched right after `MAKEMOD` has finished:
~~~ make
%.anc: %.f90
	$(MAKEMOD.f08) $<
	@touch $@
~~~
Then, the anchor file is made dependant on all module and submodule
files generated by the source file with the same name:
~~~ make
one.anc: one.mod one.smod
two.anc: two.mod two.smod
one.mod one.smod two.mod two.smod:
~~~
Note the empty rules at the end to prevent Makefile from crashing with
a "no rule to make target" error if the `.mod` or `.smod` files are
missing. This rule and these dependencies ensure that if an anchor
file is up to date, then so are all the `.mod` and `.smod` files
generated by the corresponding source file. Therefore, a target that
has any of these `.mod` or `.smod` files as dependencies can be
satisfied as well by listing the associated anchor file as
prerequisite. This is far simpler in practice because the only
information we need to build these rules is which files compile first,
instead of the particular `.mod` and `.smod` files that we need
from them.

In our example, the dependency rules are transformed into:
~~~ make
main.anc: one.anc
one@proc.anc: two.anc
two@proc.anc: one.anc

one@proc.anc: one.anc
two@proc.anc: two.anc
~~~
The first block comes from use statements in `main.f90`,
`one@proc.f90`, and `two@proc.anc`, which  require the `.mod` file. 
The second block comes from the
module-submodule relations, and refer to the use of the corresponding
`.smod` files.

By using anchor-to-anchor dependency rules, we ensure that an up to
date anchor file for a given source file implies that all `.mod` and
`.smod` files necessary to compile it are present and
current. Therefore, the compilation step can be handled by a simple
pattern rule:
~~~ make
%.o: %.anc
	$(COMPILE.f08) -o $*.o $(<:.anc=.f90)
	@touch $@
~~~
where we take advantage of the fact that the anchor file, object, and
source file share the same name. Note that in the case of files that
generate no `.mod` or `.smod` files, the syntax-only `MAKEMOD` command
is still run in order to create the anchor file. This is a small price
to pay for keeping things organized.

The complete Makefile is:
~~~ make
.SUFFIXES: 

FC=gfortran
COMPILE.f08 = $(FC) $(FCFLAGS) $(TARGET_ARCH) -c
MAKEMOD.f08 = $(FC) $(FCFLAGS) $(TARGET_ARCH) -fsyntax-only -c

SOURCES=main.f90 one.f90 one@proc.f90 two.f90 two@proc.f90

main: $(subst .f90,.o,$(SOURCES))
	$(FC) -o $@ $+

.PHONY: clean
clean:
	-rm -f *.o *.mod *.smod *.anc main 

%.anc: %.f90
	$(MAKEMOD.f08) $<
	@touch $@

%.o: %.anc
	$(COMPILE.f08) -o $*.o $(<:.anc=.f90)
	@touch $@

main.anc: one.anc
one@proc.anc: two.anc
two@proc.anc: one.anc

one@proc.anc: one.anc
two@proc.anc: two.anc

one.anc: one.mod one.smod
two.anc: two.mod two.smod
one.mod one.smod two.mod two.smod:
~~~
Note that we have also modified the `clean` recipe to delete the
anchor files.

There is one final consideration to make. When the syntax-only
compilation of a file happens, the associated `.mod` and `.smod` files
are generated. When the normal compilation happens, these files are
*also* generated in addition to the object file. Therefore, there is
the question of whether a recipe for generating an object file, which
also writes `.mod` and `.smod` files, and a recipe for reading those
same files that are being generated will enter a race condition if
`make` is used in parallel mode. With `gfortran`, this is not a
problem because it looks like the `.mod` and `.smod` files are not
updated if they have been generated in a previous syntax-only
compilation (which they always are). In `ifort`, this seems not to be
the case. However, in `ifort` it is possible to separate the directory
from where the `.mod` and `.smod` files are only read (`-I`) and the
directory where they are read and written (`-module`). Setting the
latter to a scratch directory in the compilation step should solve
this problem. For now, we will use `gfortran` for simplicity but the
final proposed Makefile takes this into account.

Example package: [example-02.tar.xz](/assets/devnotes/02_fortran_makefiles/example-02.tar.xz).

## Include files

Anchor files can also be used to introduce dependencies based on
Fortran's `INCLUDE` keyword. At almost any point in a Fortran source
an `INCLUDE` can be inserted:
~~~ fortran
include "file.inc"
~~~
This replaces the `INCLUDE` line with the contents of the
referenced file. 

The dependency rules in the Makefile for an included file can be
straightforwardly implemented by making the anchor of the parent file
depend on the included file:
~~~ make
parent.anc: included.inc
~~~
If the included file contains module or submodule definitions or use
statements, then all the dependencies those would generate are
assigned to the anchor file of the source where the file is included
as if the included file were embedded in it (which, eventually, it
is).

For instance, in our `one@proc.f90` submodule we move the
implementation of the `addone` subroutine to a `one_addone.inc` and
replace the submodule with:
~~~ fortran
submodule (one) oneproc
  implicit none
contains
  include "one_addone.inc"
end submodule oneproc
~~~

The Makefile would still have the prerequisite associated to the fact
that the `addone` routine uses the `two` module:
~~~ make
one@proc.anc: two.anc
~~~
despite the `USE` statement now being in the included file. The only
additional change to the Makefile would be adding:
~~~ make
one@proc.anc: one_addone.inc
~~~
to update the anchor file in case the included file changes.

Example package: [example-03.tar.xz](/assets/devnotes/02_fortran_makefiles/example-03.tar.xz).

## Compiling across directories and hiding .mod files

If a project is large enough chances are the developers will want to
keep parts of the source in different directories. Sometimes these
directories generate a library or a program on their own, but in
general individual modules living in different directories may use
each other. Since recursive `make` has somewhat bad press and also has
a few limitations regarding dependencies between directories, it is
interesting to consider the case of building a project with source
files dispersed across subdirectories.

To keep things simple, we will use our previous example and create two
directories: `one/` and `two/`. Directory `one/` contains `one.f90`,
`one@proc.f90`, and the include file `one_addone.inc`. Directory
`two/` contains `two.f90` and `two@proc.f90`. The program block in the
`main.f90` file stays in the root directory.

The first question is: if we compile one of the files inside a
subdirectory from the root of the directory tree, where will the
generated files pop up? In the case of object files, they will be
created where we tell the compiler via the `-o` option and they have
the same name as the source, so that one is easy. The `.mod` and
`.smod` files, however, are more tricky. Since module and submodule
files must be unique in a single build (otherwise the build would
fail) it makes sense to centralize all the `.mod` and `.smod` files in
the same directory, preferably hidden from view to avoid the clutter.
We define a variable for this location and make sure that the
directory is created:
~~~ make
MODDIR := .mod
ifneq ($(MODDIR),)
  $(shell test -d $(MODDIR) || mkdir -p $(MODDIR))
  FCFLAGS+= -J $(MODDIR)
endif
~~~
This will create the `.mod` directory in the root if the `MODDIR`
variable is defined and if it does not already exist. Compilers
provide a flag to the location where the `.mod` and `.smod` files are
both generated and read from. In `gfortran`, it is `-J` and in `ifort`
it is `-module`. If `MODDIR` is not null the code above adds the `-J`
compilation option to read and write the `.mod` and `.smod` files to
`MODDIR`.

Our `clean` recipe is no longer valid because the object files now
live in different directories, so we need to update it:
~~~ make
SOURCES:=main.f90 one/one.f90 one/one@proc.f90 two/two.f90 two/two@proc.f90
OBJECTS:=$(subst .f90,.o,$(SOURCES))
ANCHORS:=$(subst .f90,.anc,$(SOURCES))

main: $(OBJECTS)
	$(FC) -o $@ $+

.PHONY: clean
clean:
	-rm -rf *.mod *.smod $(OBJECTS) $(ANCHORS) main
	-test -d $(MODDIR) && rm -r $(MODDIR)
~~~
where we have made sure that the code still works if MODDIR is empty
(and, in case you are wondering, `MODDIR=.` results in error because
you cannot do `rm -r .`). Note that the location of the sources has
been updated with the new directories. This ensures that the
object files and anchor files are created in the same location as the
source files, while the `.mod` and `.smod` files are created in
`MODDIR` (or in the root of the tree, if no `MODDIR` is given).

Finally, all prerequisites need to be updated accordingly. Anchor
files have to have the corresponding directory prefix and `.mod` and
`.smod` files need to be prefixed with `$(MODDIR)`, but otherwise the
dependency rules stay the same:
~~~ make
main.anc: one/one.anc
one/one@proc.anc: two/two.anc
two/two@proc.anc: one/one.anc

one/one@proc.anc: one/one.anc
two/two@proc.anc: two/two.anc

one/one.anc: $(MODDIR)/one.mod $(MODDIR)/one.smod
two/two.anc: $(MODDIR)/two.mod $(MODDIR)/two.smod
$(MODDIR)/one.mod $(MODDIR)/one.smod $(MODDIR)/two.mod $(MODDIR)/two.smod:

one/one@proc.anc: one/one_addone.inc
~~~

Example package: [example-04.tar.xz](/assets/devnotes/02_fortran_makefiles/example-04.tar.xz).

## Handling several different file extensions

Fortran projects sometimes have a mixture of code from different
sources. Some of it is written in Fortran 77, some using more recent
standards. Some code may need to be preprocessed (e.g. files with
extension `.F90`) and some may not. Our Makefile can be modified
easily to deal with the variety.

For some desperately needed simplicity in our example, let us assume
that the only two extensions we have are `.f90` and `.F90`. The latter
informs the compiler that the file needs to be preprocessed. We will
rename `two/two@proc.f90` and `one/one.f90` to the corresponding
`.F90` versions and insert a `#define` preprocessor directive that
does nothing in them:
~~~ fortran
#define DUMMY 1
~~~

In our Makefile, we define a variable with all the Fortran extensions
the Makefile knows:
~~~ make
FORTEXT:=f90 F90
~~~
Naturally, the list can be expanded later on, and different rules can
be easily associated to different extensions (e.g. fixed format for
`.f77` files and free format for `.f90` files). To convert the list of
source files to objects and anchors we define the
`source-to-extension` function:
~~~ make
# $(call source-to-extension,source-file-list,new-extension)
define source-to-extension
  $(strip \
    $(foreach ext,$(FORTEXT),\
      $(subst .$(ext),.$2,$(filter %.$(ext),$1))))
endef
~~~
The function replaces the known Fortran extensions with the new
extension provided by the user in all files from the source file
list argument. With this definition, the variables that contain the
list of object and anchor files can be written as:
~~~ make
OBJECTS:=$(call source-to-extension,$(SOURCES),o)
ANCHORS:=$(call source-to-extension,$(SOURCES),anc)
~~~

Regarding the compilation rules, we want to create a pattern rule for
each of the known extensions and the corresponding anchor files. we
define the `modsource-pattern-rule` function for this and then use it
on all known extensions:
~~~ make
# $(call modsource-pattern-rule,extension)
define modsource-pattern-rule
%.anc: %.$1
	$$(MAKEMOD.f08) $$<
	@touch $$@
endef
$(foreach ext,$(FORTEXT),$(eval $(call modsource-pattern-rule,$(ext))))
~~~
For the rule relating the objects and the anchor files, we need to
identify the extension of the source file in order to know what to
compile. We do this by using the `wildcard` function, and assuming
that there is either a `.f90` file or a `.F90` file, but not both
(because why would you?):
~~~ make
%.o: %.anc
	$(COMPILE.f08) $(OUTPUT_OPTION) $(wildcard $(addprefix $*.,$(FORTEXT)))
	@touch $@
~~~
The rest of the dependency rules do not involve the source files, and
therefore remain unchanged.

Example package: [example-05.tar.xz](/assets/devnotes/02_fortran_makefiles/example-05.tar.xz).

## Multiple modules and submodules in the same file

To add contrivance to contrivance, let us now consider an example
where a single file defines more than one module or submodule. We
combine the module `two.f90`, the submodule `two@proc.F90`, and a new
module called `twomore` inside the same file, `two/two_all.F90`:
~~~ fortran
!! from two.f90
module two
  implicit none
  interface
     recursive module subroutine addtwo(msg,n)
       character(len=:), allocatable, intent(inout) :: msg
       integer, intent(inout) :: n
     end subroutine addtwo
  end interface
end module two

!! from two@proc.F90
#define DUMMY 1
submodule (two) twoproc
  implicit none
contains
  recursive module subroutine addtwo(msg,n)
    use one, only: addone
    character(len=:), allocatable, intent(inout) :: msg
    integer, intent(inout) :: n

    msg = msg // "2"
    if (n > 1) then
       n = n - 1
       call addone(msg,n)
    end if
  end subroutine addtwo
end submodule twoproc

!! new module
module twomore
contains
  recursive subroutine addtwomore(msg,n)
    use one, only: addone
    character(len=:), allocatable, intent(inout) :: msg
    integer, intent(inout) :: n

    msg = msg // "2more"
    if (n > 1) then
       n = n - 1
       call addone(msg,n)
    end if
  end subroutine addtwomore
end module twomore
~~~
In order to have some non-trivial dependencies, let us add a call to
the `addtwomore` routine from the new module in the main program:
~~~ fortran
program main
  use one, only: addone
  use twomore, only: addtwomore
  implicit none

  character(len=:), allocatable :: msg
  integer :: n

  msg = "hello, world! "
  n = 10
  call addone(msg,n)
  n = 2
  call addtwomore(msg,n)
  write (*,*) msg

end program main
~~~

Our Makefile needs to be modified to reflect these changes. First, the
list of sources needs to be updated:
~~~ make
SOURCES:=main.f90 one/one.f90 one/one@proc.f90 two/two_all.F90
~~~
and then the list of dependencies has to be changed as well. When the
`two_all.F90` file is compiled, it generates the object file (in the
same directory), and `.mod` and `.smod` files corresponding to all
the modules and submodules inside. These will be created inside
`$(MODDIR)`, and it should all work seamlessly provided we update the
dependencies correctly. Luckily, anchor files simplify this task
significantly. First, we update the anchor file dependencies caused by
`USE` statements:
~~~ make
main.anc: one/one.anc
main.anc: two/two_all.anc
one/one@proc.anc: two/two_all.anc
two/two_all.anc: one/one.anc
~~~
All references to the old files in `two/` have been moved to
`two_all.anc` and the `USE` in `main.f90` makes its anchor dependent
on `two/two_all.inc`. Next, the anchor files of submodules depend on
the anchors of their parent modules:
~~~ make
one/one@proc.anc: one/one.anc
~~~
We have removed the old `two/two@proc.anc: two/two.anc` dependency
because now both parent module and submodule live in the same file and
therefore it is up to the compiler not to mess up. Typically you avoid
errors by defining the dependent modules and submodules after their
parents within the file.

Finally, we update the list of `.mod` and `.smod` files associated
with each anchor file:
~~~ make
one/one.anc: $(MODDIR)/one.mod $(MODDIR)/one.smod
two/two_all.anc: $(MODDIR)/two.mod $(MODDIR)/two.smod $(MODDIR)/twomore.mod
$(MODDIR)/one.mod $(MODDIR)/one.smod $(MODDIR)/two.mod $(MODDIR)/two.smod $(MODDIR)/twomore.mod:
~~~
The second rule reflects that the `two_all.F90` generates multiple
`.smod` and `.mod` files. The empty rule at the end is updated with
the new targets as well.

Example package: [example-06.tar.xz](/assets/devnotes/02_fortran_makefiles/example-06.tar.xz).

## Submodules all the way down

Submodules may have other submodules as parents. In that case, the
syntax for the submodule definition is:
~~~ fortran
SUBMODULE (ancestor:parent) name
~~~
where `ancestor` is the name of the ancestor module (the module from
which all the children submodules ultimately depend) and `parent` is
the name of the parent 
submodule. To compile the source containing the `name` submodule, we
need the `.mod` file of the ancestor module and the `.smod` file of
the parent submodule. The latter is built as `ancestor@parent.smod`.

Let us add a file called `four.f90` to our example. This file contains
a submodule called `foursmod` whose parent is submodule `twoproc` of
`two.mod`, defined in `two/two_all.F90`. The source code in the new
file is:
~~~ fortran
submodule (two:twoproc) foursmod
  implicit none
contains
  recursive module subroutine addfour(msg,n)
    use one, only: addone
    character(len=:), allocatable, intent(inout) :: msg
    integer, intent(inout) :: n

    msg = msg // "4"
    if (n > 1) then
       n = n - 1
       call addone(msg,n)
    end if
  end subroutine addfour
end submodule foursmod
~~~
and then add the interface of the provided `addfour` routine to module
`two` in `two_all.F90`: 
~~~ fortran
module two
  implicit none
  interface
     recursive module subroutine addtwo(msg,n)
       character(len=:), allocatable, intent(inout) :: msg
       integer, intent(inout) :: n
     end subroutine addtwo
     recursive module subroutine addfour(msg,n)
       character(len=:), allocatable, intent(inout) :: msg
       integer, intent(inout) :: n
     end subroutine addfour
  end interface
end module two
~~~
To use the newly implemented routine, we add a call to `addfour` to
the main program:
~~~ fortran
program main
  use one, only: addone
  use two, only: addfour
  use twomore, only: addtwomore
  implicit none

  character(len=:), allocatable :: msg
  integer :: n

  msg = "hello, world! "
  n = 10
  call addone(msg,n)
  n = 2
  call addtwomore(msg,n)
  n = 2
  call addfour(msg,n)
  write (*,*) msg

end program main
~~~

The modifications required in the Makefile are pretty
straightforward. First we add the new source file:
~~~ make
SOURCES:=main.f90 one/one.f90 one/one@proc.f90 two/two_all.F90 four.f90
~~~
The submodule is not used directly, and main already depends on the
anchor file for `two_all.f90`, which contains module `two`, so no
changes need to be made there. However, compiling `four.f90` requires the
`two.mod` file and the `two@twoproc.smod` files, which are both generated
with a syntax-only compilation of `two/two_all.F90`. Therefore, we
need to add the following dependency between the anchors:
~~~ make
four.anc: two/two_all.anc
~~~
and add the `two@twoproc.smod` to the list of files on which the
anchor for `two_all.F90` depends:
~~~ make
two/two_all.anc: $(MODDIR)/two.mod $(MODDIR)/two.smod $(MODDIR)/two@twoproc.smod $(MODDIR)/twomore.mod
$(MODDIR)/one.mod $(MODDIR)/one.smod $(MODDIR)/two.mod $(MODDIR)/two.smod $(MODDIR)/two@twoproc.smod $(MODDIR)/twomore.mod:
~~~

Example package: [example-07.tar.xz](/assets/devnotes/02_fortran_makefiles/example-07.tar.xz).

## Automatic dependency generation

We now have a fairly complete Makefile template that can handle some
quite insane dependency trees. However, we have been ignoring the
elephant in the room: How do we generate the dependency rules at the
end of the Makefile? Last example had only four files and one include,
and this spawned dozens of dependency relations between existing and
generated files. Clearly, doing this by hand is unfeasible for any
reasonably sized project, so an automatic tool is required.

Ideally, we would want to use the compiler for this, since the
compiler can parse Fortran source code. When building a C/C++ project,
for instance, gcc and other compilers provide the `-M` command-line
option to automatically build make-style dependency rules. The `-M`
option is also available to `gfortran` due to it being part of the
`gcc` bundle, and a similar option exists in `ifort`
(`-gen-dep`). However, unlike with C code, using the `-M` option with
Fortran code requires having the prerequisite `.mod` and `.smod` files
in place beforehand, which in a way defeats the purpose of the flag.

Therefore, we must use a dependency generator. In the case of
Fortran90, there are already 
[several options](http://fortranwiki.org/fortran/show/Build+tools) such as
[sfmakedepend](https://marine.rutgers.edu/po/tools/perl/sfmakedepend)
and [makedepf90](https://salsa.debian.org/science-team/makedepf90).
However, to my knowledge, as of 2019 none of them implement submodule
dependency resolution completely. (makedepf90 seems to make some
mention of submodules, though, so it may be in the works.) Still,
writing our own dependency generator with AWK should not be that
difficult, since we know the way in which modules, submodules, and
includes relate to each other. Since we do not want to write a script
that does full parsing of the source, there will be some limitations. 
It is also important to note that the Fortran standard does not make a
recommendation regarding (or a even mention of) `.mod` and `.smod`
files, so the following is valid only for `gfortran` and `ifort`,
which are the two compilers I have access to. If you use a different
Fortran compiler, it may do things differently and you will have to
modify the generator accordingly.

Our automatic dependency generator will be written in traditional AWK
(without GNU extensions) and we will call it `makedepf08.awk`. The
`makedepf08.awk` script runs over all files in `SOURCES` and returns
the make-style dependency rules:
~~~
$ makedepf08.awk main.f90 one/one.f90 two/two.f90 ...
two/two.anc:.mod/two.mod
.mod/two.mod:
[...]
~~~
In the following, we consider all types of dependency rules one by
one. To keep our sanity, we will assume that all relevant lines
(`MODULE`, `SUBMODULE`, `USE`) do not have continuations, or that the
continuations occur after the important information (the name of the
module, for instance) has been given already.

### Rule 1: the anchor of a source file depends on the mod files of its modules

The first set of dependencies are those related to the generation of
`.mod` files. A file `file.f90` may contain several modules `foo`,
`bar`,... We must make the anchor file for the source `file.anc`
depend on all the module files created by it: `foo.mod`,
`bar.mod`,... and then give empty rules for each of the `.mod` files
to prevent errors when these files do not exist.

According to the 
[Fortran standard](http://isotc.iso.org/livelink/livelink?func=ll&objId=19442438&objAction=Open),
the syntax for the `MODULE` statement (R1405) is simply:
~~~ fortran
MODULE name
~~~
An initial `MODULE` keyword can appear in two other contexts:

- As a `MODULE PROCEDURE` inside an interface block (R1506).

- As a prefix to a `FUNCTION` or `SUBROUTINE` definition (R1527).

We can read in all the module names inside a source file with:
~~~ awk
tolower($1) == "module" && tolower($0) !~ /^[^!]+(subroutine|function|procedure)[[:blank:]]+[^!]/{
    name = tolower($2)
    sub(/!.*$/,"",name)
    mod[name]=file
}
~~~
and save them in the `mod` array. Note that care has been taken to
handle comments and to avoid reading the two cases above as module
definitions. The `file` variable is the name of the source file
being processed without the extension:
~~~ awk
FNR==1{
    file = FILENAME
    sub(/.(f90|F90)$/,"",file)
}
~~~
The set of dependency rules are written at the end of the run based on
the information gathered from the sources:
~~~ awk
END{
    for (i in mod){
      printf("%s.anc:.mod/%s.mod\n",mod[i],i)
      printf(".mod/%s.mod:\n",i)
    }
}
~~~
For instance, in our example the `two/two_all.f90` file contains the
modules `two` and `twomore` and `one/one.f90` contains the module
`one`:
~~~ make
$ makedepf08.awk *.f* */*.{f,F}*
two/two_all.anc:.mod/twomore.mod
.mod/twomore.mod:
two/two_all.anc:.mod/two.mod
.mod/two.mod:
one/one.anc:.mod/one.mod
.mod/one.mod:
~~~

### Rule 2: the anchor of a source file depends on the smod file of those of its modules that are ancestors of a submodule

If `file.f90` contains module `foo`, compilation will always generate
`foo.mod` but sometimes also `foo.smod`. The latter is required if a
submodule has `foo` as its parent, and is automatically generated if
the compiler reads a `MODULE SUBROUTINE` or `MODULE FUNCTION` inside
an interface block. When this happens, the anchor file (`file.anc`)
needs to depend on the `foo.smod` file as well as the `.mod` file from
the previous rule.

Since we do not have a proper parser, it is difficult to detect
whether a `MODULE SUBROUTINE` or `MODULE FUNCTION` in the source file
signals a child submodule (they may be inside a comment, for instance). 
What we do instead is read all the submodules and write down their
ancestor module. The syntax of a submodule definition is
(R1416 and ff.):
~~~ fortran
SUBMODULE (ancestor[:parent]) name
~~~
where `ancestor` is the name of the ancestor module, `parent` is
the name of the parent submodule, and `name` is the name of the new
submodule. If `parent` is not present, then `ancestor` is also the
parent. We read the existing submodules in our code with:
~~~ awk
tolower($1) == "submodule"{
    gsub(/[[:blank:]]+/,"",$0)
    gsub(/!.*$/,"",$0)
    n = split(tolower($0),arr,/[):(]/)
    name = arr[2]"@"arr[n]
    smod[name]=file
    ancestor[name] = arr[2]
    isancestor[ancestor[name]] = 1
}
~~~
First we remove all spaces and comments from the line and then we
split it into fields using the `(`, `)`, and `:` characters. The name
of the submodule is the last field. Submodules with the same name are
allowed if their ancestors are different. Therefore, to avoid clashes
we use `ancestor@name` as the name of the module, in the same way the
compiler does.

Following this, we write down some information we will need later on.
The generating source file is stored in the `smod[]` array, same as we
did in rule 1 with `mod[]` for modules. In addition, we write down the
ancestor of the submodule in `ancestor[]` and whether a module file is
ancestor of a submodule in `isancestor[]`.

If a module is ancestor to a submodule, then necessarily its `.smod`
file needs to be generated since there will be a submodule (perhaps
different from the one we are reading) that will require
it. Therefore, we add a new rule in the `END` block of our script that
says that if a  module is ancestor to any submodule, then its anchor
depends on the corresponding `.smod` file:
~~~ awk
for (i in mod){
    if ((i in isancestor) && isancestor[i]){
        printf("%s.anc:.mod/%s.smod\n",mod[i],i)
        printf(".mod/%s.smod:\n",i)
    }
}
~~~

Applying these rules to our example gives the following dependencies:
~~~ make
$ makedepf08.awk *.f* */*.{f,F}*
two/two_all.anc:.mod/two.smod
.mod/two.smod:
one/one.anc:.mod/one.smod
.mod/one.smod:
~~~
The `two/two_all.F90` file contains the `two` module, which is parent
and ancestor to the `twoproc` submodule in the same file and ancestor
to the `foursmod` submodule in `four.f90`. The `one` module in
`one/one.F90` is ancestor to submodule `proc` in `one/one@proc.f90`.

### Rule 3: the anchor of a source file depends on the smod file of those of its submodules that are parents of a submodule

Say the `file.f90` source file contains module `foo`, which is parent
and ancestor to submodule `bar`. Submodule `baz` is defined as:
~~~ fortran
SUBMODULE (foo:bar) baz
~~~
and therefore has `foo` as its ancestor module and `bar` as its parent
submodule. When the source for `baz` is compiled, we need 
`foo.mod` and `foo@bar.smod`. We now write the rules for generating
the latter by making the anchor file of the containing source file
depend on `foo@bar.smod`.

To implement this rule, first we need to save the information of which
submodule is the parent of which. We modify our submodule statement
parser to do this:
~~~ awk
tolower($1) == "submodule"{
    gsub(/[[:blank:]]+/,"",$0)
    gsub(/!.*$/,"",$0)
    n = split(tolower($0),arr,/[):(]/)
    name = arr[2]"@"arr[n]
    smod[name]=file
    ancestor[name] = arr[2]
    isancestor[ancestor[name]] = 1
    if (n >= 4){
        parent[name] = arr[2]"@"arr[3]
        isparent[parent[name]] = 1
    }
}
~~~
The only change from the previous rule is the conditional at the end
that says that four fields were present (i.e. if a colon was given)
then this submodule has a parent submodule. The name of the parent
submodule is recorded in the usual notation and the parent submodule
is flagged as such.

In the `END` block of the script, we make the anchor file of the
parent submodule source depend on the corresponding `.smod`:
~~~ awk
for (i in smod){
    if ((i in isparent) && isparent[i]){
        printf("%s.anc:.mod/%s.smod\n",smod[i],i)
        printf(".mod/%s.smod:\n",i)
    }
}
~~~
In our example, we have:
~~~ make
$ makedepf08.awk *.f* */*.{f,F}*
two/two_all.anc:.mod/two@twoproc.smod
.mod/two@twoproc.smod:
~~~
The `foursmod` submodule in `four.f90` has the `two` module as
ancestor and `twoproc` as submodule, and the latter lives in
`two/two_all.F90`. Therefore, its anchor file must depend on
`two@twoproc.smod`. 

### Rule 4: the anchor of a source file depends on all its included files and their contents

A source `file.f90` may include any number of other files with the syntax:
~~~ fortran
INCLUDE char-literal
~~~
where `char-literal` is a literal character string delimited by single
or double quotes indicating the location of the included file. The
`.mod` and `.smod` files may depend on the contents of this file, and
therefore so must the anchor for the source file.

In our script, first we record the information about the included
files:
~~~ awk
tolower($1) == "include"{
    incfile = tolower($0)
    sub(/^[[:blank:]]*include[[:blank:]]*.[[:blank:]]*/,"",incfile)
    sub(/[[:blank:]]*.[[:blank:]]*(!.*)?$/,"",incfile)
    idx = index(tolower($0),incfile)
    incfile = substr($0,idx,length(incfile))
    incfile = dirname(file)"/"incfile
    include[incfile] = file
    ARGV[ARGC++] = incfile
}
~~~
The included file is extracted from the Fortran source. Note that we
strip one character from each end with the regular expressions to
eliminate the quotation marks and that we make sure to keep the
capitalization of the file name because the filesystem is
case-sensitive even if Fortran is not. The include file path is relative to
the location of the source so, in order for `make` to find it, we need
to prepend the directory where the source file lives. The following
`dirname` function (created by Aleksey Cheusov) gives the directory
part of a file given as an absolute or relative path:
~~~awk
## https://github.com/cheusov/runawk/blob/master/modules/dirname.awk
function dirname(file){
    if (!sub(/\/[^\/]*\/?$/,"",file))
    return "."
    else if (file != "")
    return file
    else
    return "/"
}
~~~
The information about the included file names is saved to `include[]`,
which is used in the new rule at the end of the script:
~~~ awk
for (i in include){
    printf("%s.anc:%s\n",include[i],i)
}
~~~
The last thing to note is that we added the included file to the
`ARGV` list and incremented `ARGC`. This will make our script also
process the included file, in case it contains more `USE` statements,
module or submodule definitions, or other included files. If
this is the case, then the anchor file must not be associated to the
included file but to the original source file that did the inclusion,
and this needs to happen regardless of how many nested includes there
are. Therefore, we need to modify how the file name is computed when a
new source file begins being processed:
~~~ awk
FNR==1{
    if ((FILENAME in include) && include[FILENAME])
        file = include[FILENAME]
    else{
        file = FILENAME
        sub(/.(f90|F90)$/,"",file)
    }
}
~~~
If the new file has not been included anywhere, then we treat it
normally. If it has, then the source file (and therefore the
corresponding anchor file) is that of the parent file. 

In our example, this rule gives:
~~~ make
$ makedepf08.awk *.f* */*.{f,F}*
one/one@proc.anc:one/one_addone.inc
~~~
There is only one included file, in `one/one@proc.f90`. The included
file uses the `two` module, so when it is processed the set of rules
in the following section (rule 5) generate:
~~~ make
one/one@proc.anc:two/two_all.anc
~~~
as they should.

With this we are done with the dependencies of the anchor files have
with generated and included files. Now, we need to relate the anchor
files to each other according to the order in which the source files
need to be compiled.

### Rule 5: the anchor of a source file depends on the anchors of all the non-intrinsic modules it uses

The `USE` statement in Fortran is (R1409 and ff.):
~~~ fortran
USE [[,nature] ::] name ,...
~~~
where `nature` can be `INTRINSIC` or `NON_INTRINSIC` and the ellipsis
after the comma may be a rename list or an `ONLY` list.

From within the script we have no way of knowing whether a used module
is intrinsic or not, so what we do is we make a note of the module
name in the `USE` statement and then handle it in the `END` block,
once we have the list of known modules:
~~~ awk
tolower($1) == "use"{
    name = tolower($0)
    sub(/^[[:blank:]]*use[[:blank:]]*/,"",name)
    sub(/^(.*::)?[[:blank:]]*/,"",name)
    sub(/[[:blank:]]*((,|!).*)?$/,"",name)
    usedmod[name]++
    fileuse[usedmod[name],name] = file
}
~~~
The first few lines strip the Fortran line down to the module name.
Then this name is added to the `usedmod[]` array, which counts the
number of times a given module has been used. The `fileuse[i,j]` array
gives the source file that uses module `j` for the `i`th time. The
rules at the `END` are:
~~~ awk
split("", filuniq, ":")
for (i in usedmod){
    if ((i in mod) && mod[i]){
        for (j=1;j<=usedmod[i];j++){
            if (!filuniq[fileuse[j,i],mod[i]] && fileuse[j,i] != mod[i]){
                filuniq[fileuse[j,i],mod[i]] = 1
                printf("%s.anc:%s.anc\n",fileuse[j,i],mod[i])
            }
        }
    }
}
~~~
We first run over all modules that have been used. If a used module is
not in the database of known modules (`mod[]`), then we assume it is
intrinsic or external. Either way, we do not need to generate a rule
for it. For a given module `i`, we then run over all source files that
use it and write the corresponding relation between the anchors. The
conditional in the inner loop makes sure that:

- A use statement to a module within the same source file does not
  generate a circular dependence (which would work but cause an
  ugly warning).

- Rules are not repeated. To do this we keep track of which rules we
  have already written using the local `filuniq` array. This is only
  to keep things tidy and to avoid the most obvious rule repetitions.
  
In our example, this rule generates:
~~~ make
$ makedepf08.awk *.f* */*.{f,F}*
main.anc:two/two_all.anc
one/one@proc.anc:two/two_all.anc
four.anc:one/one.anc
main.anc:one/one.anc
two/two_all.anc:one/one.anc
~~~
that gives the mapping of all modules uses in the program in terms of
anchor files.

### Rule 6: submodule anchor files depend on their ancestor's anchor files

To compile a file containing a submodule, we need to have the `.mod`
file of the ancestor module. Therefore, the anchor file of the
submodule source depends on the anchor file of the ancestor module
source. We have all the information in hand and we only need to write
the entry in the `END` block:
~~~ awk
for (i in smod){
    if ((ancestor[i] in mod) && mod[ancestor[i]] && (smod[i] != mod[ancestor[i]])){
        printf("%s.anc:%s.anc\n",smod[i],mod[ancestor[i]]);
    }
}
~~~
All submodules will generate one of these rules, since they all
have one ancestor module. The only cases when the rule will not be
generated is when:

- The ancestor module is unknown (good luck with that one... we'll let
  the user handle the fallout, though).
  
- The submodule and the ancestor module are in the same file (would
  create a circular dependence).
  
In our example,
~~~ make
$ makedepf08.awk *.f* */*.{f,F}*
one/one@proc.anc:one/one.anc
four.anc:two/two_all.anc
~~~
Submodule `oneproc` in `one/one@proc.f90` has module `one` in
`one/one.F90` as ancestor. Submodule `foursmod` in `four.f90` has
module `two` from `two/two_all.F90` as ancestor.

### Rule 7: submodule anchor files depend on their parent's anchor files

To compile a source file containing a submodule, the `.smod` file of
the parent module or submodule must be available. Therefore, the
anchor file of the submodule being compiled depends on the anchor file
of its parent. Since we have the parent information, this can be
implemented easily in the `END` block:
~~~ awk
for (i in smod){
     if ((i in parent) && parent[i] && smod[i] != smod[parent[i]]){
         printf("%s.anc:%s.anc\n",smod[i],smod[parent[i]]);
     }
}
~~~
The conditional makes sure that the rule is generated if:

- The parent submodule exists. If the parent and the ancestor of the
  submodule are the same, then this is already covered by rule 6,
  which is why the ancestor module was not added to `parent[]` or
  flagged as `isparent[]`.

- The submodule source file and the parent's source file are not the
  same, to avoid circular dependencies.
  
Applying this code to our example, we have:
~~~ make
four.anc:two/two_all.anc
~~~
The `foursmod` submodule in `four.f90` has module `two` as ancestor
and module `twoproc` as parent. The latter lives in
`two/two_all.F90`.

### Putting everything together

Combining all the bits of code, we now have a functional automatic
dependency generator capable of handling the gnarliest of Fortran
sources, with just about 100 lines of AWK code. Here is the script in
its entirety:
~~~ awk
## Copyright (c) 2019 alberto Otero de la Roza <aoterodelaroza@gmail.com>
## This file is frere software; distributed under GNU/GPL version 3.

#! /usr/bin/env -S awk --traditional -f 

function dirname(file){
    ## function dirname by Aleksey Cheusov
    ## https://github.com/cheusov/runawk/blob/master/modules/dirname.awk
    if (!sub(/\/[^\/]*\/?$/,"",file))
        return "."
    else if (file != "")
        return file
    else
        return "/"
}

FNR==1{
    if ((FILENAME in include) && include[FILENAME])
        file = include[FILENAME]
    else{
        file = FILENAME
        sub(/.(f|F|fpp|FPP|for|FOR|ftn|FTN|f90|F90|f95|F95|f03|F03|f08|F08)$/,"",file)
    }
}
tolower($1) == "module" && tolower($0) !~ /^[^!]+(subroutine|function|procedure)[[:blank:]]+[^!]/{
    name = tolower($2)
    sub(/!.*$/,"",name)
    mod[name]=file
}
tolower($1) == "submodule"{
    gsub(/[[:blank:]]+/,"",$0)
    gsub(/!.*$/,"",$0)
    n = split(tolower($0),arr,/[):(]/)
    name = arr[2]"@"arr[n]
    smod[name]=file
    ancestor[name] = arr[2]
    isancestor[ancestor[name]] = 1
    if (n >= 4){
        parent[name] = arr[2]"@"arr[3]
        isparent[parent[name]] = 1
    }
}
tolower($1) == "include"{
    incfile = tolower($0)
    sub(/^[[:blank:]]*include[[:blank:]]*.[[:blank:]]*/,"",incfile)
    sub(/[[:blank:]]*.[[:blank:]]*(!.*)?$/,"",incfile)
    idx = index(tolower($0),incfile)
    incfile = substr($0,idx,length(incfile))
    incfile = dirname(file)"/"incfile
    include[incfile] = file
    ARGV[ARGC++] = incfile
}
tolower($1) == "use"{
    name = tolower($0)
    sub(/^[[:blank:]]*use[[:blank:]]*/,"",name)
    sub(/^(.*::)?[[:blank:]]*/,"",name)
    sub(/[[:blank:]]*((,|!).*)?$/,"",name)
    usedmod[name]++
    fileuse[usedmod[name],name] = file
}
END{
    for (i in mod){
        ## Rule 1: the anchor of a source file depends on the mod files of its modules
        printf("%s.anc:.mod/%s.mod\n",mod[i],i)
        printf(".mod/%s.mod:\n",i)
        if ((i in isancestor) && isancestor[i]){
            ## Rule 2: the anchor of a source file depends on the smod file of those of its modules that are ancestors of a submodule
            printf("%s.anc:.mod/%s.smod\n",mod[i],i)
            printf(".mod/%s.smod:\n",i)
        }
    }

    for (i in smod){
        ## Rule 3: the anchor of a source file depends on the smod file of those of its submodules that are parents of a submodule
        if ((i in isparent) && isparent[i]){
            printf("%s.anc:.mod/%s.smod\n",smod[i],i)
            printf(".mod/%s.smod:\n",i)
        }

        ## Rule 6: submodule anchor files depend on their ancestor's anchor files
        if ((ancestor[i] in mod) && mod[ancestor[i]] && (smod[i] != mod[ancestor[i]]))
            printf("%s.anc:%s.anc\n",smod[i],mod[ancestor[i]]);

        ## Rule 7: submodule anchor files depend on their parent's anchor files
        if ((i in parent) && parent[i] && smod[i] != smod[parent[i]])
            printf("%s.anc:%s.anc\n",smod[i],smod[parent[i]]);
    }

    ## Rule 5: the anchor of a source file depends on the anchor of all the non-intrinsic modules it uses 
    split("", filuniq, ":")
    for (i in usedmod){
        if ((i in mod) && mod[i]){
            for (j=1;j<=usedmod[i];j++){
                if (!filuniq[fileuse[j,i],mod[i]] && fileuse[j,i] != mod[i]){
                    filuniq[fileuse[j,i],mod[i]] = 1
                    printf("%s.anc:%s.anc\n",fileuse[j,i],mod[i])
                }
            }
        }
    }
     
    ## Rule 4: the anchor of a source file depends on all its included files and their contents
    for (i in include)
        printf("%s.anc:%s\n",include[i],i)
}
~~~
Applying it to our example gives the whole list of dependency rules in
one go:
~~~ make
$ makedepf08.awk *.f* */*.{f,F}*
two/two_all.anc:.mod/twomore.mod
.mod/twomore.mod:
two/two_all.anc:.mod/two.mod
.mod/two.mod:
two/two_all.anc:.mod/two.smod
.mod/two.smod:
one/one.anc:.mod/one.mod
.mod/one.mod:
one/one.anc:.mod/one.smod
.mod/one.smod:
two/two_all.anc:.mod/two@twoproc.smod
.mod/two@twoproc.smod:
one/one@proc.anc:one/one.anc
four.anc:two/two_all.anc
four.anc:two/two_all.anc
main.anc:two/two_all.anc
one/one@proc.anc:two/two_all.anc
four.anc:one/one.anc
main.anc:one/one.anc
two/two_all.anc:one/one.anc
one/one@proc.anc:one/one_addone.inc
~~~
Note that some of them are repeated. This is not a problem but, since
we have taken care of writing a single rule for each
target/prerequisite pair and the order of the rules is irrelevant in
this case, you can as easily `sort` and `uniq` them to get a tidier
list.

Example package: [example-08.tar.xz](/assets/devnotes/02_fortran_makefiles/example-08.tar.xz).

## A Makefile for all occasions

Our combination of Makefile and automatic dependency generation script
is quite general but has the following limitations:

- No continuations are allowed in `USE`, `MODULE`, `SUBMODULE`, and
  `INCLUDE` lines, except when the continuation occurs after the part
  that contains the information we need. For instance, you could have:
~~~
  use amodule, only: bleh1, bleh2, &
                     bleh3
~~~
  and this would still work because everything after the comma is
  discarded. For the same reason, continued lines that start with
  "use", "module", "submodule", or "include" are best avoided.
  
- Two files with the same name and different Fortran extensions in the
  same directory are not allowed.
  
- Since it has been tested only with `gfortran` and `ifort`, if some
  other compiler behaves differently regarding `.mod` and `.smod`
  files, the script needs to be adapted.
  
- The way our Makefile works, it may cause trouble if you use files
  with blank spaces in them.

If we name our script `makedepf08.awk`, then a complete Makefile that
compiles all sources in all subdirectories of a Fortran project is:
~~~ make
## Copyright (c) 2019 alberto Otero de la Roza <aoterodelaroza@gmail.com>
## This file is frere software; distributed under GNU/GPL version 3.

FC:=gfortran
FCSYNTAX:=-fsyntax-only
FCMODDIR:=-J
MODDIR:=.mod

#### user input ends here ####

## some tricks for text manipulation
null:=
space:=$(null) $(null)
$(space):=$(space)
define \n


endef

## no implicit rules
.SUFFIXES: 

## auxiliary programs
AWK:=awk
SED:=sed
RM:=rm -f
MKDIR:=mkdir -p
TEST:=test

## known fortran extensions
FORTEXT:=f F fpp FPP for FOR ftn FTN f90 F90 f95 F95 f03 F03 f08 F08

## locate the source files
SOURCES:=$(shell find . -regextype posix-awk -regex '.*\.($(subst $( ),|,$(FORTEXT)))$$')

## compilation and syntax-compilation commands
COMPILE.f08 = $(FC) $(FCFLAGS) $(TARGET_ARCH) -c
MAKEMOD.f08 = $(FC) $(FCFLAGS) $(TARGET_ARCH) $(FCSYNTAX) -c

## create the mod and smod directory; define slashed version of MODDIR
ifneq ($(MODDIR),)
  $(shell $(TEST) -d $(MODDIR) || $(MKDIR) -p $(MODDIR))
  MODDIRSLSH:=$(MODDIR)/
else
  MODDIRSLSH:=./
endif

## create the temporary mod and smod directory
ifneq ($(FCMODREADDIR),)
  MODDIRTMP:=.tmp$(MODDIR)
  $(shell $(TEST) -d $(MODDIRTMP) || $(MKDIR) -p $(MODDIRTMP))
  MAKEMOD.f08+= $(FCMODDIR) $(MODDIR)
  COMPILE.f08+= $(FCMODREADDIR) $(MODDIR) $(FCMODDIR) $(MODDIRTMP)
else
  MAKEMOD.f08+= $(FCMODDIR) $(MODDIR)
  COMPILE.f08+= $(FCMODDIR) $(MODDIR)
endif

## define the anchors and the objects variables
# $(call source-to-extension,source-file-list,new-extension)
define source-to-extension
  $(strip \
    $(foreach ext,$(FORTEXT),\
      $(subst .$(ext),.$2,$(filter %.$(ext),$1))))
endef
OBJECTS:=$(call source-to-extension,$(SOURCES),o)
ANCHORS:=$(call source-to-extension,$(SOURCES),anc)

## default target, main and clean targets
all: main

main: $(OBJECTS)
	$(FC) -o $@ $+

.PHONY: clean
clean:
	-$(RM) *.mod *.smod $(OBJECTS) $(ANCHORS) main
	-$(TEST) -d $(MODDIR) && $(RM) -r $(MODDIR)
	-$(TEST) -d $(MODDIRTMP) && $(RM) -r $(MODDIRTMP)

## syntax-only compilation rule: all anchor files depend on their source
# $(call modsource-pattern-rule,extension)
define modsource-pattern-rule
%.anc: %.$1
	$$(MAKEMOD.f08) $$<
	@touch $$@
endef
$(foreach ext,$(FORTEXT),$(eval $(call modsource-pattern-rule,$(ext))))

## compilation rule: objects depend on their anchor file
%.o: %.anc
	$(COMPILE.f08) $(OUTPUT_OPTION) $(wildcard $(addprefix $*.,$(FORTEXT)))
ifdef MODDIRTMP
	-@$(RM) $(MODDIRTMP)/*.mod $(MODDIRTMP)/*.smod
endif
	@touch $@

## automatically generate the dependency rules
$(eval $(subst $( ),$(\n),$(shell $(AWK) --traditional -f makedepf08.awk $(SOURCES) | sort | uniq | $(SED) -e 's!^.mod/!$(MODDIRSLSH)!' -e 's!:.mod/!:$(MODDIRSLSH)!')))
~~~
This should solve the problem of writing Makefiles for modern Fortran
projects, at least for some time.

Example package: [example-final.tar.xz](/assets/devnotes/02_fortran_makefiles/example-final.tar.xz).

## All example packages

- [example-01.tar.xz](/assets/devnotes/02_fortran_makefiles/example-01.tar.xz).
- [example-02.tar.xz](/assets/devnotes/02_fortran_makefiles/example-02.tar.xz).
- [example-03.tar.xz](/assets/devnotes/02_fortran_makefiles/example-03.tar.xz).
- [example-04.tar.xz](/assets/devnotes/02_fortran_makefiles/example-04.tar.xz).
- [example-05.tar.xz](/assets/devnotes/02_fortran_makefiles/example-05.tar.xz).
- [example-06.tar.xz](/assets/devnotes/02_fortran_makefiles/example-06.tar.xz).
- [example-07.tar.xz](/assets/devnotes/02_fortran_makefiles/example-07.tar.xz).
- [example-08.tar.xz](/assets/devnotes/02_fortran_makefiles/example-08.tar.xz).
- [example-final.tar.xz](/assets/devnotes/02_fortran_makefiles/example-final.tar.xz).
