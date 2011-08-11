require 'rest-client'
require 'json'
require 'sinatra'

# your Tropo token
@token = '3431a15483eb5c49be7b0436b534ce5ba682fdb7a2533c71d197393ef25e767d26cb7ef336829aa9cd0606f5'
@db = 'http://lsrc.iriscouch.com/raffle2011/'

set :logging, false

get '/' do
  # How many documents are there?
  response = RestClient.get @db + '_design/random/_view/all'
  count = JSON.parse(response.to_str)["total_rows"]

  # find a random document
  r = Random.new
  i = count > 1 ? r.rand(1...count) : count - 1
  response = RestClient.get @db + "_design/random/_view/all?reduce=false&skip=#{i}&limit=1"

  # Get the phone number and name
  phone = JSON.parse(response.to_str)["rows"][0]["value"]["phone"]
  name = JSON.parse(response.to_str)["rows"][0]["value"]["name"]
  rev = JSON.parse(response.to_str)["rows"][0]["value"]["rev"]

  # declare them a winner
  # print their name to the screen
  puts "<h1>#{name} is a winner!</h1>"
  puts "http://api.tropo.com/1.0/sessions?action=create&token=#{@token}&to=#{phone}&name=#{name}"
  
  # send a text message with Tropo
  #response = RestClient.get "http://api.tropo.com/1.0/sessions?action=create&token=#{@token}&to=#{phone}&name=#{name}"

  # update the doc to indicate they won
  response = RestClient.put @db + phone, "{\"_rev\": \"#{rev}\", \"name\": \"#{name}\", \"Won\": true}", {:content_type => :json}
  haml :index
end

