require 'command_line_reporter'

include CommandLineReporter

class Display
  
  COLOR_CODE = "\e"
  if  RUBY_PLATFORM =~ /mingw|mswin/
    require 'win32console'
  end

  def self.underline
    COLOR_CODE + "[4m" + COLOR_CODE + "[1m"
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


  def self.plugins(s)
    table(:border => false) do
      row(:color => 'red', :header => true, :bold => true) do
        column('NAME', :width => 20)
        column('TYPE', :width => 15)
        column('DESCRIPTION', :width => (ENV['COLUMNS'].to_i - 45))
      end
      s.each do |plugin|
        row(:color => 'blue') do
          column(plugin[0])
          column(plugin[1].to_s.split("::")[1])
          column(plugin[1].new.desc)
        end
      end
    end
  end

  def self.projects(p)
    table(:border => false) do
      row(:color => 'red', :header => true, :bold => true) do
        column('NAME', :width => 15)
        column('COMPANY', :width => 35)
        column('EMAILS', :width => 10)
        column('PERSONS', :width => 10)
        column('CREATED', :width => 10)
        column('UPDATED', :width => 10)
      end
      p.each do |project|
        row(:color => 'blue') do
          column(project.name)
          column(project.company)
          column(project.emails.size)
          column(project.persons.size)
          column(project.created_at == nil ? "--" : project.created_at.strftime("%m-%d-%Y"))
          column(project.updated_at == nil ? "--" : project.updated_at.strftime("%m-%d-%Y"))
        end
      end
    end
  end

  def self.persons(p)
    table(:border => false) do
      row(:color => 'red', :header => true, :bold => true) do
        column('NAME', :width => 12)
        column('LAST', :width => 15)
        column('TITLE', :width => (ENV['COLUMNS'].to_i - 72))
        column('FOUND_BY', :width => 10)
        column('NETs', :width => 5)
        column('@s', :width => 5)
        column('CREATED', :width => 10)
      end
      p.each do |person|
        row(:color => 'blue') do
          column(person.name)
          column(person.last)
          column(person.networks[0]["info"]["title"])
          column(person.found_by.join(" "))
          column(person.networks.size)
          column(person.emails.size)
          column(person.created_at == nil ? "--" : person.created_at.strftime("%m-%d-%Y"))
        end
      end
    end
  end

  def self.emails(e)
    table(:border => false) do
      row(:color => 'red', :header => true, :bold => true) do
        column('EMAIL', :width => 30)
        column('FOUND_BY', :width => 15)
        column('URL', :width => (ENV['COLUMNS'].to_i - 60))
      end
      e.each do |email|
        row(:color => 'blue') do
          column(email.email)
          column(email.found_by.join(" "))
          column(email.url)
        end
      end
    end
  end

  def self.hash(opt = {})
    table(:border => false) do
      row(:color => 'red', :header => true, :bold => true) do
        column('KEY', :width => 15)
        column('VALUE', :width => (ENV['COLUMNS'].to_i - 25))
      end
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
        row(:color => 'blue') do
          column(k, {:bold => true, :color => 'white'})
          column((val == nil || val.strip == "") ? "--" : val)
        end
      end
    end
  end
end


