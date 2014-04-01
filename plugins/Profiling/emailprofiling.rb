module ESearchy  
  module Profiling
    class EmailProfiling < ESearchy::BasePlugin
      include ESearchy::Helpers::Search
      include ESearchy::Parsers::Email

      ESearchy::PLUGINS[self.name.split("::")[-1].downcase] = self
      

      def initialize(options={}, &block)
        @info = {
          #This name should be the class name
          :name => "EmailProfiling",
          :desc => "Parses Google Searches to find emails for a specific 'Name Last + Company'",
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
          :type => 3
        }
        super options
      end
      
      def run
        @options[:stop] = 100
        if @project.persons != nil
          if @options[:company] != ""
            @project.persons.each do |person|
              @options[:start] = 0
              @options[:query] = CGI.escape(person.name + " " + person.last + " at " + @options[:company])
              Display.msg "[EmailProfiling] - " + person.name + " " + person.last
              search_engine do
                google.each do |result|
                  begin
                   emails_in_text(result[:content]).each do |correo|
                      correo.downcase!
                      if correo.match(/.*@*\.#{@options[:query].gsub(/.*\@/,"")}/) != nil || correo.match(/.*@#{@options[:query].gsub(/.*\@/,"")}/) !=nil
                        if email_exist?(correo)
                          person.emails << Email.new({:email => correo, :url => result[:url], :found_by => @info[:name], :created_at => Time.now})
                          @project.save!
                          Display.msg "[EmailProfiling] + " + correo
                        else
                          Display.msg "[EmailProfiling] = " + correo
                        end
                      end
                    end
                  rescue Exception => e
                    handle_error :error => e
                  end
                end
              end
              person.save!
              person.save
              @project.save
            end
          else
            Display.error "Needo to provide a company name"
          end
        end
      end
    end
  end
end