---
layout: single
title: "Input format, output format, notation"
permalink: /critic2/manual/inputoutput/
excerpt: "Input format, output format, and notation for critic2."
sidebar:
  nav: "critic2_manual"
categories: critic2 manual inputoutput
toc: true
toc_label: "Input and output format, notation"
toc_sticky: true
---

## Notation and terms

The input for critic2 is free-format and case-insensitive. Lines
preceded by `#` are treated as comments. The input syntax is
keyword-driven: the first word in any (non-blank) input line
determines the task to be performed.

In this manual, keywords are written in CAPS. Input variables are
denoted using a suffix to indicate their type: a real number (`.r`), an
integer (`.i`) or a string (`.s`). Almost anywhere that a number is
expected, it is possible to use an arithmetic expression (see the
`Arithmetic expressions, variables, and functions in critic2`_
section). If an arithmetic expression is required (and not merely
optional), then quotes are used (for instance, "expr.s"). When several
alternative keywords are possible, the or symbol (|) is used. Square
brackets ([]) denote optional keywords and curly braces ({}) are used
for grouping.

Some of the sections in the rest of this manual contain an "additional
options" subsection. These provide some independent keywords that
control the behavior of critic2 and are meant to be used either before
or after the keywords in the section in which they appear. For
instance, NOSYMM can be used before CRYSTAL to deactivate the
automatic calculation of the crystal symmetry:
~~~
NOSYMM
CRYSTAL benzene.cif
~~~
Hence, NOSYMM appears in this manual as an additional option to
CRYSTAL.

The critic2 output is mostly self-explanatory, although there are a
number of key concepts that need to be understood. In the case of
crystals, the crystal motif is represented in critic2 by two lists of
atoms. The **non-equivalent atom list** contains the atoms in the
asymmetric unit, that is, the minimal list of atoms that generate all
the atomic positions in the crystal by symmetry. The **cell atom
list**, equivalently called the **complete atom list**, contains all
atoms in the current unit cell. The non-equivalent atom list
reproduces the complete atom list by applying all symmetry operations
(except lattice translations) known to critic2.

The atoms in each of those two lists are numbered. The integer
identifier for an atom in the non-equivalent atom list is symbolized
in this manual as "nat.i". The integer identifier for an atom in the
complete atom list is "at.i". The concise syntax.txt file follows the
same notation. The distinction between atoms from the complete list
and from the non-equivalent list is irrelevant in the case of
molecules, because symmetry is not used (and hence both lists are the
same).

In exact parallel to the atomic lists, critic2 also maintains a list
of non-equivalent critical points (CP) and a complete (or cell) list
of critical points found for a given scalar field. The CPs in the
non-equivalent list reproduce all the CPs in the complete list by
symmetry, and both lists are the exactly the same in molecules because
symmetry is not used. The keyword definitions in this manual and in
syntax.txt use "ncp.i" for the integer indices in the non-equivalent
CP list, and "cp.i" for the integer identifiers in the complete CP
list.

Since in critic2 atoms are considered critical points always, the
non-equivalent (complete) atom list is a subset of the non-equivalent
(complete) CP list. Critic2 makes sure that the integer identifier for
all atoms in the atomic lists are the same as in the corresponding CP
lists. For instance, if an atom has index nat.i = 2 and at.i = 5, then
necessarily ncp.i = 2 and cp.i = 5, regardless of how many additional
critical points have been found for this system.

In most critic2 keywords, atoms can be selected by their atomic symbol
("at.s" in the syntax definitions), in which case the keyword applies
to all atoms with the same atomic number unless otherwise
stated. Atoms can also be selected by an integer identifier from the
non-equivalent atom list ("nat.i" in the definitions) in those cases
in which symmetry makes it irrelevant which of the symmetry-equivalent
atoms in the cell are used. For example, the non-equivalent atom
identifier can be used to instruct critic2 to calculate the charge
of a certain atom. Because all symmetry-equivalent atoms have the same
charge, it is not necessary to specify which atom from the complete
list we want, so the non-equivalent list is used instead.

Some additional notation and terms that will be used in the rest
of the manual are:

