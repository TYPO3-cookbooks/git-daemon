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
  comment "Git-daemon system user"
  shell "/bin/bash"
  system true
end

[
  node['git-daemon']['home'],
  node['git-daemon']['path']
].each do |dir|
  directory dir do
    user node['git-daemon']['user']
    group node['git-daemon']['group']
    recursive true
    mode 0755
  end
end


####################################
# Git daemon
####################################

package "git-core"

# systemd actions within test-kitchen / docker end up with
# error "Failed to get D-Bus connection: Unknown error -1"

systemd_socket 'git-daemon' do
  description 'Git Activation Socket'
  conflicts 'git-daemon.service'
  install do
    wanted_by 'sockets.target'
  end
  socket do
    listen_stream 9418
    accept true
  end
  action [:create, :enable, :start]
  # WARNING: disabled during tests because of systemd in Docker
  not_if { node['virtualization']['system'] == 'docker' }
end

# the trailing @ denotes that this is a template service.
# this service is not directly started, but invoked by the socket
systemd_service 'git-daemon@' do
  description 'Git Repositories Server Daemon'
  after 'network.target'
  install do
    wanted_by 'multi-user.target'
  end
  service do
    user node['git-daemon']['user']
    standard_input 'socket'
    standard_output 'inherit'
    standard_error 'journal'
    # The '-' is to ignore non-zero exit statuses
    exec_start "-/usr/lib/git-core/git-daemon --inetd --syslog --verbose --base-path=#{node['git-daemon']['path']}"
  end
  # WARNING: disabled during tests because of systemd in Docker
  not_if { node['virtualization']['system'] == 'docker' }
end
