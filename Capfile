load 'deploy'
load 'config/deploy'

# Apt Install a package
def apt_install(package, update=false)
    apt_cmd = [
      "env",
      "DEBCONF_TERSE='yes'",
      "DEBIAN_PRIORITY='critical'",
      "DEBIAN_FRONTEND=noninteractive",
      "apt-get --force-yes -qyu"
    ].join(" ")

    sudo_bash([
      "if [[ `dpkg -l #{package} 2> /dev/null` ]]; then",
        "echo \"#{package} verified\";",
      'else',
        ("#{apt_cmd} update;" if update),
        "#{apt_cmd} install #{package};",
      'fi'
    ].compact.join(' '))
end


# run apt update
def apt_update
    apt_cmd = [
      "env",
      "DEBCONF_TERSE='yes'",
      "DEBIAN_PRIORITY='critical'",
      "DEBIAN_FRONTEND=noninteractive",
      "apt-get --force-yes -qyu"
    ].join(" ")

    sudo_bash("#{apt_cmd} update")
end


# exectute a command untirely as sudo in bash
def sudo_bash(cmd, options = {}, &blk)
  sudo("/bin/bash -c \'#{cmd}\'", options, &blk)
end
