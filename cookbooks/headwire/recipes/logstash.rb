# derp

# dependency fixes
#include_recipe "runit"

# base recipes
#include_recipe "users::sysadmins"
#include_recipe "sudo"
#include_recipe "apt"
include_recipe "git"
#include_recipe "build-essential"
#include_recipe "vim"
include_recipe "nano"

# logstash specific
include_recipe "redis::install_from_package"
#include_recipe "redis::server"
include_recipe "logstash::server"

#runit_service "redis" do
#  sv_templates false
#end

#runit_service "logstash" do
#  sv_templates false
#end
