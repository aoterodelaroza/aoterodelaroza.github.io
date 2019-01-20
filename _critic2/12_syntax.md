---
layout: single
classes: wide
title: "List of Commands"
permalink: /critic2/syntax/
excerpt: "List of commands used in critic2."
sidebar:
  nav: "critic2"
---

This is the complete list of commands accepted by critic2.
~~~
## Keywords are in CAPS (except POSCAR, CONTCAR, etc.), .s are
## strings, .i are integer expressions, .r are real expressions,
## "expr" are arithmetic expresions involving fields (that is, "$"
## objects in the expression). Other extensions correspond to files.

## Arithmetic expressions can be given between single quotes (''),
## double quotes (""), parentheses, or without quoting as long as
## there are no spaces. They can be used in most places that a real or
## integer can. Variables can be used almost everywhere. Fields are
## accessed using the $ symbol and modified with a colon and a field
## modifier ($field:modifier). Structural variables are accessed using
## the @ symbol, and they can be used to incorporate
## position-dependent quantities to the expression.  See the end of
## this file for the complete list.

## In non-quiet mode (no -q argument), a copy of each input line
## is written to the output after a '%%' prefix.

## Key to the syntax:
## nat.i  atom from the nonequivalent list (asymmetric unit)
## ncp.i  critical point from the non-equivalent list
## at.i   atom from the complete list (unit cell)
## cp.i   critical point from the complete list (unit cell)
## at.s   atomic symbol 
## id.s   field identifier (string or integer)

# comment; the continuation symbol is '\'
variable.s = value.r # assigns the expression value to the variable.
expression.r # prints the value of the expression to the output.

* CRYSTAL/MOLECULE # molecule..endmolecule can be used to input a molecule.
  CRYSTAL file.cif [datablock.s]
  CRYSTAL file.res
  CRYSTAL file.ins
  CRYSTAL file.cube
  CRYSTAL file.bincube
  CRYSTAL file.struct
  CRYSTAL [file.]{POSCAR,CONTCAR,CHGCAR,CHG,ELFCAR,AECCAR0,AECCAR2} [at1.s at2.s ...|POTCAR]
  CRYSTAL file_{DEN|PAWDEN|ELF|ELF|POT|VHA|VHXC|VXC|GDEN1|GDEN2|GDEN3|LDEN|KDEN}
  CRYSTAL file.OUT # (GEOMETRY.OUT, elk)
  CRYSTAL file.out [istruct.i] # (file.scf.out, quantum espresso output)
  CRYSTAL file.out # (file.out, crystal output)
  CRYSTAL file.in # (file.scf.in, quantum espresso input)
  CRYSTAL file.STRUCT_IN 
  CRYSTAL file.STRUCT_OUT
  CRYSTAL file.gen
  CRYSTAL file.xsf
  CRYSTAL file.pwc
  CRYSTAL
   SPG spgsymbol.s
   SPGR spgsymbol.s
   CELL a.r b.r c.r alpha.r beta.r gamma.r [ANG/ANGSTROM/BOHR/AU] 
   CARTESIAN [scal.r]
     [BOHR/AU]
     [ANGSTROM/ANG]
     x1.r y1.r z1.r
     x2.r y2.r z2.r
     x3.r y3.r z3.r
   ENDCARTESIAN/END
   NEQ x.r y.r z.r at.s [ANG|ANGSTROM] [BOHR|AU]
   atom.s x.r y.r z.r [ANG/ANGSTROM] [BOHR/AU]
   atnumber.i x.r y.r z.r [ANG/ANGSTROM] [BOHR/AU]
   ...
   SYMM exprx.s, epxry.s, exprz.s
  ENDCRYSTAL/END
  CRYSTAL LIBRARY label.s
* MOLECULE file.xyz [border.r] [CUBIC|CUBE]
  MOLECULE file.wfn [border.r] [CUBIC|CUBE]
  MOLECULE file.wfx [border.r] [CUBIC|CUBE]
  MOLECULE file.fchk [border.r] [CUBIC|CUBE] [READVIRTUAL]
  MOLECULE file.molden [border.r] [CUBIC|CUBE] [READVIRTUAL]
  MOLECULE file.log [border.r] [CUBIC|CUBE]
  MOLECULE file.gen [border.r] [CUBIC|CUBE]
  MOLECULE file.cube
  MOLECULE file.bincube
  MOLECULE file.cif
  MOLECULE ...
  MOLECULE
   NEQ x.r y.r z.r atom.s [ANG/ANGSTROM] [BOHR/AU]
   atom.s x.r y.r z.r [ANG/ANGSTROM] [BOHR/AU]
   atnumber.i x.r y.r z.r [ANG/ANGSTROM] [BOHR/AU]
   CUBIC|CUBE
   BORDER border.r
  ENDMOLECULE/END
  MOLECULE LIBRARY label.s
