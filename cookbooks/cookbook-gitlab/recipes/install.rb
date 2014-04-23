#
# Cookbook Name:: gitlab
# Recipe:: install
#

gitlab = node['gitlab']

### Copy the example GitLab config
template File.join(gitlab['path'], 'config', 'gitlab.yml') do
  source "gitlab.yml.erb"
  user gitlab['user']
  group gitlab['group']
  variables({
    :host => gitlab['host'],
    :port => gitlab['port'],
    :user => gitlab['user'],
    :email_from => gitlab['email_from'],
    :support_email => gitlab['support_email'],
    :satellites_path => gitlab['satellites_path'],
    :repos_path => gitlab['repos_path'],
    :shell_path => gitlab['shell_path'],
    :signup_enabled => gitlab['signup_enabled'],
    :signin_enabled => gitlab['signin_enabled'],
    :projects_limit => gitlab['projects_limit'],
    :oauth_enabled => gitlab['oauth_enabled'],
    :oauth_block_auto_created_users => gitlab['oauth_block_auto_created_users'],
    :oauth_allow_single_sign_on => gitlab['oauth_allow_single_sign_on'],
    :oauth_providers => gitlab['oauth_providers'],
    :google_analytics_id => gitlab['extra']['google_analytics_id'],
    :sign_in_text => gitlab['extra']['sign_in_text'],
    :default_projects_features => gitlab['default_projects_features'],
    :gravatar => gitlab['gravatar'],
    :ldap_config => gitlab['ldap'],
    :ssh_port => gitlab['ssh_port'],
  })
  notifies :run, "bash[git config]", :immediately
  notifies :reload, "service[gitlab]"
end

### Make sure GitLab can write to the log/ and tmp/ directories
### Create directories for sockets/pids
### Create public/uploads directory otherwise backup will fail
%w{log tmp tmp/pids tmp/sockets public/uploads}.each do |path|
  directory File.join(gitlab['path'], path) do
    owner gitlab['user']
    group gitlab['group']
    mode 0755
    not_if { File.exist?(File.join(gitlab['path'], path)) }
  end
end

### Create directory for satellites
directory gitlab['satellites_path'] do
  owner gitlab['user']
  group gitlab['group']
  mode 0750
  not_if { File.exist?(gitlab['satellites_path']) }
end

### Unicorn config
template File.join(gitlab['path'], 'config', 'unicorn.rb') do
  source "unicorn.rb.erb"
  user gitlab['user']
  group gitlab['group']
  variables({
    :unicorn_workers_number => gitlab['unicorn_workers_number'],
    :unicorn_timeout => gitlab['unicorn_timeout']
  })
  notifies :reload, "service[gitlab]"
end

### Enable Rack attack
# Creating the file this way for the following reasons
# 1. Chef 11.4.0 must be used to keep support for AWS OpsWorks
# 2. Using file resource is not an option because it is ran at compilation time
# and at that point the file doesn't exist
# 3. Using cookbook_file resource is not an option because we do not want to include the file
# in the cookbook for maintenance reasons. Same for template resource.
# 4. Using remote_file resource is not an option because Chef 11.4.0 connects to remote URI
# see https://github.com/opscode/chef/blob/11.4.4/lib/chef/resource/remote_file.rb#L63
# 5 Using bash and execute resource is not an option because they would run at every chef run
# and supplying a restriction in the form of "not_if" would prevent an update of a file
# if there is any
# Ruby block is compiled at compilation time but only executed during execution time
# allowing us to create a resource.

ruby_block "Copy from example rack attack config" do
  block do
    resource = Chef::Resource::File.new("rack_attack.rb", run_context)
    resource.path File.join(gitlab['path'], 'config', 'initializers', 'rack_attack.rb')
    resource.content IO.read(File.join(gitlab['path'], 'config', 'initializers', 'rack_attack.rb.example'))
    resource.owner gitlab['user']
    resource.group gitlab['group']
    resource.mode 0644
    resource.run_action :create
    if resource.updated?
      self.notifies :reload, resources(:service => "gitlab")
    end
  end
