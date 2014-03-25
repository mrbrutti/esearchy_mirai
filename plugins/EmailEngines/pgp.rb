module ESearchy  
  module EmailEngines
    class PGP < ESearchy::BasePlugin
      include ESearchy::Parsers::Email

      ESearchy::PLUGINS[self.name.split("::")[-1].downcase] = self
      

      def initialize(options={}, &block)
        @info = {
          #This name should be the class name
          :name => "PGP",
          :desc => "Parses PGP server results for emails addresses that match query",
          # URL/page,data of engine or site to parse
          :engine => "pgp.mit.edu",
          # Port for request
          :help => "",
          :author => "Matias P. Brutti <FreedomCoder>", 
          :port => 11371,
          # Max number of searches per query. 
          # This is usually the max entries for most search engines.
          :num => 100,
          #TYPE 1 searches emails / TYPE 2 Searches people / TYPE 3 Profiling and Operations with data.
          :type => 1
        }
        super options
      end
      
      def run
        begin 
          if @options[:query] != "" && @options[:query] != nil
            Display.msg "[ '+' => New, '=' => Existing ]"
            url = "http://#{@info[:engine]}:#{@info[:port]}/pks/lookup?search=" + CGI.escape(@options[:query])
            emails_in_url(url).each do |correo|
              correo.downcase!
              if correo.match(/.*@*\.#{@options[:query].gsub(/.*\@/,"")}/) != nil || correo.match(/.*@#{@options[:query].gsub(/.*\@/,"")}/) !=nil
                add_email correo, url
              end
            end
          else
            Display.error "Needo to provide a query. (i.e. @company.com)."
          end
        rescue Exception => e
          handle_error :error => e, :message => "Something went wrong parsing an email"
        end
      end
    end
  end
end