# URLにアクセスするためのライブラリを読み込む
#require 'open-uri'

# XMLをパースするためのライブラリを読み込む
#require 'rexml/document'

# Doc
# http://feedjira.com/
# https://github.com/feedjira/feedjira
# http://stackoverflow.com/questions/2481285/ruby-feedzirra-and-updates/2487826#2487826
# http://xoyip.hatenablog.com/entry/2014/01/20/201703
# http://ruby-doc.org/stdlib-2.2.3/libdoc/rss/rdoc/RSS.html

# Source
# Entry Object
# https://github.com/feedjira/feedjira/blob/master/lib/feedjira/parser/rss_entry.rb

# Sample
# https://binarapps.com/blog/feedjira-with-rails/
# http://raspygold.com/ruby-rss-atom-feed-parsing/

require "feedbag"
require "feedjira"

require "./app"

require_relative 'useragent'

url_list = [
  "http://keyakizaka46ch.jp",
  "http://keyakizaka1.blog.jp",
  "http://keyakizakamatome.blog.jp",
  "http://keyaki46.2chblog.jp",
  "http://torizaka46.2chblog.jp",
  "http://keyakizaka46torimatome.com",
  "http://www.keyakizaka46matomerabo.com"
]

def normalize str
  str.gsub(/(\r\n|\r|\n|\f)/,"").strip
end

url_list.each do |site_url|
  feed_urls = Feedbag.find site_url
  feed = Feedjira::Feed.fetch_and_parse feed_urls.first

  feed.entries.each do |entry|
    matome = Api::Matome.new
    matome[:feed_title] = feed.title
    matome[:feed_url] = feed.url
    matome[:entry_title] = entry.title
    matome[:entry_url] = entry.url
    matome[:entry_published] = entry.published
    matome[:entry_categories] = entry.categories
    matome.save
  end
end

=begin
feed_urls = Feedbag.find "http://keyakizaka1.blog.jp/"
p feed_urls.first
feed = Feedjira::Feed.fetch_and_parse feed_urls.first
#p feed
p feed.title
p feed.url
p feed.last_modified
#p feed.entries
feed.entries.each do |entry|
  p "-----------------------------"
  p entry.title
  p entry.url
  p entry.published
  #p entry.author
  #p entry.content
  #p entry.entry_id
  p entry.categories
  #p entry.summary
=end
