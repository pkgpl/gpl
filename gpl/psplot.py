import os

def extname(path):
	return os.path.splitext(path)[1]

class PlotUtil:
	@staticmethod
	def run(cmd):
		print(cmd)
		os.system(cmd)
	@staticmethod
	def silent_run(cmd):
		os.system(cmd)
	@staticmethod
	def add_unit(eps,replace=False):
		msg="\n// adding velocity unit (km/s)"
		if replace:
			msg=msg.replace('km/s',replace)
		print(msg)
		unittext= \
"""%%%%% plusha - changed position of unit
GS
290 190 TR
NP
/Helvetica findfont 8 scalefont setfont
0 0 0 setrgbcolor
21.96 -6.462 M
(km/s) SW exch -0.5 mul
exch -0.5 mul RM (km/s) SH
S
GR
%%%%%
"""
		if replace:
			unittext=unittext.replace('km/s',replace)
		tmp='_tmp_'+eps
		fout=open(tmp,'w')
		fin=open(eps,'r')
		for line in fin:
			if line=="showpage\n":
				fout.write(unittext)
			fout.write(line)
		fin.close()
		fout.close()
		PlotUtil.silent_run('mv %s %s'%(tmp,eps))
	@staticmethod
	def fix_bbox(eps,lp=2,rp=2,tp=2,bp=3):
		print("\n// fixing bounding box")
		cmd="gs -sDEVICE=bbox -dNOPAUSE -dBATCH %s"%eps
		pattern='%%BoundingBox:\s(\-*\d+)\s(\-*\d+)\s(\-*\d+)\s(\-*\d+)'
		import subprocess,re
		result=subprocess.getstatusoutput(cmd)[1]
		for line in result.split('\n'):
			m=re.match(pattern,line)
			if m:
				llx,lly,urx,ury = int(m.group(1)),int(m.group(2)),int(m.group(3)),int(m.group(4))
		tmp='_btmp_'+eps
		PlotUtil.silent_run('psbbox llx=%s lly=%s urx=%s ury=%s < %s > %s'%(llx-lp,lly-bp,urx+rp,ury+tp,eps,tmp))
		PlotUtil.silent_run('mv %s %s'%(tmp,eps))
	@staticmethod
	def eps2tif(fin,fout):
		print("\n// converting EPS to TIFF ..")
		PlotUtil.silent_run("convert -density 600x600 -compress LZW -depth 8 -units PixelsPerInch %s %s"%(fin,fout))
	@staticmethod
	def convert(eps,fout):
		print("\n// converting %s to %s .."%(extname(eps),extname(fout)))
		PlotUtil.silent_run('convert -density 600x600 -depth 8 -units PixelsPerInch %s %s'%(eps,fout))

class Psplot:
	"(su)psimage: velocity, velocity_color, gradient, gradient_color, migration, seismogram, spectrum, contour"

	def __init__(self):
		self.replunit=False

	def psimage(self,target,source,option,plottype,replunit=''):
		self.replunit=replunit
		eps=os.path.splitext(os.path.basename(target))[0]+'.eps'
		# default
		opt={'labelsize':8,'label1':'Depth (km)','label2':'Distance (km)','d1s':0.5,'d2s':0.5,'height':1.0,'width':2.65}
		opt_legend={'legend':1,'lstyle':'vertright','lwidth':0.1,'lheight':1.0}
		opt_color={'bhls':'0.67,0.5,1','ghls':'0.33,0.5,1','whls':'0,0.5,1','bps':24}
		exe='psimage'
		unit=False
		# contour plot
		if plottype=='contour':
			exe='pscontour'
			opt.update({'hbox':1.0,'wbox':2.65})
		# binary or su file
		srcext=extname(source)
		if srcext=='.su' or srcext=='.SU':
			exe='su'+exe
		# color
		if plottype.endswith('color'):
			opt.update(opt_color)
		# plottype
		if plottype.startswith('velocity'):
			unit=True
			opt.update(opt_legend)
		elif plottype.startswith('gradient'):
			opt['perc']=99
		elif plottype.startswith('migration'):
			opt['perc']=97
		elif plottype.startswith('seismogram'):
			opt['perc']=98
			opt['height']=3.0
			opt['label1']='Time (s)'
			opt['d1s']=2
			opt['d2s']=2
		elif plottype.startswith('spectrum'):
			opt['perc']=99
			opt['height']=3.0
			opt['label1']='Frequency (Hz)'
			opt['d2s']=2
			opt['d2s']=2
		# options
		optstr=''
		for k,v in opt.items():
			if type(v)==str:
				optstr+='%s="%s" '%(k,v)
			else:
				optstr+='%s=%s '%(k,v)
		cmd="%s %s %s < %s > %s"%(exe,optstr,option,source,eps)
		PlotUtil.run(cmd)
		if unit: PlotUtil.add_unit(eps,replace=self.replunit)
		PlotUtil.fix_bbox(eps)
		if not target.endswith('.eps'):
			if target.endswith('.tif') or target.endswith('.tiff'):
				PlotUtil.eps2tif(eps,target)
			else:
				PlotUtil.convert(eps,target)

def add_method(cls,methodname):
	def temp(self,target,source,option,unit=''):
		return self.psimage(target,source,option,methodname,unit)
	temp.__name__=methodname
	setattr(cls,temp.__name__,temp)

for name in ['velocity','velocity_color','gradient','gradient_color','migration','seismogram','spectrum','contour']:
	add_method(Psplot,name)

plot=Psplot()

import subprocess

class Cmdplot:
	@staticmethod
	def run(cmd):
		print(cmd)
		subprocess.call(cmd,shell=True)

	@staticmethod
	def rsf3d(fout,fin,opt):
		cmd="plot3d %s %s out=%s"%(fin,opt,fout)
		Cmdplot.run(cmd)
		return fout

	@staticmethod
	def error_cat(fout,fin):
		ftmp="tmp_error.txt"
		cmd="cat %s > %s ; plot_error -i %s -o %s"%(fin,ftmp,ftmp,fout)
		Cmdplot.run(cmd)
		return fout

	@staticmethod
	def error(fout,fin):
		cmd="plot_error -i %s -o %s"%(fin,fout)
		Cmdplot.run(cmd)
		return fout

cplot=Cmdplot()

