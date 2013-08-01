#
# Cookbook Name:: base_line
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#


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


include_recipe('ssh-keys')


node.normal["ssh_keys"] = {
  "deploy" => ['dshultz']
}
