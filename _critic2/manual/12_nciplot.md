---
layout: single
title: "Non-covalent interaction (NCI) plots"
permalink: /critic2/manual/nciplot/
excerpt: "Non-covalent interaction (NCI) plots in critic2."
sidebar:
  nav: "critic2_manual"
categories: critic2 manual nciplot
---

~~~
NCIPLOT
  ONAME root.s
  CUTOFFS rhocut.r dimcut.r
  RHOPARAM rhoparam.r
  RHOPARAM2 rhoparam2.r
  CUTPLOT rhoplot.r dimplot.r
  SRHORANGE srhomin.r srhomax.r
  VOID void.r
  RTHRES rthres.r
  INCREMENTS x.r y.r z.r
  NSTEP nx.i ny.i nz.i
  ONLYNEG
  NOCHK
  CUBE x0.r y0.r z0.r x1.r y1.r z1.r
  CUBE file1.xyz file2.xyz ...
  MOLMOTIF
  FRAGMENT file.xyz
  FRAGMENT
   x.r y.r z.r # (in angstrom!)
   ...
  ENDFRAGMENT/END
ENDNCIPLOT/END
~~~
Calculates the density and reduced density gradient on a cube for the
visualization of non-covalent interactions. The output files are

* `<root>.dat`: a 2-column file with reduced density gradient (col. 2)
  vs. density (col. 1) calculated at the points of a grid. The density
  in column one is multiplied by the sign of the second eigenvalue of
  the density Hessian.

* `<root>-dens.cube`: a cube containing the electron density times the
  sign of the second Hessian eigenvalue times 100.

* `<root>-grad.cube`: a cube containing the reduced density gradient
  (RDG).

* `<root>.vmd`: the VMD script for convenient visualization of the
  results.

The root of the files can be changed using the ONAME keyword (default:
`<root>`).

By default, the region represented is the whole unit cell, with step
lengths of 0.1 bohr in each direction. The step lengths or the number
of points in each axis can be controlled with the keywords:
~~~
INCREMENTS x.r y.r z.r
~~~
x.r, y.r and z.r are the step lengths in each direction in bohr
(crystals) or angstrom(molecules).
~~~
NSTEP nx.i ny.i nz.i
~~~
NSTEP defines the number of steps in each direction.

If plotting the whole unit cell is not convenient, a parallelepipedic
region can be extruded from the crystal with the keyword:
~~~
CUBE x0.r y0.r z0.r x1.r y1.r z1.r
~~~
where (x0.r y0.r z0.r) and (x1.r y1.r z1.r) are the cube limits in
crystallographic coordinates (crystals) or molecular Cartesian
coordinates (molecules, default unit: angstrom). In crystals, a region
larger than one periodic cell can also be selected with this
method. In addition, it is possible to define the cube containing a
fragment of the structure using:
~~~
CUBE file1.xyz file2.xyz ...
~~~
Define the limits of the cube using the crystal fragments contained in
file1.xyz, file2.xyz,... A small border (RTHRES) is added around the
region exactly containing all the atoms. The xyz files have the usual
xyz format (in angstrom), in the same spirit as the FRAGMENT
keyword. The xyz, however, are not used as fragments for the NCI
calculation.

