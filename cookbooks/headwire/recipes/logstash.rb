# derp

# base recipes
include_recipe "users::sysadmins"
include_recipe "sudo"
include_recipe "apt"
include_recipe "git"
include_recipe "build-essential"
include_recipe "vim"
include_recipe "nano"

# logstash specific
include_recipe "redis::server"
include_recipe "logstash::server"
