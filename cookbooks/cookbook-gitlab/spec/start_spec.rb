require 'spec_helper'

describe "gitlab::start" do
  let(:chef_run) { ChefSpec::Runner.new.converge("gitlab::start") }


  describe "under ubuntu" do
    ["12.04", "10.04"].each do |version|
      let(:chef_run) do 
        runner = ChefSpec::Runner.new(platform: "ubuntu", version: version)
        runner.node.set['gitlab']['env'] = "production"
        runner.converge("gitlab::start")
      end

      it 'enables gitlab service' do
        expect(chef_run).to enable_service('gitlab')
      end

      # For current version of chefspec(3.0.1) there are no subscription tests
      it 'does not run gitlab service unless subscribed' do
        expect(chef_run).not_to start_service('gitlab')
      end
    end
  end

  describe "under centos" do
    ["5.8", "6.4"].each do |version|
      let(:chef_run) do 
        runner = ChefSpec::Runner.new(platform: "centos", version: version)
        runner.node.set['gitlab']['env'] = "production"
        runner.converge("gitlab::start")
      end

      it 'enables gitlab service' do
        expect(chef_run).to enable_service('gitlab')
      end

      # For current version of chefspec(3.0.1) there are no subscription tests
      it 'does not run gitlab service unless subscribed' do
        expect(chef_run).not_to start_service('gitlab')
      end
    end
  end
end
