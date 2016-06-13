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
    json_response = '{
            "name": "apache2",
            "maintainer": "johndoe",
            "description": "Repudiandae et rerum eligendi sequi accusantium pariatur.",
            "category": "Other",
            "latest_version": "http://localhost:3000/api/v1/cookbooks/apache2/versions/0.2.0",
            "external_url": "http://example.com",
            "source_url": "http://example.com",
            "issues_url": "http://example.com",
            "average_rating": null,
            "created_at": "2016-05-23T21:29:10.855Z",
            "updated_at": "2016-05-23T21:29:10.855Z",
            "up_for_adoption": null,
            "deprecated": false,
            "foodcritic_failure": null,
            "versions": [
            "http://localhost:3000/api/v1/cookbooks/apache2/versions/0.2.0",
            "http://localhost:3000/api/v1/cookbooks/apache2/versions/0.1.0"
            ],
            "metrics": {
            "downloads": {
            "total": 0,
            "versions": {
            "0.1.0": 0,
            "0.2.0": 0
            }
            },
            "followers": 0,
            "collaborators": 2
            }
            }'

    allow(Net::HTTP).to receive(:post_form).and_return(json_response)
    expect(cw.get_collaborator_count(json_response)).to eq 2
  end

  it 'checks whether coookbook version passes collaborator metrics' do
    expect(cw.sufficient_collaborators?(2)).to eql(true)
    expect(cw.sufficient_collaborators?(1)).to eql(false)
  end

  # it 'sends a post request to the results endpoint' do
  #   FoodcriticWorker.new.perform(
  #     'cookbook_artifact_url' => 'http://example.com/apache.tar.gz',
  #     'cookbook_name' => 'apache2',
  #     'cookbook_version' => '1.2.0'
  #   )

  #   assert_requested(:post, ENV['FIERI_RESULTS_ENDPOINT'], times: 1) do |req|
  #     req.body =~ /foodcritic_failure=true/
  #     req.body =~ /FC023/
  #   end
  # end

  # it 'creates a unique directory for each job to work within' do
  #   Sidekiq::Testing.inline! do
  #     job_id_1 = FoodcriticWorker.perform_async(
  #       'cookbook_artifact_url' => 'http://example.com/apache.tar.gz',
  #       'cookbook_name' => 'apache2',
  #       'cookbook_version' => '1.2.0'
  #     )

  #     job_id_2 = FoodcriticWorker.perform_async(
  #       'cookbook_artifact_url' => 'http://example.com/apache.tar.gz',
  #       'cookbook_name' => 'apache2',
  #       'cookbook_version' => '1.2.0'
  #     )

  #     assert Dir.exist?(File.join(Dir.tmpdir, job_id_1))
  #     assert Dir.exist?(File.join(Dir.tmpdir, job_id_2))
  #   end
end
