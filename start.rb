require 'dotenv'
require 'jwt'
require './helpers/form_helpers'
require 'rubygems'
require 'dotenv'
require 'sinatra'
require 'rest-client'
require 'cgi'
require_relative 'config/boot.rb'
require 'json'
require 'net/http'
require 'pry'
Dotenv.load
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
  resp = RestClient.post(
    POST_REQUEST.to_s,
    {
      client_id: CLIENT_ID,
      client_secret: CLIENT_SECRET,
      code: code
    },
    accept: :json
  )

  access_token = JSON.parse(resp)['access_token']
  session[:access_token] = access_token
  out = RestClient.get('https://api.github.com/user', params: { access_token: access_token })
  # binding.pry
  @login = JSON.parse(out)['login']
  session[:name]=@login
  @github_user = User.create(name:@login,access_token:access_token)
  unless out.nil?
    redirect to '/user'
  end
end
#-----------------------------------------------------------
get '/signup' do
  erb :signup
end
#-------------------------------------------------------------
post '/signup' do
  @user = User.create(name: params[:name], email: params[:email], password: params[:password])
  session[:id] = @user.id
  session[:name] = @user.name
  payload = {:user_id => session[:id]}
  token = JWT.encode payload, ENV['HMAC_SECRET'], 'HS256'
  session[:token] = token
  redirect to '/user'
end
#--------------------------------------------------------
get '/index' do
  "Welcome #{User.find(session[:id]).name}"
end
#--------------------------------------------------------
post '/login' do
  if session.has_key?("token")
    decoded_token = JWT.decode session[:token], ENV['HMAC_SECRET'], true, { :algorithm => 'HS256' }
    @current_user_id = decoded_token.first["user_id"]
    @current_user = User.find(@current_user_id)
    raise 'User not found'
    @login = @current_user.name
  elsif session.has_key?("access_token")
    @login = session[:name]
    redirect to '/user'
  else
    redirect to '/signup'
  end
end
#----------------------------------------------------------
get '/login' do
  erb :login
end
#--------------------------------------------------------
get '/user' do
  @login = session[:name]
  erb :user
end
#-----------------------------------------------------------
get '/auth/callback' do
end
#--------------------------------------------------------
get '/logout' do
session[:id] = nil
session[:token] = nil
redirect to '/signup'
end
