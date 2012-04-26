module ESearchy
	module UI
		module Common
	    def load_default_templates
	    	Display.msg "Loading Plugins..."
	  	  Dir[File.expand_path File.dirname(__FILE__) + "../../../../plugins/**/*.*"].each do |t|
	  	    load t
	  	    Display.debug "Loading Plugin [ #{t.split("/")[-1].split(".rb")[0]} ]"
	  	  end
	  	  Display.msg "Successfully Loaded Plugins"
	  	end

	  	def load_custom_templates
	  		Display.msg "Loading Custom Plugins..."
	  	  Dir[ENV["HOME"] + "/.esearchy/plugins/**/*.*"].each do |t|
	  	    load t
	  	    Display.debug "Loading Custom Plugin [ #{t.split("/")[-1].split(".rb")[0]} ]"
	  	  end
	  	  Display.msg "Successfully Loaded Custom Plugins"
	  	end

	  	def read_config
	  	  Display.msg "Loading Global configurations"
	  	  begin
	  	  	$globals = JSON.parse(File.read(ENV["HOME"] + "/.esearchy/config"), :symbolize_names => true)
	  	  rescue Exception => e
	  	  	Display.error "There was an error loading the json file. Please check and try again. " + e
	  	  	exit(0)
	  	  end
	  	end
	  end
	end
end


