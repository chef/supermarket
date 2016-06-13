require 'rails_helper'

describe CollaboratorWorker do
  before do
  end

  it 'calls Supermarket API for collaborator count' do
  end

  it 'checks whether coookbook version passes collaborator metrics' do
    cw = CollaboratorWorker.new()
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
