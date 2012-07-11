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
          elsif doc.search("font")[0] != nil
            @options[:results] = doc.search("font")[0].text.scan(/([0-9]*) result/)[0][0].to_i 
          else
            Display.error "No result amount was found."
            @options[:results] = @options[:stop]
            #return []
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

#         
#     def document?(url)
#       url.scan(/(.pdf$|.doc$|.docx$|.xlsx$|.pptx$|.odt$|.odp$|.ods$|.odb$|.txt$|.rtf$|.ans$|.csv$)/i) == [] ? false :true
#     end
#
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