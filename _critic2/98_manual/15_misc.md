---
layout: single
title: "Miscellaneous tools"
permalink: /critic2/manual/misc/
excerpt: "Miscellaneous tools in critic2."
sidebar:
  - repo: "critic2"
    nav: "critic2_manual"
toc: true
toc_label: "Miscellaneous tools"
toc_sticky: true
---

## Molecular Calculations (MOLCALC) {#c2-molcalc}

The MOLCALC keyword allows the (limited) calculation of molecular
properties:
~~~
MOLCALC [NELEC]
MOLCALC expr.s
MOLCALC PEACH
  mo1a [->] mo1r k1
  mo2a [->] mo2r k2
  [...]
ENDMOLCALC/END
MOLCALC HF
~~~
The MOLCALC keyword works mostly with molecular wavefunction
(wfn/wfx/fchk/molden) fields and Becke-style (molecular) meshes, but
crystals can also be used in some cases.

The NELEC keyword integrates the number of electrons using a molecular
mesh. This is useful for debugging purposes. If an expression (`expr.s`)
is used, the scalar field generated by this expression is integrated
on the molecular mesh.

The PEACH keyword calculates the index for the characterization of
electronic excitations based on orbital overlap defined as uppercase
lambda in [Peach et al., J. Chem. Phys. 128 (2008) 044118](https://doi.org/10.1063/1.2831900).
Small values (close to zero) correspond to little orbital overlap and
Rydberg excitations. Large values (close to one) are caused by high
orbital overlap and correspond to local excitations. Charge transfer
excitations can have both high or low PEACH value. Each line gives the
initial (`mo1a`) and final (`mo1r`) molecular orbital and the
oscillator strength (`k1`) for each component of the excitation. If
Gaussian is used, copying and pasting the output of the `TD` keyword
is recommended. Using the PEACH keyword requires the virtual orbitals,
which in turn requires using a fchk or molden file format with the
READVIRTUAL keyword (see the [LOAD](/critic2/manual/fields/#c2-load)
keyword).

MOLCALC HF calculates the Hartree-Fock energy from the basis set
information in the reference field using molecular integrals, which
are in turn calculated by the [libcint library](/critic2/installation/#c2-libcint).
Using this keyword requires compiling with critic2 with libcint. At
this moment, this keyword serves mostly for testing, debug, and
development purposes, as it is very inefficient (and not very
useful). The routine called by this keyword shows how to use libcint
inside critic2. Only molecular wavefunctions can be used with 
`MOLCALC HF` and only file formats that provide basis set information
(right now, only Gaussian fchk, but molden-style files could be
implemented). Gaussian wfn/wfx do not provide basis set shells, only
primitives, so they cannot be used with MOLCALC HF.

## Hirshfeld Charges (HIRSHFELD) {#c2-hirshfeld}

The HIRSHFELD keyword calculates the 
[Hirshfeld charges](https://doi.org/10.1063/1.2831900) in the system:
~~~
HIRSHFELD
~~~
The HIRSHFELD keyword can be used only with fields defined on a grid.

## The Exchange-Hole Dipole Moment Dispersion Model (XDM) {#c2-xdm}

The XDM keyword calculates the dispersion energy using the
exchange-hole dipole moment (XDM) model. See 
[J. Chem. Phys. 127, 154108 (2007)](https://doi.org/10.1063/1.2795701),
[J. Chem. Phys. 136, 174109 (2012)](https://doi.org/10.1063/1.4705760), and
[J. Chem. Phys. 138, 204109 (2013)](https://doi.org/10.1063/1.4807330)
for more details. The syntax of the XDM keyword is:
~~~
XDM GRID [RHO irho.s] [TAU itau.s] [ELF ielf.s] 
    [PDENS ipdens.s] [CORE icor.s] [LAP ilap.s] 
    [GRAD igrad.s] [RHOAE irhoae.s] [XB ib.s] 
    [XA1 a1.r] [XA2 a2.r] [ONLYC] [UPTO {6|8|10}]
XDM QE [BETWEEN at1.i at1.i ... AND at1.i at2.i ...]
XDM a1.r a2.r chf.s
~~~
There are three modes of operation for the XDM keyword. In QE, the
coefficients are read from a Quantum ESPRESSO output (loaded using
CRYSTAL), and the XDM energy is recalculated. If BETWEEN and AND are
given only the dispersion interaction between those pairs of atoms is
calculated. This keyword is used mostly for testing purposes. 
In the GRID mode, the information necessary to calculate the XDM
dispersion energy and related quantities is provided using grid
fields. If neither QE nor GRID are given, a molecular XDM calculation
is assumed, with damping function coefficients `a1.r` and `a2.r` and
functional selector `chf.s`. The latter can be either a keyword for a
functional (`blyp`, `b3lyp`, etc.) or a number between 0 and 1
indicating the fraction of exact exchange. The molecular XDM code can
be used only with wavefunction fields and DFTB fields.

The rest of the information in this section applies to the XDM GRID
keyword. XDM GRID uses the electron density (RHO), the kinetic energy
density (TAU), the Laplacian (LAP), and the gradient of the electron
density (GRAD) to compute the exchange-hole dipole moment in the
Becke-Roussel model (B). The promolecular density (PDENS) and the core
density (CORE) are used to calculate a Hirshfeld partitioning of the
unit cell. All of these fields must be available or are calculated
when running XDM. The corresponding keywords accept an integer,
corresponding to a previously loaded field. During the XDM run, cubes
for all of these fields are generated so they can be loaded in
subsequent runs.

The list of requirements is:

* RHO: the electron density. By default, `irho.s` is the reference
  field. This field is required in XDM. It is also required to give
  the pseudopotential charges using the ZPSP keyword for all types of
  atoms in the system.

* TAU: the kinetic energy density. It is used in the calculation of B,
  and can be extracted from the ELF. Hence, it is required except if
  the ELF or the B is given. If the ELF is used instead of TAU, a cube
  file (`-tau.cube`) is written.

* ELF: the electron localization function. Can be used in place of
  TAU. This is useful because most programs (e.g. QE, VASP) generate
  cubes for the ELF but not for the kinetic energy density.

* PDENS: the promolecular density. It is generated by critic2 if not
  present in the XDM call, and written to a cube file (`-pdens.cube`)
  for future use.

* CORE: the core density. It is generated by critic2 if not present in
  the XDM call and written to a cube (`-core.cube`), unless the B and
  RHOAE are given, in which case it is ignored. The ZPSP of all atoms
  is required in order to calculate this quantity.

* LAP: the Laplacian of the electron density. It is generated by
  Fourier transform of RHO unless it is given or B is given, in which
  case it is not needed and its calculation is skipped.

* GRAD: the gradient of the electron density. It is generated from RHO
  unless B is given. If B is available, the calculation of GRAD is
  skipped.

* RHOAE: the all-electron density on a cube. If given, replaces the
  pseudo-density plus core in the calculation of the atomic volumes.

* XB: the exchange-hole dipole moment in the Becke-Roussel
  model. Calculated from the above unless given.

Only closed-shell (non-spinpolarized) systems can be calculated for now. 

The usual way of running XDM for the first time is:
~~~
CRYSTAL rho.cube
ZPSP C 4 O 6 H 1
LOAD rho.cube
LOAD elf.cube
XDM GRID elf 2
~~~
This generates several cube files: `root-tau.cube`, `root-pdens.cube`,
`root-core.cube`, `root-lap.cube`, `root-grad.cube`, and
`root-b.cube`. Subsequent runs can circumvent the calculation of B,
PDENS, and CORE by doing:
~~~
CRYSTAL rho.cube
ZPSP C 4 O 6 H 1
LOAD rho.cube
LOAD root-b.cube
LOAD root-pdens.cube
LOAD root-core.cube
XDM GRID XB 2 PDENS 3 CORE 4
~~~
Note that passing `RHO 1` is not necessary because `rho.cube` is the
first field loaded (hence the reference) and assumed by default to be
the density by XDM. The ZPSP of all atoms are needed for an XDM
calculation. During the calculation, cubes for almost all
the properties above are generated so they can be reused in future
calculations. The other options are:
~~~
XA1 [a1.r]
~~~
The value of the a1 damping parameter (adimensional). Default:
0.6836 (PW86PBE parametrization for QE).
~~~
XA2 [a2.r]
~~~
The value of the a1 damping parameter (in angstrom). Default:
1.5045 (PW86PBE parametrization for QE).
~~~
ONLYC
~~~
Calculate the dispersion coefficients but not the dispersion
energy, forces, and stress. By default, they are calculated.
~~~
UPTO {6|8|10}
~~~
Only calculate the contributions to the energy coming from the 
$$C_6$$ term (6), from the $$C_6$$ and $$C_8$$ terms (8) and from 
$$C_6$$, $$C_8$$, and $$C_{10}$$ (10). The latter is the default.

## Control Commands and Options {#c2-control}

This section lists a number of keywords that are used to control the
operation of critic2. In general, they should be given before the
keywords that employ those options are used. For instance, `ODE_MODE`
should be given before integrating by bisection.

### Gradient Path Tracing (ODE\_MODE) {#c2-odemode}

~~~
ODE_MODE [METHOD {EULER|HEUN|BS|RKCK|DP}] [MAXSTEP maxstep.r] 
         [MAXERR maxerr.r] [GRADEPS gradeps.r]
~~~
The keyword `ODE_MODE` is used to control the gradient path
integration algorithm. `EULER` selects plain explicit Euler (1
evaluation per step) with a poor man's technique for the step size
adaptation. `HEUN`, Heun's method (2 evaluations), with the same size
adaptation as Euler's. `BS`, Bogacki-Shampine's embedded 2(3)th-order
method with error estimation and first step as last. `RKCK`,
Runge-Kutta-Cash-Karp embedded 4-5th order method with local
extrapolation and error estimate. `DP`, Dormand-Prince 4-5th order with
local extrapolation and error estimate (7 evaluations per
step). `maxstep.r` is the initial (and maximum) step size (bohr in
crystals, angstrom in molecules), `gradeps.r` is the 
gradient norm termination criterion for the gradient path. `maxerr.r` is
the maximum error in the trajectory (in bohr). `MAXERR` only affects
methods that provide an error estimate for the predicted steps: `BS`,
`RKCK`, and `DP`.

This keyword applies to all gradient paths except those in qtree. The
defaults are `BS` method with `maxstep.r` = 0.3 bohr, `gradeps.r` = 1e-7,
and `maxerr.r` = 1e-5.

### Gradient Path Plot Pruning (PRUNE\_DISTANCE) {#c2-prunedistance}

Plots of gradient paths are pruned so that only one point is plotted
every certain length. The PRUNE\_DISTANCE keyword is used to control
this length:
~~~
PRUNE_DISTANCE prune.r
~~~
Only one point is plotted every `prune.r` distance (units: bohr in
crystals and angstrom in molecules, default: 0.1 bohr). Gradient paths
are forced to have steps of length less than or equal to
`prune.r`. Therefore, a very small `PRUNE_DISTANCE` will result in
slow gradient path tracing.

### Radial Integration Method (INT\_RADIAL) {#c2-intradial}

The `INT_RADIAL` keyword chooses the type of radial integration method
used inside spheres or atomic basins:
~~~
INT_RADIAL [TYPE {GAULEG|QAGS|QNG|QAG}] [NR nr.r]
           [ABSERR aerr.r] [RELERR rerr.r]
           [ERRPROP prop.i]
           [PREC delta.r]
~~~
The `TYPE` keyword selects the quadrature method:

+ `GAULEG`: Gauss-Legendre.

+ `QAGS`: quadpack's dqags (general-purpose, extrapolation, globally
  adaptive, end-point singularities). All Q methods are sometimes
  unstable for heavy atoms and big beta-spheres, but this does not
  happen very often.

+ `QNG`: quadpack's dqng (smooth integrand, non-adaptive,
  Gauss-Kronrod(Patterson))

+ `QAG`: quadpack's dqag (general-purpose, integrand examiner,
  globally adaptive, Gauss-Kronrod)

The number of radial integration points, if appropriate (`GAULEG`,
`QAG`) is selected with `NR`. If the selected method is `QAG`, the
number of points may vary from `nr.r`. The allowed intervals are: 
7-15, 10-21, 15-31, 20-41, 25-51, 30-61. Critic2 selects the
appropriate interval by comparing the given `nr.r` to the lower
limits of these intervals.

`ABSERR` is the requested absolute error for QUADPACK
integrators. `RELERR` is the requested relative error for QUADPACK
integrators. `ERRPROP` controls the property for which the error is
estimated. If `prop.i` corresponds to one of the integrable properties
then `RELERR` and `ABSERR` apply only to it. The selected property
guides the adaptive integration procedure. If `prop.i` does not
represent one of the integrable properties, the maximum of the
absolute value of the properties vector is used.  Note: the option
where max(abs(prop)) is used is unstable. Some spheres (usually
associated to heavy atoms) may integrate to nonsense, depending on the
optimization levels of the compiler. Therefore, this option is
disabled by default.

In the case of basin integrations, `PREC` controls the precision in
the determination of the interatomic surface (bohr in crystal,
angstrom in molecules).

Default: `GAULEG`, `nr.r` = 50, `aerr.r` = 1d0, `rerr.r` = 1d-12. The
default errprop is the field value and the Laplacian. `delta.r` = 1e-5
bohr.

### Integration Meshes (MESHTYPE) {#c2-meshtype}

The MESHTYPE keyword chooses the type and quality of the molecular
integration mesh:
~~~
MESHTYPE {BECKE|FRANCHINI} [SMALL|NORMAL|GOOD|VERYGOOD|AMAZING]
~~~
These meshes are used in molecules and crystals to calculate integrals
over the whole space (cell in crystals, R3 in molecules). The MESHTYPE
affects XDM integration in molecules, MOLCALC, and the MESH seeding
option to AUTO.

- BECKE: Becke-style integration grid. Only available for molecules.

- FRANCHINI: a Becke-style molecular mesh with weights and quality 
  parameters adapted from 
  [Franchini et al. J. Comput. Chem. 34 (2013) 1819](https://doi.org/10.1002/jcc.23323).
  Works with molecules and crystals.

The fineness of the integration grid is be chosen by using one of
SMALL, NORMAL, GOOD, VERYGOOD, and AMAZING. No pruning of the mesh is
done yet.

Default: FRANCHINI, GOOD.

### Cube File Precision (PRECISECUBE/STANDARDCUBE) {#c2-precisecube}

The PRECISECUBE and STANDARDCUBE keywords control the precision of the
numbers written to cube files:
~~~
PRECISECUBE|STANDARDCUBE
~~~
The field values in cube files written by Gaussian are written in
exponential format with six significant digits. This precision may not
be enough for some applications, particularly involving energies. The
default behavior of critic2 (corresponding to the PRECISECUBE keyword)
is to write cubes with 14 significant digits. Some other programs that
use Gaussian cube files may not like this, however, so the keyword
STANDARDCUBE is provided to make critic2 write cube files in the
default Gaussian format.

### Bond Distance Factor (BONDFACTOR) {#c2-bondfactor}

The BONDFACTOR keyword controls the bond detection subroutines in
critic2:
~~~
BONDFACTOR bondfactor.r
~~~
Critic2 considers two atoms are covalently bonded if their distance is
less than the sum of their covalent radii times `bondfactor.r` (default:
1.4). The maximum bondfactor allowed is 2.0.

### Covalent Radii (RADII) {#c2-radii}

The keyword RADII allows changing the internal table of covalent
radii:
~~~
RADII [at1.s|z1.i] rad1.r [[at2.s|z2.i] rad2.r ...]
~~~
RADII sets the covalent radii of atoms with atomic symbol `at1.s` or
atomic number `z1.i` to `rad1.r`. (Units: bohr in crystals, angstroms
in molecules). The radii of several atoms can be changed in the same
command.

### Root of Files Created by Critic2 (ROOT) {#c2-root}

The keyword ROOT:
~~~
ROOT root.s
~~~
changes the `<root>` of the critic2 run. The root is used as prefix
for most of the auxiliary files written by critic2.

### Grid Calculations (SUM,MAX,MIN,MEAN,COUNT) {#c2-gridcalc}

These five keywords:
~~~
SUM [id.s]
MAX [id.s]
MIN [id.s]
MEAN [id.s]
COUNT id.s eps.r
~~~
are used to preform calculations using the field on a grid id.s. SUM 
calculates the sum of the grid point values. MAX calculates the
maximum value of all points on the grid. MIN calculates the minimum
value. MEAN calculates the average value. COUNT counts the number of
elements that are greater than `eps.r`. If no `id.s` is given in the
first four commands, then the reference field is used, provided it is
defined on a grid. 

### Benchmark Calculations on Fields (BENCHMARK) {#c2-benchmark}

The BENCHMARK keyword:
~~~
BENCHMARK [nn.i]
~~~
is used to determine the average speed of the evaluation of the
reference field using `nn.i` points (default: 10000). Mostly for debug
and development purposes.

### Run System Commands (RUN/SYSTEM) {#c2-system}

~~~
{RUN|SYSTEM} command.s
~~~
Execute a shell command.

### Echo a Message (ECHO) {#c2-echo}

~~~
ECHO string.s
~~~
Write the string `string.s` to the output. Useful for partitioning
long outputs.

### Terminate the Run (END) {#c2-end}

~~~
END
~~~
Terminates the execution of critic2.

### Expression Evaluation {#c2-expression}

~~~
expression.s
~~~
If the input is not identified with any of the reserved keywords, then
evaluate the command as an arithmetic expression and print its
value. Useful for simple calculations in the command line (with
critic2 -q).

## Examples

- MOLCALC

  + [Calculations using molecular structures and wavefunctions](/critic2/examples/example_15_01_molcalc/)
