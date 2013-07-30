name             'rails_app'
maintainer       'danshultz'
maintainer_email 'das0118@gmail.com'
license          'All rights reserved'
description      'Installs/Configures rails_app'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

recipe "rails_app", "Placeholder"
recipe "rails_app::database", "Create a database user"

%w( nginx postgres database ).each { |dep| depends(dep) }
