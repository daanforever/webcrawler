#!/usr/bin/env ruby

require './lib/web-crawler.rb'

# Algorithm:
#  ├┬ Check for last session
#  │└─ If none session available init with http://dron.me/
#  ├─ slkej
#  ├─ sdfsd
#  └─ dfasd

threads = []
WebCrawler.new.init('dron.me');
1.upto 20 do
    threads << Thread.new do
        crawler = WebCrawler.new();
        while(crawler.queue > 0) do
            crawler.step();
        end
    end
end
threads.each { |aThread|  aThread.join }
#crawler.dump();

