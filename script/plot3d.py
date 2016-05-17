#!/usr/bin/python

import sys
def help():
	print """
Gpl 3D plot

main:	n1 * n3
right:	n1 * n2
top:	n2 * n3
axes 1,2,3 = z,y,x

%s HeaderFile [options]
	Options
		n1=, n2=, n3=
		o1=, o2=, o3=
		d1=, d2=, d3=
		label1=, label2=, label3=
		in=,

		out='fig3d.eps', 	# output figure

		wclip=, bclip=	# clip

		colorbar=True	# add colorbar
		cblabel="Velocity (m/s)",	# colorbar label
		lbeg=, lend=, ldnum	# colorbar legend
		cmap=[cm.jet,cm.jet_r,cm.gray,cm.gray_r,cm.spectral,cm.hsv] # colormap

		px=, py=, pz=	# line pick
		lcolor=['b','g','r','c','m','y','k','w'] # line color
		lwidth=1	# line width
	
		height=0.25, width=0.4,	# main box

	Useful keys
		q: quit
		z: change box size to reflect real scale
		r: redraw with default box sizes
		h: change color map
		c: change line color
		i,j,k,l: change box size
	"""%sys.argv[0]
	sys.exit(1)

if len(sys.argv)==1:
	help()

import re
from numpy import *
from pylab import *
import matplotlib

class MetaData:
	infile='vp.bin'
	outfile='fig3d.eps'
	n1=0 ; n2=0 ; n3=0
	o1=0 ; o2=0 ; o3=0
	d1=1 ; d2=1 ; d3=1
	esize=4
	label1='z'
	label2='y'
	label3='x'
	unit1=''
	unit2=''
	unit3=''
	data_format='not_set'
	wclip=0; bclip=0
	lbeg=0 ; lend=0 ; ldnum=0
	height=0 ; width=0
	px=0 ; py=0 ; pz=0 # center line pick
	colorbar=True
	cblabel="Velocity (m/s)"
	cmap=''
	cbticks=[]
	lcolor=0
	lwidth=1

	def xmax(self):
		return o3+(n3-1)*d3
	def ymax(self):
		return o2+(n2-1)*d2
	def zmax(self):
		return o1+(n1-1)*d1

class Parser:
	def __init__(self):
		self.meta=MetaData

	def parse_sep(self,command):
		text=re.sub(r'in=(.+)$',r'infile="\1"',command)
		text=re.sub(r'out=(.+)$',r'outfile="\1"',text)
		text=re.sub(r'lcolor=(.+)$',r'lcolor="\1"',text)
		text=re.sub(r'data_format=(.+)$',r'data_format="\1"',text)
		text=re.sub(r'cblabel=(.+)$',r'cblabel="\1"',text)
		text=re.sub(r'label(.)=(.+)$',r'label\1="\2"',text)
		text=re.sub(r'unit(.)=(.+)$',r'unit\1="\2"',text)
		text=re.sub(r'"\s*"',r'"',text)
		return text

	def parse_header(self):
		hfile=sys.argv[1]
		import os.path
		if not os.path.exists(hfile):
			help()
		for line in open(hfile):
			exec("self.meta."+self.parse_sep(line))

	def parse_arg(self):
		for arg in sys.argv[2:]:
			print self.parse_sep(arg)
			exec("self.meta."+self.parse_sep(arg))

	def from_bin(self,dtype=float32):
		"""read an array from a binary file, return a numpy array"""
		fin=self.meta.infile
		n1=self.meta.n1
		n2=self.meta.n2
		n3=self.meta.n3
		s=file(fin,'rb').read()
		arr=fromstring(s,dtype=dtype)
		try:
			arr.shape=n3,n2,n1
		except:
			print "wrong shape!!"
			sys.exit(1)
		return arr,self.meta


