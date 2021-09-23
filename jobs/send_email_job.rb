require './mailer'

class SendEmailJob < Job
  def perform(path)
    Mailer.sendmail(path)
  end
end
