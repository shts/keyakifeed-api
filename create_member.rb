# URLにアクセスするためのライブラリを読み込む
require 'open-uri'

# HTMLをパースするためのライブラリを読み込む
require 'nokogiri'

require './app'

Max = 23
BaseUrl = "http://www.keyakizaka46.com"
# http://www.keyakizaka46.com/mob/arti/artiShw.php?cd=01
BaseProfileUrl = "http://www.keyakizaka46.com/mob/arti/artiShw.php?cd="

def get_all_member
  Max.times do |i|
    next if i == 0 || i == 16
    num = i.to_s
    num = "0" + i.to_s if i < 10
    parse(num) { |data|
      update data
    }
  end
end

def update data
  if Api::Member.where("key = ?", data[:key]).first == nil then
    new_member = Api::Member.new
    data.each { |key, val|
      new_member[key] = val
    }
    new_member.save
  else
    puts "already registration"
  end
end

def parse(num)

  data = {}
  data[:key] = num

  url = BaseProfileUrl + num
  doc = Nokogiri::HTML(open(url))

  status = Array.new()
  doc.css('ul.tag').each do |tag|
    status.push(tag.css('li').text)
  end
  data[:status] = status

  data[:name_main] = normalize doc.css('.box-profile_text').css('.name').text
  data[:name_sub] = normalize doc.css('.box-profile_text').css('.furigana').text
  # 公式バグ
  #puts doc.css('.box-profile_text').css('.en').text.gsub(/(\r\n|\r|\n|\f)/,"")
  data[:image_url] = BaseUrl + doc.css('.box-profile_img > img')[0][:src]
  data[:message_url] = BaseUrl + doc.css('.box-msg').css('.slide').css('img')[0][:src]

  counter = 0
  doc.css('.box-profile_text').css('.box-info').css('dl').css('dt').each do |child|
    if counter == 0 then
      data[:birthday] = normalize child.text.gsub("年", "/").gsub("月", "/").gsub("日", "")
    elsif counter == 1
      data[:constellation] = normalize child.text
    elsif counter == 2
      data[:height] = normalize child.text
    elsif counter == 3
      data[:birthplace] = normalize child.text
    elsif counter == 4
      data[:blood_type] = normalize child.text
    end
    counter = counter + 1
  end

  yield(data) if block_given?
end

def normalize str
  str.gsub(/(\r\n|\r|\n|\f)/,"").strip
end

get_all_member
