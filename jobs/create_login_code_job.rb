require './models'
require './mailer'

class CreateLoginCodeJob < Job
  def perform(user, email)
    LoginCode.generate(user: user)
    Mailer.sendmail(email)
  end
end
