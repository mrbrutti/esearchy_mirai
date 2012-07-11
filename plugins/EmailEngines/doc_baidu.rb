# module ESearchy  
#   module EmailEngines
#     class Baidu < ESearchy::BasePlugin
#       include ESearchy::Helpers::Search
#       include ESearchy::Parsers::Email
#       include ESearchy::Parsers::Document

#       ESearchy::PLUGINS[self.name.split("::")[-1].downcase] = self
      

#       def initialize(options={}, &block)
#         @info = {
#           #This name should be the class name
#           :name => "Baidu",
#           :desc => "Parses Baidu Filetype:xxx Searches for emails addresses that match query within the documents.",
#           # URL/page,data of engine or site to parse
#           :engine => "www.baidu.com",
#           :help => "",
#           :author => "Matias P. Brutti <FreedomCoder>", 
#           # Port for request
#           :port => 80,
#           # Max number of searches per query. 
#           # This is usually the max entries for most search engines.
#           :num => 100,
#           #TYPE 1 searches emails / TYPE 2 Searches people / TYPE 3 Profiling and Operations with data.
#           :type => 1
#         }
#         @options[:filetype] = ""
#         super options
#       end
      
#       def run
#         if @options[:query] != "" && @options[:filetype] != ""
#           @options[:query] += " " + @options[:filetype]
#           Display.msg "[ '+' => New, '=' => Existing ]"
#           search_engine { parse baidu }
#         else
#           Display.error "Needo to provide a query. (i.e. @company.com)." if @options[:query] != ""
#           Display.error "Needo to provide a filetype. (i.e. docx,pdf,txt,etc)." if @options[:filetype] != ""
#         end
#       end
            
#       def parse( results )
#         ts = []
#         results.each do |result|
#           ts << Thread.new {
#             begin
#               emails_in_doc(result[:url]).each do |correo|
#                 if correo.match(/.*@*\.#{@options[:query].gsub(/.*\@/,"")}/) != nil || correo.match(/.*@#{@options[:query].gsub(/.*\@/,"")}/) !=nil
#                   if email_exist?(@project.emails, correo)
#                     @project.emails << Email.new({:email => correo, :url => result[:url], :found_by => @info[:name]})
#                     @project.save!
#                     Display.msg "[Baidu] + " + correo
#                   else
#                     Display.msg "[Baidu] = " + correo
#                   end
#                 end
#               end
#             rescue Exception => e
#               Display.debug "Something went wrong." + e
#             end
#           }
#           ts.each {|t| t.join }
#         end
#       end
#     end
#   end
# end