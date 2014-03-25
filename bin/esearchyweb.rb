require 'rubygems'
require 'sinatra'
require 'mongo'
require 'json'
require 'awesome_print'
require 'geokit'
require 'cgi'
require 'rack'
require 'rest-client'

require_relative "../lib/esearchy"

include ESearchy::UI::Common

# read configuration into memory.
read_config
ESearchy::DB.start
ESearchy::DB.connect

include Mongo

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end

  def check_status(url)
  	begin
  		JSON.parse(RestClient::Resource.new(url, :timeout => 2, :open_timeout => 2).get)
			return true
  	rescue RestClient::RequestTimeout
  		return false
  	rescue RestClient::ServerBrokeConnection
  		return false
  	rescue Errno::ECONNREFUSED
  		return false
  	rescue Exception
  		return false
  	end
  end
end

configure :production do
	disable :logging
end

esearchydb = Connection.new.db('esearchy')
set :views, File.dirname(__FILE__) + "/../web/views"
set :public_folder, File.dirname(__FILE__) + '/../web/static'

set :drone_list, Proc.new { esearchydb.collection('drones').find.map {|x| [x['name'],x['_id']]} }
set :project_list, Proc.new { esearchydb.collection('projects').find({}, :sort => ['updated_at', Mongo::DESCENDING], :limit => 5).map {|x| [x['name'],x['_id']]} }
set :network_list, Proc.new {
	network = []
	esearchydb.collection('people').find.each do |res|
		network.concat res['found_by'] if res['found_by'] != nil
		res['networks'].each {|n| network << n['name'] }
	end
	return network.uniq
}


## General method.  I should show here some data. 
## / INDEX
get '/' do
	@projects = esearchydb.collection('projects').find().count
	@people = esearchydb.collection('people').find().count
	@drones = esearchydb.collection('drones').find().count
	erb :index
end

#################################### Drones Methods. ####################################
## /drones DRONE INDEX
get '/drones' do
	@drones = esearchydb.collection('drones').find({}).all
	erb :drones
end

## /drones/info DRONE INFO
get '/drones/:id/info' do
	@drone = esearchydb.collection('drones').find("_id" => BSON::ObjectId(params[:id])).first
	if check_status("#{@drone['hostname']}/status")
		begin
			@plugins = JSON.parse(RestClient.get("#{@drone['hostname']}/plugins"))
			@pluginruns = JSON.parse(RestClient.get("#{@drone['hostname']}/plugins/stats"))
		rescue
			@plugins = nil
			@pluginruns = nil
		end
	else
		@plugins = nil
		@pluginruns = nil
	end
	erb :drone_info
end

## /drones/info DRONE NEW
get '/drones/new' do
	@drone = {}
	erb :drone_edit
end

get '/drones/:id/edit' do 
	@drone = esearchydb.collection('drones').find("_id" => BSON::ObjectId(params[:id])).first
	erb :drone_edit
end

post '/drones/save' do
	if params[:id] == "" or params[:id] == nil
		id = esearchydb.collection('drones').insert(params[:drone])
	else
		id = params[:id]
		esearchydb.collection("drones").update( 
			{"_id" => BSON::ObjectId(id)}, 
			{"$set" => params[:drone]} 
		)
		id 
	end	
	redirect "/drones/#{id}/info"
end

get '/drones/:id/plugins/:pname/run' do
	@drone_id = params['id']
	@plugin_id = params['pname']
	@options = {}
	erb :plugin_run, :layout => false
end

post '/drones/:id/plugins/:pname/run' do
	@drone = esearchydb.collection('drones').find("_id" => BSON::ObjectId(params[:id])).first
	begin
		project = esearchydb.collection('projects').find({"name" => params['options']['name']}, :fields => ["company", "query", "domain"]).first
		params["options"].merge!(project)
		@plugin_status = JSON.parse(RestClient.post("#{@drone['hostname']}/plugins/#{params['pname']}/run", params))

	rescue Exception => e
		@plugin_status = e.backtrace
	end

	erb :plugin_status
	#redirect to("/drones/#{params[:id]}/info"), @plugin_status
end

#################################### Company/Project Methods. ####################################
## /company/info COMPANY INDEX

get '/projects' do
	@projects = esearchydb.collection('projects').find({}, :sort => ['created_at', Mongo::DESCENDING]).to_a
	project_people = esearchydb.collection('people').group(['project_id'], nil, {'sum' => 0},
  "function(doc, prev) { prev.sum += 1}")
	@projects.each do |project|
		count = project_people.select do |x| 
			x["project_id"] == project['_id']
		end
		if count == nil or count == []
			project['people_count'] = 0
		else
			project['people_count']	= count[0]['sum'].to_i
		end
		
	end
	erb :company_all
end

