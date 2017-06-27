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
    @timelines.reverse!

    favorites = @user.favorite
    @timelines.each do |timeline|
      timeline.is_liked = favorites.exists?(timeline_source: timeline.source, timeline_id: timeline.id)
    end
    render action: "timeline"
  end

  def favorite
    @user.favorite.create(timeline_id: params[:timeline_id], timeline_source: params[:timeline_source])
    redirect_to '/'
  end

  def unfavorite
    favorite = @user.favorite.where(timeline_id: params[:timeline_id], timeline_source: params[:timeline_source]).first
    if favorite
      favorite.destroy
    end
    redirect_to '/'
  end

  private
  def loadTweets
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = Rails.application.secrets.twitter_api_key
      config.consumer_secret     = Rails.application.secrets.twitter_api_secret
      config.access_token        = Rails.application.secrets.twitter_access_token
      config.access_token_secret = Rails.application.secrets.twitter_access_token_secret
    end

    tweets = client.search("vasily", lang: "ja").take(15).collect
    timelines = tweets.map do |tweet|
      timeline = Timeline.new
      timeline.id = tweet.id
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
        timeline.id = news['url']
        timeline.body = news['title']
        date = news['publishedAt'].to_time
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
end
