module ESearchy
	module DB
		def self.start
			Display.msg "Starting MongoDB"
			case RUBY_PLATFORM
			when /linux|darwin/
				mongod = File.expand_path File.dirname(__FILE__) + "../../../../external/mongodb/bin/mongod --fork"
				dblogs = ENV['HOME'] + "/.esearchy/logs/mongodb.logs"
				dbpath = ENV['HOME'] + "/.esearchy/data/db"
				Display.debug mongod + " --dbpath=" + dbpath + " --logpath=" + dblogs + " --logappend"
				system( mongod + " --dbpath=" + dbpath + " --logpath=" + dblogs + " --logappend" + "> /dev/null")
				sleep(1)
			when /mingw|mswin/
				system("..\\external\\tools\\Elevate.exe NET START \"MONGODB\"")
				sleep(1)
			end
		rescue
			Display.error "Something went wrong starting db"
			exit(0)
		end
		def self.connect
			Display.msg "Connecting ESearchy to MongoDB"
			sleep(2)
			MongoMapper.connection = Mongo::Connection.new($globals[:dbhost] || "localhost", $globals[:dbport] || 27017)
			MongoMapper.database = $globals[:dbname] || "esearchy"
		rescue
			Display.error "There was an error connecing to the database." 
			Display.error "Make sure mongod is running and connections are correctly setup."
			exit(0)
		end

		def self.stop
			MongoMapper.connection['admin'].command(:shutdown => 1)
			system("..\\external\\tools\\Elevate.exe NET STOP \"MONGODB\"") if RUBY_PLATFORM =~ /mingw|mswin/
		rescue
			Display.error "Looks like there is nothing to shutdown"
		end
	end
end