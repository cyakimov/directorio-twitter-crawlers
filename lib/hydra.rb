require 'typhoeus'
module Hydra
  def init_hydra(url=nil,max_concurency = 20)
    @url = url
    @user_agent = 'Googlebot/2.1 (+http://www.google.com/bot.html)'
    @users_count = 0
    @hydra = Typhoeus::Hydra.new(:max_concurrency => max_concurency)
  end

  def queue(url)
    r = Typhoeus::Request.new(url, :user_agent =>@user_agent)
    r.on_complete(&method(:process_html))
    @hydra.queue(r)
    #puts 'On queue => ' + r.url
  end

  def get(s_url = nil)
    Typhoeus::Request.get(s_url || @url, :user_agent =>@user_agent)
  end
end