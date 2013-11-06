require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the IclaSignaturesHelper. For example:
#
# describe IclaSignaturesHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
describe IclaSignaturesHelper do
  describe '#markdown' do
    it 'renders markdown' do
      expect(helper.markdown('# Test')).to eq("<h1>Test</h1>\n")
    end
  end
end
