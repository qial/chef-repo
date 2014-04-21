#
# Cookbook Name:: yum-corporate
# Attributes:: default
#
# Copyright 2011, Eric G. Wolfe
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Use the first part of the node.domain attribute as repo name (i.e. example from example.com)
default['yum']['corporate']['name'] = node['domain'] ?  node['domain'].split('.')[0] : 'localdomain'

# Set the corporate URL, e.g. http://yum.example.com/yum/rhel/6/$basearch
default['yum']['corporate']['baseurl'] = "http://yum.#{node['domain']}/yum/#{node['platform_family']}/#{node['platform_version'].to_i}/$basearch"

# URL for fetching GPG key
default['yum']['corporate']['gpgkey'] = nil

# Set GPG check, according to whether key is set.
if node['yum']['corporate']['gpgkey'].nil?
  default['yum']['corporate']['gpgcheck'] = false
else
  default['yum']['corporate']['gpgcheck'] = true
end
