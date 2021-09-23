class Web
  def get_signup
    view 'signup'
  end

  def post_signup
    @user = User.first(user_params) || User.new(user_params)

    if @user&.valid?
      @user.save if @user.new?

      CreateLoginCodeJob.perform_async @user, signup_email_path(@user)
    end

    redirect got_mail_path
  end

  hash_routes.on 'signup' do
    get do
      get_signup
    end

    post do
      post_signup
    end
  end

  private

  def user_params
    params.slice 'email'
  end
end
