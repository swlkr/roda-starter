class User < Model
  one_to_many :login_codes

  def login_code
    login_codes.order(Sequel.desc(:created_at)).limit(1).first
  end
end
