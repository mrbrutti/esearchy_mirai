require 'sinatra/base'
#require 'sinatra/synchrony'
require 'webrick'
require 'webrick/https'
require 'thin'
require 'openssl'
require 'json'
require 'cgi'
require 'awesome_print'
require 'sinatra'
require 'resque'

require_relative "workers"

$verbose = true
$running_threads = {}

$hostname = `hostname`.strip

# Load esearch's dependencies
require_relative "../../esearchy"
include ESearchy::UI::Common

# Load Plugins.
load_default_templates
load_custom_templates
# read configuration into memory.
read_config
ESearchy::DB.start
ESearchy::DB.connect
#ESearchy::Redis.start

Resque.redis = Redis.new

class EsearchyDrone  < Sinatra::Base

	get '/status' do
		content_type :json
		return {:status => "UP"}.to_json
	end

	get '/drone/info' do
		content_type :json
	end

	get '/drone/reset' do
		content_type :json
		begin
			#loading plugins
			load_default_templates
			load_custom_templates
			# read configuration into memory.
			read_config
			ESearchy::DB.start
			ESearchy::DB.connect
			return {:status => "RESET"}.to_json
		rescue Exception => e
			return {"result" => "failed", :error => e.to_s, :errorid => 100, :backtrace => e.backtrace}.to_json
		end
	end

  get '/projects' do
  	content_type :json
  	begin
  		project = Project.all
  		if project.nil?
  			return {:error => "No Company exists", :errorid => 203}.to_json
  		else
  			return project.to_json
  		end
  	rescue Exception => e
  		return {"result" => "failed", :error => e.to_s, :errorid => 100, :backtrace => e.backtrace}.to_json
  	end
  end

  post '/projects/create' do
  	content_type :json
  	begin
  		project = Project.where("name" => params[:project][:name]).first
			if project.nil?
				project = Project.new params[:project]
				project.save!
				return project.to_json
			else
				return {"result" => "failed", :error => "Company already exists", :errorid => 202}.to_json
			end
		rescue Exception => e
			return {"result" => "failed", :error => e.to_s, :errorid => 100, :backtrace => e.backtrace}.to_json
		end
  end

  get '/projects/:id/sync/emails' do 
  	content_type :json
  	begin
  		project = Project.where("id" => params['id']).first
  		if project['emails'].nil?
  			return {}.to_json
  		else
  			return project['emails'].to_json
  		end
  	rescue Exception => e
  		return {"result" => "failed", :error => e.to_s, :errorid => 102, :backtrace => e.backtrace}.to_json
  	end
  end

  get '/projects/:id/sync/people' do
  	content_type :json
    begin
  		people = People.where("project_id" => params['id']).to_a
  		if people.empty?
  			return {}.to_json
  		else
  			return people.to_json
  		end
  	rescue Exception => e
  		return {"result" => "failed", :error => e.to_s, :errorid => 103, :backtrace => e.backtrace}.to_json
  	end	
  end

  get '/projects/:id/info' do
  	content_type :json
  	begin
  		project = Project.where("id" => params['id']).first
  		if project.nil?
  			return {:error => "Company does not exists", :errorid => 201}.to_json
  		else
  			return project.to_json
  		end
  	rescue Exception => e
  		return {"result" => "failed", :error => e.to_s, :errorid => 101, :backtrace => e.backtrace}.to_json
  	end
  end

  get '/plugins' do
  	content_type :json
    ESearchy::PLUGINS.map {|x| { "name" => x[0], "description" => x[1].new.desc} }.to_json
  end

  post '/plugins/:pname/run' do
  	content_type :json
  	begin
		  if ESearchy::PLUGINS[params[:pname]].nil?
		    Display.error "Plugin does not exists."
		    return { "result" => "failed", "error" => "Plugin does not exists."}.to_json
		  else
		  	Resque.enqueue(PluginWorker, params)
		  	return { "result" => "Enqueued", "params" => params}.to_json
		  end
		rescue Exception => e
			return { "result" => "failed", 
							 "error" 	=> e.backtrace,
							 "params" => params[:options] }.to_json
		end
		# Old code using Threads. 
		#begin
		#  if ESearchy::PLUGINS[params[:pname]].nil?
		#    Display.error "Plugin does not exists."
		#    return { "result" => "failed", "error" => "Plugin does not exists."}.to_json
		#  else
		#  	start_time = Time.now
		#  	pid = "#{params[:pname]}_#{start_time.to_i}"
		#  	# create plugin instance
		#  	$running_threads[pid] = Thread.new do
		#	  	begin
		#		  	running_context = ESearchy::PLUGINS[params[:pname]].new params[:options]
		#		  	# Add run State to plugin.
		#		  	run_state = PluginRun.new  :hostname => $hostname,
		#		  							   :plugin 	=> running_context.nombre, 
		#		  							   :status 	=> "RUNNING",
		#		  							   :options => running_context.options,
		#		  							   :project => running_context.options[:name],
		#		  							   :error => nil, :error_details => nil,
		#		  							   :created_at => start_time,
		#		  							   :thread_id => pid
		#		  	run_state.save
		#
		#		  	#run the plugin :)
		#		    running_context.run
		#		    
		#		    # Add successful_db_state to plugin.
		#		    run_state.stop_at = Time.now
		#		    if running_context.options[:error] != nil
		#		    	run_state.status = "FAILED"
		#		    	run_state.error = running_context.options[:error]
		#				run_state.error_details = running_context.options[:error_details]
		#		    else
		#		    	run_state.status = "DONE"
		#		    end
		#		    run_state.save
		#		    running_context.options[:error] = nil
		#		    running_context.options[:error_details] = nil
		#		 	rescue Exception => e
		#				# Save bad state to DB.
		#				run_state.status = "FAILED"
		#				run_state.stop_at = Time.now
		#				run_state.error = e.to_s
		#				run_state.error_details = e.backtrace.join("\n")
		#				run_state.save
		#				# Display error
		#				Display.error "Something went wrong running the plugin. #{e}"
		#				Display.backtrace e.backtrace
		#				return { 
		#								"result" => "failed", 
		#						    "error" => "Something went wrong running the plugin. #{e}", 
		#						    "backtrace" => e.backtrace,
		#						    :errorid => 100, 
		#						  }.to_json
		#			end
		#		end
		#  end
		#  return { 
		#  				"result" => "success", 
		# 					 "plugin" => params['pname'], 
		# 					 "pid" 		=> pid, 
		# 					 "status" => $running_context[pid].status,
		# 					 "start" 	=> start_time
		# 				 }.to_json
		#rescue Exception => e
		#	return { "result" => "failed", 
		#		"error" => e.backtrace,
		#		"params" => params[:options] }.to_json
		#end
  end

  get '/plugins/stats' do
  	content_type :json
  	return PluginRun.all( :order => :created_at.desc, :limit => 50).to_json
  end

  get '/plugins/status' do
  	content_type :json
  	return $running_threads.map {|k,v| {"k" => v.status} }.to_json
  end

  get '/plugins/:pid/kill' do
  	content_type :json
  	begin 
  		$running_threads[params['pid']].kill
  		return { "result" => "success"}.to_json
		rescue Exception => e
			return { "result" => "failed", 
					     "error" => e.to_s, 
					     "backtrace" => e.backtrace, :errorid => 100, }.to_json
  	end
  end

  get '/plugins/reload' do
  	content_type :json
  	begin
  		load_default_templates
			load_custom_templates
			return { "result" => "success"}.to_json
		rescue Exception => e
			return { "result" => "failed", 
					     "error" => e.to_s, 
					     "backtrace" => e.backtrace, :errorid => 100, }.to_json
		end
  end           
end

CERT_PATH = '../certs/'

module ESearchy
	module Drone

		@options = {
		  :Port               => 9999,
		  :Logger             => WEBrick::Log::new($stderr, WEBrick::Log::INFO),
		  :DocumentRoot       => "../web/",
		  :SSLEnable          => true,
		  :SSLVerifyClient    => OpenSSL::SSL::VERIFY_NONE,
		  :SSLCertificate     => OpenSSL::X509::Certificate.new( File.open(File.join(CERT_PATH, "drone_server_ssl.crt")).read),
		  :SSLPrivateKey      => OpenSSL::PKey::RSA.new(  File.open(File.join(CERT_PATH, "drone_server_ssl.key")).read),
		  :SSLCertName        => [ [ "CN", WEBrick::Utils::getservername ] ],
		  :app                => EsearchyDrone,
		  :server 						=> WEBrick,
		  #:ssl => true,
	    #{}"ssl-verify" => false,
		}

		def self.ssl_options
			@options
		end
	end
end
