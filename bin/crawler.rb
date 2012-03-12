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

crawler.init('http://dron.me') unless crawler.session();
crawler.step();
crawler2.init('http://yandex.ru') unless crawler.session();
crawler2.step();
crawler.dump();

