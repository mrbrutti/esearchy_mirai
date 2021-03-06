module ESearchy  
  module SocialEngines
    class Spoke < ESearchy::BasePlugin
      include ESearchy::Helpers::Search
      include ESearchy::Parsers::People

      ESearchy::PLUGINS[self.name.split("::")[-1].downcase] = self
      

      def initialize(options={}, &block)
        @info = {
          #This name should be the class name
          :name => "Spoke",
          :desc => "Parses Spoke using Google Searches that match.",
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
          @options[:query] = "site%3Awww.spoke.com+%22at+" + CGI.escape(@options[:company])
          Display.msg "[ '+' => New, '<' => Updated, '=' => Existing ]"
          search_engine { parse google }
        else
          Display.error "Needo to provide a company name"
        end
      end
      
      private
      def parse( results )
        results.each do |result|
          begin
            name_last = result[:title].scan(/[\w\s]*,/)[0]
            if name_last != nil && name_last != " |"
              name_last = name_last.gsub(/[profiles*|,]*/i,"").strip.split(" ")
              name = name_last[0]
              last = name_last[1]
              if (name != nil || last != nil)
                if (name.strip != "" || last.strip != "") 
                  if result[:url].match(/http[s]*:\/\/www.spoke.com\/info\//) != nil
                    info = spoke(result[:url])
                    if info[:company] != nil
                      Display.debug "Checking company" + info[:company].downcase + "<=>" + @options[:company].downcase
                      if info[:company].downcase == @options[:company].downcase
                        Display.debug "Adding" + info[:name] + " " + info[:last]
                        new_empl = @project.persons.where(:name => info[:name], :last => info[:last])
                        if new_empl.size == 0 
                          employee = Person.new 
                          employee.name = info[:name]
                          employee.last = info[:last]
                          employee.created_at = Time.now
                          employee.updated_at = Time.now
                          employee.found_by = @info[:name]
                          employee.found_at = result[:url]
                          employee.networks << Network.new({:name => "Spoke", :url => result[:url], 
                                                            :nickname => info[:name]+info[:last], 
                                                            :info => info, :found_by => @info[:name],
                                                            :created_at => Time.now})
                          @project.persons << employee
                          @project.save
                          Display.msg "[Spoke] + " + info[:name] + " " + info[:last]
                        else
                          employee = new_empl.first
                          if networks_exist?(employee.networks, "Spoke")
                            Display.msg "[Spoke] < " + info[:name] + " " + info[:last]
                            employee.networks << Network.new({:name => "Spoke", :url => result[:url], 
                                                              :nickname => info[:name]+info[:last], 
                                                              :info => info, :found_by => @info[:name],
                                                              :created_at => Time.now})
                            employee.found_by << @info[:name]
                            employee.save!
                            @project.save
                          else
                            Display.msg "[Spoke] = " + info[:name] + " " + info[:last]
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          rescue Exception => e
            handle_error :error => e
          end
        end
        return nil
      end
    end
  end
end