# encoding: utf-8
# copyright: 2015, The Authors
# license: All rights reserved

describe command('berks install --berksfile={{pkg.svc_config_path}}/Berksfile') do
  its('exit_status') { should eq 0 }
  its('stdout') { should match /Installing {{cfg.i_know_this_cookbook_exists}}/}
end
