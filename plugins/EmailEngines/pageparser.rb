module ESearchy  
  module EmailEngines
    class PageParser < ESearchy::BasePlugin
      include ESearchy::Parsers::Email

      ESearchy::PLUGINS[self.name.split("::")[-1].downcase] = self
      

      def initialize(options={}, &block)
        @info = {
          #This name should be the class name
          :name => "PageParser",
          :desc => "Parses a single page for emails addresses that match query",
          #TYPE 1 searches emails / TYPE 2 Searches people / TYPE 3 Profiling and Operations with data.
          :help => "",
          :author => "Matias P. Brutti <FreedomCoder>",           
          :type => 1
        }
        options[:url] ||= ""
        super options
      end
      
      def run
        if @options[:query] != "" and @options[:query] != nil
          Display.msg "[ '+' => New, '=' => Existing ]"
          if @options[:url] != ""
            parse @options[:url]
          else
            Display.error "Needo to provide a url Page. (i.e. http://www.example.com/test.html)."
          end
        else
          Display.error "Needo to provide a query. (i.e. @company.com)."
        end
      end
            
      def parse( url )
        begin
          emails_in_url(url).each do |correo|
            correo.downcase!
            if correo.match(/.*@*\.#{@options[:query].gsub(/.*\@/,"")}/) != nil || correo.match(/.*@#{@options[:query].gsub(/.*\@/,"")}/) !=nil
              add_email correo, url
            end
          end
        rescue Exception => e
          Display.debug "Something went wrong parsing an email" + e
        end
      end
    end
  end
end