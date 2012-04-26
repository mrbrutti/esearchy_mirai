#Internal requires
require 'rubygems'
require 'net/http'
require 'cgi'
require 'uri'
require 'digest/sha2'


#External Gems
require 'json'
require 'zip/zip'
require 'zip/zipfilesystem'
require 'pdf/reader'
require 'mongo_mapper'
require 'spidr'

# Windows dependency for parsing word. 
if RUBY_PLATFORM =~ /mingw|mswin/
 require 'win32ole'
 require 'win32console'
end

PATH = '../lib/esearchy/'
#ESEARCHY REQUIRES
['db/db','db/mapper', 'helpers/display', 'helpers/useragent', 'helpers/search','esearchy', 'baseplugin',
  'ui/common', 'ui/commandparser', 'ui/command/project', 'ui/command/person','ui/console', 'parsers/people', 'parsers/email'].each {|x| require PATH + x }


# Monkey Patching to shorten timeout of open uri
# Short timeout in Net::HTTP
module Net
    class HTTP
        alias old_initialize initialize

        def initialize(*args)
            old_initialize(*args)
            @read_timeout = 2  # 2 seconds
        end
    end
end
