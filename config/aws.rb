# AWS configuration

begin
  # Store AWS credentials in a file called aws-credentials.rb somewhere
  # inside the load path
  require 'aws-credentials'
rescue LoadError
  S3_KEY    = ENV['S3_KEY']
  S3_SECRET = ENV['S3_SECRET']
end
S3_BUCKET='/test-direct-upload'

# EXPIRE_TIME=(60 * 5) # 5 minutes
EXPIRE_TIME=3000
S3_URL='http://s3-ireland.amazonaws.com'
