class LoginCode < Model
  many_to_one :user

  def self.generate(user:)
    create(
      user: user,
      code: SecureRandom.urlsafe_base64(16),
      expired_at: Time.now.to_i + 600 # 10 minutes from now
    )
  end
end
