#!/bin/sh

if cat /etc/ssh/sshd_config | grep --quiet "StrictModes yes"; then
  sed -i 's!StrictModes yes!StrictModes no!g' /etc/ssh/sshd_config
  service ssh restart
fi