end

### Configure Git global settings for git user, useful when editing via web
bash "git config" do
  code <<-EOS
    git config --global user.name "GitLab"
    git config --global user.email "gitlab@#{gitlab['host']}"
    git config --global core.autocrlf input
  EOS
  user gitlab['user']
  group gitlab['group']
  environment('HOME' => gitlab['home'])
  action :nothing
end

## Configure GitLab DB settings
template File.join(gitlab['path'], "config", "database.yml") do
  source "database.yml.#{gitlab['database_adapter']}.erb"
  user gitlab['user']
  group gitlab['group']
  variables({
    :user => gitlab['database_user'],
    :password => gitlab['database_password'],
    :host => node[gitlab['database_adapter']]['server_host'],
    :socket => gitlab['database_adapter'] == "mysql" ? node['mysql']['server']['socket'] : nil
  })
  notifies :reload, "service[gitlab]"
end

### Load db schema
execute "rake db:schema:load" do
  command <<-EOS
    PATH="/usr/local/bin:$PATH"
    bundle exec rake db:schema:load RAILS_ENV=#{gitlab['env']}
  EOS
  cwd gitlab['path']
  user gitlab['user']
  group gitlab['group']
  action :nothing
  subscribes :run, "mysql_database[gitlabhq_database]"
  subscribes :run, "postgresql_database[gitlabhq_database]"
end

### db:migrate
execute "rake db:migrate" do
  command <<-EOS
    PATH="/usr/local/bin:$PATH"
    bundle exec rake db:migrate RAILS_ENV=#{gitlab['env']}
  EOS
  cwd gitlab['path']
  user gitlab['user']
  group gitlab['group']
  action :nothing
  subscribes :run, "git[clone gitlabhq source]"
  subscribes :run, "execute[rake db:schema:load]"
end

### db:seed_fu
execute "rake db:seed_fu" do
  command <<-EOS
    PATH="/usr/local/bin:$PATH"
    bundle exec rake db:seed_fu RAILS_ENV=#{gitlab['env']}
  EOS
  cwd gitlab['path']
  user gitlab['user']
  group gitlab['group']
  action :nothing
  subscribes :run, "execute[rake db:schema:load]"
end

## Setup Init Script
# Creating the file this way for the following reasons
# 1. Chef 11.4.0 must be used to keep support for AWS OpsWorks
# 2. Using file resource is not an option because it is ran at compilation time
# and at that point the file doesn't exist
# 3. Using cookbook_file resource is not an option because we do not want to include the file
# in the cookbook for maintenance reasons. Same for template resource.
# 4. Using remote_file resource is not an option because Chef 11.4.0 connects to remote URI
# see https://github.com/opscode/chef/blob/11.4.4/lib/chef/resource/remote_file.rb#L63
# 5 Using bash and execute resource is not an option because they would run at every chef run
# and supplying a restriction in the form of "not_if" would prevent an update of a file
# if there is any
# Ruby block is compiled at compilation time but only executed during execution time
# allowing us to create a resource.

ruby_block "Copy from example gitlab init config" do
  block do
    resource = Chef::Resource::File.new("gitlab_init", run_context)
    resource.path "/etc/init.d/gitlab"
    resource.content IO.read(File.join(gitlab['path'], "lib", "support", "init.d", "gitlab"))
    resource.mode 0755
    resource.run_action :create
    if resource.updated? && gitlab['env'] == 'production'
      self.notifies :run, resources(:execute => "set gitlab to start on boot"), :immediately
    end
  end
end

