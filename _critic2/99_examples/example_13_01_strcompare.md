---
layout: single
title: "Compare molecular and crystal structures"
permalink: /critic2/examples/example_13_01_strcompare/
excerpt: "Compare molecular and crystal structures"
sidebar:
  - repo: "critic2"
    nav: "critic2_examples"
toc: true
toc_label: "Compare molecular and crystal structures"
---

## Introduction

This page contains a set of examples that shows how to compare
molecular and crystal structures using critic2.

There are different comparison methods implemented, depending on
whether molecules or crystals are being compared but, in general, they
all render a value for the similarity of a chosen pair of structures,
and it is up to the user to then decide whether the structures are
considered "the same" or "different". The interface to the comparison
methods is the [COMPARE](/critic2/manual/compare/) keyword in general
and [COMPAREVC](/critic2/manual/comparevc/) for comparisons between
crystal structures allowing for cell distortions. We focus on COMPARE
for now.

The simplest way to use the COMPARE keyword is to simply list the
structures after the keyword:
```
COMPARE file1.xyz file2.cif file3.in . file4.out
```
where any of the [formats supported by critic2](/critic2/softwarecompat/)
are allowed and `.` represents the system that has been loaded by a
previous [CRYSTAL](/critic2/manual/crystal/#c2-crystal) or
[MOLECULE](/critic2/manual/molecule/#c2-molecule) command.

## Comparing Molecules

### Atoms Are in the Same Order

There are several different ways of comparing molecules. The most
important point about molecular comparison is whether the atomic
sequence is the same in all the structures being compared, that is, if
the atoms and their coordinates as they appear in the corresponding
structure files can be assumed to be in the same order. If this is the
case, then the comparison is much simpler and you should use the
SORTED keyword. For instance, the `HIS_TYR_HIS` molecule in the
example contains a tripeptide from the
[PEPCONF library](https://doi.org/10.1038/sdata.2018.310). The three
variants of this structure are:

* `HIS_TYR_HIS_0.xyz`: the original structure calculated at the
  LC-wPBE-XDM/aug-cc-pVTZ level of theory.

* `HIS_TYR_HIS_0-rattle.xyz`: the same structure with a 0.02 standard
  deviation rattle imposed using [ASE](https://wiki.fysik.dtu.dk/ase/index.html).

* `HIS_TYR_HIS_0-sto3g.xyz`: the same structure after relaxation with
  B3LYP/STO-3G.

(The choice of `xyz` as the format for these files is immaterial; any
format accepted by critic2 can be used.)
Neither the rattle nor the geometry relaxation alter the order of the
atoms in this molecule, and therefore the comparison can be carried
out assuming the atomic sequence is the same, with:
~~~
compare sorted HIS_TYR_HIS_0-sto3g.xyz HIS_TYR_HIS_0-rattle.xyz HIS_TYR_HIS_0.xyz
~~~
For a given pair of molecules, the comparison is carried out by
translating the centers of mass of both molecules to the origin and
then finding the rotation that brings one of them in closest agreement
with the other in the least-squares sense. The output is:
```
* COMPARE: compare structures
  Molecule 1 : HIS_TYR_HIS_0-sto3g.xyz
  Molecule 2 : HIS_TYR_HIS_0-rattle.xyz
  Molecule 3 : HIS_TYR_HIS_0.xyz
# Assuming the atom sequence is the same in all molecules.
# RMS of the atomic positions in bohr
   Molecule     HIS_TYR_HIS_0-sto3g.xyz HIS_TYR_HIS_0-rattle.xyz HIS_TYR_HIS_0.xyz
      RMS                     1               2               3
  HIS_TYR_HIS_0-sto3g.xyz   0.0000000       2.5006092       2.4935909
  HIS_TYR_HIS_0-rattle.xyz  2.5006092       0.0000000       0.0599950
  HIS_TYR_HIS_0.xyz         2.4935909       0.0599950       0.0000000
```
where the individual values represent the root-mean-square (RMS) of
the deviations in the atomic positions in bohr (the units can be
changed using the [UNITS](/critic2/manual/inputoutput/#c2-units) keyword).
Note how the RMS is about 0.03 angstrom for the rattled structure,
consistent with the rattling parameter used in ASE.

### Atoms Are Not in the Same Order

The comparison problem becomes considerably trickier if the atomic
sequences are not in the same order. Consider the structure:

* `HIS_TYR_HIS_0-shuf.xyz`: the same structure as
  `HIS_TYR_HIS_0-rattle.xyz` but with a random permutation applied on
  the atoms.

In this case, there are two options: either a method is applied to try
to put the atoms in order or a comparison method is used for which the
order of the atomic sequence is irrelevant. The recommended procedure
is to use
[Ullmann's graph matching algorithm](https://doi.org/10.1145/321921.321925),
which is the default if no keywords are passed to COMPARE:
```
compare HIS_TYR_HIS_0-rattle.xyz HIS_TYR_HIS_0-shuf.xyz HIS_TYR_HIS_0.xyz
```
This method tries to match the molecular graph of one molecule onto
the other based on the atomic connectivity by exploring all possible
permutations, with tricks to shorten the search. Ullmann's method can
be expensive particularly for branching molecules with symmetric (in
the molecular graph sense) substituents. Once the two atomic sequences
are in the same order, the comparison proceeds as in the ordered case:
```
* COMPARE: compare structures
  Molecule 1 : HIS_TYR_HIS_0-rattle.xyz
  Molecule 2 : HIS_TYR_HIS_0-shuf.xyz
  Molecule 3 : HIS_TYR_HIS_0.xyz
# Using Ullmann's graph matching algorithm.
# RMS of the atomic positions in bohr
   Molecule     HIS_TYR_HIS_0-rattle.xyz HIS_TYR_HIS_0-shuf.xyz HIS_TYR_HIS_0.xyz
      RMS              1               2               3
  HIS_TYR_HIS_0-rattle.xyz  0.0000000       0.0000000       0.0599950
  HIS_TYR_HIS_0-shuf.xyz    0.0000000       0.0000000       0.0599950
  HIS_TYR_HIS_0.xyz         0.0599950       0.0599950       0.0000000
```
Note how the RMS between the rattled structure and the same structure
with shuffled atoms is zero, and the RMS of both of them with the
original structure is the same value as above.

## Comparing Crystals

The recommended procedure for comparing crystal structures is to use
powder diffraction patterns (see the [POWDER](/critic2/manual/structure/#c2-powder)
keyword) and then compare them using cross-correlation functions as
described by
[de Gelder et al.](https://doi.org/10.1002/1096-987X(200102)22:3%3C273::AID-JCC1001%3E3.0.CO;2-0).
In this method, the powder diffractograms of the two crystals are
calculated with some arbitrary, but reasonable, parameters for peak
shapes and sizes, incident wavelength, etc. Unlike the molecular
comparison, this method does not rely on the atoms being in the same
order. In the provided example three structures are given:

* `uracil.cif`: the uracil structure from the critic2 structure
  library.

* `urea.cif`: the urea structure from the critic2 structure library.

* `urea-rattle.cif`: the same urea structure but with a 0.02 standard
  deviation rattle imposed using [ASE](https://wiki.fysik.dtu.dk/ase/index.html).

* `urea-bigrattle.cif`: the same urea structure but with a 1.0 standard
  deviation rattle imposed using
  [ASE](https://wiki.fysik.dtu.dk/ase/index.html). This essentially
  destroys the molecular structure.

(The choice of `cif` as the format for these files is immaterial; any
format accepted by critic2 can be used.) To compare them, use:
```
compare urea.cif urea-rattle.cif urea-bigrattle.cif uracil.cif
```
and the result is:
```
* COMPARE: compare structures
  Crystal 1 : urea.cif
  Crystal 2 : urea-rattle.cif
  Crystal 3 : urea-bigrattle.cif
  Crystal 4 : uracil.cif
# Using cross-correlated POWDER diffraction patterns.
# Please cite:
#   de Gelder et al., J. Comput. Chem., 22 (2001) 273
# Two structures are exactly equal if DIFF = 0.
    Crystal        urea.cif     urea-rattle.cif urea-bigrattle.cif   uracil.cif
     DIFF              1               2               3               4
  urea.cif            0.0000000       0.0000248       0.2463948       0.9384096
  urea-rattle.cif     0.0000248       0.0000000       0.2448225       0.9385707
  urea-bigrattle.cif  0.2463948       0.2448225       0.0000000       0.8963729
  uracil.cif          0.9384096       0.9385707       0.8963729       0.0000000
```
The similarity index calculated by this method goes between 0 and 1,
which 0 being a perfect match and 1 complete dissimilarity. Note how
the small rattle gives a urea structure that is essentially coincident
with the original, whereas a big rattle results in a much higher
value, and the uracil and urea structures have nothing in common.

## Determining Repeated and Unique Structures

An operation that is commonly carried out with the COMPARE keyword is
to determine, from a (large) list of structures, which of them are
unique and which are repeated. This can be easily accomplished with
the REDUCE option to COMPARE, which works similar to normal COMPARE,
but skips over structures that have already been determined to be
equivalent to others in the list. For instance, if we wanted to
compare a list of 50 very similar structures we would do:
```
COMPARE REDUCE 1e-6 str-001.POSCAR str-002.POSCAR str-003.POSCAR \
  str-004.POSCAR ...
```
This means that two of the crystal structures in the list are
considered equal if the difference in their powder diffraction
patterns is less than 1e-6, calculated as in the example above. The
output of COMPARE/REDUCE contains the following parts. First, the
powder diffraction difference values are reported:
```
     DIFF              1               2               3               4               5
  str-001.POSCAR  not-calculated   0.0007855       0.0007439       0.0007439       0.0007855
  str-002.POSCAR   0.0007855      not-calculated   0.0000701       0.0000701      not-calculated
  str-003.POSCAR   0.0007439       0.0000701      not-calculated  not-calculated  not-calculated
  str-004.POSCAR   0.0007439       0.0000701      not-calculated  not-calculated  not-calculated
...
```
where some of the difference values were not calculated, because some of
the structures were determined to be equivalent to others at the
requested level (i.e. their DIFF was lower than 1e-6). This cuts down
the computational cost of the COMPARE/REDUCE calculation significantly.
After this, the list of unique structures is listed:
```
+ List of unique structures (15):
1: str-001.POSCAR with multiplicity 1
2: str-002.POSCAR with multiplicity 4
3: str-003.POSCAR with multiplicity 7
6: str-006.POSCAR with multiplicity 3
...
```
where the "multiplicity" is the number of repeated structures in the
original list corresponding to the given unique representative
structure. Lastly, the repeated structures are listed, along with
their unique representative from the list above:
```
+ List of repeated structures (34):
4: str-004.POSCAR same as 3: str-003.POSCAR
5: str-005.POSCAR same as 2: str-002.POSCAR
9: str-009.POSCAR same as 3: str-003.POSCAR
10: str-010.POSCAR same as 7: str-007.POSCAR
11: str-011.POSCAR same as 6: str-006.POSCAR
...
```

## Comparing Crystals Allowing for Cell Distortions (VC-PWDF)

The variable-cell powder diffraction comparison (VC-PWDF) method is
used to compared two crystal structures. It is similar to the plain
powder diffraction comparison method described above, but it is
designed to give a high similarity index when one of the structures is
a lattice distortion of the other. This can happen, for instance, due
to the effect of temperature or pressure, or when comparing a
calculated structure with an experimental one. VC-PWDF works by
designating one of the structures as reference and the other as
candidate, which are first both transformed into their reduced
cells. All possible transformations of the primitive cell of the
candidate structures are explored that brings it into (rough) agreement
with the reference primitive cell. Then, the candidate adopts the cell
parameters of the primitive cell and the powder diffractogram
similarity index is calculated. The process is repeated for all
possible cell transformations and the final VC-PWDF value is the
minimum of all calculated similarity indices. The algorithm for the
VC-PWDF method is described in detail in
[Mayo et al.](https://pubs.rsc.org/en/content/articlehtml/2022/ce/d2ce01080a).

Because it involves several (sometimes many) powder diffraction
generation and comparison steps, VC-PWDF is slower than the usual
powder diffraction comparison and it should not be used unless lattice
distortions are expected to be important. A VC-PWDF value of 0.03 or
lower indicates considerable similarity and a probable match, although
user discretion is recommended.

To compare two structures using the VC-PWDF method, use the
[COMPAREVC](/critic2/manual/comparevc/) keyword:
~~~
COMPAREVC xtal1.cif xtal2.cif
~~~
The output shows which structure is being used as reference and which
is the candidate, the reduced cell lattice vectors for both, the list
of transformed candidate lattice vectors, and the calculated powder
diffraction similarity values for each transformation. The final
VC-PWDF value is given at the end, calculated as the minimum of the
similarity indices for all candidates. Note that, unlike
[COMPARE](/critic2/manual/compare/),
[COMPAREVC](/critic2/manual/comparevc/) cannot compare more than two
structures at a time. Hence, if you want to compare a list of
structures, you will need to repeat COMPAREVC as many times as
necessary.

After the two crystals are compared, COMPAREVC can be used to write
the transformed structures that most resemble each other, that is, the
ones that generated the final VC-PWDF value. This is done by using the
`WRITE` option:
~~~
COMPAREVC xtal1.cif xtal2.cif WRITE
~~~
which generates two `.res` files (`<root>_structure_1.res` and
`<root>_structure_2.res`), one of each of the crystal structures that
yielded the VC-PWDF score. Likewise, the powder diffraction patterns
of the original or deformed structures can be compared using the
[POWDER](/critic2/manual/powder) command.

The same method implemented in COMPAREVC can be used to compare to
experimental powder diffraction patterns, as described in
[Mayo et al.](https://pubs.rsc.org/en/content/articlehtml/2023/sc/d3sc00168g)).
This experimental VC-PWDF (VC-xPWDF) method requires the experimental
diffraction pattern using Cu K&#945; radiation in `.xy` format
(2&#952; (°) vs intensity), the indexed cell dimensions from the
experimental PXRD data, and the crystal structure you wish to compare
to the PXRD data. For now, it can be accessed via:
~~~
TRICK COMPARE PROGST10.cif PROGST-PXRD.xy 10.3741 12.6059 13.8464 90 90.268 90
~~~
where the candidate structure, diffractogram, cell lengths (in bohr)
and cell angles (in degrees) are given. The output is entirely
analogous to [COMPAREVC](/critic2/manual/comparevc/). Same as with
COMPAREVC, the WRITE keyword can be used to write the transformed
structure that best matches the experimental pattern.
A VC-xPWDF score of 0.1 or less implies notable similarity but does
not guarantee a match, so it is recommended that the simulated powder
diffractogram is plotted along with the experimental one.

The VC-PWDF methods cannot be used reliably for disordered structures,
and will yield low scores for certain polytype and conformational
phase structures. In VC-xPWDF, experimental PXRD data that exhibit
considerable baseline require pre-processing, data that show severe
preferred orientation may yield poor results, and removing extraneous
peaks is highly recommended.

You can find scripts and more detailed instructions on how to use
VC-PWDF in VC-xPWDF at [Erin Johnson's software page](https://erin-r-johnson.github.io/software/).

### Example files package

Files: [example_13_01.tar.xz](/assets/critic2/example_13_01/example_13_01.tar.xz).

### Manual pages

- Loading crystal structures with [CRYSTAL](/critic2/manual/crystal/#c2-crystal)

- The [POWDER](/critic2/manual/powder) keyword for simulating powder diffractograms.

- The [COMPARE](/critic2/manual/compare/) keyword.

- The [COMPAREVC](/critic2/manual/comparevc/) keyword.
