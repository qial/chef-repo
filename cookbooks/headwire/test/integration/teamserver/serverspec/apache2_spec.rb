require 'serverspec'

include Serverspec::Helper::Exec
include Serverspec::Helper::DetectOS

RSpec.configure do |c|
  c.before :all do
    c.path = '/sbin:/usr/sbin'
  end
end

describe "Apache2 web server" do

  it "is listening on port 80" do
    expect(port(80)).to be_listening
  end

  it "has a running service of apache2" do
    expect(service("apache2")).to be_running
  end

end


