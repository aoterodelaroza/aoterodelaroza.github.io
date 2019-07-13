---
layout: single
title: "Delocalization Indices in Solids using Wannier Functions"
permalink: /critic2/examples/example_11_10_deloc-indices/
excerpt: "Delocalization indices in Solids using Wannier Functions"
sidebar:
  - repo: "critic2"
    nav: "critic2_examples"
toc: true
toc_label: "DIs in Solids using MLWFs"
---

Critic2 can calculate Bader's localization and delocalization indices
(DI) in solids using the pseudopotentials/plane waves approach. The
DIs are a measure of electron delocalization (sharing) between atoms,
related to the covalent bond order. The way DIs are calculated in
critic2 makes use of a transformation of the one-electron KS states
to Wannier functions, in such a way that the resulting states are
maximally localized. These 
[maximally localized wannier functions (MLWF)](http://dx.doi.org/10.1103/RevModPhys.84.1419) 
are useful for this because they allow discarding most of the atomic
overlap integrals required for the DI calculation. The details of the
algorithm and some examples are described in 
[JCTC 14 (2018) 4699](http://dx.doi.org/10.1021/acs.jctc.8b00549). 

In the following examples, we use [Quantum
ESPRESSO](https://www.quantum-espresso.org/) (QE) to run the SCF
calculations, [wannier90](http://www.wannier.org/) to compute the
transformation to MLWF and the development version of critic2 to
obtain the DIs. The tool we need to extract the KS states from the
QE run (`pw2critic.x`) was introduced in version ~6.4, so either this
or a more recent version is required. Any version of wannier90 from
2.0 onwards works.

Each DI calculation is carried out using a sequence of steps. In
general, you need to:

1. Run a PAW SCF calculation with `pw.x`. This is done in order to
   calculate the all-electron density required for the correct
   determination of the atomic basins. The all-electron density is
   written to a cube file (`rhoae.cube`) with `pp.x`.

2. Run a norm-conserving SCF calculation using `pw.x` and the same
   `ecutrho` as in step 1. This will generate the KS states that we
   will transform into our MLWFs.

3. Calculate the pseudo-valence electron density from the converged
   norm-conserving SCF calculation and write it to a cube file
   (`rho.cube`) with `pp.x`. This is done only for consistency checks
   as, in practice, the pseudo-density will always be available as a
   sum over the squares of the MLWFs.

4. Use `open_grid.x` to unpack the k-point symmetry from the
   norm-conserving calculation and prepare the Wannier run. Using
   `open_grid.x` saves time but a non-selfconsistent calculation with
   a list of all k-points in the uniform grid can also be used.

5. Extract the KS coefficient, structure, and k-point mapping data to
   a `.pwc` file using `pw2critic.x`.

6. Run wannier90 in the usual way to get its checkpoint file
   (`.chk`). In spin-polarized cases, this needs to be done twice,
   once for each spin component.

7. Read the structure and the `.pwc` and the `.chk` files as a field
   in critic2 and calculate the DIs. The calculation of the
   DIs is activated using INTEGRABLE and the DELOC keyword. 

In the output, the localization indices as well as all interatomic DIs
are given as a function of distance from the reference atom. For an
$$m \times n \times l$$ grid, all DIs between all pairs of atoms
inside a $$m\times n\times l$$ supercell will be obtained. Hence, the
higher m, n, and l, the longer the calculation will take. The cost of
the DI calculation also depends on the `ecutrho` of both SCF
calculations. In molecular crystals, molecular localization and
delocalization indices are also calculated.

## Magnesium oxide (MgO)

The PAW calculation (step 1) with `pw.x` is straightforward:
```
&control
 title='crystal',
 prefix='crystal',
 pseudo_dir='../zz_psps',
/
&system
 ibrav=0,
 celldm(1)=1.0,
 nat=2,
 ntyp=2,
 ecutwfc=80.0,
 ecutrho=320.0,
/
&electrons
 conv_thr = 1d-8,
/
ATOMIC_SPECIES
o     15.999400 o_paw.UPF
mg    24.305000 mg_paw.UPF

ATOMIC_POSITIONS crystal
mg       0.500000000   0.000000000   0.000000000
o        0.000000000   0.500000000   0.500000000

K_POINTS automatic
4 4 4 1 1 1

CELL_PARAMETERS cubic
  -0.000000000   3.901537427  -3.901537427
   3.901540775   3.901536617  -0.000000811
   3.901540775   0.000000811  -3.901536617
```
This is the (rhombohedral) primitive cell of magnesium oxide, with
only two atoms in it. After this calculation is converged, we extract
the all-electron density with `pp.x` and the input:
```
&inputpp
 prefix='crystal',
 plot_num=21,
/
&plot
 iflag = 3,
 output_format=6,
 fileout='rhoae.cube',
/
```
This generates `rhoae.cube`. We will use this as the reference field
for our atomic integrations, since it is the only density that can
give the correct Bader basins. Next is the norm-conserving calculation
(step 2):
```
&control
 title='crystal',
 prefix='crystal',
 pseudo_dir='../zz_psps,
 outdir='.',
/
&system
 ibrav=0,
 celldm(1)=1.0,
 nat=2,
 ntyp=2,
 ecutwfc=80.0,
 ecutrho=320.0,
 nosym=.true.,
/
&electrons
 conv_thr = 1d-8,
/
ATOMIC_SPECIES
o     15.999400 o.UPF
mg    24.305000 mg.UPF

ATOMIC_POSITIONS crystal
mg       0.500000000   0.000000000   0.000000000
o        0.000000000   0.500000000   0.500000000

K_POINTS automatic
4 4 4 0 0 0

CELL_PARAMETERS cubic
  -0.000000000   3.901537427  -3.901537427
   3.901540775   3.901536617  -0.000000811
   3.901540775   0.000000811  -3.901536617
```
There are several things to note in this input:
* The pseudopotentials are naturally different from those in the PAW
run but the crystal geometry is the same. 

* We use the `outdir` variable to have it write the `.save` directory
and the `.wfc` files to the current directory, so there are no mishaps
when we attempt to extract the KS states from them.

* The `ecutrho` is the same as in the PAW calculation. This will
result in the `rhoae.cube` and the KS states being represented by
grids with the same number of points (which is a prerequisite for the
DI calculation in critic2).

* The symmetry is deactivated using the `nosym=.true.` flag. This is
technically not necessary but, if it is not done, the density obtained
from the `rho.cube` generated by `pp.x` and that calculated as the sum
of the squares of the MLWFs are slightly different. This is because
the former undergoes an additional symmetrization step inside QE. In
practice, the results are the same regardless of whether `nosym` is
used or not.

* We use an automatic uniform grid but we eliminate the k-point
shifts, which would result in k-point positions that critic2 would not
know how to handle.

The pseudo-density cube file is generated next, using:
```
&inputpp
 prefix='crystal',
 plot_num=0,
/
&plot
 iflag = 3,
 output_format=6,
 fileout='rho.cube',
/
```
The `rho.cube` file will only be used for checks, since the same
information is contained in the `.pwc` file.

Now we run `open_grid.x` (step 4) on this very simple input:
```
&inputpp
 outdir='.',
 prefix='crystal',
/
```
This will unpack the k-points from the last SCF calculation and prepare
the wannier90 run. The execution of `open_grid.x` generates a list of
k-points that we will use later in the wannier90 input:
```
     Writing output data file crystal_open.save/
     Grid of q-points
     Dimensions:   4   4   4
     Shift:        0   0   0
     List to be put in the .win file of wannier90: (already in crystal/fractionary coordinates):
    0.000000000000000    0.000000000000000    0.000000000000000    0.0156250000
    0.000000000000000   -0.000000000000000    0.250000000000000    0.0156250000
[...]
   -0.250000000000000   -0.250000000000000    0.500000000000000    0.0156250000
   -0.250000000000000   -0.250000000000000   -0.250000000000000    0.0156250000
```

After unpacking the k-point grid, we need to extract the KS state
coefficients from the QE files by using `pw2critic.x` (step 5):
```
&inputpp 
 outdir = '.',
 prefix='crystal_open',
 seedname = 'mgo',
/
```
The `crystal_open` prefix is automatically created by `open_grid.x`
from the original prefix by appending `_open`. Note that `pw2critic.x`
needs to be run *without* MPI. Using `mpirun` on it will not work. The
execution of `pw2critic.x` creates a `.pwc` file can be read by
critic2 and contains the reciprocal-space coefficients of the
Kohn-Sham states.

The second piece of information we need for the DI calculation is the
rotation of the KS states to yield the MLWF. We calculate this with
`wannier90` (step 6). The input is:
```
num_wann = 4
num_iter = 20000
conv_tol = 1e-8
conv_window = 3

begin unit_cell_cart
bohr
  -0.000000000   3.901537427  -3.901537427
   3.901540775   3.901536617  -0.000000811
   3.901540775   0.000000811  -3.901536617
end unit_cell_cart

begin atoms_frac
mg       0.500000000   0.000000000   0.000000000
o        0.000000000   0.500000000   0.500000000
end atoms_frac

begin projections
random
end projections

search_shells = 24
kmesh_tol = 1d-3
mp_grid : 4 4 4

begin kpoints
    0.000000000000000    0.000000000000000    0.000000000000000    0.0156250000
[...]
   -0.250000000000000   -0.250000000000000   -0.250000000000000    0.0156250000
end kpoints
```
The `num_wann` is the number of bands in the system, equal to the
`number of Kohn-Sham states` in the norm-conserving SCF output. The
geometry is the same as in the QE calculations. The k-mesh is the same
as in the norm-conserving SCF calculation (4x4x4) and the list of
k-points is the one generated in the output of `open_grid.x`
(shortened here for convenience). To run wannier90, first we generate
the list of items that it needs from QE by doing:
```
$ wannier90.x -pp mgo.win
```
and then we run the `pw2wannier90.x` utility on the input:
```
&inputpp 
 prefix='crystal_open',
 seedname = 'mgo',
 write_mmn = .true.,
 write_amn = .true.,
 outdir='.',
/
```
This creates the files containing the integrals required for the
wannier90 run. Note that we use the prefix for the files created by
`open_grid.x`. Finally, we do:
```
$ wannier90.x mgo.win
```
and this runs the MLWF calculation and writes the rotation matrix to
the checkpoint (`.chk`) file.

Now that we have the `.pwc` file (with the KS coefficients) and the
`.chk` file (with the orbital rotation), we can finally put everything
together and use critic2 to calculate the DIs (step 7). The input is:
```
crystal mgo.pwc
load rhoae.cube
load mgo.pwc mgo.chk

integrable 2
integrable 2 deloc

yt
```
The crystal structure is read from the `.pwc` file (equivalently, it
can be read from any of the cube files or `pw.x` input/output files.
They should all be the same.) The all-electron density is loaded first
and set as the reference fields so that it is used to calculate the
atomic basins. Then, the `.pwc` and `.chk` files are loaded together
into field number two, which is set as integrable and we activate the
calculation of the DIs with the DELOC keyword. Finally, we run the
Yu-Trinkle integration with YT.

After a few seconds, the DIs are done (it will take longer for larger
crystals or crystals with more bands or denser density and k-point
grids). For each atom in the unit cell a table like this is written:
```
# Attractor 1 (cp=1, ncp=1, name=mg, Z=12) at: 0.5000000  0.0000000  0.0000000
# Id   cp   ncp   Name  Z    Latt. vec.     ----  Cryst. coordinates ----       Distance        LI/DI
  Localization index.......................................................................  0.01220619
  26   2    2      o    8    0  -1   0   0.0000000   -0.5000000    0.5000000    3.9015366    0.10953819
  58   2    2      o    8    1  -1   0   1.0000000   -0.5000000    0.5000000    3.9015366    0.10956477
  40   2    2      o    8    1   0  -1   1.0000000    0.5000000   -0.5000000    3.9015366    0.10953816
  8    2    2      o    8    0   0  -1   0.0000000    0.5000000   -0.5000000    3.9015366    0.10951576
  2    2    2      o    8    0   0   0   0.0000000    0.5000000    0.5000000    3.9015408    0.10937694
  64   2    2      o    8    1  -1  -1   1.0000000   -0.5000000   -0.5000000    3.9015408    0.10937112
  27   1    1      mg   12   0  -1   1   0.5000000   -1.0000000    1.0000000    5.5176049    0.00114987
[...]
  43   1    1      mg   12   1  -3   1   1.5000000   -3.0000000    1.0000000   13.5153222    0.00000393
  85   1    1      mg   12  -2  -2   2  -1.5000000   -2.0000000    2.0000000   15.6061465    0.00000055
  Total (atomic population)................................................................  0.36083759
```
The numbers on the last column are the localization and delocalization
indices. The first is the LI, and then the DIs with the other atoms in
the system, ordered by distance to the atom that generates the
table. For a given row, the other fields are, in order: the
attractor ID, complete-list ID, and non-equivalent list ID of the
atom, the atomic name, atomic number, and lattice vector translation
to its position relative to the main cell, its
crystallographic coordinates, and its distance to the atom that
generates the table. At the very end of the table, the sum of the
localization index and 0.5 times the sum of all the DIs is taken. This
number is the atomic population (average number of electrons in the
basin) and should coincide with the value given in the integration
table above (column `$2`):
```
* Integrated atomic properties
# Id   cp   ncp   Name  Z   mult     Volume            Pop             Lap             $2       
  1    1    1      mg   12  --   2.98869287E+01  1.55039497E+01 -3.29194756E+01  3.60837590E-01
  2    2    2      o    8   --   8.88914848E+01  1.06091782E+01  3.29194756E+01  7.63916241E+00
------------------------------------------------------------------------------------------------
  Sum                            1.18778413E+02  2.61131279E+01  4.81747975E-12  8.00000000E+00
```

Final remark: because the DI calculation can take a long time,
checkpoint files are automatically generated that contain the atomic
overlap matrices (`.pwc-sij`) and the FAB integrals (`.pwc-fa`). These
files are automatically read in second and subsequent runs.

The files for this example can be found in the
[example_11_10.tar.xz](/assets/critic2/example_11_10/example_11_10.tar.xz)
package, `mgo` subdirectory. The `runit.sh` script automatizes the
steps above.

### MgO using a non-SCF calculation instead of open_grid.x

Exactly the same DI calculation can be carried out in a different way
by using a non-self-consistent (nscf) calculation instead of the
`open_grid.x` program. If the latter is available, there is really not
much point in carrying out the DI calculation in this manner, save for
testing purposes. The sequence of steps is the same as above except
instead of running `open_grid.x`, we use `pw.x` to run:
```
&control
 title='crystal',
 prefix='crystal',
 pseudo_dir='../../data',
 calculation='nscf',
 wf_collect=.true.,
 verbosity='high',
 outdir='.',
/
&system
 ibrav=0,
 celldm(1)=1.0,
 nat=2,
 ntyp=2,
 ecutwfc=80.0,
 ecutrho=320.0,
 nosym=.true.,
/
&electrons
 conv_thr = 1d-8,
/
ATOMIC_SPECIES
o     15.999400 o.UPF
mg    24.305000 mg.UPF

ATOMIC_POSITIONS crystal
mg       0.500000000   0.000000000   0.000000000
o        0.000000000   0.500000000   0.500000000

K_POINTS crystal
64
  0.00000000  0.00000000  0.00000000  1.562500e-02 
[...]
  0.75000000  0.75000000  0.75000000  1.562500e-02 

CELL_PARAMETERS cubic
  -0.000000000   3.901537427  -3.901537427
   3.901540775   3.901536617  -0.000000811
   3.901540775   0.000000811  -3.901536617
```
The calculation is non-self-consistent (`calculation='nscf'`) and uses
the converged wavefunction calculated in the self-consistent step. In
addition, the list of k-points is passed by hand, and it contains the
64 points corresponding to an unshifted 4x4x4 grid. This list can be
generated with the `kmesh.pl` utility from the wannier90 package:
```
$ kmesh.pl 4 4 4
```
The rest of the DI calculation is exactly the same except all mentions
to the `crystal_open` prefix (which correspond to the output of
`open_grid.x`) are replaced by `crystal` and the list of k-points in
the wannier90 input must be the same as in the non-self-consistent
calculation.

## Graphite

The sequence of steps for calculating the DIs in more complex systems
is exactly the same as in MgO. Because the Wannier transformation is
ill-defined in systems with partially occupied bands (metals), the
calculation of DIs via Wannier functions does not work for
those. However, semimetals such as graphite can be calculated without
a problem.

In the graphite example included in the files package, we use a 8x8x2
k-point grid. The resulting DIs clearly differentiate between DIs for
atoms in the same graphene layer and in different layers:

```
+ Delocalization indices
  Each block gives information about a single atom in the main cell.
  First line: localization index. Next lines: delocaliazation index
  with all atoms in the environment. Last line: sum of LI + 0.5 * DIs,
  equal to the atomic population. Distances are in bohr.
# Attractor 1 (cp=1, ncp=1, name=C, Z=6) at: 0.0000000  0.0000000  0.2500000
# Id   cp   ncp   Name  Z    Latt. vec.     ----  Cryst. coordinates ----       Distance        LI/DI
  Localization index.......................................................................  1.84476772
  59   3    2      C    6    0  -1   0   0.3333333   -0.3333333    0.2500000    2.6795792    1.20502882
  507  3    2      C    6   -1  -1   0  -0.6666667   -0.3333333    0.2500000    2.6795793    1.20297829
  3    3    2      C    6    0   0   0   0.3333333    0.6666667    0.2500000    2.6795793    1.20496148
  449  1    1      C    6   -1   0   0  -1.0000000    0.0000000    0.2500000    4.6411674    0.05704442
  65   1    1      C    6    1   0   0   1.0000000    0.0000000    0.2500000    4.6411674    0.05704442
  505  1    1      C    6   -1  -1   0  -1.0000000   -1.0000000    0.2500000    4.6411674    0.05696313
  73   1    1      C    6    1   1   0   1.0000000    1.0000000    0.2500000    4.6411674    0.05696313
  57   1    1      C    6    0  -1   0   0.0000000   -1.0000000    0.2500000    4.6411674    0.05679926
  9    1    1      C    6    0   1   0   0.0000000    1.0000000    0.2500000    4.6411674    0.05679926
  67   3    2      C    6    1   0   0   1.3333333    0.6666667    0.2500000    5.3591585    0.03623788
  499  3    2      C    6   -1  -2   0  -0.6666667   -1.3333333    0.2500000    5.3591585    0.03538782
  451  3    2      C    6   -1   0   0  -0.6666667    0.6666667    0.2500000    5.3591585    0.03534794
  6    2    1      C    6    0   0  -1   0.0000000    0.0000000   -0.2500000    6.3268031    0.01795914
  2    2    1      C    6    0   0   0   0.0000000    0.0000000    0.7500000    6.3268031    0.01796043
  456  4    2      C    6   -1   0  -1  -0.3333333    0.3333333   -0.2500000    6.8708502    0.00629409
  452  4    2      C    6   -1   0   0  -0.3333333    0.3333333    0.7500000    6.8708502    0.00629535
  8    4    2      C    6    0   0  -1   0.6666667    0.3333333   -0.2500000    6.8708502    0.00629989
  4    4    2      C    6    0   0   0   0.6666667    0.3333333    0.7500000    6.8708502    0.00629977
  512  4    2      C    6   -1  -1  -1  -0.3333333   -0.6666667   -0.2500000    6.8708502    0.00627913
  508  4    2      C    6   -1  -1   0  -0.3333333   -0.6666667    0.7500000    6.8708502    0.00627871
  123  3    2      C    6    1  -1   0   1.3333333   -0.3333333    0.2500000    7.0895003    0.01039461
  51   3    2      C    6    0  -2   0   0.3333333   -1.3333333    0.2500000    7.0895003    0.01034672
  435  3    2      C    6   -2  -2   0  -1.6666667   -1.3333333    0.2500000    7.0895003    0.01030576
  75   3    2      C    6    1   1   0   1.3333333    1.6666667    0.2500000    7.0895003    0.01038713
  443  3    2      C    6   -2  -1   0  -1.6666667   -0.3333333    0.2500000    7.0895003    0.01031799
  11   3    2      C    6    0   1   0   0.3333333    1.6666667    0.2500000    7.0895003    0.01035279
[...]
```
The first three atoms are the three in-plane covalent bonds. Atoms in
the same layer (z = 0.25) show distinctly higher DIs than atoms in
different layers, even if they are farther away.

## A molecular crystal: urea

When a crystal composed of discrete units (a molecular crystal)
is read into critic2, the program will automatically detect it and
calculate the discrete fragment (molecules) that compose the crystal:
```
+ List of fragments in the system (2)
# Id = fragment ID. nat = number of atoms in fragment. C-o-m = center of mass (bohr).
# Discrete = is this fragment finite?
# Id  nat           Center of mass            Discrete  
  1    8      1.000000    0.500000    0.314384   Yes
  2    8      0.500000    1.000000    0.685616   Yes
```
In the example used above, the urea crystal, there are two molecules
in the unit cell each comprising 8 atoms. 

The DI calculation in a molecular crystal follows the same sequence of
steps as in MgO. However, critic2 detects the existence of discrete
units and offers more information. Specifically, the program
calculates the molecular localization indices (the sum of the LIs of
all atoms in the molecule plus the intramolecular DIs):
```
* Integrated molecular properties
+ Localization indices
# Mol       LI(A)           N(A)
  1     23.26310183     23.99999842
  2     23.26310705     24.00000158
```

Then, critic2 also writes to the output the list of intermolecular
delocalization indices. These are calculated as the sum of the DIs
between all atoms in the two interacting molecules. There is a table
of DIs for every molecule in the unit cell (two in this case) and the
DI information is sorted by distance to this molecule, in much the
same way as atomic DIs:
```
+ Delocalization indices
# Molecule 1 with 8 atoms at  1.000000   0.500000   0.314384 
# Mol   Latt. vec.    ---- Center of mass (cryst) ----      Distance      LI/DI
  Localization index................................................... 23.26310183
  2      1   0   0   1.5000000    1.0000000    0.6856165    8.1298272    0.16615726
  2      0   0   0   0.5000000    1.0000000    0.6856165    8.1298272    0.16615840
  2      1  -1   0   1.5000000    0.0000000    0.6856165    8.1298272    0.16615814
  2      0  -1   0   0.5000000    0.0000000    0.6856165    8.1298272    0.16615731
  1      0   0  -1   1.0000000    0.5000000   -0.6856165    8.8514772    0.46900724
  2      1  -1  -1   1.5000000    0.0000000   -0.3143835    9.2882471    0.07550946
  2      1   0  -1   1.5000000    1.0000000   -0.3143835    9.2882471    0.07550956
  2      0   0  -1   0.5000000    1.0000000   -0.3143835    9.2882471    0.07550951
  2      0  -1  -1   0.5000000    0.0000000   -0.3143835    9.2882471    0.07550956
  1     -1   0   0   0.0000000    0.5000000    0.3143835   10.5163259    0.01704341
  1      0  -1   0   1.0000000   -0.5000000    0.3143835   10.5163259    0.01704340
  1     -1   0  -1   0.0000000    0.5000000   -0.6856165   13.7456087    0.00045912
  1      0  -1  -1   1.0000000   -0.5000000   -0.6856165   13.7456087    0.00045912
  1     -1  -1   0   0.0000000   -0.5000000    0.3143835   14.8723308    0.00261252
  1     -1  -1  -1   0.0000000   -0.5000000   -0.6856165   17.3070757    0.00049917
  Total (atomic population)............................................ 23.99999842
```
Note that the sum of LI plus half of all DIs is the average molecular
electron population. In this case, both molecules are neutral, since
they are equivalent by symmetry.

## A spin-polarized case: FeO

Calculating the DIs in a spin-polarized calculation is a bit more
convoluted, but follows essentially the same procedure. In this
example, we calculate the DIs in iron(II) oxide (FeO), which has the
same structure type as MgO (rocksalt) but is ferromagnetic. The PAW
and NC SCF calculations and the extraction of the density cube files
is done in the same way as in MgO, except that the calculation is
spin-polarized. In PAW, this is done:
```
 nspin=2,
 starting_magnetization(1)=1.0,
 occupations='smearing',
 smearing='cold',
 degauss=0.1,
```
and in the NC calculation it is essential that we have completely
filled bands, so we fix the total magnetization based on the result of
PAW:
```
 nspin=2,
 tot_magnetization=4.0,
```
This results in a total of 9 bands, as shown in the NC SCF output:
```
     number of Kohn-Sham states=            9
```
With `verbosity=high`, we can verify that the spin-up channel has 9
occupied bands and spin-down has 5 occupied and 4 unoccupied bands:
```
[...]
 ------ SPIN UP ------------
          k = 0.0000 0.0000 0.0000 (  1639 PWs)   bands (ev):
    -8.7938   7.7292   7.8322   7.9838   8.1232   8.1283   8.1355   8.1770
     8.1880
     occupation numbers 
     1.0000   1.0000   1.0000   1.0000   1.0000   1.0000   1.0000   1.0000
     1.0000
 ------ SPIN DOWN ----------
          k = 0.0000 0.0000 0.0000 (  1639 PWs)   bands (ev):
    -8.2542   8.7307   8.7479   8.7545  11.2368  11.3607  11.4147  12.2011
    12.4321
     occupation numbers 
     1.0000   1.0000   1.0000   1.0000   1.0000   0.0000   0.0000   0.0000
     0.0000
[...]
```

An important difference relative to MgO happens when we calculate the
MLWFs. The way wannier90 works is that it requires two different
executions, one for each spin channel, where we need to indicate how
many bands are occupied. The spin-up wannier90 input 
(`feo_up.win`) is simple because we want to use all the occupied bands
in the transformation. It contains:
```
num_wann = 9
num_bands = 9
[...]
```
and the corresponding `pw2wannier90.x` file to generate the integrals
for wannier90 is:
```
&inputpp 
 prefix='crystal_open',
 seedname = 'feo_up',
 spin_component="up",
 write_mmn = .true.,
 write_amn = .true.,
/
```
The wannier90 calculation is run in the same way as before:
```
$ wannier90.x -pp feo_up.win
$ pw2wannier90.x < feo.pw2wan.up.in | tee feo.pw2wan.up.out
$ wannier90.x feo_up.win
```
which generates the `feo_up.chk` checkpoint file. We will read this
file into critic2.

The spin-down case is a little more complicated because only a subset
of the bands are filled. There are two different spin-dow wannier90
inputs: one for before and one for after `pw2wannier90.x`. The first
input is:
```
num_wann = 5
num_bands = 9
exclude_bands : 6-9
```
where we indicate that, even though there are 9 bands in the
calculation, we want to exclude bands 6 to 9, which are unoccupied. We
write the files that request the calculation of the integrals in QE:
```
$ wannier90.x -pp feo_dn.win
```
and then we run `pw2wannier90.x` with the input:
```
&inputpp 
 prefix='crystal_open',
 seedname = 'feo_dn',
 spin_component="down",
 write_mmn = .true.,
 write_amn = .true.,
/
```
In the second wannier run, where the actual MLWFs are calculated, we
only have 5 bands available, so it contains:
```
num_wann = 5
num_bands = 5
```
To generate the MLWFs
```
$ pw2wannier90.x < feo.pw2wan.dn.in | tee feo.pw2wan.dn.out
$ wannier90.x feo_dn.win
```
This creates the `feo_dn.chk` checkpoint file with the rotation for
the spin-down MLWFs.

Finally, we indicate that this is a spin-polarized case by passing
both checkpoint files to critic2:
```
crystal feo.pwc
load rhoae.cube id rho
load feo.pwc feo_up.chk feo_dn.chk

integrable 2
integrable 2 deloc

yt
```
The interpretation of the critic2 output is essentially the same as in
the MgO case.

## Example files package

Files: [example_11_10.tar.xz](/assets/critic2/example_11_10/example_11_10.tar.xz).

## Manual pages

- [The reference field](/critic2/manual/fields/#c2-reference)

- [Yu and Trinkle method (YT)](/critic2/manual/integrate/#c2-yt)

- [Loading a field](/critic2/manual/fields/#c2-load)

- [Marking fields or expressions as integrable quantities](/critic2/manual/integrate/#c2-integrable)

