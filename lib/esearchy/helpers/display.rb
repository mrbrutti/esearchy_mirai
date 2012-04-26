if  RUBY_PLATFORM =~ /mingw|mswin/
  require 'win32console'
  class Display
    def self.error(message)
      puts "\e[31m[!]\e[0m - #{message}"
    end
    
    def self.debug(message)
      puts "\e[31m[#]\e\[0m - #{message}" if $debug
    end

    def self.print(message)
      puts "      #{message}"
    end
      
    def self.warn(message)
      puts "\e[33m[!]\e[0m - #{message}"
    end
    
    def self.msg(message)
       puts "[*] - #{message}"
    end
    
    def self.help(message)
      puts "\e[34m[|]\e[0m   #{message}"
    end
    
    def self.logo
      puts "\e[31m___________ \e[0m_________                           .__          " 
      puts "\e[31m\\_   _____/\e[0m/   _____/ ____ _____ _______   ____ |  |__ ___.__."
      puts "\e[31m |    __)_ \e[0m\\_____  \\_/ __ \\\\__  \\\\_  __ \\_/ ___\\|  |  <   |  |"
      puts "\e[31m |        \\\e[0m/        \\  ___/ / __ \\|  | \\/\\  \\___|   Y  \\___  |"
      puts "\e[31m/_______  /\e[0m_______  /\\___  >____  /__|    \___  >___|  / ____|"
      puts "\e[31m        \\/\e[0m        \\/     \\/     \\/            \\/    \\/\\/  #{ESearchy::VERSION}"
    end

    def self.hash(opt = {})
      opt.each do |k,v|
        case v
        when String
          val = v
        when Fixnum
          val = v.to_s
        when Array
          val = "[" + v.join(", ") + "]"
        when Hash
          val = "{" + v.map { |x| x.join(" => ")}.join(",\n ") + "}"
        else
          val = v.to_s
        end
        print "\e[33m#{k}\e[0m\t\=\t#{val}"
      end
    end
  end
else
  class Display
    def self.error(message)
      puts "\033[31m[!]\033\[0m - #{message}"
    end
    
    def self.debug(message)
      puts "\033[31m[#]\033\[0m - #{message}" if $debug
    end

    def self.print(message)
      puts "      #{message}"
    end
      
    def self.warn(message)
      puts "\033[33m[!]\033\[0m - #{message}"
    end
    
    def self.msg(message)
       puts "[*] - #{message}"
    end
    
    def self.help(message)
      puts "\033[34m[|]\033\[0m   #{message}"
    end

    def self.logo
      puts "\033[31m___________ \033\[0m_________                           .__          " 
      puts "\033[31m\\_   _____/\033\[0m/   _____/ ____ _____ _______   ____ |  |__ ___.__."
      puts "\033[31m |    __)_ \033\[0m\\_____  \\_/ __ \\\\__  \\\\_  __ \\_/ ___\\|  |  <   |  |"
      puts "\033[31m |        \\\033\[0m/        \\  ___/ / __ \\|  | \\/\\  \\___|   Y  \\___  |"
      puts "\033[31m/_______  /\033\[0m_______  /\\___  >____  /__|    \___  >___|  / ____|"
      puts "\033[31m        \\/\033\[0m        \\/     \\/     \\/            \\/    \\/\\/  #{ESearchy::VERSION}"
    end

    def self.hash(opt = {})
      opt.each do |k,v|
        case v
        when String
          val = v
        when Fixnum
          val = v.to_s
        when Array
          val = "[" + v.join(", ") + "]"
        when Hash
          val = "{\n" + v.map { |x| "\t" + x.join(" => ")}.join(",\n ") + "\n}"
        when nil
          val = ""
        else
          val = v.to_s
        end
        print "\033[33m#{k}\033\[0m\t\=\t#{val}"
      end
    end
  end
end

