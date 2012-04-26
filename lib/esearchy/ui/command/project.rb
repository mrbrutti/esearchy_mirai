module ESearchy
	module UI
		module CommandParser
			#
			# Command: Project
			# Description: Meta Project command. 
			#			
			def cmd_project(args)
				begin
					sub_cmd = args[0]
					run_cmd("project_#{sub_cmd}", args[1..-1])
				rescue Exception => e
					Display.error "Something went wrong running the command."
				end 
			end

			#
			# Command: Project new
			# Description: Creates a new project.
			#			
			def cmd_project_new(args)
				begin
					if (args == [] || args == nil) && (@options[:name] == nil || @options[:name] == "")
						Display.error "We need a name for the project"
					elsif Project.where({:name => args[0]}).first != nil
						Display.error "Project #{args[0]} already exists."
					else
						@options[:name] = args[0].downcase
						@project = Project.new(@options)
						@project.save
						Display.msg "Successfuly created project #{args[0]}"
					end
				rescue Exception => e
					Display.error "Something went wrong running the command." + e
				end
			end

			#
			# Command: Project open
			# Description: Opens an existing project.
			#			
			def cmd_project_open(args)
				begin
					if args == []
						Display.error "We need a name for the project"
					else 
						project = Project.where({:name => args[0].downcase}).first
						if project != nil
							@options[:name] = args[0].downcase
							@project = project
						else
							Display.error "Project does not exists"
						end
					end
				rescue Exception => e
					Display.error "Something went wrong running the command." + e
				end 
			end

			#
			# Command: Project save
			# Description: Saves the current working project.
			#			
			def cmd_project_save(args)
				begin
					@project.name 		= @options[:name]
					@project.domain 	= @options[:domain]
					@project.url 		= @options[:url]
					@project.company = @options[:company]
					@project.save
				rescue Exception => e
					Display.error "Something went wrong running the command." + e
				end
			end 
			
			#
			# Command: Project open
			# Description: Closes the working project
			#			
			def cmd_project_close(args)
				begin
					@project.save!
					@project = nil
					@options = {:name => "", :domain => "", :url => "", :start => 0, :stop => $globals[:maxhits], :company => ""}
				rescue Exception => e
					Display.error "Something went wrong running the command." + e
				end
			end 

			def cmd_project_delete(args)
				begin
					if args == []
						if @project.nil?
							Display.error "We need a name for the project"
						else
							Display.warn "Do you want to delete the current open project? [yes/no]"
      				if $stdin.gets.strip == "yes"
      					@project.persons.all.each {|x| x.delete() }
      					@project.delete()
      				end
      			end
					else 
						project = Project.where({:name => args[0].downcase}).first
						if project != nil
							Display.warn "Do you want to delete the #{args[0]} project? [yes/no]"
							if $stdin.gets.strip == "yes"
								project.persons.all.each {|x| x.delete() }
      					project.delete()
      				end
						else
							Display.error "Project does not exists"
						end
					end
				rescue Exception => e
					Display.error "Something went wrong running the command." + e
				end
			end


			#
			# Command: Project info
			# Description: Information from current open Project
			#			
			def cmd_project_list(args)
				begin
					Project.all.each do |project|
						Display.msg "PROJECT: #{project.name}"
						Display.print "Employees\t= " + project.persons.size.to_s
						Display.print "Emails\t= " + project.emails.size.to_s
					end
				rescue Exception => e
					Display.error "Something went wrong running the command." + e
				end
			end 

			#
			# Command: Project info
			# Description: Information from current open Project
			#			
			def cmd_project_info(args)
				begin
					if @project != nil
						project = Project.where({:name => @project.name}).first
						if args.empty? || args == nil
							Display.msg "INFORMATION"
							Display.print "\033[33mProject Name\033[0m\t=\t" + project.name
							Display.print "\033[33mDomain\033[0m\t\t=\t" + project.domain
							Display.print "\033[33mWebsite\033[0m\t\t=\t" + project.url
							Display.print "\033[33mCompany Name\033[0m\t=\t" + project.company
							Display.print "\033[33mPersons\033[0m\t\t=\t" + project.persons.size.to_s
							Display.print "\033[33mEmails\033[0m\t\t=\t" + project.emails.size.to_s
						elsif args[0] =~ /email/
							Display.msg "EMAIL INFORMATION"
							project.emails.each do |email|
								Display.print email.email.to_s
							end
							Display.msg "Total emails: #{project.emails.size}"
						elsif args[0] =~ /person/
							Display.msg "PERSONS INFORMATION"
							project.persons.each do |p|
								Display.print "#{p.name} #{p.last} \e[31m|\e[0m #{p.networks.size} Networks \e[31m|\e[0m #{p.emails.size} Emails"
							end
						else
							Display.error "Unrecognize option [#{args[0]}]."
						end
					else
						Display.error "No project currently open"
					end
				rescue Exception => e
					Display.error "Something went wrong running the command." + e
				end
			end
		end
	end
end