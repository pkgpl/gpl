#!/usr/bin/ruby -w
#
# Program : Show information of an image
# Date : 8 May 2008

require 'RMagick'

def show_info(fname)
	img = Magick::Image::read(fname).first
	fmt = img.format
	w,h = img.columns,img.rows
	dep = img.depth
	nc  = img.number_colors
	nb  = img.filesize
	xr  = img.x_resolution
	yr  = img.y_resolution
	res = Magick::PixelsPerInchResolution ? "inch" : "cm"
	cmp = img.compression
	xdim= w.to_f/xr
	ydim= h.to_f/yr
	puts <<-EOF
	File:		#{fname}
	Format:		#{fmt}
	Dimensions:	#{w}x#{h} pixels
	Colors:		#{nc}
	Image size:	#{nb} bytes
	Resolution:	#{xr}/#{yr} pixels per #{res}
	Dimension:	#{xdim}*#{ydim} #{res}
	Depth:		#{dep}
	Compression:	#{cmp}
	EOF
	puts
end

if ARGV.size==0
	puts 'input image file name'
	exit 1
end
if File.exist?(ARGV[0])
	show_info(ARGV[0])
else
	puts 'File not exists!'
	exit 1
end
