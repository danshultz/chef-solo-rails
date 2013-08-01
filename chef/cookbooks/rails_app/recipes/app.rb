#
# Cookbook Name:: rails_app
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe("postgresql")

app_name = node['rails_app']['name']
user_name = "rails_#{app_name}"
app_directory = "/var/www/#{app_name}"

directory("/var/www") do
  owner "root"
  group "root"
  mode 0755
  action :create
end


group("admin") { action :create }


file("/etc/sudoers.d/group_admin") do
  owner "root"
  group "root"
  mode 0440
  content "%admin ALL=(ALL) NOPASSWD: ALL"
end


directory(app_directory) do
  owner "deploy"
  mode 0755
  action :create
end
