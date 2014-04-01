module ESearchy
	module Redis
		def self.start
			Display.msg "Starting Redis Database"
			@@redis_pid = system("redis-server &")
			sleep(1)
			Display.msg "Starting Redis Plugin Queue"
			@@resque_pid = system("bundle exec resque work -q plugin -r ../lib/esearchy/drone/workers.rb &")
			return {:redis => redis_pid, :resque => resque_pid}
		rescue
			Display.error "Something went bad starting Redis database or queue"
		end

		def self.stop
			Display.msg "Stoping Redis Database"
			system("kill -9 #{@@redis_pid}")
			Display.msg "Stoping Redis Plugin Queue"
			system("kill -9 #{@@resque_pid}")
		rescue
			Display.error "Something went bad stoping Redis (pid:#{@@redis_pid}) database or queue (pid:#{@@resque_pid}) "
		end
	end
end