require './roda_app'

class Mailer < RodaApp
  plugin :mailer, content_type: 'text/html'
  plugin :render, escape: true, layout: './emails/layout'

  request_delegate :mail, :on

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

  def self.deliver_later(path)
    SendEmailJob.perform_async path
  end

  def hostname
    if development?
      'http://localhost:9292'
    else
      'https://your_project.com'
    end
  end

  route do
    set_view_subdir 'emails'

    from 'You <you@your_project.com>'

    on 'users', Integer do |id|
      @user = User[id]

      no_mail! unless @user

      to @user.email
      subject '[your_project] Your login link is in inside'

      @link = "#{hostname}#{session_path(@user)}"

      mail 'signup' do
        view 'signup'
      end

      mail 'login' do
        view 'signup'
      end
    end
  end
end
