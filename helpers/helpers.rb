helpers do
if session.has_key?("token")
    decoded_token = JWT.decode session[:token], ENV['HMAC_SECRET'], true, { :algorithm => 'HS256' }
    @current_user_id = decoded_token.first["user_id"]
    @current_user = User.find(@current_user_id)
    @login = @current_user.name

    binding.pry
    redirect to '/user'
  else
    redirect to '/signup'
  end
end
