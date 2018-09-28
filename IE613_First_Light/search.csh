#!/bin/csh

# Evan Keane
# Sep 2018
#
# This is a simple search script to dedisperse an input filterbank
# file, and then run an FFT search at each DM trial using seek, and
# also run a single pulse search at each DM trial using seek and
# destroy. 

set filfile = $1
set stem    = `stem $filfile`

rm pulses.pls 
rm pulses.hst
rm $stem".pls"
rm $stem".hst"

# Old-timey POSIX version needed for old seek sort call to be recognised
setenv 

# DM Loop
foreach dm (`seq 0 0.1 20`)

    $sigproc/dedisperse $filfile -d $dm -i badchans > $stem".tim"
    $sigproc/seek $stem".tim" -pulse -A
    ~/GIT/destroy_gutted/destroy $stem".tim"

end

marbh:
exit
