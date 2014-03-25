module ESearchy  
  module Profiling
    class SocialProfiling < ESearchy::BasePlugin
      include ESearchy::Helpers::Search
      include ESearchy::Parsers::People

      ESearchy::PLUGINS[self.name.split("::")[-1].downcase] = self
      

      def initialize(options={}, &block)
        @info = {
          #This name should be the class name
          :name => "SocialProfiling",
          :desc => "Parses results and uses Google Searches to match and add other possible profiles",
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

      def add_network(network_name, person, nick, url, &block)
        if networks_exist?(person.networks, network_name)
          block.nil? ? info = {} : info = block.call
          if info[:company] == @options[:company]
            person.networks << Network.new({:name => network_name, 
                                            :url => result[:url],  
                                            :nickname => nick, 
                                            :info => info, 
                                            :found_by => @info[:name]}) 
            Display.msg "[SocialProfiling] - ++ #{network_name}"
            person.save
          end
        else
          Display.debug "[SocialProfiling] - == #{network_name}"
        end
      end

      def run
        @options[:stop] = 100
        if @project.persons != nil
          if @options[:company] != ""
            @project.persons.each do |person|
              @options[:start] = 0
              @options[:query] = CGI.escape(person.name + " " + person.last + " at " + @options[:company])
              Display.msg "[SocialProfiling] - " + person.name + " " + person.last
              search_engine do
                engine.each do |result|
                  begin
                    # Uncomment if you want to use Baidu search engine. 
                    #if @options[:engine] == "baidu"
                    #  result[:url] = Net::HTTP.new("www.baidu.com", 80).request_head("/link?" + result[:url].split("/link?") )['location']
                    #end
                    case result[:url]
                    when /linkedin.com/i
                      add_network("LinkedIn", person, person.name + "_" + person.last, result[:url] ) { linkedin(result[:url]) }
                    when /spoke.com/i
                      add_network("Spoke", person, person.name + "_" + person.last, result[:url] ) { spoke(result[:url]) }
                    when /http[s]*:\/\/www.classmates.com\/[directory|people]*\//i
                      add_network("Classmates", person, result[:url].split("regId=")[1], result[:url] ) { classmates(result[:url]) }
                    when /twitter.com/i
                      add_network("Twitter", person, result[:url].split("/").last, result[:url] ) { twitter(result[:url]) }
                    when /plaxo.com/i
                      add_network("Plaxo", person, result[:url].split("/").last, result[:url] )
                    when /plus.google.com|profiles.google.com/i
                      add_network("GooglePlus", person, result[:url].split("/").last, result[:url] ) { googleplus(result[:url]) }
                    when /facebook.com/i
                      add_network("Facebook", person, result[:url].split("/").last, result[:url] )
                    when /ziggs.com/i
                      add_network("Ziggs", person, result[:url].split("/").last, result[:url] ) { ziggs(result[:url]) }
                    when /xing.com/i
                      add_network("Xing", person, result[:url].split("/").last, result[:url] )
                    else
                      Display.debug "Currently not parting #{result[:url]}"
                    end
                  rescue Exception => e
                    Display.error "Something went wrong with #{person.name + " " + person.last}" + e.to_s
                  end
                end
              end
              # Temporarily off until I can find a practical way of encoding this to UTF-8.
              # I've tried many things but mongodb keeps on failing when trying to save it. ARGHHH !!!!
              person.save(:validate => true)

              begin 
                person[:interestinglinks] = google[0..25]
                person.save(:validate => true)
              rescue
                Display.error "[SocialProfiling] - Interesting Links save action failed. UTF-8 Not suported."
              end
              
            end
          else
            handle_error :error => e
          end
        end
      end
    end
  end
end