#!/bin/bash

### ARGS
# $1 - title
# $2 - a crystal structure file
# $3 - an expt PXRD as .xy
# $4 - a
# $5 - b
# $6 - c
# $7 - alpha
# $8 - beta
# $9 - gamma

title=$1
xtal=$2
pxrd=$3
a=$4
b=$5
c=$6
alpha=$7
beta=$8
gamma=$9

# basic processing of the PXRD pattern
minI=$(sort -n -k2 $pxrd | head -n 1 | awk '{print$2}')
maxI=$(sort -nr -k2 $pxrd | head -n 1 | awk '{print$2}')
pxrd_bc=${pxrd%.xy}-bc.xy
awk -v min="$minI" -v max="$maxI" '{print $1, (($2-min)/((max-min)/100))}' $pxrd > $pxrd_bc

# run VC-xPWDF
cat > ${xtal%.*}_vc.cri << EOF
trick compare $xtal $pxrd_bc $a $b $c $alpha $beta $gamma WRITE
crystal ${xtal%.*}_vc_structure_2.res
powder
symm recalc
write ${xtal%.*}_vc.cif
EOF
critic2 ${xtal%.*}_vc.cri > ${xtal%.*}_vc.cro
vcpwdf=$(grep FINAL ${xtal%.*}_vc.cro | awk '{printf "%.4f", $5}')
xtal_vc=${xtal%.*}_vc_xrd.dat
xtal_label=$(echo ${xtal%.*} | sed 's/_/-/g')
rm ${xtal%.*}_vc_structure_2.res
#mv ${xtal%.*}_vc_structure_2.res ${xtal%.*}_vc.res

### write gnuplot instruction file
cat > overlay.gnu << EOF
set term post enhanced color solid "Helvetica" 18
set encoding iso_8859_1
set output 'overlay-${title}-${2%%.*}VC-${3%%.*}.ps'
set size ratio 0.6

set style line 1  pt 7  lc rgb "#222222" lw 0.3 ps 0.3 lt 0.3 #black
set style line 9  pt 4  lc rgb "#BE0032" lw 2 ps 2 lt 1 #red

set title '$title (VC-xPWDF = $vcpwdf)'
set xlabel "2{/Symbol q} (degrees)"
set ylabel "Intensity (arb. units)"
set xrange [5.0000000:50.0000000]
plot "$xtal_vc" u 1:2 w lines ls 9 t "${xtal_label}-VC",\
     "$pxrd_bc" u 1:2 w points ls 1 t "expt PXRD",

!ps2pdf overlay-${title}-${2%%.*}VC-${3%%.*}.ps
!pdfcrop overlay-${title}-${2%%.*}VC-${3%%.*}.pdf
!mv overlay-${title}-${2%%.*}VC-${3%%.*}-crop.pdf overlay-${title}-${2%%.*}VC-${3%%.*}.pdf
EOF

gnuplot overlay.gnu