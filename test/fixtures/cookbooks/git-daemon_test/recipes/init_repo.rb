execute "create bare repo" do
  command "git init --bare"
  cwd node['git-daemon']['path']
  user node['git-daemon']['user']
  not_if { File.directory?(File.join(node['git-daemon']['path'], "index")) }
end

file File.join(node['git-daemon']['path'], "git-daemon-export-ok") do
  content ''
  user node['git-daemon']['user']
end