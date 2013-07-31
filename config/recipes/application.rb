set(:application, "blog")
set(:repository,  "git@github.com:danshultz/sample-rails-app.git")

before('deploy:cold', 'deploy:setup')
