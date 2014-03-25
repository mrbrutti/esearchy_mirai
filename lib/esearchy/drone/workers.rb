require 'resque'
require_relative "../../esearchy"

$hostname = `hostname`.strip

# - [review] - Just in case I DB.connect, but not 100% sure if I need it. Here need to test
ESearchy::DB.connect
include ESearchy::UI::Common

# Load Plugins.
load_default_templates
load_custom_templates

class PluginWorker
	include ESearchy
	@queue = :plugin
	@@PLUGINS = ESearchy::PLUGINS

	def self.plugins
		@@PLUGINS
	end

	def self.reload_plugins
		load_default_templates
		load_custom_templates
	end

	def self.symbolize_keys(h)
    Hash[h.map{ |k, v| [k.to_sym, v] }]
	end

	def self.perform(options)
		begin
	  	start_time = Time.now
	  	pid = "#{options['pname']}_#{start_time.to_i}"
	  	running_context = plugins[options['pname']].new symbolize_keys(options['options'])
	  	# Add run State to plugin.
	  	run_state = PluginRun.new  :hostname => $hostname,
	  							   :plugin 	=> running_context.nombre, 
	  							   :status 	=> "RUNNING",
	  							   :options => running_context.options,
	  							   :project => running_context.options[:name],
	  							   :error => nil, 
	  							   :error_details => nil,
	  							   :created_at => start_time,
	  							   :thread_id => pid
	  	run_state.save

	  	#run the plugin :)
	    running_context.run
	    
	    # Add successful_db_state to plugin.
	    run_state.stop_at = Time.now
	    if running_context.options[:error] != nil
	    	run_state.status = "FAILED"
	    	run_state.error = running_context.options[:error]
			run_state.error_details = running_context.options[:error_details]
	    else
	    	run_state.status = "DONE"
	    end
	    run_state.save
	    running_context.options[:error] = nil
	    running_context.options[:error_details] = nil
		rescue Exception => e
			if run_state == nil
		  	run_state = PluginRun.new(:hostname => $hostname,
							   :plugin 	=> plugins[options['pname']].name.split("::")[-1], 
							   :status 	=> "FAILED",
							   :options => options['options'],
							   :project => options['name'],
							   :error => e.to_s, 
							   :error_details => e.backtrace.join("\n"),
							   :created_at => start_time,
							   :thread_id => pid)
				run_state.save
			else
				run_state.status = "FAILED"
				run_state.stop_at = Time.now
				run_state.error = e.to_s
				run_state.error_details = e.backtrace.join("\n")
				run_state.save
			end
			# Display erro
			Display.error "Something went wrong running the plugin. #{e}"
			Display.backtrace e.backtrace
		end
	end
end