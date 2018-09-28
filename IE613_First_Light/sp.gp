# Evan Keane
# Sep 2018
#
# This is a gnuplot script to plot the output from destroy.
# This was used for analysis of the IE613 First Light pulsar observations.
# Run it like so: 
# > gnuplot sp.gp          # if terminal is postscript, this outputs a ps file
# > gnuplot -persist sp.gp # if terminal is x11, this keeps an X Window open

#set term x11
set terminal postscript enhanced color solid 
set output "ILOFAR_FirstLight.ps"

# Set some labels
set title "I-LOFAR (IE613) Pulsar First Light Observation of PSR B0950+08" font ", 20"
set ylabel "Dispersion Measure (cm^{-3} pc)" font ", 20"
set xlabel "Time (seconds)" font ", 20"
set y2label "Distance (parsecs)" font ", 20"

# Set some plot ranges
dmmax = 15 # in pc/cc units
set y2range[0:dmmax*(260/2.92)]

# Set some axes specs.
set ytic in nomirror
set y2tic in nomirror
set mytics 5
set mxtics 5

# Anois, plot
plot [0:31][0:dmmax]"pulses.pls" u ($3*0.00008192):1:(($4-4)*0.2) with points lt 2 pointsize variable pt 6 notitle
