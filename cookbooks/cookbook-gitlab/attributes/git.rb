# Git
default['gitlab']['git']['prefix'] = "/usr/local"
default['gitlab']['git']['version'] = "1.8.5.2"
default['gitlab']['git']['url'] = "https://codeload.github.com/git/git/zip/v#{node['gitlab']['git']['version']}"

if platform_family?("rhel")
  packages = %w{expat-devel gettext-devel libcurl-devel openssl-devel perl-ExtUtils-MakeMaker zlib-devel}
else
  packages = %w{unzip build-essential libcurl4-openssl-dev libexpat1-dev gettext libz-dev libssl-dev}
end

default['gitlab']['git']['packages'] = packages
