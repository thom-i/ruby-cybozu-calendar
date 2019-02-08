require 'yaml'
require 'mechanize'
require 'nokogiri'
require 'csv'
require 'date'
require './lib/post_to_slack.rb'

conf = YAML.load_file("config.yaml")

agent = Mechanize.new

# サイボウズにログイン
page = agent.get(conf["url"])
form = page.forms.first
form.field_with(:name => "_ID").value = conf["username"]
form.field_with(:name => "Password").value = conf["password"]
result = form.submit

# ログイン後のHTMLを取得
doc = Nokogiri::HTML(result.content.toutf8)
message = []
message.push("```")

# 日付チェック
day_tmp = ""

doc.css("div.eventInner").each do |title|
  day = title.css('a.event').to_s.match(/GID=&amp;Date=da.(.+)&amp;BDate=/)[1].gsub(".","-")
  week = %w(日 月 火 水 木 金 土)[Date.parse(day).wday]
  message.push("\n" + day + "(" + week + ")\n") if day_tmp != day
  message.push(title.css('span').inner_text)
  message.push("\n")
  day_tmp = day
end

message.push("```")

# 前回保存されたスケジュールを読み込む
before_schedule = ""
File.open("schedule.txt", "r") do |f|
  before_schedule = f.read
end

# 前回実行時のスケジュールと差分があればSlackに通知
if before_schedule.chomp != message.join
  PostToSlack.notify(message.join, conf["slackchid"], conf["webhook"])
end

# 今回取得したスケジュールを保存
File.open("schedule.txt", "w") do |f|
  f.puts(message.join)
end