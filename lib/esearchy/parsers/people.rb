#encoding: UTF-8

module ESearchy
	module Parsers
		module People

			def ziggs(profile)
				doc = Nokogiri::HTML(open(profile))
				links = Nokogiri::HTML(open(profile.gsub('/Background/', "/Links/")))
				begin
					if get_info(doc.search('span[@id="ctl00_ContentPlaceHolder1_MemberImageCard1_lblCompany"]')).strip.match(/#{@options[:company]}/i) != nil
						person = {}
						name_last = get_info(doc.search('span[@id="ctl00_ContentPlaceHolder1_MemberImageCard1_lblName"]')).split(" ")
						person[:name] = name_last.first  
						person[:last] = name_last.last
						person[:title] = get_info(doc.search('span[@id="ctl00_ContentPlaceHolder1_MemberImageCard1_lblTitle"]'))
						person[:company] = @options[:company]
						person[:photo] = get_info(doc.search('img[@id="ctl00_ContentPlaceHolder1_MemberImageCard1_imgMember"]'))
						person[:city], person[:state] = get_info(doc.search('span[@id="ctl00_ContentPlaceHolder1_MemberImageCard1_lblLocation"]')).split(",")
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
				doc = Nokogiri::HTML(open(profile))
				begin
					if get_info(doc.search('ul[@class="FLMe8d"]')).strip.match(/#{@options[:company]}/i) != nil
						person = {}
						name_last = get_info(doc.search('span[@class="fn"]')).split(" ")
						person[:name] = name_last.first  
						person[:last] = name_last.last
						person[:title] = get_info(doc.search('div[@class="aYm0te c-wa-Da title"]'))
						person[:company] = @options[:company]
						person[:city] = get_info(doc.search('div[@class="adr"]'))
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
				doc = Nokogiri::HTML(open(profile))
				begin
					if get_info(doc.search('div[@id="storyPartialView"]')).split("Biography:")[1].strip.match(/#{@options[:company]}/i) != nil
						person = {}
						person[:name], person[:last] = get_info(doc.search('h2[@class="fwdSlash customFont txtUpper inline"]')).split(" ")
						person[:biography] = get_info(doc.search('div[@id="storyPartialView"]')).split("Biography:")[1].strip
						information = get_info(doc.search('div[@id="c:SEOMemberBasicInfo"]'))
						person[:school] = information.split("High School")[0]
						person[:yeargrad] = information.split("High School")[1].split("Class of ")[1].split("Member Since: ")[0].strip.to_i
						person[:city], person[:state] = information.split("High School")[1].split("Class")[0].strip.split(", ")
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
				doc = Nokogiri::HTML(open(profile))
				begin
					if get_info(doc.search('p[@class="headline-title title"]')).match(/#{@options[:company]}/i) != nil
						person = {}
						person[:name] = get_info(doc.search('span[@class="given-name"]'))
						person[:last] = get_info(doc.search('span[@class="family-name"]'))
						person[:title] = get_info(doc.search('p[@class="headline-title title"]'))
						person[:location] = get_info(doc.search('dd[@class="locality"]'))
						person[:photo] = doc.search('div[@class="image zoomable"]').search('img[@class="photo"]')[0] == nil ? 
							"˚∫" : 
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

			def jigsaw
				
			end

			def plaxo
				
			end

			def googleprofiles(profile)
				googleplus(profile)
			end

			def spoke(profile)
				doc = Nokogiri::HTML(open(profile))
				begin
					if get_info(doc.search('h3[@class="fn"]')).match(/#{@options[:company]}/i) != nil
						person = {}
						person[:name], person[:last] = get_info(doc.search('h1[@class="ellipsis"]')).split(" ")
						person[:title] = get_info(doc.search('span[@class="title"]'))
						person[:company] = @options[:company]
						person[:detail] = get_info(doc.search('div[@class="expandable bio"]'))
						person[:photo] = "http://www.spoke.com" + get_info(doc.search('div[@class="img-profile"]'))
						return person
					else
						return {}
					end
				rescue
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
