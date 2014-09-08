

import struct
import sys
import os

os.mkdir("output");

print "creating base model..."

output = open("output/base.smd", "w")

output.write( "version 1\n" );
output.write( "nodes\n" );

for i in range(0,17):
	output.write( str(i) + " \"slot" + str(i) + "\" -1\n" )

output.write( "end\n" );
output.write( "skeleton\n" );
output.write( "time 0\n" );

# node x y z ang ang ang (radians)

for i in range(0,17):
	output.write( str(i) + " " );
	vec = [i * 1.0,0.0,0.0]
	
	output.write( str(vec[0]) + " " + str(vec[1]) + " " + str(vec[2]) + " 0.0 0.0 -1.570796\n" );
	
output.write( "end\n" );
output.close()
