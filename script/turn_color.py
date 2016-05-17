#!/usr/bin/python
#
# Program : change terminal output color
# Date :
# Usage:
#   turn_color.py [color]
#
#   color: red, green, black(default)

import sys

try:
	key=sys.argv[1]
except:
	key='black'

colortable={'red':"\033[1;31m",'green':"\033[1;32m",'black':"\033[m"}

try:
	print colortable[key]
except:
	pass
