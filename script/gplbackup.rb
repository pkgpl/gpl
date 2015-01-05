#!/home/happywan/bin/ruby -w
# Program : Backup script
# Author : wansooha@gmail.com
# Date : 13 Aug 2007
#
$: << File.dirname($0)+'/../lib/'
#require 'gpllib'
require 'yaml'
require 'fileutils'
require 'find'

#def selfdoc
#	message= <<-MSGEND
#	Gpl Backup Manager : backup files matching extensions recursively
#	Usage :
#		#{File.basename(__FILE__)} [cfg filename] 
#	Optional parameters :
#		cfg filename	: configuration file(yaml file) name 
#		--cfg > gplbackup.yml		: generate sample 'gplbackup.yml' file
#	Configuration file
#		see sample 'gplbackup.yml' file. (use --cfg option)
#	MSGEND
#	error(message)
#end
#selfdoc if ARGV.size == 0
message= <<-MSGEND
Gpl Backup Manager : backup files matching extensions recursively
Usage :
	#{File.basename(__FILE__)} [cfg filename] 
Optional parameters :
	cfg filename	: configuration file(yaml file) name 
	--cfg > gplbackup.yml		: generate sample 'gplbackup.yml' file
Configuration file
	see sample 'gplbackup.yml' file. (use --cfg option)
MSGEND
if ARGV.size == 0
	puts message
	exit 1
end

def genyml
	message= <<-MSGEND
# Gpl Backup Manager Configuration File
# Date : #{Time.now.strftime("%Y.%m.%d")}

# Source directories you want to backup
sourceDirectory :
- Documents
- lib

# Extensions of files you want to backup
extensions :
- .f
- .f90
- .c
- .rb
- .sh
- Makefile
- .tex

# A directory name to which the backup files will be copied
targetDirectory : #{ENV["HOSTNAME"].split(".")[0]}Bak

# Print the copying process (T/F)
verbose : T

# Make "#{ENV["HOSTNAME"].split(".")[0]}Bak#{Time.now.strftime("-%Y.%m.%d")}.tgz" file using the targetDirectory (T/F)
makeTarBall : T

# Remove the targetDirectory after backup (T/F) - when you want tgz file only
removeBackupDir : F

# Files containing these words in their absolute path will be omitted
exclude :
- 'backup'
- 'lib/dms'
- 'lib/UMFPACK'
- 'lib/SU'
- 'lib/seplib'
- '.svn'
	MSGEND
	puts message
	exit 0
end
genyml if ARGV[0]=='--cfg'

# reading configuration file
cfgfile=ARGV[0] if ARGV.size > 0
unless File.exist?(cfgfile)
	puts "\nNo configuration file [#{cfgfile}] exist!"
	puts "run #{File.basename(__FILE__)} with --cfg option to make cfg file"
	exit 1
end
cfg=File.open(cfgfile,"r"){|f|YAML.load(f)}
targetDirectory=cfg["targetDirectory"] || error('cannot find "targetDirectory"')

if File.exists?(targetDirectory)
	puts "\nThe target directory [#{targetDirectory}] exists. Do you want to continue?"
	print "[o]verwrite, [r]emove it and continue, [s]top :"
	answer=STDIN.read(1)
	case answer
	when 'o'
		puts "overwrite"
	when 'r'
		puts "removing #{targetDirectory}"
		FileUtils.rm_rf(targetDirectory)
	when 's'
		puts "stop"
		exit 1
	else
		puts "overwrite"
	end
end

class File
	# copy file to target directory
	def File.backup(file,target,verb)
		dir=File.dirname(file)
		dir=target + File::SEPARATOR + dir
		unless File.exists?(dir)
			FileUtils.mkdir_p(dir)
		end
		begin
			FileUtils.cp(file,dir)
		rescue
			puts "copy error : cp #{file}   #{dir}"
		end
		puts "cp  #{file}     #{dir}" if verb
	end

	# versioned filename to prevent overwriting .tgz file
	def File.versioned_filename(base, first_suffix='.0')
		suffix=nil
		filename=base+".tgz"
		while File.exists?(filename)
			suffix=(suffix ? suffix.succ : first_suffix)
			filename=base+suffix+".tgz"
		end
		return filename
	end
end

# copy files to target directory
error('cannot find "sourceDirectory"') unless cfg["sourceDirectory"]
error('cannot find "extensions"') unless cfg["extensions"]

verbose=( cfg["verbose"] == 'T' ? 1 : nil )
exclude=cfg['exclude'] << targetDirectory
nfile=0
cfg["sourceDirectory"].each do |src|
	puts "\nin #{src}"
	Find.find(src) do |f|
		# skip 'exclude' directory
		absf=File.expand_path(f)
		exclude.each do |exc|
			Find.prune if absf =~ /#{exc}/
		end
		# backup
		cfg["extensions"].each do |ext|
			expr=( ext =~ /^\./ ? "\\"+ext+"$" : ext+"$" )
			if f =~ /#{expr}$/ && !File.directory?(f)
				File.backup(f,targetDirectory,verbose)
				nfile+=1
			end
		end
	end
end
puts "#{nfile} files are backed up"

if nfile==0
	cfg["makeTarBall"]='F'
	cfg["removeBackupDir"]='F'
end

# archive the backup directory to .tgz file
if maketarball=( cfg["makeTarBall"] == 'T' ? 1 : nil )
	# tgz file (file name will be #{targetDirectory}-#{date}.tgz)
	print "making tgz ball : "
	now = Time.now.strftime("-%Y%m%d") #'-%Y%m%d-%H.%M.%S'
	filename=File.versioned_filename(targetDirectory+now,'-00')
	system "cd #{File.dirname(targetDirectory)}; tar -zcvf #{filename} #{File.basename(targetDirectory)}"
	puts "#{filename} : #{File.size(filename)} bytes"
end

# remove backup directory
if remove=( cfg["removeBackupDir"] == 'T' ? 1 : nil )
	puts "removing targetDirectory #{targetDirectory}"
	FileUtils.rm_rf(targetDirectory) 
end
