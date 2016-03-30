require_relative '../../libraries/config'

describe Supermarket::Config do
  describe 'environment_variables_from' do
    it 'creates environment varibles from attributes' do
      expect(described_class.environment_variables_from(
        'test1' => 123,
        'test2' => 'abc',
        'test3' => {},
        'test4' => [],
        'test5' => 'def',
        'test6' => true,
        'test7' => false,
        'test8' => nil,
      )).to eq(<<EOF
export TEST1="123"
export TEST2="abc"
export TEST5="def"
export TEST6="true"
export TEST7="false"
EOF
)
    end
  end
end
