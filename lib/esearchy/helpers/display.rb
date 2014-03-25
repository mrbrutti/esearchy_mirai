class Display
  COLOR_CODE = "\e"
  if  RUBY_PLATFORM =~ /mingw|mswin/
    require 'win32console'
  end

  def self.red
    COLOR_CODE + "[31m"
  end

  def self.backred
    COLOR_CODE + "[41m"
  end

  def self.blue
    COLOR_CODE + "[34m"
  end

  def self.yellow
    COLOR_CODE + "[33m"
  end

  def self.default
    COLOR_CODE + "[0m"
  end

  def red
    COLOR_CODE + "[31m"
  end

  def backred
    COLOR_CODE + "[41m"
  end

  def blue
    COLOR_CODE + "[34m"
  end

  def yellow
    COLOR_CODE + "[33m"
  end

  def default
    COLOR_CODE + "[0m"
  end

  def self.error(message)
    puts red() + "[!]" + " - #{message}" + default if $verbose
  end
  
  def self.debug(message)
    puts red + "[#]"  + " - #{message}" + default if $debug
  end

  def self.print(message)
    puts "      #{message}"
  end
    
  def self.warn(message)
    puts yellow + "[!]"  + " - #{message}" + default
  end
  
  def self.msg(message)
     puts "[*] - #{message}"
  end
  
  def self.help(message)
    puts blue + "[|]" + "   #{message}" + default
  end

  def self.backtrace backtrace
    if $backtrace
      backtrace.each do |x| 
        puts backred + "* BACKTRACE | " + x.to_s + " | BACKTRACE * " + default 
      end 
    end
  end

  def self.logo
    puts red + "___________ " + default + "_________                           .__          " 
    puts red + "\\_   _____/" + default + "/   _____/ ____ _____ _______   ____ |  |__ ___.__."
    puts red + " |    __)_ " + default + "\\_____  \\_/ __ \\\\__  \\\\_  __ \\_/ ___\\|  |  <   |  |"
    puts red + " |        \\" + default + "/        \\  ___/ / __ \\|  | \\/\\  \\___|   Y  \\___  |"
    puts red + "/_______  /" + default + "_______  /\\___  >____  /__|    \___  >___|  / ____|"
    puts red + "        \\/" + default + "        \\/     \\/     \\/            \\/    \\/\\/  #{ESearchy::VERSION}"
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
      print yellow + "#{k}" + default + "\t\=\t#{val}"
    end
  end
end


