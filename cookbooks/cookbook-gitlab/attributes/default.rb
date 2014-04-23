# Packages
if platform_family?("rhel")
  packages = %w{
    libicu-devel libxslt-devel libyaml-devel libxml2-devel gdbm-devel libffi-devel zlib-devel openssl-devel
    libyaml-devel readline-devel curl-devel openssl-devel pcre-devel git mysql-devel gcc-c++
    ImageMagick-devel ImageMagick
  }
else
  packages = %w{
    build-essential zlib1g-dev libyaml-dev libssl-dev libgdbm-dev libreadline-dev libncurses5-dev libffi-dev
    curl openssh-server checkinstall libxml2-dev libxslt-dev libcurl4-openssl-dev libicu-dev python-docutils
    logrotate vim curl wget checkinstall
  }
end

default['gitlab']['packages'] = packages
default['gitlab']['ruby'] = "2.0.0-p353" # Latest 2.0 by ruby-build 20131225.1 (Ubuntu)

# GitLab shell
default['gitlab']['shell_repository'] = "https://github.com/gitlabhq/gitlab-shell.git"

# GitLab shell configuration
default['gitlab']['repos_path'] = "/home/git/repositories"
default['gitlab']['shell_path'] = "/home/git/gitlab-shell"
default['gitlab']['redis_path'] = "/usr/local/bin/redis-cli"
default['gitlab']['redis_host'] = "127.0.0.1"
default['gitlab']['redis_port'] = "6379"
default['gitlab']['namespace']  = "resque:gitlab"
default['gitlab']['self_signed_cert'] = false

# GitLab
default['gitlab']['repository'] = "https://github.com/gitlabhq/gitlabhq.git"
default['gitlab']['deploy_key'] = "" # Optional. Private key used to connect to private GitLab repository.

# Setup environments
if node['gitlab']['env'] == "development"
  default['gitlab']['environments'] = %w{development test}
  default['gitlab']['revision'] = "master"
  default['gitlab']['url'] = "http://localhost:3000/"
  default['gitlab']['port'] = "3000"
  default['gitlab']['ssh_port'] = "2222"
  default['gitlab']['shell_revision'] = "master"
else
  default['gitlab']['environments'] = %w{production}
  default['gitlab']['revision'] = "6-8-stable" # Must be branch, otherwise GitLab update will run on each chef run
  default['gitlab']['url'] = "http://localhost:80/"
  default['gitlab']['port'] = "80"
  default['gitlab']['ssh_port'] = "22"
  default['gitlab']['shell_revision'] = "v1.9.3"
end

# GitLab configuration
default['gitlab']['git_path'] = "/usr/local/bin/git"
default['gitlab']['host'] = "localhost"
default['gitlab']['email_from'] = "gitlab@localhost"
default['gitlab']['support_email'] = "support@localhost"

default['gitlab']['signup_enabled'] = false
default['gitlab']['signin_enabled'] = true
default['gitlab']['projects_limit'] = 10
default['gitlab']['oauth_enabled'] = false
default['gitlab']['oauth_block_auto_created_users'] = true
default['gitlab']['oauth_allow_single_sign_on'] = false
default['gitlab']['oauth_providers'] = [] # Example: default['gitlab']['oauth_providers'] = [ { "name": "google_oauth2", "app_id": "YOUR APP ID", "app_secret": "YOUR APP SECRET", "args": "access_type: 'offline', approval_prompt: ''" }, { "name": "twitter", "app_id": "YOUR APP ID", "app_secret": "YOUR APP SECRET" }, { "name":"github", "app_id": "YOUR APP ID", "app_secret": "YOUR APP SECRET" }]

default['gitlab']['extra']['google_analytics_id'] = "" # Example:  "AA-1231231-1"
default['gitlab']['extra']['sign_in_text'] = "" # Example:  "![Company Logo](http://www.example.com/logo.png)"

