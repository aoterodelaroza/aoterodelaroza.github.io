---
layout: single
title: "Exporting the structure"
permalink: /critic2/manual/write/
excerpt: "Keywords for exporting the structure in critic2."
sidebar:
  nav: "critic2_manual"
categories: critic2 manual write
---

Critic2 can be used as a converter between different crystal structure
file formats. For instance, to convert a cif file to a QE input, we
can use:
~~~
CRYSTAL myfile.cif
WRITE myfile.scf.in
~~~
Sometimes, it is also useful to create a finite representation of a
crystal by taking the crystal motif, perhaps extended with some of
atoms in the neighboring cell. The simplest way of doing this is by
writing an xyz file:
~~~
CRYSTAL myfile_DEN
WRITE myfile.xyz MOLMOTIF
~~~
The MOLMOTIF keyword writes all atoms in the unit cell and completes
the molecules by using the atoms in the neighboring cells. A covalent
radii criterion is used to determine whether two atoms are bonded or
not (see the BONDFACTOR and RADII keywords in `Control commands and
options`_). The full syntax of the WRITE keyword is:
~~~
WRITE file.{xyz,gjf,cml} [SPHERE rad.r [x0.r y0.r z0.r]] 
      [CUBE side.r [x0.r y0.r z0.r]] [BORDER] [ix.i iy.i iz.i]
      [MOLMOTIF] [ONEMOTIF] [ENVIRON dist.r]
      [NMER nmer.i]
WRITE file.{obj,ply,off} [SPHERE rad.r [x0.r y0.r z0.r]] 
      [CUBE side.r [x0.r y0.r z0.r]] [BORDER] [ix.i iy.i iz.i] 
      [MOLMOTIF] [ONEMOTIF] [CELL] [MOLCELL] 
WRITE file.scf.in
WRITE file.tess
WRITE file.cri|file.incritic
WRITE {[file.]POSCAR|[file.]CONTCAR}
WRITE file.abin
WRITE file.elk
WRITE file.gau
WRITE file.cif
WRITE file.d12 [NOSYM|NOSYMM]
WRITE file.m
WRITE file.db
WRITE file.gin
WRITE file.lammps
WRITE file.fdf
WRITE file.STRUCT_IN
WRITE file.hsd
WRITE file.gen
~~~
A number of file formats can be written by critic2. As in CRYSTAL and
MOLECULE, the type of file is detected by the extension (xyz, in,
tess, cri, etc.). 

In the first WRITE command above, an xyz file containing a finite
piece of the crystal (if the structure was loaded with CRYSTAL) or the
molecule (resp. MOLECULE) is generated. Alternatively, if the gjf
extension is used, a template for a Gaussian input file is
written. The number of cells used in each direction is given by ix.i,
iy.i and iz.i (default: 1, 1, 1). For the purpose of its graphical
representation, it is sometimes interesting to include atoms which are
almost exactly at the edge of the cell. For instance, when doing:
~~~
CRYSTAL
  SPG f m -3 m
  CELL 5.64 5.64 5.64 90 90 90 ANG
  NEQ 0. 0. 0. na
  NEQ 1/2 1/2 1/2 cl
ENDCRYSTAL
WRITE nacl.xyz
~~~
Critic2 will (correctly) generate a list of 4 Na and 4 Cl atoms,
representing 1/8th of the conventional cell, because the atoms at (1,
0, 0), (1, 1/2, 0), etc. are repetitions of the atoms in the main
cell. However, this does not look good when the unit cell is
represented in a figure, because many of the atoms in the cubic cell
are "missing". By using BORDER, these atoms are included.

The SPHERE keyword writes all atoms inside a sphere of radius rad.r
(bohr) and centered around the crystallographic coordinates (x0.r y0.r
z0.r). In molecules, the default units for both the center and radius
of the sphere are Cartesian in angstrom. If no center is given,
(0,0,0) is used. The similar keyword CUBE writes all atoms inside a
cube of side side.r centered around (x0.r y0.r z0.r) (default:
(0,0,0)).

The keyword MOLMOTIF is used in molecular crystals. All atoms in the
requested crystal fragment are written to the xyz file. Then, the
molecules are completed using atoms from outside the fragment. In
order to do this, a connectivity criterion is used: two atoms are
bonded if their distance is less than BONDFACTOR times their sum of
covalent radii (see the BONDFACTOR and RADII keywords in `Control
commands and options`_).

The ONEMOTIF and ENVIRON keywords are also used in molecular
crystals. ONEMOTIF writes all atoms in the unit cell, translated by
lattice vectors to give connected molecules. ENVIRON writes the
molecular environment of the unit cell origin up to a distance renv.r
(bohr in crystals, angstrom in molecules). All connected molecules
whose center of mass is at a distance less than renv.r are written.

