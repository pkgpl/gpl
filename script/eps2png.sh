#!/bin/bash
# Script name :

if [ $# -lt 1 ]
then
	echo 'input eps file name(s)'
	exit 1
fi

for eps in $*
do
	#eps=$1
	png=${eps/.eps/.png}
	tmp=tmp$eps

	fixbbox $eps $tmp
	convert -density 200x200 -depth 8 -units PixelsPerInch $tmp $png
	rm $tmp
	echo "output file = $png"
done