* By **scalar field** or **field** we mean a numerical or analytical
  representation of a function that associates a scalar value to every
  point in space. Most of the time, this function is the electron
  density, for which special techniques are provided (for instance,
  core augmentation in the case of valence densities, see ZPSP
  below). However, critic2 can deal with any scalar field, and
  examples other than the density are the ELF, the Laplacian, etc.

* The **promolecular density** is the scalar field built by using the
  sum of the in-vacuo atomic densities. This object comes up in a
  number of contexts. For instance, NCIPLOT and HIRSHFELD use it. The
  promolecular density does not require any input from the user other
  than the crystal or molecular structure, and is always available
  under field identifier $0 (or $rho0).

* We denote by <root> the root of the input file. That is, the name of
  the file without the extension. If no input file is known (for
  instance, because critic2 was run as 'critic2 < inputfile'), then
  the root defaults to "stdin". The default root can be changed with
  the keyword ROOT (see `Control commands and options`_).

* The critical points of a field can be classified by their **rank**
  (r) and **signature** (s). The rank is the number of non-zero
  eigenvalues of the Hessian. In the vast majority of cases, r =
  3. The signature is the number of positive eigenvalues minus the
  number of negative eigenvalues. s = -3 is a maximum, s = -1 is a
  first-order saddle point, s = +1 is a second-order saddle point and
  s = 3 is a minimum. These four types of critical points receive
  special names: nuclear CP, bond CP, ring CP, and cage CP,
  respectively. The abbreviations ncp, bcp, rcp, and ccp are also used
  throughout the manual and in the output. Note that a maximum is a
  "nuclear critical point" even though it may not be associated to any
  nucleus.

## Input and output units

The default input and output units in critic2 are bohr for crystals
(if the structure is loaded using the CRYSTAL keyword) and angstrom
for molecules (if the MOLECULE keyword is used). This default behavior
can be changed with the UNITS keyword:
~~~
UNITS {BOHR|AU|A.U.|ANG|ANGSTROM}
~~~
This keyword changes the units of all distances in input and output.

## Input/Output for a crystal

As an example, let us consider an input for the conventional cell of
the fluorite (CaF2) crystal:
~~~
CRYSTAL
 SPG f m -3 m
 CELL 5.463 5.463 5.463 90 90 90 ANG
 NEQ 0 0 0 ca
 NEQ 1/4 1/4 1/4 f
ENDCRYSTAL
~~~
The non-equivalent atom list contains two atoms: Ca at (0 0 0) with
multiplicity 4 and F at (1/4 1/4 1/4) with multiplicity 8. The cell
atom list contains twelve atoms: four Ca atoms at (0 0 0), (1/2 1/2
0), etc. and eight F atoms at (1/4 1/4 1/4), (3/4 1/4 1/4), etc.

