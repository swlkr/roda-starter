require './shared'
require './models'

class Mailer < Shared
  plugin :mailer, content_type: 'text/html'
  plugin :render, engine: 'mab', layout: './emails/layout'

  request_delegate :mail

  if production?
    Mail.defaults do
      delivery_method :smtp, {
        address: 'smtp.mailgun.org',
        user_name: 'postmaster@your_project.com',
        password: ENV['SMTP_PASSWORD'],
        port: 587
      }
    end
  else
    Mail.defaults do
      delivery_method :logger
    end
  end

  route do
    set_view_subdir 'emails'

    from 'You <you@your_project.com>'

    mail 'signup', Integer do |id|
      @user = User.first(id: id)

      no_mail! unless @user

      @link = "https://your_project.com/login/#{@user.token}"

      to @user.email
      subject '[your_project] Your login link to sign in is inside'

      view 'signup'
    end
  end
end
