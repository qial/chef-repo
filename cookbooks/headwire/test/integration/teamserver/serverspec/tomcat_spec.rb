require 'serverspec'

include Serverspec::Helper::Exec
include Serverspec::Helper::DetectOS

RSpec.configure do |c|
  c.before :all do
    c.path = '/sbin:/usr/sbin'
  end
end

describe "Tomcat server" do

  it "is listening on port 8080" do
    expect(port(8080)).to be_listening
  end

# Not sure how to test if tomcat is running
#  it "has a running service of tomcat" do
#    expect(service("apache2")).to be_running
#  end

end




