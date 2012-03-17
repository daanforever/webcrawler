
require 'test/unit'
require '../lib/web-crawler.rb'

class HolaTest < Test::Unit::TestCase
  def test_crawler_version
    assert_equal "Crawler",
      WebCrawler.hi("english")
  end

end
