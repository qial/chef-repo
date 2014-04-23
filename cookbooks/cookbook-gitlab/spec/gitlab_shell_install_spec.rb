require 'spec_helper'

describe "gitlab::gitlab_shell_install" do
  let(:chef_run) { ChefSpec::Runner.new.converge("gitlab::gitlab_shell_install") }


  describe "under ubuntu" do
    ["12.04", "10.04"].each do |version|
      let(:chef_run) do 
        runner = ChefSpec::Runner.new(platform: "ubuntu", version: version)
        runner.node.set['gitlab']['env'] = "production"
        runner.converge("gitlab::gitlab_shell_install")
      end

      it 'creates a gitlab shell config' do
        expect(chef_run).to create_template('/home/git/gitlab-shell/config.yml').with(
          source: 'gitlab_shell.yml.erb',
          variables: {
            user: "git",
            home: "/home/git",
            url: "http://localhost:80/",
            repos_path: "/home/git/repositories",
            redis_path: "/usr/local/bin/redis-cli",
            redis_host: "127.0.0.1",
            redis_port: "6379",
            namespace: "resque:gitlab",
            self_signed_cert: false
          }
        )
      end

      it 'creates repository directory in the gitlab user home directory' do
        expect(chef_run).to create_directory("/home/git/repositories").with(
          user: 'git',
          group: 'git',
          mode: 02770
        )
      end

      it 'creates .ssh directory in the gitlab user home directory' do
        expect(chef_run).to create_directory("/home/git/.ssh").with(
          user: 'git',
          group: 'git',
          mode: 0700
        )
      end

      it 'creates authorized hosts file in .ssh directory' do
        expect(chef_run).to create_file_if_missing("/home/git/.ssh/authorized_keys").with(
          user: 'git',
          group: 'git',
          mode: 0600
        )
      end

      it 'does not run a execute to install gitlab shell on its own' do
        expect(chef_run).to_not run_execute('gitlab-shell install')
      end
    end
  end

  describe "under centos" do
    ["5.8", "6.4"].each do |version|
      let(:chef_run) do 
        runner = ChefSpec::Runner.new(platform: "centos", version: version)
        runner.node.set['gitlab']['env'] = "production"
        runner.converge("gitlab::gitlab_shell_install")
      end

      it 'creates a gitlab shell config' do
        expect(chef_run).to create_template('/home/git/gitlab-shell/config.yml').with(
          source: 'gitlab_shell.yml.erb',
          variables: {
            user: "git",
            home: "/home/git",
            url: "http://localhost:80/",
            repos_path: "/home/git/repositories",
            redis_path: "/usr/local/bin/redis-cli",
            redis_host: "127.0.0.1",
            redis_port: "6379",
            namespace: "resque:gitlab",
            self_signed_cert: false
          }
        )
      end

      it 'creates repository directory in the gitlab user home directory' do
        expect(chef_run).to create_directory("/home/git/repositories").with(
          user: 'git',
          group: 'git',
          mode: 02770
        )
      end

      it 'creates .ssh directory in the gitlab user home directory' do
        expect(chef_run).to create_directory("/home/git/.ssh").with(
          user: 'git',
          group: 'git',
          mode: 0700
        )
      end

      it 'creates authorized hosts file in .ssh directory' do
        expect(chef_run).to create_file_if_missing("/home/git/.ssh/authorized_keys").with(
          user: 'git',
          group: 'git',
          mode: 0600
        )
      end

      it 'does not run a execute to install gitlab shell on its own' do
        expect(chef_run).to_not run_execute('gitlab-shell install')
      end
    end
  end
end
