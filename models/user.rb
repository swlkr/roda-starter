class User < Model
  def refresh_token
    self.token = SecureRandom.urlsafe_base64(16)
    self.token_expires_at = Time.now.to_i + 600 # 10 minutes from now
  end

  def clear_token
    self.token = nil
    self.token_expires_at = nil
  end
end
