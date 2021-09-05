require 'roda'

class Shared < Roda
  plugin :path
  plugin :environments
  plugin :delegate
  plugin :view_options

  def self.paths
    path :home, '/'
    path :signup, '/signup'
    path :got_mail, '/got-mail'
    path :login, '/login'
    path :session, url: true do |user|
      "/login/#{user&.token}"
    end
    path :logout, '/logout'
  end

  # helpers for :environments
  def development?
    self.class.development?
  end

  def production?
    self.class.production?
  end
end
