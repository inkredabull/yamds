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
    artist = "Skrillex"
    #@shows = get_artist_events(artist)
    @shows = get_recommended_events(artist)
  end

  private

    # soundcloud

    def get_user_id
      username = params[:username]
      response = `curl -v 'http://api.soundcloud.com/resolve.json?url=http://soundcloud.com/#{username}&client_id=#{ENV["CLIENT_ID"]}'`
      parse_response(response)
    end

    def parse_response(response)
      response.match(/(\d+).json/).captures[0]
    end

    def get_likes(user_id, limit=1000, offset=0)
      response = `curl https://api-v2.soundcloud.com/users/#{user_id}/likes?limit=#{limit}&offset=#{offset}`
      JSON.parse(response).first[1]
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
      loc = URI::encode(loc)
      response = `curl "http://api.bandsintown.com/artists/#{artist}/events/recommended?location=#{loc}&radius=#{rad}&app_id=YOUR_APP_ID&api_version=2.0&format=json"`
      JSON.parse(response)
    end

    def get_artist_events(artist, rad=50, loc="use_geoip")
      loc = URI::encode(loc)
      response = `curl "http://api.bandsintown.com/artists/#{artist}/events/search.json?api_version=2.0&app_id=YOUR_APP_ID&location=#{loc}&radius=#{rad}"`
      JSON.parse(response)
    end

end
