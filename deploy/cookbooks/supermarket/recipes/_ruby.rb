Chef::Resource.send(:include, Chef::Mixin::ShellOut)

source_url = node['supermarket']['ruby']['source_url']
src_dir    = node['supermarket']['ruby']['src_dir']
version    = node['supermarket']['ruby']['version']
prefix     = node['supermarket']['ruby']['prefix']

%w[build-essential zlib1g-dev libssl-dev libreadline6-dev libyaml-dev].each do |name|
  package name do
    action :install
  end
end

directory src_dir do
  action :create
end

remote_file "#{src_dir}/ruby-#{version}.tar.gz" do
  source source_url
  not_if do
    File.exists?("#{prefix}/bin/ruby") &&
    shell_out("#{prefix}/bin/ruby --version").stdout.include?(version.gsub('-', ''))
  end
  notifies :run, "execute[untar-ruby-#{version}]", :immediately
end

execute "untar-ruby-#{version}" do
  command "tar -xvzf ruby-#{version}.tar.gz"
  cwd src_dir
  notifies :run, "execute[compile-ruby-#{version}]", :immediately
  action :nothing
end

execute "compile-ruby-#{version}" do
  command "./configure --prefix=#{prefix} && make && make install"
  cwd "#{src_dir}/ruby-#{version}"
  notifies :reload, 'ohai[reload_ruby]', :immediately
  action :nothing
end

ohai 'reload_ruby' do
  plugin 'ruby'
  action :nothing
end

gem_package 'bundler' do
  action :install
end
