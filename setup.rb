require 'rubygems'
require 'lib/esearchy/helpers/display.rb'

VERSION="2.0.3"

def gem_available?(name)
   Gem::Specification.find_by_name(name)
rescue Gem::LoadError
   Display.msg "esearchy requires #{name}."
   system "sudo gem install #{name}"
end

def mongo_download(os,platform)
	Display.msg "Downloading mongodb-#{os}-#{platform}-#{VERSION}.tgz"
	system("curl http://fastdl.mongodb.org/osx/mongodb-#{os}-#{platform}-#{VERSION}.tgz > external/mongodb.tgz")
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
		Display.error "WINDOWS USERS HAVE TO MANNUALLY DECOMPRESS AND MOVE mongodb.tgz into external/mongdb"
		Display.error "SORRY: if you want to do it and send me a patch you are welcomed."
	end
end

def mongo_install?
	unless File.exists? File.expand_path File.dirname(__FILE__) + "external"
		system("mkdir external")
		unless File.exists? File.expand_path File.dirname(__FILE__) + "external/mongodb"
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

def configure_esearchy
  #Check & create folders
  unless File.exists? ENV["HOME"] + "/.esearchy"
    Display.msg "Running for the first time."
    Display.msg "Generating environment"
    system("mkdir " + ENV["HOME"] + "/.esearchy")
  end
  unless File.exists? ENV["HOME"] + "/.esearchy/config"
  	File.open(ENV['HOME'] + "/.esearchy/config", "w" ) do |line|
      # A few defaults. Although this can all be overwritten at runtime. 
      line << " { \"maxhits\" : 1000,\n"
      line << " \"yahookey\" : \"AwgiZ8rV34Ejo9hDAsmE925sNwU0iwXoFxBSEky8wu1viJqXjwyPP7No9DYdCaUW28y0.i8pyTh4\",\n" 
      line << "\"bingkey\" : \"220E2E31383CA320FF7E022ABBB8B9959F3C0CFE\",\n"
      line << "\"dburl\" : \"localhost\",\n"
	    line << "\"dbport\" : 27017,\n"
      line << " \"dbname\" : \"esearchy\"\n }"
	end
  end
  unless File.exists? ENV["HOME"] + "/.esearchy/data"
    system("mkdir " + ENV["HOME"] + "/.esearchy/data")
    unless File.exists? ENV["HOME"] + "/.esearchy/data/db"
      system("mkdir " + ENV["HOME"] + "/.esearchy/data/db")
    end
  end
  unless File.exists? ENV["HOME"] + "/.esearchy/plugins"
    system("mkdir " + ENV["HOME"] + "/.esearchy/plugins")
  end
  unless File.exists? ENV["HOME"] + "/.esearchy/logs"
    system("mkdir " + ENV["HOME"] + "/.esearchy/logs")
  end
end

Display.msg "-<[ ESearchy 0.3 CodeName Miata ]>-"
Display.msg "-<[ Setup and Configurations script ]>-"

Display.msg "Missing Gem installation"
gem_available? "sinatra"
gem_available? "mongo"
gem_available? "bson_ext"
gem_available? "mongo_mapper"
#gem_available? "restclient"
gem_available? 'json'
gem_available? 'zip'
#gem_available? 'uri'
gem_available? 'pdf_reader'
gem_available? 'nokogiri'
gem_available? 'readline-history-restore'
gem_available? 'spidr'

if  RUBY_PLATFORM =~ /mingw|mswin/
  gem_available? 'win32console'
end

Display.msg "Installing mongodb"
mongo_install?

Display.msg "Setup esearchy initial configuration"
configure_esearchy


