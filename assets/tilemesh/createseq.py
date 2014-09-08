

import struct
import sys
import os

if not os.path.exists( "output" ):
	os.mkdir( "output" )

print "creating sequences..."

for seq in range(0,272):
	
	with open("output/%03d.smd" % (seq), "w") as output:
		output.write( "version 1\n" )
		output.write( "nodes\n" )
		for i in range(0,17):
			output.write( str(i) + " \"slot" + str(i) + "\" -1\n" )
		
		output.write( "end\n" )
		output.write( "skeleton\n" )
		output.write( "time 0\n" )
		
		# node x y z ang ang ang (radians)
		for i in range(0,17):
			output.write( str(i) + " " );
			vec = [i * 1.0 - seq * 1.0/16.0,0.0,0.0]
			if vec[0] <= -1.0:
				vec[0] += 17.0
			output.write( str(vec[0]) + " " + str(vec[1]) + " " + str(vec[2]) + " 0.0 0.0 -1.570796\n" )
		
		output.write( "end\n" )

