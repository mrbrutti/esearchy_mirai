module ESearchy  
  module IODate
    class Export < ESearchy::BasePlugin
      ESearchy::PLUGINS[self.name.split("::")[-1].downcase] = self
      

      def initialize(options={}, &block)
        @info = {
          #This name should be the class name
          :name => "Export",
          :desc => "Parses PGP server results for emails addresses that match query",
          # URL/page,data of engine or site to parse
          :help => "",
          :author => "Matias P. Brutti <FreedomCoder>", 
          #TYPE 5 Handling import/Export Data
          :type => 5
        }
        options[:output]
        super options
      end
      
      def run
        begin 
          if @project != nil
            case @options[:output]
            when /csv/i then
            when /html/i then
              @project.emails.each do |email|
                #
              end
              @project.person.each do |person|
                #
              end
            else
              Display.error "Output type not supported."
            end
          else
            Display.error "Needo to provide a project. (i.e. > project open xyz)."
          end
        rescue Exception => e
          handle_error :error => e
        end
      end
    end
  end
end