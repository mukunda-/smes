
import sys

if( len(sys.argv) < 2 ):
	print 'Usage: gencart.py <gameid>'
	sys.exit(0)

game = sys.argv[1];

def copy_template( srcpath, destpath, id ):
	with open( destpath, "wt" ) as fout:
		with open( srcpath, "rt" ) as fin:
			for line in fin:
				fout.write( line.replace('{{REPLACE}}', id) )
	print 'Created ' + destpath

copy_template( "template.smd", "cart_" + game + ".smd", game )
copy_template( "template.qc", "cart_" + game + ".qc", game );

