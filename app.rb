require 'sinatra'
require 'base64'
require 'openssl'
require 'cgi'
require 'json'
require 'coffee-script'
require './config/aws'

get '/' do
  send_file 'index.html'
end

get '/styles.css' do
  send_file 'styles.css'
end

get '/favicon.ico' do
  send_file 'favicon.ico'
end

get '/awscors.js' do
  coffee :awscors
end

get '/robots.txt' do
  content_type :text
  robots_txt = <<-ROBOTS.gsub(/^ {4}/, '')
    User-agent:*
    Disallow: *
  ROBOTS
end

get '/signput' do
  content_type :json
  objectName = "/#{CGI::escape(params['name'])}"

  mimeType = params['type']
  expires = Time.now.getutc.to_i + EXPIRE_TIME

  amzHeaders = "x-amz-acl:public-read"
  stringToSign = "PUT\n\n#{mimeType}\n#{expires}\n#{amzHeaders}\n#{S3_BUCKET}#{objectName}";
  sig = CGI::escape(Base64.strict_encode64(OpenSSL::HMAC.digest('sha1', S3_SECRET, stringToSign)))

  {:upload_url => "#{S3_URL}#{S3_BUCKET}#{objectName}?AWSAccessKeyId=#{S3_KEY}&Expires=#{expires}&Signature=#{sig}"}.to_json
end
