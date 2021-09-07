class App
  def get_login
    view 'login'
  end

  def post_login
    @user = User.first(email: params['email'])

    LoginCodeJob.perform_async(@user, login_email_path(@user)) if @user

    redirect got_mail_path
  end

  def get_session(code)
    @code = LoginCode.where(code: code).exclude { expired_at <= Time.now.to_i }.first

    if @code
      session['user_id'] = @code.user_id
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

    is String do |code|
      # GET /login/:code
      get do
        get_session(code)
      end
    end
  end
end
