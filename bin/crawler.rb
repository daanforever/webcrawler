#!/usr/bin/env ruby

require './lib/web-crawler.rb'

# Algorithm:
#  ├┬ Check for last session
#  │└─ If none session available init with http://dron.me/
#  ├─ slkej
#  ├─ sdfsd
#  └─ dfasd

crawler = WebCrawler.new();
crawler2 = WebCrawler.new();

puts crawler.version()
crawler.init('http://dron.me') unless crawler.session();
while(crawler.queue>0) do
crawler.step();
end
crawler.dump();

