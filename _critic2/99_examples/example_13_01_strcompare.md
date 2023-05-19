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
are allowed and `.` representes the system that has been loaded by a
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
the computational cost of the COMARE/REDUCE calculation significantly.
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



## VC-PWDF walk-through

### Overview

The VC-PWDF protocol uses the simulated powder
diffractograms of the two structures in order to yield a dissimilarity value using a cross-correlation
function (ie. a measure of peak overlap,
[J. Comput. Chem., 2001, 22, 273](https://doi.org/10.1002/1096-987X(200102)22:3%3C273::AID-JCC1001%3E3.0.CO;2-0)). The value yielded by the method
is a number between 0 (identical) and 1 (completely dissimilar). We have called this value the "VC-PWDF score",
and a score \< 0.03 indicates considerable similarity and a probable match; however, user discretion is
recommended regarding a cutoff for classifying a "match". The protocol is specifically
designed to be highly effective for the comparison of crystal structures obtained under different conditions;
low/high temperatures, high pressure, or in silico-generated by force field/MM or electronic structure
theory/DFT computational methods.

Details on the development, abilities, and applications (identification of target crystal structures in CSP
landscapes [CrystEngComm, 2021, 23, 7118](https://pubs.rsc.org/en/content/articlehtml/2021/ce/d1ce01058a),
distinguishing the same structure from polymorph structures in the
CSD [CrystEngComm, 2022, 24, 8326](https://pubs.rsc.org/en/content/articlehtml/2022/ce/d2ce01080a),
matching experimental PXRD to crystal structures
 [Chem. Sci., 2023](https://pubs.rsc.org/en/content/articlehtml/2023/sc/d3sc00168g)) are
provided elsewhere.

If you find the VC-PWDF method useful, please cite:
- R.A. Mayo, A. Otero de la Roza, and E.R. Johnson, _CrystEngComm_, **2022**, _24_, 8326-8338.

If you find the VC-xPWDF method useful, please cite:
- R.A. Mayo, K.M. Marczenko, and E.R. Johnson, _Chem. Sci._, **2023**, https://doi.org/10.1039/D3SC00168G.

In either case, please note your usage of critic2 by citing:
- A. Otero-de-la-Roza, E. R. Johnson and V. Luaña, _Comput. Phys. Commun._, **2014**, _185_, 1007-1018.
- A. Otero-de-la-Roza, M. A. Blanco, A. Martín Pendás and V. Luaña, _Comput. Phys. Commun._, **2009**, _180_, 157–166.

### Limitations
The VC-PWDF methods currently only simulate/compare powder diffractograms from Cu K&#945;<sub>1</sub>
radiation, cannot
be used reliably for disordered structures, and will yield low scores for certain polytype and conformational
phase structures. Experimental PXRD data that exhibit considerable amorphous-like baseline require pre-processing; data
that show severe preferred orientation may yield poor results.

### Prerequisits
It is expected that critic2 has been fully installed and that the user has a basic level of Linux familiarity
(read/write files, command line tools and navigation, conditional statements, for-loops). For a more
beginner-level walk-through, the [VC-(x)PWDF instruction manual](https://erin-r-johnson.github.io/software/) posted on the Johnson group web page may be useful.

### Comparing two crystal structures to obtain the VC-PWDF score
#### Interactive
Start an instance of critic2 in a working directory containing the two crystal structure files you wish to
compare. The critic2 command `COMPAREVC` is used to initiate the VC-PWDF protocol to compare the two crystal
structures given (see [here](https://aoterodelaroza.github.io/critic2/manual/crystal/) for compatible crystal
structure file types):
~~~
COMPAREVC xtal1.cif xtal2.cif
~~~
The two crystal structure files that are being compared must be in the working directory, or the relative or
absolute path to the files can be given.

The printed output includes:
- which structure has been used as the refence and which has been designated the candidate structure,
- the Niggli reduced cell lattice vectors and cell dimensions,
- the list of viable lattice vectors of the candidate structure and their matching to the lattice vector(s)
of the reference structure's Niggli cell,
- the [POWDIFF](https://aoterodelaroza.github.io/critic2/manual/structure/#c2-compare) results from comparison of the reference structure to the distorted cells of the candidate
structure,
- The VC-PWDF score is the lowest POWDIFF result, printed at the very end of the output
`+ FINAL Diff = <value>`

#### Input file
The critic2 commands can be written to an input file (`.cri` extension recommend) and run with critic2 non-
interactively.
~~~
critic2 input.cri
~~~
If your interest is only the VC-PWDF score, piping the output through a `grep` command can give you this value:
~~~
critic2 input.cri | grep FINAL
~~~
Simply pipe the output to a file (`.cro` extension recommended) to save it. Sending the output to be printed
into a file allows you to review the protocol run, and save the VC-PWDF score in a file to review later if
necessary.
~~~
critic2 input.cri > output.cro
~~~

### Comparing a list of structures with a target structure
If you are searching a list of structures to see if any match a reference experimental structure that you have
(eg. a CSP landscape for an experimental structure), one way to do this is to generate all the input files
with a for loop. Given the example of the following sample directory:
~~~
target.cif  xx03.cif    xx06.cif    xx09.cif    xx12.cif    xx15.cif
xx01.cif    xx04.cif    xx07.cif    xx10.cif    xx13.cif    xx16.cif
xx02.cif    xx05.cif    xx08.cif    xx11.cif    xx14.cif    xx17.cif
~~~
etc...  where the `target.cif` crystal structure is the reference experimental structure, and the `xx*.cif`
files were generated computationally, a `for` loop to make all the critic2 input files could look like this:
~~~
for i in xx*.cif ; do echo "COMPAREVC target.cif $i" > ${i%.cif}.cri ; done
~~~
which can be run from the command line. A similar `for` loop can be written to run all the new .cri files
through critic2:
~~~
for i in *.cri ; do critic2 $i > ${i%.cri}.cro ; done
~~~

If you have a couple thousand structures to compare, running the comparisons in parallel over N processors
will reduce the total time required to approximately 1/N. This can be done with [parallel](https://www.gnu.org/software/parallel/). If your list of CSP structures is
all contained within one concatenated file, [csplit](https://www.gnu.org/software/coreutils/manual/html_node/csplit-invocation.html) is ideal for creating a unique file for each structure.

Once output files have been generated, a table of results sorted by lowest VC-PWDF score can be made
with the following line:
~~~
for i in *.cro ; do echo -n "${i%.cro}   " ; grep FINAL $i | awk '{print$5}' ; done | sort -n -k2 > results.txt
~~~

### Generating a file of the distorted crystal structure
If you want to view the overlay of the two crystal structures that yield the VC-PWDF score (as a result of the
lattice deformation), add `WRITE` to the end of the command:
~~~
COMPAREVC xtal1.cif xtal2.cif WRITE
~~~

Two `.res` format files will be generated, one of each of the crystal
structures that yielded the VC-PWDF score. The crystal structure entered first after the `comparevc` command
(`xtal1.cif`) will be written
 to the file `stdin_structure_1.res`, and the second structure to `stdin_structure_2.res` (where `stdin` is
replaced by the `filename` of `filename.cri` if using an input file). Review the output information to
determine
whether `xtal1` or `xtal2` was deformed (ie. _not_ the reference). These structures can be viewed in a
GUI of
your choice, compared with other methods, etc...

### Plotting the simulated powder diffractograms
A simulated powder diffractogram can be generated for any crystal structure with critic2 by loading the
crystal structure, then entering the `POWDER` command.
~~~
crystal stdin_structure_2.res
POWDER
~~~

Two files will be generated, a sample gnuplot command file to plot the data with
[gnuplot](http://www.gnuplot.info/) `stdin_xrd.gnu`, and a two-column file of 2&#952; (°) and intensity `stdin_xrd.dat`.  Use a plotting program of your choice to plot the simulated powder patterns.

<figure style="width: 95%" class="align-center">
  <img src="{{ site.url }}{{ site.baseurl }}/assets/critic2/example_13_01/PXRD_overlay-VC.png" alt="VC-PWDF simulated PXRD overlay">
</figure>

## Comparing experimental PXRD data with a crystal structure

The VC-xPWDF method is used to compare experimentally collected powder diffractograms to the simulated powder
diffractograms from crystal structures in order to identify the matching crystal structure to the experimental
powder diffractogram. The VC-xPWDF method requires that experimental powder diffractogram be indexed, our
recommendation for accomplishing this is the [Crysfire2020 program](http://ccp14.cryst.bbk.ac.uk/Crysfire.html). A VC-xPWDF score \< 0.1 implies notable
similarity but does not guarantee a match. It is recommended to plot an overlay of the simulated powder
diffractogram of the best-matching crystal structure and the experimental data in order to confirm a match.
The VC-xPWDF method also provides an optimal starting point for the model structure if one has sufficiently
high quality PXRD data to perform Rietveld refinement. Minimal processing of the experimental PXRD data is
done within the protocol, so if there is a substantial baseline (eg. transmission mode collection), or the
instrument used to collect the data lacks a
Cu K&#945; filter, pre-processing to baseline correct and strip extraneous peaks from radiation not matching
Cu K&#945;<sub>1</sub> is highly recommended for viable results.

#### Required inputs
The following are required to run a VC-xPWDF comparison
- a powder diffractogram from Cu K&#945; diffraction in `.xy` format (2&#952; (°) vs intensity)
- indexed unit cell dimensions from your experimental PXRD data
- a crystal structure you wish to compare to the PXRD data

#### The VC-xPWDF command
While `COMPAREVC` is used to compare two given crystal structures, to run the VC-xPWDF method `trick compare` is used,
followed by the crystal structure file, then the PXRD data file and the indexed unit cell dimensions (a, b, c,
alpha, beta, gamma – in order).
~~~
trick compare PROGST10.cif PROGST-PXRD.xy 10.3741 12.6059 13.8464 90 90.268 90
~~~
The VC-xPWDF value is given at the end of the output `+ FINAL Diff = <value>`.

#### Plotting PXRD overlays
In order to ensure a matching structure, plotting the overlay of the experimental data and simulated powder
diffractogram of the best (lowest VC-xPWDF score) crystal structure is recommended. If you have gnuplot
installed, running the [vc-xpwdf-plot.sh](/assets/critic2/example_13_01/vc-xpwdf-plot.sh) script from the
Linux command line will perform the VC-xPWDF comparison,
generate the simulated powder pattern from the distorted structure, and plot the data for you.
Run with the arguments requested, eg:
~~~
bash vc-xpwdf-plot.sh PROGST10-PXRD PROGST10.cif PROGST-PXRD.xy 10.3741 12.6059 13.8464 90 90.268 90
~~~
to yield the following image in `.pdf` format.

<figure style="width: 95%" class="align-center">
  <img src="{{ site.url }}{{ site.baseurl }}/assets/critic2/example_13_01/PROGST10-overlay.png" alt="PROGST10-PXRD overlay">
</figure>

### Example files package

Files: [example_13_01.tar.xz](/assets/critic2/example_13_01/example_13_01.tar.xz).

### Manual pages

- Loading [crystal structures](/critic2/manual/crystal/#c2-crystal)

- Simulating powder diffractograms from crystal structures [POWDER](/critic2/manual/powder)

- The [COMPARE](/critic2/manual/compare/) keyword

- The [COMPAREVC](/critic2/manual/comparevc/) keyword
