<b>Lá Fhéile Portáin Sona Daoibh</b>

Hi Jane, Paul, 

I just did the following:

Searched the file you pointed me at with a quick hacky script that was
basically this:

#!/bin/csh

set file = ASPROVIDEDBYYOU
set dm   = 56.7628 # JB timing fit for March 2020
set sigproc = PATH TO SIGPROC BINARIES
set destroy = DESTROY BINARY

if ( -e pulses.) rm pulses.*
foreach dmval ( `seq 56.0 0.1 59.0` )

    echo "DM:" $dmval
    $sigproc/dedisperse $file".fil" -d $dmval > $file"."$dmval".tim"
    $destroy -spthresh 6.0 $file"."$dmval".tim"

end

That's it. I did not do any RFI zapping or anything. I plotted the
resulting file like so:

gnuplot>
set xlabel "Time (s)"
set ylabel "DM (pc/cc)"
plot [][56:59][8:]"pulses.pls" u ($3*0.00008192):1:($4*0.5) with points pt 7 pointsize variable notitle

That gives DM-t-SNR.png. The GP at ~8000 s is very obvious; there are
also a few more but I did not (yet) investigate those.

I cut out ~1 minute of the huge fil file centred on the 8000-s GP for
ease of working with a smalle file (hence the 29.65-second offset
below, i.e. about half-way in the now 1-minute file). I plotted the
output, now only at DM=57.6 pc/cc

gnuplot 
set xlabel "Time offset (ms)"
set ylabel "S/N (destroy)"
plot "< '{if ($1==57.6) print $0}' pulses.pls" u(1000*($3*0.00008192-29.65)):4:(log($2)/log(2)) palette notitle

That gives destroySNRfilters.png. You can see that the best (to
nearest power of 2) trial width is 256 time samples, which is ~21 ms.

One can make an ascii version of the dedispersed time series and
filterbank. 

$SIGPROC/decimate -t 256 file.tim > file.dec256.tim
$SIGPROC/decimate -t 256 -c 1 file.fil > file.dec256.fil

If you simply plot the first like this:

gnuplot
set xlabel "Time (s)"
set ylabel "Amplitude"
plot [29:32]"chop.ascii" wi li notitle

you get DM=57.6rawtimeseries.png

To look at the filterbank file I just opened it in Fiji and that is
DMsweepCrab.png



