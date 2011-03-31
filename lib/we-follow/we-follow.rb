# coding: utf-8
require 'nokogiri'
require_relative '../storage'
require_relative '../hydra'

class WeFollow
  include Storage, Hydra
  attr_accessor :users
  
  def initialize(urls)
    @urls = urls
    @users = []
    init_storage
    init_hydra
  end

  def process_html(res)
    cat = 'Venezuela'
    url = res.effective_url
    #puts "Completed #{url}"

    doc = Nokogiri::HTML(res.body.force_encoding('UTF-8'))
      
    #get next page url
    if /more/ =~ doc.xpath('id("main_content")/a/img/@src').first.content
      queue "http://wefollow.com"+doc.xpath('id("main_content")/a/@href').first.content
    end
      
    doc.xpath('id("results")//div[@class="result_row"]').each do |row|
      usuario = row.xpath('div[@class="result_details"]//a').first
      next if usuario == nil
                
      #username
      username = "#{usuario.content}"
        
      #profile pic
      pic = row.xpath('div[@class="result_thumbnail"]//img/@src').to_s
        
      #followers
      if /(\d.+\d)/ =~ row.xpath('p[@class="follower_count"]').to_s
        followers = $1.gsub(',','')
      end        

      doc = {"username" => username, "name" => '', "bio" => '', "pic" => pic,
        "since" => '0000-00-00 00:00:00', "followers" => followers,"following" => '', "tags" => '', "ref"=>2}
      
      @users << doc
    end        
  end
  
  def run          
    @urls.collect!(&method(:queue))
    @hydra.run
  end
  
end