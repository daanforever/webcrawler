
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
        r = HTTParty.get(url).body;
        r = Nokogiri.parse(r);
        hash = Hash.new
        r.search('a').each do |a|
            url = a['href'].match(/http:\/\/([^\/]+)/)[1] 
            hash[url] = 1
        end
        hash
    end

    def dump
    end

    def session
    end

    def step
    end
end

