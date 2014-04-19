#Vagrant::Config.run do |config|
#  config.vm.box = "trusty64"
#   config.vm.provision :chef_solo do |chef|
#     chef.cookbooks_path = "cookbooks"
#     chef.add_recipe "redis"
#     chef.log_level = :debug
#  end
#end

Vagrant::Config.run do |config|
  config.vm.box = "trusty64"
  config.vm.forward_port 80, 8080

  config.vm.customize [
    "modifyvm", :id,
    "--name", "TEST",
    "--memory", "512"
  ]

  config.vm.network :hostonly, "10.0.0.23"
  config.vm.host_name = "doku"
  config.vm.share_folder("vagrant-root", "/home/vagrant/apps", ".", :nfs => true)

  # Your organization name for hosted Chef
  #orgname = "CHANGE_THIS_TO_YOUR_HOSTED_CHEF_ORGNAME"

  # Set the Chef node ID based on environment variable NODE, if set. Otherwise default to vagrant-$USER
  node = ENV['NODE']
  node ||= "vagrant-#{ENV['USER']}"

  config.vm.provision :chef_client do |chef|
    chef.chef_server_url = "https://192.168.42.16"
    chef.validation_key_path = "#{ENV['HOME']}/dev/chef-repo/.chef/chef-validator.pem"
    chef.validation_client_name = "chef-validator"
    chef.encrypted_data_bag_secret_key_path = "#{ENV['HOME']}/dev/chef-repo/.chef/encrypted_data_bag_secret"
    chef.node_name = "#{node}"
    chef.provisioning_path = "/etc/chef"
    chef.log_level = :debug
    #chef.log_level = :info

    chef.environment = "dev"
    chef.add_role("base")
    #chef.add_role("db_master")
    chef.add_role("webserver")

    #chef.json.merge!({ :mysql_password => "foo" }) # You can do this to override any default attributes for this node.
  end
end
