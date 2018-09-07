#!/bin/csh

if ( $#argv != 1 ) then 
    echo "Usage: scheduler.csh fil.sch"
    exit
endif

set schedule = $1
set psr = `awk '{print $1}' $schedule`
set tstart = `awk '{print $2}' $schedule`
set tobs = `awk '{print $3}' $schedule`

echo "SOME KIND OF RUBBISH SCHEDULER"
echo ""

    echo "PATH="$PATH > de601.sched.cron 


foreach i (`seq 1 $#psr`)
    
    echo "Adding "$psr[$i] "to schedule"
    echo "Start time:" $tstart[$i]
    echo "Observation length:" $tobs[$i]
    echo ""
    set min = `echo $tstart[$i] | sed s/\\:/" "/g | awk '{print $2}'`
    set hour = `echo $tstart[$i] | sed s/\\:/" "/g | awk '{print $1}'`
    set day = `date +%d`
    set month = `date +%m`
    echo $min $hour $day $month "*" ~user9/PSR_Scripts/beamctl_etc_script.csh $psr[$i] $tobs[$i]
    echo $min $hour $day $month "*" ~user9/PSR_Scripts/beamctl_etc_script.csh $psr[$i] $tobs[$i] >> de601.sched.cron

    echo "That was great for me. Was it good for you?"
    echo ""

end

    crontab de601.sched.cron

exit
