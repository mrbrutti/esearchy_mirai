module ESearchy  
  module SocialEngines
    class Ziggs < ESearchy::BasePlugin
      include ESearchy::Helpers::Search
      include ESearchy::Parsers::People

      ESearchy::PLUGINS[self.name.split("::")[-1].downcase] = self
      

      def initialize(options={}, &block)
        @info = {
          #This name should be the class name
          :name => "Ziggs",
          :desc => "Parses Ziggs using Google Searches that match.",
          # URL/page,data of engine or site to parse
          :engine => "www.google.com",
          # Port for request
          :help => "",
          :author => "Matias P. Brutti <FreedomCoder>", 
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
          @options[:query] = "site%3Aziggs.com%2Fbackground%2F+Company%3A*" + CGI.escape(@options[:company])

          Display.msg "[ '+' => New, '<' => Updated, '=' => Existing ]"
          search_engine { parse google }
        else
          Display.error "Needo to provide a company name"
        end
      end

      private
      def parse( results )
        Display.debug "Parsing #{results.size} for Ziggs data."
        results.each do |result|
            begin
              name_last = result[:title].scan(/[\w\s]* -/)[0]
              if name_last != nil && name_last != " |"
                name_last = name_last.strip.split(" ")
                name = name_last.first
                last = name_last.last
                if (name.strip != "" || last.strip != "") && (name != nil || last != nil) 
                  if result[:url].match(/http[s]*:\/\/www.ziggs.com\/Background\//i) != nil
                    info = ziggs(result[:url])
                    if info[:company] != nil
                      if info[:company].downcase == @options[:company].downcase
                        new_empl = @project.persons.where(:name => name, :last => last)
                        if new_empl.size == 0 
                          employee = Person.new 
                          employee.name = name
                          employee.last = last
                          employee.created_at = Time.now
                          employee.updated_at = Time.now
                          employee.found_by = @info[:name]
                          employee.found_at = result[:url]
                          employee.networks << Network.new({:name => "Ziggs", :url => result[:url], 
                                                            :nickname => result[:url].split("regId=")[1], 
                                                            :info => info, :created_at => Time.now})
                          if info[:links] != []
                            parse_links(info[:links]).each {|x| employee.networks << x }
                          end
                          @project.persons << employee
                          @project.save
                          Display.msg "[Ziggs] + " + name + " " + last
                        else
                          employee = new_empl.first
                          if networks_exist?(employee.networks, "Ziggs")
                            Display.msg "[Ziggs] < " + name + " " + last
                            employee.networks << Network.new({:name => "Ziggs", :url => result[:url], 
                                                              :nickname => result[:url].split("regId=")[1], 
                                                              :info => info, :created_at => Time.now})

                            if info[:links] != []
                              parse_links(info[:links]).each {|x| employee.networks << x }
                            end
                            employee.found_by << @info[:name]
                            employee.save!
                            @project.save
                          else
                            Display.msg "[Ziggs] = " + name + " " + last
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

      def parse_links(links)
        ts = []
        links.each do |key,value|
          ts << Thread.new {
            case key
            when /linkedin/i
              networks << Network.new({:name => "LinkedIn", 
                                       :url => value, 
                                       :nickname => name+last, 
                                       :info => linkedin(value), 
                                       :found_by => @info[:name]})
            when /spoke/i
              networks << Network.new({:name => "Spoke", 
                                       :url => value, 
                                       :nickname => name+last, 
                                       :info => spoke(value), 
                                       :found_by => @info[:name]})
            when /classmate/i
              networks << Network.new({:name => "Classmates", 
                                       :url => value, 
                                       :nickname => result[:url].split("regId=")[1], 
                                       :info => classmates(result[:url]), 
                                       :found_by => @info[:name]})
            when /twitter/i
              networks << Network.new({:name => "Twitter", 
                                       :url => value, 
                                       :nickname => value.split("/").last, 
                                       :info => {}, 
                                       :found_by => @info[:name]})
            when /plaxo/i
              networks << Network.new({:name => "Plaxo", 
                                       :url => value, 
                                       :nickname => value.split("/").last, 
                                       :info => {}, 
                                       :found_by => @info[:name]}) 
            when /Google [Profile|plus]*/i
              networks << Network.new({:name => "GooglePlus", 
                                       :url => value, 
                                       :nickname => value.split("/").last, 
                                       :info => {}, 
                                       :found_by => @info[:name]})
            else
              # We do not yet parse this network. 
            end
          }
          ts.each {|t| t.join }

        end
        return networks
      end
    end
  end
end