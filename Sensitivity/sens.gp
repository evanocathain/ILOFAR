# Evan Keane
# Jan 2019
#
# This is a gnuplot script to plot theoretical LOFAR station SEFDs
#
# Run it like so: 
# > gnuplot sp.gp          # if terminal is postscript, this outputs a ps file
# > gnuplot -persist sp.gp # if terminal is x11, this keeps an X Window open

set term x11

# Physical constants
c       = 3.0e8
k       = 1380.0

#aeff(x) = 512.0*(c/(x*1.0e6))**2 < 2400.0 ? 512.0*(c/(x*1.0e6))**2 : 2400.0 # EU station
aeff(x) = 256.0*(c/(x*1.0e6))**2 < 1200.0 ? 256.0*(c/(x*1.0e6))**2 : 1200.0 # NL remote station
Tsky(x) = 60.0*(c/(x*1.0e6))**(2.55) # 10 < |gb| < 90 value
#Trec(x) = 0.1*Tsky(x) + 40 # SKA1-Low model
Trec(x) = 400.0 # NB this is just a simple assumption. But probably ok in the Galactic plane. Will make this more realistic in future update.
Tsys(x) = Tsky(x) + Trec(x)

set ylabel "SEFD (Jy)"
set xlabel "Frequency (MHz)
plot [120:180] 2.0*k*Tsys(x)/(0.5*aeff(x)) title "NL core", 2.0*k*Tsys(x)/aeff(x) title "NL remote", 2.0*k*Tsys(x)/(2.0*aeff(x)) title "EU"
#, 2.0*k*(3*Tsky(x)+Trec(x))/aeff(x) title "3C 295 Direction"
#, 2.0*k*(Trec(x))/aeff(x) title "No Trec contribution"



