#!/usr/bin/ruby -w
#
# Program :
# Date :

fin='test.f90'
if ARGV.size==0 then
	puts " Gpl Fortran Allocatable array insepctor - Inspect allocatable arrays in an f90 file"
	puts " Usage: gplfalloc [f90 file]"
	exit
else
	fin=ARGV[0]
end

allocatable={}
allocated={}
allocated_current={}
used_before_alloc={}
dealloc_before_alloc={}

line_number=0
File.open(fin).each do |line|
	line_number+=1
	text=line.chomp.downcase
	if not text =~ /^\ *!/ # skip comment line
		if text.include? 'allocatable'
			# find allocatable array names from declaration
			text2=text.gsub(/\(\ *:(\ *,\ *:)*\ *\)/,'') # remove dimension (:), (:,:) ...
			arrs=text2.split('::')[1].gsub(' ','').split(',')
			arrs.each do |arr|
				allocatable[arr]=line_number
			end
		elsif text.include? 'deallocate'
			# find deallocated array names
			text2=text.split(/deallocate\ *\(/)[1]
			arrs2=text2.gsub(')','').gsub(' ','').split(',')
			arrs2.each do |arr|
				if allocated_current.include?(arr)
					allocated_current.delete(arr)
				else
					dealloc_before_alloc[arr]=line_number
				end
			end
		elsif text.include? 'allocate'
			# find allocated arrays
			text2=text.split(/allocate\ *\(/)[1]
			arrs2=text2.gsub(/\(.*?\)/,'').gsub(')','').gsub(' ','').split(',')
			arrs2.each do |arr|
				allocated_current[arr]=line_number
				allocated[arr]=line_number
			end
		else
			# find arrays used before allocation
			allocatable.keys.each do |arr|
				#if text.include? arr
				if /\W#{arr}\W/ =~ text
					if not allocated_current.include? arr
						used_before_alloc[arr]=line_number
					end
				end
			end
		end
	end
end
puts " Used before allocation:\n\t#{used_before_alloc.inspect}"
puts " Deallocated before allocation:\n\t#{dealloc_before_alloc.inspect}"
puts " Not allocated:\n\t#{(allocatable.keys - allocated.keys).inspect}"