case gitlab['env']
when 'production'
  # Updates defaults so gitlab can boot on start. As per man pages of update-rc.d runs only if links do not exist
  execute "set gitlab to start on boot" do
    if platform_family?("debian")
      command "update-rc.d gitlab defaults 21"
    else
      command "chkconfig --level 21 gitlab on"
    end
    action :nothing
  end

  ## Setup logrotate
  # Creating the file this way for the following reasons
  # 1. Chef 11.4.0 must be used to keep support for AWS OpsWorks
  # 2. Using file resource is not an option because it is ran at compilation time
  # and at that point the file doesn't exist
  # 3. Using cookbook_file resource is not an option because we do not want to include the file
  # in the cookbook for maintenance reasons. Same for template resource.
  # 4. Using remote_file resource is not an option because Chef 11.4.0 connects to remote URI
  # see https://github.com/opscode/chef/blob/11.4.4/lib/chef/resource/remote_file.rb#L63
  # 5 Using bash and execute resource is not an option because they would run at every chef run
  # and supplying a restriction in the form of "not_if" would prevent an update of a file
  # if there is any
  # Ruby block is compiled at compilation time but only executed during execution time
  # allowing us to create a resource.

  ruby_block "Copy from example logrotate config" do
    block do
      resource = Chef::Resource::File.new("logrotate", run_context)
      resource.path "/etc/logrotate.d/gitlab"
      resource.content IO.read(File.join(gitlab['path'], "lib", "support", "logrotate", "gitlab"))
      resource.mode 0644
      resource.run_action :create
    end
  end

  # SMTP email settings
  if gitlab['smtp']['enabled']
    smtp = gitlab['smtp']
    template File.join(gitlab['path'], 'config', 'initializers', 'smtp_settings.rb') do
      source "smtp_settings.rb.erb"
      user gitlab['user']
      group gitlab['group']
      variables({
        :address => smtp['address'],
        :port => smtp['port'],
        :username => smtp['username'],
        :password => smtp['password'],
        :domain => smtp['domain'],
        :authentication => smtp['authentication'],
        :enable_starttls_auto => smtp['enable_starttls_auto']
      })
      notifies :reload, "service[gitlab]"
    end
  end

  if gitlab['aws']['enabled']
    template "aws.yml" do
      owner gitlab['user']
      group gitlab['group']
      path "#{gitlab['path']}/config/aws.yml"
      mode 0755
      variables({
        :aws_access_key_id => gitlab['aws']['aws_access_key_id'],
        :aws_secret_access_key => gitlab['aws']['aws_secret_access_key'],
        :bucket => gitlab['aws']['bucket'],
        :region => gitlab['aws']['region'],
        :host => gitlab['aws']['host'],
        :endpoint => gitlab['aws']['endpoint']
      })
      notifies :reload, "service[gitlab]"
    end
  end

  execute "rake assets:clean" do
    command <<-EOS
      PATH="/usr/local/bin:$PATH"
      bundle exec rake assets:clean RAILS_ENV=#{gitlab['env']}
    EOS
    cwd gitlab['path']
    user gitlab['user']
    group gitlab['group']
    action :nothing
    subscribes :run, "execute[rake db:migrate]", :immediately
  end

  execute "rake assets:precompile" do
    command <<-EOS
      PATH="/usr/local/bin:$PATH"
      bundle exec rake assets:precompile RAILS_ENV=#{gitlab['env']}
    EOS
    cwd gitlab['path']
    user gitlab['user']
    group gitlab['group']
    action :nothing
    subscribes :run, "execute[rake db:migrate]", :immediately
  end

  execute "rake cache:clear" do
    command <<-EOS
      PATH="/usr/local/bin:$PATH"
      bundle exec rake cache:clear RAILS_ENV=#{gitlab['env']}
    EOS
    cwd gitlab['path']
    user gitlab['user']
    group gitlab['group']
    action :nothing
    subscribes :run, "execute[rake db:migrate]", :immediately
  end
else
  ## For execute javascript test
  include_recipe "phantomjs"
end
