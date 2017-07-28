require 'dotenv'
require 'bcrypt'
require 'jwt'
require 'rubygems'
require 'dotenv'
require 'sinatra'
require 'rest-client'
require 'cgi'
require_relative 'config/boot.rb'
require 'json'
require 'net/http'
require 'pry'
require 'dotenv/load'
CLIENT_ID = ENV['CLIENT_ID']
CLIENT_SECRET = ENV['CLIENT_SECRET']
GET_REQUEST = ENV['GET_REQUEST']
REDIRECT_URI = ENV['REDIRECT_URI']
POST_REQUEST = ENV['POST_REQUEST']
#------------------------------------------------------
enable :sessions
#---------------------------------------------------
get '/' do
  erb :index, locals: { client_id: CLIENT_ID }
end
#-----------------------------------------------------
get '/oauth2/callback' do
  code = params[:code]
  response = RestClient.post(
    POST_REQUEST.to_s,
    {
      client_id: CLIENT_ID,
      client_secret: CLIENT_SECRET,
      code: code
    },
    accept: :json
  )
  access_token = JSON.parse(response)['access_token']
  out = RestClient.get('https://api.github.com/user', params: { access_token: access_token })
  login = JSON.parse(out)['login']
  @user = User.create(name: login, access_token: access_token)
  crypt_token
  if out.nil?
    redirect to '/'
  else
    session[:name] = @user.name
    binding.pry
    redirect to '/user'
  end
end
#--------------------------------------------------------
get '/user' do
  if current_user?
    @login = session[:name]
    erb :user
  else
    redirect to '/'
  end
end
#-----------------------------------------------------------
get '/logout' do
  session[:token] = nil
  session[:id] = nil
  redirect to '/'
end
def current_user?
  if session[:token].nil?
    false
  else
    decoded_token = JWT.decode session[:token], ENV['HMAC_SECRET'], true, algorithm: 'HS256'
    @current_user_id = decoded_token.first['user_id']
    @current_user = User.find(@current_user_id)
  end
end

def crypt_token
  payload = { user_id: @user.id }
  token = JWT.encode payload, ENV['HMAC_SECRET'], 'HS256'
  session[:id] = @user.id
  session[:token] = token
end
