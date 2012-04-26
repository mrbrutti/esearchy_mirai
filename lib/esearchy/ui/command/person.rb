module ESearchy
	module UI
		module CommandParser
			#
			# Command: Person meta command method
			# Description: Dispatcher for person commands.
			#		
			def cmd_person(args)
				begin
					sub_cmd = args[0]
					run_cmd("person_#{sub_cmd}", args[1..-1])
				rescue Exception => e
					Display.debug "Something went wrong running the command."
				end 
			end

			#
			# Command: person search
			# Description: This should show globals options, instance options, plugin options.
			# and plugion constants
			#
			def cmd_person_search(args)
				begin
					if args == []
						Display.error "We need a query"
					else 
						if @options[:name] != nil
							results = Project.find_by_name(@options[:name]).persons.where(JSON.parse(args[0..-1].join(" "), :symbolize_names => true))
							if results.size == 0
								Display.msg "No person was found with that name."
							elsif results.size == 1
								#puts JSON.pretty_generate(JSON.parse(results.first.to_json))
								show_person results.first
								#Display.hash JSON.parse(results.first.to_json, :symbolize_names => true)
							else
								#results.each {|x| puts JSON.pretty_generate(JSON.parse(x.to_json)) }
								results.each {|x| show_person x }
							end
						else
							Display.error "No open Project"
						end
					end
				rescue Exception => e
					Display.debug "Something went wrong running the command." + e
				end
			end

								

			#
			# Command: person search and delete.
			# Description: Should allow you to search and then delete a specific or multiple persons.
			# and plugion constants
			#
			def cmd_person_delete(args)
				begin
					if args == []
						Display.error "A mongo query is needed [i.e. {'name' : 'test'}"
					else 
						if @options[:name] != nil
							results = Project.find_by_name(@options[:name]).persons.where(JSON.parse(args[0..-1].join(" "), :symbolize_names => true))
							if results.size == 0
								Display.msg "No person was found."
							else
								#Show persons
								results.all.each {|x| show_person x }
								#Confirm delete.
								Display.warn "Do you want to delete #{results.size} selected persons? [yes/no]"
      					if $stdin.gets.strip == "yes"
									results.all.each {|x| x.delete() }
								end
							end
						else
							Display.error "No open Project."
						end
					end
				rescue Exception => e
					Display.debug "Something went wrong running the command." + e
				end
			end
			#
			# Command: helper to display person information. 
			# Description: This should show globals options, instance options, plugin options.
			# and plugion constants
			#
			private
			def show_person(person)
				Display.msg "\e[31mName:\e[0m #{person.name}#{" #{person.middle}"} \e[31mLast:\e[0m #{person.last}"
				Display.print "\e[33mCreated:\e[0m #{person.created_at}"
				Display.print "\e[33mFound by:\e[0m #{person.found_by}"
				Display.print "\e[33mFound in:\e[0m #{person.found_at}"
				Display.print "\e[33mEmails:\e[0m "
				person.emails.each do |email|
					Display.print "\t#{email}"
				end
				Display.print "\e[33mNetworks:\e[0m "
				person.networks.each do |network|
					Display.print "\t\e[33mName:\e[0m #{network.name}\t\e[33mUrl:\e[0m  #{network.url}"
					Display.print "\t\e[33mTitle\e[0m #{network.info[:title]}" if network.info[:title] != nil
					Display.print "\t\e[33mFound by:\e[0m #{network.found_by}"
					Display.print ""
				end
			end
		end
	end
end