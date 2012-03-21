
#require 'rubygems'
require 'httparty'
require 'nokogiri'
require 'mysql2'
require 'logger'

class WebCrawler

    @@crawler_version = "Web Crawler version 0.0.2";

    attr_accessor :url, :seen_url

    def version
        @@crawler_version
    end

    def initialize
        $log = Logger.new(STDOUT)
        #$log.level = Logger::DEBUG
        $log.level = Logger::INFO
        $log.debug('initialize') {"WebCrawler created"}
        @url = URL.new
    end

    def init(url)
        $log.debug('init') {"start with #{url}"}
        get(url)
    end

    def get(url)
        $log.debug('get') {"request to get '#{url}'"}
        begin
            begin
                body = HTTParty.get("http://#{url}").body
            rescue
                body = HTTParty.get("http://www.#{url}").body
            end
            parse(body)
        rescue => detail
            $log.error('get') {"Can't fetch url: #{url}: #{detail.message}"}
        end
    end

    def parse(body)
        $log.debug('parse') {"parsing"}
        begin
            body = Nokogiri.parse(body);
            extractUrl(body);
        rescue => detail
            $log.error('parse') {"Can't parse: #{detail.message}"}
        end
    end

    def extractUrl(body)
        $log.debug('extractUrl') {"extracting url"}
        seen = Array.new
        begin
            body.search('a').each do |a|
                if ((nil != a['href']) and (nil != url = a['href'].match(/http:\/\/(?:[\w\d\-\.]{1,64}\.)?([\w\d\-]{1,64}\.\w{2,4})/))) then
                    if (! seen.include?(url[1])) then
                        @url.add url[1]
                        seen.push url[1]
                    end
                end
            end
        rescue => detail
            $log.error('extractUrl') {"Can't extract URL: #{ detail.message}"}
        end
    end

    def dump
        p @url
    end

    def session
    end

    def step
        $log.debug('step') {"run"}
        if (nil != url = @url.next_url) then
            $log.info('step') {"#{url['url']}"}
            get(url['url']);
        end
    end

    def queue
        url.unseen
    end

end

class WebCrawler::URL
    def initialize
        $log.debug('url.initialize') {'Initialization'}

        dbhost = 'localhost'
        dbport = 3306
        dbuser = 'webcrawler'
        dbpass = 'RiNChdOuD48On35S'
        dbbase = 'webcrawler_development'

        begin
            @client = Mysql2::Client.new(:host => dbhost, :port => dbport, :username => dbuser, :password => dbpass, :database => dbbase)
        rescue => detail
            $log.error('url.initialize') {"Error on connect to mysql: #{detail.message}"}
            @client.close if @client
        end
    end

    def add(url)
        $log.debug('url.add') {"#{url}"}
        begin
            #puts "add: #{url}"
            @client.query("INSERT IGNORE INTO `urls` SET `url`='#{url}', `created_at`=NOW()")
        rescue => detail
            $log.error('url.add') {"Error on insert to mysql: #{detail.message}"}
        end
    end

    def get
    end

    def get_by_url(url)
        $log.debug('url.get_by_url') {"run"}
        begin
            url = @client.escape(url);
            results = @client.query("SELECT `id` FROM `urls` WHERE `url` = '#{url}'");
            results
        rescue => detail
            $log.error('url.get_by_url') {"Error on query to mysql: #{detail.message}"}
        end
    end

    def total
        $log.debug('url.total') {"run"}
        begin
            query = @client.query("SELECT count(`id`) FROM `urls`");
            query.each do |row|
                result = row["id"]
            end
            $log.debug('url.total') {"#{total}"}
            result
        rescue => detail
            $log.error('url.total') {"Error on query to mysql: #{detail.message}"}
        end
    end

    def know?(url)
    end

    def seen!
    end

    def count(url)
        $log.debug('url.count') {"run"}
        result = get_by_url(url)
        $log.debug('url.count') {"#{result.count}"}
        result.count
    end

    def next_url(unseen=0)
        $log.debug('next_url') {"run"}
        begin
            @client.query("LOCK TABLES `urls` WRITE")
            # Next must return "WHERE `updated` IS NULL" and "WHERE `updated` < NOW()-1DAY"
            query = @client.query("SELECT `id`, `url` FROM `urls` WHERE `updated_at` IS NULL OR `updated_at` < DATE_SUB(NOW(), INTERVAL 7 DAY) LIMIT 1")
            if  query.each.empty? then
                query = @client.query("SELECT `id`, `url` FROM `urls` ORDER BY `updated_at` limit 1")
            end
            url = nil
            query.each do |row|
                url = row
                @client.query("UPDATE `urls` SET `updated_at` = CURRENT_TIMESTAMP WHERE `id` = '#{url['id']}'") unless unseen == 1
                $log.debug('url.next_url') {"next url: #{url['url']}"}
            end
            url
        rescue => detail
            $log.error('url.next_url') {"Error on query to mysql: #{detail.message}"}
        ensure
            @client.query("UNLOCK TABLES")
        end
    end

    def unseen
        $log.debug('url.unseen') {"run"}
        begin
            result = next_url(1).nil? ? 0 : 1
            $log.debug('url.unseen') {"unseen: #{result}"}
            result
        
        rescue => detail
            $log.error('url.unseen') {"Error on query to next_url: #{detail.message}"}
        end
    end


    def seen?(url)
        $log.debug('url.seen?') {"ask: #{url}"}
        result = get_by_url(url) 
        dresult = result.count == 0 ? 'unseen' : 'seen'
        $log.debug('url.seen?') {"answer: #{url} #{dresult}"}
        result == 0 ? false : true
    end
end
