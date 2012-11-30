# AWS configuration, most of these settings should be overridden in
# aws-credentials
begin
  # Store AWS credentials in a file called aws-credentials.rb
  require './config/aws-credentials'
rescue LoadError
  S3_KEY    = ENV['S3_KEY']
  S3_SECRET = ENV['S3_SECRET']
end

S3_BUCKET='/direct-upload' unless defined?(S3_BUCKET)

# EXPIRE_TIME=(60 * 5) # 5 minutes
EXPIRE_TIME=3000 unless defined?(EXPIRE_TIME)
S3_URL='http://s3-eu-west-1.amazonaws.com' unless defined?(S3_URL)
