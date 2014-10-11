require_relative '../../libraries/supermarket'

describe Supermarket do
  describe 'parsed_database_url' do
    it 'parses a database url' do
      expect(described_class.parsed_database_url(
        'postgres://user:pass@host:1234/db'
      )).to eq(
        'production' => {
          'adapter' => 'postgresql',
          'database' => 'db',
          'username' => 'user',
          'password' => 'pass',
          'host' => 'host',
          'port' => 1234,
        }
      )
    end
  end
end
