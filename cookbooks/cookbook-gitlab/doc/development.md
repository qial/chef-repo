### Development installation on a virtual machine with Vagrant

### Requirements

* [Ruby 1.9 or higher](https://www.ruby-lang.org/) and [Rubygems](http://rubygems.org/)
* [VirtualBox](https://www.virtualbox.org)
* [Vagrant 1.4.0](https://www.vagrantup.com/download-archive/v1.4.0.html)
* The NFS packages for the synced folder of Vagrant. These are already installed if you are using Mac OSX and not necessary if you are using Windows. On Linux install them by running:

```bash
sudo apt-get install nfs-kernel-server nfs-common portmap
```

Make sure to use Vagrant v1.3.5. Do not install Vagrant via rubygems.org as there exists an old gem which will probably cause errors. Instead, go to [Vagrant download page](http://downloads.vagrantup.com/) and install version `1.3.5`.

On OS X you can also choose to use [the (commercial) Vagrant VMware Fusion plugin](http://www.vagrantup.com/vmware) instead of VirtualBox.

### Speed notice

Running in Vagrant is slow compared to running in a metal (non-virtualized) environment. To run your tests at an acceptable speed we recommend using the [Spork application preloader](https://github.com/sporkrb/spork). If you run `bundle exec spork` before running a single test it completes 4 to 10 times faster after the initial run.

Time of `time be rspec spec/models/project_spec.rb` on a Intel core i5 processor with 6GB:
- Metal without spork: 53 seconds
- Metal with spork: 16 seconds
- Virtualbox without spork: 298 seconds (almost 5 minutes)
- Virtualbox with Spork: 32 seconds

The paid [VMware Fusion](http://www.vmware.com/products/fusion/) is a little faster than Virtualbox but it doesn't make a big difference. In it does seem to be more stable than Virtualbox, so consider it if you encounter problems running Virtualbox.

Rails 4.1 comes with the [Spring application preloader](https://github.com/jonleighton/spring), when we upgrade to Rails 4.1 that will replace Spork.

If you are frequently developing GitLab you can consider installing all the development dependencies on your [metal environment](development_metal.md).

### Installation

We assume you already have a working Ruby and Rubygems installation.

`Vagrantfile` already contains the correct attributes so in order use this cookbook in a development environment following steps are needed:

1. Check if you have a gem version of Vagrant installed:

```bash
gem list vagrant
```

If it lists a version of vagrant, remove it with:

```bash
gem uninstall vagrant
```

Next steps are:

```bash
vagrant plugin install vagrant-berkshelf --plugin-version 1.3.7
vagrant plugin install vagrant-omnibus
vagrant plugin install vagrant-bindfs
git clone https://gitlab.com/gitlab-org/cookbook-gitlab.git
cd ./cookbook-gitlab
bundle install
vagrant up --provision
```

If you have VMWare Fusion and the Vagrant VMWare Fusion provider you can opt to use that instead of the VirtualBox provider. Follow all of the steps above except substitute the following vagrant up command instead:

```bash
vagrant up --provider=vmware_fusion --provision
```

By default the VM uses 1.5GB of memory and 2 CPU cores. If you want to use more memory or cores you can use the GITLAB_VAGRANT_MEMORY and GITLAB_VAGRANT_CORES environment variables:

```bash
GITLAB_VAGRANT_MEMORY=2048 GITLAB_VAGRANT_CORES=4 vagrant up
```

**Note:**
You can't use a vagrant project on an encrypted partition (ie. it won't work if your home directory is encrypted).

You'll be asked for your password to set up NFS shares.
Also note that if you are using a firewall on the host machine, it should allow the NFS related traffic,
otherwise you might encouter NFS mounting errors during `vagrant up` like:
```
mount.nfs: mount to NFS server '.../cookbook-gitlab/home_git' failed: timed out, giving up
```


### Running the tests

Once everything is done you can log into the virtual machine and run the tests as the git user:

```bash
vagrant ssh
cd /home/git/gitlab/
bundle exec rake gitlab:test
```

### Start the Gitlab application

```bash
cd /home/git/gitlab/
bundle exec foreman start
```

You should also configure your own remote since by default it's going to grab
gitlab's master branch.

```bash
git remote add mine git://github.com/me/gitlabhq.git
# or if you prefer set up your origin as your own repository
git remote set-url origin git://github.com/me/gitlabhq.git
```

#### Accessing the application

`http://0.0.0.0:3000/` or your server for your first GitLab login.

```
admin@local.host
5iveL!fe
```

#### Virtual Machine Management

When done just log out with `^D` and suspend the virtual machine

```bash
vagrant suspend
```

then, resume to hack again

```bash
vagrant resume
```

Run

```bash
vagrant halt
```

to shutdown the virtual machine, and

```bash
vagrant up
```

to boot it again.

You can find out the state of a virtual machine anytime by invoking

```bash
vagrant status
```

Finally, to completely wipe the virtual machine from the disk **destroying all its contents**:

```bash
vagrant destroy # DANGER: all is gone
```

### OpenLDAP

If you need to setup OpenLDAP in order to test the functionality you can use the [basic OpenLDAP setup guide](doc/open_LDAP.md)

### Updating

The gitlabhq version is _not_ updated when you rebuild your virtual machine with the following command:

```bash
vagrant destroy && vagrant up
```

You must update it yourself by going to the gitlabhq subdirectory in the gitlab-vagrant-vm repo and pulling the latest changes:

```bash
cd gitlabhq && git pull --ff origin master
```

A bit of background on why this is needed. When you run 'vagrant up' there is a checkout action in the recipe that points to [gitlabhq repo](https://github.com/gitlabhq/gitlabhq). You won't see any difference when running 'git status' in the cookbook-gitlab repo because the cloned directory is in the [.gitignore](https://gitlab.com/gitlab-org/cookbook-gitlab/blob/master/.gitignore). You can update the gitlabhq repo yourself or remove the home_git so the repo is checked out again.
