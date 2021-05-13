require "./models"

class Mailer < Roda
  plugin :render
  plugin :mailer, content_type: "text/html"
  plugin :symbol_views
  plugin :render, engine: "mab", layout: "email_layout"
  plugin :environments
  plugin :delegate
  request_delegate :mail

  if production?
    Mail.defaults do
      delivery_method :smtp,
        address: "smtp.mailgun.org",
        user_name: "postmaster@your_project.com",
        password: ENV["SMTP_PASSWORD"],
        port: 587
    end
  else
    Mail.defaults do
      delivery_method :logger
    end
  end

  route do |r|
    from "You <you@your_project.com>"

    mail "signup", Integer do |id|
      no_mail! unless @user = User.first(id: id)

      @link = "https://your_project.com/login/#{@user.token}"

      to @user.email
      subject "[your_project] Your login link to sign in is inside"

      :signup_email
    end
  end
end
