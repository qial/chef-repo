name             "headwire"
maintainer       "headwire.com, Inc."
maintainer_email "kw@headwire.com"
license          "Apache 2.0"
description      "Installs/Configures headwire"

version          "0.1.0"

# Dependencies
#depends "runit", "~> 1.4.0"
depends "redis"
depends "logstash"
depends "nano"
depends "git"

# Transitive dependencies we shouldn't have to put here but do
#ifail
#depends "metachef"
