#
# Cookbook Name:: git-daemon
# Recipe:: default
#
# Copyright 2012, Steffen Gebert / TYPO3 Association
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

####################################
# User setup
####################################

group node['git-daemon']['group']

user node['git-daemon']['user'] do
  gid node['git-daemon']['group']
  home node['git-daemon']['home']
  comment "Gerrit system user"
  shell "/bin/bash"
  system true
end

[
	node['git-daemon']['home'],
	node['git-daemon']['home'] + "/repositories"
].each do |dir|
  directory dir do
    owner node['git-daemon']['user']
    group node['git-daemon']['group']
    recursive true
  end
end


####################################
# Git daemon
####################################

package "git-daemon-run"

template "/etc/sv/git-daemon/run" do
  source "git-daemon.run.erb"
  notifies :restart, "service[git-daemon]"
end

template "/etc/init.d/git-daemon" do
  source "init.erb"
  mode 0744
end

service "git-daemon" do
  supports :status => true, :restart => true, :reload => false
  action [ :enable, :start ]
end