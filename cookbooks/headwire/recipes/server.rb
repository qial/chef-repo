include_recipe "headwire"
#include_recipe "runit"

package "git-daemon-run"

# I can't get the runit plugin working right
#runit_service "git-daemon" do
#  sv_templates false
#end

