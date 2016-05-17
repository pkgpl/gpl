#!/usr/bin/ruby -w
#
# Program :
# Date :

class Array
	def to_hash()
		hash={}
		ARGV.each do |item|
			k,v=item.split('=')
			hash[k]=v
		end
		hash
	end
end
		

def argv_to_hash()
	hash={}
	ARGV.each do |item|
		k,v=item.split('=')
		hash[k]=v
	end
	return hash
end

# input: n1=10 d1=0.1 label1="Depth (km)"
# output: {:n1=>"10", :d1=>"0.1", :label1=>"Depth (km)"}
def parse_argv(argv)
	param={}
	argv.each do |term|
		key,val=term.split('=')
		param[key.to_sym]=val
	end
	param
end


# input: 'n1=201 d1=0.04 label1="Depth (km)" r1=3'
# output: {n1:201,d1:0.04,label1:"Depth (km)",r1:3}
#

class OptionString < String
	def initialize(opt)
		@opt=opt
	end

	def to_hash
		list=@opt.split(' ')
		pars=[]
		list.each do |l|
			if l.include? '='
				pars << l
			else
				pars[-1]+=" #{l}"
			end
		end
		hash={}
		pars.each do |p|
			k,v=p.split('=')
			hash[k.to_sym]=no_quote(v)
		end
		hash
	end

	def no_quote(str)
		str=str[1..-1] if str.start_with? '"' or str.start_with? "'"
		str=str[0..-2] if str.end_with? '"' or str.end_with? "'"
		str
	end
end

#a=OptionString.new('n1=201 d1=0.04 label1="Depth (km)" r1=3')
#p a.to_hash
