set(:application, "chef")
set(:repository, "git@github.com:danshultz/chef-solo-rails.git")

_cset(:chef_base_path) { current_path }
set(:chef_cookbook_path) { File.join('/etc', 'chef', 'cookbooks') }
set(:chef_role_path) { File.join(chef_base_path, 'chef', 'roles') }
set(:chef_data_bag_path) { File.join(chef_base_path, 'chef', 'data_bags') }
set(:chef_attributes) { File.join(chef_base_path, "rails_app.json") }

namespace(:deploy) do
  task(:migrate) { }
end


namespace(:_chef) do

  before('deploy:setup', '_chef:dir_hack')
  before('deploy:cold', 'deploy:setup')
  after('deploy:setup', '_chef:setup')
  after('deploy:update', '_chef:run')


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
    sudo("chef-solo -j #{chef_attributes}")
  }


  task(:dir_hack) {
    sudo("mkdir -p #{deploy_to}")
    sudo("chown -R #{user} #{deploy_to}")
  }

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
