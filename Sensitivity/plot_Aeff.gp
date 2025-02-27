#
# Trying to figure out the mysterious answer to the question:
# What is the Aeff of a LOFAR station?
#
set term x11

set ylabel "Effective Area (m^2)"
set xlabel "Frequency (MHz)"

c_per_MHz     = 300.00 # So x can be freq in MHz

# HBA
set title "High Band Antennas"
N_per_tile    = 16.0
N_tiles       = 96.0

# van Haarlem et al. 2013
HBA_vH_sparse(x)=(c_per_MHz/x)**2/3.0
HBA_vH_dense(x)=1.25*1.25
plot [100:200][:2500](HBA_vH_dense(x) < HBA_vH_sparse(x) ? HBA_vH_dense(x) : HBA_vH_sparse(x))*N_per_tile*N_tiles title "van Haarlem et al. (2013)"

# Wijnholds & van Cappellen 2011
HBA_WvC_sparse(x)=x<=180 ? (c_per_MHz/x)**2/3.0: 0.0
HBA_WvC_dense(x)=x>=110 ? 1.25*1.25 : 0.0
Analog_BF_eff = 0.9 # actually only quoted at 240 MHz 
replot Analog_BF_eff*((x <= 180.0) ? HBA_WvC_dense(x) : 0 )*N_per_tile*N_tiles title "Wijnholds \\& van Cappellen"

## NEED LBA SPACINGS TO DO THIS PROPERLY
## EVERYTHING BELOW IS NOT FINISHED
## LBA
##set title "Low Band Antennas"
##N_dipoles     = 96.0

# van Haarlem et al. 2013
##LBA_vH_sparse(x)=(c_per_MHz/x)**2/3.0
##LBA_vH_dense(x)=1.25*1.25
###plot [100:200][:2500](HBA_vH_dense(x) < HBA_vH_sparse(x) ? HBA_vH_dense(x) : HBA_vH_sparse(x))*N_per_tile*N_tiles title "van Haarlem et al. (2013)"

# Wijnholds & van Cappellen 2011
##pi = 3.14159
# quote 7 dB at 65 MHz and 5.7 dB at 80 MHz
# I am crudely fitting a line between these
# Note that lambda^2 fall off from 65 would be worse by 80
# This isn't really representative of the LBA bandpass anyways but plotting 
# for completeness
##plot [20:100][0:](x<= 65.0 ? 10**(7.0/10.0) : 10**(7.0/10.0)+(10**(5.7/10.0)-10**(7.0/10.0))*(x-65.0))*((c_per_MHz/x)**2/(4.0*pi))*N_dipoles title "Wijnhols & van Cappellen"
