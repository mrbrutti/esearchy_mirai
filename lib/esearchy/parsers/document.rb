class PageTextReceiver
   attr_accessor :content

   def initialize
     @content = []
   end

   # Called when page parsing starts
   def begin_page(arg = nil)
     @content << ""
   end

   # record text that is drawn on the page
   def show_text(string, *params)
     @content.last << string.strip
   end

   # there's a few text callbacks, so make sure we process them all
   alias :super_show_text :show_text
   alias :move_to_next_line_and_show_text :show_text
   alias :set_spacing_next_line_show_text :show_text

   # this final text callback takes slightly different arguments
   def show_text_with_positioning(*params)
     params = params.first
     params.each { |str| show_text(str) if str.kind_of?(String)}
   end
end

module ESearchy
	module Parsers
		module Document
			def emails_in_doc(url)
				#download
				#case type
				return emails
			end


			# Private methods to manage documents. 
			private
			# Handle PDF files. 
			def pdf(name)
	      begin
	        receiver = PageTextReceiver.new
	        pdf = PDF::Reader.file(name, receiver)
	        search_emails(receiver.content.inspect)
	      rescue PDF::Reader::UnsupportedFeatureError
	        Display.warn "Encrypted PDF - Unable to parse."
	      rescue PDF::Reader::MalformedPDFError
	        Display.warn "Malformed PDF - Unable to parse."
	      rescue
	        Display.error "Unknown error - Unable to parse."
	      end
	    end

			# Handle containers with xml files (i.e docx, xlsx, .pages, .numbers, etc.)
			def xml(name)
		  	begin
		     	Zip::ZipFile.open(name) do |zip|
		      	text = z.entries.each { |e| zip.file.read(e.name) if e.name =~ /.xml$/}
		      	search_emails(text)
		      end
		    rescue
		    	Display.erro "Unknown error - Unable to parse"
		    end
		  end
			
			# handles anything that can be readable on plain_text
			def plain(name)
      	search_emails(File.open(name).readlines.to_s)
    	end
			
			# This is basically for old school .doc documents.
			def doc(name)
      	if RUBY_PLATFORM =~ /mingw|mswin/
        	begin
          	word(name)
        	rescue
          	antiword(name)
        	end
      	elsif RUBY_PLATFORM =~ /linux|darwin/
        	begin
          	antiword(name)
        	rescue
          	Display.error "Error: Unable to parse .doc"
        	end
      	else
        	Display.error "Error: Platform not supported."
      	end
      end

			def word(name)
      	word = WIN32OLE.new('word.application')
      	word.documents.open(name)
      	word.selection.wholestory
      	search_emails(word.selection.text.chomp)
      	word.activedocument.close( false )
      	word.quit
    	end

    	def antiword(name)
        if File.exists?($globals[:antiword])
         	search_emails(`#{ANTIWORD_WIN} "#{name}" -f -s`)
      	else
      		Display.warn "Antiword not found. Parsing word as plain text."
         	# This ///G h e t t o/// but, for now it works on emails that do not contain Capital letters:).
					# Last resort, but hey it might fish something worth it.
         	search_emails(File.open(name).readlines[0..19].to_s)
      	end
    	end
		end
	end
end