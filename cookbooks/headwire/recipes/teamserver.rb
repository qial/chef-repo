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

# Set up Tomcat
include_recipe "tomcat"

# Download Jenkins
remote_file "#{Chef::Config['file_cache_path']}/jenkins.war" do
  source    node[:jenkins][:url]
  mode      00644
  not_if "test -f #{Chef::Config['file_cache_path']}/jenkins.war"
end

# Download Nexus
remote_file "#{Chef::Config['file_cache_path']}/nexus-#{node[:nexus][:version]}.war" do
  source    node[:nexus][:url]
  checksum  node[:nexus][:checksum]
  mode      00644
  not_if "test -f #{Chef::Config['file_cache_path']}/nexus-#{node[:nexus][:version]}.war"
end

# Install Nexus to Tomcat
execute "Installing Nexus #{node[:nexus][:version]} from WAR" do
  cwd Chef::Config['file_cache_path']
  command "(mv nexus-#{node[:nexus][:version]}.war /var/lib/tomcat6/webapps/nexus.war)"
# <<-COMMAND  COMMAND
#    (mkdir git-#{node['git']['version']} && tar -zxf git-#{node['git']['version']}.tar.gz -C git-#{node['git']['version']} --strip-components 1)
#    (cd git-#{node['git']['version']} && make prefix=#{node['git']['prefix']} install)
#  creates "#{node['git']['prefix']}/bin/git"
#  not_if "git --version | grep #{node['git']['version']}"
end

# Install Jenkins to Tomcat
execute "Installing Jenkins from WAR" do
  cwd Chef::Config['file_cache_path']
  command "(mv jenkins.war /var/lib/tomcat6/webapps/jenkins.war)"
end

# Set up GitLab
#getting a strange error about not finding a "ruby" recipe in mysql
include_recipe "gitlab::setup"
include_recipe "gitlab::deploy"

#echo "OHAAAAIIIIIII"

