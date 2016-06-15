require 'rails_helper'

describe CollaboratorWorker do
  let(:cw) { CollaboratorWorker.new() }
  let(:cookbook_name) { "greatcookbook" }
  let(:json_response) { File.read("spec/support/cookbook_metrics_fixture.json") }
  let(:uri) { "https://supermarket.chef.io/api/v1/cookbooks/#{cookbook_name}" }

  before do
    stub_request(:get, "https://supermarket.chef.io/api/v1/cookbooks/greatcookbook").
      to_return(:status => 200, :body => json_response, :headers => {})
  end

  it 'calls Supermarket API for collaborator count' do
    expect(Net::HTTP).to receive(:get).with(URI(uri)).and_return(json_response)
    cw.get_json(cookbook_name)
  end

  it 'parses the json response from supermarket to find collaborators' do
    allow_any_instance_of(CollaboratorWorker).to receive(:get_json).and_return(json_response)
    expect(cw.get_collaborator_count(json_response)).to eq 2
  end

  it 'checks whether coookbook version passes collaborator metrics' do
    expect(cw.sufficient_collaborators?(2)).to eql(true)
    expect(cw.sufficient_collaborators?(1)).to eql(false)
  end

  it 'sends a post request to the results endpoint' do
    stub_request(:post, "http://supermarket.getchef.com/api/v1/cookbook-versions/evaluation").
         to_return(:status => 200, :body => json_response, :headers => {})

    CollaboratorWorker.new.perform(
      'cookbook_name' => cookbook_name,
    )

    assert_requested(:post, "http://supermarket.getchef.com/api/v1/cookbook-versions/evaluation", times: 1) do |req|
      req.body =~ /collaborator_feedback=true/
    end
  end

  # it 'creates a unique directory for each job to work within' do
  #   Sidekiq::Testing.inline! do
  #     job_id_1 = CollaboratorWorker.perform_async(
  #       'cookbook_artifact_url' => 'http://example.com/apache.tar.gz',
  #       'cookbook_name' => 'apache2',
  #       'cookbook_version' => '1.2.0'
  #     )

  #     job_id_2 = CollaboratorWorker.perform_async(
  #       'cookbook_artifact_url' => 'http://example.com/apache.tar.gz',
  #       'cookbook_name' => 'apache2',
  #       'cookbook_version' => '1.2.0'
  #     )

  #     assert Dir.exist?(File.join(Dir.tmpdir, job_id_1))
  #     assert Dir.exist?(File.join(Dir.tmpdir, job_id_2))
  #   end
  # end
end
