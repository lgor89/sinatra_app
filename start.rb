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
  response = RestClient.post(
    POST_REQUEST.to_s,
    { client_id: CLIENT_ID,
      client_secret: CLIENT_SECRET,
      code: code },
    accept: :json
  )
  access_token = JSON.parse(response)['access_token']
  out = RestClient.get('https://api.github.com/user', params: { access_token: access_token })
  @login = JSON.parse(out)['login']
  @user = User.create(name: @login, access_token: access_token)
  crypt_token
  if out.nil?
    redirect to '/'
  else
    redirect to '/user'
  end
end
#-----------------------------------------------------------
get '/signup' do
  erb :signup
end
#-------------------------------------------------------------
post '/signup' do
  if params[:password] == params[:password_confirmation]
    password = params[:password]
    secure_password = BCrypt::Password.create(password)
    @user = User.create(name: params[:name], email: params[:email], password: secure_password)
    crypt_token
    redirect to '/user'
  else
    erb :signup
  end
end
#--------------------------------------------------------
get '/index' do
  if current_user?
    "Welcome #{User.find(session[:id]).name}"
  else
    redirect to '/signup'
  end
end
#--------------------------------------------------------
post '/login' do
  email = params[:email]
  if User.find_by_email(email).nil?
    redirect to '/signup'
  else
    @user = User.find_by_email(email)
    user_password = @user.password
    encrypt_user_password = BCrypt::Password.new(user_password)
    if encrypt_user_password == params[:password]
      @login = @user.name
      crypt_token
      redirect to '/user'
    else
      redirect to '/login'
    end
  end
end
#----------------------------------------------------------
get '/login' do
  erb :login
end
#--------------------------------------------------------
get '/user' do
  if current_user?
    @login = session[:name]
    erb :user
  else
    redirect to '/login'
  end
end
#-----------------------------------------------------------
get '/logout' do
  session[:token] = nil
  session[:id] = nil
  redirect to '/signup'
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
