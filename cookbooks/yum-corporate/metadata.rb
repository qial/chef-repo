maintainer       'Eric G. Wolfe'
maintainer_email 'wolfe21@marshall.edu'
license          'Apache 2.0'
description      'Configures repo file, via attributes, for internal corporate yum mirror.'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '3.0.1'
depends          'yum'
name             'yum-corporate'
recipe 'yum-corporate::default', 'Installs repo file, for internal corporate yum mirror'

%w{ redhat centos scientific amazon oracle }.each do |os|
  supports os, '>= 5.0'
end
