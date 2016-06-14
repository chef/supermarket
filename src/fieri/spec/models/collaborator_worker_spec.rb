require 'rails_helper'

describe CollaboratorWorker do
  let(:cw) { CollaboratorWorker.new() }
  let(:cookbook_name) { "greatcookbook" }

  it 'calls Supermarket API for collaborator count' do
    uri = 'https://supermarket.chef.io/api/v1/cookbooks'
    expect(Net::HTTP).to receive(:post_form).with(uri, cookbook_name)
    cw.get_json(cookbook_name)
  end

  it 'parses the json response from supermarket to find collaborators' do
    json_response = File.read("spec/support/cookbook_metrics_fixture.json")

    allow(Net::HTTP).to receive(:post_form).and_return(json_response)
    expect(cw.get_collaborator_count(json_response)).to eq 2
  end

  it 'checks whether coookbook version passes collaborator metrics' do
    expect(cw.sufficient_collaborators?(2)).to eql(true)
    expect(cw.sufficient_collaborators?(1)).to eql(false)
  end
end