Some cutoffs are relevant to the visualization of the NCI:
~~~
CUTOFFS rhocut.r dimcut.r
~~~
These cutoffs apply to the writing of density and reduced density
gradients (respectively) to the dat file. If, at a given point, the
density is above rhocut.r or the reduced density gradient is above
dimcut.r, then the point is not written to the dat file. Defaults:
rhocut.r = 0.2 and dimcut.r = 2.0 for loaded densities and 1.0 for
promolecular densities.
~~~
CUTPLOT rhoplot.r dimplot.r
~~~
When the density is greater than rhoplot.r, the rdg in the -grad.cube
file is set to 100d0, effectively eliminating the point from the
isosurface plot. Also, the color scale represented in RDG isosurfaces
ranges from -rhoplot.r to rhoplot.r. The default value is 0.05
(selfconsistent densities) or 0.07 (promolecular). The dimplot.r
controls the isosurface value to be represented in VMD. Default: 0.5
(SC) or 0.3 (promolecular).
~~~
SRHORANGE srhomin.r srhomax.r
~~~
Similar to CUTPLOT. When the density times the sign of the second
Hessian eigenvalue is greater than srhomax.r or smaller than
srhomin.r, the rdg in the -grad.cube file is set to 100d0, effectively
eliminating the point from the isosurface plot. This is useful when
plotting a subset of the peaks found in the dat file as
isosurfaces. Default: no range used.
~~~
MOLMOTIF
~~~
Complete the molecules that lie across unit cell faces by using atoms
in the neighboring cells.
~~~
ONLYNEG
~~~
Represent only the points where the second eigenvalue of the Hessian
is negative.
~~~
NOCHK
~~~
Do not read or write the checkpoint file. The nciplot checkpoint file
(<root>.chk_nci) contains the promolecular densities for the whole
system and the fragments, the density, and the reduced density
gradient. If the checkpoint file exists and is compatible with the
current structure and fragments, it is read. Otherwise, it is
discarded and a new checkpoint is written. By default, checkpoitn
files are used unless NOCHK is given in the input.
~~~
VOID void.r
~~~
Represent only the points where the promolecular density is lower than
void.r.
~~~
FRAGMENT file.xyz
FRAGMENT
 x.r y.r z.r # (in angstrom!)
 ...
ENDFRAGMENT/END
~~~
In the current version of NCIplot it is possible to define molecular
fragments in order to focus on some part of the crystal, or some
particular interaction. This is done by using the FRAGMENT
environments. Each FRAGMENT block defines one fragment and only the
intermolecular interactions between fragments are represented (hence,
you need at least two blocks). The atomic positions (in Cartesian
coordinates, the units are angstrom) of the atoms in the fragment
appear inside. To obtain the list of atoms, the recommended
procedure is to write an xyz file (using the WRITE keyword), then
cutting it into pieces (using, for instance, avogadro) and then
placing the resulting atom lists in FRAGMENT environments.

Alternatively, the fragment can be read from an xyz file.

There are three options that control the behavior of the fragments:
RTHRES, RHOPARAM and RHOPARAM2.
~~~
RTHRES rthres.r
~~~
When fragments are used, the density and rdg grids are reduced to
a piece encompassing the fragments, with a border of rthres.r (bohr in
crsytals, angstrom in molecules, default: 2.0 bohr).
~~~
RHOPARAM rhoparam.r
~~~
Consider only the points where none of the fragments contributes
more than rhoparam.r times the total promolecular density (default:
0.95).
~~~
RHOPARAM2 rhoparam2.r
~~~
Consider only the points where the sum of the density of all
fragments is more than rhoparam2.r times the total promolecular
density (default: 0.75). Note that the fragments need not include
all atoms in the crystal.

Some advice regarding the execution of NCIPLOT:

* If the density is given on a grid, it is usually much faster if
  core-augmentation (ZPSP and the CORE field option) is not used. The
  reason is that if the core augmentation is not present, the reduced
  density gradient and the Hessian components can be calculated by
  Fourier transform (which is smoother) and it is not necessary to sum
  over neighboring atoms. However, not using the core augmentation can
  sometimes result in noisy Hessian components, which may result in
  alternate blue/red domains (because of a spurious change of sign
  caused by numerical inaccuracies).

* Likewise, any option that activates the calculation of the
  promolecular density (VOID or FRAGMENT) is going to be expensive
  because it involves a sum over neighboring atoms. In those cases, it
  is recommended to calculate the promolecular density once for a
  certain grid, then use the checkpoint file.

* Some programs (most notably older versions of VMD) have problems
  dealing with non-orthogonal cells. There's little critic2 can do
  about this - the cube files on output hav been examined and they
  seem to be correctly written. Using FRAGMENT or CUBE in critic2 so
  that a orthogonal piece of the crystal is represented may help.

