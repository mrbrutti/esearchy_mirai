 module ESearchy  
   module EmailEngines
     class BaiduDoc < ESearchy::BasePlugin
       include ESearchy::Helpers::Search
       include ESearchy::Parsers::Email
       include ESearchy::Parsers::Document

       ESearchy::PLUGINS[self.name.split("::")[-1].downcase] = self
     

       def initialize(options={}, &block)
         @info = {
           #This name should be the class name
           :name => "BaiduDoc",
           :desc => "Parses Bing Searches for emails addresses that match query within a specific doc type",
           # URL/page,data of engine or site to parse
           :engine => "www.baidu.com",
           :help => "",
           :author => "Matias P. Brutti <FreedomCoder>",           
           # Port for request
           :port => 80,
           # Max number of searches per query. 
           # This is usually the max entries for most search engines.
           :num => 100,
           #TYPE 1 searches emails / TYPE 2 Searches people / TYPE 3 Profiling and Operations with data.
           :type => 1
         }
         options[:filetype] ||= ""
         super options
       end
     
       def run
       	if @options[:filetype] != ""
					if @options[:query] != ""
            query_temp = @options[:query]
						@options[:query] << "%20filetype:" + @options[:filetype]
			      Display.msg "[ '+' => New, '=' => Existing ]"
			      search_engine do
			      	parse baidu
			      end
            @options[:query] = query_temp
			    else
			    	Display.error "Needo to provide a query. (i.e. @company.com)."
            @options[:query] = query_temp
			    end
			  else
			  	Display.error "Needo to provide a filetype. (i.e. PDF,DOCX,TXT,etc)."
          @options[:query] = query_temp
			  end
       end
           
       def parse( results )
         ts = []
         results.each do |result|
           ts << Thread.new {
             begin
               Display.debug "--> Parsing <" + result[:url] + ">"
               emails_in_text(result[:content]).concat(emails_in_doc(result[:url], @options[:filetype])).each do |correo|
                 correo.downcase!
                 if correo.match(/.*@*\.#{@options[:query].split("%20")[0].gsub(/.*\@/,"")}/) != nil || correo.match(/.*@#{@options[:query].split("%20")[0].gsub(/.*\@/,"")}/) !=nil
                  add_email correo, result[:url]
                 end
               end
             rescue Exception => e
               Display.debug "Something went wrong parsing an email" + e
             end
           }
         end
         ts.each {|t| t.join }
       end
     end
   end
 end