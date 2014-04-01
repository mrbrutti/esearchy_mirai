esearchy_mirai
==============

Esearchy 0.3 Codename: Mirai. This is a complete re-write from esearchy-ng. 

This is where I should put the interesting how-to info, but for now.

SETUP THE ENVIRONMENT:

```bash
ruby setup.rb

cd bin

./esearchy 
```

and enjoy


# Development

## Sample script
```ruby
module ESearchy  
  # This is mainly to separate plugins into catogagories. Current ones are
  # SearchEngines
  # LocalEngines
  # SocialEngines
  # ProfilingEngines
  # OtherEngines

  module SearchEngines 
    class SamplePlugin < ESearchy::BasePlugin
      include ESearchy::Helpers::Search
      # This is a must in order to declare your plugin on the plugin list. 
      ESearchy::PLUGINS[self.name.split("::")[-1].downcase] = self
      
      def initialize(options={}, &block)
        @info = {
          #This name should be the class name
          :name => "SamplePlugin",
          :desc => "Enables sample engine searches",
          # URL/page,data of engine or site to parse
          :engine => "sampleengine.com",
          # Port for request
          :port => 80,
          # Max number of searches per query. 
          # This is usually the max entries for most search engines.
          :num => 100,
          #TYPE 1 searches emails / TYPE 2 Searches people / TYPE 3 Profiling and Operations with data.
          :type => 1
        }
        super options
      end

      # This is usually handled by the GenericEngine, but it can be overwritten. 
      # Having said that, a few things should be respected in order to work. 
      # first parameter is query, 
      # Second is start, 
      # Third is stop or desired maxhits. 
      # Fourth is a block. In case client wants to do something in instance. 
      
      def run
        # What you want the code to actually run.
        # There are a few automated methods:
        # search(query)
        Display.msg "nothng"
        @options[:query] = "@xxx.com"
        p search
        # 
      end
      
    end
  end
end
```

In order to develop new features for esearchy here are a few things to take into account.

## Objects

## Company object
```json 
{
    "_id" : ObjectId(),
    "type" : "company",
    "name" : "Company XYZ",
    "url" : "http://company.xyz",
    "nickname" : "xyz",
    "queries" : [ "Company XYZ", "XYZ Company", "XYZ Inc" ],
    "created_at" : Date( 1362512104822 ),
    "updated_at" : Date( 1362512104822 )
}
```

## Person object
```json
{
    "_id" : ObjectId(),
    "project_id" : ObjectId(),
    "name" : "Matias",
    "last" "Brutti",
    "networks" : [
        {
            "_id" : ObjectId(),
            "name" : "LinkedIn",
            "nickname" : "NameLast"
            "found_by" : "LinkedIn"
            "info" : {
                "name" : "",
                "last" : "",
                "location" : "",
                "company" : "",
                "title" : "",
                "education" : ""
                "abc" : "123",
            }
        }
    ]
    "created_at" : Date( 1362512104822 ),
    "updated_at" : Date( 1362512104822 )
}
```

#Networks
The network objects contain a _url_ where it was found, a _nickname_ for the person network, where it was found _found\_by_ , the usual timestamps (created_at,updated_at) and most importantly _info_ which contains all of the specific network fields as it is shown on the screenshot below. 
```json
{
    "_id" : ObjectId(),
    "url" : "http://xxx.com",
    "nickname" : "NameLast",
    "found_by" : "LinkedIn"
    "info" : {
        "name" : "",
        "last" : "",
        "location" : "",
        "company" : "",
        "title" : "",
        "education" : ""
        "abc" : "123",
    }
    "created_at" : Date( 1362512104822 ),
    "updated_at" : Date( 1362512104822 )
}
```

#Emails
```json
{
    "_id" : ObjectId(),
    "url" : "http://xxx.com",
    "email" : "NameLast",
    "found_by" : "LinkedIn"
    "created_at" : Date( 1362512104822 ),
    "updated_at" : Date( 1362512104822 )
}
```

#Documents
```json
{
    "_id" : ObjectId(),
    "url" : "http://xxx.com",
    "format" : "pdf",
    "name" : "NameLast",
    "found_by" : "LinkedIn"
    "created_at" : Date( 1362512104822 ),
    "updated_at" : Date( 1362512104822 )
}
```

#Drones
```json
{ 
    "_id" : ObjectId( "513e44aec1806b7691000001" ),
    "hostname" : "https://localhost:9999",
    "name" : "poruto",
    "password" : "WeWillChangeThistoBeATokenSoon",
    "username" : "WeWillChangeThistoBeATokenSoon" 
}
```

#Plugin History
```json
{ 
    "_id" : ObjectId( "513648e8c1806b83d7000006" ),
    "plugin" : "SocialProfiling",
    "status" : "DONE",
    "created_at" : Date( 1362512104822 ),
    "stop_at" : Date( 1362512116975 ),
    "options" : { 
        "name" : "yahoo",
        "domain" : "http://www.yahoo.com",
        "url" : "http://www.yahoo.com",
        "start" : 0,
        "stop" : 1000,
        "company" : "Yahoo!, Inc",
        "results" : 1000 
        },
    "project" : "yahoo" 
}
```
