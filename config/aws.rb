# AWS configuration, most of these settings should be overridden in
# aws-credentials
S3_BUCKET='/direct-upload'

# EXPIRE_TIME=(60 * 5) # 5 minutes
EXPIRE_TIME=3000
S3_URL='http://s3-ireland.amazonaws.com'

begin
  # Store AWS credentials in a file called aws-credentials.rb
  require './aws-credentials'
rescue LoadError
  S3_KEY    = ENV['S3_KEY']
  S3_SECRET = ENV['S3_SECRET']
end
