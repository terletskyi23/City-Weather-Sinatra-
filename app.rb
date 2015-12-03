require 'sinatra'
require 'json'
require 'rest_client'
require 'haml'

set :haml, :format => :html5

class City_Weather < Sinatra::Base
	@city_name
	@days

	get '/' do
	  haml :form
	end

	post '/' do
		@city_name = params[:city] 
		@days = params[:days]

	  api_result = RestClient.get "http://api.openweathermap.org/data/2.5/forecast/daily?q=#{@city_name}&mode=json&units=metric&cnt=#{@days}&appid=e289605282a4562afea94a0ffe4ffaa8"
	  received_hash = JSON.parse(api_result)

	  unless received_hash["message"] == "Error: Not found city" 
		  city = received_hash["city"]["name"]
		  country = received_hash["city"]["country"]
		  output = ""
		  i = 1

		  weathers = received_hash["list"]

		  weathers.each do |w|
		  	output += "<tr><td>Day: #{i.to_s} </td>" 
		  	output += "<td>main: #{w["weather"][0]["main"].to_s}</td>"
		  	output += "<td>description: #{w["weather"][0]["description"].to_s}</td>"
		  	output += "<td>speed: #{w["speed"].to_s}</td>"
		  	output += "<td>deg: #{w["deg"].to_s}</td>"
		  	output += "<td>clouds: #{w["clouds"].to_s}</td>"
		  	if w["rain"] == nil
		  		output += "<td>rain: none :) </td></tr>"
		  	else
		  		output += "<td>rain: #{w["rain"].to_s}</td></tr>"
		  	end
		  	i += 1
		  end

		  haml :index, :locals => {city: city, country: country, output: output}
		else 
			haml :error, :locals => { message: received_hash["message"]} # ones I will decorate this view :)
		end
	
	end

	not_found do
	  status 404
	  "This page does not exist" # ones I will create 404 page view :)
	end
end