default['gitlab']['ldap']['enabled'] = false
default['gitlab']['ldap']['host'] = "_your_ldap_server"
default['gitlab']['ldap']['base'] = "_the_base_where_you_search_for_users"
default['gitlab']['ldap']['port'] = 636
default['gitlab']['ldap']['uid'] = "sAMAccountName"
default['gitlab']['ldap']['method'] = "ssl"
default['gitlab']['ldap']['bind_dn'] = "_the_full_dn_of_the_user_you_will_bind_with"
default['gitlab']['ldap']['password'] = "_the_password_of_the_bind_user"
default['gitlab']['ldap']['allow_username_or_email_login'] = true

default['gitlab']['gravatar'] = true

default['gitlab']['default_projects_features']['issues'] = true
default['gitlab']['default_projects_features']['merge_requests'] = true
default['gitlab']['default_projects_features']['wiki'] = true
default['gitlab']['default_projects_features']['wall'] = false
default['gitlab']['default_projects_features']['snippets'] = false
default['gitlab']['default_projects_features']['visibility_level'] = "private"

# Gems
default['gitlab']['bundle_install'] = "SSL_CERT_FILE=/opt/local/etc/certs/cacert.pem bundle install --path=.bundle --deployment"

# Databases
# Assumed defaults
# database: postgresql (option: mysql)
# environment: production (option: development)
default['gitlab']['external_database'] = false
default['gitlab']['database_adapter'] = "postgresql"
default['gitlab']['database_password'] = "datapass"
default['gitlab']['database_user'] = "git"
default['gitlab']['env'] = "production"

# MySQL attributes
default['mysql']['server_host'] = "localhost" # Host of the server that hosts the database.
default['mysql']['client_host'] = "localhost" # Host where user connections are allowed from.
default['mysql']['server_root_username'] = "root"
default['mysql']['server_root_password'] = "rootpass"
default['mysql']['server_repl_password'] = "replpass"
default['mysql']['server_debian_password'] = "debianpass"

 # Here for legacy reasons. mysql cookbook removed support for configurable sockets. See: https://github.com/opscode-cookbooks/mysql#mysql-cookbook
case node["platform_family"]
when "debian"
  default['mysql']['server']['socket'] = "/var/run/mysqld/mysqld.sock"
when "rhel"
  default['mysql']['server']['socket'] = "/var/lib/mysql/mysql.sock"
end

# PostgreSQL attributes
include_attribute 'postgresql'

default['postgresql']['version'] = "9.3"
case node["platform_family"]
when "debian"
  default['postgresql']['enable_pgdg_apt'] = true
  default['postgresql']['client']['packages'] = %w{postgresql-client-9.3 libpq-dev}
  default['postgresql']['server']['packages'] = %w{postgresql-9.3}
  # due to the way attributes are organized we have to override the default paths too
  default['postgresql']['dir'] = "/etc/postgresql/#{node['postgresql']['version']}/main"
  default['postgresql']['config']['data_directory'] = "/var/lib/postgresql/#{node['postgresql']['version']}/main"
  default['postgresql']['config']['hba_file'] = "/etc/postgresql/#{node['postgresql']['version']}/main/pg_hba.conf"
  default['postgresql']['config']['ident_file'] = "/etc/postgresql/#{node['postgresql']['version']}/main/pg_ident.conf"
  default['postgresql']['config']['external_pid_file'] = "/var/run/postgresql/#{node['postgresql']['version']}-main.pid"
  default['postgresql']['config']['ssl'] = false
  default['postgresql']['config']['unix_socket_directory'] = nil
  default['postgresql']['config']['unix_socket_directories'] = '/var/run/postgresql'
  default['gitlab']['postgresql']['configuration_dir'] = nil
when "rhel"
  default['postgresql']['enable_pgdg_yum'] = true
  default['postgresql']['client']['packages'] = ["postgresql#{node['postgresql']['version'].split('.').join}-devel"]
  default['postgresql']['server']['packages'] = ["postgresql#{node['postgresql']['version'].split('.').join}-server"]
  default['postgresql']['contrib']['packages'] = ["postgresql#{node['postgresql']['version'].split('.').join}-contrib"]
  default['postgresql']['dir'] = "/var/lib/pgsql/data"
  default['postgresql']['server']['service_name'] = "postgresql-#{node['postgresql']['version']}"
  default['gitlab']['postgresql']['configuration_dir'] = "/usr/pgsql-#{node['postgresql']['version']}/bin"