The NMER keyword is used in molecular systems as well, and in
combination with ONEMOTIF, MOLMOTIF, or ENVIRON. When NMER is given,
the selected fragment of the system is split into its component
connected molecules. Then, all monomers, dimers, trimers,... are
written to separate files. All n-mers are written from monomers up to
n-mers, where n is the value of nmer.i. In NMER is used with ENVIRON,
the first molecule in all n-mers except for those with n = nmer.i is
always part of the Wigner-Seitz cell, which is useful when generating
molecular environments of the crystal for calculations using
incremental methods.

There is an important application of the xyz-format WRITE keyword: the
coordinates written to the xyz file are consistent with the
transformation to Cartesian coordinates in critic2, so it is possible
to bring back all or part of these coordinates to critic2 in order to
represent a subset of the atoms in a crystal. This is very useful
when generating fragments for an NCIPLOT calculation (see FRAGMENT
keyword in section `Non-covalent interaction visualization
(NCIPLOT)`_).

The CML (Chemical Markup Language) format has the same options as the
xyz and obj output formats. In the CML format, an XML-style file is
written containing the selected crystal fragment. If the system is a
crystal (loaded with the CRYSTAL keyword), then the cell geometry is
written as well. The CML output format is specially tailored for being
easy to read by avogadro and its underlying engine, openbabel.

The OBJ output is similar to xyz: critic2 will write a finite piece of
the crystal or molecule to a file with Wavefront OBJ format. The OBJ
format is a three-dimensional model representation, that is, it uses
vertices and faces instead of atoms. This file format is understood by
many visualizers such as view3dscene, meshlab, blender, and
others. The keywords have the same meaning as in the xyz format. The
additional CELL keyword instructs critic2 to write a stick
representation of the unit cell. In a molecular structure, the MOLCELL
keyword can be used to represent the molecular cell (see `The
molecular cell`_). The similarly popular PLY (polygon file format or
Stanford triangle format) and OFF (Geomview) file formats can be used
as well, with the same options.

Quantum ESPRESSO inputs can be written using the extension
scf.in. This conversion is especially useful in the case of
low-symmetry crystals (e.g. monoclinic in a non-conventional setting)
where the conversion from other formats, such as CIF, can be
tricky. The QE input generation works by first determining the Bravais
lattice from the symmetry operations. Critic2 uses 'ibrav=0' always,
and writes a CELL_PARAMETERS block containing the
crystallographic-to-Cartesian transformation matrix. QE is particular
about how this matrix should written in order for its own symmetry
module to work. If the crystal setting matches any of those covered in
the QE manual, then that particular matrix is used. Otherwise, critic2
uses its own internal CELL_PARAMETERS matrix, which may result in
Quantum ESPRESSO failing to recognize the crystal symmetry. By
default, the crystal cell used by critic2 is written to the QE input
template. To reduce the cell to a primitive, use NEWCELL with the
PRIMITIVE keyword before writing the file.

A tessel input (extension .tess) and a critic2 input using the (.cri
or .incritic) can be written. Tessel is a program for crystal and
molecular plotting; it can be found at
http://azufre.quimica.uniovi.es. 

A VASP POSCAR (or CONTCAR) is generated by using the POSCAR/CONTCAR
extension or name. The list of atomic types is written to the critic2
output. This list is necessary to build the corresponding POTCAR. The
atoms are always ordered in increasing atomic number. An abinit input
file containing the input structure can be written by using the 'abin'
extension. An elk input template can be written using the elk
extension. A simple cif file (no symmetry) is generated if the cif
extension is used.

A template input file for crystal14 (incomplete - no basis set
specification) can be written with the extension d12. The generation
of these inputs uses the spglib symmetry routines to find the crystal
symmetry, and is still experimental. You should do NEWCELL PRIMITIVE
or NEWCELL STANDARD before writing a d12 file. The NOSYM (or NOSYMM)
option writes a template in the P1 space group.

A Gaussian input file for calculations under periodic boundary
conditions can be written using the gau extension. For a template
corresponding to a finite molecule, use gjf (see above).

The octave script file (extension .m) contains the structure in octave
format, to be read using the escher library (visit
http://schooner.chem.dal.ca for more information). The db file format
is intended for a set of automated input generation scripts written in
octave (https://github.com/aoterodelaroza/dcp).

A simple GULP template input file containing the structure (and EEM as
the first line) can be written using the .gin extension. No resonant
carbon atoms are detected.  For file names with an extension .lammps,
critic2 writes a simple LAMMPS data file containing one unit cell
(length units are angstrom). Only orthogonal cells are supported for
now. Both the GULP and the LAMMPS outputs are experimental, so please
exercise care and double-check the templates.

Two types of siesta inputs can be generated. The fdf extension writes
a template for a proper functional siesta input template containing
the crystal structure. The STRUCT_IN extension writes a files that can
be read using the MD.UseStructFile option.

Two inputs for DFTB+ may be written. The gen format contains only the
structure and is meant to be used with the GenFormat method in
Geometry. The hsd writes a fulll input template, including the
structure.

