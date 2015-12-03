require 'sinatra'
require 'json'
require 'rest_client'
require 'haml'

set :haml, :format => :html5

class City_Weather < Sinatra::Base
	get '/' do
	  api_result = RestClient.get 'http://api.openweathermap.org/data/2.5/forecast/daily?q=Lviv&mode=json&units=metric&cnt=14&appid=e289605282a4562afea94a0ffe4ffaa8'
	  received_hash = JSON.parse(api_result)
	 
	  city = received_hash["city"]["name"]
	  country = received_hash["city"]["country"]
	  output = ""
	  i = 1

	  weathers = received_hash["list"]

	  weathers.each do |w|
	  	output += "<tr><td>Day: #{i.to_s} </td>" 
	  	i += 1
	  	output += "<td>main: #{w["weather"][0]["main"].to_s}</td>"
	  	output += "<td>description: #{w["weather"][0]["description"].to_s}</td>"
	  	output += "<td>speed: #{w["speed"].to_s}</td>"
	  	output += "<td>deg: #{w["deg"].to_s}</td>"
	  	output += "<td>clouds: #{w["clouds"].to_s}</td>"
	  	output += "<td>rain: #{w["rain"].to_s}</td>"
	  end

	  haml :index, :locals => {city: city, country: country, output: output}
	end

end