* LIBRARY {CRYSTAL|MOLECULE} path.s
* ATOMLABEL template.s
* UNITS {BOHR|AU|A.U.|ANG|ANGSTROM}
* NOSYMM|NOSYM|{SYMM|SYM} [-1|0|1]
  SYMPREC symprec.r
* MOLCELL [border.r]
* CLEARSYM/CLEARSYMM
* Q/QAT at1.s q1.r [at2.s q2.r] ...
* ZPSP at1.s q1.r [at2.s q2.r] ...
* NOCORE
* WRITE file.{xyz,gjf,cml} [SPHERE rad.r [x0.r y0.r z0.r]] 
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
  WRITE file.gin [DREIDING]
  WRITE file.lammps
  WRITE file.fdf
  WRITE file.STRUCT_IN
  WRITE file.hsd
  WRITE file.gen
* LOAD file.cube
  LOAD file.bincube
  LOAD file_{DEN|PAWDEN|ELF|ELF|POT|VHA|VHXC|VXC|GDEN1|GDEN2|GDEN3|LDEN|KDEN}
  LOAD [file.]{CHGCAR|AECCAR0|AECCAR2}
  LOAD {[file.]CHG|[file.]ELFCAR}
  LOAD file.qub
  LOAD file.xsf
  LOAD file.grid
  LOAD file.clmsum file.struct
  LOAD file.{RHO,BADER,DRHO,LDOS,VT,VH}
  LOAD file.OUT
  LOAD STATE.OUT GEOMETRY.OUT
  LOAD STATE.OUT GEOMETRY.OUT OTHER.OUT
  LOAD file1.ion {nat1.i/at1.s} file2.ion ...
  LOAD file.xml file.bin file.hsd
  LOAD file.wfn
  LOAD file.wfx
  LOAD file.fchk
  LOAD file.molden
  LOAD COPY id.s [TO id2.s]
  LOAD PROMOLECULAR
  LOAD PROMOLECULAR [FRAGMENT file.xyz]
  LOAD [WIEN|ELK|PI|CUBE|ABINIT|VASP|VASPCHG|QUB|XSF|ELKGRID|SIESTA|DFTB|
        WFN|WFX|MOLDEN|FCHK|PWC] file
  LOAD ... [NEAREST|TRILINEAR|TRISPLINE|TRICUBIC] [EXACT|APPROXIMATE]
           [RHONORM|VNORM] [CORE|NOCORE] [NUMERICAL|ANALYTICAL]
           [TYPNUC {-3,-1,1,3}] [NORMALIZE n.r] [{NAME|ID} id.s]
           [NOTESTMT] [ZPSP at1.s q1.r...]
  LOAD AS "expression.s" [n1.i n2.i n3.i|SIZEOF id.s|GHOST]
  LOAD AS PROMOLECULAR {n1.i n2.i n3.i|SIZEOF id.s} [FRAGMENT file.xyz]
  LOAD AS CORE {n1.i n2.i n3.i|SIZEOF id.s}
  LOAD AS LAP id.s
  LOAD AS GRAD id.s
  LOAD AS POT id.s [RY|RYDBERG]
  LOAD AS CLM {ADD id1.s id2.s|SUB id1.s id2.s}
  LOAD file.pwc [file.chk]
* UNLOAD {id.s|ALL}
* SETFIELD [id.s] [NEAREST|TRILINEAR|TRISPLINE|TRICUBIC] [EXACT|APPROXIMATE]
                  [RHONORM|VNORM] [CORE|NOCORE] [NUMERICAL|ANALYTICAL]
                  [TYPNUC {-3,-1,1,3}] [NORMALIZE n.r] [ZPSP at1.s q1.r...]
* REFERENCE id.s
* POINT x.r y.r z.r [ALL] [FIELD {id.s/"expr"}]
* LINE x0.r y0.r z0.r x1.r y1.r z1.r npts.i [FILE file.s] [FIELD id.s/"expr"]
       [GX,GY,GZ,GMOD,HXX,HXY,HXZ,HYY,HYZ,HZZ,LAP] 
