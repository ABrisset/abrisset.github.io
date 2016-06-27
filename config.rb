###
# Compass
###

# Change Compass configuration
# compass_config do |config|
#   config.output_style = :compact
# end

###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
#
# With no layout
# page "/path/to/file.html", :layout => false
#
# With alternative layout
# page "/path/to/file.html", :layout => :otherlayout
#
# A path which all have the same layout
# with_layout :admin do
#   page "/admin/*"
# end

# Proxy pages (https://middlemanapp.com/advanced/dynamic_pages/)
# proxy "/this-page-has-no-template.html", "/template-file.html", :locals => {
#  :which_fake_page => "Rendering a fake page with a local variable" }

###
# Helpers
###

# Automatic image dimensions on image_tag helper
# activate :automatic_image_sizes

# Reload the browser automatically whenever files change
# configure :development do
#   activate :livereload
# end

# Methods defined in the helpers block are available in templates
# helpers do
#   def some_helper
#     "Helping"
#   end
# end

require 'slim'

###
# Blog settings - Begin
###

Time.zone = "Paris"
I18n.config.enforce_available_locales = false
I18n.default_locale = :fr

activate :blog do |blog|
  # This will add a prefix to all links, template references and source paths
    blog.prefix = "blog"
    blog.name = "blog"
    blog.permalink = "/{title}"
  # Matcher for blog source files
    blog.sources = "{year}-{month}-{day}-{title}"
  # blog.taglink = "tags/{tag}.html"
    blog.layout = "layouts/blog"
  # blog.summary_separator = /()/
  # blog.summary_length = 250
  # blog.year_link = "{year}.html"
  # blog.month_link = "{year}/{month}.html"
  # blog.day_link = "{year}/{month}/{day}.html"
    blog.default_extension = ".markdown"
    blog.new_article_template = "source/new-article.markdown"

  # blog.tag_template = "tag.html"
  # blog.calendar_template = "calendar.html"

  # Enable pagination
    blog.paginate = true
    blog.per_page = 20
    blog.page_link = "page/{num}"

  # Custom categories
    blog.custom_collections = {
      category: {
        link: '/categories/{category}.html',
        template: '/category.html'
      }
    }
end

activate :sitemap_ping do |config|
  config.host = "#{data.settings.site.url}"
end

page "/blog/feed.xml", layout: false

###
# Blog settings - End
###

helpers do
  def set_hero_image(image)
    styles = %{<style>.header{background-image: url('/images/backgrounds/small/#{image}');}
    @media screen and (min-width: 25em){.header{background-image: url('/images/backgrounds/medium/#{image}');}}
    @media screen and (min-width: 50em){.header{background-image: url('/images/backgrounds/#{image}');}}</style>}
    return styles
  end

  def pretty_date(date)
    date.strftime('%e %b %Y')
  end

  def is_page_active(page)
    if current_page.url == page
      'metas__link--is-active'
    else
      ''
    end
  end

  def gtm(id)
    tag = %{<!-- Google Tag Manager -->
          <noscript><iframe src="//www.googletagmanager.com/ns.html?id=GTM-WW7MSH"
          height="0" width="0" style="display:none;visibility:hidden"></iframe></noscript>
          <script>(function(w,d,s,l,i){w[l]=w[l]||[];w[l].push({'gtm.start':
          new Date().getTime(),event:'gtm.js'});var f=d.getElementsByTagName(s)[0],
          j=d.createElement(s),dl=l!='dataLayer'?'&l='+l:'';j.async=true;j.src=
          '//www.googletagmanager.com/gtm.js?id='+i+dl;f.parentNode.insertBefore(j,f);
          })(window,document,'script','dataLayer','#{id}');</script>
          <!-- End Google Tag Manager -->}
    if build?
      return tag
    end
  end
end

set :css_dir, 'stylesheets'

set :js_dir, 'javascripts'

set :images_dir, 'images'

set :markdown_engine, :redcarpet

set :markdown, :tables => true, :fenced_code_blocks => true, :smartypants => true

# Build-specific configuration
configure :build do
  # Enable cache buster
  # activate :asset_hash

  # Use relative URLs
  # activate :relative_assets

  # Or use a different image path
  # set :http_prefix, "/Content/images/"

  activate :favicon_maker do |f|
    f.template_dir  = File.join(root, 'source')
    f.output_dir    = File.join(root, 'build')
    f.icons = {
      "_favicon_template.png" => [
        { icon: "apple-touch-icon-152x152-precomposed.png" },
        { icon: "apple-touch-icon-144x144-precomposed.png" },
        { icon: "apple-touch-icon-120x120-precomposed.png" },
        { icon: "apple-touch-icon-114x114-precomposed.png" },
        { icon: "apple-touch-icon-76x76-precomposed.png" },
        { icon: "apple-touch-icon-72x72-precomposed.png" },
        { icon: "apple-touch-icon-60x60-precomposed.png" },
        { icon: "apple-touch-icon-57x57-precomposed.png" },
        { icon: "apple-touch-icon-precomposed.png", size: "57x57" },
        { icon: "apple-touch-icon.png", size: "57x57" },
        { icon: "favicon-196x196.png" },
        { icon: "favicon-160x160.png" },
        { icon: "favicon-96x96.png" },
        { icon: "favicon-32x32.png" },
        { icon: "favicon-16x16.png" },
        { icon: "favicon.png", size: "16x16" },
        { icon: "favicon.ico", size: "64x64,32x32,24x24,16x16" },
        { icon: "mstile-144x144", format: "png" },
      ]
    }
  end

  # Sitemap
  activate :sitemap, hostname: data.settings.site.url

end

# Deploy
activate :deploy do |deploy|
  deploy.method = :git
  deploy.branch = 'master'
  deploy.build_before = true
end

# Autoprefixer
activate :autoprefixer do |config|
  config.browsers = ['last 2 versions', 'Explorer >= 9']
end

# Livereload
configure :development do
  activate :livereload
end

# Email
activate :protect_emails

# Minification
activate :minify_css
activate :minify_javascript
activate :minify_html, remove_input_attributes: false

# Gzip compression
activate :gzip

# I18n
activate :i18n

# Code highlighting
activate :rouge_syntax

# Directory indexes
activate :directory_indexes

# Disqus
activate :disqus do |d|
  d.shortname = 'blogantoinebrisset' # Remplacer par votre nom Disqus
end

# SEO redirects
activate :alias
