#!/usr/bin/ruby -w
#
# Program :
# Date :

# Matplotlib.draw('output.eps') do
#   # instance_eval
#   xlim [xmin,xmax]
#   xlabel 'label x'
#   ticklabel_format :y,true
#   grid
#   legend 'best'
#   log :y
#   plot 'file1', u:[1,3], t:'title1', w:'k-', lw:2, beg:1, end:100, skip:2
#   plot 'file2', t:'title2'
#   left 0.12
#   right 0.945
#   bottom 0.14
#   top 0.92
#   rcparams
#   color
# end
#
# Matplotlib.new('output2.png') do
#   subplot 211
#   subplots_adjust :wspace=>0.1,:hspace=>0.1
#   semilogy 'file1'
#   loglog 'file2'
#   text 0.5, 0.2, 'text', color=>, size=>, rotation=>, style=>, ...
#   subplot 212
# end


# TODO
# imshow => velocity, gradient, migration, seismogram, spectrum  ## psimage
#   color, colorbar
# tick spacing

class Matplotlib

# Constants
PYIMPORT=<<END
# Python matplotlib script generated by ruby on #{Time.new}
import matplotlib
from pylab import *
import numpy
END
RCPREPEND=<<END
\n# rc parameters
matplotlib.rcParams['figure.figsize']=(8.0,4.0)
matplotlib.rcParams['font.size']=12.0
matplotlib.rcParams['savefig.dpi']=600
matplotlib.rcParams['figure.subplot.left']=0.12
matplotlib.rcParams['figure.subplot.right']=0.945
matplotlib.rcParams['figure.subplot.bottom']=0.14
matplotlib.rcParams['figure.subplot.top']=0.92
END
PREPEND=<<END
\n# Header
figure()
hold(True)
END
FORMATTER1=<<END
\ndef formatter1(val,pos=None):
	out="%g"%val
	# 1e-10 => 1.0e-10
	if out[1:2]=='e':
		out=out[0:1]+'.0'+out[1:]
	# -1e-10 => -1.0e-10
	if out[0]=='-' and out[2:3]=='e':
		out=out[0:2]+'.0'+out[2:]
	return out
