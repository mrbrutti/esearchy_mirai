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