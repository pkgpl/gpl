import sys

class Axis:
	def __init__(self):
		self.n=0
		self.d=0.
		self.o=0.
		self.l=""
		self.u=""

	def dump(self,fout=sys.stdout):
		fout.write("n=%s o=%s d=%s label=%s unit=%s\n"%(self.n,self.o,self.d,self.l,self.u))

def strip_delim(str):
	tmp=str
	if tmp.startswith('"') or tmp.startswith("'"): tmp=tmp[1:]
	if tmp.endswith('"')   or tmp.endswith("'"): tmp=tmp[:-1]
	return tmp

class RsfFile:
	def __init__(self,fhead,mode):
		self.fhead=fhead
		self.fh=open(self.fhead,mode)
		self.initialize()
		if mode=='r':
			self.parse()

	def initialize(self):
		self.data_format='native_float'
		self.infile=""
		self.n=[0,0,0,0,0,0,0,0,0,0]
		self.d=[0.,0.,0.,0.,0.,0.,0.,0.,0.,0.]
		self.o=[0.,0.,0.,0.,0.,0.,0.,0.,0.,0.]
		self.l=['','','','','','','','','','']
		self.u=['','','','','','','','','','']
		for i in range(1,10):
			self.n[i]=0
			self.d[i]=0.
			self.o[i]=0.
			self.l[i]=''
			self.u[i]=''

	def parse(self):
		words=self.fh.read().split()
		self.fh.close()
		for word in words:
			if '=' in word:
				key,val=word.split('=')
				if   key=='in': self.infile=strip_delim(val)
				elif key=='data_format': self.data_format=strip_delim(val)
				else:
					num=int(key[-1])
					if   key[0]=='n': self.n[num]=int(val)
					elif key[0]=='d': self.d[num]=float(val)
					elif key[0]=='o': self.o[num]=float(val)
					elif key[0:5]=='label': self.l[num]=strip_delim(val)
					elif key[0:4]=='unit': self.u[num]=strip_delim(val)

	def iaxa(self,axis,num):
		self.n[num]=axis.n
		self.d[num]=axis.d
		self.o[num]=axis.o
		self.l[num]=axis.l
		self.u[num]=axis.u

	def oaxa(self,axis,num):
		axis.n=self.n[num]
                axis.d=self.d[num]
                axis.o=self.o[num]
                axis.l=self.l[num]
                axis.u=self.u[num]

	def dump(self,fout=sys.stdout):
		for i in range(1,10):
			if not self.n[i]==0:
				fout.write("\tn%s=%s o%s=%s d%s=%s\n"%(i,self.n[i],i,self.o[i],i,self.d[i]))
				if not self.l[i]=='': fout.write('\tlabel%s="%s"\n'%(i,self.l[i]))
				if not self.u[i]=='': fout.write('\tunit%s="%s"\n'%(i,self.u[i]))
		fout.write('\tin="%s"\n'%(self.infile))
		fout.write('\tdata_format="%s"\n'%(self.data_format))

	def dump2file(self,filename):
		fout=open(filename,'w')
		# info
		import os
		program=os.path.basename(sys.argv[0])
		cwd=os.getcwd().split('/')
		if len(cwd)>=3: pwd=os.path.join(*cwd[-3:])
		else: pwd=os.getcwd()
		user=os.getlogin()
		host=os.getenv('HOSTNAME')
		import time
		tm=time.ctime()

		fout.write("%s\t%s:\t%s@%s\t%s\n\n"%(program,pwd,user,host,tm))
		self.dump(fout)
		fout.close()

# main
#print __name__, __file__
if __name__ == '__main__':
	rsf=RsfFile('test.rsf','r')
	rsf.dump2file('new.rsf')

	ax=Axis()
	rsf.oaxa(ax,1)
	ax.dump()
