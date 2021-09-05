class App
  def post_logout
    @current_user.clear_token
    @current_user.save
    session.delete('user_id')

    redirect home_path
  end

  hash_routes.on 'logout' do
    post do
      post_logout
    end
  end
end
