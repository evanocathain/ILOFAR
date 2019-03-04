#!/bin/csh

#Write wrapper script for pcap to fil conversion

#chop up pcap file into ncores_avail chunks
#make sure they are integer number of packets

#for i in ncores_avail
# bf2fil.py file_part$i

#stitch back all the bits together

#stick on fil header

#process

if ($#argv != 4) then
    echo "Usage: csh bf2fil.csh [pcap_filename] [npackets] [mode] [ram_factor]"
    goto marbh
endif

set file       = $argv[1]
set npackets   = $argv[2]
set mode       = $argv[3] # evan or olaf
set ram_factor = $argv[4] # Set some kind of arbitrary nice-ness factor

# How many processors do we have?
set host = `uname`
echo $host
if ($host == "Darwin") then       # We're on a Mac
    set nprocessors = `sysctl -n hw.physicalcpu`
else if ($host == "Linux") then   # We're on a Linux
    set nprocessors = `nproc`
endif

echo "You have" $nprocessors "processors available"
set ncores_avail = `echo $nprocessors | awk -v ram_factor=$ram_factor '{print int($1*ram_factor)}'`
echo "Using" $ncores_avail "of these"

# Figure out the headersizes of the packets
if ($mode == "evan" ) then
    set headersize  = 98   # bytes
    set packet_size = 7882 # (120*4*1*16+98+104) bytes
else if ($mode == "olaf") then
    set headersize  = 16   # bytes
    set packet_size = 7824 # (122*4*1*16+16)
else
    echo "Don't recognise recording mode. Slán."
    goto marbh
endif
echo "Data recorded in" $mode "mode"

set packets_per_chunk = `echo $ncores_avail $npackets | awk '{print int($2/$1)}'`
set chunksize = `echo $packets_per_chunk $packet_size | awk '{print $1*$2}'`
echo $chunksize

goto skip
# Chop up the file
foreach chunk (`seq 1 $ncores_avail`)
    set hd = `echo $chunk $chunksize | awk '{print $1*$2}'`
    echo "Chunk" $chunk
    schedtool -a $chunk -e head -c $hd $file | tail -c $chunksize > "chunk"$chunk &
#    head -c $hd $file | tail -c $chunksize > "chunk"$chunk
    echo "Done"
end
wait # wait for the chunking up of the data to be complete before 

skip:
# Run bf2fil.py on each chunk, using a different processor for each
foreach chunk (`seq 1 $ncores_avail`)
    echo "Running bf2fil.py on chunk" $chunk
    schedtool -a $chunk -e python bf2fil.py -infile "chunk"$chunk -npackets $packets_per_chunk -nbeamlets 122 -nbits 8 -mode evan -o "chunk"$chunk".tmp" &
end
wait # wait for all the bf2fil.py calls to finish before progressing

skip:
rm full.tmp
echo "Re-stitching the chunks"
foreach chunk (`seq 1 $ncores_avail`)
    cat "chunk"$chunk".tmp" >> full.tmp
end
echo "Sticking on a SIGPROC header"
/home/obs/Evan/mockHeader/mockHeader -tel 1916 -tsamp 0.00008192 -fch1 166.6015625 -fo -0.1953125 -nchans 122 -nbits 32 headerfile_341
cat headerfile_341 full.tmp > "file.fil"
    
marbh:
exit
					
