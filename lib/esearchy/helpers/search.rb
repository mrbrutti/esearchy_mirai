require 'open-uri'
require 'nokogiri'

module ESearchy
  module Helpers
    module Search      
      def google
        Display.debug "Entering Google Search for query= #{"http://www.google.com/cse?&safe=off&num=100&site=&q=" +  @options[:query]  + "&btnG=Search&start=" + @options[:start].to_s}"

        begin 
          search = open("http://www.google.com/cse?&safe=off&num=100&site=&q=" +  @options[:query]  + "&btnG=Search&start=" + @options[:start].to_s)
        rescue Exception => e
          Display.error "Something went wrong while rendering the page #{e.to_s}"
        end

        doc = Nokogiri::HTML(search)
        # For the first search extract results.
        if @options[:start] == 0 
          result_qnty = doc.search('div[@id="resultStats"]')
          if result_qnty != nil
            @options[:results] = result_qnty.text.scan(/([0-9,]*) result/).to_s.gsub(",","").to_i
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
          doc.search('div[@id="ires"]')[0].search('li[@class="g"]').each do |result| 
            begin
              url = result.search('h3[@class="r"]')[0].search('a')[0]['href']
              if url.match(/\/url\?q=/) != nil
                res_url = url.scan(/\/url\?q=([0-9A-Za-z:\\\/?=@+%.;"'()_-]+)\&/).join
              else
                res_url = url
              end

              results << { :title => result.search('h3[@class="r"]')[0].search('a')[0].text, 
                           :url => res_url, 
                           :content => result.search('span[@class="st"]')[0].text }
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
        begin 
          search = open("https://api.datamarket.azure.com/Bing/Search/Web?Query=%27" + 
                        CGI.escape(@options[:query]) + "%27&$format=json&$top=50&$skip=" + @options[:start].to_s , 
                        :http_basic_authentication=>[$globals[:bingkey],$globals[:bingkey]]).readlines[0]
        rescue Exception => e
          Display.error "It looks like were are being blocked (#{e.to_s}). Change engine."
        end

        doc = JSON.parse(search)

        # OLD URL
        # doc = JSON.parse(open("http://api.search.live.net/json.aspx?AppId=" + $globals[:bingkey] + 
        #                      "&query=" + @options[:query] + "&Sources=Web&Web.Count=50&Web.Offset=" + @options[:start].to_s).readlines[0])
        # For the first search extract results. 
        #@options[:results] = doc["SearchResponse"]["Web"]["Total"].to_i if @options[:start] == 0
        # create results array. 
        # No longer providing a total. MSFT sucks even for this :(
        @options[:results] = @options[:stop]

        results = []
        begin
          doc["d"]["results"].each do |result| 
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
        begin
          search = open("http://www.baidu.com/s?wd=" + @options[:query] + "&rn=100&pn=" + @options[:start].to_s)
        rescue Exception => e
          Display.error "It looks like were are being blocked (#{e.to_s}). Change engine."
          return []
        end

        doc = Nokogiri::HTML(search)

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
                           :content => result.search('font').text.strip }
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
          Display.error "Something went wrong with Search. " + e.to_s
          Display.backtrace e.backtrace
        end
      end

      def engine
        #Display.debug "I am checking engine options."
        if @options[:engine].nil?
          google
        else
          #Display.msg "Using non-default engine for search: #{@options[:engine]}"
          case @options[:engine]
          when /google/i
            google
          when /baidu/i
            baidu
          when /bing/i
            bing
          else
            google
          end
        end
      end

      private
      def total?
      ( @options[:stop].to_i >= @options[:start].to_i + 
        @info[:num] && @options[:results] >= @options[:start].to_i ) ? true : false
      end

      def _end_
        (@options[:start].to_i + @info[:num].to_i) > @options[:results] ? 
        @options[:results] : @options[:start].to_i + @info[:num]
      end

      def add
        @options[:start] = @options[:start].to_i + @info[:num]
      end
    end
  end
end