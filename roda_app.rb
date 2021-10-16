require 'roda'

class RodaApp < Roda
  plugin :path
  plugin :environments
  plugin :view_options
  plugin :hash_routes
  plugin :enhanced_logger, filter: ->(path) { path.start_with?('/assets') }, trace_missed: true

  path :home, '/'
  path :signup, '/signup'
  path :got_mail, '/got-mail'
  path :login, '/login'
  path :session do |user|
    "/login/#{user.login_code}"
  end
  path :logout, '/logout'

  # email routes
  path :login_email do |user|
    "/users/#{user.id}/login"
  end

  path :signup_email do |user|
    "/users/#{user.id}/signup"
  end

  # helpers for :environments
  def development?
    self.class.development?
  end

  def production?
    self.class.production?
  end
end
