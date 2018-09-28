#/usr/bin/python

# Evan Keane
# Sep 2018
#
# This script reads in files of single station LOFAR beam-formed UDP
# data as acquired by Evan's dump.csh OR Olaf's dump_udp_ow_4, forms
# Stokes I, flips frequency to sigproc hi->lo ordering and time
# scrunches by a factor of nscans. Output is then essentially a
# header-less sigproc filterbank format file

# Import some useful packages
import argparse
import numpy as np
import sys
import struct

## Parse command line arguments & set default values
parser = argparse.ArgumentParser()
parser.add_argument('-infile', dest='infile', help='set the input file name', default='B0329+54')
parser.add_argument('-npackets', type=int, dest='npackets', help='How many UDP packets to read (def=1)', default=1)
parser.add_argument('-header', type=int, dest='udp_header', help='Size of UDP packet header in bytes (def=16)', default=16)
parser.add_argument('-nbits', type=int, dest='nbits', help='Bit mode for recorded samples (def=8)', default=8)
parser.add_argument('-nbeamlets', type=int, dest='nbeamlets', help='Number of beamlets (def=122)', default=122)
parser.add_argument('-nscans', type=int, dest='nscans', help='Number of time scans per packet (def=16)', default=16)
parser.add_argument('-o', dest='outfile', help='Set outfile name', default='outfile')
parser.add_argument('-mode', dest='acqmode', help='Acquisition mode ("evan" OR "olaf")', default='evan')
args      = parser.parse_args()
infile    = args.infile
outfile   = args.outfile
bitmode   = args.nbits/8 # could also have been 2 - grab from header
acqmode   = args.acqmode
if acqmode == "evan":
    extra_header = 82    # extra UDP header before beamlet data this many bytes
    if bitmode == 1:
        fmt = "<B"
        incomplete = 2   # Last two beamlets incomplete
    elif bitmode == 2:
        fmt = "<H"
        incomplete = 1   # Last beamlet incomplete
elif acqmode == "olaf":
    extra_header = 0
    if bitmode == 1:
        fmt = "<B"
    elif bitmode == 2:
        fmt = "<H"
    incomplete   = 0
npackets  = args.npackets
udp_header= args.udp_header
nbeamlets = args.nbeamlets # could also have been 61 - grab from header
nscans    = args.nscans
# See formats here https://docs.python.org/3/library/struct.html

# Stokes I array for one packet
I=np.zeros((nbeamlets*nscans),dtype=np.float32)
Iave=np.zeros(nbeamlets, dtype=np.float32)

# Open up files
f = file(infile, 'rb')
g = file(outfile, "wb")

i=0
j=0

# Read UDP packets
for packets in range(0,npackets):
    # Starting reading the next UDP packet
    f.seek(extra_header,1) # skip the UDP header
    header = f.read(udp_header) # read the beamlet data header
    # TO DO: grab the info in the headers and act accordingly! In first instance just skip it
    if (ord(header[1])==128): # Read only RSP0 data, 128==RSP0, 129==RSP1, 130==RSP2, ...
        i = i + 1
        for beamlets in range(0,nbeamlets-incomplete):
            for scans in range(0,nscans):
                Xr=f.read(bitmode) # X-pol, real
                Xi=f.read(bitmode) # X-pol, imaginary
                Yr=f.read(bitmode) # Y-pol, real
                Yi=f.read(bitmode) # Y-pol, imaginary
                # Do a simple 16x time scrunch
                Iave[nbeamlets-incomplete-beamlets] = Iave[nbeamlets-incomplete-beamlets] + (struct.unpack(fmt,Xr)[0])*(struct.unpack(fmt,Xr)[0]) + (struct.unpack(fmt,Xi)[0])*(struct.unpack(fmt,Xi)[0]) + (struct.unpack(fmt,Yr)[0])*(struct.unpack(fmt,Yr)[0]) + (struct.unpack(fmt,Yi)[0])*(struct.unpack(fmt,Yi)[0])

        if (acqmode == "evan"):
            f.seek(104,1) # Last beamlet is screwed up for I-LOFAR data, consisting only of 104 bytes
            Iave[0]=0.0   # Last beamlet is screwed up for I-LOFAR data, consisting only of 104 bytes
            Iave[1]=0.0
            
        scans = 0     # re-set the scan number, ahead of moving to next beamlet       
        g.write(Iave) # all beamlets read for this packet, so write out
    elif (ord(header[1])==129 or ord(header[1])==130 or ord(header[1])==131): # if RSP1, RSP2, ... just skip the beamlet data
#        print packets, ord(header[1]), f.tell(), f.tell()/7882
        j = j + 1
#        print ord(header[1]), i, j, packets, f.tell()
        f.seek((nbeamlets-incomplete)*bitmode*4*nscans+104,1)
    else:
        # Packet is screwed up. Try to recover
        print "uh oh", i, j, packets, f.tell()
        f.seek(-82-udp_header, 1) # Go back to start of this UDP packet
        x = f.read(7882)          # Read in a whole packet's worth. 
        indexes1 = [i for i,y in enumerate([ord(c) for c in x]) if y==3]
        indexes2 = [i for i,y in enumerate([ord(c) for c in x]) if (y==128 or y==129 or y==130 or y==131)]
        print indexes1, len(indexes1)
        print indexes2, len(indexes2)
        offset = -12345
        for k in range(0,len(indexes1)):
            for l in range(0,len(indexes2)):
                if indexes2[l]==indexes1[k]+1:
                    offset=indexes1[k]
                    break
        if (offset == -12345):
            print "Can't figure out where I am in the stream!"
            sys.exit()
        f.seek(-7882+offset-82,1) # Get back on track, at start of next packet
#        f.seek(-7882+offset-82-udp_header,1) # Get back on track, at start of next packet
#        f.seek(offset-82-udp_header,1) # Get back on track, at start of next packet
        print offset, [ord(c) for c in x][offset],f.tell()
        
#    print f.tell()
    Iave.fill(0.0)          # re-set the Stokes I array, ahead of moving to next packet
#    beamlets = 0            # re-set the beamlet number, ahead of moving to next packet

print i, j, packets, f.tell()
print "Finished"
