require './app'

class Mailer < App
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

  Dir[File.join(__dir__, "mailers", "*.rb")].each do |file|
    require file
  end

  route do
    set_view_subdir 'emails'

    from 'You <you@your_project.com>'

    mail 'signup', Integer do |id|
      signup User[id]
    end

    mail 'login', Integer do |id|
      login User[id]
    end
  end
end
