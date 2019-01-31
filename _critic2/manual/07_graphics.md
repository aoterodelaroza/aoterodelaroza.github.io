---
layout: single
title: "Graphical representations: points, lines, planes, grids"
permalink: /critic2/manual/graphics/
excerpt: "Make graphical representations of scalar fields and structures: points, lines, planes, grids"
sidebar:
  nav: "critic2_manual"
toc: true
toc_label: "Graphical representations"
toc_sticky: true
---

## Points (POINT) {#c2-point}

~~~
POINT x.r y.r z.r [ALL] [FIELD {id.s|"expr.s"}]
~~~
Calculates the value of the reference field, its derivatives, and
related quantities at the point (x.r, y.r, z.r) in crystallographic
coordinates (if the structure is a CRYSTAL) or molecular Cartesian
coordinates (if it is a MOLECULE). For the latter, the default units
are angstrom unless changed by the UNITS keyword. If ALL is used, all
loaded fields are evaluated. In addition, all arithmetic expressions
that have been registered using the POINTPROP keyword are also
calculated (see `List of properties calculated at points
(POINTPROP)`_). The POINTPROP keyword combined with POINT is useful to
evaluate chemical functions at arbitrary points in space.

If FIELD is used and followed by an integer or field identifier
(id.s), then only that field is evaluated. FIELD followed by an
arithmetic expression calculates the value of that expression at the
point.

## Lines (LINE) {#c2-line}

~~~
LINE x0.r y0.r z0.r x1.r y1.r z1.r npts.i [FILE file.s]
     [FIELD id.s|"expr.s"] [GX|GY|GZ|GMOD|HXX|HXY|HXZ|HYX|HYY|
     HYZ|HZX|HZY|HZZ|LAP]
~~~
Calculate a line from (x0.r y0.r z0.r) to (x1.r y1.r z1.r) with npts.i
points. The units for the two endpoints (x0 and x1) are
crystallographic coordinates in crystals and molecular Cartesian
coordinates in molecules. The latter are angstrom by default (unless
UNITS is used).

By default, the result is written to the standard output, but it can
be redirected to a file using FILE. The reference field is used unless
a FIELD keyword appears, in which case the field id.s or the
expression expr.s are evaluated. Together with the value of the field,
an additional quantity can be evaluated: the components of the
gradient (GX,GY,GZ), the norm of the gradient (GMOD), the components
of the Hessian (HXX,...) and the Laplacian of the reference (or the
id.i) field.

## Planes and contour plots (PLANE) {#c2-plane}

~~~
PLANE x0.r y0.r z0.r x1.r y1.r z1.r x2.r y2.r z2.r nx.i ny.i 
      [SCALE sx.r sy.r] [EXTENDX zx0.r zx1.r] [EXTENDY zy0.r zy1.r]
      [FILE file.s] [FIELD id.s/"expr"]
      [F,GX,GY,GZ,GMOD,HXX,HXY,HXZ,HYY,HYZ,HZZ,LAP] 
      [CONTOUR {LOG niso.i [zmin.r zmax.r]|ATAN niso.i [zmin.r zmax.r]|
      BADER|LIN niso.i [rini.r rend.r]|i1.r i2.r ...}] [COLORMAP [LOG|ATAN]] 
      [RELIEF zmin.r zmax.r] [LABELZ labelz.r]
~~~
Calculate the value or other properties of the reference field on a
plane. The results are written to a file, with default name
`<root>_plane.dat`. The geometry of the plane is specified by three
points: (x0.r y0.r z0.r) is the origin, (x1.r y1.r z1.r) is the x-end
of the plane and (x2.r y2.r z2.r) is the y-end. The number of
calculated points on each axis are given by nx.i (x-axis) and ny.i
(y-axis). The units for these points are crystallographic coordinates
in a crystal, and molecular Cartesian coordinates in a molecule
(default: angstrom unless the UNITS keyword is used). The two axes of
the plane can be scaled using the SCALE keyword. If sx.r (sy.r) is
given, the total length of the x-axis (y-axis) is scaled by sx.r
(sy.r). If EXTENDX is used, extend the x-axis by zx0.r (initial point
of the x-axis) and zx1.r (end point). The keyword EXTENDY performs the
equivalent operation on the y-axis. The units for EXTENDX and EXTENDY
are bohr (crystals) or angstrom (molecules) unless changed by the
UNITS keyword.

