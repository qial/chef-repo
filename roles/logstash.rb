name "logstash"
description "Logstash central server"
all_env = [
  "role[base]",
  #"recipe[redis::install_from_release]",
  "recipe[redis::server]",
  "recipe[logstash::server]",
]

run_list(all_env)

env_run_lists(
  "_default" => all_env,
  "prod" => all_env,
  #"dev" => all_env + ["recipe[php:module_xdebug]"],
  "dev" => all_env,
)

