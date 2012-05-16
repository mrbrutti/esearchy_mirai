module ESearchy  
  module Profiling
    class SocialProfiling < ESearchy::BasePlugin
      include ESearchy::Helpers::Search
      include ESearchy::Parsers::Email

      ESearchy::PLUGINS[self.name.split("::")[-1].downcase] = self
      

      def initialize(options={}, &block)
        @info = {
          #This name should be the class name
          :name => "SocialProfiling",
          :desc => "Parses Ziggs using Google Searches that match.",
          # URL/page,data of engine or site to parse
          :engine => "www.google.com",
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
              #p person.networks
              @options[:start] = 0
              @options[:query] = CGI.escape(person.name + " " + person.last + " at " + @options[:company])
              Display.msg "[SocialProfiling] - " + person.name + " " + person.last
              search_engine do
                google.each do |result|
                  begin
                    case result[:url]
                    when /linkedin.com/i
                      if networks_exist?(person.networks, "LinkedIn")
                        person.networks << Network.new({:name => "LinkedIn", :url => result[:url],  :nickname => person.name+person.last, :info => linkedin(result[:url]), :found_by => @info[:name]}) 
                        Display.msg "-\t< LinkedIn"
                      end
                    when /spoke.com/i
                      if networks_exist?(person.networks, "Spoke")
                        info = spoke(result[:url])
                        if info[:company] == @options[:company]
                          person.networks << Network.new({:name => "Spoke", :url => result[:url],  :nickname => person.name+person.last, :info => info, :found_by => @info[:name]})
                          Display.msg "-\t< Spoke"
                        end
                      end
                    when /http[s]*:\/\/www.classmates.com\/[directory|people]*\//i
                      if networks_exist?(person.networks, "Classmates")
                        info = classmates(result[:url])
                        if info[:company] == @options[:company]
                          person.networks << Network.new({:name => "Classmates", :url => result[:url], :nickname => result[:url].split("regId=")[1], :info => info, :found_by => @info[:name]})
                          Display.msg "-\t< Classmates"
                        end
                      end
                    when /twitter.com/i
                      if networks_exist?(person.networks, "Twitter")
                        person.networks << Network.new({:name => "Twitter", :url => result[:url], :nickname => result[:url].split("/").last, :info => twitter(result[:url]), :found_by => @info[:name]})
                        Display.msg "-\t< Twitter"
                      end
                    when /plaxo.com/i
                      if networks_exist?(person.networks, "Plaxo")
                        person.networks << Network.new({:name => "Plaxo", :url => result[:url],  :nickname => result[:url].split("/").last, :info => {}, :found_by => @info[:name]})
                        Display.msg "-\t< Plaxo"
                      end
                    when /plus.google.com|profiles.google.com/i
                      if networks_exist?(person.networks, "GooglePlus")
                        person.networks << Network.new({:name => "GooglePlus", :url => result[:url],  :nickname => result[:url].split("/").last, :info => googleplus(result[:url]), :found_by => @info[:name]})
                        Display.msg "-\t< GooglePlus"
                      end
                    when /facebook.com/i
                      if networks_exist?(person.networks, "Facebook")
                        person.networks << Network.new({:name => "Facebook", :url => result[:url], :nickname => result[:url].split("/").last, :info => {}, :found_by => @info[:name]})
                        Display.msg "-\t< Facebook"
                      end
                    when /ziggs.com/i
                      if networks_exist?(person.networks, "Ziggs")
                        if info[:company] == @options[:company]
                          person.networks << Network.new({:name => "Ziggs", :url => result[:url], :nickname => result[:url].split("/").last, :info => ziggs(result[:url]), :found_by => @info[:name]})
                          Display.msg "-\t< Ziggs"
                        end
                      end
                    when /xing.com/i
                      if networks_exist?(person.networks, "Xing")
                        person.networks << Network.new({:name => "Xing", :url => result[:url], :nickname => result[:url].split("/").last, :info => {}, :found_by => @info[:name]})
                        Display.msg "-\t< Xing"
                      end
                    else
                      Display.debug "Currently not parting #{result[:url]}"
                    end
                  rescue Exception => e
                    Display.error "Something went wrong with #{person.name + " " + person.last}" + e
                  end
                end
              end
              person[:interestinglinks] = google[0..25]
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