#!/bin/csh

# Evan Keane
# 18/09/2018
# Quick and dirty dumping of the UDP packets

if ( $#argv != 3 ) then
    echo "Usage: dump.csh <tobs_seconds> <psr_name> <nbits>"
        goto marbh
	endif

set tobs  = $argv[1] # in seconds
set psr   = $argv[2]
set nbits = $argv[3]

#set npackets = `echo $tobs | awk '{print int($1/(5.0e-9*2*512*16))}'`
set npackets = `echo $tobs | awk '{print int($1/(0.00008192))}'`
set date     = `date '+%Y-%m-%d-%H:%M:%S'`
echo $npackets

sudo tcpdump udp -vv -n port 4346 -c $npackets -i eno2 -p -w $psr"_"$nbits"bit_"
$npackets"_"$date
#echo "Déanta"
