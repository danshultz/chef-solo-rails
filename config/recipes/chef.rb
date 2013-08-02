# Chef capistrano deployment configuration

require 'json'

set(:application, "chef")
set(:repository, "git@github.com:danshultz/chef-solo-rails.git")

# allow the chef_base_path to be overridden
_cset(:chef_base_path) { current_path }
set(:chef_cookbook_path) { File.join('/etc', 'chef', 'cookbooks') }
set(:chef_role_path) { File.join(chef_base_path, 'chef', 'roles') }
set(:chef_data_bag_path) { File.join(chef_base_path, 'chef', 'data_bags') }
set(:chef_attributes) { File.join('/etc/chef', "attributes.json") }


# Override the deploy:migrate task to prevent it from doing anything
namespace(:deploy) do
  task(:migrate) { }
end


# Chef Specific tasks
namespace(:_chef) do

  before('deploy:setup', '_chef:ensure_deploy')
  before('deploy:cold', 'deploy:setup')
  before('deploy', '_chef:ensure_deploy')
  after('deploy:setup', '_chef:setup')
  after('deploy:update', '_chef:run')


  desc("run chef solo")
  task(:run) {
    sudo_bash([
      "if [ ! -e /etc/chef ] || [ ! -e #{chef_cookbook_path} ]; then",
        "mkdir -p /etc/chef/cookbooks;",
      'fi;'
    ].join(' '))
    sudo("chown  #{user} /etc/chef")

    sudo_bash('if [ -e /etc/chef/solo.rb ]; then rm /etc/chef/solo.rb; fi;')
    put(<<config, '/etc/chef/solo.rb')
# Config options generated
# http://docs.opscode.com/config_rb_solo.html
data_bag_path "#{chef_data_bag_path}"
role_path "#{chef_role_path}"
cookbook_path "#{chef_cookbook_path}"
config

    sudo_bash("cd #{chef_base_path} && bundle install")
    sudo_bash("cd #{chef_base_path} && bundle exec berks install --path #{chef_cookbook_path}")
    sudo_bash("if [ -e #{chef_attributes} ]; then rm #{chef_attributes}; fi;")
    find_servers.each { |server|
      put(JSON.pretty_generate(server.options[:chef_attributes]), chef_attributes, :hosts => server.host)
    }
    sudo("chef-solo -j #{chef_attributes}")
  }


  # Ensure ownership is set properly for deploy user
  # I'm sure this is somehow unecessary
  task(:ensure_deploy) {
    sudo("mkdir -p #{deploy_to}")
    sudo("chown -R #{user} #{deploy_to}")
  }


  # setup and bootstrap chef
  task(:setup) {

    apt_cmd = [
      "env",
      "DEBCONF_TERSE='yes'",
      "DEBIAN_PRIORITY='critical'",
      "DEBIAN_FRONTEND=noninteractive",
      "apt-get --force-yes -qyu"
    ].join(" ")

    sudo_bash([
      'if [[ `which ruby` && (`ruby -v` =~ "ruby 1.9") ]]; then',
        'echo "Ruby 1.9 verified";',
      'else',
        "#{apt_cmd} update;",
        "#{apt_cmd} purge ruby ruby1.8 ruby1.8-dev;",
        "#{apt_cmd} install ruby1.9.1 ruby1.9.1-dev git-core build-essential libxslt-dev libxml2-dev;",
      'fi'
    ].join(' '))

    gem_install('chef', '11.4.4')
    gem_install('bundler')

  }


  def gem_install(name, version=nil)
    v = version.nil? ? "" : "-v #{version}"
    sudo_bash([
      "if [[ `gem q -i -n \"^#{name}$\" #{v}` =~ \"true\" ]]; then",
        "echo \"#{name} verified\";",
      'else',
        "gem install #{name} #{v} --no-rdoc --no-ri;",
      'fi'
    ].join(' '))
  end

end
