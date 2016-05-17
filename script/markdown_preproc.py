# Markdown preprocessor 
# equation, table, figure numbering
#
# reference,cite: @kind:label
# parse time: @time(format)

import sys,re

text=sys.stdin.read()

def parse_crossref(text):
	"""
	Cross reference
	@kind:label -> numbers (sequential)
	"""
	count={}
	queue={}
	items=re.findall('(@(\w+):\w+)',text)
	for item in items:
		label,kind=item
		if not kind in count:
			count[kind]=0
			queue[kind]={}
		count[kind]+=1
		queue[kind][label]=count[kind]
		text=text.replace(label,str(queue[kind][label]))
	return text

def parse_time(text):
	"""
	Parse time using time.strftime
	@time(format string)
	"""
	import time
	items=re.findall('(@time\((.+?)\))',text)
	for item in items:
		label,fmt=item
		text=text.replace(label,time.strftime(fmt)[0:-1])
	return text

text=parse_crossref(text)
text=parse_time(text)

sys.stdout.write(text)
