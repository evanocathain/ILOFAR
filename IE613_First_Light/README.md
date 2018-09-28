This is a small step-by-step how-to guide to see pulsars with IE613
data, as used for the first successful pulsar observations, in case
anybody else wants to give it a go. I have tried to add some comments
etc. in each component step along the way, so have a look at the
code/scripts there too if you want to see the details of what is
happening.

Step 1: Turn on the HBAs, form tied-array beamlets and start sending
UDP data stream of these data from (RSPs) telescope to acquisition
machine(s).

On the LCU run:
> swlevel 3
> rspctl --mode=5
> rspctl --stati         # Optional check that the bandpass looks alright, remember you should have ssh'd with -X or -Y
> rspctl --bitmode=8
> beamctl --antennaset=HBA_JOINED --rcus=0:95 --rcumode=5 --beamlets=0:121 --subbands=220:341 --anadir=2.588127,0.138345,J2000 --digdir=2.588127,0.138345,J2000&
> rspctl --stati=beamlet # Another optional check, this time of the beamlets that should have just been formed

Step 2: Record UDP beam-formed data to disk on acquisition machine. 

This is only one way of recording data, and indeed it is quite
hard-core/hacky, depending on how you look at it or depening on what
you are trying to do. But, it works, and within the context of various
not fully-understood-at-the-time network configurations it was the
only thing that worked for the first observations.

On acquisition machine, ucc1 in the case of IE613:
> nohup time csh dump.csh 120 B0809+74 8

This will dump a file called: B0950+08_8bit_1464843_$timestamp. The
original detection of PSR B0950+08 with IE613 is in file
B0950+08_8bit_1464843_2018-09-21-12:37:13. As it happens 1464843 is
the number of integer packets that is closest to what accounts for 120
seconds of data. The "8" is simply so the nbits gets stuck in the file
name.

Step 3: Process the data so that they are examinable by standard pulsar software

On acquisition machine, ucc1, or anywhere that you have this python script
> nohup time python read4.py -infile B0950+08_8bit_1464843_2018-09-21-12:37:13 -npackets 1464843 -nbeamlets 122 -nbits 122 -mode evan -o B0950+08_8bit_1464843_2018-09-21-123713

This parses the UDP and beamlet headers appropriately, forms Stokes I
(i.e. Xr*Xr + Xi*Xi + Yr*Yr + Yi*Yi) from the complex voltage data,
flips the frequency channels, and 'scrunches' in time by a factor of
16. This script is slow, and I've made zero attempt to make it fast, I
just wanted it to be right and I was time constrained from such
messing. But on ucc1 for example it uses 1 CPU (out of 64) regardless
of affinity settings. If anybody wants to sort that out I'd be
grateful :) The output of this is essentially a headerless sigproc
filterbank format file. A header can be generated as follows:

> mockHeader -tel 1916 -tsamp 0.00008192 -fch1 166.6015625 -fo -0.1953125 -nchans 122 headerfile_341

If you don't have that installed already try:
> git clone https://github.com/evanocathain/mockHeader
> cd mockHeader
> gcc mockHeader.c -o mockHeader -lm

Note that 166.6015625 = 100 + 100*341/512, noting that sub-band 341
was the highest frequency specified in the beamctl command. Also
0.1953125 = 100/512 and the minus sign is because this is high->low
frequency ordering. One you can simply attach this header to the
output file from read4.py to get a sigproc filterbank file.

> cat headerfile_341 B0950+08_8bit_1464843_2018-09-21-123713 > B0950+08_8bit_1464843_2018-09-21-123713.fil

Step 4: Search the data to look for a pulsar

This resultant filterbank file from Step 3 can now be processed by
sigproc, presto, dspsr, psrchive, ... which are massive and
well-tested software quites. You can do this on ucc1 or wherever you
have sigproc etc. installed.

> $sigproc/header B0950+08_8bit_1464843_2018-09-21-123713.fil

should display the header, and if it is the following version:
https://github.com/evanocathain/sigproc it should recognise I-LOFAR as
a telescope. If you want to grab that, it should work by doing this:

> git clone https://github.com/evanocathain/sigproc
> cd sigproc
> ./bootstrap
> ./configure
> make

But of course you may need to do some edits as per your local
conditions and have a look at the readme files there. Now that you
have sigproc you can do dedispersion and Fourier domain and single
pulse searching. However there is a better code to use for single
pulse detection, because of <reasons> which you can get easily as
follows:

> git clone https://github.com/evanocathain/destroy_gutted
> cd destroy_gutted
> make

All set, so now run the simple script to search the file

> nohup time csh search.csh B0950+08_8bit_1464843_2018-09-21-123713.fil

Step 5: Look at the search results

Now that you have a bunch of search output. For the FFT search you
have .prd files with the top periods, for each harmonic sum for each
DM. The .top file shows the top single candidate for each DM. For the
single pulse search there are .pls and .hst files from seek and
destroy. You can plot the output of the latter by running:

> gnuplot [-persist] sp.gp

That will give you a .ps file, or a plot to screen depending on what
line you've commented in/out at start of that gnuplot script.




