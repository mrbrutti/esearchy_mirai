module ESearchy  
  class BasePlugin
    
    def initialize(options={}, &block)
      @options = options
      @project = Project.find_by_name(@options[:name]) || nil
      @options[:start] ||= 0
      @options[:start] =  @options[:start].to_i
      @options[:stop] ||= $globals[:maxhits].to_i
      @options[:results] ||= $globals[:maxhits].to_i


      block.call(self) if block_given?
    end
    attr_accessor :options

    def run
      raise "This is just a container."
    end

    def post
      raise "This is just a future container."
    end

    def self.help
      Display.msg "HELP"
      Display.help @info[:name]
      Display.help "\t" + @info[:desc]
    end

    def help
      Display.msg "HELP"
      Display.help @info[:name]
      Display.help "\t" + @info[:desc]
    end
    
    def self.nombre
      @info[:name]
    end

    def self.desc
      @info[:desc]
    end

    def desc
      @info[:desc]
    end

    def nombre
      @info[:name]
    end

    def project
      @project
    end

    def persons(options={})
      options == {} ? @project.persons.all : @project.persons.where(options)
    end

    def networks_exist?(net, name)
      if net == nil
        true
      elsif net.select {|x| x[:name] == name}.size == 0
        true
      else
        false
      end
    end

    def email_exist?(email)
      if @project.emails == nil
        true
      elsif @project.emails.select {|x| x[:email] == email }.size == 0
        true
      else
        false
      end
    end
  end
end
