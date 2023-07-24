#!/opt/homebrew/opt/python@3.10/bin/python3.10

import sys 
from datetime import *
import ephem

if len(sys.argv)<2:
    print("Usage: lst/mjd [site]")
    print(' ')
    print("This program returns the current location, LST, UT and MJD for a given site")
    print("e.g. lst jbo produces")
    print("Site = Jodrell Bank")
    print("Long,Lat = -2:18:25.7 53:14:13.2")
    print("LST = 17:51:18.81")
    print("UT = 2011/11/10 14:42:53")
    print("UT (MJD) = 55875.6131134")
    sys.exit(0)

place=sys.argv[1]

site=ephem.Observer()

# NB. I got all coordinates from wikipedia. Sorry if they are incorrect!
if (place=="jbo" or place=="jodrell"):
    site.long = '-2.30715'
    site.lat = '53.23700'
    site.elevation = 0
    place = "Jodrell Bank"
elif (place=="birr" or place=="Birr" or place=="I-LOFAR" or place=="ilofar"):
    site.long = '-7.9133'
    site.lat = '53.0914'
    site.elevation = 0
    place = "Birr"
elif (place=="eff" or place=="effelsberg"):
    site.long = '6:52:58'
    site.lat = '50:31:29'
    site.elevation = 0
    place = "Effelsberg"
elif (place=="srt" or place=="sardinia"):
    site.long = '9:14:43'
    site.lat = '39:29:35'
    site.elevation = 0
    place = "Sardinia Radio Telescope"
elif (place=="wsrt" or place=="westerbork"):
    site.long = '6:36:12'
    site.lat = '52:54:53'
    site.elevation = 0
    place = "Westerbork Synthesis Radio Telescope"
elif (place=="nancay"):
    site.long = '2:12'
    site.lat = '47:23'
    site.elevation = 0
    place = "Nancay Radio Telescope"
elif (place=="gbt"):
    site.long = '-79:50:23'
    site.lat = '38:25:59'
    site.elevation = 0
    place = "Green Bank Telescope"
elif (place=="pks" or place=="parkes"):
    site.long = '148:15:44.3'
    site.lat = '-32:59:59.8'
    site.elevation = 0
    place = "Parkes Observatory"
elif (place=="arecibo"):
    site.long = '-66:45:10'
    site.lat = '18:20:39'
    site.elevation = 0
    place = "Arecibo"
elif (place=="vla"):
    site.long = '-107.61835'
    site.lat = '34.078967'
    site.elevation = 0
    place = "Very Large Array"
elif (place=="gmrt"):
    site.long = '74:02:59.07'
    site.lat = '19:05:47.46'
    site.elevation = 0
    place = "The Giant Metrewave Radio Telescope"
elif (place=="lofar"):
    site.long = '6:52:08.18'
    site.lat = '52:54:31.55'
    site.elevation = 0
    place = "LOFAR Superterp"
else: 
    print("Which telescope?! Try again!")
    sys.exit(0)

site.date=datetime.utcnow()
print("Site =",place)
print("Long,Lat =",site.long,site.lat)
print("LST =",site.sidereal_time())
print("UT =",site.date)
print("UT (MJD) =",site.date+15019.5)
## NB pyephem records Dublin Julian Day Number not MJD
## see Table in en.wikipedia.org/wiki/Julian_day for more info


sys.exit(0)

