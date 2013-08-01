This repository is a working example and template that can be used to bootstrap
a server and deploy a basic rails applicaiton using chef and capistrano

This was developed for a talk [Cooking with Chef](http://danshultz.github.io/talks/cooking_with_chef)

### Dependencies

* VirtualBox
* Vagrant
* Ruby >= 1.9.3
* Bundler Gem

### Quick Start

1. Clone Repo
1. ```bundle install```
1. ```vagrant up```
1. Add your a new user databag to ```chef/data_bags/users``` like [dshultz.json](https://github.com/danshultz/chef-solo-rails/blob/master/chef/data_bags/users/dshultz.json)
1. Edit ```chef/cookbooks/baseline/recipes/default.rb``` to include your ssh key for the deploy user
1. ```cap chef deploy:cold AS=vagrant``` (password is vagrant) ***

*** This is required the first time a "deploy" is executed, each subsequent provision 
can simply use ```cap chef deploy```
