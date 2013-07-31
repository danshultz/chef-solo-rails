require('bundler/capistrano')
#%w(chef ).each { |x| load("config/recipes/#{x}.rb") }

set(:stages, %w(production staging dev))
set(:default_stage, "dev")
require 'capistrano/ext/multistage'

set(:user, ENV['AS'] || 'deploy')
set(:password) {
  puts
  warn("A server is prompting for the \"#{user}\" user's login password.")
  warn("You can run as another user with the AS environment variable.")
  Capistrano::CLI.password_prompt
}
ssh_options[:keys] = [File.join(ENV["HOME"], ".ssh", "id_rsa")]
ssh_options[:forward_agent] = true
default_run_options[:pty] = true
set(:use_sudo, false);

set(:deploy_via, :remote_cache)
set(:deploy_to) { "/var/www/#{application}" }


task(:chef) {
  load("config/recipes/chef.rb")
}
task(:app) {
  load("config/recipes/application.rb")
}
