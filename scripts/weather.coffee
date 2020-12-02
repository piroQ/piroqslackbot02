cronJob = require('cron').CronJob

module.exports = (robot) ->

  robot.respond /weather (.+)/i, (msg) ->
    target = msg.match[1]
    apikey = ""
    params = "q=#{target},jp&appid=daeaca2d38232ddac18f0431a8d43810&units=metric"
    searchWeather(params, target, msg)

  searchWeather = (url, place, msg) ->
    request = robot.http("http://api.openweathermap.org/data/2.5/weather?#{url}").get()
    stMessage = request (err, res, body) ->
      json = JSON.parse body
      if json['cod'] != 200
        #APIerror
        msg.send ":warning:" + json['message']
        return
      weatherName = json['weather'][0]['main']
      icon = json['weather'][0]['icon']
      temp = json['main']['temp']
      temp_max = json['main']['temp_max']
      temp_min = json['main']['temp_min']
      msg.send "今日の#{place}の天気は「" + weatherName + "」です。\n気温:"+ temp + "℃ 最高気温："  + temp_max+ "℃ 最低気温：" + temp_min + "℃\nhttp://openweathermap.org/img/w/" + icon + ".png"

  new cronJob('30 18 8 * * *', () ->
    apikey = ""
    #東京
    tokyo = "q=Tokyo,jp&appid=daeaca2d38232ddac18f0431a8d43810&units=metric"
    #横浜
    yokohama = "q=Yokohama,jp&appid=daeaca2d38232ddac18f0431a8d43810&units=metric"
    searchWeatherCron(yokohama, "横浜")
    searchWeatherCron(tokyo, "東京")
  ).start()

  searchWeatherCron = (url, place) -> 
    request = robot.http("http://api.openweathermap.org/data/2.5/weather?#{url}").get()
    stMessage = request (err, res, body) ->
      json = JSON.parse body
      weatherName = json['weather'][0]['main']
      icon = json['weather'][0]['icon']
      temp = json['main']['temp']
      temp_max = json['main']['temp_max']
      temp_min = json['main']['temp_min']
      sendMessage = "今日の#{place}の天気は「" + weatherName + "」です。\n気温:"+ temp + "℃ 最高気温："  + temp_max+ "℃ 最低気温：" + temp_min + "℃\nhttp://openweathermap.org/img/w/" + icon + ".png"
      robot.send {room: "#weather_info"}, sendMessage
