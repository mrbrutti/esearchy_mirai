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