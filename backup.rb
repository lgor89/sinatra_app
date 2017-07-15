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
helpers FormHelpers
    get '/login' do
  erb :login
end
get '/signup' do
  erb :signup
end
post '/signup' do
  @user = User.create(name: params[:user][:name],email: params[:user][:email],password: params[:user][:password])
  session[:id] = @user.id
  redirect to '/index'
end
get '/index' do
  "Welcome #{User.find(session[:id]).name}"
end

