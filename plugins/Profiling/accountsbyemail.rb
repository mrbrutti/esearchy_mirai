module ESearchy  
  module Profiling
    class AccountsByEmail < ESearchy::BasePlugin
    	

      ESearchy::PLUGINS[self.name.split("::")[-1].downcase] = self
      

      def initialize(options={}, &block)
        @info = {
          #This name should be the class name
          :name => "AccountsByEmail",
          :desc => "Checks multiple sites and checks wether or not the email is regitered on the site.",
          :help => "",
          :author => "Matias P. Brutti <FreedomCoder>",
          # URL/page,data of engine or site to parse
          :num => 100,
          #TYPE 1 searches emails / TYPE 2 Searches people / TYPE 3 Profiling and Operations with data.
          :type => 3
        }
        options[:email] = ""
        super options
      end
      
      def run
        begin
      		discover @project.emails
        rescue Exception => e
          handle_error :error => e
        end
			end

			private
			def discover(emails)
				emails.each do |email|
      		results = {}
					(ESearchy::Helpers::Discover.public_methods - Object.methods).each do |site|
            if ESearchy::Helpers::Discover.send(site, email[:email])
              Display.msg "[#{@info[:name]}] - Email => #{email[:email]} has an account in #{site[0..-2]}"
						   results[site[0..-2]] = 1
            else
              Display.debug "[#{@info[:name]}] - Email => #{email[:email]} has NO account in #{site[0..-2]}"
            end 
					end
					email[:sites] = results
          email.save!
				end
			  @project.save
      end
		end
	end
end

