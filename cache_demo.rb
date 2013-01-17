$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rubygems'
require 'bundler'
Bundler.require
require 'cgi'
require 'pry'
require 'pry-remote'

set :views, File.join(File.dirname(__FILE__), 'views')



get "/:cache_visibility/:revalidate/:last_modified/:etag" do
  now = Time.now

  case params[:last_modified]
  when 'same_last_modified'
    last_modified(Time.rfc2822('Wed, 16 Jan 2013 20:52:56 GMT'))
  when'different_last_modified'
    last_modified(now)
  end

  case params[:etag]
  when 'same_etag'
    etag('e9db93d4fb9cb8ba9f5a47f316edeec4')

  when 'different_etag'
    etag(now.to_i.to_s)
  end

  if params[:revalidate] == 'must_revalidate'
    cache_control params[:cache_visibility], :must_revalidate, :max_age => params[:max]
  elsif params[:revalidate] == 'no_revalidate'
    cache_control params[:cache_visibility], :max_age => params[:max]
  end

  if params[:age]
    headers('Age' => params[:age])
    headers('Date' => CGI::rfc1123_date(now))
  end

  @request_url = request.path
  @request_url << '?' + request.query_string unless request.query_string.empty?
  erb :demo
end

get "/docs/:cache_visibility" do
  cache_control params[:cache_visibility], :must_revalidate, :max_age => 0
  # cache_control :no_cache
  # cache_control :no_store
  headers('Vary' => 'Accept')
  if request.accept.include?('application/json')
    content_type :json
    '[{"_id":"4ef3accbfa9dcb3a91000004","accent_color":null,"account_id":"4ef3acf1fa9dcb3a9100000a","avatar_id":"4ef3accbfa9dcb3a91000002","background_color":null,"background_image_id":null,"contents":{},"created_at":"2011-12-09T00:50:05-06:00","description":null,"lowercase_slug":"test/hello/world","notify_on_open":false,"password":null,"published":true,"slug":"test/hello/world","theme_id":null,"title":"Hello world","updated_at":"2011-12-23T00:50:05-06:00","published_doc_url":"http://example.com/test/hello/world"}]'
  else
    erb :docs
  end
end
