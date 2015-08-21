require 'soundcloud'
require 'json'
require 'csv'
require 'open-uri'

ARTIST_NAME_COLUMN = "artist_name"
INPUT_CSV = ""

class WelcomeController < ApplicationController

  def soundcloud
    #user_id = get_user_id
    #likes = get_likes(user_id)
    #@liked_artists = build_liked_artists(likes) || []
    @liked_artists = []
  end

  def shows
    #all_artist_events = []
    #all_recommended_events = []

    #artist = row[ARTIST_NAME_COLUMN]
    #@shows = get_artist_events(artist)
    @shows = {}
    source_artists.each do |a|
      @shows[a] = get_recommended_events(a)
    end

    base_url = "https://w.soundcloud.com/player/?url=https%3A//api.soundcloud.com/tracks/TRACK_ID&amp;color=ff5500&amp;auto_play=false&amp;hide_related=false&amp;show_comments=true&amp;show_user=true&amp;show_reposts=false" 

    @api_urls = []
    @track_urls = [
      "https://soundcloud.com/ruffneck-ting/genetix-habitat-adrenaline-1",
      "https://soundcloud.com/drumandbass/genetix-oslo-shotgun-premiere",
      "https://soundcloud.com/multi-function/genetix-humanity-released-20th-may"
    ]
    @track_urls.each do |url|
      track_id = get_track_id(url)
      @api_urls.push(base_url.gsub(/TRACK_ID/, track_id))
    end
  end

  def artists
    render json: source_artists
  end

  private

    # soundcloud

    def get_track_id(url)
      r = `curl -v 'http://api.soundcloud.com/resolve.json?url=#{CGI.escape url}&client_id=#{ENV["CLIENT_ID"]}'`
      r.match(/tracks\/(\d+).json/).captures[0]
    end

    def get_user_id
      username = params[:username]
      r = `curl -v 'http://api.soundcloud.com/resolve.json?url=http://soundcloud.com/#{username}&client_id=#{ENV["CLIENT_ID"]}'`
      #parse_response(r)
      r.match(/(\d+).json/).captures[0]
    end

    def parse_response(r)
      r.match(/(\d+).json/).captures[0]
    end

    def get_likes(user_id, limit=1000, offset=0)
      r = `curl https://api-v2.soundcloud.com/users/#{user_id}/likes?limit=#{limit}&offset=#{offset}`
      JSON.parse(r).first[1]
    end

    def build_liked_artists(likes)
      liked_artists = []
      likes.each do |like|
        if like["track"]
          track_info = like["track"]
          track_title = track_info["title"]
          track_url = track_info["permalink_url"]
          track_artist = track_info["user"]["username"]
          liked_artists << [track_title, track_artist, track_url]
        end
      end
      liked_artists
    end

    # bandsintown

    def get_recommended_events(artist, rad=50, loc="use_geoip")
      artist = URI::encode(artist)
      loc = "San%20Francisco,CA" # otherwise is set to Seattle, WA (AWS)
      #loc = URI::encode(loc)
      url = "http://api.bandsintown.com/artists/#{URI.escape artist}/events/recommended?location=#{loc}&radius=#{rad}&app_id=YOUR_APP_ID&api_version=2.0&format=json"
      puts url
      r = `curl "#{url}"`
      JSON.parse(r)
    end

    def get_artist_events(artist, rad=50, loc="use_geoip")
      artist = URI::encode(artist)
      loc = "San%20Francisco,CA" # otherwise is set to Seattle, WA (AWS)
      #loc = URI::encode(loc)
      r = `curl "http://api.bandsintown.com/artists/#{URI.escaped artist}/events/search.json?api_version=2.0&app_id=YOUR_APP_ID&location=#{loc}&radius=#{rad}"`
      JSON.parse(r)
    end

    def source_artists
      job_id = 768382 #768695
      cf_token = ENV['CF_TOKEN']
      #url = "https://api.crowdflower.com/v2/jobs/#{job_id}/judgments"
      #r = `curl -u "#{cf_token}:" #{url}`
      #JSON.parse(r).collect { |a| a['data']['artist_name'] }.flatten.uniq.reject { |c| c.empty? }.sample(7).sort
      ['Genetix']
    end
end
