---
layout: single
title: "List of Keywords"
permalink: /critic2/syntax/
excerpt: "List of commands used in critic2."
sidebar:
  - repo: "critic2"
    nav: "critic2"
classes: wide
toc: true
toc_label: "List of keywords"
---

{:center: style="text-align: center"}
**Keywords**
{:center}

| [AMD](#key-amd)                         | [ATOMLABEL](#key-atomlabel)       | [AUTO](#key-auto)           | [BADER](#key-bader)           | [BASINPLOT](#key-basinplot)     | [BENCHMARK](#key-benchmark)           |
| [BONDFACTOR](#key-bondfactor)           | [BUNDLEPLOT](#key-bundleplot)     | [BZ](#key-bz)               | [CLEAR](#key-clear)           | [COMPARE](#key-compare)         | [COMPAREVC](#key-comparevc)           |
| [COORD](#key-coord)                     | [COUNT](#key-count)               | [CPREPORT](#key-cpreport)   | [CRYSTAL](#key-crystal)       | [CUBE](#key-cube)               | [ECHO](#key-echo)                     |
| [ECON](#key-econ)                       | [END](#key-end)                   | [ENVIRON](#key-environ)     | [EWALD](#key-ewald)           | [EXIT](#key-exit)               | [FLUXPRINT](#key-fluxprint)           |
| [GRDVEC](#key-grdvec)                   | [HIRSHFELD](#key-hirshfeld)       | [IDENTIFY](#key-identify)   | [INTEGRABLE](#key-integrable) | [INTEGRALS](#key-integrals)     | [INT_RADIAL](#key-int-radial)         |
| [ISOSURFACE](#key-isosurface)           | [KPOINTS](#key-kpoints)           | [LIBRARY](#key-library)     | [LIBXC](#key-libxc)           | [LINE](#key-line)               | [LIST](#key-list)                     |
| [LOAD](#key-load)                       | [MAKEMOLSNC](#key-makemolsnc)     | [MAX](#key-max)             | [MEAN](#key-mean)             | [MESHTYPE](#key-meshtype)       | [MIN](#key-min)                       |
| [MOLCALC](#key-molcalc)                 | [MOLCELL](#key-molcell)           | [MOLECULE](#key-molecule)   | [MOLMOVE](#key-molmove)       | [MOLREORDER](#key-molreorder)   | [NCIPLOT](#key-nciplot)               |
| [NEWCELL](#key-newcell)                 | [NOCORE](#key-nocore)             | [NOSYM](#key-nosym)         | [NOSYMM](#key-nosymm)         | [ODE_MODE](#key-ode-mode)       | [PACKING](#key-packing)               |
| [PLANE](#key-plane)                     | [POINT](#key-point)               | [POLYHEDRA](#key-polyhedra) | [POWDER](#key-powder)         | [PRECISECUBE](#key-precisecube) | [PRUNE_DISTANCE](#key-prune-distance) |
| [Q/QAT](#key-q)                         | [QTREE](#key-qtree)               | [POINTPROP](#key-pointprop) | [RADII](#key-radii)           | [RDF](#key-rdf)                 | [REFERENCE](#key-reference)           |
| [RESET](#key-reset)                     | [ROOT](#key-root)                 | [RUN](#key-run)             | [SETFIELD](#key-setfield)     | [SIGMAHOLE](#key-sigmahole)     | [SPG](#key-spg)                       |
| [SPHEREINTEGRALS](#key-sphereintegrals) | [STANDARDCUBE](#key-standardcube) | [STM](#key-stm)             | [SUM](#key-sum)               | [SYM](#key-sym)                 | [SYMM](#key-symm)                     |
| [SYSTEM](#key-system)                   | [UNITS](#key-units)               | [UNLOAD](#key-unload)       | [VDW](#key-vdw)               | [VORONOI](#key-voronoi)         | [WRITE](#key-write)                   |
| [XDM](#key-xdm)                         | [YT](#key-yt)                     | [ZPSP](#key-zpsp)           |                               |                                 |                                       |

## Notation

* Keywords are in CAPS (except POSCAR, CONTCAR, etc.)
* `.s`: strings, `.i`: integers, `.r`: real numbers, `expr.s`: arithmetic expressions.
* Arithmetic expressions can be given between single quotes (''),
double quotes (""), or without quoting as long as there are no
spaces. They can be used in most places that a real or integer can. An
expression input:
~~~
expression.r
~~~
prints the value of the expression to the output. The list of
functions that can be used in arithmetic expressions is
[below](/critic2/syntax/#farithmetics).
* Variables can be used almost everywhere.  Variables are assigned:
~~~
variable.s = value.r
~~~
* Fields are accessed using the `$` symbol and modified with an
optional colon and field modifier (`$field:modifier`). See
[below](/critic2/syntax/#fmods) for a list of field modifiers.
* Structural variables are accessed using the `@` symbol, and they can
be used to incorporate position-dependent quantities to the expression.
See [below](/critic2/syntax/#structvar) for a list of structural
variables.
* In non-quiet mode (no -q argument), a copy of each input line
is written to the output after a '%%' prefix.
* Comment prefix: `#`.
* Continuation symbol: `\`.

## List of Keywords

In the entries below, we use:
* `nat.i`: atom integer ID from the nonequivalent list (asymmetric unit).
* `ncp.i`: critical point integer ID from the non-equivalent list (asymmetric unit).
* `at.i`: atom integer ID from the complete list (unit cell).
* `cp.i`: critical point integer ID from the complete list (unit cell).
* `at.s`: atomic symbol.
* `id.s`: field identifier (string or integer ID).

<a id="key-amd"></a>
[AMD](/critic2/manual/structure/#c2-amd)
: Calculate the average minimum distances vector.
~~~
AMD [nnmax.i]
~~~

<a id="key-atomlabel"></a>
[ATOMLABEL](/critic2/manual/structure/#c2-atomlabel)
: Relabel the atoms in the current structure.
~~~
ATOMLABEL template.s
~~~

<a id="key-auto"></a>
[AUTO](/critic2/manual/cpsearch/#c2-auto)
: Determine the position and properties of the critical points.
~~~
AUTO [GRADEPS eps.r] [CPEPS eps.r] [NUCEPS neps.r] [NUCEPSH nepsh.r]
     [EPSDEGEN edeg.r] [DISCARD expr.s] [CHK] [DRY] [SEEDOBJ]
AUTO ... [CLIP CUBE x0.r y0.r z0.r x1.r y1.r z1.r]
AUTO ... [CLIP SPHERE x0.r y0.r z0.r rad.r]
AUTO ... [SEED ...] [SEED ...] ...
AUTO SEED WS [DEPTH depth.i] [X0 x0.r y0.r z0.r] [RADIUS rad.r]
AUTO SEED OH [DEPTH depth.i]  [X0 x0.r y0.r z0.r] [RADIUS rad.r]
             [NR nr.r]
AUTO SEED SPHERE [X0 x0.r y0.r z0.r] [RADIUS rad.r] [NTHETA ntheta.i]
                 [NPHI nphi.i] [NR nr.r]
AUTO SEED PAIR [DIST dist.r] [NPTS n.i]
AUTO SEED TRIPLET [DIST dist.r]
AUTO SEED LINE [X0 x0.r y0.r z0.r] [X1 x0.r y0.r z0.r] [NPTS n.i]
AUTO SEED POINT [X0 x0.r y0.r z0.r]
AUTO SEED MESH
~~~

<a id="key-bader"></a>
[BADER](/critic2/manual/integrate/#c2-bader)
: Integrate the attraction (atomic) basins of a field defined on a
  grid using Henkelman et al.'s method.
~~~
BADER [NNM] [NOATOMS] [WCUBE] [BASINS [OBJ|PLY|OFF] [ibasin.i]] [RATOM ratom.r]
      [DISCARD expr.s] [JSON file.json] [ONLY iat1.i iat2.i ...]
~~~

<a id="key-basinplot"></a>
[BASINPLOT](/critic2/manual/basinplot/#c2-basinplot)
: Three-dimensional plots of the attraction basins.
~~~
BASINPLOT [CUBE [lvl.i] | TRIANG [lvl.i] | SPHERE [ntheta.i nphi.i]]
          [OFF|OBJ|PLY|BASIN|DBASIN [npts.i]}]
          [CP cp.i] [PREC delta.r] [VERBOSE] [MAP id.s|"expr"]
~~~

<a id="key-benchmark"></a>
[BENCHMARK](/critic2/manual/misc/#c2-benchmark)
: Run a benchmark test to measure the evaluation cost of the reference
  field. Mostly for debug purposes.
~~~
BENCHMARK nn.i
~~~

<a id="key-bondfactor"></a>
[BONDFACTOR](/critic2/manual/misc/#c2-bondfactor)
: Two atoms are considered covalently bonded if their distance is less
  than the sum of their covalent radii times BONDFACTOR.
~~~
BONDFACTOR bondfactor.r
~~~

<a id="key-bundleplot"></a>
[BUNDLEPLOT](/critic2/manual/basinplot/#c2-bundleplot)
: Three-dimensional plot of a primary bundle.
~~~
BUNDLEPLOT x.r y.r z.r
           [CUBE [lvl.i] | TRIANG [lvl.i] | SPHERE [ntheta.i nphi.i]]
           [OFF|OBJ|PLY|BASIN|DBASIN [npts.i]}]
           [ROOT root.s] [PREC delta.r] [VERBOSE] [MAP id.s|"expr"]
~~~

<a id="key-bz"></a>
[BZ](/critic2/manual/structure/#c2-bz)
: Print the geometry of the Brillouin zone.
~~~
BZ
~~~

<a id="key-clear"></a>
[CLEAR](/critic2/manual/arithmetics/#c2-clear)
: Clear the value of one or more variables.
~~~
CLEAR {var1.s var2.s ...|ALL}
~~~

<a id="key-comparevc"></a>
[COMPAREVC](/critic2/manual/structure/#c2-comparevc)
: Compare two crystal structures allowing for cell deformations.
~~~
COMPAREVC {.|file1.s} {.|file2.s} [THR thr.r] [WRITE] [NOH] [MAXELONG me.r] [MAXANG ma.r]
~~~

<a id="key-compare"></a>
[COMPARE](/critic2/manual/structure/#c2-compare)
: Compare two or more crystal or molecular structures.
~~~
COMPARE {.|file1.s} {.|file2.s} [{.|file3.s} ...]
COMPARE ... [MOLECULE|CRYSTAL]
COMPARE ... [REDUCE eps.r] [NOH]
COMPARE ... [POWDER|RDF|AMD|EMD] [XEND xend.r] [SIGMA sigma.r] [NORM 1|2|INF] ## crystals
COMPARE ... [SORTED|RDF|ULLMANN|UMEYAMA]  ## molecules
~~~

<a id="key-coord"></a>
[COORD](/critic2/manual/structure/#c2-coord)
: Calculate the pair and triplet coordination numbers.
~~~
COORD [DIST dist.r] [FAC fac.r]
~~~

<a id="key-count"></a>
[COUNT](/critic2/manual/misc/#c2-gridcalc)
: Count the number of nodes of a field defined on a grid that are
  greater than a certain value.
~~~
COUNT id.s eps.r
~~~

<a id="key-cpreport"></a>
[CPREPORT](/critic2/manual/cpsearch/#c2-cpreport)
: Print additional information (including three-dimensional plots)
  about the critical point list.
~~~
CPREPORT {SHORT|LONG|VERYLONG|SHELLS [n.i]}
CPREPORT file.{xyz,gjf,cml,vmd} [SPHERE rad.r [x0.r y0.r z0.r]]
         [CUBE side.r [x0.r y0.r z0.r]] [BORDER] [ix.i iy.i iz.i]
         [MOLMOTIF] [ONEMOTIF] [ENVIRON dist.r]
         [NMER nmer.i]
CPREPORT file.{obj,ply,off} [SPHERE rad.r [x0.r y0.r z0.r]]
         [CUBE side.r [x0.r y0.r z0.r]] [BORDER] [ix.i iy.i iz.i]
         [MOLMOTIF] [ONEMOTIF] [CELL] [MOLCELL]
CPREPORT file.scf.in
CPREPORT file.tess
CPREPORT file.cri|file.incritic
CPREPORT {[file.]POSCAR|[file.]CONTCAR}
CPREPORT file.abin
CPREPORT file.elk
CPREPORT file.gau
CPREPORT file.cif
CPREPORT file.m
CPREPORT file.gin
CPREPORT file.lammps
CPREPORT file.fdf
CPREPORT file.STRUCT_IN
CPREPORT file.hsd
CPREPORT file.gen
CPREPORT file.json
CPREPORT file.test
CPREPORT [...] [GRAPH]
~~~

<a id="key-crystal"></a>
[CRYSTAL](/critic2/manual/crystal/#c2-crystal)
: Load a crystal structure.
~~~
CRYSTAL/MOLECULE # molecule..endmolecule can be used to input a molecule.
CRYSTAL file.cif [datablock.s]
CRYSTAL file.res
CRYSTAL file.ins
CRYSTAL file.16
CRYSTAL file.21
CRYSTAL file.dmain
CRYSTAL file.cube
CRYSTAL file.bincube
CRYSTAL file.struct
CRYSTAL [file.]{POSCAR,CONTCAR,CHGCAR,CHG,ELFCAR,AECCAR0,AECCAR1,AECCAR2} [at1.s at2.s ...|POTCAR]
CRYSTAL file_{DEN|PAWDEN|ELF|POT|VHA|VHXC|VXC|VCLMB|VPSP|GDEN1|GDEN2|GDEN3|LDEN|KDEN}
CRYSTAL file.OUT # (GEOMETRY.OUT, elk)
CRYSTAL file.out [istruct.i] # (file.scf.out, quantum espresso output)
CRYSTAL file.out # (file.out, crystal output)
CRYSTAL file.in # (file.scf.in, quantum espresso input)
CRYSTAL file.STRUCT_IN
CRYSTAL file.STRUCT_OUT
CRYSTAL file.gen
CRYSTAL file.xsf
CRYSTAL file.axsf [istruct.i [xnudge.r]]
CRYSTAL file.pwc
CRYSTAL file.{in,in.next_step} # (geometry.in, FHIaims input)
CRYSTAL file.{out,own} # (FHIaims output)
CRYSTAL file.frac
CRYSTAL [CIF|SHELX|21|CUBE|BINCUBE|WIEN|ABINIT|ELK|QE_IN|QE_OUT|CRYSTAL|XYZ|WFN|WFX|
         FCHK|MOLDEN|GAUSSIAN|SIESTA|XSF|GEN|VASP|PWC|AXSF|DAT|PGOUT|ORCA|DMAIN|
         FHIAIMS_IN|FHIAIMS_OUT|FRAC] ...
CRYSTAL
 SPG [hall.i|ita.i HM|spg.s]
 CELL a.r b.r c.r alpha.r beta.r gamma.r [ANG|ANGSTROM|BOHR|AU]
 CARTESIAN [scal.r]
   [BOHR/AU]
   [ANGSTROM/ANG]
   x1.r y1.r z1.r
   x2.r y2.r z2.r
   x3.r y3.r z3.r
 ENDCARTESIAN/END
 NEQ x.r y.r z.r at.s [ANG|ANGSTROM] [BOHR|AU]
 atom.s x.r y.r z.r [ANG|ANGSTROM] [BOHR/AU]
 atnumber.i x.r y.r z.r [ANG|ANGSTROM] [BOHR/AU]
 ...
 SYMM exprx.s, epxry.s, exprz.s
ENDCRYSTAL/END
CRYSTAL LIBRARY label.s
~~~

<a id="key-cube"></a>
[CUBE](/critic2/manual/graphics/#c2-cube)
: Write a file containing the values of a field on a three-dimensional
  grid.
~~~
CUBE x0.r y0.r z0.r x1.r y1.r z1.r nx.i ny.i nz.i [FILE file.s] [FIELD id.s/"expr"]
     [F,GX,GY,GZ,GMOD,HXX,HXY,HXZ,HYY,HYZ,HZZ,LAP] [HEADER] [ORTHO]
CUBE x0.r y0.r z0.r x1.r y1.r z1.r bpp.r ...
CUBE CELL {bpp.r|nx.i ny.i nz.i} ...
CUBE GRID [SHIFT ix.i iy.i iz.i] ...
CUBE MLWF ibnd.i nRx.i nRy.i nRz.i [SPIN ispin.i] ...
CUBE WANNIER ibnd.i nRx.i nRy.i nRz.i [SPIN ispin.i] ...
CUBE UNK ibnd.i ik.i [SPIN ispin.i] ...
CUBE PSINK ibnd.i ik.i nRx.i nRy.i nRz.i [SPIN ispin.i] ...
CUBE ... FILE CHGCAR
CUBE ... FILE bleh.cube
CUBE ... FILE bleh.bincube
CUBE ... FILE bleh.xsf
~~~

<a id="key-echo"></a>
[ECHO](/critic2/manual/misc/#c2-echo)
: Write a message to the critic2 output.
~~~
ECHO echooo.s
~~~

<a id="key-econ"></a>
[ECON](/critic2/manual/structure/#c2-econ)
: Calculate the effective coordination number (ECON).
~~~
ECON
~~~

<a id="key-end"></a>
[END](/critic2/manual/misc/#c2-end)
: Terminates the critic2 run. Same as EXIT.
~~~
END
~~~

<a id="key-environ"></a>
[ENVIRON](/critic2/manual/structure/#c2-environ)
: Calculate the nearest neighbors of the atoms in the crystal
  structure.
~~~
ENVIRON [DIST dist.r] [POINT x0.r y0.r z0.r|ATOM at.s/iat.i|CELATOM iat.i]
[BY by.s/iby.i] [SHELLS]
~~~

<a id="key-ewald"></a>
[EWALD](/critic2/manual/structure/#c2-ewald)
: Calculate the electrostatic energy by performing an Ewald
  summation.
~~~
EWALD
~~~

<a id="key-exit"></a>
[END](/critic2/manual/misc/#c2-end)
: Terminates the critic2 run. Same as END.
~~~
EXIT
~~~

<a id="key-fluxprint"></a>
[FLUXPRINT](/critic2/manual/gradientpath/#c2-fluxprint)
: Three-dimensional representations of the current field's gradient
  paths.
~~~
FLUXPRINT
  POINT {1|-1|0} x.r y.r z.r
  NCP cp.i ntheta.i nphi.i [LVEC x.i y.i z.i]
  BCP cp.i 1 [LVEC x.i y.i z.i]
  BCP cp.i {0|-1} n.i [LVEC x.i y.i z.i] [BRAINDEAD|QUOTIENT|DYNAMICAL]
  RCP cp.i -1 [LVEC x.i y.i z.i]
  RCP cp.i {0|1} n.i [LVEC x.i y.i z.i] [BRAINDEAD|QUOTIENT|DYNAMICAL]
  CCP cp.i ntheta.i nphi.i [LVEC x.i y.i z.i]
  GRAPH igraph.i
  COLOR r.i g.i b.i
  TEXT|TESSEL|TESS|OBJ|PLY|OFF|CML
  SHELLS ishl.i
  NOSYM
ENDFLUXPRINT/END
~~~

<a id="key-grdvec"></a>
[GRDVEC](/critic2/manual/gradientpath/#c2-grdvec)
: Two-dimensional representations of the reference field, comprising
  contour lines, gradient paths, or a combination of the two.
~~~
GRDVEC
 {FILES|ROOT|ONAME} rootname.s
 PLANE x0.r y0.r z0.r x1.r y1.r z1.r x2.r y2.r z2.r
 SCALE sx.r sy.r
 EXTENDX zx0.r zx1.r
 EXTENDY zy0.r zy1.r
 OUTCP sx.r sy.r
 HMAX hmax.r
 ORIG x.r y.r z.r atr.i up.i down.i
 CP id.i up.i down.i
 CPALL
 BCPALL up.i down.i
 RBCPALL bup.i bdown.i rup.i rdown.i
 CHECK
      x.r y.r z.r
      ...
 ENDCHECK/END
 CONTOUR {F,GX,GY,GZ,GMOD,HXX,HXY,HXZ,HYY,HYZ,HZZ,LAP}
   nptsu.i nptsv.i {LIN niso.i [cini.r cend.r]|
   LOG niso.i [zmin.r zmax.r]|ATAN niso.i [zmin.r zmax.r]|
   BADER|i1.i i2.i...}
ENDGRDVEC/END
~~~

<a id="key-hirshfeld"></a>
[HIRSHFELD](/critic2/manual/integrate/#c2-hirshfeld)
: Calculate the Hirshfeld (stockholder) atomic properties.
~~~
HIRSHFELD [WCUBE] [ONLY iat1.i iat2.i ...]
~~~

<a id="key-identify"></a>
[IDENTIFY](/critic2/manual/structure/#c2-identify)
: Identify the position of an atom or a critical point given in
  crystallographic or cartesian coordinates.
~~~
IDENTIFY [ANG|ANGSTROM|BOHR|AU|CRYST]
  x y z [ANG|ANGSTROM|BOHR|AU|CRYST]
  ...
  file.xyz
ENDIDENTIFY/END
IDENTIFY file.xyz
~~~

<a id="key-integrable"></a>
[INTEGRABLE](/critic2/manual/integrate/#c2-integrable)
: Mark a field as a property to be integrated in the attraction
  basins.
~~~
INTEGRABLE id.s {F|FVAL|GMOD|LAP|LAPVAL} [NAME name.s]
INTEGRABLE id.s {MULTIPOLE|MULTIPOLES} [lmax.i]
INTEGRABLE id.s DELOC [WANNIER] [PSINK] [NOU] [NOSIJCHK] [NOFACHK] [WANCUT wancut.r]
INTEGRABLE "expr.s"
INTEGRABLE DELOC_SIJCHK file-sij.s
INTEGRABLE DELOC_FACHK file-fa.s
INTEGRABLE CLEAR
INTEGRABLE ... [NAME name.s]
~~~

<a id="key-integrals"></a>
[INTEGRALS](/critic2/manual/integrate/#c2-integrals)
: Integrate the basins of the reference field by bisection.
~~~
INTEGRALS {GAULEG ntheta.i nphi.i|LEBEDEV nleb.i}
          [CP ncp.i] [RWINT] [VERBOSE]
~~~

<a id="key-int-radial"></a>
[INT_RADIAL](/critic2/manual/misc/#c2-intradial)
: Radial integration method used in bisection.
~~~
INT_RADIAL [TYPE {GAULEG|QAGS|QNG|QAG}] [NR nr.i] [ABSERR err.r]
           [RELERR err.r] [ERRPROP prop.i] [PREC prec.r]
~~~

<a id="key-isosurface"></a>
[ISOSURFACE](/critic2/manual/integrate/#c2-isosurface)
: Integration of regions bound by isosurfaces.
~~~
ISOSURFACE {HIGHER|LOWER} isov.r [WCUBE] [BASINS [OBJ|PLY|OFF] [ibasin.i]]
           [DISCARD expr.s]
~~~

<a id="key-kpoints"></a>
[KPOINTS](/critic2/manual/structure/#c2-kpoints)
: Calculate the dimensions of uniform k-point grids.
~~~
KPOINTS [rk.r] [RKMAX rkmax.r]
~~~


<a id="key-library"></a>
[LIBRARY](/critic2/manual/crystal/#c2-library)
: Define the path to the library file.
~~~
LIBRARY {CRYSTAL|MOLECULE} path.s
~~~

<a id="key-libxc"></a>
[LIBXC](/critic2/manual/arithmetics/#c2-libxc)
: List and give information about the functionals available in the libxc library.
~~~
LIBXC [REF|REFS] [NAME|NAMES] [FLAGS] [ALL]
~~~

<a id="key-line"></a>
[LINE](/critic2/manual/graphics/#c2-line)
: Calculate the values of a field on a line.
~~~
LINE x0.r y0.r z0.r x1.r y1.r z1.r npts.i [FILE file.s] [FIELD id.s/"expr"]
     [GX,GY,GZ,GMOD,HXX,HXY,HXZ,HYY,HYZ,HZZ,LAP]
~~~

<a id="key-list"></a>
[LIST](/critic2/manual/arithmetics/#c2-list)
: List all defined variables and named fields.
~~~
LIST
~~~

<a id="key-load"></a>
[LOAD](/critic2/manual/fields/#c2-load)
: Load a scalar field.
~~~
LOAD file.cube
LOAD file.bincube
LOAD file_{DEN|PAWDEN|ELF|ELF|POT|VHA|VHXC|VXC|GDEN1|
           GDEN2|GDEN3|LDEN|KDEN}
LOAD [file.]{CHGCAR|CHG|AECCAR0|AECCAR1|AECCAR2} [block.i|RHO|SPIN|MAGX|MAGY|MAGZ]
LOAD {[file.]ELFCAR} [block.i|RHO|SPIN|MAGX|MAGY|MAGZ]
LOAD file.qub
LOAD file.xsf
LOAD file.grid
LOAD file.{clmsum|clmup|clmdn} file.struct
LOAD file.{RHO,BADER,DRHO,LDOS,VT,VH}
LOAD file.OUT
LOAD STATE.OUT GEOMETRY.OUT
LOAD STATE.OUT GEOMETRY.OUT OTHER.OUT
LOAD file1.ion {nat1.i/at1.s} file2.ion ...
LOAD file.xml file.bin file.hsd
LOAD file.wfn
LOAD file.wfx
LOAD file.fchk [READVIRTUAL]
LOAD file.molden [READVIRTUAL] [ORCA|PSI4]
LOAD file.molden.input [READVIRTUAL]
LOAD file.pwc [file.chk [filedn.chk]] [SPIN spin.i] [KPT k1.i k2.i...]
              [BAND b1.i b2.i ...] [ERANGE emin.r emax.r]
LOAD COPY id.s [TO id2.s]
LOAD PROMOLECULAR
LOAD PROMOLECULAR [FRAGMENT file.xyz]
LOAD [WIEN|ELK|PI|CUBE|BINCUBE|ABINIT|VASP|VASPNOV|QUB|XSF|ELKGRID|SIESTA|DFTB|
      WFN|WFX|MOLDEN|MOLDEN_ORCA|MOLDEN_PSI4|FCHK|PWC] file
LOAD ... [NEAREST|TRILINEAR|TRISPLINE|TRICUBIC|SMOOTHRHO [NENV nenv.i] [FDMAX fdmax.r]]
         [EXACT|APPROXIMATE] [RHONORM|VNORM] [CORE|NOCORE] [NUMERICAL|ANALYTICAL]
         [TYPNUC {-3,-1,1,3}] [NORMALIZE n.r] [{NAME|ID} id.s]
         [NOTESTMT] [ZPSP at1.s q1.r...]
LOAD AS "expression.s" [n1.i n2.i n3.i|SIZEOF id.s|GHOST]
LOAD AS PROMOLECULAR {n1.i n2.i n3.i|SIZEOF id.s}
        [FRAGMENT file.xyz]
LOAD AS CORE {n1.i n2.i n3.i|SIZEOF id.s}
LOAD AS LAP id.s
LOAD AS GRAD id.s
LOAD AS POT id.s [RY|RYDBERG]
LOAD AS RESAMPLE id.s n1.i n2.i n3.i
LOAD AS CLM {ADD id1.s id2.s|SUB id1.s id2.s}
~~~

<a id="key-makemolsnc"></a>
[MAKEMOLSNC](/critic2/manual/write/#c2-makemolsnc)
: Write a mols file for DMACRYS/NEIGHCRYS.
~~~
MAKEMOLSNC file_fort.21.s file_mols.s
~~~

<a id="key-max"></a>
[MAX](/critic2/manual/misc/#c2-gridcalc)
: Find the maximum value of a field defined on a grid.
~~~
MAX [id.s]
~~~

<a id="key-mean"></a>
[MEAN](/critic2/manual/misc/#c2-gridcalc)
: Find the average of a field defined on a grid.
~~~
MEAN [id.s]
~~~

<a id="key-meshtype"></a>
[MESHTYPE](/critic2/manual/misc/#c2-meshtype)
: Type and quality of the molecular integration mesh.
~~~
MESHTYPE {BECKE|FRANCHINI} [SMALL|NORMAL|GOOD|VERYGOOD|AMAZING]
~~~

<a id="key-min"></a>
[MIN](/critic2/manual/misc/#c2-gridcalc)
: Find the minimum value of a field defined on a grid.
~~~
MIN [id.s]
~~~

<a id="key-molcalc"></a>
[MOLCALC](/critic2/manual/misc/#c2-molcalc)
: Calculate molecular properties using molecular/mesh integrations.
~~~
MOLCALC
MOLCALC expr.s
MOLCALC PEACH
  mo1a [->] mo1r k1
  mo2a [->] mo2r k2
  [...]
ENDMOLCALC/END
MOLCALC HF
MOLCALC ... [ASSIGN var.s]
~~~

<a id="key-molcell"></a>
[MOLCELL](/critic2/manual/molecule/#c2-molcell)
: Define the molecular cell.
~~~
MOLCELL [border.r]
~~~

<a id="key-molecule"></a>
[MOLECULE](/critic2/manual/molecule/#c2-molecule)
: Load a molecular structure.
~~~
MOLECULE file.xyz [border.r] [CUBIC|CUBE]
MOLECULE file.wfn [border.r] [CUBIC|CUBE]
MOLECULE file.wfx [border.r] [CUBIC|CUBE]
MOLECULE file.fchk [border.r] [CUBIC|CUBE]
MOLECULE file.molden [border.r] [CUBIC|CUBE]
MOLECULE file.log [border.r] [CUBIC|CUBE]
MOLECULE file.{gjf,com} [border.r] [CUBIC|CUBE]
MOLECULE file.dat [border.r] [CUBIC|CUBE]
MOLECULE file.pgout [border.r] [CUBIC|CUBE]
MOLECULE file.gen [border.r] [CUBIC|CUBE]
MOLECULE file.cube
MOLECULE file.bincube
MOLECULE file.{in,in.next_step} # (geometry.in, FHIaims input)
MOLECULE file.{out,own} # (FHIaims output)
MOLECULE file.cif
MOLECULE ...
MOLECULE [CIF|SHELX|21|CUBE|BINCUBE|WIEN|ABINIT|ELK|QE_IN|QE_OUT|CRYSTAL|XYZ|WFN|WFX|
          FCHK|MOLDEN|GAUSSIAN|SIESTA|XSF|GEN|VASP|PWC|AXSF|DAT|PGOUT|ORCA|DMAIN|
          FHIAIMS_IN|FHIAIMS_OUT|FRAC] ...
MOLECULE
 NEQ x.r y.r z.r atom.s [ANG/ANGSTROM] [BOHR/AU]
 atom.s x.r y.r z.r [ANG/ANGSTROM] [BOHR/AU]
 atnumber.i x.r y.r z.r [ANG/ANGSTROM] [BOHR/AU]
 CUBIC|CUBE
 BORDER border.r
ENDMOLECULE/END
MOLECULE LIBRARY label.s
~~~

<a id="key-molmove"></a>
[MOLMOVE](/critic2/manual/structure/#c2-molmove)
: Move atoms inside a molecular crystal to match a set of molecular structures.
~~~
MOLMOVE mol1.s mol2.s ... target.s new.s
~~~

<a id="key-molreorder"></a>
[MOLREORDER](/critic2/manual/structure/#c2-molreorder)
: Reorder the atoms in a molecule or molecular crystal to match a template.
~~~
MOLREORDER template.s target.s [WRITE file.s] [MOVEATOMS] [INV] [UMEYAMA|ULLMANN]
~~~

<a id="key-nciplot"></a>
[NCIPLOT](/critic2/manual/nciplot/)
: Make a non-covalent interaction plot.
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
   x.r y.r z.r # (in angstrom, use it with xyz)
   ...
  ENDFRAGMENT/END
ENDNCIPLOT/END
~~~

<a id="key-newcell"></a>
[NEWCELL](/critic2/manual/structure/#c2-newcell)
: Change the cell setting of the current crystal structure by defining
  a new unit cell.
~~~
NEWCELL {x1.r y1.r z1.r x2.r y2.r z2.r x3.r y3.r z3.r|n1.i n2.i n3.i} [INV|INVERSE]
        [ORIGIN x0.r y0.r z0.r]
NEWCELL [{PRIMSTD|STANDARD|PRIMITIVE} [REFINE]]
NEWCELL [NIGGLI|DELAUNAY]
NEWCELL NICE [inice.i]
~~~

<a id="key-nocore"></a>
[NOCORE](/critic2/manual/fields/#c2-addload)
: Clears the pseudopotential charge (ZPSP) of all atoms, deactivating
  the use of the core contribution.
~~~
NOCORE
~~~

<a id="key-nosym"></a><a id="key-nosymm"></a>
[NOSYMM/NOSYM](/critic2/manual/crystal/#c2-symm)
: Deactivate the use of the symmetry module that lets critic2
  determine the space group operations of a crystal structure.
~~~
NOSYMM|NOSYM
~~~

<a id="key-ode-mode"></a>
[ODE_MODE](/critic2/manual/misc/#c2-odemode)
: Choose the numerical method for gradient path tracing.
~~~
ODE_MODE [METHOD {EULER|HEUN|BS|RKCK|DP}] [MAXSTEP maxstep.r] [MAXERR maxerr.r] [GRADEPS gradeps.r]
~~~

<a id="key-packing"></a>
[PACKING](/critic2/manual/structure/#c2-packing)
: Calculate the packing ratio of the current crystal structure.
~~~
PACKING {COV|VDW|} [PREC prec.r]
~~~

<a id="key-plane"></a>
[PLANE](/critic2/manual/graphics/#c2-plane)
: Write a file containing the values of a field on a plane and,
  optionally, make a contour plot.
~~~
PLANE x0.r y0.r z0.r x1.r y1.r z1.r x2.r y2.r z2.r nx.i ny.i
      [SCALE sx.r sy.r] [EXTENDX zx0.r zx1.r] [EXTENDY zy0.r zy1.r]
      [FILE file.s] [FIELD id.s/"expr"]
      [F,GX,GY,GZ,GMOD,HXX,HXY,HXZ,HYY,HYZ,HZZ,LAP]
            [CONTOUR {LOG niso.i [zmin.r zmax.r]|ATAN niso.i [zmin.r zmax.r]|
      BADER|LIN niso.i [rini.r rend.r]|i1.r i2.r ...}] [COLORMAP [LOG|ATAN]]
      [RELIEF zmin.r zmax.r] [LABELZ labelz.r]
~~~

<a id="key-point"></a>
[POINT](/critic2/manual/graphics/#c2-point)
: Write the properties (value, derivatives, related quantities) of one
  or more fields at a given point or set of arbitrary points.
~~~
POINT [x.r y.r z.r|file.s] [ALL] [FIELD {id.s/"expr"}]
~~~

<a id="key-pointprop"></a>
[POINTPROP](/critic2/manual/cpsearch/#c2-pointprop)
: Defines the list of properties to be calculated at critical
  points (AUTO) and through the use of the POINT keyword.
~~~
POINTPROP name.s expr.s
POINTPROP CLEAR
POINTPROP
~~~

<a id="key-polyhedra"></a>
[POLYHEDRA](/critic2/manual/structure/#c2-polyhedra)
: Calculate coordination polyhedra.
~~~
POLYHEDRA atcenter.s atvertex.s [[rmin.r] rmax.r]
~~~

<a id="key-powder"></a>
[POWDER](/critic2/manual/structure/#c2-powder)
: Calculate the powder diffraction pattern of the current crystal
  structure.
~~~
POWDER [TH2INI t2i.r] [TH2END t2e.r] [{L|LAMBDA} l.r]
       [FPOL fpol.r] [NPTS npts.i] [SIGMA sigma.r]
       [ROOT root.s] [HARD|SOFT]
~~~

<a id="key-precisecube"></a>
[PRECISECUBE](/critic2/manual/misc/#c2-precisecube)
: Extra precision in output cube files.
~~~
PRECISECUBE|STANDARDCUBE
~~~

<a id="key-prune-distance"></a>
[PRUNE_DISTANCE](/critic2/manual/misc/#c2-prunedistance)
: Prune gradient paths for lighter output.
~~~
PRUNE_DISTANCE prune.r
~~~

<a id="key-q"></a><a id="key-qat"></a>
[Q/QAT](/critic2/manual/crystal/#c2-charge)
: Define the atomic charges.
~~~
Q/QAT at1.s q1.r [at2.s q2.r] ...
~~~

<a id="key-qtree"></a>
[QTREE](/critic2/manual/integrate/#c2-qtree)
: Integrate the attractor basins using the qtree method.
~~~
QTREE [maxlevel.i [plevel.i]] [MINL minl.i] [GRADIENT_MODE gmode.i]
      [QTREE_ODE_MODE omode.i] [STEPSIZE step.r] [ODE_ABSERR abserr.r]
      [INTEG_MODE level.i imode.i] [INTEG_SCHEME ischeme.i] [KEASTNUM k.i]
      [PLOT_MODE plmode.i] [PROP_MODE prmode.i] [MPSTEP inistep.i]
      [QTREEFAC f.r] [CUB_ABS abs.r] [CUB_REL rel.r] [CUB_MPTS mpts.i]
      [SPHFACTOR {ncp.i fac.r|at.s fac.r}] [SPHINTFACTOR atom.i fac.r]
      [DOCONTACTS] [WS_ORIGIN x.r y.r z.r] [WS_SCALE scale.r]
      [NOKILLEXT] [AUTOSPH {1|2}] [CHECKBETA] [NOPLOTSTICKS]
      [COLOR_ALLOCATE {0|1}] [SETSPH_LVL lvl.i] [VCUTOFF vcutoff.r]
~~~

<a id="key-radii"></a>
[RADII](/critic2/manual/misc/#c2-radii)
: Sets the covalent and van der Waals radii of atoms.
~~~
RADII {COV|VDW|} [at1.s|z1.i] rad1.r [[at2.s|z2.i] rad2.r ...]
~~~

<a id="key-rdf"></a>
[RDF](/critic2/manual/structure/#c2-rdf)
: Calculate the radial distribution function of atoms in a molecule or
  crystal.
~~~
RDF [RINI t2i.r] [REND t2e.r] [SIGMA sigma.r] [NPTS npts.i]
    [ROOT root.s] [PAIR is1.s is2.s [PAIR is1.s is2.s ...]]
    [HARD|SOFT]
~~~

<a id="key-reference"></a>
[REFERENCE](/critic2/manual/fields/#c2-reference)
: Mark a field as the reference field.
~~~
REFERENCE id.s
~~~

<a id="key-reset"></a>
[RESET](/critic2/manual/crystal/#c2-reset)
: Restart the critic2 run by clearing all structural and field
  information.
~~~
RESET
~~~

<a id="key-root"></a>
[ROOT](/critic2/manual/misc/#c2-root)
: Change the default prefix for the files generated by critic2.
~~~
ROOT {root.s}
~~~

<a id="key-run"></a>
[RUN](/critic2/manual/misc/#c2-system)
: Run an external command.
~~~
RUN command.s
~~~

<a id="key-setfield"></a>
[SETFIELD](/critic2/manual/fields/#c2-setfield)
: Change field flags after the field was loaded.
~~~
SETFIELD [id.s] [NEAREST|TRILINEAR|TRISPLINE|TRICUBIC] [EXACT|APPROXIMATE]
                [RHONORM|VNORM] [CORE|NOCORE] [NUMERICAL|ANALYTICAL]
                [TYPNUC {-3,-1,1,3}] [NORMALIZE n.r] [ZPSP at1.s q1.r...]
~~~

<a id="key-sigmahole"></a>
[SIGMAHOLE](/critic2/manual/misc/#c2-sigmahole)
: Calculate the properties of a $$\sigma$$-hole in a molecule
~~~
SIGMAHOLE ib.i ix.i [NPTS nu.i nv.i] [ISOVAL rho.r] [MAXANG ang.r]
~~~

<a id="key-spg"></a>
[SPG](/critic2/manual/crystal/#c2-spg)
: List the space group types known to critic2.
~~~
SPG
~~~

<a id="key-sphereintegrals"></a>
[SPHEREINTEGRALS](/critic2/manual/integrate/#c2-integrals)
: Integrate fields on a sphere.
~~~
SPHEREINTEGRALS {GAULEG [ntheta.i nphi.i]|LEBEDEV [nleb.i]}
                [NR npts.i] [R0 r0.r] [REND rend.r] [CP ncp.i]
~~~

<a id="key-standardcube"></a>
[STANDARDCUBE](/critic2/manual/misc/#c2-precisecube)
: Normal precision in output cube files.
~~~
PRECISECUBE|STANDARDCUBE
~~~

<a id="key-stm"></a>
[STM](/critic2/manual/stm/)
: Make scanning tunneling microscopy plots.
~~~
STM [CURRENT [curr.r]|HEIGHT [hei.r]] [TOP top.r]
    [{CELL|CELLS} nx.i ny.i] [NPTS n1.i n2.i]
    [LINE x0.r y0.r x1.r y1.r npts.i]
~~~

<a id="key-sum"></a>
[SUM](/critic2/manual/misc/#c2-gridcalc)
: Sum of the values of a field defined on a grid.
~~~
SUM [id.s]
~~~

<a id="key-sym"></a><a id="key-symm"></a>
[SYMM/SYM](/critic2/manual/crystal/#c2-symm)
: Activates the use of symmetry and controls the symmetry level.
~~~
{SYMM|SYM}
{SYMM|SYM} [-1|0|1]
{SYMM|SYM} eps.r
{SYMM|SYM} CLEAR
{SYMM|SYM} RECALC
{SYMM|SYM} ANALYSIS
{SYMM|SYM} REFINE
{SYMM|SYM} WHOLEMOLS
~~~

<a id="key-system"></a>
[SYSTEM](/critic2/manual/misc/#c2-system)
: Run an external command.
~~~
SYSTEM command.s
~~~

<a id="key-units"></a>
[UNITS](/critic2/manual/inputoutput/#c2-units)
: Change the default units used in the input and output.
~~~
UNITS {BOHR|AU|A.U.|ANG|ANGSTROM}
~~~

<a id="key-unload"></a>
[UNLOAD](/critic2/manual/fields/#c2-unload)
: Unload a field.
~~~
UNLOAD {id.s|ALL}
~~~

<a id="key-vdw"></a>
[VDW](/critic2/manual/structure/#c2-vdw)
: Calculate the van der Waals volume of a crystal or molecule.
~~~
VDW [PREC prec.r]
~~~

<a id="key-voronoi"></a>
[VORONOI](/critic2/manual/integrate/#c2-voronoi)
: Calculate atomic properties integrated in the atomic Voronoi regions.
~~~
VORONOI [BASINS [OBJ|PLY|OFF] [ibasin.i]] [ONLY iat1.i iat2.i ...]
~~~

<a id="key-write"></a>
[WRITE](/critic2/manual/write/#c2-write)
: Write the crystal structure to an external file.
~~~
WRITE file.{xyz,gjf,cml} [SPHERE rad.r [x0.r y0.r z0.r]]
      [CUBE side.r [x0.r y0.r z0.r]] [BORDER] [ix.i iy.i iz.i]
      [MOLMOTIF] [ONEMOTIF] [ENVIRON dist.r]
      [NMER nmer.i]
WRITE file.{obj,ply,off} [SPHERE rad.r [x0.r y0.r z0.r]]
      [CUBE side.r [x0.r y0.r z0.r]] [BORDER] [ix.i iy.i iz.i]
      [MOLMOTIF] [ONEMOTIF] [CELL] [MOLCELL]
WRITE file.scf.in [rklength.r]
WRITE file.tess
WRITE file.cri|file.incritic
WRITE {[file.]POSCAR|[file.]CONTCAR}
WRITE file.abin
WRITE file.elk
WRITE file.gau
WRITE file.cif [NOSYM|NOSYMM]
WRITE file.d12 [NOSYM|NOSYMM]
WRITE file.res [NOSYM|NOSYMM]
WRITE file.m
WRITE file.db
WRITE file.gin
WRITE file.lammps
WRITE file.fdf
WRITE file.STRUCT_IN
WRITE file.hsd
WRITE file.gen
WRITE file.pyscf
WRITE file.in [rklength.r] ## FHIaims geometry.in
WRITE file.frac
~~~

<a id="key-xdm"></a>
[XDM](/critic2/manual/misc/#c2-xdm)
: Calculate the XDM dispersion energy and derivatives.
~~~
XDM GRID [RHO irho.s] [TAU itau.s] [ELF ielf.s]
    [PDENS ipdens.s] [CORE icor.s] [LAP ilap.s]
    [GRAD igrad.s] [RHOAE irhoae.s] [XB ib.s]
    [XA1 a1.r] [XA2 a2.r] [ONLYC] [UPTO {6|8|10}]
XDM [QE|POSTG] [FILE file.s] [BETWEEN at1.i at1.i ... AND at1.i at2.i ...]
       [NOC6] [NOC8] [NOC10] [SCALC6 s6.r] [SCALC8 s8.r] [SCALC10 s10.r]
       [C9] [SCALC9 s9.r]
       [DAMP a1.r a2.r] [DAMP3 a3.r a4.r] [DAMP3BJN 3|6|sqrt6]
XDM a1.r a2.r chf.s
~~~

<a id="key-yt"></a>
[YT](/critic2/manual/integrate/#c2-yt)
: Integrate the attraction (atomic) basins of a field defined on a
  grid using Yu and Trinkle's method.
~~~
YT [NNM] [NOATOMS] [WCUBE] [BASINS [OBJ|PLY|OFF] [ibasin.i]] [RATOM ratom.r]
   [DISCARD expr.s] [JSON file.json] [ONLY iat1.i iat2.i ...]
~~~

<a id="key-zpsp"></a>
[ZPSP](/critic2/manual/crystal/#c2-charge)
: Define the core contribution for an atom by setting the
  pseudopotential charge.
~~~
ZPSP at1.s q1.r [at2.s q2.r] ...
~~~

## List of Functions Used in Arithmetic Expressions {#farithmetics}

Basic arithmetic functions
: abs, exp, sqrt, floor, ceil, ceiling, round, log, log10, sin, asin,
  cos, acos, tan, atan, atan2, sinh, cosh, erf, erfc, min, max.

gtf(id) [gtf]
: Thomas-Fermi kinetic energy density.

vtf(id) [vtf]
: Thomas-Fermi potential energy density (uses local virial).

htf(id) [htf]
: Thomas-Fermi total energy density (uses local virial).

gtf_kir(id) [gtf_kir]
: Thomas-Fermi ked with Kirzhnits gradient correction.

vtf_kir(id) [vtf_kir]
: Thomas-Fermi potential energy density with Kirzhnits gradient correction (uses local virial).

htf_kir(id) [htf_kir]
: Thomas-Fermi total energy density with Kirzhnits gradient correction
  (uses local virial).

gkin(id) [gkin]
: Kinetic enregy density, g-version (grho * grho).

kkin(id) [kkin]
: Kinetic enregy density, k-version (rho * laprho).

lag(id) [lag]
: Lagrangian density (-1/4 laprho).

elf(id) [elf]
: Electron localization function.

vir(id) [vir]
: Electronic potential energy density (virial field).

stress  [stress]
: Schrodinger stress tensor (for the reference field only).

he(id) [he]
: Electronic energy density, gkin+vir.

lol(id) [lol]
: Localized-orbital locator.

lol_kir(id) [lol_kir]
: Localized-orbital locator, with Kirzhnits k.e.d.

brhole_a1(id), brhole_a2(id), brhole_a(id)
: BR hole, A prefactor (spin up, down, and average).

brhole_b1(id), brhole_b2(id), brhole_b(id)
: BR hole, hole-reference distance (spin up, down, and average).

brhole_alf1(id), brhole_alf2(id), brhole_alf(id)
: BR hole, exponent (spin up, down, and average).

xhcurv1(id), xhcurv2(id), xhcurv(id)
: Curvature of the exchange hole at the reference point (spin up, down, and average).

dsigs1(id), dsigs2(id), dsigs(id)
: Same-spin pair density leading coefficient (Dsigma) (spin up, down, and average).

xhole(id,x,y,z)
: Exchange hole with reference point at x,y,z.

stress [STRESS]
: Schrodinger stress tensor (only for the reference field).

mep(id)
: Molecular electrostatic potential (requires [libcint](/critic2/installation/#c2-libcint)).

uslater(id)
: Slater potential (requires [libcint](/critic2/installation/#c2-libcint)).

nheff(id)
: Reverse-BR effective hole normalization (requires [libcint](/critic2/installation/#c2-libcint)).

xc(...,idx)
: Exchange-correlation energy density (requires [libxc](/critic2/installation/#c2-libxc)).

## List of Field Modifiers ($field:modifier) {#fmods}
\:v
: Valence-only value of the field.

\:c
: Core-only value of the field.

\:x, :y, :z
: First derivatives of the field

\:xx, :xy, :yx, :xz, :zx, :yy, :yz, :zy, :zz
: Second derivatives.

\:g
: Norm of the gradient.

\:l
: Laplacian.

\:lv
: Valence Laplacian.

\:lc
: Core Laplacian.

\:\<n\>
: Value of MO number n. (only for molecular wavefunctions)

\:HOMO
: Highest-occupied molecular orbital (RHF). (only for molecular wavefunctions)

\:LUMO
: Lowest-unoccupied molecular orbital (RHF). (only for molecular wavefunctions)

\:A\<n\>
: Alpha MO number n. (only for molecular wavefunctions)

\:B\<n\>
: Beta MO number n. (only for molecular wavefunctions)

\:AHOMO
: Alpha highest-occupied molecular orbital (UHF). (only for molecular wavefunctions)

\:ALUMO
: Alpha lowest-unoccupied molecular orbital (UHF). (only for molecular wavefunctions)

\:BHOMO
: Beta highest-occupied molecular orbital (UHF). (only for molecular wavefunctions)

\:BLUMO
: Beta lowest-unoccupied molecular orbital (UHF). (only for molecular wavefunctions)

\:up, :dn, :sp
: Alpha, beta, spin density. (only for molecular wavefunctions)

## List of Structural Variables (@strucvar) {#structvar}

@dnuc
: Distance to the closest nucleus. If used as @dnuc:n, the distance to
  the closest nucleus with ID n from the complete list.

@xnucx
: x of the closest nucleus (crystallographic). If used as @xnuc:n, the
  x coordinate of the closest nucleus with ID n from the complete list.

@ynucx
: y of the closest nucleus (crystallographic). If used as @ynuc:n, the
  y coordinate of the closest nucleus with ID n from the complete list.

@znucx
: z of the closest nucleus (crystallographic). If used as @znuc:n, the
  z coordinate of the closest nucleus with ID n from the complete list.

@xnucc
: x of the closest nucleus (Cartesian). If used as @xnucc:n, the x
  coordinate of the closest nucleus with ID n from the complete list.

@ynucc
: y of the closest nucleus (Cartesian). If used as @ynucc:n, the y
  coordinate of the closest nucleus with ID n from the complete list.

@znucc
: z of the closest nucleus (Cartesian). If used as @znucc:n, the z
  coordinate of the closest nucleus with ID n from the complete list.

@xx
: x of the evaluation point (crystallographic).

@yx
: y of the evaluation point (crystallographic).

@zx
: z of the evaluation point (crystallographic).

@xc
: x of the evaluation point (Cartesian).

@yc
: y of the evaluation point (Cartesian).

@zc
: z of the evaluation point (Cartesian).

@xm
: x of the evaluation point (Cartesian molecular).

@ym
: y of the evaluation point (Cartesian molecular).

@zm
: z of the evaluation point (Cartesian molecular).

@xxr
: x of the evaluation point (reduced crystallographic).

@yxr
: y of the evaluation point (reduced crystallographic).

@zxr
: z of the evaluation point (reduced crystallographic).

@idnuc
: Complete-list id of the closest nucleus.

@nidnuc
: Non-equivalent-list id of the closest nucleus.

@rho0nuc
: Atomic density contribution from the closest nucleus. If used as
  @rho0nuc:n, the atomic density contribution of the closest nucleus
  with ID n from the complete list.

@spcnuc
: Species id of the closest nucleus.

@zatnuc
: Atomic number of the closest nucleus.
