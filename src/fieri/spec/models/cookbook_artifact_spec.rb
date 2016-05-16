require 'rails_helper'

describe CookbookArtifact do
  let(:artifact) { CookbookArtifact.new("http://example.com/apache.tar.gz", "somejobid") }

  describe "when checking cookbooks that have metadata.rb" do
    before do
      stub_request(:get, "http://example.com/apache.tar.gz").
        to_return(
          :body => File.open(File.expand_path("./spec/fixtures/apache.tar.gz")),
          :status => 200
      )
    end

    describe "#initalize" do
      it "assigns #url" do
        assert_equal "http://example.com/apache.tar.gz", artifact.url
      end

      it "assigns #archive" do
        assert artifact.archive.is_a?(Tempfile)
      end

      it "assigns #directory" do
        assert_equal File.expand_path("/tmp/cook/somejobid/apache2"), artifact.directory
      end
    end

    describe "#criticize" do
      it "it returns the feedback and status from the FoodCritic run" do
        feedback, status = artifact.criticize

        assert_match(/FC023/, feedback)
        assert_equal true, status
      end
    end

    describe "#clean" do
      it "deletes the artifacts unarchived directory" do
        artifact.cleanup
        assert !Dir.exist?("/tmp/cook/#{artifact.job_id}")
      end
    end
  end

  describe "when checking a cookbook that does not have metadata.rb" do
    let(:artifact) { CookbookArtifact.new("http://example.com/apache.tar.gz", "somejobid2") }

    before do
      stub_request(:get, "http://example.com/apache.tar.gz").
        to_return(
          :body => File.open(File.expand_path("./spec/fixtures/apache-no-metadata.rb.tar.gz")),
          :status => 200
      )
    end

    describe "#criticize" do
      it "disables ~FC031 and ~FC045 by default" do
        feedback, _status = artifact.criticize
        refute_match(/FC031/, feedback)
        refute_match(/FC045/, feedback)
      end
    end
  end
end
