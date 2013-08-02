require('bundler/capistrano')

# Set the applicable stages and use the multistage extension to manage them
set(:stages, %w(production staging dev))
set(:default_stage, "dev")
require 'capistrano/ext/multistage'

# Set the common Capistrno User
set(:user, ENV['AS'] || 'deploy')
set(:password) {
  puts
  warn("A server is prompting for the \"#{user}\" user's login password.")
  warn("You can run as another user with the AS environment variable.")
  Capistrano::CLI.password_prompt
}

# include local ssh keys
ssh_options[:keys] = [File.join(ENV["HOME"], ".ssh", "id_rsa")]
ssh_options[:forward_agent] = true
default_run_options[:pty] = true
set(:use_sudo, false);

set(:deploy_via, :remote_cache)
set(:deploy_to) { "/var/www/#{application}" }


# load the chef recipe to deploy chef configurations
task(:chef) {
  load("config/recipes/chef.rb")
}


# load application recipe to deploy rails application
task(:app) {
  load("config/recipes/application.rb")
}
