class ChefCapConfigWrapper
  def initialize(config)
    @config = config
  end


  def [](key)
    @config["chef_#{key}"]
  end


  def logger
    @config.logger
  end


  def exists?(a)
    @config.exists?("chef_#{a}")
  end


  def respond_to?(v)
    @config.respond_to?("chef_#{v}") || @config.respond_to?(v)
  end


  def method_missing(sym, *args, &block)
    if @config.respond_to?("chef_#{sym}")
      @config.send("chef_#{sym}", *args, &block)
    elsif @config.respond_to?(sym)
      @config.send(sym, *args, &block)
    else
      super
    end
  end

end

namespace(:chef) do

  set(:chef_base_path) { ENV['VAGRANT'] ? '/vagrant' : chef_current_path }
  set(:chef_cookbook_path) { File.join('/etc', 'chef', 'cookbooks') }
  set(:chef_role_path) { File.join(chef_base_path, 'chef', 'roles') }
  set(:chef_data_bag_path) { File.join(chef_base_path, 'chef', 'data_bags') }
  set(:chef_attributes) { File.join(chef_base_path, "rails_app.json") }

  _cset(:chef_revision) { chef_source.head }
  _cset(:chef_deploy_to, '/var/www/chef')
  _cset(:chef_current_path) { File.join(chef_deploy_to, current_dir) }
  _cset(:chef_releases_path) { File.join(chef_deploy_to, 'release') }
  _cset(:chef_release_path) { File.join(chef_releases_path, release_name) }
  _cset(:chef_shared_path) { File.join(chef_deploy_to, 'shared') }

  _cset(:chef_scm, :git)
  _cset(:chef_real_revision) { chef_source.local.query_revision(chef_revision) { |cmd| with_env("LC_ALL", "C") { run_locally(cmd) } } }
  _cset(:chef_deploy_via, :remote_cache)
  _cset(:chef_repository, 'git@github.com:danshultz/chef-solo-rails.git')
  _cset(:chef_scm_config) { {
    :branch => chef_branch,
    :chef_remote => chef_remote,
    :git_shallow_clone => chef_git_shallow_clone
  } }

  _cset(:chef_strategy_config) { {
    :repository_cache => :chef_repository_cache,
    :release_path => :chef_release_path,
    :deploy_to => :chef_deploy_to,
    :real_revision => :chef_real_revision
  } }

  _cset(:chef_config_wrapper) { ChefCapConfigWrapper.new(self) }

  _cset(:chef_source) { Capistrano::Deploy::SCM.new(chef_scm, chef_config_wrapper) }
  _cset(:chef_strategy) { Capistrano::Deploy::Strategy.new(chef_deploy_via, chef_config_wrapper) }

  desc("provision the server with chef")
  task(:deploy) do
    bootstrap
    setup
    chef_strategy.deploy!
    run "#{try_sudo} rm -f #{chef_current_path} && #{try_sudo} ln -s #{chef_release_path} #{chef_current_path}"
    run_chef
  end

  task(:setup, :except => { :no_release => true }) do
    dirs = [chef_deploy_to, chef_releases_path, chef_shared_path]
    run "#{sudo} mkdir -p #{chef_deploy_to}"
    run "#{sudo} chown -R #{user} #{chef_deploy_to}"
    run "#{try_sudo} mkdir -p #{dirs.join(' ')}"
    run "#{try_sudo} chmod g+w #{dirs.join(' ')}" if fetch(:group_writable, true)
  end

  task(:run_chef) {
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

    run("cd #{chef_base_path} && #{sudo} bundle install")
    run("cd #{chef_base_path} && #{sudo} bundle exec berks install --path #{chef_cookbook_path}")
    sudo("chef-solo -j #{chef_attributes}")
  }


  task(:bootstrap) {
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

  def sudo_bash(cmd, options = {}, &blk)
    sudo("/bin/bash -c \'#{cmd}\'", options, &blk)
  end

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
