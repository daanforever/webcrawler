
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
            body = HTTParty.get(url).body;
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
        begin
            body.search('a').each do |a|
                if ((nil != a['href']) and (nil != url = a['href'].match(/http:\/\/(?:[\w\d\-\.]{1,64}\.)?([\w\d\-]{1,64}\.\w{2,4})/))) then
                    @url.add url[1]  if ! @url.seen? url[1]
                    #puts "Not seen #{url[1]}"  if ! @url.seen? url[1]
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
        #p @url
        $log.debug('step') {"run"}
        if (nil != url = @url.next) then
            #puts "total=#{@url.total} unseen=#{@url.unseen} current=#{url}"
            #puts "#{url}"
            $log.info('step') {"#{url}"}
            get("http://#{url}");
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
        dbbase = 'webcrawler'

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
            @client.query("INSERT IGNORE INTO `url` SET `url`='#{url}'")
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
            results = @client.query("SELECT `id` FROM `url` WHERE `url` = '#{url}'");
            results
        rescue => detail
            $log.error('url.get_by_url') {"Error on query to mysql: #{detail.message}"}
        end
    end

    def unseen
        $log.debug('url.unseen') {"run"}
        begin
            query = @client.query("SELECT `id` FROM `url` WHERE `updated` IS NULL LIMIT 1");
            result = 0;
            query.each do |row|
                result = row["id"]
            end
            $log.debug('url.unseen') {"unseen: #{result}"}
            result
        
            #if (! row.nil?) then
            #    puts "unseen: #{row[1]}"
            #    row[1].nil? ? 0 : row[1]
            #end
        rescue => detail
            $log.error('url.unseen') {"Error on query to mysql: #{detail.message}"}
        end
    end

    def total
        $log.debug('url.total') {"run"}
        begin
            query = @client.query("SELECT count(`id`) FROM `url`");
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

    def next
        $log.debug('next') {"run"}
        begin
            @client.query("LOCK TABLES `url` WRITE")
            query = @client.query("SELECT `id`, `url` FROM `url` WHERE `updated` IS NULL LIMIT 1")
            url = ''
            query.each do |row|
                url = row
                @client.query("UPDATE `url` SET `updated` = CURRENT_TIMESTAMP WHERE `id` = '#{url['id']}'")
                @client.query("UNLOCK TABLES")
                $log.debug('url.next') {"next url: #{url}"}
            end
            url
        rescue => detail
            $log.error('url.next') {"Error on query to mysql: #{detail.message}"}
        end
    end

    def seen?(url)
        $log.debug('url.seen?') {"ask: #{url}"}
        result = count(url) 
        dresult = result == 0 ? 'unseen' : 'seen'
        $log.debug('url.seen?') {"answer: #{url} #{dresult}"}
        result == 0 ? false : true
    end
end
