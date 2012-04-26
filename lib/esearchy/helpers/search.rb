require 'open-uri'
require 'nokogiri'

module ESearchy
  module Helpers
    module Search      
      def google
        Display.debug "Entering Google Search for query= #{@options[:query]}"
        doc = Nokogiri::HTML(open("http://www.google.com/cse?&safe=off&num=100&site=&q=" +  
                                    @options[:query]  + "&btnG=Search&start=" + @options[:start].to_s))

        # For the first search extract results.
        if @options[:start] == 0 
          if doc.search("font")[0].elements[2] != nil
            @options[:results] = doc.search("font")[0].elements[2].text.gsub(",","").to_i
          else
            Display.error "No results were found."
            @options[:results] = 0
            return []
          end
        end 
        # create results array.
        Display.debug "Correcty Parsed results size (#{@options[:results]})"
        results = []
        begin
          doc.search('div[@id="res"]')[0].search('div[@class="g"]').each do |result| 
            begin
              results << { :title => result.search('a[@class="l"]')[0].text, 
                           :url => result.search('a[@class="l"]')[0]['href'], 
                           :content => result.search('span[@class="s"]')[0].text }
              Display.debug "parsed result number " + results.size.to_s
            rescue
              Display.error "Something went wrong parsing a result at #{@options[:start]} with query #{@options[:query]}"
            end
          end
        rescue
          Display.error "The doc fail at #{@options[:start]} with query #{@options[:query]}"
        end
        return results #[{:title => "", :url => "", :content => ""},..,{}]
      end
    
      def bing
        doc = JSON.parse(open("http://api.search.live.net/json.aspx?AppId=" + $globals[:bingkey] + 
                              "&query=" + @options[:query] + "&Sources=Web&Web.Count=50&Web.Offset=" + @options[:start].to_s).readlines[0])
        # For the first search extract results. 
        @options[:results] = doc["SearchResponse"]["Web"]["Total"].to_i if @options[:start] == 0
        # create results array. 
        results = []
        begin
          doc["SearchResponse"]["Web"]["Results"].each do |result| 
            begin
              results << { :title => result["Title"], :url => result["Url"], :content => result["Description"] }
            rescue
              Display.error "Something went wrong parsing a result at #{$options[:start]} with query #{$options[:query]}"
            end
          end
        rescue
          Display.error "The doc fail at #{$options[:start]} with query #{$options[:query]}"
        end
        return results #[{:title => "", :url => "", :content => ""},..,{}]
      end

      def baidu
        doc = Nokogiri::HTML(open("http://www.baidu.com/s?wd=" + @options[:query] + "&rn=100&pn=" + @options[:start].to_s))
        # For the first search extract results.
        if @options[:start] == 0
          if doc.search('span[@class="nums"]') != nil
            @options[:results] = doc.search('span[@class="nums"]').text.gsub(/[^0-9]*/,"").to_i
          else
            Display.error "No results were found."
            @options[:results] = 0
            return []
          end
        end    
        # create results array. 
        results = []
        begin
          doc.search('table[@class="result"]').each do |result| 
            begin
              results << { :title => result.search('h3[@class="t"]').text, 
                           :url => result.search('h3[@class="t"]').children[0]['href'], 
                           :content => result.search('font').text.stri }
            rescue
              Display.error "Something went wrong parsing a result at #{@options[:start]} with query #{@options[:query]}"
            end
          end
        rescue
          Display.error "The doc fail at #{@options[:start]} with query #{@options[:query]}"
        end
        return results #[{:title => "", :url => "", :content => ""},..,{}]
      end

      def search_engine(&block)
        begin
          while total?
            Display.msg "Searching from #{@options[:start]} to #{_end_}"
            block.call
            add
          end
        rescue Exception => e
          Display.msg "Something went wrong with Search. " + e
        end
      end

      private
      def total?
      ( @options[:stop].to_i >= @options[:start].to_i + @info[:num] && @options[:results] >= @options[:start].to_i ) ? true : false
      end

      def _end_
        (@options[:start].to_i + @info[:num].to_i) > @options[:results] ? @options[:results] : @options[:start].to_i + @info[:num]
      end

      def add
        @options[:start] = @options[:start].to_i + @info[:num]
      end
    end
  end
end 

