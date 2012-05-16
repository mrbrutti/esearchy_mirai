module ESearchy  
  module EmailEngines
    class Spider < ESearchy::BasePlugin
      include ESearchy::Parsers::Email

      ESearchy::PLUGINS[self.name.split("::")[-1].downcase] = self
      

      def initialize(options={}, &block)
        @info = {
          #This name should be the class name
          :name => "Spider",
          :desc => "Spiders a website for emails addresses that match query",
          #TYPE 1 searches emails / TYPE 2 Searches people / TYPE 3 Profiling and Operations with data.
          :author => "Matias P. Brutti <FreedomCoder>", 
          :type => 1
        }
        options[:url] ||= ""
        super options
      end
      
      def run
        if @options[:query] != ""
          Display.msg "[ '+' => New, '=' => Existing ]"
          if @options[:url] != ""
            Spidr.site(@options[:url]) do |spider|
              spider.every_page do |page|
                Display.debug "Parsing #{page.url}"
                parse page.url, page.body
              end
            end
          else
            Display.error "Needo to provide a url Page. (i.e. http://www.example.com/test.html)."
          end
        else
          Display.error "Needo to provide a query. (i.e. @company.com)."
        end
      end
            
      def parse( url, text )
        begin
          emails_in_text(text).each do |correo|
            correo.downcase!
            if correo.match(/.*@*\.#{@options[:query].gsub(/.*\@/,"")}/) != nil || correo.match(/.*@#{@options[:query].gsub(/.*\@/,"")}/) !=nil
              if email_exist?(correo)
                @project.emails << Email.new({:email => correo, :url => url, :found_by => @info[:name]})
                @project.save!
                Display.msg "[Spider] + " + correo
              else
                Display.msg "[Spider] = " + correo
              end
            end
          end
        rescue Exception => e
          Display.debug "Something went wrong parsing an email" + e
        end
      end
    end
  end
end