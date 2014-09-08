#gensmd.py
#
# generates an SMD file that contains a single flat textured surface
#

#----------------------------------------------------------------------------------------
import sys, getopt

#----------------------------------------------------------------------------------------
usage = 'gensmd.py -w <width> -h <height> -t <texture file no extension> -o <output smd file>'



#----------------------------------------------------------------------------------------
def main(argv):
	width = ''
	height = ''
	texture = ''
	outputfile = ''
	try:
		opts, args = getopt.getopt(argv,"hw:h:t:o:",["help","width=","height=","texture=","output="])
	except getopt.GetoptError:
		print "error!"
		print usage
		sys.exit(2)
	for opt, arg in opts:
		if opt in ("-h","--help"):
			print usage
			sys.exit()
		elif opt in ("-w", "--width"):
			width = arg
		elif opt in ("-h", "--height"):
			height = arg
		elif opt in ("-t", "--texture"):
			texture = arg
		elif opt in ("-o", "--output"):
			outputfile = arg
		
	# quit if an argument is missing
	if width == '' or height == '' or texture == '' or outputfile == '':
		print 'bad arguments ' + width + ' ' + height + ' ' + texture + ' ' + outputfile
		sys.exit(2)
		
	# poop out stuff
	print 'writing ' + outputfile + '...'
	output = open(outputfile,"w")
	
	output.write( 'version 1\n' )
	output.write( 'nodes\n' )
	output.write( '0 "root" -1\n' )
	output.write( 'end\n' )
	output.write( 'skeleton\n' )
	output.write( 'time 0\n' )
	output.write( '0 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000\n' )
	output.write( 'end\n' )
	output.write( 'triangles\n' )
	output.write( texture + '\n' )
	output.write( '0 0.000000 -0.000000 0.000000 0.000000 -1.000000 0.000000 0.000000 1.000000\n' )
	output.write( '0 0.000000 -0.000000 -' + height + '.000000 0.000000 -1.000000 0.000000 0.000000 0.000000\n' )
	output.write( '0 '+width+'.000000 -0.000000 -' + height + '.000000 0.000000 -1.000000 0.000000 1.000000 0.000000\n' )
	output.write( texture + '\n' )
	output.write( '0 '+width+'.000000 -0.000000 -' + height + '.000000 0.000000 -1.000000 0.000000 1.000000 0.000000\n' )
	output.write( '0 '+width+'.000000 -0.000000 0.000000 0.000000 -1.000000 0.000000 1.000000 1.000000\n' )
	output.write( '0 0.000000 -0.000000 0.000000 0.000000 -1.000000 0.000000 0.000000 1.000000\n' )
	output.write( 'end\n' )
	output.close()
	
	print 'done.'

#----------------------------------------------------------------------------------------
if __name__ == "__main__":
	main(sys.argv[1:])
	
	