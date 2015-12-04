require 'sinatra'
require 'json'
require 'rest_client'
require 'haml'

set :haml, :format => :html5

class City_Weather < Sinatra::Base

	get '/' do
	  haml :form
	end

	post '/' do
		city_name = params[:city] 
		days = params[:days]
		nice_day = params[:nice_day]
		MAX_WIND_SPEED = 9

	  api_result = RestClient.get "http://api.openweathermap.org/data/2.5/forecast/daily?q=#{city_name}&mode=json&units=metric&cnt=#{days}&appid=e289605282a4562afea94a0ffe4ffaa8"
	  received_hash = JSON.parse(api_result)

	  unless received_hash["message"] == "Error: Not found city" 
		  city = received_hash["city"]["name"]
		  country = received_hash["city"]["country"]
		  i = 0
		  exist_nice_day = false

		  # titles
		  output = "<tr><th> № </th><th> Date </th><th> Weather </th><th colspan='4'> Temperature </th><th> Wind </th>"
		  output += "<th colspan='4'> Other Information </th></tr>"

		  weathers = received_hash["list"]
		  weathers.each do |w|
		  	i += 1
		  	unless nice_day && (w["rain"] != nil || w["speed"] > MAX_WIND_SPEED)
		  		exist_nice_day = true
			  	date = Time.at(w["dt"]).strftime("%d.%m.%y")
			  	# head 1
			  	output += "<tr>"
				  	output += "<td rowspan='4'> #{i.to_s} </td>" 
				  	output += "<td rowspan='4'> #{date} </td>" 
				  	output += "<td> #{w["weather"][0]["main"].to_s} </td>"
				  	output += "<td colspan='2'> t, min </ td><td colspan='2'> t, max </td>"
				  	output += "<td> Direction </td>"
				  	output += "<td> Pressure </td>"
				  	output += "<td> Humidity </td>"
				  	output += "<td> Clouds </td>"
				  	output += "<td> Rain </td>"
			  	output += "</tr>"
			  	# body 1
			  	output += "<tr>"
			  		output += "<td rowspan='3'> #{w["weather"][0]["description"].to_s} </td>"
			  		output += "<td colspan='2'>#{w["temp"]["min"]}&#176;C</td><td colspan='2'>#{w["temp"]["max"]}&#176;C</td>"
			  		# output += "<td><div class='wind-arrow' style='transform: rotate(#{w["deg"].to_s}deg);'>&#8226;&#8674;</div></td>"
			  		output += "<td><img src='img/point18.png' class='wind-arrow' alt='wind direction' style='transform: rotate(#{w["deg"].to_s}deg);'></td>"
			  		output += "<td rowspan='3'> #{w["pressure"].to_s} </td>" 
				  	output += "<td rowspan='3'> #{w["humidity"].to_s}%  </td>" 
				  	output += "<td rowspan='3'> #{w["clouds"].to_s}% </td>" 
				  	if w["rain"] == nil
				  		output += "<td rowspan='3'> none :) </td></tr>"
				  	else
				  		output += "<td rowspan='3'> #{w["rain"].to_s} </td></tr>"
				  	end
			  	output += "</tr>"	
			  	# head 2
			  	output += "<tr>"
			  		output += "<td> t, morning </td><td> t, day </td><td> t, evening</ td><td> t, night </td>"
			  		output += "<td>Speed</td>"
			  	output += "</tr>"	
			  	# body 2
			  	output += "<tr>"
			  		output += "<td>#{w["temp"]["morn"]}&#176;C</td><td>#{w["temp"]["day"]}&#176;C</td>"
			  		output += "<td>#{w["temp"]["eve"]}&#176;C</td><td>#{w["temp"]["night"]}&#176;C</td>"
			  		output += "<td>#{w["speed"].to_s}m/s</td>"
			  	output += "</tr>"	  	
			  end
		  end

		  unless exist_nice_day 
		  	output = "<tr><th><h1> Sorry but in this interval nice days doesn't exist! :( </h1></th></tr>"
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
