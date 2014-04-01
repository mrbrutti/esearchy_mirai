require 'readline'
require 'readline/history/restore'  unless RUBY_PLATFORM =~ /mingw|mswin/


module ESearchy
	module UI
		class	Console
			include ESearchy::UI::Common
			include ESearchy::UI::CommandParser

			def initialize(options={})
	  		# declare running_context
	  		$running_context = self
	  		@project = nil
	  		@options ||= {:name => "", :domain => "", :url => "", :start => 0, :stop => $globals[:maxhits], :company => ""}
	  		# Load templates from Base and custom directories
	  		load_default_templates
	  		load_custom_templates
	  		# read configuration into memory.
	  		read_config
	  		ESearchy::DB.start
	  		ESearchy::DB.connect

	  		# Merge list of auto-complete commands with plugin name list to easy of use. 
	  		common_commands = %w{project new open save close help use run options set} + 
	  		                  %w{back exit show options globals constants edit list load } +
	  		                  %w{name domain url company person name middle last email emails } + 
	  		                  %w{persons start stop nickname format export}
	  		ESearchy::PLUGINS.each_key {|p| common_commands << p}
        Project.all.each {|x| common_commands << x['name']}

	  		comp = proc do |s| 
	        case s
	        when /^\/|\\/ then
	          Dir[s+'*'].grep( /^#{Regexp.escape(s)}/ )
	        else
	          common_commands.grep( /^#{Regexp.escape(s)}/ )
	        end
	      end

	      Readline.completion_append_character = " "
	      Readline.completion_proc = comp
        Readline::History::Restore.new(ENV["HOME"] + "/.esearchy/.esearchy_console_history", :history_limit => 100)  unless RUBY_PLATFORM =~ /mingw|mswin/

  		end
      attr_accessor :options

      def nombre
      	""
      end
      
  		def run
  			Display.logo
  			trap("INT") { exit_app }
      	while true do
      		parse_line prompt
      	end
  		end
  	  
  		private
  		def parse_line(cmd)
  		  unless cmd == nil || cmd == ""
  				args = cmd.split(" ")
  				command = args[0]
  				parameters = args[1..-1] == [] ? nil : args[1..-1]
  				run_cmd(command, parameters)
				end
  		end

      def project_context
        if @project !=nil
          " [\e[34m#{@project.name}\e[0m]"
        end
      end

  		def context
        if $running_context.nombre != ""
    			" (\e[31m#{$running_context.nombre}\e[0m)"
        end
  		end

      def self.back
        self
      end
      
      def info
        {}
      end

  		def prompt
      	return Readline.readline(Display.underline + "esy" + Display.default + "#{project_context}#{context} > ", true).strip
    	end
    end
  end
end