#
# Cookbook Name:: dokuwiki
# Recipe:: webserver
# Author:: Kyle Watson
#

app_name = 'dokuwiki'
app_config = node[app_name]
# What is this?
#app_secrets = Chef::EncryptedDataBagItem.load("secrets",app_name)

include_recipe "apache2"
include_recipe "apache2::mod_php5"

# Set up the Apache virtual host
web_app app_name do
  server_name app_config['server_name']
  docroot app_config['docroot']
  #server_aliases [node['fqdn'], node['hostname']]
  template "#{app_name}.conf.erb"
  log_dir node['apache']['log_dir']
end

#
# Set up the local application config.
# This part is most likely to be different for different applications.
#

directory "#{app_config['config_dir']}" do
  owner "root"
  group "root"
  mode "0755"
  action :create
  recursive true
end

template "#{app_config['config_dir']}/local.config.php" do
  source "local.config.php.erb"
  mode 0440
  owner "root"
  group node['apache']['group']
  variables(
    'db_master' => {
      'user' => app_config['db_user'],
      'pass' => app_secrets[node.chef_environment]['db_pass'],
      'dbname' => app_config['db_name'],
      'host' => master_db_host,
    }
  )
end


