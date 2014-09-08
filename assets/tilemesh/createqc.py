
import struct
import sys
import os

if not os.path.exists( "output" ):
	os.mkdir( "output" )

print "creating compile script..."


output = open("output/compile.qc", "w")

output.write( '$modelname "videogames/tilemesh.mdl"\n' )
output.write( '$model "base" "base.smd"\n' )
output.write( '$cdmaterials "videogames"\n' )

for i in range(0,17):
	output.write( '$attachment "slot%d" "slot%d" 0.00 0.00 0.00 rotate 0.00 0.00 0.00\n' % (i,i) )
	
for i in range(0,272):
	if( i == 0 ):
		output.write( '$sequence "idle" "000.smd" fadein 0.0 fadeout 0.0 snap  \n' )
	else:
		output.write( '$sequence "%03d" "%03d.smd" fadein 0.0 fadeout 0.0 snap \n' % (i,i) )

output.close();

