require "feedbag"
require "feedjira"

require "date"
require 'eventmachine'

require "./app"

ROUTINE_TIME = 60 * 30 #30分

url_list = [
  "http://keyakizaka46ch.jp",
  "http://keyakizaka1.blog.jp",
  "http://keyakizakamatome.blog.jp",
  "http://keyaki46.2chblog.jp",
  "http://torizaka46.2chblog.jp",
  "http://keyakizaka46torimatome.com",
  "http://www.keyakizaka46matomerabo.com"
]

### デーモン化処理
pid_file = "./tmp/pids/crawler_matomes.pid"
# 第2引数にfalseを指定して標準出力を"/dev/null" へリダイレクトする
Process.daemon(true, false)
# 起動後にプロセスidを保持する
open(pid_file, 'w') {|f| f << Process.pid} if pid_file

def normalize str
  str.gsub(/(\r\n|\r|\n|\f)/,"").strip
end

def fetch_rss_feed
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
end

EM.run do
  EM::PeriodicTimer.new(ROUTINE_TIME) do
    fetch_rss_feed
  end
end
