---
layout: single
title: "Equations of State"
permalink: /gibbs2/manual/eos/
excerpt: "Choosing an Equation of State."
sidebar:
  - repo: "gibbs2"
    nav: "gibbs2_manual"
toc: true
toc_label: "Equations of State"
toc_sticky: true
---

## Equations of State {#g2-eos}

In order to calculate the volume derivatives of the energy, an
analytical expression needs to be fitted to the input $$E(V)$$
data. This mathematical expression, commonly known as the equation of
state (EOS), can take many forms. Which equation of state is used for
a particular phase is determined by the FIT option to PHASE:
~~~
PHASE ... [FIT {POLYGIBBS|BM2|BM3|BM4|PT2|PT3|PT4|PT5|MURN|ANTONS|VINET|AP2|
                STRAIN {EULERIAN|BM|NATURAL|PT|LAGRANGIAN|LAGR|INFINITESIMAL|
                        INF|QUOTIENT|X1|X3|XINV3|X3INV|V} [order.i|0]}]
          [REG {LAD|LSQ}] [FIX i1.i v1.r i2.i v2.r ...]
~~~
Two types of EOS can be used: those based on
[strain polynomials](#g2-strainpol) and analytical expressions with a
few parameters derived from the known elastic behavior of solids. The
latter are very common in the literature and we refer to them as
[traditional EOS](#g2-traditionaleos). The EOS is chosen using the FIT
option to the PHASE keyword.

The analytical EOS is used in two distinct contexts:

* The EOS is used to fit the static energy-volume data to generate the
  static equation equation of state.

* At a given temperature, the EOS is used to fit the Hemlholtz free
  energy vs. volume data. This is used to calculate the volume at that
  temperature and an arbitrary pressure $$V(p,T)$$ as well as the
  volume derivatives necessary for the calculation of the other
  thermodynamic properties.

Regardless of which equation of state is used to fit the data, it is
strongly recommended that the quality of the fit is examined for every
new set of data by at least plotting the 
[`efit` file](/gibbs2/manual/inputoutput/#g2-efitfile). 
This file presents the original source data and the fitted equation of
state, and allows assessing whether the fit is good or not. Ideally,
you would also examine the smoothness of some of the other
thermodynamic properties that depend on the derivatives of the E(V)
curve, such as the bulk modulus.

It is also important to note that gibbs2 is not designed for
extrapolation. Thermodynamic properties are never calculated at
equilibrium volumes outside of the input volume grid.

### EOS Based on Strain Polynomials {#g2-strainpol}

The EOS based on strain polynomials are fitted using a linear
least-squares fitting method (employing the SLATEC library). They are
selected by using the FIT option to PHASE followed by the STRAIN
keyword, the type of strain used, and the degree of the
polynomial. The strain type can be one of:

| Keyword        | Name                              | Expression                                                          |
|--------------------------------------------------------------------------------------------------------------------------|
| EULERIAN or BM | Birch-Murnaghan (Eulerian)        | $$f = \frac{1}{2}\left[\left(\frac{V}{V_0}\right)^{-2/3}-1\right]$$ |
| NATURAL or PT  | Poirier-Tarantola (natural)       | $$f = \frac{1}{3}\log\left(\frac{V}{V_0}\right)$$                   |
| LAGRANGIAN     | Lagrangian                        | $$f = \frac{1}{2}\left[\left(\frac{V}{V_0}\right)^{2/3}-1\right]$$  |
| INFINITESIMAL  | Infinitesimal                     | $$f = -\left(\frac{V}{V_0}\right)^{-1/3}+1$$                        |
| QUOTIENT or X1 | Compression factor                | $$f = \frac{V}{V_0}$$                                               |
| X3             | Linear compression factor         | $$f = \left(\frac{V}{V_0}\right)^{1/3}$$                            |
| XINV3 or X3INV | Inverse linear compression factor | $$f = \left(\frac{V}{V_0}\right)^{-1/3}$$                           |
| V              | Volume                            | $$f = V$$                                                           |

The type of strain must be followed by the degree of the polynomial
(`order.i`). For instance, `FIT STRAIN BM 4` indicates a
fourth-order Birch-Murnaghan EOS, equivalent to a fourth degree
polynomial in the BM strain.

If 0 is used as the degree of the polynomial, a number of polynomials
of increasing degree are fitted to the data and then a polynomial
average is used. The agreement between polynomials of various degrees
can be used as a measure of the quality of the input data.  The
minimum and maximum degree of the polynomials that enter the
polynomial average are controlled by the [SET MPAR and SET MPARMIN
keywords](#g2-optional). By default, the polymials go from third
degree up to 12th degree.  In cases when the input dataset contains
only a few points, the default maximum strain polynomial degree is
lower to prevent overfitting.

The default EOS in gibbs2 if no FIT keyword is given is to use an
average of strain polynomials based on the Birch-Murnaghan strain (FIT
STRAIN BM 0). This method has proved to be quite robust.

### Traditional EOS {#g2-traditionaleos}

Traditional EOS based on analytical expressions can be used in gibbs2
as well. They are activated for a given phase by using the FIT option
to the PHASE keyword followed by the keyword for the desired EOS.
Contrary to the strain polynomials, these EOS are fitted using a
non-linear minimization method (Levenberg-Marquardt) implemented in
the MINPACK library. The goodness of the fit using traditional EOS is
typically lower than with strain polynomials (particularly high-degree
polynomials or averages) but these EOS contain fewer parameters so
they are appropriate in cases when there are fewer points to fit, and
they can also be used to extrapolate or to smooth noisy data.

The list of traditional EOS implemented and the corresponding keywords
are:

| Keyword | Name              | Order | Parameters                        | Expression                                                                                                                                                                                                                                                                            |
|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| BM2     | Birch-Murnaghan   |     2 | $$E_0,V_0,B_0$$                   | $$E(V) = E_0 + \frac{9}{2} B_0 V_0 f^2$$, $$f = \frac{1}{2} \left[ \left(\frac{V_0}{V}\right)^{2/3} - 1 \right]$$                                                                                                                                                                     |
| BM3     | Birch-Murnaghan   |     3 | $$E_0,V_0,B_0,B_0'$$              | $$E(V) = E_0 + \frac{9}{2} V_0 B_0 f^2 [1 + (B_0^\prime-4) f]$$, $$f$$ as above                                                                                                                                                                                                       |
| BM4     | Birch-Murnaghan   |     4 | $$E_0,V_0,B_0,B_0',B_0''$$        | $$E(V) = E_0 + \frac{3}{8} V_0 B_0 f^2 \{(9H - 63B_0^\prime + 143) f^2 + 12 (B_0^\prime-4) f + 12\}$$, $$H = B_0 B_0^{\prime\prime} + (B_0^\prime)^2$$, $$f$$ as above                                                                                                                |
| PT2     | Poirier-Tarantola |     2 | $$E_0,V_0,B_0$$                   | $$E(V) = E_0 + \frac{9}{2} B_0 V_0 f_N^2$$, $$f_N = \ln\left(\frac{V}{V_0}\right)^{1/3}$$                                                                                                                                                                                             |
| PT3     | Poirier-Tarantola |     3 | $$E_0,V_0,B_0,B_0'$$              | $$E(V) = E_0 + \frac{9}{2} B_0 V_0 f_N^2 [(B_0^\prime+2)f_N+1]$$, $$f_N$$ as above                                                                                                                                                                                                    |
| PT4     | Poirier-Tarantola |     4 | $$E_0,V_0,B_0,B_0',B_0''$$        | $$E(V) = E_0 + 9B_0 V_0 f_N^2 \{3(H+3B_0^\prime+3) f_N^2 + 4(B_0^\prime+2) f_N + 4\}$$, $$H = B_0^{\prime\prime}B_0+(B_0^\prime)^2$$, $$f_N$$ as above                                                                                                                                |
| PT5     | Poirier-Tarantola |     5 | $$E_0,V_0,B_0,B_0',B_0'',B_0'''$$ | Cetacean needed.                                                                                                                                                                                                                                                                      |
| MURN    | Murnaghan         |     3 | $$E_0,V_0,B_0,B_0'$$              | $$E(V) = E_0 + \frac{B_0 V}{B_0^\prime} \left[ \frac{(V_0/V)^{B_0^\prime}}{B_0^\prime -1} + 1 \right] - \frac{B_0 V_0}{B_0^\prime - 1}$$                                                                                                                                              |
| ANTONS  | Anton-Schmidt     |     3 | $$E_{\infty},V_0,B_0,B_0'$$       | $$E(V) = E_\infty + \frac{B_0 V_0}{n+1} \left(\frac{V}{V_0}\right)^{n+1} \left[\ln\left(\frac{V}{V_0}\right) - \frac{1}{n+1} \right]$$, $$n = -B_0'/2$$                                                                                                                               |
| VINET   | Vinet             |     3 | $$E_0,V_0,B_0,B_0'$$              | $$E(V) = E_0 + \frac{4B_0V_0}{(B_0^\prime-1)^2} - \frac{2B_0V_0}{(B_0^\prime-1)^2} [3(B_0^\prime-1)(\eta-1)+2] \exp\left\{-\frac{3}{2}(B_0^\prime-1)(\eta-1)\right\}$$, $$\eta = (V/V_0)^{1/3}$$                                                                                      |
| AP2     | Holzapfel's AP2   |     3 | $$E_0,V_0,B_0,B_0'$$              | $$E(V) = E_0 + 9B_0V_0 \Big\{\left[\Gamma(-2,c_0\eta)-\Gamma(-2,c_0)\right] c_0^2 e^{c_0} + \left[\Gamma(-1,c_0\eta)-\Gamma(-1,c_0)\right] c_0(c_2-1) e^{c_0} - \left[\Gamma( 0,c_0\eta)-\Gamma( 0,c_0)\right] 2c_2 e^{c_0} + \frac{c_2}{c_0} \left[e^{c_0(1-\eta)}-1\right] \Big\}$$ |

Note that the AP2 EOS requires setting the number of electrons for the
system with the [NELECTRON keyword](#g2-optional). Also, the BM2, BM3,
etc. EOS are different from the equivalent strain polynomial versions
(STRAIN BM 2, STRAIN BM 3, etc.) only in that a non-linear
least-squares fit is used. The use of the strain polynomial versions
is recommended, as the two of them give equivalent results when the
fit is successful and non-linear fits may fail sometimes.

Lastly, the fitting method used in the previous version of the
program (gibbs) can be used with the POLYGIBBS keyword. This option is
available mostly for testing and backwards-compatibility. POLYGIBBS
may remove points from the energy-volume grid, and is known to be
unstable in some cases.

## Optional keywords  {#g2-optional}

The following optional keywords can be used to control how gibbs2
carries out the equation of state fitting:
~~~
REG {LAD|LSQ}
~~~
The REG keyword chooseS the regression technique for the EOS fits: least-squares
(LSQ, default) or least absolute deviation (LAD). The
former minmizes $$\sum_i |y_i-f(x_i)|^2$$ and the latter minimizes
$$\sum_i |y_i-f(x_i)|$$. LAD is sometimes used as a robust fitting
technique because it is less sensitive than least-squares to noise
in the data. LAD can only be used with the traditional EOS, i.e., it
cannot be used with FIT STRAIN X Y or with FIT POLYGIBBS.
~~~
FIX i1.i v1.r i2.i v2.r ...
~~~
The FIX keyword fixes some of the EOS parameters to user-defined
values. This keyword 
only applies to traditional EOS (i.e. those that are not accessed via
the FIT STRAIN keyword or POLYGIBBS). The constraints also apply to
fits to static data only. They are not honored in the calculation of
temperature-pressure data, i.e. when fitting free energy vs. volume
curves. The `i1.i` integer gives the parameter to be fixed. It can be
$$V_0$$ (2), $$B_0$$ (3), $$B_0'$$ (4), $$B_0''$$ (5), or $$B_0'''$$
(6). The value at which the corresponding parameter is fixed comes
after the integer identifier (`v1.r`). Multiple identifier/value pairs
can be given.
~~~
NELECTRONS nelec.i
~~~
The NELECTRONS keyword gives the total number of electrons per NAT
atoms. This value is used only if the AP2 EOS is used. Note this
variable is not associated with the NELEC option in PHASE.
~~~
SET MPAR mpar.i
~~~
In the case of a strain polynomial EOS (FIT STRAIN) using weighed
average polynomials (`order.i` = 0), MPAR sets the maximum degree of
the weighed polynomial fit to `mpar.i`. The default `mpar.i` is 12 or
half the E(V) points minus one, whichever is lowest. `mpar.i` is never
lower than 3.
~~~
SET MPARMIN mparmin.i
~~~
In the case of a strain polynomial EOS using weighed average
polynomials (`order.i` = 0), MPARMIN sets the minimum degree of the
weighed polynomial fit to mparmin.i. The default `mparmin.i` is 2.
~~~
SET NDEL ndel.i
~~~
Sets the number of external points to be removed from the dataset in
POLYGIBBS. POLYGIBBS should only be used for testing. The default
`ndel.i` is 3.
~~~
SET PFIT_MODE {GAUSS|SLATEC}
~~~
With the GAUSS keyword, use the method from the previous gibbs program
to conduct the linear least-squares fits (i.e. the strain polynomials
and POLYGIBBS). SLATEC: use dpolft and dpolcf from the SLATEC library
instead. GAUSS Is known to be unstable, so the default is SLATEC. This
keyword is useful only for testing purposes.
~~~
SET PWEIGH_MODE {GIBBS1|GIBBS2|SLATEC}
~~~
Use the previous gibbs version (GIBBS1) or the GIBBS2 method to
average the fit polynomials. Alternatively, let the SLATEC library do
it. This keyword is useful only for testing purposes. Default: GIBBS2.

