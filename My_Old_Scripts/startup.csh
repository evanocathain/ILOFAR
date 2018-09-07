#!/bin/csh

# If no RCU mode given, print usage #
if ( $# != 1 ) then
    echo "Usage: startup.csh <rcu_mode>"
    exit
endif

set mode=$1
killall beamctl # kill all pointing commands that might be hanging around #
swlevel 0
swlevel 1
sleep 5
swlevel 2
set goOn = 0
while ( $goOn == 0 ) # check for errors before going to swlevel 3 #
    sleep 15
    set ErrCt = `grep -v INFO /log/RSPDriver.log | tail -15 | grep has\ not\ yet\ completed | wc -l`
    if ( $ErrCt == 0 ) then
	set goOn = 1
    endif
end
swlevel 3
sleep 30
if ( $mode == 6 ) then # if RCU mode 6, need the 160 MHz clock #
    rspctl --clock=160
    sleep 120
endif
poweruphba.sh $mode
#python ~/LOFAR_test/start_HBA_Ef2.py --rcumode=5 -v
rspctl --rcu # now lists the RCUs, which should all be ON #
