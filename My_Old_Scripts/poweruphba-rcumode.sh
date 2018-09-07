#!/bin/bash
#
# V1.0, M.J.Norden, 13-04-2011
# usage: ./poweruphba.sh 5  (or 6 or 7)
# Power up of the HBA Tiles needs to be slowed down because of high rush-in current. 

if [ "$1" != "" ]; then
    if   [ $1 -lt 5 ]; then
       echo -e "Usage: ./poweruphba.sh 5 (or 6 or 7)\n"
       exit  
    elif [ $1 -gt 7 ]; then
       echo -e "Usage: ./poweruphba.sh 5 (or 6 or 7)\n"
       exit
    else
       hbamode=$1
    fi
else 
   echo -e "Usage: ./poweruphba.sh 5 (or 6 or 7)\n"
   exit
fi

if [ -e /opt/lofar/etc/RemoteStation.conf ]; then
  let rspboards=`sed -n  's/^\s*RS\.N_RSPBOARDS\s*=\s*\([0-9][0-9]*\).*$/\1/p' /opt/lofar/etc/RemoteStation.conf`
  let rcus=$rspboards*8
else
  echo "Could not find /opt/lofar/etc/RemoteStation.conf"
  let rspboards=12
  let rcus=$rspboards*8
fi

rspctl --rcumode=$hbamode --sel=0:31
sleep 2
rspctl --rcumode=$hbamode --sel=32:63
sleep 2
rspctl --rcumode=$hbamode --sel=64:95
sleep 2

if [ $rcus -eq 192 ]; then
  rspctl --rcumode=$hbamode --sel=96:127
  sleep 2
  rspctl --rcumode=$hbamode --sel=128:159
  sleep 2
  rspctl --rcumode=$hbamode --sel=160:191
  sleep 2
fi

rspctl --rcuenable=1
sleep 2
if [ $hbamode -eq 5 ]; then 
   rspctl --specinv=1
fi
