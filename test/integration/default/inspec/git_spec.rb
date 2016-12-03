control 'git-1' do
  title 'Git Setup'
  desc '
    Check that git is installed and running
  '

  describe directory('/var/cache/git') do
    it { should exist }
  end

  [9418].each do |listen_port|
    describe port(listen_port) do
      # systemd setup not working in docker
      let(:node) { json('/tmp/kitchen/chef_node.json').params }
      before do
        skip if node['automatic']['virtualization']['system'] == 'docker'
      end

      it { should be_listening }
      its('protocols') { should include 'tcp6'}
    end
  end

  # can clone a repository
  describe command("git clone git://localhost/ /tmp/git-daemon_test-clone-$(date +%s)/") do
    # systemd setup not working in docker
    let(:node) { json('/tmp/kitchen/chef_node.json').params }
    before do
      skip if node['automatic']['virtualization']['system'] == 'docker'
    end

    its('exit_status') { should eq 0 }
  end

end