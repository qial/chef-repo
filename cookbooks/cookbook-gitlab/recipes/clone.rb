#
# Cookbook Name:: gitlab
# Recipe:: clone
#

gitlab = node['gitlab']

# If cloning from a private repository we need to use a deploy key
# Based on application cookbook: https://github.com/poise/application/blob/v4.1.4/templates/default/deploy-ssh-wrapper.erb
unless gitlab['deploy_key'].empty?
  template File.join(gitlab['home'], ".ssh", "deploy-ssh-wrapper.sh") do
    source "deploy-ssh-wrapper.erb"
    user gitlab['user']
    group gitlab['group']
    mode 0755
    variables({
      :path => File.join(gitlab['home'], ".ssh")
    })
  end

  file File.join(gitlab['home'], ".ssh", "id_deploy_key") do
    mode 0600
    content gitlab['deploy_key']
    user gitlab['user']
    group gitlab['group']
  end
end

# 6. GitLab
## Clone the Source
git "clone gitlabhq source" do
  destination gitlab['path']
  repository gitlab['repository']
  revision gitlab['revision']
  user gitlab['user']
  group gitlab['group']
  ssh_wrapper File.join(gitlab['home'], ".ssh", "deploy-ssh-wrapper.sh") unless gitlab['deploy_key'].empty?
  action :sync
end
