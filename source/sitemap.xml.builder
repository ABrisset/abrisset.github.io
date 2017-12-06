xml.instruct!
xml.urlset 'xmlns' => "http://www.sitemaps.org/schemas/sitemap/0.9" do
  sitemap.resources.select { |page| page.path =~ /\.html|\.markdown/ && !page.data.noindex == true }.each do |page|
    xml.url do
      xml.loc "https://www.antoine-brisset.com#{page.url}"
    end
  end
end