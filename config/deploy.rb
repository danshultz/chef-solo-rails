require('bundler/capistrano')
%w(chef ).each { |x| load("config/recipes/#{x}.rb") }

set(:application, "blog")
set(:repository,  "git@github.com:danshultz/sample-rails-app.git")
set(:user, ENV['AS'] || 'deploy')
set(:password) {
  puts
  warn("A server is prompting for the \"#{user}\" user's login password.")
  warn("You can run as another user with the AS environment variable.")
  Capistrano::CLI.password_prompt
}
ssh_options[:keys] = [File.join(ENV["HOME"], ".ssh", "id_rsa")]

set(:deploy_via, :remote_cache)
set(:deploy_to, "/var/www/#{application}")


role(:rails_server, "192.168.24.100")
role(:app, "192.168.24.100")
role(:web, "192.168.24.100")
role(:db, "192.168.24.100", :primary => true)

