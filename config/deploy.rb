require('bundler/capistrano')
#%w(chef ).each { |x| load("config/recipes/#{x}.rb") }

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

role(:rails_server, "192.168.24.100")
role(:app, "192.168.24.100")
role(:web, "192.168.24.100")
role(:db, "192.168.24.100", :primary => true)

task(:chef) {
  load("config/recipes/chef.rb")
}
task(:app) {
  load("config/recipes/application.rb")
}
