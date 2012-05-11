unless Kernel.respond_to?(:require_relative)
  module Kernel
    def require_relative(path)
      require File.join(File.dirname(caller[0]), path.to_str)
    end
  end
end

case RUBY_PLATFORM
when /mingw|mswin/
	@slash = "\\"
else
	@slash = "/"
end

VERSION="2.0.4"
require 'rubygems'
require 'readline'

# CHECK FOR GEMS HACK METHOD
def gem_available?(name)
   Gem::Specification.find_by_name(name)
rescue Gem::LoadError
   puts "[*] - esearchy requires #{name}."
   if  RUBY_PLATFORM =~ /mingw|mswin/
   	system "gem install #{name}"
   else
   	system "sudo gem install #{name}"
   end
end

puts "-<[ ESearchy 0.3 CodeName Miata ]>-"
puts "-<[ Setup and Configurations script ]>-"
puts ""
puts "[*] - Missing Gem installation"

if  RUBY_PLATFORM =~ /mingw|mswin/
	puts "[*] - If windows need to install win32console Gem."
  gem_available? 'win32console'
end

require_relative 'lib/esearchy/helpers/display.rb'



# MONGO METHODS
def mongo_download(os,platform)
	case os
	when /linux|osx/
		Display.msg "Downloading mongodb-#{os}-#{platform}-#{VERSION}.tgz"
		system("curl http://fastdl.mongodb.org/#{os}/mongodb-#{os}-#{platform}-#{VERSION}.tgz > external/mongodb.tgz")
	when /win32/
		Display.msg "Downloading mongodb-#{os}-#{platform}-#{VERSION}.zip" 
		system("external/tools/wget.exe -O external\\mongodb.zip http://fastdl.mongodb.org/#{os}/mongodb-#{os}-#{platform}-#{VERSION}.zip")
	end
end

def mongo_install(os)
	case os
	when /linux|darwin/
		Display.msg "Decompressing mongodb"
		system("tar xzf external/mongodb.tgz -C external")
		system("mv external/mongodb-* external/mongodb")
		Display.msg "Removing downloaded file"
		system("rm external/mongodb.tgz")
	when /mingw|mswin/
		Display.msg "Decompressing mongodb"
		system("external/tools/unzip.exe external\\mongodb*.zip -d external")
		system("move external\\mongodb-* external\\mongodb")
		Display.msg "Removing downloaded file"
		system("del external\\mongodb.zip")
	end
end

def mongo_install_service
	# runas /user:Administrator "external\mongodb\bin\mongod --install --dbpath=C:\Users\matt\.esearchy\data\db --logpath=C:\Users\matt\.esearchy\logs\mongodb.logs--logappend --serviceName=MONGODB"
	mongod = "external/mongodb/bin/mongod --install"
	dblogs = ENV['HOME'] + "/.esearchy/logs/mongodb.logs"
	dbpath = ENV['HOME'] + "/.esearchy/data/db"
	cmd = (mongod + " --dbpath=\"" + dbpath + "\" --logpath=\"" + dblogs + "\" --logappend --serviceName MONGODB").gsub("/",@slash)
	system("external\\tools\\Elevate.exe " + cmd )
	sleep(1)
rescue
	Display.error "Something went wrong installing MongoDB as a service."
end

def mongo_install?
	unless File.exists?((File.expand_path File.dirname(__FILE__) + "external").gsub("/",@slash))
		system("mkdir external")
		unless File.exists?((File.expand_path File.dirname(__FILE__) + "external/mongodb").gsub("/",@slash))
			case RUBY_PLATFORM
			when /linux/
				Display.msg "IMPORTANT: curl must be installed and on $PATH."
				RUBY_PLATFORM =~ /x86_64/ ? 
					mongo_download("linux", "x86_64") :
					mongo_download("linux", "i686")
				mongo_install("linux")
			when /darwin/
				RUBY_PLATFORM =~ /x86_64/ ?
					mongo_download("osx", "x86_64") :
					mongo_download("osx", "i386")
				mongo_install("darwin")
			when /mingw|mswin/
				Display.msg "IMPORTANT: curl must be installed and on $PATH."
				RUBY_PLATFORM =~ /x86_64/ ?
					mongo_download("win32", "x86_64") :
					mongo_download("win32", "i386")
				mongo_install("mswin")
			end
		end
	end
end

# CHECK FOR BASIC CONFIG STRUCTURE METHOD
# TODO: Might need to implement a few changes here for Windows.
def configure_esearchy
  #Check & create folders
  unless File.exists?((ENV["HOME"] + "/.esearchy").gsub("/",@slash))
    Display.msg "Running for the first time."
    Display.msg "Generating environment"
    system(("mkdir " + ENV["HOME"] + "/.esearchy").gsub("/",@slash))
  end
  unless File.exists?((ENV["HOME"] + "/.esearchy/config").gsub("/",@slash))
  	File.open((ENV['HOME'] + "/.esearchy/config").gsub("/",@slash), "w" ) do |line|
      # A few defaults. Although this can all be overwritten at runtime. 
      line << " { \"maxhits\" : 1000,\n"
      line << " \"yahookey\" : \"AwgiZ8rV34Ejo9hDAsmE925sNwU0iwXoFxBSEky8wu1viJqXjwyPP7No9DYdCaUW28y0.i8pyTh4\",\n" 
      line << "\"bingkey\" : \"220E2E31383CA320FF7E022ABBB8B9959F3C0CFE\",\n"
      line << "\"dburl\" : \"localhost\",\n"
	    line << "\"dbport\" : 27017,\n"
      line << " \"dbname\" : \"esearchy\"\n }"
	end
  end
  unless File.exists?((ENV["HOME"] + "/.esearchy/data").gsub("/",@slash))
    system(("mkdir " + ENV["HOME"] + "/.esearchy/data").gsub("/",@slash))
    unless File.exists?((ENV["HOME"] + "/.esearchy/data/db").gsub("/",@slash))
      system(("mkdir " + ENV["HOME"] + "/.esearchy/data/db").gsub("/",@slash))
    end
  end
  unless File.exists?((ENV["HOME"] + "/.esearchy/plugins").gsub("/",@slash))
    system(("mkdir " + ENV["HOME"] + "/.esearchy/plugins").gsub("/",@slash))
  end
  unless File.exists?((ENV["HOME"] + "/.esearchy/logs").gsub("/",@slash))
    system(("mkdir " + ENV["HOME"] + "/.esearchy/logs").gsub("/",@slash))
  end
end


#gem_available? "sinatra"
gem_available? "mongo"
gem_available? "bson_ext"
gem_available? "mongo_mapper"
#gem_available? "restclient"
gem_available? 'json'
gem_available? 'zip'
#gem_available? 'uri'
#gem_available? 'pdf_reader'
gem_available? 'nokogiri'
gem_available? 'readline-history-restore'
gem_available? 'spidr'


Display.msg "Installing mongodb"
mongo_install?

Display.msg "Setup esearchy initial configuration"
configure_esearchy

if RUBY_PLATFORM =~ /mingw|mswin/
	Display.msg "Installing mongodb as service"
	mongo_install_service
end



