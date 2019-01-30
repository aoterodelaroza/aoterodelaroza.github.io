---
layout: single
title: "Arithmetic expressions, variables, and functions"
permalink: /critic2/manual/arithmetics/
excerpt: "Arithmetic expressions, variables, and functions used for critic2."
sidebar:
  nav: "critic2_manual"
categories: critic2 manual arithmetics
toc: true
toc_label: "Arithemtic expressions, variables, functions"
toc_sticky: true
---

### Basic usage {#c2-arithbasic}

In critic2, an arithmetic expression can be used almost everywhere in
the input where a real or integer number is expected. Arithmetic
expressions that appear in the input (without an associated keyword)
are evaluated and their result is written to the output. For instance,
you can start critic2 and write:
~~~
3+2*sin(pi/4)
%% 3+2*sin(pi/4)
   4.4142135623731
~~~
Similarly, variables can be defined and utilized in any
expression. Variable names must start with a letter and are composed
only of letters, numbers, and the underscore character. Also, they
cannot have the same name as a known constant (pi, e, eps) or a
function, regardless of case. Variables in expressions are
case-sensitive. To use a variable, first you need to assign it. For
instance:
~~~
a = 20+10
a/7 + 1
%% a/7 + 1
   5.2857142857143
~~~
By using the "-q" command-line option, critic2 can be used as a simple
calculator:
~~~
$ echo "1+erf($RANDOM/100000)" | critic2 -q
1.2578249310340
~~~
When used in combination with other keywords, arithmetic expressions
must be enclosed in either double quotes ("), single quotes ('), or
parentheses, or they must form a single word (i.e. no spaces). For
instance, this is valid critic2 input:
~~~
a = 0.12
NEQ 1/3 "2 / 3" 1/4+a Be
~~~
but this is not:
~~~
NEQ 1/3 2 /3 1/4 Be
~~~
because it contains one field too many (the space between 2 and /3 is
the problem). Arithmetic expressions can contain:

* Operators: +, -, *, /, ** or ^, % (modulo)

* Functions: see `List of available functions`_.

* Constants: pi, e and eps (the machine precision).

* Variables defined by the user as above.

* Structural variables. See `List of structural variables`_.

Parentheses can be used and the usual rules of associativity and
precedence apply.

In some cases, arithmetic expressions can be applied to make new
scalar fields by transforming existing fields. Scalar fields are
denoted with a dollar sign ($) followed by an identifier and,
optionally, a modifier. The default identifier for a field is the
order in which the field was loaded in the input. For instance, if the
first field ($1) is the spin-up density and the second ($2) is the
spin-down density, the total density can be calculated with the
expression "$1+$2". The expressions "$0" or "$rho0" represent the
promolecular density (which is always available once the crystal
structure is known) so "$1+$2-$rho0" would represent the density
difference between the actual crystal density and the sum of atomic
densities. Fields can also be referred by a name, if the ID keyword is
used (see `Loading a field (LOAD)`_ and `Additional LOAD
options`_). Named fields simplify the work if you load many fields.

It is possible to specify a field modifier right after the number or
name for that field in order to access its derivatives and other
properties related to that scalar field. The modifier, which is
separated by the field name using the ":" character and is case
insensitive, may be one of:

+ v: valence-only value of the field (it is usually employed to access
  the valence density in a grid field in which core augmentation is
  active).
+ c: core-only value of the field.
+ x, y, z: first derivatives.
+ xx, xy, yx, xz, zx, yy, yz, zy, zz: second derivatives.
+ g: norm of the gradient.
+ l: Laplacian.
+ lv: valence Laplacian (Laplacian without core augmentation).
+ lc: core Laplacian.

For instance, "$2:l" is the Laplacian of field 2 and "$rho0:xy" is the
xy-component of the Hessian of the promolecular density. In molecular
wavefunctions (wfn/wfx/fchk/molden), the value of particular orbitals
can be selected using the following field modifiers:

+ a number (<n>): selects molecular orbital number n. Thus, "$1:3"
  refers to the value of molecular orbital number 3 in field 1.
+ HOMO: the highest-occupied MO in an RHF wavefunction.
+ LUMO: the lowest-unoccupied MO in an RHF wavefunction.
+ AHOMO: the alpha highest-occupied MO in a UHF wavefunction.
+ ALUMO: the alpha lowest-unoccupied MO in a UHF wavefunction.
+ BHOMO: the beta highest-occupied MO in a UHF wavefunction.
+ BLUMO: the beta lowest-unoccupied MO in a UHF wavefunction.
+ A<n>: alpha MO number n in a UHF wavefunction.
+ B<n>: beta MO number n in a UHF wavefunction.

The flags that select virtual orbitals require a file format that
contains that information, and the field has to be loaded using the
READVIRTUAL keyword (see `Loading a field (LOAD)`_). Also in
unrestricted molecular wavefunction fields, one can access the spin
densities:

+ up,dn,sp: alpha, beta, and spin densities.

There is a clear distinction between expressions that reference fields
and those that do not and, for certain keywords, critic2 will decide
what to do with an expression based on this distinction. For
instance:
~~~
a = 2
CUBE CELL FIELD "a*$1"
~~~
calculates a grid spanning the entire cell for a scalar field that is
built as two times the value of field number 1, but:
~~~
a = 2
CUBE CELL FIELD "a*1"
~~~
uses field number two (a*1 = 2) to calculate the same
grid. Expressions involving fields can also be used in LOAD and in
other keywords (POINT, LINE, INTEGRABLE, etc.).

When using arithmetic expressions to create new fields, it is possible
to refer to coordinates in real space in those expressions by using
"structural variables". See `List of structural variables`_.

The value of a variable can be cleared using the CLEAR keyword:
~~~
CLEAR var1.s var2.s ...
CLEAR ALL
~~~
This keyword deletes the variables var1.s, var2.s, etc. or all the
variables (ALL). At any moment, the internal list of variables can be
printed to the output using the keyword LIST:
~~~
LIST
~~~
The LIST keyword lists all named variables and fields.

### Special fields

Some special fields are defined from the crystal (or molecular)
structure alone. For now, the only available special field is "ewald",
that can be accessed using "$ewald" in arithmetic expressions, and
gives the value of the Ewald potential using the current existing
charges (that can be set with the Q keyword, see `Atomic charge
options`_ for more information). For instance:
~~~
cube cell field "2 * $ewald"
~~~
calculates a grid using 2 times the value of the Ewald potential. 

### List of available functions {#availchemfun}

Arithmetic expressions can use any of the functions in the critic2
function library. These functions include the usual mathematical
functions (like exp or sin) but also functions that are meant to be
applied to scalar fields of a certain type (e.g., the Thomas-Fermi
kinetic energy density, gtf). It is very important to distinguish
whether a function expects a numerical argument (e.g. sin(x)), or a
field identifier (e.g. gtf(1) or gtf(rho0)).

The list of arithmetic functions is: abs, exp, sqrt, floor, ceil,
ceiling, round, log, log10, sin, asin, cos, acos, tan, atan, atan2,
sinh, cosh, erf, erfc, min, max. All these functions apply to numbers
(or other arithmetic expressions), and their behavior is the
usual. For instance, "sin(2*pi)", "max($1,0)", and "atan2(y,x)" are
all valid expressions.

The following "chemical" functions accept one or more field
identifiers as their arguments. Their purpose is to provide shorthands
to build fields from other fields using physically-relevant
formulas. For instance, "gtf(1)" is the Thomas-Fermi kinetic energy
density calculated using the electron density in field 1. In all
instances, "gtf(1)" is equivalent to writing the formula in full
("3/10*(3*pi^2)^(2d0/3d0)*$1^(5/3)") but, obviously, much more
convenient. Some of the chemical functions like, for instance, those
that require having access to the one-electron data, can only be used
with fields of a certain type.

In the lists below, the name in square brackets, if available, is a
shorthand for applying the chemical function to the reference field
(case-insensitive) in the POINTPROP keyword.

The following list of chemical functions can be used with any field
type. In all cases, field id must correspond to the system's electron
density.

* gtf(id) [GTF]: Thomas-Fermi kinetic energy density. The kinetic
  energy density for a uniform electron gas with its density given by
  the value of field id at the point.

  + Yang and Parr, Density-Functional Theory of Atoms and Molecules.

* vtf(id) [VTF]: the potential energy density calculated using the
  Thomas-Fermi kinetic energy density and the local virial theorem
  (2g(r) + v(r) = 1/4*lap(r) in au).

* htf(id) [HTF]: the total energy density calculated using the
  Thomas-Fermi kinetic energy density and the local virial theorem
  (2g(r) + v(r) = 1/4*lap(r) in au). The field id must contain the
  electron density of the system.

* gtf_kir(id) [GTF_KIR]: Thomas-Fermi kinetic energy density with the
  semiclassical gradient correction proposed by Kirzhnits for the
  not-so-homogeneous electron gas. The electron density and its
  derivatives are those of field id at every point in space. See:

  + Kirzhnits, (1957). Sov. Phys. JETP, 5, 64-72.

  + Kirzhnits, Field Theoretical Methods in Many-body Systems
    (Pergamon, New York, 1967).

  + Abramov, Y. A. Acta Cryst. A (1997) 264-272.

  and also:

  + Zhurova and Tsirelson, Acta Cryst. B (2002) 58, 567-575.

  + Espinosa et al., Chem. Phys. Lett. 285 (1998) 170-173.

  for more references and an example of the application of this
  quantity with experimental electron densities.

* vtf_kir(id) [VTF_KIR]: the potential energy density calculated using
  gtf_kir(id) and the local virial theorem (2g(r) + v(r) =
  1/4*lap(r) in au).

* htf_kir(id) [HTF_KIR]: the total energy density calculated using
  gtf_kir(id) and the local virial theorem (2g(r) + v(r) =
  1/4*lap(r) in au).

* lag(id) [LAG]: the Lagrangian density (-1/4 * lap(rho)).

* lol_ki(id) [LOL_KIR]: the localized-orbital locator (LOL) with the
  kinetic energy density calculated using the Thomas-Fermi
  approximation with Kirzhnits gradient correction. See:

  + Tsirelson and Stash, Acta Cryst. (2002) B58, 780.

The following functions require the kinetic energy density, and
therefore can only be used with fields that provide the one-electron
states. At present, this is only available for molecular wavefunction
fields. 

* gkin(id) [GKIN]: the kinetic energy density, G-version (grad(rho) *
  grad(rho)). See: 

  + Bader and Beddall, J. Chem. Phys. (1972) 56, 3320.

  + Bader and Essen, J. Chem. Phys. (1984) 80, 1943.

* kkin(id) [KKIN]: the kinetic energy density, K-version (rho *
  lap(rho)).

* vir(id) [VIR]: the electronic potential energy density, also called
  the virial field.

  + Keith et al. Int. J. Quantum Chem. (1996) 57, 183-198.

* he(id) [HE]: the electronic energy density, vir(id) + gkin(id).

* elf(id) [ELF]: the electron localization function (ELF).

  + Becke and Edgecombe J. Chem. Phys. (1990) 92, 5397-5403

* lol(id) [LOL]: the localized-orbital locator (LOL).

  + Schmider and Becke, J. Mol. Struct. (Theochem) (2000) 527, 51-61

  + Schmider and Becke, J. Chem. Phys. (2002) 116, 3184-3193.

* brhole_a1(id), brhole_a2(id), brhole_a(id): the A prefactor of the
  spherically averaged hole model proposd by Becke and Roussel
  (spin up, down, and average, respectively). The BR hole is an
  exponential A*exp(-alpha * r) at a distance b from the reference
  point. 

  + A.D. Becke and M.R. Roussel, Phys. Rev. A 39 (1989) 3761

* brhole_b1(id), brhole_b2(id), brhole_b(id): the b parameter of the
  BR hole model (spin up, down, and average). b is distance from the
  exponential center to the reference point.

* brhole_alf1(id), brhole_alf2(id), brhole_alf(id): the exponent of
  the BR hole model (spin up, down, and average).

* xhcurv1(id), xhcurv2(id), xhcurv(id): the curvature of the exchange
  hole at the reference point (spin up, down, and average). Q_sigma in
  the literature:

  + A.D. Becke and M.R. Roussel, Phys. Rev. A 39 (1989) 3761

* dsigs1(id), dsigs2(id), dsigs(id): the leading coefficient of the
  same-spin pair density (spin up, down, and average). D_sigma in the
  literature:

  + A.D. Becke and M.R. Roussel, Phys. Rev. A 39 (1989) 3761

The following chemical functions require both a molecular wavefunction
and basis set information (at present, this is only read from a
Gaussian fchk file). In addition, it is necessary to have critic2
compiled with the libCINT library to calculate the molecular integrals
involved (see README).

* mep(id): molecular electrostatic potential. 

* uslater(id): Slater potential U_x. The HF exchange energy is 
  the integral of rho times U_x. See:

  A.D. Becke, J. Chem. Phys. 138 (2013) 074109 and references therein.

* nheff(id): reverse BR efefctive hole normalization. See:

  A.D. Becke, J. Chem. Phys. 138 (2013) 074109 and references therein.

* xhole(id,x,y,z): Exchange hole with reference point at (x,y,z). The
  coordinates are Cartesian in angstrom referred to the molecular
  origin if the system is a molecule or crystallographic coordinates
  if the system is a crystal.

Other special labels can be used, that activate the calculation of
properties for the reference field. These are:

* stress: calculate the Schrodinger stress tensor of the reference
  field. The virial field is the trace of this tensor.

  + Keith et al. Int. J. Quantum Chem. (1996) 57, 183-198.

A particular case of chemical function is xc(), that allows the user
to access the external LIBXC library. This is only possible if the
LIBXC library was linked during the compilation of critic2. See `Use
of LIBXC in arithmetic expressions`_.

### Use of LIBXC in arithmetic expressions {#libxc}

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
~~~
xc($1,1)+xc($1,9)
~~~
because idx=1 is Slater's exchange and idx=9 is Perdew-Zunger
correlation. PBE (a GGA) would be:
~~~
xc($1,$2,101)+xc($1,$2,130)
~~~
Here 101 is PBE exchange and 130 is PBE correlation. Field $1 contains
the electron density and $2 is its gradient, which can be determined
using, for instance:
~~~
LOAD AS GRAD 1
~~~
or, if the field is not a grid, in direct way by doing:
~~~
xc($1,$1:g,101)+xc($1,$1:g,130)
~~~

### List of structural variables

When creating new fields as transformations of existing fields, it is
possible to refer to the crystal or molecular structure (the nearest
atom, the position, etc.) using structural variables. Structural
variables start with the symbol "@" followed by an identifier that
select the type of variable. For some of the variables, an additional
modifier can be applied using the ":" symbol after the variable
identifier. For instance, "@dnuc" gives the distance to the nearest
nucleus. "@rho0nuc:3" is the atomic density at the given point of the
nearest atom number 3 (from the complete list). The following
structural variables are accepted in critic2:

* dnuc: Distance to the closest nucleus. By default, the distance is
  in angstrom for molecules and in bohr for crystals, unless changed
  using the UNITS keyword (see `Input and output units`_). (*)

* xnucx,ynucx,znucx: x,y,z coordinates of the nearest nucleus in
  crystallographic coordinates. (*)

* xnucc,ynucc,znucc: x,y,z coordinates of the nearest nucleus in
  Cartesian coordinates. By default, the coordinates have units of
  bohr in crystals, and are referred to the molecular center and have
  units of angstrom in molecules. (*)

* xx,yx,zx: the x,y,z coordinates of the point where the arithmetic
  expression is being evaluated (crystallographic coordinates).

* xc,yc,zc: the x,y,z Cartesian coordinates of the point where the
  arithmetic expression is being evaluated. Units are bohr. (*)

* xm,ym,zm: the x,y,z Cartesian coordinates of the point where the
  arithmetic expression is being evaluated. By default, the
  coordinates have units of bohr in crystals, and are referred to the
  molecular center and have units of angstrom in molecules. (*)

* xxr,yxr,zxr: the x,y,z coordinates of the point where the arithmetic
  expression is being evaluated (crystallographic coordinates in the
  reduced unit cell).

* idnuc: complete-list ID of the closest nucleus.

* nidnuc: non-equivalent list ID of the closest nucleus.

* rho0nuc: atomic density contribution from the nearest nucleus. (*)

* spcnuc: species ID of the nearest nucleus.

* zatnuc: atomic number of the closest nucleus.

Entries marked by a (*) at the end correspond to the structural
variables that accept a modifier. A modifieris a colon (:) followed by
a number id.i. If given, the modifier restricts the structural
variable to atoms with ID id.i (from the complete list). 

For instance, if we have a crystal structure and its electron density
in field $1 as a grid, then:
~~~
LOAD AS "(@idnuc == 1) * $1" ID voronoi
SUM VORONOI
~~~
calculates the Voronoi charge of atom 1. Likewise, this:
~~~
LOAD AS "@rho0nuc:1/$0 * $1" ID hirsh
SUM hirsh
~~~
calculates the Hirshfeld charge. Structural variables are also useful
in molecules in combination with the MOLCALC keyword. For instance, to
calculate the dipole moment of a neutral molecule (in units of
electrons*angstrom):
~~~
molcalc "$wfx * @xc"
molcalc "$wfx * @yc"
molcalc "$wfx * @zc"
~~~
Similar expressions can also be used to create new scalar fields by
restricting or modifying the values of a scalar field only in certain
areas of the system.

