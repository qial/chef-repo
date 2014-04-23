### Production installation with Chef Solo

This guide details installing a GitLab server with Chef Solo.
By using Chef Solo you do not need a dedicated Chef Server.

### Requirements

Ubuntu 12.04, CentOS 6.4 or RHEL 6.5

### Installation

Configure your installation parameters by editing the `/tmp/solo.json` file.
Parameters which you will likely want to customize include:

```bash
curl -o /tmp/solo.json https://gitlab.com/gitlab-org/cookbook-gitlab/raw/master/solo.json.production_example
```

You only need to keep parameters which need to differ from their default values.
For example, if you are using `mysql`, there is no need to keep the `postgresql` configuration.
If you are NOT on Debian/Ubuntu, you can remove `server_debian_password` and if you are not
planning to use MySQL replication, then you can remove `server_repl_password`.

If you wish to relay mail through a remote SMTP server instead of having Postfix installed you
can entirely remove the `postfix` section and remove its entry from `run_list`.

First we install dependencies based on the OS used:

```bash
distro="$(cat /etc/issue | awk ''NR==1'{ print $1 }')"
case "$distro" in
  Ubuntu)
    sudo apt-get update
    sudo apt-get install -y build-essential git curl # We need git to clone the cookbook, newer version will be compiled using the cookbook
  ;;
  CentOS)
    yum groupinstall -y "Development Tools"
  ;;
  *)
    echo "Your distro is not supported." 1>&2
    exit 1
  ;;
esac
```

Next run:

```bash
cd /tmp
curl -LO https://www.opscode.com/chef/install.sh && sudo bash ./install.sh -v 11.4.4
sudo /opt/chef/embedded/bin/gem install berkshelf --no-ri --no-rdoc
git clone https://gitlab.com/gitlab-org/cookbook-gitlab.git /tmp/cookbook-gitlab
cd /tmp/cookbook-gitlab
/opt/chef/embedded/bin/berks vendor /tmp/cookbooks
cat > /tmp/solo.rb << EOF
cookbook_path    ["/tmp/cookbooks/"]
log_level        :debug
EOF
sudo chef-solo -c /tmp/solo.rb -j /tmp/solo.json
```


Chef-solo command should start running and setting up GitLab and it's dependencies.
No errors should be reported and at the end of the run you should be able to navigate to the
`gitlab['host']` you specified using your browser and connect to the GitLab instance.

You should consider removing the `.json` file once you are done with it since
it contains sensitive information:

```bash
rm /tmp/solo.json
```

### Note about using the external database

By setting the attribute:

```json
{
  "gitlab": {
    "external_database": true
  }
}
```

database won't be installed on the server.
If the external database doesn't have database table and database user created, superuser credentials would have to be supplied so database table and user can be created. For example, if using mysql you will need to supply:

```json
{
  "gitlab": {
    "external_database": true,
    "database_adapter": "mysql",
    "database_user": "git",
    "database_password": "gitdbpass"
    default['mysql']['server_host'] = "localhost"
  },
  "mysql": {
    "server_host": "http://example.com",
    "server_root_username": "root",
    "server_root_password": "rootpass"
  }
}
```
This will connect to the database located at `http://example.com` with user `root`. User `root` has the credentials to create the database so this cookbook will create database table `gitlabhq_production` and database user `git` with password `gitdbpass`.

*Note* If using an existing database and database user use the same credentials for `server_root_username` and `database_user` (passwords too).
There is a manual step involved after the run is complete to add admin user to the database.
You will need to create an initial user manually with:

`sudo -u git -H bundle exec rake db:seed_fu RAILS_ENV=production`


### Enabling HTTPS

In order to enable HTTPS you will need to provide the following custom attributes:

```json
{
  "gitlab": {
    "port": "443",
    "url": "https://example.com/",
    "ssl_certificate": "-----BEGIN CERTIFICATE-----\nLio90slsdflsa0salLfjfFLJQOWWWWFLJFOAlll0029043jlfssLSIlccihhopqs\n-----END CERTIFICATE-----",
    "ssl_certificate_key": "-----BEGIN PRIVATE KEY-----\nLio90slsdflsa0salLfjfFLJQOWWWWFLJFOAlll0029043jlfssLSIlccihhopqs\n-----END PRIVATE KEY-----"
  }
}
```

### Cloning GitLab from private repository

By default GitLab is cloned from the public repository.
If you need to clone GitLab from a private repository (eg. you are maintaining a fork or need to install GitLab Enterprise) you need to specify a deploy key:

```json
{
  "gitlab": {
    "deploy_key": "-----BEGIN RSA PRIVATE KEY-----\nMIIEpAIBAAK\n-----END RSA PRIVATE KEY-----"
  }
}
```

*Note*: Deploy key is a *private key*.
=======

*Note*: SSL certificate(.crt) and SSL certificate key(.key) must be in valid format. If this is not the case nginx won't start! By default, both the certificate and key will be located in `/etc/ssl/` and will have the name of HOSTNAME, eg. `/etc/ssl/example.com.crt` and `/etc/ssl/example.com.key`.

### Including multi-line strings in JSON

You can use the following Ruby 1.9 one-liner to output valid JSON for a certificate file or private key:

```bash
ruby -rjson -e 'puts JSON.dump([ARGF.read])[1..-2]' my_site.cert
```

This one-liner reads `my_site.cert` and writes its contents to standard out as a multi-line JSON string.

### Storing repositories and satellites in a custom directory

In some situations it can be practical to put repository and satellite data on a separate volume.
Below we assume that the GitLab system user (`git`) will have UID:GID 1234:1234, and that `/mnt/storage` is owned by 1234:1234.

```json
{
  "gitlab": {
    "user_uid": 1234,
    "user_gid": 1234,
    "repos_path": "/mnt/storage/repositories",
    "satellites_path": "/mnt/storage/satellites"
  }
}
```

### Using a proxy server for network access

If you are behind a proxy server, you must ensure that the `http_proxy`
and `https_proxy` environment variables have been correctly set.

In addition, you need to add the following to the end of your `solo.rb` file:

```ruby
http_proxy      "https://my-proxy.example.com:8080"
https_proxy     "https://my-proxy.example.com:8080"
```

### RHEL

If you are on RHEL 6.4+, `libicu-devel` has been moved to the
*optional* channel. You must enable the optional channel if you have not
already done so, see here: https://access.redhat.com/site/solutions/389423.

### Monitoring

Basic monitoring can be [setup with monit](doc/monit.md)
