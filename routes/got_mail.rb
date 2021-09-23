class Web
  def get_got_mail
    @user = nil
    @development = development?

    if @development
      @user = LoginCode.order(:id).last.user
    end

    view 'got_mail'
  end

  hash_routes.on 'got-mail' do
    get do
      get_got_mail
    end
  end
end
