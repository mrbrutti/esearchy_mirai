module ESearchy  
  module EmailEngines
    class Google < ESearchy::BasePlugin
      include ESearchy::Helpers::Search
      include ESearchy::Parsers::Email

      ESearchy::PLUGINS[self.name.split("::")[-1].downcase] = self
      

      def initialize(options={}, &block)
        @info = {
          #This name should be the class name
          :name => "Google",
          :desc => "Parses Google Searches for emails addresses that match query",
          # URL/page,data of engine or site to parse
          :engine => "www.google.com",
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
        super options
      end
      
      def run
        if @options[:query] != ""
          Display.msg "[ '+' => New, '=' => Existing ]"
          search_engine do
            parse google
          end
          return true
        else
          Display.error "Needo to provide a query. (i.e. @company.com)."
          return false
        end
      end
            
      def parse( results )
        #ts = []
        results.each do |result|
          #ts << Thread.new {
            begin
              Display.debug "--> Parsing <" + result[:url] + ">"
              emails_in_text(result[:content]).concat(emails_in_url(result[:url])).each do |correo|
                correo.downcase!
                if correo.match(/.*@*\.#{@options[:query].gsub(/.*\@/,"")}/) != nil || correo.match(/.*@#{@options[:query].gsub(/.*\@/,"")}/) !=nil
                  add_email correo, result[:url]
                end
              end
            rescue Exception => e
              Display.debug "Something went wrong parsing an email" + e
            end
          #}
          #ts.each {|t| t.join }
          return nil
        end
      end
    end
  end
end