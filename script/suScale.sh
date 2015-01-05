#!/bin/bash
# Script name :

if [ $# -lt 3 ]
then
	echo ""
	echo "su scale"
	echo ""
	echo " $0 <input.su> <output.su> <scale>"
	echo ""
	exit 1
fi

fin=$1
fout=$2
scale=$3

headtmp=head.tmp
tmp=tmp.drt
tmpscale=tmp.drt.scaled

ns=` suwind count=1 < $fin | sugethw key=ns output=geom `
sustrip < $fin head=$headtmp > $tmp
farith op=scale scale=$scale < $tmp > $tmpscale
supaste ns=$ns head=$headtmp < $tmpscale > $fout
rm $headtmp $tmp $tmpscale
