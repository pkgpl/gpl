#!/usr/bin/ruby -w
#
# Program :
# Date :

class FortranInspect
	ReUse=/^\s*use\s+(\w+)/i
	ReMod=/^\s*module\s+(\w+)/i
	ReCall=/^[^!]*call\s+(\w+)/i
	ReSub=/^\s*subroutine\s+(\w+)/i
	ReFunc=/.*function\s+(\w+)/i
	def initialize(file)
		@use,@mod,@call,@sub,@func=collect_info(file)
	end
	def collect_info(file)
		use,mod,call,sub,func=[],[],[],[],[]
		unless File.exists? file
			puts "file [#{file}] not exists"
			exit 1
		end
		IO.foreach(file) do |line|
			if mt=line.downcase.match(ReUse ) then use  << mt[1] end
			if mt=line.downcase.match(ReMod ) then mod  << mt[1] end
			if mt=line.downcase.match(ReCall) then call << mt[1] end
			if mt=line.downcase.match(ReSub ) then sub  << mt[1] end
			if mt=line.downcase.match(ReFunc) then func << mt[1] end
		end
		return use.uniq, mod.uniq, call.uniq, sub.uniq, func.uniq
	end
	attr_reader :use, :call, :sub, :mod, :func
end

class GplLibInfo
	def self.numeric
		return %w(tconvolve csy laplacetr fftcc dfftcc fdgaus gauss ricker)
	end
	def self.modules
		#return %w(gpl suio rsf segyio sepio numeric)
		return %w(gpl suio segyio sepio numeric)
	end
end

