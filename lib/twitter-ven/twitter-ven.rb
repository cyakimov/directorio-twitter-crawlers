# coding: utf-8
require 'nokogiri'
require_relative '../storage'
require_relative '../hydra'

class TwitterVenezuela
  include Storage, Hydra
  attr_accessor :users, :categories

  def initialize(url)
    @categories = []
    @users = []
    init_storage
    init_hydra url,10    
  end
 
  def fetch_categories
    req = get
    doc = Nokogiri::HTML(req.body)
    #Fetch all main categories url
    doc.xpath('id("rightcolumn")//h2[text()="Categorías de twitteros..."]/../ul//a').each do |link|
      l_url = link.xpath('@href').first.content
      @categories << l_url
      queue l_url
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

    doc.xpath('id("listado")//tr').each do |row|
      usuario = row.xpath('td[3]//a').first
      next if usuario == nil

      username,name = usuario.inner_html.split("<br>")
      username['@'] = ''

      #profile pic
      pic = row.xpath('td[2]/img/@src').first.content

      #bio
      bio = row.xpath('td[3]//a/@title').first.content

      #followers
      followers = row.xpath('td[4]').first.content.to_i

      #following
      following = row.xpath('td[5]').first.content.to_i

      #on twitter since
      since = row.xpath('td[8]').first.content

      #tag
      tag = row.xpath('td[10]').first.content.gsub(/\.+/,'') #replace dots

      #ref => 1 (twitter-venezuela)
      doc = {"username" => username, "name" => name, "bio" => bio, "pic" => pic,
        "since" => since, "followers" => followers,"following" => following, "tags" => tag, "ref"=>1}
      @users << doc
    end
  end

  def run
    fetch_categories    
    @hydra.run
  end
  
end