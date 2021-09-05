class App
  def get_login
    view 'login'
  end

  def post_login
    @user = User.first(email: params['email'])

    if @user
      @user.refresh_token
      @user.save

      MailJob.perform_async "/signup/#{@user.id}"
    end

    redirect got_mail_path
  end

  def get_session(token)
    @user = User.where(Sequel.lit('token = ? and token_expires_at > ?', token, Time.now.to_i)).first

    if @user
      @user.clear_token
      @user.save
      session['user_id'] = @user.id
      redirect home_path
    else
      response.status = 404
      halt
    end
  end

  hash_routes.on 'login' do
    is do
      get do
        get_login
      end

      post do
        post_login
      end
    end

    is String do |token|
      # GET /login/:token
      get do
        get_session(token)
      end
    end
  end
end