The name of the output file can be changed with FILE. Using FIELD, one
of the loaded fields (id.s) or an expression ("expr.s") can be
evaluated. In addition to the field value, a second property can be
evaluated: the field again (F), its derivatives (Gx), its second
derivatives (Hxx), the gradient norm (GMOD) or the Laplacian (LAP).

The keyword CONTOUR writes a contour map representation of the plane:
two contour line files (.iso and .neg.iso) and a gnuplot script
(.gnu). The isovalue distribution can be: logarithmic (LOG, with
niso.i contours), arctangent (ATAN, with niso.i contours), same as in
the aimpac program (BADER, {1,2,4,8}x10^{-3,-2,-1,0,1}), linear (LIN,
niso.i contours from r0.r to r1.r), or the user can specify the
contour values manually (no keyword). In LOG and ATAN, the default
contours range from the minimum to the maximum value of the field in
the plot. These quantities can be changed by passing the optional
zmin.r and zmax.r parameters to LOG/ATAN. The field or any of its
derivatives, selected with the [F|GX|...] keyword, is used for the
contour plot.  The GRDVEC keyword (see `Gradient path representations
in a plane (GRDVEC)`_) performs the same functions as PLANE with the
CONTOUR option, and more (like, for instance, tracing gradient paths
in the plane), but is more complex to use.

The RELIEF keyword writes a gnuplot template for a three-dimensional
relief plot using the data calculated by PLANE. The default suffix is
-relief.gnu. The mandatory arguments zmin.r and zmax.r establish the
range of the z axis in the plot. 

The COLORMAP keyword writes a template for a colormap plot of the
field on the plane. If the LOG or ATAN keywords are given, the
logarithm or the arctangent of the field are represented in the
colormap.

For the plots that display atomic or critical point labels, LABELZ
controls how many labels are represented. Any atom or critical point
that is at a distance less than labelz.r (default: 0.1 bohr) is shown
as a label in the plot.

## Grids (CUBE) {#c2-cube}

~~~
CUBE x0.r y0.r z0.r x1.r y1.r z1.r nx.i ny.i nz.i [FILE file.s] [FIELD id.s/"expr"]
     [F,GX,GY,GZ,GMOD,HXX,HXY,HXZ,HYY,HYZ,HZZ,LAP] [HEADER]
CUBE x0.r y0.r z0.r x1.r y1.r z1.r bpp.r ...
CUBE CELL {bpp.r|nx.i ny.i nz.i} ...
CUBE GRID ...
CUBE ... FILE CHGCAR
CUBE ... FILE bleh.cube
CUBE ... FILE bleh.bincube
~~~
The CUBE keyword writes a three-dimensional grid in Gaussian cube,
binary cube, or VASP CHGCAR formats. The limits of the grid can be set
in three ways. By giving the end-points (x0.r y0.r z0.r) and (x1.r
y1.r z1.r) it is possible to build a grid from an orthogonal fragment
of space. The CELL keyword calculates a grid spanning the entire unit
cell, which may or may not be orthogonal depending on the
structure. GRID has the same effect as CELL regarding the output grid
geometry. If the end points are given, they should be in
crystallographic coordinates in crystals (the structure was read using
the CRYSTAL keyword) or molecular Cartesian coordinates
(MOLECULE). The units in the latter default to angstrom unless changed
using the UNITS keyword.

The number of points in the grid can also be controlled in several
ways. If the cube limits are given explicitly or using CELL, then the
number of points in each axis can be indicated by giving three
integers (nx.i, ny.i, and nz.i) corresponding to the number of points
in the x-, y-, and z-axis respectively. If a single number (bpp.r) is
found, then the number of points is the length of the axis divided by
bpp.r (that is, bpp is the number of bohrs per point, hence the
name). The GRID keyword can be used to write a field defined on a grid
directly to a cube file. This is useful when combined with the LOAD
keyword to read, manipulate, and then save grids to an external
file. If GRID is used, both the geometry of the grid and the number of
points are adopted from the corresponding field.

Independently on how the grid is set up, several options control the
behavior of CUBE. FILE sets the name of the output file (default:
CHGCAR). If the extension of file.s is not .cube, then critic2 uses
the vasp-style CHGCAR format for the output. HEADER writes only the
header to the output file (no calculations are done). FIELD sets the
field to be used by numer or identifier label (id.s). Alternatively,
an arithmetic expression that combines the existing fields can be
used. Finally, a derivative of the scalar field (gradient, Hessian,
Laplacian) can be selected instead of the value of the field itself
(F) to build the grid.

