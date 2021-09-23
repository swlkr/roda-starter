class Web
  def post_logout
    session.delete('user_id')

    redirect home_path
  end

  hash_routes.on 'logout' do
    post do
      post_logout
    end
  end
end
