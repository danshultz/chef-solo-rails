#
# Cookbook Name:: rails::database
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe("postgresql")
include_recipe("postgresql::server")
include_recipe("postgresql::ruby")

# use a custom hba_config
hba_conf = resources("template[#{node['postgresql']['dir']}/pg_hba.conf]")
hba_conf.source("pg_hba.conf.erb")
hba_conf.cookbook("rails_app")


postgresql_connection_info = {
  :host => "localhost",
  :port => node['postgresql']['config']['port'],
  :username => 'postgres',
  :password => node['postgresql']['password']['postgres']
}

user = node['rails_app']['database']['user']
password = node['rails_app']['database']['password']


database_user(user) {
  connection postgresql_connection_info
  password password
  database_name user
  provider Chef::Provider::Database::PostgresqlUser
  action :create
}


database(user) {
  connection postgresql_connection_info
  provider Chef::Provider::Database::Postgresql
  action :create
}
