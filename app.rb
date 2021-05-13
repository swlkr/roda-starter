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

  plugin :assets,
    css: ["app.css"],
    js: [],
    gzip: true

  compile_assets unless ENV["RACK_ENV"] == "development"

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
    r.assets if ENV["RACK_ENV"] == "development"
    check_csrf!

    # CURRENT_USER
    @current_user = User.first(id: r.session["user_id"])

    # HOME
    r.root do
      :home
    end

    # SIGNUP
    r.is "signup" do
      # GET /signup
      r.get do
        :signup
      end

      # POST /signup
      r.post do
        @user = User.first(email: r.params["email"]) || User.new
        @user.email = r.params["email"]
        @user.refresh_token

        if @user.valid?
          @user.save

          # send signup email
          MailJob.perform_async("/signup/#{@user.id}")

          r.redirect got_mail_path
        else
          :signup
        end
      end
    end

    # LOGIN
    r.on "login" do
      r.is do
        # GET /login
        r.get do
          :login
        end

        # POST /login
        r.post do
          @user = User.first(email: r.params["email"])

          if @user
            @user.refresh_token
            @user.save

            MailJob.perform_async "/signup/#{@user.id}"
          end

          r.redirect got_mail_path
        end
      end

      r.is String do |token|
        # GET /logins/:token
        r.get do
          @user = User.where(Sequel.lit("token = ? and token_expires_at > ?", token, Time.now.to_i)).first

          if @user
            @user.clear_token
            @user.save
            r.session['user_id'] = @user.id
            r.redirect home_path
          else
            response.status = 404
            r.halt
          end
        end
      end
    end

    # GOT MAIL
    r.is "got-mail" do
      @user = nil

      if ENV["RACK_ENV"] == "development"
        @user = User.order(Sequel.desc(:created_at)).first
      end

      :got_mail
    end

    # LOGOUT
    r.is "logout" do
      # POST /logout
      r.post do
        session.delete('user_id')
        r.redirect home_path
      end
    end

    # CHECK FOR CURRENT_USER
    unless @current_user
      response.status = 404
      r.halt
    end

    # PROTECTED ROUTES
  end
end
