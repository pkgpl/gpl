#!/bin/sh
# touch files in recursive directories
#
if [ $# -lt 1 ]
then
	echo ""
	echo "	Gpl Recursive Touch : touch files in a directory and its subdirectories recursively"
	echo ""
	echo "	Usage :"
	echo "		gplrtouch.sh [directory]"
	echo ""
	echo "	Required parameter :"
	echo "			directory name"
	echo ""
	exit 1
fi

echo "touching $1"
find $1 -print0 | xargs -r0 touch
echo "files in $1 touched!"
