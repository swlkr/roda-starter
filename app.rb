require 'roda'

class App < Roda
  plugin :path
  plugin :environments
  plugin :delegate
  plugin :view_options

  def self.paths
    path :home, '/'
    path :signup, '/signup'
    path :got_mail, '/got-mail'
    path :login, '/login'
    path :session do |user|
      "/login/#{user.login_code}"
    end
    path :logout, '/logout'
  end

  paths

  # helpers for :environments
  def development?
    self.class.development?
  end

  def production?
    self.class.production?
  end
end
