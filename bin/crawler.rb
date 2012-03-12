#!/usr/bin/env ruby

require './lib/web-crawler.rb'

# Algorithm:
#  ├┬ Check for last session
#  │└─ If none session available init with http://dron.me/
#  ├─ slkej
#  ├─ sdfsd
#  └─ dfasd

crawler = WebCrawler.new();

crawler.init('http://dron.me') unless crawler.session();
crawler.step();
crawler.dump();

