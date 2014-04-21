yum-corporate Cookbook
======================

[![Build Status](https://secure.travis-ci.org/atomic-penguin/cookbook-yum-corporate.png?branch=master)](http://travis-ci.org/atomic-penguin/cookbook-yum-corporate)

Configures repo file, via attributes, for internal corporate yum mirror.

This is a simple cookbook, where you may set a few attributes to point
servers at a local yum mirror.  Much of the credit goes to @BryanWB
for the idea, and a good portion of the original implementation in
the soon to be deprecated yumrepo cookbook.

Requirements
------------

This cookbook depends on the `yum_repository` provider from the `yum` cookbook.
You need to have a RHEL family platform, and yum, to use the cookbook.

#### cookbooks 

- `yum` - Opscode maintained v3.0.x cookbook

Attributes
----------
The following are overridable attributes, in the `yum['corporate']` namespace.

#### yum-corporate::default

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['yum']['corporate']['name']</tt></td>
    <td>String</td>
    <td>Short name for the repo.  The first part of the domain attribute will be used, if not set.
        given example.com, value would be:</td>
    <td><tt>example</tt></td>
  </tr>
  <tr>
    <td><tt>['yum']['corporate']['baseurl']</tt></td>
    <td>String</td>
    <td>URL where repodata folder is located.  Your domain, platform_family, and major platform_version will be used as a guess, if not set.
        Given domain example.com; platform_family rhel; and platform_version 6.4 the default would be:</td>
    <td><tt>http://yum.example.com/yum/rhel/6/$basearch</tt></td>
  </tr>
  <tr>
    <td><tt>['yum']['corporate']['gpgkey']</tt></td>
    <td>String</td>
    <td>URL where GPG key is located.  The repository provider in yum should authorize the key by setting this attribute.</td>
    <td><tt>nil (off)</tt></td>
  </tr>
  <tr>
    <td><tt>['yum']['corporate']['gpgcheck']</tt></td>
    <td>true/false</td>
    <td>Whether, or not, to validate signed packages from this repository against the GPG key specified.
        Default value depends on whether gpgkey has been set, or not.</td>
    <td><tt>false, if ['yum']['corporate']['gpgkey'] not set.
            true, if ['yum']['corporate']['gpgkey'] is set.</tt></td>
  </tr>
</table>

Usage
-----
#### yum-corporate::default

Optionally, set attributes in a role, and
include `yum-corporate` in your node's `run_list`:

```
default_attributes(
  :yum => {
    :corporate => {
      :gpgkey => {
        "http://yum.example.com/yum/RPM-GPG-KEY-example" 
      }
    }
  }
)
```

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[yum-corporate]"
  ]
}
```

#### yum-corporate::undo

Removes repository file based on `['yum']['corporate']['name']`.
This recipe does the opposite action of yum-corporate::default.

Contributing
------------

1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------

Author:: Eric G. Wolfe
Copyright:: 2010-2011

Contributor:: Bryan W. Berry
Copyright:: 2012

Author:: Tippr, Inc.
Copyright:: 2010

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
