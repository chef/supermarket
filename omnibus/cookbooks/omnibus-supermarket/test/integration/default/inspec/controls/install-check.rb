require 'json'
property = json('/etc/supermarket/supermarket-running.json')

control "supermarket-ctl-perms" do
  title "Check that the -ctl commands error correctly"
  # run as someone other that the supermarket OS user
  describe command("supermarket-ctl console") do
    its(:stderr) { should match /supermarket-ctl console should be run as the supermarket OS user./ }
  end

  # run as someone other that the supermarket OS user
  describe command("supermarket-ctl make-admin") do
    its(:stderr) { should match /supermarket-ctl make-admin should be run as the supermarket OS user./ }
  end

  # run as supermarket user, but with a user that doesn't exist
  describe command("sudo -u supermarket supermarket-ctl make-admin user=nope") do
    its(:stdout) { should match /nope was not found in Supermarket./ }
  end
end

control "ssl-config" do
  title "Configurations for SSL"

  only_if { property['supermarket']['ssl']['enabled'] }

  describe file('/var/opt/supermarket/ssl/ca/dhparams.pem') do
    it { should be_file }
    its(:content) { should match /BEGIN DH PARAMETERS/}
  end

  describe file('/var/opt/supermarket/nginx/etc/sites-enabled/rails') do
    its(:content) { should match /ssl_dhparam/ }
 end
end

control "log-management" do
  title "Manage The Logs"

  describe file(property['supermarket']['var_directory'] + '/etc/logrotate.d') do
    it { should be_directory }
  end

  describe file(property['supermarket']['var_directory'] + '/etc/logrotate.conf') do
    it { should be_file }
    its(:content) { should match /#{'include ' + property['supermarket']['var_directory'] + '/etc/logrotate.d'}/ }
  end

  describe file('/etc/cron.hourly/supermarket_logrotate') do
    it { should be_file }
    its(:content) { should match /#{'logrotate /var/opt/supermarket/etc/logrotate.conf'}/ }
  end

  describe file(property['supermarket']['var_directory'] + '/etc/logrotate.d/nginx') do
    it { should be_file }
    its(:content) { should match /#{property['supermarket']['nginx']['log_directory'] + '/\*.log'}/}
  end
end

control "proxy" do
  title "Reverse Proxy"
  only_if { property['supermarket']['nginx']['enable'] }

  describe port(property['supermarket']['nginx']['non_ssl_port']) do
    it { should be_listening }
    its('protocols') { should include 'tcp' }
  end

  if property['supermarket']['ssl']['enabled'] && property['supermarket']['nginx']['force_ssl']
    describe port(property['supermarket']['nginx']['ssl_port']) do
      it { should be_listening }
      its('protocols') { should include 'tcp' }
    end
  end
end

control "database" do
  title "Database"
  only_if { property['supermarket']['postgresql']['enable'] }

  describe port(property['supermarket']['postgresql']['port']) do
    it { should be_listening }
    its('protocols') { should include 'tcp' }
  end
end

control "cache-dirs" do
  title "Happy cache directories"

  describe file(property['supermarket']['var_directory'] + '/cache') do
    it { should be_directory }
  end

  describe file(property['supermarket']['install_directory'] + '/embedded/cookbooks/local-mode-cache') do
    it { should_not exist }
  end
end

control "redis" do
  title "Redis"
  only_if { property['supermarket']['redis']['enable'] }

  describe port(property['supermarket']['redis']['port']) do
    it { should be_listening }
    its('protocols') { should include 'tcp' }
  end
end

control "web-app" do
  title "Web App"
  only_if { property['supermarket']['rails']['enable'] }
  describe port(property['supermarket']['rails']['port']) do
    it { should be_listening }
    its('protocols') { should include 'tcp' }
  end
end
