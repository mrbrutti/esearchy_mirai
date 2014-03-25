# encoding: UTF-8
require 'geokit'

Geokit::Geocoders::google = "AIzaSyAXSzCJBDU6H2LSYM_SAyMOrKTigAhA4ZE"

module ESearchy
	module Parsers
		module People

			def ziggs(profile)
				begin
          search = open(profile)
        rescue Exception => e
          Display.error "There was an error opening the Ziggs Profile #{e}"
          return {}
        end
				doc = Nokogiri::HTML(search)

				begin
          search = open(profile.gsub('/Background/', "/Links/"))
        rescue Exception => e
          Display.error "There was an error opening the Ziggs Links Profile #{e}"
          return {}
        end
				links = Nokogiri::HTML(search)

				begin
					if get_info(doc.search('span[@id="ctl00_ContentPlaceHolder1_MemberImageCard1_lblCompany"]')).strip.match(/#{@options[:company]}/i) != nil
						person = {}
						name_last = get_info(doc.search('span[@id="ctl00_ContentPlaceHolder1_MemberImageCard1_lblName"]')).split(" ")
						person[:name] = name_last.first  
						person[:last] = name_last.last
						person[:title] = get_info(doc.search('span[@id="ctl00_ContentPlaceHolder1_MemberImageCard1_lblTitle"]'))
						person[:company] = @options[:company]
						person[:photo] = get_info(doc.search('img[@id="ctl00_ContentPlaceHolder1_MemberImageCard1_imgMember"]'))
						person[:location] = get_info(doc.search('span[@id="ctl00_ContentPlaceHolder1_MemberImageCard1_lblLocation"]'))
						if person[:location].strip != "" and person[:location] != nil
							geoloc = Geokit::Geocoders::MultiGeocoder.geocode(person[:location]).ll
							if geoloc != ","
								person[:geolocation] = geoloc
							else
								geoloc = Geokit::Geocoders::GoogleGeocoder3.geocode(person[:location]).ll
								person[:geolocation] = geoloc if geoloc != ","
							end
						end
						#Fetch resume URL if a resume doc is posted.
						resume = doc.search('a[@id="ctl00_ContentPlaceHolder1_lnkResumeName"]')		  
		  				person[:resume] = resume[0]['href'] unless resume.empty?
						# Work History
						person[:workhistory] = get_info(doc.search('div[@id="ctl00_ContentPlaceHolder1_divWork"]')).split(/[\r\n\t\t\t\t\t\t]+/).map {|x| x.strip}.select {|x| x != ""}
						# School History
						person[:schoolhistory] = get_info(doc.search('div[@id="ctl00_ContentPlaceHolder1_divEducation"]')).split(/[\r\n\t\t\t\t\t\t]+/).map {|x| x.strip}.select {|x| x != ""}
						# Links
						person[:links] = {}						
						links.search('div[@id="ctl00_ContentPlaceHolder1_divWebLinks"]').search('a[@class="bold"]').each {|x| person[:links][x.text] = x['href']}
						return person
					else
						return {}
					end
				rescue
					return {}
				end	
			end

			def googleplus(profile)
				if profile.match(/\/about/) == nil
					profile += "/about"
				end
				begin
          search = open(profile)
        rescue Exception => e
          Display.error "There was an error opening the Google+ Profile #{e}"
          return {}
        end
				doc = Nokogiri::HTML(search)
				begin
					if get_info(doc.search('ul[@class="FLMe8d"]')).strip.match(/#{@options[:company]}/i) != nil
						person = {}
						name_last = get_info(doc.search('span[@class="fn"]')).split(" ")
						person[:name] = name_last.first  
						person[:last] = name_last.last
						person[:title] = get_info(doc.search('div[@class="aYm0te c-wa-Da title"]'))
						person[:company] = @options[:company]
						person[:location] = get_info(doc.search('div[@class="adr"]'))
						if person[:location].strip != "" and person[:location] != nil
							if geoloc != ","
								person[:geolocation] = geoloc
							else
								geoloc = Geokit::Geocoders::GoogleGeocoder3.geocode(person[:location]).ll
								person[:geolocation] = geoloc if geoloc != ","
							end
						end
		  			person[:gender] = get_info(doc.search('div[@class="kM5Oeb-fYiPJe KtnyId IzbGp"]')).gsub("Gender","") 
		  			person[:photo] = get_info(doc.search('img[@class="l-tk photo"]'))
						work_edit = doc.search('ul[@class="FLMe8d"]')
						# Work History
						if work_edit[0] != nil
							person[:employment] = [] ; work_edit[0].search('li[@class="TPAeZc"]').each {|y| person[:employment] << [y.search('div')[0].text, y.search('div')[1].text] }
						end
						if work_edit[1] != nil
							# School History
							person[:education] =  [] 
							work_edit[1].search('li[@class="TPAeZc"]').each {|y| person[:education] << [y.search('div')[0].text, y.search('div')[1].text] }
						end
						# Links
						person[:links] = {}		
						if doc.search('ul[@class="FLMe8d PLDbbf"]') != nil				
						 doc.search('ul[@class="FLMe8d PLDbbf"]').each {|x| p x.search('a').each {|y| person[:links][y['title']] = y['href'] }}
						end
						return person
					else
						return {}
					end
				rescue
					return {}
				end	
			end

			def twitter(profile)
				begin
					person = {}
					screenname = profile.split("/").last
					person = JSON.parse(open("https://api.twitter.com/1/users/show.json?screen_name=#{screenname}&include_entities=true").readlines[0], :symbolize_names => true)
					person[:friends] = JSON.parse(open("https://api.twitter.com/1/friends/ids.json?cursor=-1&screen_name=#{screenname}").readlines[0])["ids"]
					person[:followers] = JSON.parse(open("https://api.twitter.com/1/followers/ids.json?cursor=-1&screen_name=#{screenname}").readlines[0])["ids"]
					person[:photo] = person[:profile_image_url]
					return person
				rescue
					return person
				end				
			end

			def classmates(profile)
				begin
          search = open(profile)
        rescue Exception => e
          Display.error "There was an error opening the Classmates Profile #{e}"
          return {}
        end
				doc = Nokogiri::HTML(search)

				begin
					if get_info(doc.search('div[@id="storyPartialView"]')).split("Biography:")[1].strip.match(/#{@options[:company]}/i) != nil
						person = {}
						person[:name], person[:last] = get_info(doc.search('h2[@class="fwdSlash customFont txtUpper inline"]')).split(" ")
						person[:biography] = get_info(doc.search('div[@id="storyPartialView"]')).split("Biography:")[1].strip
						information = get_info(doc.search('div[@id="c:SEOMemberBasicInfo"]'))
						person[:school] = information.split("High School")[0]
						person[:yeargrad] = information.split("High School")[1].split("Class of ")[1].split("Member Since: ")[0].strip.to_i
						person[:location] = information.split("High School")[1].split("Class")[0].strip
						if person[:location].strip != "" and person[:location] != nil
							geoloc = Geokit::Geocoders::MultiGeocoder.geocode(person[:location]).ll
							if geoloc != ","
								person[:geolocation] = geoloc
							else
								geoloc = Geokit::Geocoders::GoogleGeocoder3.geocode(person[:location]).ll
								person[:geolocation] = geoloc if geoloc != ","
							end
						end
						person[:company] = @options[:company]
						person[:communities] = get_info(doc.search('ul[@class="botMargin1"]')).split(")").map {|x| x.strip + ")"}
						person[:photo] = get_info(doc.search('div[@class"space1marT"'))
						return person
					else
						return {}
					end
				rescue
					return {}
				end		
			end
			
			def linkedin(profile)
				begin
          search = open(profile)
        rescue Exception => e
          Display.error "There was an error opening the LinkedIn Profile #{e}"
          return {}
        end
				doc = Nokogiri::HTML(search)
				begin
					if get_info(doc.search('p[@class="headline-title title"]')).match(/#{@options[:company]}/i) != nil
						person = {}
						person[:name] = get_info(doc.search('span[@class="given-name"]'))
						person[:last] = get_info(doc.search('span[@class="family-name"]'))
						person[:title] = get_info(doc.search('p[@class="headline-title title"]'))
						person[:location] = get_info(doc.search('dd[@class="locality"]'))
						if person[:location].strip != "" and person[:location] != nil
							geoloc = Geokit::Geocoders::MultiGeocoder.geocode(person[:location]).ll
							if geoloc != ","
								person[:geolocation] = geoloc
							else
								geoloc = Geokit::Geocoders::GoogleGeocoder3.geocode(person[:location]).ll
								person[:geolocation] = geoloc if geoloc != ","
							end
						end
						person[:photo] = doc.search('div[@class="image zoomable"]').search('img[@class="photo"]')[0] == nil ? 
							nil : 
							doc.search('div[@class="image zoomable"]').search('img[@class="photo"]')[0].attributes["src"].value
						person[:company] = @options[:company]
						person[:education] = get_info(doc.search('dd[@class="summary-education"]')).gsub(/\t|\n|(\s)\1{5,}/,"")
						return person
					else
						return {}
					end
				rescue
					return {}
				end				
			end

			def facebook
				
			end

			def jigsaw(profile)
				begin
          search = open(profile)
        rescue Exception => e
          Display.error "There was an error opening the Jigsaw Profile #{e}"
          return {}
        end
				doc = Nokogiri::HTML(search)

				begin
					if get_info(doc.search('div[@class="businesscard-companyinfo-name"]')).match(/#{@options[:company]}/i) != nil
						person = {}
						name_last = get_info(doc.search('div[@class="businesscard-contactinfo-name"]')).split(" ")
						person[:name] = name_last[0..-2].join(" ")
						person[:last] = name_last[-1]
						person[:title] = get_info(doc.search('div[@class="businesscard-contactinfo-title"]'))
						person[:location] = get_info(doc.search('div[@class="businesscard-companyinfo-addressline"]'))
						person[:location] << " " + get_info(doc.search('div[@class="businesscard-companyinfo-citystatezip"]')).gsub("  ", "").gsub("\r\n", " ").strip
						person[:location] << " " + get_info(doc.search('div[@class="businesscard-companyinfo-country"]'))
						if person[:location].strip != "" and person[:location] != nil
							geoloc = Geokit::Geocoders::MultiGeocoder.geocode(person[:location]).ll
							if geoloc != ","
								person[:geolocation] = geoloc
							else
								Display.error "Using Googlev3 GeoCoders"
								geoloc = Geokit::Geocoders::GoogleGeocoder3.geocode(person[:location]).ll
								person[:geolocation] = geoloc if geoloc != ","
							end
						end
						person[:photo] = nil
						person[:company] = @options[:company]
						return person
					else
						Display.debug "Company does not match."
						return {}
					end
				rescue Exception => e
					Display.error "There was an error parsing the Jigsaw Profile #{e}"
					Display.backtrace e.backtrace
					return {}
				end
			end

			def plaxo
				
			end

			def googleprofiles(profile)
				googleplus(profile)
			end

			def spoke(profile)
				begin
          search = open(profile)
        rescue Exception => e
          Display.error "There was an error opening the Spoke Profile #{e}"
          return {}
        end
				doc = Nokogiri::HTML(search)
				Display.debug profile
				begin
					company = get_info(doc.search('h3[@class="fn"]'))
					if company.match(/#{@options[:company]}/i) != nil
						Display.debug "I am where I should since ( " + company + " ) == " + @options[:company] + "!"
						person = {}
						person[:name], person[:last] = get_info(doc.search('h1[@itemprop="name"]')).split(" ")
						person[:title] = get_info(doc.search('span[@class="title"]'))
						person[:company] = @options[:company]
						person[:detail] = get_info(doc.search('div[@class="expandable summary"]'))
						person[:photo] = "http:" + doc.search('[@class="large-portrait"]')[0].children[1].attributes["src"].value
						return person
					else
						Display.debug "I fail for some reason ( " + company + " ) != " + @options[:company] + "?"
						return {}
					end
				rescue Exception => e
					Display.debug "Error in Spoke " + e.to_s
					return {}
				end
			end

			private

			def get_info(res)
				res[0] == nil ? "" : res[0].text.strip
			end
		end
	end
end
