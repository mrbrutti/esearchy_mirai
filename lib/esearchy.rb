#Internal requires
require 'rubygems'
require 'net/http'
require 'cgi'
require 'uri'
require 'digest/sha2'
require 'command_line_reporter'

#External Gems
require 'json'
require 'zip/zip'
require 'zip/zipfilesystem'
#require 'pdf/reader'
require 'mongo_mapper'
require 'spidr'

# Windows dependency for parsing word. 
if RUBY_PLATFORM =~ /mingw|mswin/
 require 'win32ole'
 require 'win32console'
end

PATH ||= 'esearchy/'
#ESEARCHY REQUIRES
['db/db', 'db/redis','db/mapper', 'helpers/display', 'helpers/useragent', 'helpers/search','esearchy', 'baseplugin',
  'ui/common', 'ui/commandparser', 'ui/command/project', 'ui/command/person','ui/console', 'parsers/people', 
  'parsers/email', 'parsers/document', 'helpers/discover'].each {|x| require_relative PATH + x }


# Monkey Patching to shorten timeout of open uri
# Short timeout in Net::HTTP
module Net
    class HTTP
        alias old_initialize initialize

        def initialize(*args)
            old_initialize(*args)
            @read_timeout = 4  # 2 seconds
        end
    end
end

require 'iconv' unless String.method_defined?(:encode)

def encode_string( s )
  if String.method_defined?(:encode)
    s.encode!('UTF-16', 'UTF-8', :invalid => :replace, :replace => '')
    s.encode!('UTF-8', 'UTF-16')
  else
    ic = Iconv.new('UTF-8', 'UTF-8//IGNORE')
    s = ic.iconv(s)
  end
  return s
end


module OpenURI
  def OpenURI.redirectable?(uri1, uri2) # :nodoc:
    uri1.scheme.downcase == uri2.scheme.downcase ||
    (/\A(?:https?|ftp)\z/i =~ uri1.scheme && /\A(?:https?|ftp)\z/i =~ uri2.scheme)
  end
end
