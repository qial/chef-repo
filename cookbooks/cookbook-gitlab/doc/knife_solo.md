### Production installation with Knife Solo

This guide details installing a GitLab server with Knife Solo.

### Requirements

[knife-solo](http://matschaffer.github.io/knife-solo/)

### Installation

Create chef directory:

```bash
$ gem install berkshelf
$ gem install knife-solo
$ knife configure
$ knife solo init ./gitlab_chef
$ cd ./gitlab_chef/
```

Install cookbooks:

```bash
$ curl -o Berksfile https://gitlab.com/gitlab-org/cookbook-gitlab/raw/master/Berksfile
$ sed -i.bak '/^metadata$/d' Berksfile
$ echo "cookbook 'gitlab', git: 'https://gitlab.com/gitlab-org/cookbook-gitlab.git'" >> Berksfile
$ berks install --path ./cookbooks
```

SSH config setting:

```
$ cat << __EOS__ >> ~/.ssh/config
Host vagrant
  Hostname 127.0.0.1
  Port 2222
  User vagrant
  IdentityFile ~/.vagrant.d/insecure_private_key
__EOS__
```

Node setting:

```
$ cat << __EOS__ > ./nodes/vagrant.json
{
  "gitlab": {
    "host": "localhost",
    "url": "http://localhost:80/"
  },
  "run_list": [
    "gitlab::default"
  ]
}
__EOS__
```

Install GitLab server:

```
$ knife solo prepare vagrant --bootstrap-version 11.4.4
$ knife solo cook vagrant
```

For more information on how to run the application, the tests and more please see the [Development installation on a virtual machine](doc/development.md).
