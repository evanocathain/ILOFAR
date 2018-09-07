#!/bin/csh

set psr = $1
set tobs = $2

observe.csh psr $psr
sleep $tobs
killall beamctl
poweruphba.sh 5

exit
