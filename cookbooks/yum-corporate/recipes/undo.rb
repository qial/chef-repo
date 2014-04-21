#
# Cookbook Name:: yum-corporate
# Recipe:: undo
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

yum_repository node['yum']['corporate']['name'] do
  action :delete
end

unless Chef::Config[:solo]
  ruby_block 'remove yum-corporate::undo from run_list when there is a conflict' do
    block do
      node.run_list.remove('recipe[yum-corporate::undo]')
    end
    only_if { node.run_list.include?('recipe[yum-corporate::default]') }
  end
end
