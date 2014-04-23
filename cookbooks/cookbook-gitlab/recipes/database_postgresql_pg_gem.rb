#
# Cookbook Name:: gitlab
# Recipe:: database_postgresql_pg_gem
#

begin
  chef_gem "pg"
rescue Gem::Installer::ExtensionBuildError => e
  # Are we an omnibus install?
  raise if RbConfig.ruby.scan(%r{(chef|opscode)}).empty?
  # Still here, must be omnibus. Lets make this thing install!
  Chef::Log.warn 'Failed to properly build pg gem. Forcing properly linking and retrying (omnibus fix)'
  gem_dir = e.message.scan(%r{will remain installed in ([^ ]+)}).flatten.first
  raise unless gem_dir
  gem_name = File.basename(gem_dir)
  ext_dir = File.join(gem_dir, 'ext')
  gem_exec = File.join(File.dirname(RbConfig.ruby), 'gem')
  new_content = <<-EOS
require 'rbconfig'
%w(
configure_args
LIBRUBYARG_SHARED
LIBRUBYARG_STATIC
LIBRUBYARG
LDFLAGS
).each do |key|
RbConfig::CONFIG[key].gsub!(/-Wl[^ ]+( ?\\/[^ ]+)?/, '')
RbConfig::MAKEFILE_CONFIG[key].gsub!(/-Wl[^ ]+( ?\\/[^ ]+)?/, '')
end
RbConfig::CONFIG['RPATHFLAG'] = ''
RbConfig::MAKEFILE_CONFIG['RPATHFLAG'] = ''
EOS
  new_content << File.read(extconf_path = File.join(ext_dir, 'extconf.rb'))
  File.open(extconf_path, 'w') do |file|
    file.write(new_content)
  end

  lib_builder = execute 'generate pg gem Makefile' do
    # [COOK-3490] pg gem install requires full path on RHEL
    if node['platform_family'] == 'rhel'
      command "#{RbConfig.ruby} extconf.rb --with-pg-config=/usr/pgsql-#{node['postgresql']['version']}/bin/pg_config"
    else
      command "#{RbConfig.ruby} extconf.rb"
    end
    cwd ext_dir
    action :nothing
  end
  lib_builder.run_action(:run)

  lib_maker = execute 'make pg gem lib' do
    command 'make'
    cwd ext_dir
    action :nothing
  end
  lib_maker.run_action(:run)

  lib_installer = execute 'install pg gem lib' do
    command 'make install'
    cwd ext_dir
    action :nothing
  end
  lib_installer.run_action(:run)

  spec_installer = execute 'install pg spec' do
    command "#{gem_exec} spec ./cache/#{gem_name}.gem --ruby > ./specifications/#{gem_name}.gemspec"
    cwd File.join(gem_dir, '..', '..')
    action :nothing
  end
  spec_installer.run_action(:run)

  Chef::Log.warn 'Installation of pg gem successful!'
end
