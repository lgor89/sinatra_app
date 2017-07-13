require 'dotenv'
require 'jwt'
require './helpers/form_helpers'
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
enable :sessions
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

    out = RestClient.get("https://api.github.com/user",{:params=> {:access_token => access_token}})
  #binding.pry
  @login = JSON.parse(out)['login']
  unless out.nil?
    @users = User.all
    binding.pry
    erb :user
  end
end
helpers FormHelpers
    get '/login' do
  erb :login
end
get '/signup' do
  erb :signup
end
post '/signup' do
  @user = User.create(name: params[:name],email: params[:email],password: params[:password])
  session[:id] = @user.id
  payload = {:user_id => session[:id]}
@token = JWT.encode payload, ENV['HMAC_SECRET'], 'HS256'
 # redirect to '/index'
  session[:token] = @token
end
get '/index' do
  "Welcome #{User.find(session[:id]).name}"
end
  post '/login' do
@name = params[:name]
binding.pry
decoded_token = JWT.decode session[:token], ENV['HMAC_SECRET'], true, { :algorithm => 'HS256' }
puts decoded_token
end
