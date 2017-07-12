require 'dotenv'
require 'rubygems'
require 'dotenv'
Dotenv.load
require 'sinatra'
require 'rest-client'
require 'cgi'
require_relative 'config/boot.rb'
require 'json'
require 'net/http'
require 'pry'
CLIENT_ID = ENV['CLIENT_ID']
CLIENT_SECRET = ENV['CLIENT_SECRET']
GET_REQUEST = ENV['GET_REQUEST']
REDIRECT_URI = ENV['REDIRECT_URI']
POST_REQUEST = ENV['POST_REQUEST']

get '/' do
  erb :index, :locals => {:client_id => CLIENT_ID}
end

get '/oauth2/callback' do
  code = params[:code]
  resp = RestClient.post(
    "#{POST_REQUEST}",
    {
      :client_id => CLIENT_ID,
      :client_secret => CLIENT_SECRET,
      :code => code
    },
    :accept => :json)

  access_token = JSON.parse(resp)['access_token']
  out = RestClient.get("https://api.github.com/user",{:params=> {:access_token => access_token}})
  #binding.pry
  @login = JSON.parse(out)['login']
  unless out.nil?
    @users = User.all
    binding.pry
    erb :user
  end
end
get '/user' do
  end
