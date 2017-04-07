describe 'omnibus-supermarket::database' do
  before do
    stub_command("echo '\\dx' | psql supermarket | grep plpgsql").and_return('')
    stub_command("echo '\\dx' | psql supermarket | grep pg_trgm").and_return('')
  end

  let(:chef_run) do
    ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '16.04') do |node|
      node.automatic['memory']['total'] = '16000MB'
    end.converge(described_recipe)
  end

  
end
