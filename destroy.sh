#!/bin/bash
########################################################
# Script to kill vagrant instance and remove related   #
# pieces from the chef master server.                  #
########################################################

# kill vagrant
vagrant destroy --force

# cleanup chef
knife client delete vagrant-kw --yes
knife node delete vagrant-kw --yes

# Done!
echo "Vagrant destroyed."
