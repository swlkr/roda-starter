class App
  def get_got_mail
    @user = nil
    @development = development?

    if @development
      @user = User.where(Sequel.lit('token is not null and token_expires_at > ?', Time.now.to_i)).first
    end

    view 'got_mail'
  end

  hash_routes.on 'got-mail' do
    get do
      get_got_mail
    end
  end
end
