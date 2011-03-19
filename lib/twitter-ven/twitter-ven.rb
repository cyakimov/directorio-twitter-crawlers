# coding: utf-8
require 'typhoeus'
require 'nokogiri'

class Scrapper
  attr_accessor :users,:users_count

  def initialize(url)
    @url = url
    @user_agent = 'Googlebot/2.1 (+http://www.google.com/bot.html)'    
    @users = Hash.new
    @users.default=Array.new
    @users_count = 0
    @hydra = Typhoeus::Hydra.new(:max_concurrency => 10)
  end

  def queue(url)
    r = Typhoeus::Request.new(url, :user_agent =>@user_agent)
    r.on_complete(&method(:process_html))
    @hydra.queue(r)
    #puts 'On queue => ' + r.url
  end
 
  def fetch_categories
    req = Typhoeus::Request.get(@url, :user_agent =>@user_agent)
    doc = Nokogiri::HTML(req.body)
    #Fetch all main categories url
    doc.xpath('id("rightcolumn")//h2[text()="Categorías de twitteros..."]/../ul//a').each do |link|
      queue link.xpath('@href').first.content
      #break
    end
  end

  def process_html(res)
    url = res.effective_url
    #puts "Completed => #{url}"

    doc = Nokogiri::HTML(res.body.force_encoding('UTF-8'))

    #check if we arent in a subpage
    if(/pag=\d+/ !~ url)
      #get all subpages
      doc.xpath('id("leftcolumn")//div[@align="center"][1]/a/@href').each do |link|
        queue url+link.value
      end
    end

    cat = doc.xpath('id("leftcolumn")//h1').first.content rescue nil

    doc.xpath('id("listado")//tr').each do |row|
      usuario = row.xpath('td[3]//a').first
      next if usuario == nil
      info = []

      usuario = usuario.inner_html
      usuario['<br>'] = ':'

      #username
      info << usuario

      #profile pic
      info << row.xpath('td[2]/img/@src').first.content

      #descripcion
      #info << row.xpath('td[3]//a/@title').first.content

      #followers
      info << row.xpath('td[4]').first.content

      #following
      info << row.xpath('td[5]').first.content

      #tweets number
      info << row.xpath('td[6]').first.content

      #lists number
      info << row.xpath('td[7]').first.content

      #on twitter since
      info << row.xpath('td[8]').first.content

      #tag
      info << row.xpath('td[10]').first.content.gsub(/\.+/,'')

      @users[cat] += [info.join('|')]
      @users_count +=1
    end
  end

  def run
    fetch_categories    
    @hydra.run
  end
  
end

puts "Running pid #{Process.pid}"

obj = Scrapper.new 'http://www.twitter-venezuela.com/'
obj.run

puts "Total users #{obj.users_count}"

File.open("twitter-ven.txt", "w") do |f|
  obj.users.each do |cat,users|
    users.each do |user|
      f.puts "#{cat}:#{user}"
    end
  end
end

puts
puts '<----- END ----->'