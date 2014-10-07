#describe 'supermarket::ssl' do
  #let(:chef_run) do
    #ChefSpec::Runner.new do |node|
      #node.automatic['memory']['total'] = '16000MB'
    #end.converge(described_recipe)
  #end

  #it 'creates /var/opt/supermarket/ssl' do
    #expect(chef_run).to create_directory('/var/opt/supermarket/ssl').with(
      #user: 'supermarket',
      #group: 'supermarket',
      #mode: '0700',
    #)
  #end

  #it 'creates /var/opt/supermarket/ssl/ca' do
    #expect(chef_run).to create_directory('/var/opt/supermarket/ssl/ca').with(
      #user: 'supermarket',
      #group: 'supermarket',
      #mode: '0700',
    #)
  #end

  #context 'when an ssl certificate is not defined' do
    #it 'creates /var/opt/supermarket/ssl/ca/fqdn.key' do
      #expect(chef_run).to create_file_if_missing(
        #'/var/opt/supermarket/ssl/ca/fqdn.key'
      #).with(
        #owner: 'root',
        #group: 'root',
        #mode: '0640',
      #)
    #end

    #it 'creates /var/opt/supermarket/ssl/ca/fqdn-ssl.conf' do
      #expect(chef_run).to create_template_if_missing(
        #'/var/opt/supermarket/ssl/ca/fqdn-ssl.conf'
      #).with(
        #source: 'ssl-signing.conf',
        #owner: 'root',
        #group: 'root',
        #mode: '0644',
      #)
    #end
  #end

  #context 'when an ssl certificate is defined' do
    #before :each do
      #chef_run.node.set['supermarket']['ssl']['certificate'] = '/etc/mycert.pem'
      #chef_run.converge(described_recipe)
    #end

    #it 'links the CA cert' do
      #expect(chef_run).to create_link(
        #'/var/opt/supermarket/ssl/cacert.pem'
      #).with(
        #to: '/opt/supermarket/embedded/ssl/certs/cacert.pem'
      #)
    #end
  #end
#end
