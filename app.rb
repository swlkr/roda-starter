require "roda"

require "./models"
require "./mailer"
require "./jobs"

class App < Roda
  # PLUGINS
  plugin :path
  plugin :flash
  plugin :render, engine: "mab"
  plugin :sessions, secret: ENV.fetch("SESSION_SECRET"), cookie_options: { max_age: 86400 * 30 }
  plugin :route_csrf
  plugin :symbol_views
  plugin :slash_path_empty
  plugin :environments
  plugin :delegate
  plugin :disallow_file_uploads # use direct uploads from client instead
  plugin :precompile_templates

  # precompile templates
  precompile_views %w[home signup login got_mail layout]

  # don't call r. everywhere
  request_delegate :root, :on, :is, :get, :post, :redirect, :assets, :params, :halt

  plugin :assets,
    css: ["app.css"],
    js: [],
    gzip: true

  compile_assets unless development?

  plugin :not_found do
    view "404"
  end

  plugin :default_headers,
    "Content-Type"              => "text/html",
    "Strict-Transport-Security" => "max-age=16070400;",
    "X-Content-Type-Options"    => "nosniff",
    "X-Frame-Options"           => "deny",
    "X-XSS-Protection"          => "1; mode=block"

  plugin :content_security_policy do |csp|
    csp.default_src :none
    csp.style_src :self
    csp.script_src :self
    csp.connect_src :self
    csp.img_src :self
    csp.font_src :self
    csp.form_action :self
    csp.base_uri :none
    csp.frame_ancestors :none
    csp.block_all_mixed_content
  end

  # PATHS
  path :home, "/"
  path :signup, "/signup"
  path :got_mail, "/got-mail"
  path :login, "/login"
  path :session do |user|
    "/login/#{user&.token}"
  end
  path :logout, "/logout"

  route do |r|
    assets if self.class.development?
    check_csrf!

    # CURRENT_USER
    @current_user = User.first(id: session["user_id"])

    # HOME
    root do
      :home
    end

    # SIGNUP
    is "signup" do
      # GET /signup
      get do
        :signup
      end

      # POST /signup
      post do
        @user = User.first(email: params["email"]) || User.new
        @user.email = params["email"]
        @user.refresh_token

        if @user.valid?
          @user.save

          # send signup email
          MailJob.perform_async("/signup/#{@user.id}")

          redirect got_mail_path
        else
          :signup
        end
      end
    end

    # LOGIN
    on "login" do
      is do
        # GET /login
        get do
          :login
        end

        # POST /login
        post do
          @user = User.first(email: params["email"])

          if @user
            @user.refresh_token
            @user.save

            MailJob.perform_async "/signup/#{@user.id}"
          end

          redirect got_mail_path
        end
      end

      is String do |token|
        # GET /logins/:token
        get do
          @user = User.where(Sequel.lit("token = ? and token_expires_at > ?", token, Time.now.to_i)).first

          if @user
            @user.clear_token
            @user.save
            session["user_id"] = @user.id
            redirect home_path
          else
            response.status = 404
            halt
          end
        end
      end
    end

    # GOT MAIL
    is "got-mail" do
      @user = nil
      @development = self.class.development?

      if @development
        @user = User.where(Sequel.lit("token is not null and token_expires_at > ?", Time.now.to_i)).first
      end

      :got_mail
    end

    # LOGOUT
    is "logout" do
      # POST /logout
      post do
        @current_user.clear_token
        @current_user.save
        session.delete("user_id")
        redirect home_path
      end
    end

    # CHECK FOR CURRENT_USER
    unless @current_user
      response.status = 404
      halt
    end

    # PROTECTED ROUTES
  end
end
