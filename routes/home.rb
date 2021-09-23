class Web
  def home_get
    if @current_user
      view 'home'
    else
      redirect login_path
    end
  end

  hash_routes do
    on '' do
      get do
        home_get
      end
    end
  end
end
