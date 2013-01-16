$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rubygems'
require 'bundler'
Bundler.require
require 'cgi'
require 'pry'
require 'pry-remote'

set :views, File.join(File.dirname(__FILE__), 'views')



get "/:cache_visibility/must_revalidate/:validity" do
  last_modified_string = 'Wed, 16 Jan 2013 20:52:56 GMT'
  last_modified = Time.rfc2822(last_modified_string)
  date = Time.now
  age = date.to_i - last_modified.to_i

  cache_control params[:cache_visibility], :must_revalidate, :max_age => params[:max]
  headers('Age' => age.to_s)
  headers('Date' => CGI::rfc1123_date(date))
  headers('Last-Modified' => last_modified_string)
  if params[:validity] == 'invalid'
    etag(Time.now.to_i.to_s)
  elsif params[:validity] == 'valid'
    etag('e9db93d4fb9cb8ba9f5a47f316edeec4')
  end
  headers('Content-Type' => 'text/plain')
  params[:data]
end

get "/docs" do
  cache_control :private, :must_revalidate, :max_age => 0
  headers('Vary' => 'Accept')
  if request.accept.include?('application/json')
    content_type :json
    '[{"_id":"4ef3accbfa9dcb3a91000004","accent_color":null,"account_id":"4ef3acf1fa9dcb3a9100000a","avatar_id":"4ef3accbfa9dcb3a91000002","background_color":null,"background_image_id":null,"contents":{},"created_at":"2011-12-09T00:50:05-06:00","description":null,"lowercase_slug":"test/hello/world","notify_on_open":false,"password":null,"published":true,"slug":"test/hello/world","theme_id":null,"title":"Hello world","updated_at":"2011-12-23T00:50:05-06:00","published_doc_url":"http://example.com/test/hello/world"}]'
  else
    erb :docs
  end
end
