#
# Cookbook Name:: base_line
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

group("admin") { action :create }


file("/etc/sudoers.d/group_admin") do
  owner "root"
  group "root"
  mode 0440
  content "%admin ALL=(ALL) NOPASSWD: ALL"
end


user("deploy") do
  home "/home/deploy"
  group "admin"
  shell "/bin/bash"
end


directory("/home/deploy") do
  owner "deploy"
  mode 0755
  action :create
end


node.normal["ssh_keys"] = {
  "deploy" => ['dshultz']
}


include_recipe('ssh-keys')

