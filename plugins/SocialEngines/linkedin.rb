module ESearchy  
  module SocialEngines
    class LinkedIn < ESearchy::BasePlugin
      include ESearchy::Helpers::Search
      include ESearchy::Parsers::People

      ESearchy::PLUGINS[self.name.split("::")[-1].downcase] = self
      

      def initialize(options={}, &block)
        @info = {
          #This name should be the class name
          :name => "LinkedIn",
          :desc => "Parses LinkedIn using Google Searches that match.",
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
          :type => 2
        }
        super options
      end
      
      def run
        if @options[:company] != ""
          @options[:query] = "site%3Awww.linkedin.com/pub+in+%22at+" + CGI.escape(@options[:company])
          Display.msg "[ '+' => New, '<' => Updated, '=' => Existing ]"
          search_engine do
            parse google
          end
        else
          Display.error "Needo to provide a company name."
        end
      end
            
      def parse( results )
        ts = []
        results.each do |result|
          ts << Thread.new {
          begin
            name_last = result[:title].scan(/[\w\s]* \|/)[0]
            if name_last != nil && name_last != " |"
              name_last = name_last.gsub(/profile[s]*/i,"").gsub("|","").strip.split(" ")
              name = name_last.first
              last = name_last.last
              if (name.strip != "" || last.strip != "") && (name != nil || last != nil) 
                if result[:url].match(/http[s]*:\/\/www.linkedin.com\/pub\//) != nil
                  info = linkedin(result[:url])
                  if info[:company].downcase == @options[:company].downcase
                    new_empl = @project.persons.where(:name => name, :last => last)
                    if new_empl.size == 0 
                      employee = Person.new 
                      employee.name = name
                      employee.last = last
                      employee.created_at = Time.now
                      employee.found_by = @info[:name]
                      employee.found_at = result[:url]
                      employee.networks << Network.new({:name => "LinkedIn", :url => result[:url], :nickname => name+last, :info => info, :found_by => @info[:name]})
                      @project.persons << employee
                      @project.save
                      Display.msg "[LinkedIn] + " + name + " " + last
                    else
                      employee = new_empl.first
                      if networks_exist?(employee.networks, "LinkedIn")
                        Display.msg "[LinkedIn] < " + name + " " + last
                        employee.networks << Network.new({:name => "LinkedIn", :url => result[:url], :nickname => name+last, :info => info, :found_by => @info[:name]})
                        employee.found_by << @info[:name]
                        employee.save!
                        @project.save
                      else
                        Display.msg "[LinkedIn] = " + name + " " + last
                      end
                    end
                  end
                end
              end
            end
          rescue Exception => e
            Display.debug "Something went wrong." + e
          end
        }
        ts.each {|t| t.join }
        end
      end
    end
  end
end