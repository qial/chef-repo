#
# Cookbook Name:: gitlab
# Recipe:: gitlab_shell_install
#

gitlab = node['gitlab']

## Edit config and replace gitlab_url
template File.join(gitlab['shell_path'], "config.yml") do
  source "gitlab_shell.yml.erb"
  user gitlab['user']
  group gitlab['group']
  variables({
    :user => gitlab['user'],
    :home => gitlab['home'],
    :url => gitlab['url'],
    :repos_path => gitlab['repos_path'],
    :redis_path => gitlab['redis_path'],
    :redis_host => gitlab['redis_host'],
    :redis_port => gitlab['redis_port'],
    :namespace => gitlab['namespace'],
    :self_signed_cert => gitlab['self_signed_cert']
  })
end

## Do setup
directory "Repositories path" do
  path gitlab['repos_path']
  owner gitlab['user']
  group gitlab['group']
  mode 02770
end

directory "SSH key directory" do
  path File.join(gitlab['home'], "/", ".ssh")
  owner gitlab['user']
  group gitlab['group']
  mode 0700
end

file "authorized keys file" do
  path File.join(gitlab['home'], "/", ".ssh", "/", "authorized_keys")
  owner gitlab['user']
  group gitlab['group']
  mode 0600
  action :create_if_missing
end
