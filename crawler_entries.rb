# URLにアクセスするためのライブラリを読み込む
require 'open-uri'
# HTMLをパースするためのライブラリを読み込む
require 'nokogiri'
# 日付ライブラリの読み込み
require "date"

require "uri"

require 'eventmachine'

require 'gcm'

require './app'

### デーモン化処理
pid_file = "./tmp/pids/crawler_entries.pid"
# 第2引数にfalseを指定して標準出力を"/dev/null" へリダイレクトする
Process.daemon(true, false)
# 起動後にプロセスidを保持する
open(pid_file, 'w') {|f| f << Process.pid} if pid_file

### 記事収集処理
BaseUrl = "http://www.keyakizaka46.com"
BlogBaseUrl = "http://www.keyakizaka46.com/mob/news/diarKiji.php?cd=member&ct="

def parse_for_key key
  return if key == nil
  parsepage(BlogBaseUrl + key, false) { |data|
    yield(data) if block_given?
  }
end

def parse url
  parsepage(url) { |data|
    yield(data) if block_given?
  }
end

# 1記事から情報を取得する
def parsepage url, loop=true
  puts "parsepage in : #{url}"

  page = Nokogiri::HTML(open(url))

  page.css('article').each do |article|

    data = {}
    data[:title] = normalize article.css('.box-ttl > h3').text
    data[:published] = normalize article.css('.box-bottom > ul > li')[0].text
    data[:published] = DateTime.parse(data[:published])

    data[:url] = BaseUrl + article.css('.box-bottom > ul > li')[1].css('a')[0][:href]
    data[:url] = url_normalize data[:url]

    image_url_list = Array.new()
    article.css('.box-article').css('img').each do |img|
      image_url_list.push(BaseUrl + img[:src])
    end
    data[:image_url_list] = image_url_list

    yield(data) if block_given?
  end

  return if !loop

  page.css('.pager > ul > li').each do |li|
    puts "no more page" if li.text == '>'
    parse(BaseUrl + li.css('a')[0][:href]) { |data|
      yield(data) if block_given?
    } if li.text == '>'
  end
end

def normalize str
  str.gsub(/(\r\n|\r|\n|\f)/,"").strip
end

def url_normalize url
  # before
  # http://www.keyakizaka46.com/mob/news/diarKijiShw.php?site=k46o&ima=0445&id=405&cd=member
  # after
  # http://www.keyakizaka46.com/mob/news/diarKijiShw.php?id=405&cd=member
  uri = URI.parse(url)
  q_array = URI::decode_www_form(uri.query)
  q_hash = Hash[q_array]
  "http://www.keyakizaka46.com/mob/news/diarKijiShw.php?id=#{q_hash['id']}&cd=member"
end

def save_data data, member
  data[:member_id] = member['id']
  entry = Api::Entry.new
  data.each { |key, val|
    entry[key] = val
  }
  result = entry.save
  yield(result, data) if block_given?
end

def is_new? data
  Api::Entry.where('url = ?', data[:url]).first == nil
end

def get_all_entry
  puts Api::Member.all.order(key: :desc).count
  Api::Member.all.order(key: :desc).each do |member|
    parse_for_key(member['key']) { |data|
      save_data(data, member) if is_new? data
    }
  end
end

def routine_work
  Api::Member.all.order(key: :desc).each do |member|
    parse_for_key(member['key']) { |data|
      save_data(data, member) { |r, d|
        push_notification d
      } if is_new? data
    }
  end
end

def push_notification data

  registeration_ids = Array.new
  Api::Fcm.all.each do |fcm|
    registeration_ids.push fcm['reg_id']
  end

  send_data = {}
  e = Api::Entry.where(url: data[:url]).limit(1)
  data.each { |key, val|
    send_data[key] = val
  }

  gcm = GCM.new(API_KEY) # TODO: APIキーを設定するとこ
  # :data の内容が extras に格納される
  option = { :data => send_data }
  gcm.send_notification(registration_ids, option)
end

# すべての記事を取得する
get_all_entry

EM.run do
  EM::PeriodicTimer.new(60) do
    # 1ページのみ取得する
    routine_work
  end
end