#      private    
#     def get(url, port, querystring = "/", headers = {}, limit = 10, &block)
#       http = Net::HTTP.new(url,port)
#       begin
#         http.start do |http|
#           request = Net::HTTP::Get.new(querystring, headers)
#           response = http.request(request)
#           case response
#           when Net::HTTPSuccess
#             block.call(response)
#           when Net::HTTPRedirection
#             get(URI.parse(response['location']).host, 
#                 URI.parse(response['location']).port.to_i,
#                 querystring, headers, limit - 1, &block)
#           else
#             return response.error!
#           end
#         end
#       rescue Net::HTTPFatalError
#         D "Error: Something went wrong with the HTTP request"
#       rescue Net::HTTPServerException
#         D "Error: Something went wrong with the HTTP request"
#       rescue 
#         D "Error: Something went wrong :( + #{$!}"
#       end
#     end
#             
#     def header
#       begin
#         return self.class::OPTS[:header]
#       rescue
#         return {'User-Agent' => UserAgent::fetch}
#       end
#     end
#     
#     
#     def total
#       @options[:stop] > @options[:results] ? @options[:results] : @options[:start]
#     end
#     
#     def parse(object)
#       case object
#       when Array
#         parse_html object
#       when Json
#         parse_json object
#       end
#     end
#         
#     def document?(url)
#       url.scan(/(.pdf$|.doc$|.docx$|.xlsx$|.pptx$|.odt$|.odp$|.ods$|.odb$|.txt$|.rtf$|.ans$|.csv$)/i) == [] ? false :true
#     end

#     def parse_html ( array )
#       array.each do |a|
#         case a[0]
#         when /(PDF|DOC|XLS|PPT|TXT)/
#           @documents << [a[1],"."+$1.to_s.downcase]
#         when nil
#           if a[2] =~ /(.pdf$|.doc$|.docx$|.xlsx$|.pptx$|.odt$|.odp$\
#.ods$|.odb$|.txt$|.rtf$|.ans$|.csv$)/i
#             @documents << [a[2],$1.to_s.downcase]
#           end
#         when /(.pdf$|.doc$|.docx$|.xlsx$|.pptx$|.odt$|.odp$|.ods$|.odb$|.txt$|.rtf$|.ans$|.csv$)/i
#           @documents << [CGI.unescape(a[2] || ""),$1.to_s.downcase]
#         else
#           #D "I do not parse this doc's \"#{a}\" filetype yet:)"
#         end
#       end
#     end
#     
#     def parse_json ( json )
#       json.each do |j|
#         case j["url"]
#         when /(.pdf$|.doc$|.docx$|.xlsx$|.pptx$|.odt$|.odp$|.ods$|.odb$|.txt$|.rtf$|.ans$|.csv$)/i
#           @documents << [j["url"],$1.to_s.downcase]
#         else
#           @urls << [j["url"],$1.to_s.downcase]
#         end
#       end
#     end
#     
#     def crawler(text)
#       self.class::TYPE < 2 ? crawl_emails(text) : crawl_people(text)
#     end
#         
#     def crawl_emails(text)
#       list = text.scan(/[a-z0-9!#$&'*+=?^_`{|}~-]+(?:\.[a-z0-9!#$&'*+=?^_`{|}~-]+)*_at_\
#?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z](?:[a-z-]*[a-z])?|\
#a-z0-9!#$&'*+=?^_`{|}~-]+(?:\.[a-z0-9!#$&'*+=?^_`{|}~-]+)*\sat\s(?:[a-z0-9](?:[a-z0-9-]\
#[a-z0-9])?\.)+[a-z](?:[a-z-]*[a-z])?|[a-z0-9!#$&'*+=?^_`{|}~-]+\
#?:\.[a-z0-9!#$&'*+=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z](?:[a-z-]*[a-z])?|\
#a-z0-9!#$&'*+=?^_`{|}~-]+(?:\.[a-z0-9!#$&'*+=?^_`{|}~-]+)*\s@\s(?:[a-z0-9](?:[a-z0-9-]*\
#a-z0-9])?\.)+[a-z](?:[a-z-]*[a-z])?|[a-z0-9!#$&'*+=?^_`{|}~-]+(?:\sdot\s[a-z0-9!#$&'*+=?^_`\
#|}~-]+)*\sat\s(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\sdot\s)+[a-z](?:[a-z-]*[a-z])??/i)
#       #print_(list)
#       c_list = fix(list)
#       @emails.concat(c_list).uniq!
#       c_list.zip do |e| 
#         @results << [e[0], "E", "",self.class.to_s.upcase, 
#             e[0].downcase.match(/#{CGI.unescape(@query).gsub("@","").split('.')[0]}/) ? "T" : "F"]
#       end
#     end
# 
#     def fix(list)
#       list.each do |e|
#         e.gsub!(" at ","@")
#         e.gsub!("_at_","@")
#         e.gsub!(" dot ",".")
#         e.gsub!(/[+0-9]{0,3}[0-9()]{3,5}[-]{0,1}[0-9]{3,4}[-]{0,1}[0-9]{3,5}/,"")
#       end
#     end
#     
#     def help
#       raise "This is just a container. Help should be define in your plugin."
#     end

#     def crawl_people(text)
#       raise "This is just a container"
#     end