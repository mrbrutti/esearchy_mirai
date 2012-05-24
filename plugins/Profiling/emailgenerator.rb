module ESearchy  
  module Profiling
    class EmailGenerator < ESearchy::BasePlugin

      ESearchy::PLUGINS[self.name.split("::")[-1].downcase] = self
      

      def initialize(options={}, &block)
        @info = {
          #This name should be the class name
          :name => "EmailGenerator",
          :desc => "Parses Gathering information (name & lastname) to generate emails for a specific domain",
          :help => "",
          :author => "Matias P. Brutti <FreedomCoder>",
          # URL/page,data of engine or site to parse
          :num => 100,
          #TYPE 1 searches emails / TYPE 2 Searches people / TYPE 3 Profiling and Operations with data.
          :type => 3
        }
        
        #specific options 
        options[:length_n] = "0..-1" # specify a range.
        options[:length_l] = "0..-1" # specify a range. 
        options[:spliter] = "" # spliter is used to specify divider between name and lastname i.e. name.last@domain.com
        options[:first] = "NAME"

        super options
      end
      
      def run
        begin
          if @project.persons != nil
            @options[:length_n] = eval(@options[:length_n]) # convert 2 range.
            @options[:length_l] = eval(@options[:length_l]) # convert 2 range. 
            if @options[:domain] != ""
              if @options[:length_n].class == Range && @options[:length_l].class == Range          
                @project.persons.each do |person|
                  Display.msg "[Generating email] - " + person.name + " " + person.last
                  if @options[:first] == "NAME"
                    email = person.name[@options[:length_n]] + @options[:spliter] + person.last[@options[:length_l]] + "@"  + @options[:domain]
                  elsif @options[:first] == "LAST"
                    email = person.name[@options[:length_l]] + @options[:spliter] + person.last[@options[:length_n]] + "@"  + @options[:domain]
                  else
                    raise "Non supported :first option [#{@options[:first]}]"
                  end 
                  if email_exist?(email)
                    Display.msg "[EmailGenerator] + " + email
                    person.emails << Email.new({ :email => email, :url => person.found_at, :found_by => @info[:name] })
                    person.save!
                    person.save
                    @project.save
                  else
                    Display.msg "[EmailGenerator] = " + email
                  end
                end
              else
                Display.error "Either name or last options are not a proper range."
              end
            else
              Display.error "Needo to provide a domain"
            end
          end
        rescue Exception => e
          Display.error "Something went wrong. #{e}" 
        end
      end
    end
  end
end