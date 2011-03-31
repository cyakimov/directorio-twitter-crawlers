puts '1) Run Twitter-Venezuela crawler'
puts '2) Run We-follow crawler'

opt = gets.chomp!

exit if !['1','2'].include?(opt)

puts "Running pid #{Process.pid}"
if opt == '1'
  require_relative 'twitter-ven/twitter-ven'
  obj = TwitterVenezuela.new 'http://www.twitter-venezuela.com/'
  obj.run

  puts "Total users #{obj.users_count}"
  puts
  puts '<----- END ----->'

else
  urls = [
    'http://wefollow.com/city/venezuela/followers',
    'http://wefollow.com/city/caracas_venezuela/followers'
  ]

  obj = WeFollow.new urls
  obj.run

  puts "Total users #{obj.users_count}"
  puts
  puts '<----- END ----->'
end
