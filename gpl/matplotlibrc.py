#!/usr/bin/python
#
# Program : change matplotlibrc parameters
# Date : 08 May 2009


## configuration for publication

# figure size
paper_width=3.32 # Geophysics: 3.32 in. / 4.32 in.
savefig_dpi=600
default_width=8
ratio=paper_width/default_width

# font size
paper_fontsize=6.
default_fontsize=12.
ratio_font=paper_fontsize/default_fontsize


############
import matplotlib

def PaperParams(Paper,ratio):
	"""multiply matplotlib.rcParams by ratio
	
	dict Paper={'object'=[attributes]}
	"""
	for object,attributes in Paper.iteritems():
		for attribute in attributes:
			mkey=object+'.'+attribute
			matplotlib.rcParams[mkey]=matplotlib.rcParams[mkey]*ratio

#matplotlib.rcParams['axes.formatter.limits']=[-4,5]
# figure size
matplotlib.rcParams['figure.figsize']=(8.0*ratio,6.0*ratio)
matplotlib.rcParams['figure.dpi']=matplotlib.rcParams['figure.dpi']/ratio
matplotlib.rcParams['savefig.dpi']=savefig_dpi

matplotlib.rcParams['figure.subplot.left']=0.17
matplotlib.rcParams['figure.subplot.right']=0.945
#matplotlib.rcParams['figure.subplot.bottom']=0.12
matplotlib.rcParams['figure.subplot.bottom']=0.14
matplotlib.rcParams['figure.subplot.top']=0.92
#matplotlib.rcParams['figure.subplot.wspace']=0.2
#matplotlib.rcParams['figure.subplot.hspace']=0.2

Paper=dict()
Paper['lines']=['linewidth','markeredgewidth','markersize']
Paper['patch']=['linewidth']
Paper['axes']=['linewidth']
Paper['xtick']=['major.size','minor.size','major.pad','minor.pad']
Paper['ytick']=['major.size','minor.size','major.pad','minor.pad']
Paper['grid']=['linewidth']
#Paper['legend']=['labelsep','handlelen','handletextsep','axespad']
#Paper['legend']=['borderaxespad','borderpad','columnspacing']
#Paper['legend']=['borderaxespad','borderpad','columnspacing','handlelen','handletextpad','handletextsep','labelsep','labelspacing']
#Paper['legend']=['columnspacing','handletextsep','labelsep']
Paper['legend']=['columnspacing']
# 'legend.axespad': 0.5,
# 'legend.borderaxespad': 0.5,
# 'legend.borderpad': 0.40000000000000002,
# 'legend.columnspacing': 2.0,
# 'legend.fancybox': False,
# 'legend.fontsize': 'large',
# 'legend.handlelen': 0.050000000000000003,
# 'legend.handlelength': 2.0,
# 'legend.handletextpad': 0.80000000000000004,
# 'legend.handletextsep': 0.02,
# 'legend.isaxes': True,
# 'legend.labelsep': 0.01,
# 'legend.labelspacing': 0.5,
# 'legend.loc': 'upper right',
# 'legend.markerscale': 1.0,
# 'legend.numpoints': 2,
# 'legend.pad': 0,
# 'legend.shadow': False,
matplotlib.rcParams['legend.fontsize']=6
matplotlib.rcParams['legend.handlelength']=3.0
matplotlib.rcParams['legend.borderpad']=0.7

PaperParams(Paper,ratio)


# font size
Paper=dict()
Paper['font']=['size']
#Paper['axes']=['titlesize','labelsize']
#Paper['xtick']=['labelsize']
#Paper['ytick']=['labelsize']
#Paper['legend']=['fontsize']
#matplotlib.rcParams["axes.titlesize"]='large'
#matplotlib.rcParams["axes.titlesize"]=50

PaperParams(Paper,ratio_font)

def savefig_paper(fout,dpi=600):
	import os.path
	eps=os.path.splitext(fout)[0]+'.eps'
	matplotlib.pyplot.savefig(eps,dpi=dpi)
	import commands
	cmd='convert -density %sx%s -compress LZW -depth 8 -units PixelsPerInch %s %s'%(dpi,dpi,eps,fout)
	commands.getstatusoutput(cmd)
