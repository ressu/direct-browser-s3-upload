set :rvm_ruby_string, '1.9.3@direct-s3'

set :application, "direct-s3-upload"
set :deploy_to, "/srv/badwolf/direct-s3-upload"

set :user, "ressu"
ssh_options[:forward_agent] = true
set :deploy_via, :remote_cache
set :repository,  "https://github.com/ressu/direct-browser-s3-upload.git"

set :use_sudo, false
set :copy_strategy, :export
set :copy_cache, true

# public/system is not needed for this
set :shared_children, %w(log tmp/pids)

server "web1.badwolf.fi", :web, :app

require "rvm/capistrano"
require "capistrano-unicorn"
require "bundler/capistrano"

namespace :aws do
  desc <<-DESC
    Copy credentials from local host to the server if the aws-credentials
    file exists. The target destination is within the shared directory and
    the file is then linked to the correct location.
  DESC
  task :credentials, :roles => ["app"] do
    if File.exists?(File.join("config", "aws-credentials.rb"))
      # Define file locations
      shared_config_path = File.join(shared_path, "config")
      shared_config = File.join(shared_config_path, "aws-credentials.rb")
      aws_config = File.join(current_release, "config", "aws-credentials.rb")

      # Create shared directory if it doesn't exist
      run "#{try_sudo} mkdir -p #{shared_config_path}"

      # Upload configuration to shared directory
      upload(File.join("config","aws-credentials.rb"), shared_config)

      # And finally link in to place
      run "#{try_sudo} ln -fs #{shared_config} #{aws_config}"
    end
  end
end

# Install RVM before doing anything else, if not installed
before 'deploy:setup', 'rvm:install_rvm'
before 'deploy:setup', 'rvm:install_ruby'

# Install configuration before finalizing installation
before 'deploy:finalize_update', 'aws:credentials'

# There really is no need to keep old releases laying around
after "deploy:restart", "deploy:cleanup"
