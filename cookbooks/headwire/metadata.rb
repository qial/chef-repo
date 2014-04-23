name             "headwire"
maintainer       "headwire.com, Inc."
maintainer_email "kw@headwire.com"
license          "Apache 2.0"
description      "Installs/Configures headwire"

version          "0.1.0"

###
# Dependencies
###

# Base unix dependencies
#depends "users"
#depends "sudo"
depends "apt"
depends "nano"
depends "git"
depends "vim"

# server dependencies
depends "redis"
depends "logstash"
depends "apache2"
depends "gitlab"


# Transitive dependencies we shouldn't have to put here but do
#ifail
#depends "metachef"
