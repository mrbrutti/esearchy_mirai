require 'zip/zip'
require 'open-uri'
require 'zip/zipfilesystem'
require 'pdf/reader'

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
			def emails_in_doc(url,filetype)
        d = Doc.new({:url => google_url?(url), :filetype => filetype})
        d.download
        d.process
        d.delete
        Display.debug "EMAILS -----"
        Display.debug d.emails.map {|x| x + "  "}
        Display.debug "EMAILS -----"
        return d.emails
			end

      private

      def google_url?(url)
        if url.match(/google.com\/url\?/) != nil
          Display.debug("New Url: " + CGI.unescape(url.scan(/url=(.*)&ei=/).to_s))
          return CGI.unescape url.scan(/url=(.*)&ei=/).to_s
        else
          Display.debug("Url: " + url)
          return url
        end
      end

      class Doc
        case RUBY_PLATFORM 
        when /mingw|mswin/
          TEMP = "C:\\WINDOWS\\Temp\\"
        else
          TEMP = "/tmp/"
        end

        def initialize(options)
          @url = options[:url]
          if options[:filetype] !=nil
            @filetype = options[:filetype]
          else
            @filetype = filetype_detector()
          end
          @filename = nil
          @emails = nil
        end
        attr_reader :emails

        #
        # Download and & save.
        #
        def download
          data = open(@url).read
          @filename = save_to_disk(data)
        end

        #
        # based on Filetype search
        #
        def process
          case @filetype
          when /pdf/i
            @emails = pdf()
          when /txt|rtf|ans|html|xml|json|sql/i
            @emails = plain()
          when /doc/i
            @emails = doc()
          when /docx|xlsx|pptx|odt|odp|ods|odb/i
            @emails =  xml()
          else
            @emails = plain()
          end
          nil
        end
                
        #
        # Remove the file. 
        #
        def delete
          if @filename != nil
            `rm "#{@filename}"`
          end
        end
        

        private
        #
        # Filetype detection.
        #
        def filetype_detector
          case @url
          when /.pdf/i then
            "PDF"
          when /.doc/i then 
            "DOC"
          when /.txt/i then
            "TXT"
          when /.rtf/i then
            "RTF"
          when /.ans/i then
            "ANS"
          when /.html$/i then
            "HTML"
          when /.xml$/i then
            "XML"
          when /.json/i then
            "JSON"
          when /.sql/i  then
            "SQL"
          when /.docx/i then
            "XLSX"
          when /.xlsx/i then
            "XLSX"
          when /.pptx/i then
            "PPTX"
          when /.odt/i  then
            "ODT"
          when /.odp/i  then
            "ODP"
          when /.ods/i  then
            "ODS"
          when /.odb/i  then
            "ODB"
          else
            Display.debug "Format #{format} not supported."
            return "TXT"
          end
        end

        #
        # Save url to /tmp or c:/windows/temp
        #
        def save_to_disk(data)
          name = TEMP + "/" + hash_url(@url).to_s + "." + @filetype.downcase
          open(name, "wb") { |file| file.write(data) }
          name
        end

        #
        # Generate Hash to save file with unique URL 
        # and use a time stamp to prevent overwrites.
        #
        def hash_url(url)
          Digest::SHA2.hexdigest("#{Time.now.to_f}--#{url}")
        end

        #
        # Process PDF files using default PDF library. Not perfect but works.
        #
        def pdf
          begin
            receiver = PageTextReceiver.new
            pdf = PDF::Reader.file(@filename, receiver)
            return search_emails(receiver.content.inspect)
          rescue PDF::Reader::UnsupportedFeatureError
            Display.error "Encrypted PDF - Unable to parse."
          rescue PDF::Reader::MalformedPDFError
            Display.error "Malformed PDF - Unable to parse."
          rescue
            Display.error "Unknown error - Unable to parse."
          end
        end

        #
        # Process zip files with xml such as:
        # i.e docx, xlsx, .pages, .numbers, etc.
        #
        def xml
          begin
            text = ""
            emails = []
            Zip::ZipFile.open(@filename) do |zip|
              zip.entries.each { |e| text << zip.file.read(e.name) if e.name =~ /.xml$/}
              emails.concat(search_emails(text.to_s))
            end
            return emails
          rescue
            Display.error "Unknown error - Unable to parse"
            return emails
          end
        end
        
        #
        # Process plain text.
        #
        def plain
          return search_emails(File.open(@filename).readlines.to_s)
        end
        
        #
        # Meta-Process word 97/98 documents.
        # Using several methods. 
        #
        def doc
          if RUBY_PLATFORM =~ /mingw|mswin/
            begin
              word
            rescue
              antiword
            end
          elsif RUBY_PLATFORM =~ /linux|darwin/
            begin
              antiword
            rescue
              Display.error "Error: Unable to parse .doc"
            end
          else
            Display.error "Error: Platform not supported."
          end
        end

        #
        # Process Word 97/98 Documents using MSWord.
        #
        def word
          word = WIN32OLE.new('word.application')
          word.documents.open(@filename)
          word.selection.wholestory
          emails = search_emails(word.selection.text.chomp)
          word.activedocument.close( false )
          word.quit
          return emails
        end

        #
        # Process Word 97/98 using Antiword
        #
        def antiword
          if File.exists?($globals[:antiword])
            return search_emails(`#{ANTIWORD_WIN} "#{@filename}" -f -s`)
          else
            Display.debug "Antiword not found. Parsing word as plain text."
            # This ///G h e t t o/// but, for now it works on emails that do not contain Capital letters:).
            # Last resort, but hey it might fish something worth it.
            return search_emails(File.open(name).readlines[0..19].join)
          end
        end

        def search_emails(text)
          Display.debug "parse_emails_in_doc " + @filename
          emails = text.scan(/[a-z0-9!#$&'*+=?^_`{|}~-]+(?:\.[a-z0-9!#$&'*+=?^_`{|}~-]+)*_at_\
(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z](?:[a-z-]*[a-z])?|\
[a-z0-9!#$&'*+=?^_`{|}~-]+(?:\.[a-z0-9!#$&'*+=?^_`{|}~-]+)*\sat\s(?:[a-z0-9](?:[a-z0-9-]\
*[a-z0-9])?\.)+[a-z](?:[a-z-]*[a-z])?|[a-z0-9!#$&'*+=?^_`{|}~-]+\
(?:\.[a-z0-9!#$&'*+=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z](?:[a-z-]*[a-z])?|\
[a-z0-9!#$&'*+=?^_`{|}~-]+(?:\.[a-z0-9!#$&'*+=?^_`{|}~-]+)*\s@\s(?:[a-z0-9](?:[a-z0-9-]*\
[a-z0-9])?\.)+[a-z](?:[a-z-]*[a-z])?|[a-z0-9!#$&'*+=?^_`{|}~-]+(?:\sdot\s[a-z0-9!#$&'*+=?^_`\
{|}~-]+)*\sat\s(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\sdot\s)+[a-z](?:[a-z-]*[a-z])??/i)
          if emails != nil
            emails.each do |e|
              e.gsub!("_at_","@")
              e.gsub!(" at ","@")
              e.gsub!(" dot ",".")
              e.gsub!(/[+0-9]{0,3}[0-9()]{3,5}[-]{0,1}[0-9]{3,4}[-]{0,1}[0-9]{3,5}/,"")
            end
            #Display.debug emails.map {|x| x + "  "}
            return emails
          else
            return []
          end
        end
      end		
		end
	end
end