* PLANE x0.r y0.r z0.r x1.r y1.r z1.r x2.r y2.r z2.r nx.i ny.i 
        [SCALE sx.r sy.r] [EXTENDX zx0.r zx1.r] [EXTENDY zy0.r zy1.r]
        [FILE file.s] [FIELD id.s/"expr"]
        [F,GX,GY,GZ,GMOD,HXX,HXY,HXZ,HYY,HYZ,HZZ,LAP] 
	        [CONTOUR {LOG niso.i [zmin.r zmax.r]|ATAN niso.i [zmin.r zmax.r]|
        BADER|LIN niso.i [rini.r rend.r]|i1.r i2.r ...}] [COLORMAP [LOG|ATAN]] 
        [RELIEF zmin.r zmax.r] [LABELZ labelz.r]
* CUBE x0.r y0.r z0.r x1.r y1.r z1.r nx.i ny.i nz.i [FILE file.s] [FIELD id.s/"expr"]
       [F,GX,GY,GZ,GMOD,HXX,HXY,HXZ,HYY,HYZ,HZZ,LAP] [HEADER]
  CUBE x0.r y0.r z0.r x1.r y1.r z1.r bpp.r ...
  CUBE CELL {bpp.r|nx.i ny.i nz.i} ...
  CUBE GRID ...
  CUBE ... FILE CHGCAR
  CUBE ... FILE bleh.cube
  CUBE ... FILE bleh.bincube
* AUTO [GRADEPS eps.r] [CPEPS eps.r] [NUCEPS neps.r] [NUCEPSH nepsh.r]
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
  AUTO SEED POINT  [X0 x0.r y0.r z0.r]
  AUTO SEED MESH
* CPREPORT {SHORT|LONG|VERYLONG|SHELLS [n.i]}
  CPREPORT file.{xyz,gjf,cml} [SPHERE rad.r [x0.r y0.r z0.r]] 
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
  CPREPORT file.gin [DREIDING]
  CPREPORT file.lammps
  CPREPORT file.fdf
  CPREPORT file.STRUCT_IN
  CPREPORT file.hsd
  CPREPORT file.gen
  CPREPORT [...] [GRAPH]
* GRDVEC
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
* FLUXPRINT
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
* BASINPLOT [CUBE [lvl.i] | TRIANG [lvl.i] | SPHERE [ntheta.i nphi.i]]
            [OFF|OBJ|PLY|BASIN|DBASIN [npts.i]}]  
            [CP cp.i] [PREC delta.r] [VERBOSE] [MAP id.s|"expr"]
* BUNDLEPLOT x.r y.r z.r 
             [CUBE [lvl.i] | TRIANG [lvl.i] | SPHERE [ntheta.i nphi.i]]
             [OFF|OBJ|PLY|BASIN|DBASIN [npts.i]}] 
             [ROOT root.s] [PREC delta.r] [VERBOSE] [MAP id.s|"expr"]
* POINTPROP name.s expr.s
  POINTPROP CLEAR
  POINTPROP
* INTEGRABLE id.s {F|FVAL|GMOD|LAP|LAPVAL} [NAME name.s]
  INTEGRABLE id.s {MULTIPOLE|MULTIPOLES} [lmax.i] 
  INTEGRABLE id.s DELOC [NOSIJCHK] [NOFACHK] [WANCUT wancut.r]
  INTEGRABLE "expr.s" 
  INTEGRABLE CLEAR
  INTEGRABLE ... [NAME name.s]
* INTEGRALS {GAULEG ntheta.i nphi.i|LEBEDEV nleb.i}
            [CP ncp.i] [RWINT] [VERBOSE]
* SPHEREINTEGRALS {GAULEG [ntheta.i nphi.i]|LEBEDEV [nleb.i]}
                  [NR npts.i] [R0 r0.r] [REND rend.r] [CP ncp.i] 
* QTREE maxlevel.i plevel.i
  + QTREE_MINL minl.i
  + GRADIENT_MODE gmode.i
  + QTREE_ODE_MODE omode.i
  + STEPSIZE step.r
  + ODE_ABSERR abserr.r
  + INTEG_MODE level.i imode.i
  + INTEG_SCHEME ischeme.i
  + KEASTNUM k.i
  + PLOT_MODE plmode.i
  + PROP_MODE prmode.i
  + MPSTEP inistep.i
  + QTREEFAC f.r
  + CUB_ABS abs.r
  + CUB_REL rel.r
  + CUB_MPTS mpts.i
  + SPHFACTOR {ncp.i fac.r|at.s fac.r}
  + SPHINTFACTOR atom.i fac.r
  + DOCONTACTS 
  + NOCONTACTS
  + WS_ORIGIN x.r y.r z.r
  + WS_SCALE scale.r
  + WS_EPS_VOL eps_vol.r
  + KILLEXT
  + NOKILLEXT
  + AUTOSPH {1|2} # default is 2
  + CHECKBETA # default is nocheckbeta
  + NOCHECKBETA
  + PLOTSTICKS
  + NOPLOTSTICKS
  + COLOR_ALLOCATE {0|1}
  + SETSPH_LVL lvl.i
  + VCUTOFF vcutoff.r
