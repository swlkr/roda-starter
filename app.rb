require './roda_app'
require './models'
require './mailer'
require './jobs'

class App < RodaApp
  # PLUGINS
  plugin :flash
  plugin :render, escape: true, layout: './layout'
  plugin :sessions, secret: ENV.fetch('SESSION_SECRET'), cookie_options: { max_age: 86_400 * 30 }
  plugin :route_csrf
  plugin :slash_path_empty
  plugin :disallow_file_uploads # use direct uploads from client instead
  plugin :precompile_templates
  plugin :forme_route_csrf
  plugin :partials

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

  if development?
    plugin :exception_page

    class RodaRequest
      def assets
        exception_page_assets
        super
      end
    end
  end

  plugin :error_handler do |e|
    case e
    when Roda::RodaPlugins::RouteCsrf::InvalidToken
      @page_title = 'Invalid Security Token'
      response.status = 400
      view(content: '<p>An invalid security token was submitted with this request, and this request could not be processed.</p>')
    when Sequel::NoMatchingRow
      response.status = 404
      halt
    else
      $stderr.print "#{e.class}: #{e.message}\n"
      $stderr.print e.backtrace

      next exception_page(e, assets: true) if development?

      @page_title = 'Internal Server Error'
      view(content: '')
    end
  end

  compile_assets unless development?

  # don't call r. everywhere
  request_delegate :root, :on, :is, :get, :post, :redirect, :params, :halt, :hash_routes, :assets

  Dir[File.join(__dir__, "routes", "*.rb")].each do |file|
    require file
  end

  route do
    assets if development?
    check_csrf!

    @current_user = User.first(id: session['user_id'])

    def current_user!
      return if @current_user

      response.status = 404
      halt
    end

    hash_routes
  end
end
