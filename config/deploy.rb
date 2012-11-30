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

server "web1.badwolf.fi", :web, :app

require "rvm/capistrano"
require "capistrano-unicorn"
require "bundler/capistrano"

# Install RVM before doing anything else, if not installed
before 'deploy:setup', 'rvm:install_rvm'
before 'deploy:setup', 'rvm:install_ruby'

# Restart Unicorn
after 'deploy:restart', 'unicorn:restart'

# if you want to clean up old releases on each deploy uncomment this:
after "deploy:restart", "deploy:cleanup"
