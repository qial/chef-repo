# Things to do when creating new monthly minor or major cookbook release

NOTE: This is a guide for GitLab developers.

## Check the official guides

Check the [install guide](https://gitlab.com/gitlab-org/gitlab-ce/blob/master/doc/install/installation.md) and the [update guide](https://gitlab.com/gitlab-org/gitlab-ce/blob/master/doc/update/patch_versions.md) for any minor/major changes.

## Check for differences in template files

Diff between TEMPLATE and CONFIG in main GitLab repository

1. templates/gitlab.yml.erb and config/gitlab.yml.example
1. templates/nginx.erb and lib/support/nginx/gitlab
1. templates/unicorn.rb.erb and config/unicorn.rb.example
1. templates/database.yml.(postgresql | mysql).erb and config/database.yml.(postgresql | mysql)

## Change revision

In  [default attributes](https://gitlab.com/gitlab-org/cookbook-gitlab/blob/master/attributes/default.rb#L45) change the revision for production environment

## Fix any failing tests

Most of the time only tests that need fixing are in [clone spec](spec/clone_spec.rb)

## Change the version of the cookbook

Replace the version in [metadata](metadata.rb) with the new version.
Example: If released GitLab version is 6.7, cookbook version is 0.6.7

## Running the cookbook in different environments

Provision a GitLab instance by using the cookbook in supported environments:

1. Ubuntu 12.04
1. CentOS 6.5
1. AWS OpsWorks
1. Vagrant (development)

After provisioning, login to each instance and *at least* create a repository and push to GitLab.
