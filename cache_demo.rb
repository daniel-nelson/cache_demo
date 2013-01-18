$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rubygems'
require 'bundler'
Bundler.require
require 'cgi'
require 'pry'
require 'pry-remote'

set :views, File.join(File.dirname(__FILE__), 'views')



get "/:revalidation/:last_modified/:etag/:max_age" do
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

  if params[:revalidation] == 'no_revalidate'
    cache_control :public, :max_age => params[:max_age]
  else
    cache_control :public, params[:revalidation].sub('_', '-'), :max_age => params[:max_age]
  end

  headers('Age' => '8')
  headers('Date' => CGI::rfc1123_date(now))

  @request_url = request.path
  @request_url << '?' + request.query_string unless request.query_string.empty?
  erb :demo
end

get "/docs/:revalidation" do

  if params[:revalidation] == 'no_revalidate'
    cache_control :private, :max_age => params[:max_age]
  else
    cache_control :private, params[:revalidation].sub('_', '-'), :max_age => params[:max_age]
  end

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
