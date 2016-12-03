# Export the node attributes so that we can access them later in the inspec
ruby_block "Save node attributes" do
  block do
    if Dir::exist?('/tmp/kitchen')
      IO.write("/tmp/kitchen/chef_node.json", node.to_json)
    end
  end
end