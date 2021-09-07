class Mailer
  def login(user)
    @user = user

    no_mail! unless @user

    @link = "https://your_project.com/login/#{@user.login_code}"

    to @user.email
    subject '[your_project] Your login link is in inside'

    view 'login'
  end
end
