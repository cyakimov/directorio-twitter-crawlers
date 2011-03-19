require 'typhoeus'
require 'nokogiri'

class Scrapper
  attr_accessor :users,:users_count
  
  def initialize(urls)
    @urls = urls
    @user_agent = 'Googlebot/2.1 (+http://www.google.com/bot.html)'    
    @users = Hash.new {|cat,url|cat[url]=[]}
    @users_count = 0
    @hydra = Typhoeus::Hydra.new(:max_concurrency => 20)    
  end

  def queue(url)
    r = Typhoeus::Request.new(url, :user_agent =>@user_agent)
    r.on_complete(&method(:process_html))
    @hydra.queue(r)
    #puts 'On queue => ' + r.url
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
      info = []
                
      #username
      info << "@#{usuario.content}"
        
      #profile pic
      info << row.xpath('div[@class="result_thumbnail"]//img/@src').to_s
        
      #followers
      if /(\d.+\d)/ =~ row.xpath('p[@class="follower_count"]').to_s
        info << $1.gsub(',','')
      end
        
      @users[cat] += [info.join('|')]
      @users_count +=1
    end        
  end
  
  def run          
    @urls.collect!(&method(:queue))
    @hydra.run
  end
  
end

puts "Running pid #{Process.pid}"

urls = [
  'http://wefollow.com/city/venezuela/followers',
  'http://wefollow.com/city/caracas_venezuela/followers'      
]

obj = Scrapper.new urls
obj.run

puts "Total users #{obj.users_count}"

File.open("we-follow.txt", "a") do |f|       
  obj.users.each do |cat,users|    
    users.each do |user|
      f.puts "#{cat}:#{user}"
    end
  end    
end

puts
puts '<----- END ----->'