* YT [NNM] [NOATOMS] [WCUBE] [BASINS [OBJ|PLY|OFF] [ibasin.i]] [RATOM ratom.r]
     [DISCARD expr.s]
* BADER [NNM] [NOATOMS] [WCUBE] [BASINS [OBJ|PLY|OFF] [ibasin.i]] [RATOM ratom.r]
     [DISCARD expr.s]
* NCIPLOT 
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
* POWDER [TH2INI t2i.r] [TH2END t2e.r] [{L|LAMBDA} l.r] [FPOL fpol.r]
  [NPTS npts.i] [SIGMA sigma.r] [ROOT root.s]
* RDF [REND t2e.r] [SIGMA sigma.r] [NPTS npts.i] [ROOT root.s]
* COMPARE [MOLECULE|CRYSTAL] [SORTED|UNSORTED] [XEND xend.r] 
          [SIGMA sigma.r] [POWDER|RDF] 
          {.|file1.s} {.|file2.s} [{.|file3.s} ...]
* NEWCELL {x1.r y1.r z1.r x2.r y2.r z2.r x3.r y3.r z3.r|n1.i n2.i n3.i} [INV|INVERSE]
  [ORIGIN x0.r y0.r z0.r] 
  NEWCELL [PRIMSTD|STANDARD|PRIMITIVE|NIGGLI|DELAUNAY]
* ROOT {root.s}
* HIRSHFELD
* EWALD
* ENVIRON [DIST dist.r] [POINT x0.r y0.r z0.r|ATOM at.s/iat.i]
  [BY by.s/iby.i] [SHELLS]
