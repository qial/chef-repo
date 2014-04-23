### Production installation on Amazon Web Services (AWS) with Vagrant

### Requirements

* [VirtualBox](https://www.virtualbox.org)
* [Vagrant 1.3.x](http://vagrantup.com)

Make sure to use Vagrant v1.3.x. Do not install Vagrant via rubygems.org as there exists an old gem which will probably cause errors. Instead, go to [Vagrant download page](http://downloads.vagrantup.com/) and install a version ~> `1.3.0`.

### Installation

Create an AWS instance:

```bash
gem install berkshelf
vagrant plugin install vagrant-berkshelf
vagrant plugin install vagrant-omnibus
vagrant plugin install vagrant-aws
vagrant box add dummy https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box
git clone https://gitlab.com/gitlab-org/cookbook-gitlab.git ./gitlab
cd ./gitlab/
cp ./example/Vagrantfile_aws ./Vagrantfile
editor ./Vagrantfile
```
Fill in the AWS credentials under the aws section in Vagrantfile and then run:

```bash
vagrant up --provider=aws
eval $(vagrant ssh-config | awk '/HostName/ {print "HostName=" $2}')
sed -i.bak "s/example.com/$HostName/g" Vagrantfile
sed -i.bak 's/chef.run_list = \[\]/chef.run_list = \["gitlab::default"\]/g' Vagrantfile
vagrant provision
```

For more information on how to run the application, the tests and more please see the [Development installation on a virtual machine](doc/development.md).
