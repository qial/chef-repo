
default[:logstash][:dir]       = "/etc/logstash"
default[:logstash][:data_dir]  = "/var/lib/logstash"
default[:logstash][:log_dir]   = "/var/log/logstash"
# one of: debug, verbose, notice, warning
default[:logstash][:loglevel]  = "notice"
default[:logstash][:user]      = "logstash"
default[:logstash][:port]      = 6379
default[:logstash][:bind]      = "127.0.0.1"

#default[:nexus][:url] = "http://www.sonatype.org/downloads/nexus-latest-bundle.tar.gz"
default[:nexus][:version] = "2.8.0-05"
default[:nexus][:url] = "http://download.sonatype.com/nexus/oss/nexus-#{node[:nexus][:version]}.war"
default[:nexus][:checksum] = "e1cece1ae5eb3a12f857e2368a3e9dbc"

default[:jenkins][:url] = "http://mirrors.jenkins-ci.org/war/latest/jenkins.war"
# default[:jenkins][:checksum] = no checksum right now
