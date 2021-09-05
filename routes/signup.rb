class App
  def get_signup
    view 'signup'
  end

  def post_signup
    @user = User.first(email: params['email']) || User.new
    @user.email = params['email']
    @user.refresh_token

    if @user.valid?
      @user.save

      # send signup email
      MailJob.perform_async("/signup/#{@user.id}")

      redirect got_mail_path
    else
      view 'signup'
    end
  end

  hash_routes.on 'signup' do
    get do
      get_signup
    end

    post do
      post_signup
    end
  end
end
