#!/bin/bash
# tobelight@gmail.com
# Script name : column_extractor
# bash and awk, 11OCT2008

if [ $# == 0 ]
then
	echo ""
	echo "COLumn EXTractor"
	echo "Usage:"
	echo "	$0 [options] [col numbers] < file"
	echo ""
	echo "Options:"
	echo "	fs=\" \"    : input field separator"
	echo "	rs=\"\n\"   : input record separator"
	echo "	ofs=\" \"   : output field separator"
	echo "	ors=\"\n\"  : output record separator"
	echo ""
	echo "Example:"
cat <<EOF
	$ cat testcol.dat 
	col1 	col2   col3 col4 col5
	1 	2   3 4 5
	11 	12   13 14 15
	21 	22   23 24 25
	
	$ $0 ors=";\n" 3 2 5 <testcol.dat 
	col3 col2 col5;
	3 2 5;
	13 12 15;
	23 22 25;
EOF
	echo ""
	exit 1
fi

## make column number option
opt=""

## awk options
fs=" "
rs="\n"
ofs=" "
ors="\n"

for i in $@
do
	case ${i%=*} in
		fs)
			fs=${i#*=}
			;;
		rs)
			rs=${i#*=}
			;;
		ofs)
			ofs=${i#*=}
			;;
		ors)
			ors=${i#*=}
			;;
		*)
			opt=$opt"\$$i,"
			;;
	esac
done

awk "BEGIN{FS=\"$fs\";RS=\"$rs\";OFS=\"$ofs\";ORS=\"$ors\"} {print ${opt%,}}" $stdin