* COORD [DIST dist.r] [FAC fac.r] [RADII [IONIC|COVALENT|VDW|at1.s r1.s ...]
* PACKING [VDW] [PREC prec.r]
* IDENTIFY [ANG|ANGSTROM|BOHR|AU|CRYST|file.xyz]
    x y z [ANG|ANGSTROM|BOHR|AU|CRYST]
    ...
    file.xyz
  ENDIDENTIFY/END
* XDM GRID [RHO irho.s] [TAU itau.s] [ELF ielf.s] [PDENS ipdens.s] 
      [COR icor.s] [LAP ilap.s] [GRAD igrad.s] [RHOAE irhoae.s]
      [XB ib.s] [XA1 a1.r] [XA2 a2.r] [ONLYC] [UPTO {6|8|10}]
  XDM QE [BETWEEN at1.i at1.i ... AND at1.i at2.i ...]
  XDM a1.r a2.r chf.s
* STM [CURRENT [curr.r]|HEIGHT [hei.r]] [TOP top.r] 
      [{CELL|CELLS} nx.i ny.i] [NPTS n1.i n2.i] 
      [LINE x0.r y0.r x1.r y1.r npts.i] 
* MOLCALC [NELEC]
  MOLCALC PEACH
    mo1a [->] mo1r k1
    mo2a [->] mo2r k2
    [...]
  ENDMOLCALC/END
  MOLCALC expr.s
  MOLCALC HF
* BENCHMARK nn.i
* SUM [id.s]
* MIN [id.s]
* MAX [id.s]
* MEAN [id.s]
* COUNT id.s eps.r
* TESTRMT
* ODE_MODE [METHOD {EULER|HEUN|BS|RKCK|DP}] [MAXSTEP maxstep.r] [MAXERR maxerr.r] [GRADEPS gradeps.r]
* PRUNE_DISTANCE prune.r
* INT_RADIAL [TYPE {GAULEG|QAGS|QNG|QAG}] [NR nr.i] [ABSERR err.r]
  [RELERR err.r] [ERRPROP prop.i] [PREC prec.r] [NOBETA]
* MESHTYPE {BECKE|FRANCHINI {1|2|3|4|5}}
* PRECISECUBE|STANDARDCUBE
* RADII [at1.s|z1.i] rad1.r [[at2.s|z2.i] rad2.r ...]
* BONDFACTOR bondfactor.r
* CLEAR {var1.s var2.s ...|ALL}
* LIST
* RESET
* RUN command.s
  SYSTEM command.s
* ECHO echooo.s
* END

# List of functions
* abs, exp, sqrt, floor, ceil, ceiling, round, log, log10, sin, asin,
  cos, acos, tan, atan, atan2, sinh, cosh, erf, erfc, min, max.
* gtf(id) [gtf] # Thomas-Fermi kinetic energy density
* vtf(id) [vtf] # Thomas-Fermi potential energy density (uses local virial)
* htf(id) [htf] # Thomas-Fermi total energy density (uses local virial)
* gtf_kir(id) [gtf_kir] # Thomas-Fermi ked with Kirzhnits gradient correction
* vtf_kir(id) [vtf_kir] # .... potential energy density (uses local virial)
* htf_kir(id) [htf_kir] # .... total energy density (uses local virial)
* gkin(id) [gkin] # Kinetic enregy density, g-version (grho * grho)
* kkin(id) [kkin] # Kinetic enregy density, k-version (rho * laprho)
* lag(id) [lag] # Lagrangian density (-1/4 laprho)
* elf(id) [elf] # electron localization function
* vir(id) [vir] # electronic potential energy density (virial field)
* stress  [stress] # Schrodinger stress tensor for the reference field.
* he(id) [he] # electronic energy density, gkin+vir.
* lol(id) [lol] # localized-orbital locator
* lol_kir(id) [lol_kir] # localized-orbital locator, with Kirzhnits k.e.d.
* brhole_a1(id), brhole_a2(id), brhole_a(id) # BR hole, A prefactor (spin up, down, and average)
* brhole_b1(id), brhole_b2(id), brhole_b(id) # BR hole, hole-reference distance (spin up, down, and average)
* brhole_alf1(id), brhole_alf2(id), brhole_alf(id) # BR hole, exponent (spin up, down, and average)
* xhcurv1(id), xhcurv2(id), xhcurv(id) # Curvature of the exchange hole at the reference point (spin up, down, and average)
* dsigs1(id), dsigs2(id), dsigs(id) # Same-spin pair density leading coefficient (Dsigma) (spin up, down, and average)
* stress [STRESS] # Schrodinger stress tensor of the reference field
* mep(id) # Molecular electrostatic potential
* uslater(id) # Slater potential
* nheff(id) # Reverse-BR effective hole normalization
* xc(...,idx)

# List of field modifiers ($field:modifier):
* v - valence-only value of the field
* c - core-only value of the field
* x, y, z: first derivatives.
* xx, xy, yx, xz, zx, yy, yz, zy, zz: second derivatives.
* g: norm of the gradient.
* l: Laplacian.
* lv: valence Laplacian.
* lc: core Laplacian.
* In molecular wavefunctions:
*   <n>: value of MO number <n>.
*   HOMO: highest-occupied molecular orbital (RHF).
*   LUMO: lowest-unoccupied molecular orbital (RHF).
*   A<n>: alpha MO number <n>.
*   B<n>: beta MO number <n>.
*   AHOMO: alpha highest-occupied molecular orbital (UHF).
*   ALUMO: alpha lowest-unoccupied molecular orbital (UHF).
*   BHOMO: beta highest-occupied molecular orbital (UHF).
*   BLUMO: beta lowest-unoccupied molecular orbital (UHF).
*   up, dn, sp - alpha, beta, spin density

# List of structural variables (@strucvar):
* dnuc: distance to the closest nucleus. (*)
* xnucx: x of the closest nucleus (crystallographic). (*)
* ynucx: y of the closest nucleus (crystallographic). (*)
* znucx: z of the closest nucleus (crystallographic). (*)
* xnucc: x of the closest nucleus (Cartesian). (*)
* ynucc: y of the closest nucleus (Cartesian). (*)
* znucc: z of the closest nucleus (Cartesian). (*)
* xx: x of the evaluation point (crystallographic).
* yx: y of the evaluation point (crystallographic).
* zx: z of the evaluation point (crystallographic).
* xc: x of the evaluation point (Cartesian).
* yc: y of the evaluation point (Cartesian).
* zc: z of the evaluation point (Cartesian).
* xxr: x of the evaluation point (reduced crystallographic).
* yxr: y of the evaluation point (reduced crystallographic).
* zxr: z of the evaluation point (reduced crystallographic).
* idnuc: complete-list id of the closest nucleus.
* nidnuc: non-equivalent-list id of the closest nucleus.
* rho0nuc: atomic density contribution from the closest nucleus. (*)
* spcnuc: species id of the closest nucleus.
* zatnuc: atomic number of the closest nucleus.
Entries with a (*) at the end accept a numerical modifier (:n) to
indicate the same quantity but referred to the nearest atom with ID
equal to n (from the complete list)
~~~
