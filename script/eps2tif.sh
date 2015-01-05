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
	tif=${eps/.eps/.tif}
	tmp=tmp$eps
	#echo $tmp $tif

	fixbbox $eps $tmp
	convert -density 600x600 -compress LZW -depth 8 -units PixelsPerInch $tmp $tif
	rm $tmp
	echo "output file = $tif"
done
