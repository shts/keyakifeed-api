# URLにアクセスするためのライブラリを読み込む
require 'open-uri'
# HTMLをパースするためのライブラリを読み込む
require 'nokogiri'
# 日付ライブラリの読み込み
require "date"

require "uri"

require './app'

# http://qiita.com/yoshioota/items/4a58d977b4f89078d7d4
#サムネイルURLにスペースが入っているので回避するためのGem
require 'addressable/uri'

require_relative 'useragent'

BaseReportUrl = "http://www.keyakizaka46.com/mob/news/diarShw.php?cd=report"
# http://www.keyakizaka46.com/mob/news/diarShw.php?cd=report
# http://www.keyakizaka46.com/mob/news/diarKijiShw.php?cd=report

def get_all_report
  fetch_report { |data|
    save_data(data) if is_new? data
  }
end

def fetch_report
  begin
    page = Nokogiri::HTML(open(BaseReportUrl, 'User-Agent' => UserAgents.agent))
    page.css('.box-sub').each do |box|
      data = {}
      # uri
      #puts url_normalize "#{box.css('a')[0][:href]}"
      # /mob/news/diarKijiShw.php?site=k46o&ima=5839&id=2539&cd=report
      # "http://www.keyakizaka46.com" + box.css('a')[0][:href]
      data[:url] = url_normalize box.css('a')[0][:href]

      # thumbnail
      # puts thumbnail_url_normalize "#{box.css('.box-img').css('img')[0][:src]}"
      # thumbnail_url_normalize box.css('.box-img').css('img')[0][:src]
      data[:thumbnail_url] = thumbnail_url_normalize box.css('.box-img').css('img')[0][:src]

      # title
      # puts normalize "#{box.css('.box-txt').css('.ttl').css('p').text}"
      data[:title] = normalize box.css('.box-txt').css('.ttl').css('p').text

      # published
      # puts normalize "#{box.css('.box-txt').css('time').text}"
      pub = normalize box.css('.box-txt').css('time').text
      d = pub.split(".")
      data[:published] = DateTime.new(d[0].to_i, d[1].to_i, d[2].to_i)

      #image_url_list
      data[:image_url_list] = Array.new()
      article = Nokogiri::HTML(open(data[:url], 'User-Agent' => UserAgents.agent))
      article.css('.box-content').css('img').each do |img|
        image_url = thumbnail_url_normalize img[:src]
        data[:image_url_list].push image_url
      end

      yield(data) if block_given?
    end
  rescue OpenURI::HTTPError => ex
    puts "******************************************************************************************"
    puts "HTTPError : url(#{url}) retry!!!"
    puts "******************************************************************************************"
    sleep 5
    retry
  end
end

def save_data data
  entry = Api::Report.new
  data.each { |key, val|
    entry[key] = val
  }
  result = entry.save
  yield(result) if block_given?
end

def is_new? data
  Api::Report.where('url = ?', data[:url]).first == nil
end

def normalize str
  str.gsub(/(\r\n|\r|\n|\f)/,"").strip
end

def thumbnail_url_normalize url
  uri = Addressable::URI.parse(url)
  if uri.scheme == nil || uri.host == nil then
    "http://www.keyakizaka46.com" + url
  else
    url
  end
end

def url_normalize url
  # before
  # http://www.keyakizaka46.com/mob/news/diarKijiShw.php?site=k46o&ima=1900&id=1820&cd=report
  # after
  # http://www.keyakizaka46.com/mob/news/diarKijiShw.php?id=1820&cd=report
  uri = URI.parse(url)
  q_array = URI::decode_www_form(uri.query)
  q_hash = Hash[q_array]
  "http://www.keyakizaka46.com/mob/news/diarKijiShw.php?id=#{q_hash['id']}&cd=report"
end

get_all_report
