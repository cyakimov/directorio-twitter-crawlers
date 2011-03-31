require 'test/unit'
require_relative '../lib/twitter-ven/twitter-ven.rb'

class TwitterVenezuelaTest < Test::Unit::TestCase

  def setup
    @tw = TwitterVenezuela.new('http://www.twitter-venezuela.com/')
  end

  def test_fetch_categories
    @tw.fetch_categories
    refute_empty(@tw.categories, 'Something is wrong, couldnt fetch categories')
    @tw.categories.each do |url|
      assert_match(/.com\/categoria/, url.downcase, "BOOM! A non valid category URL detected")
    end
  end

  def test_user_extractor
    res = @tw.get 'http://www.twitter-venezuela.com/categoria/politica?pag=10'
    @tw.process_html(res)
    refute_empty(@tw.users, 'BOOM! Empty user array')
    
    @tw.users.each do |user|
      assert_match(/profile_images\/.*\.(bmp|jpg|jpeg|png|gif)/, user['pic'].downcase, 'BOOM! User Pic URL pattern has changed')
      assert_operator user['username'].length, :<=, 15, 'Something could be wrong. Username has more than 15 chars'
    end
    
  end

end
