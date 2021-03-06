This repository is a working example and template that can be used to bootstrap
a server and deploy a basic rails applicaiton using chef and capistrano

This was developed for a talk [Cooking with Chef](http://danshultz.github.io/talks/cooking_with_chef)

### Dependencies

* VirtualBox
* Vagrant
* Ruby >= 1.9.3
* Bundler Gem
* Git

### Quick Start

1. Clone Repo. ```git clone https://github.com/danshultz/chef-solo-rails```
1. ```cd chef-solo-rails```
1. ```bundle install```
1. ```vagrant up```
1. Add your a new user databag to ```chef/data_bags/users``` like [dshultz.json](https://github.com/danshultz/chef-solo-rails/blob/master/chef/data_bags/users/dshultz.json)
1. Edit ```chef/cookbooks/baseline/recipes/default.rb``` to include your ssh key for the deploy user
1. ```cap chef deploy:cold AS=vagrant``` (password is vagrant) ***

*** This is required the first time a "deploy" is executed, each subsequent provision
can simply use ```cap chef deploy```


### Deploying a Rails Application after configuring with Chef

1. Make sure to update the rails configuration details in [config/deploy/dev.rb](https://github.com/danshultz/chef-solo-rails/blob/master/config/deploy/dev.rb#L48)
1. run ```cap chef deploy``` to make sure the updated rails app configurations are in place if you haven't done so
1. Update any necessary configurations in [config/recipes/application.rb](https://github.com/danshultz/chef-solo-rails/blob/master/config/recipes/application.rb) for your rails app
1. run ```cap app deploy:cold``` to deploy your application for the first time
1. Review your deployed application at http://192.168.24.100
