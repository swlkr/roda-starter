require './mailer'
require './models'

class LoginCodeJob < Job
  def perform(user_id, email)
    user = User[user_id]

    # create login code
    LoginCode.create(user: user)

    # send email
    Mailer.sendmail(email)
  end
end
