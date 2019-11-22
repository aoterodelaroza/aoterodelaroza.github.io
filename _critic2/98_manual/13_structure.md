---
layout: single
title: "Structural tools"
permalink: /critic2/manual/structure/
excerpt: "Structural tools for crystallographic computations in critic2."
sidebar:
  - repo: "critic2"
    nav: "critic2_manual"
toc: true
toc_label: "Structural tools"
toc_sticky: true
---

## Relabel the Atoms in the Structure (ATOMLABEL) {#c2-atomlabel}

The ATOMLABEL keyword can be used to change the atomic labels for the
atoms in the current structure:
~~~
ATOMLABEL template.s
~~~
The template string (`template.s`) is used to build the new atomic
names. The format specifiers for this template are:

* `%aid`: the index for the atom in the non-equivalent atom list. 

* `%id`: the index for the atom in the non-equivalent atom list,
   counting only the atoms of the same type.

* `%S`: the atomic symbol, derived from the current atomic number.

* `%s`: same as `%S`, but lowercase.

* `%l`: the current atom label.

## Powder Diffraction (POWDER) {#c2-powder}

The keyword POWDER calculates the powder diffraction pattern for the
current crystal structure:
~~~
POWDER [TH2INI t2i.r] [TH2END t2e.r] [{L|LAMBDA} l.r]
       [FPOL fpol.r] [NPTS npts.i] [SIGMA sigma.r]
       [ROOT root.s] [HARD|SOFT]
~~~
Only the $$2\theta$$ range from `t2i.r` (default: 5 degrees) to
`t2e.r` (default: 90 degrees) will be plotted. The wavelength of the
incident radiation is given by `l.r` (in angstrom, default: 1.5406
angstrom, corresponding to Cu-K&alpha;). The polarization of the X-ray
radiation affects the treatment of the resulting intensities. The
default is `fpol.r = 0`, unpolarized light. For synchrotron radiation,
use `fpol.r = 0.95`. `npts.i` is the number of points in the generated
spectrum (deafult: 10001). Gaussian broadening is used on the observed
peaks, with width parameter `sigma.r` (default: 0.05 degrees).

By default, two files are generated: `<root>_xrd.dat`, containing the
$$2\theta$$ versus intensity data, and `<root>_xrd.gnu`, the gnuplot
script to plot it. The name of these files can be changed using the
ROOT keyword. The Miller indices of the peaks are written to the
standard output.

The `HARD` and `SOFT` keywords control how peaks right outside the
plot range are treated. In a `HARD` powder diffraction pattern, the
peaks outside the plot range are not computed, and therefore their
tails will not appear on the plot even if the corresponding peak is so
close that the contribution to the RDF would be significant. In a
`SOFT` powder diffraction pattern, all peaks are computed and
represented, even if the maximum is outside the plot range. Default:
`SOFT`. 

## Radial Distribution Function (RDF) {#c2-rdf}

The RDF keyword calculates the radial distribution function (RDF) for
the current crystal or molecular structure:
~~~
RDF [RINI t2i.r] [REND t2e.r] [SIGMA sigma.r] [NPTS npts.i] 
    [ROOT root.s] [PAIR is1.s is2.s [PAIR is1.s is2.s ...]]
    [HARD|SOFT]