get '/projects/:id/info' do
	@project = esearchydb.collection('projects').find("_id" => BSON::ObjectId(params[:id])).first
	@people = esearchydb.collection('people').find("project_id" => BSON::ObjectId(params[:id])).to_a
	@emails_size = @project['emails'].nil? ? "" : @project['emails'].size == 0 ? "" : @project['emails'].size
	@pluginruns = esearchydb.collection('plugin_runs').find({"project" => @project['name']}, :sort => ['created_at', Mongo::DESCENDING], :limit => 50)
	@drones = [] 
	if @project['drones']
		@project['drones'].each do |drone|
			d = esearchydb.collection('drones').find("_id" => BSON::ObjectId(drone)).first
			d["status"] = check_status("#{d['hostname']}/status")
			@drones << d
		end
	end
	@geolocations = []
	@people.each do |x| 
	  if x['networks'][0]['info']['geolocation']
		@geolocations << { 
						   :geolocation => x['networks'][0]['info']['geolocation'], 
						   :icon => ( x["networks"][0]["info"]["photo"] || "/img/no_face.jpg" ), 
						   :name => x["networks"][0]["info"]["name"],
						   :last => x["networks"][0]["info"]["last"],
						   :network => x["networks"][0]["name"],
						   :link => x["networks"][0]["url"],
						   :location => x["networks"][0]["info"]["location"]
						}
	  end
	end
	erb :projects
end

get '/projects/:id/people' do
	@people = esearchydb.collection('people').find("project_id" => BSON::ObjectId(params[:id]))
	erb :people_info
end

get '/projects/new' do
	@project = {}
	erb :company_edit, :layout => false 
end

post '/projects/create' do 
	id = esearchydb.collection('projects').insert(params[:project])
	redirect "/projects/#{id}/info"
end

get '/projects/:id/edit' do 
	@project = esearchydb.collection('projects').find("_id" => BSON::ObjectId(params[:id])).first
	erb :company_edit, :layout => false
end

post '/projects/save' do
	if params[:id] == "" or params[:id] == nil
		params[:created_at] = Time.now
		params[:updated_at] = params[:created_at]
		p params
		id = esearchydb.collection('projects').insert(params[:project])
		# TODO: Iterate through Drones and create if it does not exists. 
		# esearchydb.collection('drones').find({}).each do |drone| 
		#		
		# end

	else
		id = params[:id]
		params[:updated_at] = Time.now
		esearchydb.collection("projects").update( 
			{"_id" => BSON::ObjectId(id)}, 
			{"$set" => params[:project]} 
		)
	end
	redirect "/projects/#{id}/info"
end

get '/projects/:id/delete' do
	@projects = esearchydb.collection('projects').find("_id" => BSON::ObjectId(params[:id]))
	@deleted_project = esearchydb.collection('projects').remove({"_id" => BSON::ObjectId(params[:id])})
	@deleted_people = esearchydb.collection('people').remove({"project_id" => BSON::ObjectId(params[:id])})
	redirect '/'
end

#################################### People Methods. ####################################
## /people PEOPLE INDEX
get '/people' do
	@people = esearchydb.collection('people').find(params)
	puts params
	erb :people_info
end

get '/projects/:id/people/:pid/details' do
	@people = esearchydb.collection('people').find("_id" => BSON::ObjectId(params[:pid]))
	puts params
	erb :people_info
end

get '/projects/:id/people/:pid/raw' do
	@people = esearchydb.collection('people').find("_id" => BSON::ObjectId(params[:pid]))
	erb :raw
end

get '/projects/:id/people/:pid/delete' do
	@people = esearchydb.collection('people').find("_id" => BSON::ObjectId(params[:pid])).first
	@deleted_person = esearchydb.collection('people').remove({"_id" => BSON::ObjectId(params[:pid])})
	
	redirect back
end

get '/projects/:id/people/:pid/network/:nid/delete' do
	esearchydb.collection("people").update( 
		{"networks._id" => BSON::ObjectId( params[:nid] )}, 
		{"$pull" => { "networks" => {"_id" => BSON::ObjectId(params[:nid])}}} 
	)
	redirect back
end



#################################### Email Methods. ####################################
## /emails/delete EMAIL DELETE
get '/projects/:id/emails' do 
end

get '/projects/:id/emails/:pid/delete' do
	esearchydb.collection("projects").update( 
		{"emails._id" => BSON::ObjectId( params[:pid] )}, 
		{"$pull" => { "emails" => {"_id" => BSON::ObjectId(params[:pid])}}} 
	)
	#flash[:notice] = "Email deleted"
	redirect back
end

#################################### Network Methods. ####################################
## /network/people PEOPLE IN NETWORK 
get '/network/people' do
	@people = esearchydb.collection('people').find("networks.name" => params[:name])

	erb :people_info
end