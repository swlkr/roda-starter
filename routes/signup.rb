class App
  def get_signup
    view 'signup'
  end

  def post_signup
    @user = User.first(user_params) || User.new(user_params)

    if @user.valid?
      # only save user if user is new
      @user.save if @user.new?

      # create a new login code and send it in an email
      LoginCodeJob.perform_async @user.id, signup_email_path(@user)

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

  private

  def user_params
    params.slice 'email'
  end
end