END

	def initialize(fout,&block)
		# output figure file
		@fout=fout
		# python interpreter
		@python='python'
		# python script
		@rc,@pyhead,@pycmd,@pyopt,@pyfoot=[],[],[[]],[[]],[]
		# isub: number of subplots, np: number of plots in a subplot
		@isub=0; @np=[0] 
		@written,@ppt=false,false
		# default values
		@plot_cmd='plot'
		@mark=['k-','k--','k:','k-.']
		@defaults={:skip=>1,:linewidth=>3,:fontsize=>'large'}
		@skip=1
		@linewidth=3
		@fontsize='large'
		# eval
		self.instance_eval(&block)
		self
	end

        def self.draw(fout,&block)
		self.new(fout,&block).run
	end

	# command type 1: String argument
	%w(xlabel ylabel).each do |cmd|
		define_method cmd do |str|
			@pyopt[@isub] << "#{cmd}(r#{quote(str)},fontsize=fontsize)"
		end
	end
	# general command with/without arguments
	def py(cmd,*args)
		if args.empty?
			arg='' ; hash=''
		else
			hash= (Hash === args[-1])? args.delete_at(-1) : nil
			hash= (hash)? ','+to_args(hash) : ''
			arg=args.inject(''){|out,a| out += "#{quote(a)},"}[0...-1]
		end
		@pyopt[@isub] << "#{cmd}(#{arg}#{hash})"
	end
	def rcparams(name,val)
		@rc << "matplotlib.rcParams[#{quote(name)}]=#{val}"
	end
	# rc parameters
	%w(left right top bottom).each do |cmd|
		define_method cmd do |arg|
			#@rc << "matplotlib.rcParams['figure.subplot.#{cmd}']=#{arg}"
			rcparams("figure.subplot.#{cmd}",arg)
		end
	end
	def figsize(arr)
		#@rc << "matplotlib.rcParams['figure.figsize']=(#{arr[0]},#{arr[1]})"
		rcparams('figure.figsize',"(#{arr[0]},#{arr[1]})")
	end
	# general command with/without arguments
	%w(text grid xlim ylim).each do |cmd|
		define_method cmd do |*args|
			py(cmd,*args)
		end
	end
	alias :xrange :xlim
	alias :yrange :ylim

	def color
		@mark=['b-','r--','g-.','ko:']
	end

	def ppt
		@ppt=true
		color
	end

	def paper
		figsize [4,2]
		rcparams 'font.size',8
		rcparams 'legend.fontsize',8
		left 0.18
		bottom 0.18
	end

	# line plot command
	def plot(file,*args)
	    arg=args.inject({}){|result,element| result.merge! element}
	    # Data - using columns
	    @pycmd[@isub] << "\nData=numpy.loadtxt(#{quote(file)})"
	    arg[:u]=[1,2] unless arg[:u]
	    @pycmd[@isub] << "x=Data[:,#{arg[:u].first-1}]; y=Data[:,#{arg[:u].last-1}]"
	    # Data - begin,end,skip
	    data="[#{arg[:beg]?arg[:beg]-1:''}:#{arg[:end]?arg[:end]-1:''}:#{arg[:skip]||@defaults[:skip]}]"
	    # Options
	    linestyle=arg[:w] || @mark[@np[@isub]]
	    label=arg[:t] || file
	    lw=arg[:lw] || @defaults[:linewidth]
	    # additional options
	    addition=''
	    addition+=",ms=#{arg[:ms]}" if arg[:ms]
	    # Plot command
	    @pycmd[@isub] << "#{@plot_cmd}(x#{data},y#{data},#{quote(linestyle)},label=#{quote(label)},lw=#{lw}#{addition})\n"
	    @np[@isub]+=1
	end
	def log(ax=:y)
		@plot_cmd=case ax
			  when :y then 'semilogy'
			  when :x then 'semilogx'
			  when :xy then 'loglog'
			  else 'plot'
			  end
	end
	%w(semilogy semilogx loglog).each do |cmd|
		define_method cmd do |file,*args|
			@plot_cmd=cmd
			plot(file,*args)
		end	
	end
	def subplot(n)
		@isub+=1 ; @np[@isub]=0
		@pycmd[@isub],@pyopt[@isub]=[],[]
		@pycmd[@isub] << "\n# subplot #{@isub}"
		@pycmd[@isub] << "subplot(#{n})"
	end
	def subplots_adjust(hash)
		@pyhead << "subplots_adjust(#{to_args(hash)})"
	end

	def legend(loc='best',handlelength=nil)
		if handlelength
			@pyopt[@isub] << "legend(loc=#{quote(loc)},handlelength=#{handlelength})"
		else
			@pyopt[@isub] << "legend(loc=#{quote(loc)})"
		end
	end
	def ticklabel_format(ax=:y,zero=false)
		if zero
			@rc << FORMATTER1
			@pyopt[@isub] << "gca().#{ax}axis.set_major_formatter(matplotlib.ticker.FuncFormatter(formatter1))"
		else
			@pyopt[@isub] << "gca().#{ax}axis.set_major_formatter(matplotlib.ticker.FuncFormatter(lambda v,p: \"%g\"%v))"
		end
		left 0.15
	end
	def write
		@python_script='Plot_'+File.basename(@fout,'.*')+'.py'
		File.open(@python_script,'w') do |f|
			# header
			f.write(PYIMPORT)
			f.write(RCPREPEND) unless @ppt
			@rc.each{|l| f.write("#{l}\n")}
			f.write(PREPEND)
			%w{skip linewidth fontsize}.each do |v|
				val=instance_eval("@#{v}")
				f.write("#{v}=#{val.inspect}\n")
			end
			@pyhead.each{|l| f.write("#{l}\n")}
			# plot and options
			f.write("\n# Body\n")
			0.upto(@isub) do |isub|
				@pycmd[isub].each{|l| f.write("#{l}\n")}
				@pyopt[isub].each{|l| f.write("#{l}\n")}
			end
			# footer
			f.write("\n# Foot\n")
			@pyfoot.each{|l| f.write("#{l}\n")}
			f.write("savefig(#{quote(@fout)})\n")
		end
		@written=true
		puts "python script: #{@python_script}"
		@python_script
	end
	def run
		write unless @written
		cmd="#{@python} #{@python_script}"
		system(cmd)
		puts "output: #{@fout}"
		@fout
	end

	def quote(str)
		if String === str
			if str.start_with?('"') or str.start_with?("'")
				str
			else
				'"'+str+'"'
			end
		else
			str
		end
	end
	#def quote(strin)
	#	str=strin.to_s
	#	if str.start_with?('"') or str.start_with?("'")
	#		str
	#	else
	#		'"'+str+'"'
	#	end
	#end
	def to_args(hash)
		arg=hash.inject(''){|o,e| o+="#{e[0]}=#{quote(e[1])},"}[0...-1]
	end

end

#Matplotlib.new('test.eps') do 
##	xlim [0,5.0]
##	ylim [-1,1]
#	xlabel 'label $\frac{X^2}{\pi}$'
#	ylabel 'label Y'
#	legend 'best'
#	#@skip=2
#	plot 'test.dat',u,t:'title1'
#	#semilogy 'test2.txt',u(1,4),t:'title2'
#	bottom 0.14
#	grid
#end.run