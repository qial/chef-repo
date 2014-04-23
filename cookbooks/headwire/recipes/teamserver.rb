# AEM Team Server creation

# Base packages
#include_recipe "users::sysadmins"
#include_recipe "sudo"
include_recipe "apt"
include_recipe "git"
include_recipe "vim"
include_recipe "nano"

# Set up Apache2
include_recipe "apache2"

# Set up LDAP?
# TODO?

# Set up Jenkins
# TODO

# Set up Nexus
# TODO

# Set up GitLab
#getting a strange error about not finding a "ruby" recipe in mysql
#include_recipe "gitlab"

#echo "OHAAAAIIIIIII"

