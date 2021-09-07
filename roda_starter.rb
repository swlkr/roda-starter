require './app'
require './models'
require './mailer'
require './jobs'

class RodaStarter < App
  # PLUGINS
  plugin :flash
  plugin :render, engine: 'mab', layout: './layout'
  plugin :sessions, secret: ENV.fetch('SESSION_SECRET'), cookie_options: { max_age: 86_400 * 30 }
  plugin :route_csrf
  plugin :slash_path_empty
  plugin :disallow_file_uploads # use direct uploads from client instead
  plugin :precompile_templates

  plugin :assets, {
    css: %w[
      colors.css
      typography.css
      layout.css
      ui.css
      reset.css
      app.css
    ],
    js: [],
    gzip: true
  }

  plugin :not_found do
    view '404'
  end

  plugin :default_headers,
    'Content-Type'              => 'text/html',
    'Strict-Transport-Security' => 'max-age=16070400;',
    'X-Content-Type-Options'    => 'nosniff',
    'X-Frame-Options'           => 'deny',
    'X-XSS-Protection'          => '1; mode=block'

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

  # don't call r. everywhere
  request_delegate :root, :on, :is, :get, :post, :redirect, :assets, :params, :halt

  compile_assets unless development?

  Dir[File.join(__dir__, "routes", "*.rb")].each do |file|
    require file
  end

  route do
    assets if development?
    check_csrf!

    # CURRENT_USER
    @current_user = User.first(id: session['user_id'])

    # HOME
    root do
      if @current_user
        view 'home'
      else
        redirect login_path
      end
    end

    def current_user!
      return if @current_user

      response.status = 404
      halt
    end

    hash_routes
  end
end
