class TweetsController < ApplicationController
  require 'twitter'
  require 'net/http'
  require 'uri'
  require 'json'
  require "date"

  def timeline
    tweetTimeline = loadTweets
    newsTimeline = loadNews
    @timelines = []
    @timelines.concat(tweetTimeline)
    @timelines.concat(newsTimeline)
    @timelines.sort_by! {|timeline| timeline.created_at }

    cookie()

    render action: "timeline"
  end

  def loadTweets
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = "KVsIwdklDohJ7Jx3yKJgS4mXv"
      config.consumer_secret     = "0mJciEOWhIO2fiqbAfGW7KlGljTpNJITyIDgGdnHJ0ZLai30zv"
      config.access_token        = "1192963789-Qzh56bzHDflYWuo8yUIVp1SHVCmgxDs8oW3CKEf"
      config.access_token_secret = "n1FJAXvt8eaHM5pVZIthC3WYIac7BL4FasUsQSgV7Ian8"
    end

    tweets = client.search("vasily", lang: "ja")
    timelines = tweets.map do |tweet|
      timeline = Timeline.new
      timeline.body = tweet.text
      date = tweet.created_at
      timeline.created_at = date
      timeline.created_at_date = date.strftime("%Y年 %m月 %d日")
      timeline.created_at_time = date.strftime("%X")
      timeline.source = "Twitter"
      timeline.user = tweet.user.screen_name
      timeline
    end
    timelines
  end

  def loadNews
    uri = URI.parse('https://newsapi.org/v1/articles?source=google-news&sortBy=top&apiKey=a7bea8a54a1b41ccaac039d644451560')
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    res = https.start {
      https.get(uri.request_uri)
    }

    timelines = []
    if res.code == '200'
      result = JSON.parse(res.body)
      articles = result['articles'].select { |article| article['publishedAt'] != nil }
      timelines = articles.map do |news|
        timeline = Timeline.new
        timeline.body = news['title']
        date = news['publishedAt'].to_date
        timeline.created_at = date
        timeline.created_at_date = date.strftime("%Y年 %m月 %d日")
        timeline.created_at_time = date.strftime("%X")
        timeline.source = "Google News"
        timeline.author = news['author']
        timeline
      end
    end
    timelines
  end

  def cookie
    @fav = cookies[:fav]
  end

  def cookie_rec
    cookies[:fav] = { value: timeline.body, expires: 3.months.from_now, http_only: true }
  end

end
