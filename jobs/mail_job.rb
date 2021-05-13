require "./mailer"

class MailJob < Job
  def perform(str)
    Mailer.sendmail(str)
  end
end
