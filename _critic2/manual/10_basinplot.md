---
layout: single
title: "Plotting atomic basins"
permalink: /critic2/manual/basinplot/
excerpt: "Methods for plotting atomic basins in critic2."
sidebar:
  - repo: "critic2"
    nav: "critic2_manual"
toc: true
toc_label: "Plotting atomic basins"
toc_sticky: true
---

## Attractor basin plots (BASINPLOT) {#c2-basinplot}

~~~
BASINPLOT [CUBE [lvl.i] | TRIANG [lvl.i] | 
  SPHERE [ntheta.i nphi.i]]
  [OFF|OBJ|PLY|BASIN|DBASIN [npts.i]}]
  [CP cp.i] [PREC delta.r] [VERBOSE] [MAP id.s|"expr"]
~~~
Plot the attraction basin of the CP cp.i from the complete list (if CP
is not given, all the non-equivalent attractors are used). The rays on
which the bisection is carried out are determined by the method
chosen. With CUBE, a cube is selected as the starting polyhedron, and
recursively subdivided lvl.i times. The final (convex) polyhedron is
placed on the attractor and the zero-flux surface limit for the rays
is determined. TRIANG follows the same process, starting from an
octahedron. SPHERE stands for a direct triangulation of the unit
sphere. There are nphi.r parallels. The equatorial circles contain
exponentially more points than the polar. Ntheta.i thus represents a
seed. The total number of points is given by the formula
2*nphi*(2**ntheta-1)+2.

The output keyword selects the output format for the basin plot: OFF,
OBJ, PLY, BASIN, and DBASIN. Note that DBASIN files also contain
information about scalar fields measured along the basin rays.

The naming scheme of the output files is <root>-cp.ext where root is
the general root of the run (the name of the input file up to the
first dot unless changed by the ROOT keyword), cp is the complete CP
list id. of the attractor and ext is the appropriate extension (off,
basin or dbasin)

The precision of the bisection is delta.r (set using the PREC
keyword). VERBOSE gives more information in the output about the
bisection process.

If a 3d model format is used (OFF, OBJ, PLY), the MAP keyword can be
utilized to colormap a given field (given by the field number or
identifier id.s) or field-containing expression ("expr") onto the
surface. The color scale limits are the minimum and the maximum value
of the field or expression on all the points of the surface. The
mapping function is the same as in gnuplot (r=sqrt(x), g=x^3,
b=sin(360*x), with x from 0 to 1).

Default: TRIANG method, lvl.i = 3, ntheta.i = nphi.i = 5, OBJ output,
phtheta.r = 0d0, phphi.r = 0d0, all the non-equivalent attractors
found in AUTO.

## Primary bundle plots (BUNDLEPLOT) {#c2-bundleplot}

~~~
BUNDLEPLOT x.r y.r z.r
  [CUBE [lvl.i] | TRIANG [lvl.i] | SPHERE [ntheta.i nphi.i]]
  [OFF|OBJ|PLY|BASIN|DBASIN [npts.i]}]
  [ROOT root.s] [PREC delta.r] [VERBOSE] [MAP id.s|"expr"]
~~~
Plot a primary bundle starting from a point in its interior, given by
x.r y.r z.r in crystallographic coordinates (crystal) or molecular
Cartesian coordinates (molecule, default units: angstrom). The
bisection algorithm is used with precision delta.r (PREC keyword,
default: 1d-5 bohr). The rays traced are obtained by a recursive
subdivision (lvl.i cycles) a cube (CUBE), an octahedron (TRIANG) or
using a uniform distribution of ntheta.i * nphi.i points on the unit
sphere (SPHERE). The output file has root root.s, and its format may
be OFF, OBJ, PLY, BASIN or DBASIN with npts.i points sampled along
each ray. The initial polyhedron may be rotated a phase given by
phtheta.r (polar angle) and phphi.r (azimuthal angle).

If a 3d model format is used (OFF, OBJ, PLY), the MAP keyword can be
utilized to colormap a given field (given by field number or
identifier id.s) or field-containing expression ("expr") onto the
surface. The color scale limits are the minimum and the maximum value
of the field or expression on all the points of the surface. The
mapping function is the same as in gnuplot (r=sqrt(x), g=x^3,
b=sin(360*x), with x from 0 to 1).

Default values: TRIANG, lvl.i = 3, ntheta.i = nphi.i = 5, OBJ output,
phtheta.r = 0d0, phphi.r = 0d0, root.s = <root>-bundle.

