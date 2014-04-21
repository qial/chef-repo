default[:logstash][:dir]       = "/etc/logstash"
default[:logstash][:data_dir]  = "/var/lib/logstash"
default[:logstash][:log_dir]   = "/var/log/logstash"
# one of: debug, verbose, notice, warning
default[:logstash][:loglevel]  = "notice"
default[:logstash][:user]      = "logstash"
default[:logstash][:port]      = 6379
default[:logstash][:bind]      = "127.0.0.1"

