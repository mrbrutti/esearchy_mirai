module ESearchy  
  module StateEngines
    class SecOfState < ESearchy::BasePlugin
      include ESearchy::Parsers::Email

      ESearchy::PLUGINS[self.name.split("::")[-1].downcase] = self
      

      def initialize(options={}, &block)
        @info = {
          #This name should be the class name
          :name => "SecOfState",
          :desc => "Parses Secretary of State information looking for Company Information",
          # URL/page,data of engine or site to parse
          :engine => "www.sos.wa.gov",
          # Port for request
          :help => "",
          :author => "Matias P. Brutti <FreedomCoder>", 
          #TYPE 1 searches emails / TYPE 2 Searches people / TYPE 3 Profiling and Operations with data / TYPE 4 Company info.
          :type => 4
        }
        super options
      end
      
      def run
        begin 
          if @options[:company] != "" 

            Display.msg "Please Choose one option: "

          else
            Display.error "Needo to provide a query. (i.e. @company.com)."
          end
        rescue Exception => e
          Display.debug "Something went wrong parsing an email" + e
        end
      end

      def search_name(company_name)
      	
      end

      def search_UBI(ubi_id)
      	
      end
    end
  end
end


# Also add another plugin for EDGAR http://www.sec.gov/edgar/searchedgar/companysearch.html
# This plugin should concentrate in obtaining corporate state information in US.
# http://www.coordinatedlegal.com/SecretaryOfState.html
# WA json API --> http://www.sos.wa.gov/corps/SearchAPI.aspx
# SAMPLE:
# Request: http://www.sos.wa.gov/corps/search_results.aspx?name_type=starts_with&name=IOActive&format=json
# Response: 
# { "UBI": "603015809", "BusinessName": "IOACTIVE LABS, LLC" },{ "UBI": "602038563", "BusinessName": "IOACTIVE, INC." }
# Request: http://www.sos.wa.gov/corps/search_detail.aspx?ubi=602038563&format=json
# Response: 
# {
#    "entity": {
#        "BusinessName": "IOACTIVE, INC.",
#        "UBI": "602038563",
#        "Category": "REG",
#        "Type": "Profit",
#        "Active": "Active",
#        "StateOfIncorporation": "WA",
#        "DateOfIncorporation": "05/18/2000",
#        "ExpirationDate": "05/31/2012",
#        "DissolutionDate": "",
#        "Duration": "Perpetual",
#        "RegisteredAgentName": "MARTIN KAMINSKI",
#        "RegisteredAgentAddress": "701 5TH AVE # 6850",
#        "RegisteredAgentCity": "SEATTLE",
#        "RegisteredAgentState": "WA",
#        "RegisteredAgentZip": "98104",
#        "AlternateAddress": "",
#        "AlternateCity": "",
#        "AlternateState": "",
#        "AlternateZip": "",
#        "GoverningPersons": [{
#            "Title": "Officer",
#            "LastName": "STEFFENS",
#            "MiddleName": "",
#            "FirstName": "JENNIFER",
#            "Address": "701 FIFTH AVE # 6850",
#            "City": "SEATTLE",
#            "State": "WA",
#            "Zip": ""
#        },
#        {
#            "Title": "President",
#            "LastName": "PENNELL",
#            "MiddleName": "",
#            "FirstName": "JOSHUA",
#            "Address": "701 FIFTH AVE # 6850",
#            "City": "SEATTLE",
#            "State": "WA",
#            "Zip": ""
#        }]
#    }
#}