~~~
The definition of RDF is similar to the one found in 
[Willighagen et al., Acta Cryst. B 61 (2005) 29](https://doi.org/10.1107/S0108768104028344),
but where the atomic charges are replaced by the square root of the
atomic number. Each pair of atoms A and B at a distance $$d_{AB}$$ in
the system will create a peak in the RDF with a Gaussian shape:
\begin{equation}
I_{AB}(r) = \sqrt{Z_AZ_B}\times \exp\left(-\frac{(r-d_{AB})^2}{2\sigma^2}\right)
\end{equation}
The RDF is constructed from the sum of all $$I_{AB}(r)$$ functions from all
unique atom pairs by doing:
\begin{equation}
{\rm RDF}(r) = \sum_{A<B} \frac{I_{AB}(r)}{r^2N_{\rm cell}}
\end{equation}
where $$N_{\rm cell}$$ is the number of atoms in the unit cell.

The RDF is plotted from an initial distance `t21.r` (default: 0) up to
a maximum distance `t2e.r` (default: 25 bohr) using `npts.i` points in
that interval (default: 10001). Gaussian broadening is used with sigma
equal to `sigma.r` (default: 0.05 bohr). The default units of `RINI`,
`REND`, and `SIGMA` are bohr in crystals and angstrom in molecules
(this can be changed with the
[UNITS](/critic2/manual/inputoutput/#c2-units) keyword).

Two files are generated: `<root>_rdf.dat`, containing the RDF versus
distance data, and `<root>_rdf.gnu`, the gnuplot script to plot
it. The name of these files can be changed using the ROOT keyword. If
`PAIR` is given, only the distances between atoms of type `is1.s` and
`is2.s` will contribute to the RDF. Multiple `PAIR` keywords can be
used. The `is1.s` and `is2.s` must be the name of an atomic species in
the system.

The `HARD` and `SOFT` keywords control how peaks right outside the
plot range are treated. In a `HARD` RDF, the peaks outside the plot
range are not computed, and therefore their tails will not appear on
the plot even if the corresponding peak is so close that the
contribution to the RDF would be significant. In a `SOFT` RDF, all
peaks are computed and represented, even if the maximum is outside the
plot range. Default: `SOFT`.

## Compare Crystal and Molecular Structures (COMPARE) {#c2-compare}

The COMPARE keywords compares two or more structures:
~~~
COMPARE [MOLECULE|CRYSTAL] [SORTED|UNSORTED] [XEND xend.r] 
        [SIGMA sigma.r] [POWDER|RDF] 
        {.|file1.s} {.|file2.s} [{.|file3.s} ...]
~~~
If the structures are crystals, COMPARE finds
the measure of similarity (DIFF) based on either their radial
distribution functions (RDF keyword) or their powder diffraction
patterns (POWDER). If they are molecules, all atoms in all structures
under comparison may come in the
same order (SORTED) or not (UNSORTED, default). If the atoms are
sorted, COMPARE finds the translation and rotation that brings the two
molecules into closest
agreement and report the root-mean-square (RMS) of the atomic
positions. If the atoms are unsorted, compare the molecules using the
radial distribution functions.

In crystals, the default is to use the powder diffraction
patterns. Two crystal structures are exactly equal if 
`DIFF = 0`. Maximum dissimilarity occurs when `DIFF = 1`.  The crystal
similarity 
measure is calculated using the cross-correlation functions defined in
[de Gelder et al., J. Comput. Chem., 22 (2001) 273](https://doi.org/10.1002/1096-987X(200102)22:3%3C273::AID-JCC1001%3E3.0.CO;2-0),
using the triangle weight. Powder diffraction patterns are calculated
from $$2\theta = 5$$ up to `xend.r` (default: 50). Radial distribution
functions are calculated from zero up to `xend.r` bohr (default: 25
bohr). SIGMA is the Gaussian broadening parameter for the powder
diffraction or RDF peaks. The RDF defaults also apply to comparison
of unsorted molecules.

In sorted molecules, the root mean square (RMS) of the atomic
positions is reported (the units are angstrom, unless changed with the
[UNITS](/critic2/manual/inputoutput/#c2-units) keyword). The molecular
rotation is calculated using Walker et al.'s quaternion algorithm 
([Walker et al., CVGIP-Imag. Understan. 54 (1991) 358](https://doi.org/10.1016/1049-9660(91)90036-O)). 
For the comparison to work correctly, it is necessary that the two
molecules have the same number of atoms and that the atoms are in the
same sequence.

Whether the molecular or the crystal comparison is used depends on the
file formats passed to COMPARE. If the MOLECULE/CRYSTAL keyword is
used then the molecule/crystal comparison code is used.

The structures can be given by passing an external file to
COMPARE. The syntax is the same as in CRYSTAL and MOLECULE: the file
format is identified using the file extension. If a dot (".") is used
instead of a file name, use the current structure (previously loaded
with CRYSTAL/MOLECULE).

The COMPARE keyword does not require a previous CRYSTAL or MOLECULE
keyword. Hence, valid critic2 inputs would be:
~~~
COMPARE bleh1.scf.in bleh2.cif
COMPARE bleh1.xyz bleh2.wfx
~~~
provided the files exist.

## Transform the Unit Cell (NEWCELL) {#c2-newcell}

The NEWCELL keyword transforms the unit cell used to describe the
current crystal structure to a new cell:
~~~
NEWCELL {x1.r y1.r z1.r x2.r y2.r z2.r x3.r y3.r z3.r|n1.i n2.i n3.i} [INV|INVERSE]
        [ORIGIN x0.r y0.r z0.r] 
NEWCELL [PRIMSTD|STANDARD|PRIMITIVE] [REFINE]
NEWCELL [NIGGLI|DELAUNAY]
~~~
The new unit cell is given by the vectors (`x1.r` `y1.r` `z1.r`), 
(`x2.r` `y2.r` `z2.r`), and (`x3.r` `y3.r` `z3.r`) in
crystallographic coordinates relative to the old unit cell. The x1,
x2, x3 vectors must be pure translations of the old cell; either
lattice vectors, centering vectors, or combinations of the
two. Alternatively, if three integers are given (`n1.i` `n2.i` `n3.i`),
NEWCELL builds a supercell with `n1.i` cells in the a direction,
`n2.i` cells in the b direction, and `n3.i` cells in the c direction.

NEWCELL unloads all fields (except the promolecular density) and
clears the critical point list. If the INV (or INVERSE) keyword is
used, the input vectors correspond to the crystallographic coordinates
of the old cell in the new coordinate system. A NEWCELL transformation
is the inverse of the same transformation using the INV keyword. 
Optionally, if an ORIGIN vector is given, (`x0.r` `y0.r` `z0.r`), the
cell origin is translated to x0. The units of x0 are crystallographic
coordinates of the original cell.

The NEWCELL keyword is useful for building supercells or for
performing routine but tedious crystallographic transformations. For
instance, given a face-centered cubic lattice and the conventional
cubic cell one can find the primitive (rhombohedral) cell by doing:
~~~
CRYSTAL LIBRARY mgo
NEWCELL 1/2 1/2 0 1/2 0 1/2 0 1/2 1/2
~~~
Likewise, if the current cell is rhombohedral, the same NEWCELL order
but including the INVERSE keyword transforms to the cubic. That is:
~~~
CRYSTAL LIBRARY mgo
NEWCELL 1/2 1/2 0 1/2 0 1/2 0 1/2 1/2
NEWCELL 1/2 1/2 0 1/2 0 1/2 0 1/2 1/2 INVERSE
~~~
gives a unit cell and crystal structure description that is equivalent
to the initial one read from the library.

NEWCELL also admits specific keywords that perform common
transformations to certain cells of interest. The cell can be
transformed to:

* STANDARD: standard (canonical) unit cell. 

* PRIMITIVE: standard primitive unit cell. Does not transform the cell
  if the unit cell is already primitive.

* PRIMSTD: standard primitive unit cell. Does the transformation even
  if the current unit cell is primitive.

* NIGGLI: Niggli-reduced cell for the current lattice. Use a NEWCELL
  PRIMITIVE first to get the primitive Niggli cell.

* DELAUNAY: Delaunay-reduced cell for the current lattice. Use a
  NEWCELL PRIMITIVE first to get the primitive Delaunay cell.

The origin is not translated by any of these keywords. If the REFINE
keyword is used, then the atomic positions are idealized according to
the space group symmetry operations. For instance, an atomic
coordinate of 0.333 may become 0.3333333... in a hexagonal space
group. REFINE can be used with STANDARD, PRIMITIVE, and PRIMSTD only.
These transformations use the
[spglib](https://atztogo.github.io/spglib/) library. Please consult
the spglib manual for more information.

## Calculate Atomic Environments (ENVIRON) {#c2-environ}

The ENVIRON keyword prints lists of neighbor atoms:
~~~
ENVIRON [DIST dist.r] [POINT x0.r y0.r z0.r|ATOM at.s/iat.i]
[BY by.s/iby.i] [SHELLS]
~~~
If POINT is given, print the atomic neighbors
around the point with coordinates (`x0.r` `y0.r` `z0.r`) in
crystallographic coordinates (crystal) or or molecular Cartesian
coordinates (molecule, default units: angstrom). Instead, if ATOM is
given, print the neighbors around atom `iat.i` from the non-equivalent
atom list or around every atom with atomic symbol `at.s` (converted
internally to atomic number). If neither POINT nor ATOM are given,
print the environments of all non-equivalent atoms in the unit cell.

By default, the environments extend up to 5 angstrom from the central
point. The DIST keyword can be used to change this value (by default,
`dist.r` is in bohr in crystals and angstrom in molecules). The BY
keyword allows filtering the neighbor list to print only certain kinds
of atoms. If `iby.i` is given, print only atoms whose non-equivalent ID
is the same as `iby.i`. If `by.s` is given, print only atoms with the same
atomic symbol as `by.s` (converted internally to atomic number). If
SHELLS is given, group the neighbors in shells by distance (1e-2
atomic distance threshold for atoms in the same shell) and
non-equivalent ID.

## Pair and Triplet Coordination Numbers (COORD) {#c2-coord}

The COORD keyword calculates pair and triplet coordination numbers:
~~~
COORD [DIST dist.r] [FAC fac.r] [RADII {at1.s|z1.i} r1.s [{at2.s|z2.i} r2.s ...]]
~~~
By default two atoms are coordinated if they are
within `fac.r` times the sum of their radii. By default, `fac.r` is equal
to the [BONDFACTOR](/critic2/manual/misc/#c2-bondfactor)
and the covalent radii are used (see the
[RADII](/critic2/manual/misc/#c2-radii) keyword). The value of
`fac.r` can be changed with the FAC keyword. The atomic radii for atomic
species can be changed with RADII, either by giving the atomic symbol
(`at1.s`) or the atomic number (`z1.i`) followed by the new radius
(default: bohr in crystals and angstrom in molecules). If the DIST
keyword is used, all atoms within a distance `dist.r` are
coordinated.

On output, COORD will list the number of coordinated pairs per atom in
the unit cell and per atomic species. In addition, it will also list
all coordinated triplets X-Y-Z, where Y runs over all atoms in the
unit cell and over all atomic species.

## Packing Ratio (PACKING) {#c2-packing}
The PACKING keyword computes the packing ratio of the crystal assuming
atomic spheres with radius equal to the nearest-neighbor distance
divided by 2:
~~~
PACKING [VDW] [PREC prec.r]
~~~
If VDW is used, then use the van der Waals radii and allow the spheres
to overlap. This option is currently implemented by building a grid on
the unit cell and checking whether its points are inside any atomic
sphere, which is not very efficient. The PREC keyword allows
controlling the precision of the packing ratio calculated using the
VDW keyword. If PREC is used, expect an error in the percent packing
ratio in the order of `prec.r`. The default `prec.r` is 0.1.

## Identify Atoms in the Structure Given Their Coordinates (IDENTIFY) {#c2-identify}

The IDENTIFY keyword identifies the coordinates in the user input by
matching them against the internal list of atoms and critical points:
~~~
IDENTIFY [ANG|ANGSTROM|BOHR|AU|CRYST|file.xyz]
 x.r y.r z.r [ANG|ANGSTROM|BOHR|AU|CRYST]
 ...
 file.xyz
ENDIDENTIFY/END
IDENTIFY file.xyz
~~~
If a coordinate is close (1e-4 bohr) to an atom or CP, the
corresponding indices as well as the coordinates are written to the
output. The input can come as either the coordinates of the points
themselves or a filename pointing to an `.xyz` file. IDENTIFY can be
used in environment mode (IDENTIFY/ENDIDENTIFY, with several lines of
input) or as a single command when applying it to a single `.xyz`
file.

The default units are crystallographic coordinates in crystals and
molecular Cartesian coordinates in molecules (default unit:
angstrom). However, these units can be modified with one of the
keywords that follow the IDENTIFY command. For specific points, the
unit can be changed by specifying the same keywords after the three
coordinates. The units in the `.xyz` file are angstrom (the xyz file
also has to have the usual syntax, with the number of atoms in the
first line and the title, or a blank line, in the second line).

In addition to the identity of the points, if any, critic2 also
provides the vertices of the cube that encompasses all the points in
the list that did match an atom or CP.

## Point-Charge Electrostatic Energy (EWALD) {#c2-ewald}

The EWALD keyword calculates the electrostatic energy of the lattice
of point charges using Ewald's method:
~~~
EWALD
~~~
The atomic charges are defined using the Q keyword.