end
default['postgresql']['username']['postgres'] = "postgres"
default['postgresql']['password']['postgres'] = "psqlpass"
default['postgresql']['server_host'] = "localhost"

# Postfix
default['postfix']['mail_type'] = "client"
default['postfix']['myhostname'] = "mail.localhost"
default['postfix']['mydomain'] = "localhost"
default['postfix']['myorigin'] = "mail.localhost"
default['postfix']['smtp_use_tls'] = "no"

# User
default['gitlab']['user'] = "git" # Do not change this attribute in production since some code from the GitLab repo such as init.d script assume it is git.
default['gitlab']['group'] = "git"
default['gitlab']['user_uid'] = nil # Use to specify user id.
default['gitlab']['user_gid'] = nil # Use to specify group id.
default['gitlab']['home'] = "/home/git"

# GitLab hq
default['gitlab']['path'] = "/home/git/gitlab" # Do not change this attribute in production since some code from the GitLab repo such as init.d assume this path.
default['gitlab']['satellites_path'] = "/home/git/gitlab-satellites"

# Unicorn specific configuration
default['gitlab']['unicorn_workers_number'] = 2
default['gitlab']['unicorn_timeout'] = 30

# Nginx ssl certificates
default['gitlab']['ssl_certificate_path'] = "/etc/ssl" # Path to .crt file. If it directory doesn't exist it will be created
default['gitlab']['ssl_certificate_key_path'] = "/etc/ssl" # Path to .key file. If directory doesn't exist it will be created
default['gitlab']['ssl_certificate'] = "" # SSL certificate
default['gitlab']['ssl_certificate_key'] = "" # SSL certificate key

# SMTP email
default['gitlab']['smtp'] = {
  :enabled => false,
  :address => "email.server.com",
  :port => 456,
  :username => "smtp",
  :password => "123456",
  :domain => "gitlab.example.com",
  :authentication => "login",
  :enable_starttls_auto => true
}

# AWS is disabled by default. If enabled is set to true, bundler will install gems from aws group and use the credentials to populate config/aws.yml
default['gitlab']['aws'] = {
  :enabled => false,
  :provider => 'AWS', # required
  :aws_access_key_id     => 'yyy', # required
  :aws_secret_access_key => 'xxx', # required
  :bucket => 'zzz', # optional
  :region => 'eu-west-1', # optional, defaults to 'us-east-1'
  :host     => 's3.example.com', # optional, defaults to nil
  :endpoint  => 'https://s3.example.com:8080' # optional, defaults to nil
}

# Monit specific configuration
default['gitlab']['monitrc']['sidekiq'] = {
  :pid_path => "#{default['gitlab']['path']}/tmp/pids/sidekiq.pid",
  :start_timeout => "80", # in seconds
  :stop_timeout => "40", # in seconds
  :cpu_threshold => "40", # in %. Assuming our server has two cores, 40% totalcpu means pinning 80% of a single core
  :cpu_cycles_number => "10",
  :mem_threshold => "225", # in MB
  :mem_cycles_number => "10",
  :restart_number => "5", # Number of consecutive restarts before alerting.
  :restart_cycles_number => "5", # Number of cycles to monitor for consecutive restarts.
  :max_workers_timeout => "60" # Number of consecutive seconds that Sidekiq may report 25/25 workers busy
}

default['gitlab']['monitrc']['unicorn'] = {
  :pid_path => "#{default['gitlab']['path']}/tmp/pids/unicorn.pid",
  :mem_threshold => "1000.0", # in MB
  :mem_cycles_number => "25"
}

default['gitlab']['monitrc']['disk_usage'] = {
  :disk_percentage => "85", # in %, 0 to disable this config
  :path => "/" # Path on the filesystem to monitor
}

# Can be specified if you need to use different alert email in sidekiq monitor config
# If you need only one alert email, specify with https://github.com/phlipper/chef-monit/blob/1.4.0/attributes/default.rb#L27
default['gitlab']['monitrc']['notify_email'] = nil

# Some events may warrant extra notifcations, e.g. to a pager notification service
default['gitlab']['monitrc']['emergency_email'] = nil
default['gitlab']['monitrc']['emergency_events'] = ['timeout']
