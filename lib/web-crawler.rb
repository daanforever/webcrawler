
#require 'rubygems'
require 'httparty'
require 'nokogiri'
require 'mysql.so'

class WebCrawler

    @@crawler_version = "Web Crawler version 0.0.1";

    attr_accessor :url, :seen_url

    def version
        @@crawler_version
    end

    def initialize
        @url = URL.new
    end

    def init(url)
        get(url)
    end

    def get(url)
        begin
            body = HTTParty.get(url).body;
            parse(body)
        rescue => detail
            puts "Can't fetch url: " + url + ": " + detail.message
        end
    end

    def parse(body)
        begin
            body = Nokogiri.parse(body);
            extractUrl(body);
        rescue => detail
            puts "Can't parse: " + detail.message
        end
    end

    def extractUrl(body)
        begin
            body.search('a').each do |a|
                if ((nil != a['href']) and (nil != url = a['href'].match(/http:\/\/([\w\d\-\.]{4,64})/))) then
                    #url.add(url[1]) if ! url.seen?(url[1])
                end
            end
        rescue => detail
            puts "Can't extract URL: " + detail.message
        end
    end

    def dump
        p @url
    end

    def session
    end

    def step
        #p @url
        #if (nil != curr_url = @url.shift) then
        #    @seen_url.push(curr_url)
        #    puts "url.size=#{url.size} seen_url.size=#{seen_url.size} Current url=#{curr_url}"
        #    get("http://#{curr_url}");
        #end
    end

    def queue
        #url.size
        0
    end

    def url_new(key, value)
        @@cache.set(key, value)
    end
end

class WebCrawler::URL
    def initialize
        dbhost   = 'localhost'
        dbuser   = 'webcrawler'
        dbpass   = 'RiNChdOuD48On35S'
        dbbase   = 'webcrawler'
        #@@db    = Mysql2::Client.new(:host => dbhost, :username => dbuser, :password => dbpass, :database => dbbase, :encoding => 'utf8')

        begin
            @@dbh    = Mysql::connect(dbhost, dbuser, dbpass, dbbase)
        rescue Mysql::Error => e
            puts "Error code: #{e.errno}"
            puts "Error message: #{e.error}"
            puts "Error SQLSTATE: #{e.sqlstate}" if e.respond_to?("sqlstate")
        ensure
            @@dbh.close if @@dbh
        end
    end

    def add(url)
        
    end

    def get
    end

    def know?(url)
    end

    def seen!
    end

    def seen?(url)
    end
end
