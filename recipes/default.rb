#
# Cookbook Name:: opennms
# Recipe:: default
#
# Copyright 2014, Spanlink Communications, Inc
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

include_recipe 'build-essential::default'
chef_gem 'java_properties'
chef_gem 'rest-client'

if node['opennms']['stable']
  yum_repository 'opennms-stable-common' do
    description 'RPMs Common to All OpenNMS Architectures RPMs (stable)'
    baseurl node['yum']['opennms-stable-common']['baseurl']
    mirrorlist node['yum']['opennms-stable-common']['url']
    gpgkey node['yum']['opennms']['key_url']
    failovermethod node['yum']['opennms-stable-common']['failovermethod']
    includepkgs node['yum']['opennms-stable-common']['includepkgs']
    exclude node['yum']['opennms-stable-common']['exclude']
    action :create
  end
  yum_repository 'opennms-stable-rhel6' do
    description 'RedHat Enterprise Linux 6.x and CentOS 6.x RPMs (stable)'
    baseurl node['yum']['opennms-stable-rhel6']['baseurl']
    mirrorlist node['yum']['opennms-stable-rhel6']['url']
    gpgkey node['yum']['opennms']['key_url']
    includepkgs node['yum']['opennms-stable-rhel6']['includepkgs']
    exclude node['yum']['opennms-stable-rhel6']['exclude']
    action :create
  end
else
  yum_repository 'opennms-snapshot-common' do
      description 'RPMs Common to All OpenNMS Architectures RPMs (stable)'
      baseurl node['yum']['opennms-snapshot-common']['baseurl']
      mirrorlist node['yum']['opennms-snapshot-common']['url']
      gpgkey node['yum']['opennms']['key_url']
      failovermethod node['yum']['opennms-snapshot-common']['failovermethod']
      includepkgs node['yum']['opennms-snapshot-common']['includepkgs']
      exclude node['yum']['opennms-snapshot-common']['exclude']
      gpgcheck false
      action :create
  end
  yum_repository 'opennms-snapshot-rhel6' do
    description 'RedHat Enterprise Linux 6.x and CentOS 6.x RPMs (stable)'
    baseurl node['yum']['opennms-snapshot-rhel6']['baseurl']
    mirrorlist node['yum']['opennms-snapshot-rhel6']['url']
    gpgkey node['yum']['opennms']['key_url']
    includepkgs node['yum']['opennms-snapshot-rhel6']['includepkgs']
    exclude node['yum']['opennms-snapshot-rhel6']['exclude']
      gpgcheck false
    action :create
  end
end

fqdn = node[:fqdn]
fqdn ||= node[:hostname]

onms_home = node[:opennms][:conf][:home]
onms_home ||= '/opt/opennms'

hostsfile_entry node['ipaddress'] do
  hostname fqdn
  action [:create_if_missing, :append]
end

onms_packages = ['opennms-core', 'opennms-webapp-jetty', 'opennms-docs']
onms_versions =  [node['opennms']['version'], node['opennms']['version'],
  node['opennms']['version']]

if node['opennms']['plugin']['xml']
  onms_packages.push 'opennms-plugin-protocol-xml'
  onms_versions.push node['opennms']['version']
end

if node['opennms']['plugin']['nsclient']
  onms_packages.push 'opennms-plugin-protocol-nsclient'
  onms_versions.push node['opennms']['version']
end

if node['opennms']['stable']
  package onms_packages do
    version onms_versions
    allow_downgrade node['opennms']['allow_downgrade']
    action :install
  end
else
  yum_package onms_packages do
    timeout 3200
    allow_downgrade node['opennms']['allow_downgrade']
    action :install
  end
end

package "iplike" do
  action :install
end

package "perl-libwww-perl" do
  action :install
end
package "perl-XML-Twig" do
  action :install
end

include_recipe 'opennms::send_events'

if node['opennms']['upgrade']
  include_recipe 'opennms::upgrade'
end

execute "runjava" do
  cwd onms_home
  creates "#{onms_home}/etc/java.conf"
  command "#{onms_home}/bin/runjava -s"
end

execute "install" do
  cwd onms_home
  creates "#{onms_home}/etc/configured"
  command "#{onms_home}/bin/install -dis"
end

include_recipe 'opennms::base_templates'
include_recipe 'opennms::templates'

service "opennms" do
  supports :status => true, :restart => true
  action [ :enable]#, :start ]
end
