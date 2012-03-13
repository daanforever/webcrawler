
require 'rubygems'
require 'httparty'
require 'nokogiri'
require 'memcached'

class WebCrawler

    @@crawler_version = "Web Crawler version 0.0.1";

    attr_accessor :url, :seen_url

    def version
        @@crawler_version;
    end

    def initialize
        @url = Array.new
        @seen_url = Array.new
    end

    def init(url)
        get(url)
    end

    def get(url)
        begin
            r = HTTParty.get(url).body;
            parse(r)
        rescue => detail
            puts "Can't fetch url: " + url + ": " + detail.message
        end
    end

    def parse(r)
        begin
            r = Nokogiri.parse(r);
            @url.concat extractUrl(r);
        rescue => detail
            puts "Can't parse: " + detail.message
        end
    end

    def extractUrl(body)
        begin
            result = Array.new
            body.search('a').each do |a|
                if ((nil != a['href']) and (nil != url = a['href'].match(/http:\/\/([\w\d\-\.]{4,64})/))) then
                    result.push url[1] if ! (result.include? url[1]) and ! (@url.include? url[1]) and ! (@seen_url.include? url[1])
                end
            end
        rescue => detail
            puts "Can't extract URL: " + detail.message
        end
        result
    end

    def dump
        p @url
    end

    def session
    end

    def step
        #p @url
        if (nil != curr_url = @url.shift) then
            @seen_url.push(curr_url)
            puts "url.size=#{url.size} seen_url.size=#{seen_url.size} Current url=#{curr_url}"
            get("http://#{curr_url}");
        end
    end

    def queue
        url.size
    end

    def url_new(key, value)
        @@cache.set(key, value)
    end
end

class WebCrawler::URL
    def initialize
        @@cache = Memcached.new('localhost:11211')
    end

    def add(url)
        # TODO: may be need to add try/catch?
        @@cache.set(url, 1)
    end

    def get

    end

    def know?
        begin
        rescue
        end
    end
end
