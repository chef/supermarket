require 'rails_helper'

describe FoodcriticWorker do
  before do
    #
    # Stubs criticize for speed!
    #
    CookbookArtifact.any_instance.stub(:criticize)
                    .and_return('FC023', true)

    #
    # Stubs cleanup so we can test the creation of unique
    # directories.
    #
    CookbookArtifact.any_instance.stub(:cleanup)
                    .and_return(0)

    stub_request(:get, 'http://example.com/apache.tar.gz').
      to_return(
        body: File.open(File.expand_path('./spec/fixtures/apache.tar.gz')),
        status: 200
      )

    stub_request(:post, "#{ENV['FIERI_SUPERMARKET_ENDPOINT']}/api/v1/cookbook-versions/foodcritic_evaluation")
  end

  it 'sends a post request to the results endpoint' do
    FoodcriticWorker.new.perform(
      'cookbook_artifact_url' => 'http://example.com/apache.tar.gz',
      'cookbook_name' => 'apache2',
      'cookbook_version' => '1.2.0'
    )

    assert_requested(:post, "#{ENV['FIERI_SUPERMARKET_ENDPOINT']}/api/v1/cookbook-versions/foodcritic_evaluation", times: 1) do |req|
      req.body =~ /foodcritic_failure=true/
      req.body =~ /FC023/
    end
  end
end
