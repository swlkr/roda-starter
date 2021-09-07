class LoginCode < Model
  many_to_one :user

  def initialize
    super

    self.identifier = SecureRandom.urlsafe_base64(16)
    self.expired_at = Time.now.to_i + 600 # 10 minutes from now
  end
end
