module ESearchy
	module UI
		module CommandParser
			
			#
			# Command: Meta_cmd 
			# Description: This is the meta handler for all commands. 
			#
			def run_cmd(method, arguments)
			  if self.respond_to?("cmd_"+ method)
				self.send("cmd_"+ method, arguments || [])
			  else
			    Display.error "Command #{method.split("_")[-1]} does not exists."
		    end
			end

			def cmd_debug(args)
				begin
					if args != [] || args != nil
						if args[0] == "on"
							$debug = true
						elsif args[0] == "off"
							$debug = false
						end	
					else
						Display.error "Need to provide an option [on|off]"
					end
				rescue Exception => e
					Display.error "Something went wrong running the command."
				end 
			
			end
			
			def cmd_backtrace(args)
				begin
					if args != [] || args != nil
						if args[0] == "on"
							$backtrace = true
						elsif args[0] == "off"
							$backtrace = false
						end	
					else
						Display.error "Need to provide an option [on|off]"
					end
				rescue Exception => e
					Display.error "Something went wrong running the command."
				end 
			
			end

			#
			# Command: use
			# Description: Command to actually open a plugin. 
			#
			def cmd_use(args)
				begin
					# Fetch plugin name. 
					plugin_name = args[0]
					$running_context = ESearchy::PLUGINS[plugin_name.downcase].new(@options.clone)
					# Run the plugin if the run is passed as an argument. 
					$running_context.run if args[1] == "run"
				rescue Exception => e
					$running_context = self
					Display.error "Something went wrong loading the plugin." + e
				end
			end
			
			#
			# Command: run
			# Description: Meta command used to start running a plugin.
			#
			def cmd_run(args)
				begin
				  if $running_context.class == ESearchy::UI::Console
				    Display.error "Not within a plugin. Select one and then run :)"
				  else
				  	# Add run State to plugin.
				  	run_state = PluginRun.new  :hostname => $hostname,
				  							   :plugin 	=> $running_context.nombre, 
				  							   :status 	=> "RUNNING", 
				  							   :options => $running_context.options,
				  							   :project => $running_context.options[:name],
				  							   :error => nil, :error_details => nil,
				  							   :created_at => Time.now 
				  	run_state.save

				  	#run the plugin :)
				    $running_context.run
				    $running_context.options[:start] = 0
				    
				    # Add successful_db_state to plugin.
				    run_state.stop_at = Time.now
				    if $running_context.options[:error] != nil
				    	run_state.status = "FAILED"
				    	run_state.error = $running_context.options[:error]
						run_state.error_details = $running_context.options[:error_details]
				    else
				    	run_state.status = "DONE"
				    end
				    run_state.save
				    $running_context.options[:error] = nil
				    $running_context.options[:error_details] = nil
			    end
				rescue Exception => e
					# Save bad state to DB. 
					run_state.status = "FAILED"
					run_state.stop_at = Time.now
					run_state.error = e.to_s
					run_state.error_details = e.backtrace.join("\n")
					run_state.save
					# Display error
  					Display.error "Something went wrong running the plugin. #{e}"
  					Display.backtrace e.backtrace
  				end
  			end
			#
			# Command: show
			# Description: This should show globals options, instance options, plugin options.
			# and plugion constants
			#
			def cmd_show(args)
				begin
					type = args[0]
				 	case type 
				 	when "globals"
				 		Display.msg "GLOBALS"
				 		#Display.msg "Name\t\tValue"
				 		show_variables $globals, args[1..-1]
					when "options"
						Display.msg "OPTIONS " + "[#{$running_context.nombre}]"
				 		#Display.msg "Name\t\tValue"
						show_variables $running_context.options, args[1..-1]
					when "constants"
				 		Display.msg "CONSTANTS " + "[#{$running_context.nombre}]"
				 		#Display.msg "Name\t\tValue"						
						show_variables $running_context.info, args[1..-1]
					end
				rescue Exception => e
					Display.error "Something went wrong running the command." + e
				end
			end
			
			#
			# Command Show Helper method. 
			#
			def show_variables(options={}, key=[])
				if key == []
					Display.hash(options)
				else
					search_terms = keys.join("|").to_s
					Display.hash(options.select { |k,v| k.to_s.match(/#{search_terms}/i) != nil || v.to_s.match(/#{search_terms}/i) != nil })
				end
			end

			#
			# Command: reload
			# Description: This should reload all of the plugins or globals or both. 
			#
			def cmd_reload(args)
				begin
					if args == nil
						Display.error "Need to provide an argument [globals|plugins]"
					else	
						case args[0]
						when /plugin/i
							load_default_templates
		  				load_custom_templates
						when /global/i
							# Reload Configuration.
							read_config
							# Because Database might have changed.
							# Need to restart and connect. 
							ESearchy::DB.stop
							ESearchy::DB.start
	  					ESearchy::DB.connect
						end
				end
				rescue Exception => e
					Display.error "Something went wrong running the command." + e
				end 
			end

			#
			# Command: help
			# Description: yeap, the almighty help. :)
			#
			def cmd_help(args)
				begin
					Display.msg "HELP"
					if args == nil || args == []
						Display.msg "COMMANDS"
						help_commands
						Display.help "TODO"
						Display.msg "PLUGINS"
						if $running_context.nombre == ""
							sorted = ESearchy::PLUGINS.sort_by { |k,v| v.to_s }
							Display.plugins(sorted)
						else
							$running_context.help
						end
					else
						plugin_name = args[0].downcase
						ESearchy::PLUGINS[plugin_name].new.help
					end
				rescue Exception => e
					Display.error "Something went wrong running the command." + e
				end 
			end

			#
			# Command: help command
			# Description: This meta-class only displays the command tree
			#
			def help_commands()
				Display.help ""
				Display.help "  help <plugin>"
				Display.help ""
				Display.help " 	project"
				Display.help "   |------> new <name>"
				Display.help "   |------> open <name>"
				Display.help "   |------> save"
				Display.help "   |------> close"
				Display.help "   |------> info"
				Display.help "   |------> info [emails|persons]"
				Display.help ""
				Display.help "  use <plugin>"
				Display.help "   |"
				Display.help "   |------> help"
				Display.help "   |------> run"
				Display.help "   |------> show options"
				Display.help "   |------> set <key> <val>"
				Display.help "   |------> back"
				Display.help ""
				Display.help "  show"
				Display.help "   |------> options [key] "
				Display.help "   |------> globals [key]"
				Display.help ""
				Display.help "  set <key> <val>"
				Display.help ""
				Display.help "  search [term|term2]"
				Display.help ""
				Display.help "  edit"
				Display.help "   |------> plugins <name>"
				Display.help "   |------> globals"
				Display.help ""
				Display.help "  list"
				Display.help "   |------> plugins"
				Display.help ""
				Display.help "  reload"
				Display.help "   |------> plugins"
				Display.help ""
				# [ TODO ] Display.help "  export"
				# [ TODO ] Display.help "   |------> html"
				# [ TODO ] Display.help "   |------> pdf"
				# [ TODO ] Display.help "   |------> csv"
				# [ TODO ] Display.help "  search <plugins>"
				# [ TODO ] Display.help "  load <plugin>"
				# [ TODO ] Display.help "  exit"
				Display.help " "
			end
			
			def cmd_list(args)
				begin
					if args == []
						Display.error "Need to provide an argument [plugins]"
					else
						Display.msg "LIST PLUGINS"
						sorted = ESearchy::PLUGINS.sort_by { |k,v| v.to_s }
						Display.plugins(sorted)
					end
				rescue Exception => e
					Display.error "Something went wrong running the command." + e
				end 
			end
			


			#
			# Command: show
			# Description: This should show globals options, instance options, plugin options.
			# and plugion constants
			#
		 	def cmd_search(args)
		 		begin
		 			unless args == []
		 				search_terms = args.join("|").to_s
		 				selected = ESearchy::PLUGINS.select do |k,v| 
		 					k.match(/#{search_terms}/i) != nil || v.new.desc.match(/#{search_terms}/i) != nil 
		 				end
		 				sorted = selected.sort_by { |k,v| v.to_s } 
		 				Display.msg "SEARCH RESULTS"
		 				Display.plugins(sorted)
		 			else
		 				Display.error "Need to provide a search argument [search plugin_name]"
		 			end
		 		rescue Exception => e
		 			Display.error "Something went wrong running the command. " + e
		 		end 
		 	end

			#
			# Command: show
			# Description: This should show globals options, instance options, plugin options.
			# and plugion constants
			#			
			def cmd_edit(args)
				begin
					if args == nil || args == []
						Display.error "Need to provide an argument [globals|plugins]"
					else
						RUBY_PLATFORM =~ /mingw|mswin/ ? slash = "\\" : slash = "/" 
						case args[0]
						when /plugin[s]*/i
							if args.size > 1
								filename = args[1..-1].join(" ").to_s
								if (File.exists? ENV["HOME"] + "/.esearchy/plugins/" + filename).gsub("/",slash)
									filename = (ENV["HOME"] + "/.esearchy/plugins/" + filename).gsub("/",slash)
									system( $globals[:editor] + " " + filename )
									load filename
								else
									Display.error "Files does not exists."
									Display.error "Remember Full path is required."
								end
							end
						when /global[s]*/i
							system( $globals[:editor] + " " + ENV["HOME"] + "/.esearchy/config" )
							read_config
						end
					end
				rescue Exception => e
					Display.error "Something went wrong running the command." + e
				end
			end
			#
			# Command: set
			# Description: This should set instance options, plugin options.
			#
			def cmd_set(args)
				begin
					$running_context.options[args[0].to_sym] = args[1..-1].join(" ")
				rescue Exception => e
					Display.error "Something went wrong running the command." + e
				end
			end

			#
			# Command: back
			# Description: This is used to get out of a plugin and go back to main.
			#
			def cmd_back(args)
				$running_context =  self
			end

			#
			# Command: exit
			# Description: Just a container fo exit_app.
			#
			def cmd_exit(args)
				exit_app
			end

			#
			# Command: exit_app
			# Description: Confirmation method to exit app
			#
			def exit_app
		      	Display.warn "Are you sure you want to quit EMaily? [yes/no] "
		      	if $stdin.gets.strip == "yes"
		      		#Display.warn "Do you want to stop the database? [yes/no] "
		      		#if $stdin.gets.strip == "yes"
		      			ESearchy::DB.stop
		      		#end
		      		$running_context
		      		Kernel.exit(1)
		      	end
      		end
      		
	      	#
	      	# Command: NONE
	      	# This should handle the non-existant methods. 
	      	#
	      	def self.method_missing(method_sym, *arguments, &block)
				Display.error "Command #{method_sym} does not exists."
			end
		end
	end
end