class Plot3dObj:
	ox=0.; oy=0.; oz=0.
	dx=1.; dy=1.; dz=1.
	xlabel='x'
	ylabel='y'
	zlabel='z'
	intp='bilinear'
	vmin=0
	vmax=0

	# color map
	cmaps=[cm.jet,cm.jet_r,cm.gray,cm.gray_r,cm.spectral,cm.hsv]
	#cmaps=[cm.gray_r]
	icmap=0
	cmap=cmaps[icmap]

	# line color
	colors=['b','g','r','c','m','y','k','w']
	icolor=-2
	color=colors[icolor]

	def __init__(self,meta,data):
		self.meta=meta
		self.nx=meta.n3
		self.ox=meta.o3
		self.dx=meta.d3
		self.ny=meta.n2
		self.oy=meta.o2
		self.dy=meta.d2
		self.nz=meta.n1
		self.oz=meta.o1
		self.dz=meta.d1
		unit1=''; unit2=''; unit3=''
		if meta.unit1: unit1=" (%s)"%meta.unit1
		if meta.unit2: unit2=" (%s)"%meta.unit2
		if meta.unit3: unit3=" (%s)"%meta.unit3
		self.xlabel=meta.label3 + unit3
		self.ylabel=meta.label2 + unit2
		self.zlabel=meta.label1 + unit1

		self.fig=matplotlib.pyplot.figure()
		self.data=data
		self.init_box()

		self.vmin= meta.lbeg or data.min()
		self.vmax= meta.lend or data.max()
		#if meta.lend: self.vmax=meta.lend

		meta.lbeg= meta.lbeg or data.min()
		meta.lend= meta.lend or data.max()
		#meta.ldnum=meta.ldnum or int((data.max()-data.min())/5)

		if meta.cmap: self.cmap=meta.cmap
		if meta.lcolor: self.color=meta.lcolor

	def init_box(self):
		self.px = self.line_pick(self.meta.px,self.ox,self.dx,self.nx)
		self.py = self.line_pick(self.meta.py,self.oy,self.dy,self.ny)
		self.pz = self.line_pick(self.meta.pz,self.oz,self.dz,self.nz)

		## box size
		self.left=0.11
		self.bottom=0.22 #0.16
		self.width=0.4
		self.height=0.25
		self.width_inc=0.04
		self.height_inc=0.04
		self.top_height=0.45
		self.right_width=0.4
		self.spacing=0.01

		if self.meta.height:
			self.height=self.meta.height
			self.top_height=0.7-self.height
		if self.meta.width:
			self.width=self.meta.width
			self.right_width=0.8-self.width

	def line_pick(self,px,ox,dx,nx):
		if px:
			return (px-ox)/dx
		else:
			return nx/2
	
	def clip(self,min,max):
		if not min: min=self.data.min()
		if not max: max=self.data.max()
		if min>=max: return
		self.min=min
		self.max=max
		self.data=self.data.clip(min,max)

	def set_axes(self):
		# definitions for the axes
		left, width = self.left, self.width
		bottom, height = self.bottom, self.height
		top_height = self.top_height
		right_width = self.right_width
		spacing=self.spacing
		cb_bottom = 0.1 # colorbar
		cb_height = 0.02

		left_h = left+width+spacing
		bottom_h = bottom+height+spacing

		rect_main = [left, bottom, width, height]
		rect_top = [left, bottom_h, width, top_height]
		rect_right = [left_h, bottom, right_width, height]
		rect_cb = [left, cb_bottom, width+spacing+right_width, cb_height]

		self.ax_main=self.fig.add_axes(rect_main)
		self.ax_right=self.fig.add_axes(rect_right)
		self.ax_top=self.fig.add_axes(rect_top)
		if self.meta.colorbar: self.ax_cb=self.fig.add_axes(rect_cb)

	def set_ticks(self):
		nxtick=5 ; nytick=5 ; nztick=5
		self.xr=linspace(0,self.nx-1,nxtick)
		self.yr=linspace(0,self.ny-1,nytick)
		self.zr=linspace(0,self.nz-1,nztick)

	def get_planes(self):
		self.planez=self.data[:,:,self.pz].transpose()
		self.planey=self.data[:,self.py,:].transpose()
		self.planex=self.data[self.px,:,:].transpose()
	
	def num_format(self,label):
		if label == 0: return '0'
		if abs(label) < 0:
			return "%5.3f"%label
		if abs(label) < 1:
			return "%4.2f"%label
		if abs(label) < 10:
			return "%4.2f"%label
		if abs(label) < 100:
			return "%4.1f"%label
		if abs(label) < 1000:
			return "%3.0f"%label
		if abs(label) < 10000:
			return "%4.0f"%label
		if abs(label) < 100000:
			return "%5.0f"%label
		return "%8.0f"%label

	def make_xticks(self,axis,xr,o,d):
		axis.set_xticks(xr)
		axis.set_xticklabels([self.num_format(item) for item in o+d*xr])

	def make_yticks(self,axis,yr,o,d):
		axis.set_yticks(yr)
		axis.set_yticklabels([self.num_format(item) for item in o+d*yr])

	def draw_top(self):
		nx=self.nx; ny=self.ny
		px=self.px; py=self.py
		ox=self.ox; oy=self.oy
		dx=self.dx; dy=self.dy
		# z=const plane
		self.ax_top.imshow(self.planez,interpolation=self.intp,cmap=self.cmap,origin='lower',vmin=self.vmin,vmax=self.vmax)
		self.ax_top.plot([px,px],[0,ny-1],self.color+':',lw=self.meta.lwidth)
		self.ax_top.plot([0,nx-1],[py,py],self.color+':',lw=self.meta.lwidth)
		self.ax_top.axis('tight')
		self.ax_main.axis([0,nx-1,0,ny-1])
		## ticks
		nytick=3
		yr=linspace(0,ny-1,nytick)
		#self.ax_top.set_yticks(yr)
		ylabel=[self.num_format(item) for item in oy+dy*yr]
		ylabel[0]=''
		#self.ax_top.set_yticklabels(ylabel)

		xt=arange(0,nx,nx/5)
		self.ax_top.set_xticks(xt)
		self.ax_top.set_xticklabels([])
		#self.ax_main.set_xticklabels([int(i) for i in xt*dx])

		yt=arange(0,ny,ny/3)
		self.ax_top.set_yticks(yt[1:])
		self.ax_top.set_yticklabels([int(i) for i in oy+yt[1:]*dy])
		## labels
		self.ax_top.set_ylabel(self.ylabel)

	def draw_main(self):
		nx=self.nx; nz=self.nz
		px=self.px; pz=self.pz
		ox=self.ox; oz=self.oz
		dx=self.dx; dz=self.dz
		# y=const plane
		self.ax_main.imshow(self.planey,interpolation=self.intp,cmap=self.cmap,vmin=self.vmin,vmax=self.vmax)
		self.ax_main.plot([px,px],[0,nz-1],self.color+':',lw=self.meta.lwidth)
		self.ax_main.plot([0,nx-1],[pz,pz],self.color+':',lw=self.meta.lwidth)
		self.ax_main.axis('tight')
		self.ax_main.axis([0,nx-1,nz-1,0])
		## ticks
		#self.make_xticks(self.ax_main,self.xr,ox,dx)
		#self.make_yticks(self.ax_main,self.zr,oz,dz)
		xt=arange(0,nx,nx/5)
		self.ax_main.set_xticks(xt)
		self.ax_main.set_xticklabels([int(i) for i in ox+xt*dx])
		yt=arange(0,nz,nz/5)
		self.ax_main.set_yticks(yt)
		self.ax_main.set_yticklabels([int(i) for i in oz+yt*dz])
		## labels
		self.ax_main.set_xlabel(self.xlabel)
		self.ax_main.set_ylabel(self.zlabel)

	def draw_right(self):
		ny=self.ny; nz=self.nz
		py=self.py; pz=self.pz
		oy=self.oy; oz=self.oz
		dy=self.dy; dz=self.dz
		# x=const plane
		im=self.ax_right.imshow(self.planex,interpolation=self.intp,cmap=self.cmap,vmin=self.vmin,vmax=self.vmax)
		self.ax_right.plot([py,py],[0,nz-1],self.color+':',lw=self.meta.lwidth)
		self.ax_right.plot([0,ny-1],[pz,pz],self.color+':',lw=self.meta.lwidth)
		self.ax_right.axis('tight')
		self.ax_right.axis([0,ny-1,nz-1,0])
		## ticks
		#nytick=3
		#yr=linspace(0,1,nytick)*float(ny-1)
		#self.ax_right.set_xticks(yr)
		#xlabel=[self.num_format(item) for item in oy+dy*yr]
		#xlabel[0]=''
		#self.ax_right.set_xticklabels(xlabel)
		self.ax_right.set_yticklabels([])
		yt=arange(0,ny,ny/3)
		self.ax_right.set_xticks(yt[1:])
		self.ax_right.set_xticklabels([int(i) for i in oy+yt[1:]*dy])
		## labels
		self.ax_right.set_xlabel(self.ylabel)
		if self.meta.colorbar:
			if self.meta.ldnum:
				self.meta.cbticks=arange(self.meta.lbeg,self.meta.lend+self.meta.ldnum,self.meta.ldnum)
			if self.meta.cbticks==[]:
				cb=self.fig.colorbar(im,cax=self.ax_cb,orientation='horizontal')
			else:
				cb=self.fig.colorbar(im,cax=self.ax_cb,orientation='horizontal',ticks=self.meta.cbticks)
			cb.ax.set_xlabel(self.meta.cblabel)

	def draw_figure(self):
		self.set_axes()
		self.set_ticks()
		self.draw_top()
		self.draw_main()
		self.draw_right()
		self.text_box()
		#canvas=matplotlib.backend_bases.FigureCanvasBase(self.fig)
		#canvas.resize(800,800)
	
	def text_box(self):
		px=self.get_position(self.ox,self.dx,self.px)
		py=self.get_position(self.oy,self.dy,self.py)
		pz=self.get_position(self.oz,self.dz,self.pz)
		txt_x=self.left+self.width+self.spacing
		txt_dx=0.11
		txt_y=self.bottom+self.height+self.spacing
		txt_dy=0.04
		#self.fig.text(0.5,txt_y+self.top_height+self.spacing,"in=%s"%(meta.infile),ha='center')
		#self.fig.text(0.7,txt_y+self.top_height+self.spacing,"min=%s"%(self.num_format(self.data.min())))
		#self.fig.text(0.85,txt_y+self.top_height+self.spacing,"max=%s"%(self.num_format(self.data.max())))

		#self.fig.text(txt_x,txt_y+2*txt_dy,"nx=%s"%(self.nx))
		#self.fig.text(txt_x,txt_y+txt_dy,"ny=%s"%(self.ny))
		#self.fig.text(txt_x,txt_y,"nz=%s"%(self.nz))

		#self.fig.text(txt_x+txt_dx,txt_y+2*txt_dy,"px=%s"%(self.num_format(px)))
		#self.fig.text(txt_x+txt_dx,txt_y+txt_dy,"py=%s"%(self.num_format(py)))
		#self.fig.text(txt_x+txt_dx,txt_y,"pz=%s"%(self.num_format(pz)))


	def toggle_cmap(self):
		self.icmap+=1
		self.cmap=self.cmaps[self.icmap%len(self.cmaps)]

	def toggle_barcolor(self):
		self.icolor+=1
		self.color=self.colors[self.icolor%len(self.colors)]
	
	def width_plus(self):
		self.width+=self.width_inc
		self.right_width-=self.width_inc

	def width_minus(self):
		self.width-=self.width_inc
		self.right_width+=self.width_inc

	def height_plus(self):
		self.height+=self.height_inc
		self.top_height-=self.height_inc

	def height_minus(self):
		self.height-=self.height_inc
		self.top_height+=self.height_inc
	
	def get_position(self,o,d,i):
		return o+d*i
	
	def print_position(self,ix,iy,iz):
		print "x=%s, y=%s, z=%s"%(
				self.get_position(self.ox,self.dx,ix),
			 	self.get_position(self.oy,self.dy,iy),
			 	self.get_position(self.oz,self.dz,iz))
	
	def real_size(self):
		yz=self.ny+self.nz
		xy=self.nx+self.ny
		height=self.height+self.top_height
		width=self.width+self.right_width
		self.height=height*self.nz/yz
		self.top_height=height*self.ny/yz
		self.width=self.height*self.nx/self.nz
		self.right_width=self.width*self.nx/self.ny

		if self.width+self.right_width > width:
			self.width=width*self.nx/xy
			self.right_width=width*self.ny/xy
			self.height=self.width*self.nz/self.nx
			self.top_height=self.width*self.ny/self.nx
		print self.width,self.right_width,self.height,self.top_height

	def onclick(self,event):
		if event.button in (2,3): # center, right click
			return
	#	print 'button=%s, x=%s, y=%s, xdata=%s, ydata=%s'%(
	#		event.button, event.x, event.y, event.xdata, event.ydata)
		if event.inaxes==self.ax_main:
			self.px=int(event.xdata)
			self.pz=int(event.ydata)
		if event.inaxes==self.ax_top:
			self.px=int(event.xdata)
			self.py=int(event.ydata)
		if event.inaxes==self.ax_right:
			self.py=int(event.xdata)
			self.pz=int(event.ydata)
		self.print_position(self.px,self.py,self.pz)
		self.redraw()

	def on_key(self,event):
		#print 'you pressed', event.key, event.xdata, event.ydata
		# quit
		if event.key=='q':
			sys.exit(0)
		# change color map
		if event.key=='h':
			self.toggle_cmap()
		# change line color
		if event.key=='c':
			self.toggle_barcolor()
		# box size
		if event.key=='j':
			self.width_minus()
		if event.key=='l':
			self.width_plus()
		if event.key=='i':
			self.height_plus()
		if event.key=='k':
			self.height_minus()
		# real size
		if event.key=='z':
			self.real_size()
		# reset box
		if event.key=='r':
			self.init_box()
		self.redraw()
	
	def redraw(self):
		self.get_planes()
		self.fig.clf()
		self.draw_figure()
		self.fig.canvas.draw()


parser=Parser()
parser.parse_header()
parser.parse_arg()
data,meta=parser.from_bin()

ha=Plot3dObj(meta,data)
ha.clip(meta.wclip,meta.bclip)

ha.get_planes()
ha.draw_figure()

cid = ha.fig.canvas.mpl_connect('button_press_event', ha.onclick)
cid = ha.fig.canvas.mpl_connect('key_release_event', ha.on_key)

ha.draw_figure()
ha.redraw()
savefig(meta.outfile)
show()
