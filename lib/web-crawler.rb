
require 'rubygems'
require 'httparty'
require 'nokogiri'
#require 'uri'

class WebCrawler

    @crawler_version = "Web Crawler version 0.0.1";

    def self.version
        @crawler_version;
    end

    def initialization
    end

    def init(url)
        self.get(url)
    end

    def get(url)
        begin
            r = HTTParty.get(url).body;
            r = Nokogiri.parse(r);
            @hash = Hash.new
            r.search('a').each do |a|
                if (nil != a['href']) then
                    if (nil != newurl = a['href'].match(/http:\/\/([^\/]+)/)) then
                        @hash[newurl[1]] = 1
                    end
                end
            end
        rescue => detail
            puts "Can't fetch url: " + url + ":\n" + detail.message
        end
        @hash
    end

    def dump
    end

    def session
    end

    def step
        p @hash
    end
end

