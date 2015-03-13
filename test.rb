require 'pry'
require 'httparty'
require 'yelp'

#create empty json
json = ''

#read json file
File.open('secret.json', 'r') do |f|
  f.each_line do |line|
    json << line
  end
end

#parse json and set api keys to hash values
json_hash = JSON.parse(json)

#googlemaps key
google_key = json_hash['google_key']

#yelp keys
consumer_key = json_hash['key']
consumer_secret = json_hash['con_secret']
token = json_hash['token']
token_secret = json_hash['token_secret']

#lat, lng arrays
lats = []
lngs = []

##first address
  #get address1 and replace spaces
  puts "enter first address"
  address1 = gets.chomp
  updated_address1 = address1.gsub ' ','+'

  #create url and send HTTP request
  url1 = "https://maps.googleapis.com/maps/api/geocode/json?address=" + updated_address1 + "key=" + google_key
  response1 = HTTParty.get(url1)

  #return lat, long from response
  lat1 = response1["results"][0]["geometry"]["location"]["lat"]
  lats.push(lat1)
  lng1 = response1["results"][0]["geometry"]["location"]["lng"]
  lngs.push(lng1)

##second address
  #get address2 and replace spaces
  puts "enter second address"
  address2 = gets.chomp
  updated_address2 = address2.gsub ' ','+'

  #create url and send HTTP request
  url2 = "https://maps.googleapis.com/maps/api/geocode/json?address=" + updated_address2 + "key=" + google_key
  response2 = HTTParty.get(url2)

  #return lat, long from response
  lat2 = response2["results"][0]["geometry"]["location"]["lat"]
  lats.push(lat2)
  lng2 = response2["results"][0]["geometry"]["location"]["lng"]
  lngs.push(lng2)

##third address
  #get address3 and replace spaces
  puts "enter third address"
  address3 = gets.chomp
  updated_address3 = address2.gsub ' ','+'

  #create url and send HTTP request
  url3 = "https://maps.googleapis.com/maps/api/geocode/json?address=" + updated_address3 + "key=" + google_key
  response3 = HTTParty.get(url3)

  #return lat, long from response
  lat3 = response3["results"][0]["geometry"]["location"]["lat"]
  lats.push(lat3)
  lng3 = response3["results"][0]["geometry"]["location"]["lng"]
  lngs.push(lng3)

##evaluate max and min for lat and lng
sw_lat = lats.min
ne_lat = lats.max
if lngs.min > 0 && lngs.max > 0
  ne_lng = lngs.max
  sw_lng = lngs.min
else
  ne_lng = lngs.min
  sw_lng = lngs.max
end

#configure Yelp request
Yelp.client.configure do |config|
  config.consumer_key = consumer_key
  config.consumer_secret = consumer_secret
  config.token = token
  config.token_secret = token_secret
end

#set bounding box lats and longs
bounding_box = { sw_latitude: sw_lat, sw_longitude: sw_lng, ne_latitude: ne_lat, ne_longitude: ne_lng }

#get search params from user
puts "enter cuisine preference"
cuisine = gets.chomp
puts "enter number of options"
number = gets.chomp.to_i
params = { term: cuisine, limit: number }

#send Yelp search request
bounding_search_results = Yelp.client.search_by_bounding_box(bounding_box, params)
businesses = bounding_search_results.businesses
businesses.each do |business|
  puts "Restaurant: " + business.name
  puts "Phone: " + business.phone
  puts "Link: " + business.mobile_url
  puts "Description: " + business.snippet_text
end

if businesses.length == 0
  puts "no results match your search parameters"
end
