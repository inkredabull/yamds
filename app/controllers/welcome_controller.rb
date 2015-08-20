require 'soundcloud'
require 'json'
require 'csv'

class WelcomeController < ApplicationController

  def soundcloud
    user_id = get_user_id
    likes = get_likes(user_id)
    @liked_artists = build_liked_artists(likes) || []
  end

  private

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

end
