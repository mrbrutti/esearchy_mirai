module ESearchy  
  module SocialEngines
    class Classmates < ESearchy::BasePlugin
      include ESearchy::Helpers::Search
      include ESearchy::Parsers::People

      ESearchy::PLUGINS[self.name.split("::")[-1].downcase] = self
      

      def initialize(options={}, &block)
        @info = {
          #This name should be the class name
          :name => "Classmates",
          :desc => "Parses Classmates using Google Searches that match.",
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
          @options[:query] = "site%3Awww.classmates.com+%22work+at+" + 
                              CGI.escape(@options[:company]) + 
                              "%22+%7C%7C+%22work+for+" + 
                              CGI.escape(@options[:company]) + "%22" 

          Display.msg "[ '+' => New, '<' => Updated, '=' => Existing ]"
          search_engine { parse google }
        else
          Display.error "Needo to provide a company name"
        end
      end
      
      def parse( results )
        results.each do |result|
          begin
            name_last = result[:title].scan(/[\w\s]* \|/)[0]
            if name_last != nil && name_last != " |"
              name_last = name_last.gsub(/profile[s]*/i,"").gsub("|","").strip.split(" ")
              name = name_last[0]
              last = name_last[1]
              if (name.strip != "" || last.strip != "") && (name != nil || last != nil) 
                if result[:url].match(/http[s]*:\/\/www.classmates.com\/[directory|people]*\//) != nil
                  info = classmates(result[:url])
                  if info[:company] != nil
                    if info[:company].downcase == @options[:company].downcase
                      new_empl = @project.persons.where(:name => name, :last => last)
                      if new_empl.size == 0 
                        employee = Person.new 
                        employee.name = name
                        employee.last = last
                        employee.created_at = Time.now
                        employee.found_by = @info[:name]
                        employee.found_at = result[:url]
                        employee.networks << Network.new({:name => "Classmates", :url => result[:url], 
                                                          :nickname => result[:url].split("regId=")[1], :info => info, :found_by => @info[:name]})
                        @project.persons << employee
                        @project.save
                        Display.msg "[Classmates] + " + name + " " + last
                      else
                        employee = new_empl.first
                        if networks_exist?(employee.networks, "Classmates")
                          Display.msg "[Classmates] < " + name + " " + last
                          employee.networks << Network.new({:name => "Classmates", :url => result[:url], 
                                                            :nickname => result[:url].split("regId=")[1], :info => info, :found_by => @info[:name]})
                          employee.found_by << @info[:name]
                          employee.save!
                          @project.save
                        else
                          Display.msg "[Classmates] = " + name + " " + last
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