The output for this example follows. First, the output gives the
header with some information about the system, the version (the commit
number), and the location of the relevant library and density files:
~~~
                  _   _     _          ___
                 (_) | |   (_)        |__ \
     ___   _ __   _  | |_   _    ___     ) |
    / __| | '__| | | | __| | |  / __|   / /
   | (__  | |    | | | |_  | | | (__   / /_
    \___| |_|    |_|  \__| |_|  \___| |____|

* CRITIC2: analysis of real-space scalar fields in solids
           and molecules.
  (c) 1996-2015 A. Otero-de-la-Roza, A. Martin-Pendas, V. Lua~na
  Distributed under GNU GPL v.3 (see COPYING for details)
  Bugs, requests, and rants: alberto@fluor.quimica.uniovi.es
  If you find this software useful, please cite:
  AOR, Comput. Phys. Commun. 185 (2014) 1007-1018.
  AOR, Comput. Phys. Commun. 180 (2009) 157-166.

+ critic2, commit e7c2707
 compile host: Linux puck 4.2.0-1-amd64 #1 SMP Debian
 compile date: Wed Oct 21 18:39:47 PDT 2015
    using f77: ifort -g
          f90: ifort -g -FR -fopenmp
      ldflags:
       debug?: no
 compiled dat: /usr/local/share/critic2
      datadir: /home/alberto/git/critic2/dat
     dic file: /home/alberto/git/critic2/dat/cif_core.dic
...was found?:  T

CRITIC2--2015/10/21, 23:08:09.362
~~~
After the CRYSTAL keyword is read, critic2 first lists the basic
information about the crystal (note that the input lines read are
copied to the output preceded by the "%%" prefix), starting with the
cell parameters and the number of atoms in the crystal motif:
~~~
%% CRYSTAL
%% SPG f m -3 m
%% CELL 5.463 5.463 5.463 90 90 90 ANG
%% NEQ 0 0 0 ca
%% NEQ 1/4 1/4 1/4 f
%% ENDCRYSTAL
* Input crystal data
  From: <input>
  Lattice parameters (bohr): 10.323763  10.323763  10.323763
  Lattice parameters (ang): 5.463100  5.463100  5.463100
  Lattice angles (degrees): 90.000  90.000  90.000
  Molecular formula:
    Ca(1) F(2)
  Number of non-equivalent atoms in the unit cell: 2
  Number of atoms in the unit cell: 12
  Number of electrons: 152
~~~
Next comes the non-equivalent atom list. In this case, the whole
crystal is generated by replicating two atoms: one Ca and one F. The
positions, multiplicities, and the atomic numbers are indicated:
~~~
+ List of non-equivalent atoms (cryst. coords.):
# nat     x       y       z    name mult  Z
   1   0.0000  0.0000  0.0000   ca    4  20
   2   0.2500  0.2500  0.2500   f     8   9
~~~
The next table is the complete atom list. Here, critic2 lists all the
atoms in the unit cell: four Ca and eight F. The exact same list is
repeated in Cartesian coordinates, referred to the internal coordinate
framework used in critic2.
~~~
+ List of atoms in the unit cell (cryst. coords.): 
# at      x       y       z     name  Z  
   1   0.0000  0.0000  0.0000    ca   20 
   2   0.0000  0.5000  0.5000    ca   20 
   3   0.5000  0.0000  0.5000    ca   20 
   4   0.5000  0.5000  0.0000    ca   20 
   5   0.2500  0.2500  0.2500    f    9  
   6   0.2500  0.7500  0.7500    f    9  
   7   0.7500  0.2500  0.7500    f    9  
   8   0.7500  0.7500  0.2500    f    9  
   9   0.7500  0.7500  0.7500    f    9  
  10   0.7500  0.2500  0.2500    f    9  
  11   0.2500  0.7500  0.2500    f    9  
  12   0.2500  0.2500  0.7500    f    9  

+ List of atoms in Cartesian coordinates (bohr): 
# at      x       y       z     name  Z
   1   0.0000  0.0000  0.0000    ca   20 
   2   0.0000  5.1617  5.1617    ca   20 
   3   5.1617  0.0000  5.1617    ca   20 
   4   5.1617  5.1617  0.0000    ca   20 
   5   2.5808  2.5808  2.5808    f    9
   6   2.5808  7.7426  7.7426    f    9
   7   7.7426  2.5808  7.7426    f    9
   8   7.7426  7.7426  2.5808    f    9
   9   7.7426  7.7426  7.7426    f    9
  10   7.7426  2.5808  2.5808    f    9
  11   2.5808  7.7426  2.5808    f    9
  12   2.5808  2.5808  7.7426    f    9
~~~
Following this information comes the cell volume, in atomic units and
in cubed angstrom:
~~~
+ Cell volume (bohr^3): 1100.30746
+ Cell volume (ang^3): 163.04874
~~~
And then the list of symmetry operations:
~~~
+ List of symmetry operations (48):
  Operation 1:
     1.000000  0.000000  0.000000  0.000000
     0.000000  1.000000  0.000000  0.000000
     0.000000  0.000000  1.000000  0.000000
  Operation 2:
     0.000000  0.000000 -1.000000  0.000000
    -1.000000  0.000000  0.000000  0.000000
     0.000000 -1.000000  0.000000  0.000000
[...]
  Operation 48:
     0.000000  1.000000  0.000000  0.000000
     0.000000  0.000000  1.000000  0.000000
    -1.000000  0.000000  0.000000  0.000000

+ List of centering vectors (4):
  Vector 1: 0.000000  0.000000  0.000000
  Vector 2: 0.000000  0.500000  0.500000
  Vector 3: 0.500000  0.000000  0.500000
  Vector 4: 0.500000  0.500000  0.000000

+ Centering type (p=1,a=2,b=3,c=4,i=5,f=6,r=7): 6
~~~
The Cartesian/crystallographic transformation matrices are the
transformation operations between the vector basis formed by the cell
vectors (crystallographic coordiantes) and the internal Cartesian axes
used in critic2 (Cartesian coordinates). The crystallographic to
Cartesian matrix ("crys to car") gives the cell vectors in Cartesian
axes. The metric tensor is the transpose of "crys to car" times "crys
to car", and contains the scalar products between lattice vectors. 
~~~
+ Car/crys coordinate transformation matrices:
  A = car to crys (xcrys = A * xcar, bohr^-1)
       0.0968656798    -0.0000000000    -0.0000000000 
       0.0000000000     0.0968656798    -0.0000000000 
       0.0000000000     0.0000000000     0.0968656798 
  B = crys to car (xcar = B * xcrys, bohr)
      10.3235738640     0.0000000000     0.0000000000 
       0.0000000000    10.3235738640     0.0000000000 
       0.0000000000     0.0000000000    10.3235738640 
  G = metric tensor (B'*B, bohr^2)
     106.5761773245     0.0000000000     0.0000000000 
       0.0000000000   106.5761773245     0.0000000000 
       0.0000000000     0.0000000000   106.5761773245 
~~~
Some more information about crystal symmetry follows, including the
list of operations in chemical notation (and their principal axes),
the crystal point group, the Laue class and the cyrstal system:
~~~
+ Symmetry operations (rotations) in chemical notation:
  1    E    ( 0.00000,  0.00000,  0.00000)
  2    S3   (-0.57735, -0.57735, -0.57735)
  3    C4   ( 0.00000,  0.00000,  1.00000)
  [...]
  48   S3   (-0.57735,  0.57735, -0.57735)

+ Crystal point group: Oh
+ Number of operations (point group): 48
+ Laue class: m-3m
+ Crystal system: cubic
~~~
The next few lines give the number of atoms contributing to the
density in the main cell (the cell at the origin of the lattice). This
is the set of atoms around the main cell whose in vacuo atomic density
contribution to the main cell is more than a certain threshold. These
"atomic environments" are used in certain applications of critic2 that
involve quantites that break the translational symmetry of the crystal
(e.g. calculating the promolecular density at a point in space).
~~~
+ Building the atomic environment of the main cell
  Number of atoms contributing density to the main cell: 15972
~~~
A list of nearest-neighbor shells for all atoms in the non-equivalent
list follows, together with information about the nearest-neighbor
distance, the faces of the Wigner-Seitz cell (these are used to
calculate distances between non-equivalent atoms), and, finally,
whether the input cell is orthogonal:
~~~
+ Atomic environments (distances in bohr)
#  id   atom   nneig     distance  nat   type      
   1     ca      8       4.4702386   2    f         
         ...    12       7.2998691   1    ca        
         ...    24       8.5598553   2    f         
         ...     6      10.3235739   1    ca        
         ...    24      11.2498538   2    f         
         ...    24      12.6437441   1    ca        
         ...    32      13.4107158   2    f         
         ...    12      14.5997382   1    ca        
         ...    48      15.2687717   2    f         
         ...    24      16.3230035   1    ca        
   2      f      4       4.4702386   1    ca        
         ...     6       5.1617869   2    f         
         ...    12       7.2998691   2    f         
         ...    12       8.5598553   1    ca        
         ...     8       8.9404772   2    f         
         ...     6      10.3235739   2    f         
         ...    12      11.2498538   1    ca        
         ...    24      11.5421065   2    f         
         ...    24      12.6437441   2    f         
         ...    16      13.4107158   1    ca        

+ List of half nearest neighbor distances (bohr)
   id   atom      rnn/2    
   1     ca      2.2351193 
   2      f      2.2351193 

+ Lattice vectors for the Wigner-Seitz neighbors
   1:  0  0 -1
   2:  0  1  0
   3: -1  0  0
   4:  1  0  0
   5:  0  0  1
   6:  0 -1  0

+ Is the cell orthogonal? T
~~~
Critic2 always has a "reference" scalar field defined. The reference
is the field that, for instance, provides the attraction basins
integrated when calculating atomic charges, or whose critical points
are determined by AUTO. In absence of any external field loaded by the
user, critic2 defaults to using the promolecular density (the sum of
atomic densities) as reference. The information that follows in the
output shows how critic2 builds the promolecular density. First, the
atomic numbers and charges are identified, the number of electrons is
counted, and then the density tables for the appropriate atoms are
loaded from external files:
~~~
* Atomic radial density grids
+ List of atoms and charges:
# nat  atom    Z    Q  ZPSP
    1   Ca    20    0   -1
    2    F     9    0   -1

+ Number of electrons: 152
+ Number of valence electrons: 152
+ Number of core electrons: 0

+ Reading new promolecular density grids
+ Read density file: ca_pbe.wfc
  Log grid (r = a*e^(b*x)) with a = 1.2394E-04, b = 2.0E-03
  Num. grid points = 5855, rmax (bohr) = 15.0633965
  Integrated charge = 19.9999732987
  El. conf.: 1S(2)2S(2)2P(6)3S(2)3P(6)4S(2)
+ Read density file: f__pbe.wfc
  Log grid (r = a*e^(b*x)) with a = 2.7542E-04, b = 2.0E-03
  Num. grid points = 5161, rmax (bohr) = 8.3542920
  Integrated charge = 8.9999953160
  El. conf.: 1S(2)2S(2)2P(5)

+ Reading new core density grids
~~~
Finally, the just-built promolecular density is made available to the
user through the field identifier $0 (also, $rho0), and it is set as
reference. A list of the current integrable properties is also
given. This is the list of properties that would be integrated in the
attraction basins if the user runs INTEGRALS or any of the other
integration methods:
~~~
* Field number 0 is now REFERENCE.

* Integrable properties list
#  Id  Type  Field  Name
    1   v        0  Volume
    2  fval      0  Charge
    3  lval      0  Lap
~~~
The execution finishes with a report of the warnings found and the
timestamp. It is always a good idea to check for warnings in the
output:
~~~
CRITIC2 ended succesfully (0 WARNINGS, 0 COMMENTS)

CRITIC2--2015/5/25, 13:06:32.168
~~~

## Input/Output for a molecular

Molecular structures are read in critic2 using the MOLECULE keyword. A
simple example for a water molecule is:
~~~
MOLECULE
  O 0.000000 0.000000 0.118882
  H 0.000000 0.756653 -0.475529
  H 0.000000 -0.756653 -0.475529
ENDMOLECULE
~~~
Unlike in CRYSTAL, the coordinates in the MOLECULE environment are
Cartesian coordinates. The default units in and after a MOLECULE
keyword are angstrom.

The output starts off with the same header as in CRYSTAL, and then:
~~~
%% MOLECULE
%% O 0.000000 0.000000 0.118882
%% H 0.000000 0.756653 -0.475529
%% H 0.000000 -0.756653 -0.475529
%% ENDMOLECULE
* Input molecular structure
  From: <input>
  Encompassing cell dimensions (bohr): 20.0 22.8 21.1
  Encompassing cell dimensions (ang): 10.5 12.0 11.1
  Number of atoms: 3
  Number of electrons: 10
~~~
The output shows a copy of the input lines (after the "%%" prefix),
and some general information about the structure. Critic2 works under
periodic boundary conditions, even for molecular structures. The
difference is that the molecule is placed into a very large unit cell
to mimic gas-phase conditions. However, critic2 treats the molecule in
the same way as a crystal, converting the atomic coordinates to
"crystallographic" coordinates inside the supercell. In the "Input
molecular structure" output, critic2 shows the dimension of this cell
in bohr and angstrom, and the number of atoms and electrons in the
molecule. Keywords are available in the MOLECULE keyword and
environment for changing the size and shape of the encompassing
cell. 

After that comes the list of atoms in Cartesian coordinates (angstrom
units):
~~~
+ List of atoms in Cartesian coordinates (ang): 
# at      x       y       z  name  Z
   1  0.0000  0.0000  0.1188   o   8
   2  0.0000  0.7566 -0.4755   h   1
   3  0.0000 -0.7566 -0.4755   h   1
~~~
Contrary to CRYSTAL, two atom lists (non-equivalent and complete) are
not necessary because symmetry is automatically deactivated. So when
using MOLECULE, at.i and nat.i in the keyword syntax are completely
equivalent, and refer to the first column numbers in the previous
table. 

In molecular structures, the molecule is placed inside a big cell that
tries to model the empty space around the molecule. This, however, may
lead to some problems with critic2's methods. For instance, the
critical point search will find that at the border of the supercell
the density is discontinuous (because critic2 uses periodic boundary
conditions) and report spurious CPs. Likewise, the gradient path
tracing routines can become trapped at the border of the cell. To
prevent this, MOLECULE defines by default a second cell, slightly
smaller than the encompassing cell defined above. This "molecular
cell" (see `The molecular structure`_) represents the valid
molecular 
space for the current structure. Regions outside the molecular cell
(esssentially, the border of the encompassing cell) can not be
traversed by gradient paths and can not hold any critical
points. Essentially, the border of the encompassing cell becomes a
representation of infinity for the gas-phase molecule under study. 

The dimensions of the molecular cell are given next in the output:
~~~
+ Limits of the molecular cell (in fractions of the cell).
  The region of the encompassing cell outside the 
  molecular cell is assumed to represent infinity (no 
  CPs or gradient paths in it).
  x-axis: 0.1000 -> 0.9000
  y-axis: 0.0875 -> 0.9125
  z-axis: 0.0947 -> 0.9053
~~~
where the limits are given in fractional coordinates of the
encompassing cell. That is, the molecular cell goes from 0.1 to 0.9 of
the encompassing cell (given above) in the x direction, etc. The
remaining 10% of the cell in each direction becomes the forbidden zone
for the structure.

After this, the output is very similar to CRYSTAL, except the output
related to the crystal symmetry is not present. The atomic
environments and nearest neighbor distances (all in angstrom) are
shown next:
~~~
+ Atomic environments (distances in ang)
#  id   atom   nneig     distance  nat   type      
   1      o      2       0.9622101   2    h         
   2      h      1       0.9622101   1    o         
         ...     1       1.5133060   3    h         
   3      h      1       0.9622101   1    o         
         ...     1       1.5133060   2    h         

+ List of half nearest neighbor distances (ang)
   id   atom      rnn/2    
   1      o      0.4811050 
   2      h      0.4811050 
   3      h      0.4811050 
~~~
Then the program prepares for calculating the promolecular density by
identifying and loading the atomic density grids:
~~~
* Atomic radial density grids
+ List of atomic charges and atomic numbers
# nat  name    Z    Q  ZPSP
    1    o     8    0   -1
    2    h     1    0   -1
    3    h     1    0   -1

+ Number of electrons: 10
+ Number of valence electrons: 10
+ Number of core electrons: 0

* Reading new promolecular density grids
+ Read density file: o__pbe.wfc
  Log grid (r = a*e^(b*x)) with a = 3.0984E-04, b = 2.0E-03
  Num. grid points = 5142, rmax (bohr) = 9.0481332
  Integrated charge = 7.9999938286
  El. conf.: 1S(2)2S(2)2P(4)
+ Read density file: h__pbe.wfc
  Log grid (r = a*e^(b*x)) with a = 2.4788E-03, b = 2.0E-03
  Num. grid points = 4153, rmax (bohr) = 10.0141591
  Integrated charge = 0.9999910815
  El. conf.: 1S(1)

* Reading new core density grids
~~~
And, finally, the promolecular density is set as the reference field
and the default integrable properties are set:
~~~
* Field number 0 is now REFERENCE.

* List of integrable properties
#  Id  Type  Field  Name
    1   v        0  Volume
    2  fval      0  Charge
    3  lval      0  Lap

CRITIC2 ended succesfully (0 WARNINGS, 0 COMMENTS)

CRITIC2--2015/10/23, 23:18:42.312
~~~~

