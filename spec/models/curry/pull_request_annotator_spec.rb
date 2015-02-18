require 'spec_helper'
require 'vcr_helper'

describe Curry::PullRequestAnnotator, uses_secrets: true do
  describe '#annotate' do
    let(:octokit) do
      Octokit::Client.new(
        access_token: ENV['GITHUB_ACCESS_TOKEN']
      )
    end

    let(:repository) do
      create(:repository, owner: 'chef', name: 'paprika')
    end

    let(:pull_request) do
      Curry::PullRequest.create!(
        number: '1',
        repository: repository
      )
    end

    before do
      VCR.use_cassette('pull_request_annotation_setup', record: :once) do
        octokit.remove_all_labels(
          repository.full_name,
          pull_request.number
        )

        issue_comments = octokit.issue_comments(
          repository.full_name,
          pull_request.number
        )

        issue_comments.each do |comment|
          octokit.delete_comment(
            repository.full_name,
            comment.id
          )
        end
      end
    end

    it 'adds a comment to the Pull Request when not all commit authors have signed a CLA' do
      VCR.use_cassette('pull_request_annotation_adds_comment', record: :once) do
        pull_request.commit_authors.create!(login: 'brettchalupa')
        pull_request.commit_authors.create!(
          email: 'brian+bcobb+brettchalupa@gofullstack.com'
        )

        annotator = Curry::PullRequestAnnotator.new(pull_request)

        annotator.annotate

        comments = octokit.issue_comments(
          repository.full_name,
          pull_request.number
        )

        expect(comments.map(&:body)).to_not be_empty
      end
    end

    it 'records the act of leaving a comment' do
      VCR.use_cassette('pull_request_annotation_adds_comment', record: :once) do
        pull_request.commit_authors.create!(login: 'brettchalupa')
        pull_request.commit_authors.create!(
          email: 'brian+bcobb+brettchalupa@gofullstack.com'
        )

        annotator = Curry::PullRequestAnnotator.new(pull_request)

        annotator.annotate

        comments = octokit.issue_comments(
          repository.full_name,
          pull_request.number
        )

        comment_id = comments.first.id

        expect(pull_request.comments.with_github_id(comment_id).count).to eql(1)
      end
    end

    it 'records the set of unauthorized commit authors along with the comment' do
      VCR.use_cassette('pull_request_annotation_adds_comment', record: :once) do
        pull_request.commit_authors.create!(login: 'brettchalupa')
        pull_request.commit_authors.create!(
          email: 'brian+bcobb+brettchalupa@gofullstack.com'
        )

        annotator = Curry::PullRequestAnnotator.new(pull_request)

        annotator.annotate

        comments = octokit.issue_comments(
          repository.full_name,
          pull_request.number
        )

        comment = pull_request.comments.with_github_id(comments.first.id).first!

        expect(comment.mentioned_commit_authors).
          to eql(Set.new(['brettchalupa', 'brian+bcobb+brettchalupa@gofullstack.com']))
      end
    end

    it 'does not leave a new comment if the unauthorized commit authors have not changed' do
      VCR.use_cassette('pull_request_annotation_updates_comment', record: :once) do
        pull_request.commit_authors.create!(login: 'brettchalupa')
        pull_request.commit_authors.create!(
          email: 'brian+bcobb+brettchalupa@gofullstack.com'
        )

        annotator = Curry::PullRequestAnnotator.new(pull_request)

        2.times { annotator.annotate }

        comments = octokit.issue_comments(
          repository.full_name,
          pull_request.number
        )

        expect(comments.count).to eql(1)
      end
    end

    it "updates the previous comment's updated_at timestamp instead of leaving a duplicate comment" do
      VCR.use_cassette('pull_request_annotation_updates_comment', record: :once) do
        pull_request.commit_authors.create!(login: 'brettchalupa')
        pull_request.commit_authors.create!(
          email: 'brian+bcobb+brettchalupa@gofullstack.com'
        )

        annotator = Curry::PullRequestAnnotator.new(pull_request)
        annotator.annotate

        expect do
          annotator.annotate
        end.to change { pull_request.reload.comments.last.updated_at }
      end
    end

    context 'when all commit authors are authorized' do
      it 'leaves a label and a comment when a PR transitions from unauthorized to authorized' do
        VCR.use_cassette('pull_request_annotation_when_authors_become_authorized', record: :once) do
          brett = pull_request.commit_authors.create!(login: 'brettchalupa')

          annotator = Curry::PullRequestAnnotator.new(pull_request)
          annotator.annotate

          brett.sign_cla!

          annotator.annotate

          comments = octokit.issue_comments(
            repository.full_name,
            pull_request.number
          )
          labels = octokit.labels_for_issue(
            repository.full_name,
            pull_request.number
          )

          success_comment = %(
            I have added the "#{ENV['CURRY_SUCCESS_LABEL']}"
            label to this issue so it can easily be found in the future.
          ).squish

          expect(comments.last.body).to include(success_comment)
          expect(labels.map(&:name)).to include(ENV['CURRY_SUCCESS_LABEL'])
        end
      end

      it 'just adds the label when a PR is opened by authorized contributors' do
        VCR.use_cassette('pull_request_annotation_authorized_from_start', record: :once) do
          brett = pull_request.commit_authors.create!(login: 'brettchalupa')
          brett.sign_cla!

          annotator = Curry::PullRequestAnnotator.new(pull_request)
          annotator.annotate

          comments = octokit.issue_comments(
            repository.full_name,
            pull_request.number
          )
          labels = octokit.labels_for_issue(
            repository.full_name,
            pull_request.number
          )

          expect(comments).to be_empty
          expect(labels.map(&:name)).to include(ENV['CURRY_SUCCESS_LABEL'])
        end
      end

      it 'records the act of leaving a success comment' do
        VCR.use_cassette('pull_request_annotation_when_authors_become_authorized', record: :once) do
          brett = pull_request.commit_authors.create!(login: 'brettchalupa')

          annotator = Curry::PullRequestAnnotator.new(pull_request)
          annotator.annotate

          brett.sign_cla!

          annotator.annotate

          comments = octokit.issue_comments(
            repository.full_name,
            pull_request.number
          )

          expect(pull_request.comments.with_github_id(comments.last.id)).
            to_not be_empty
        end
      end

      it 'does not leave a success comment twice' do
        VCR.use_cassette('pull_request_annotation_no_double_comment', record: :once) do
          brett = pull_request.commit_authors.create!(login: 'brettchalupa')

          annotator = Curry::PullRequestAnnotator.new(pull_request)
          annotator.annotate

          brett.sign_cla!

          2.times { annotator.annotate }

          comments = octokit.issue_comments(
            repository.full_name,
            pull_request.number
          )

          expect(comments.count).to eql(2)
        end
      end

      it 'leaves two success comments if the authorization status fluctuates' do
        VCR.use_cassette('pull_request_annotation_leaves_two_success_comments', record: :once) do
          brett = pull_request.commit_authors.create!(login: 'brettchalupa')

          annotator = Curry::PullRequestAnnotator.new(pull_request)
          annotator.annotate

          brett.sign_cla!

          annotator.annotate

          brian = pull_request.commit_authors.create!(login: 'bcobb')

          annotator.annotate

          brian.sign_cla!

          annotator.annotate

          comments = octokit.issue_comments(
            repository.full_name,
            pull_request.number
          )

          success_comment = %(
            I have added the "#{ENV['CURRY_SUCCESS_LABEL']}"
            label to this issue so it can easily be found in the future.
          ).squish

          success_comments = comments.select do |comment|
            comment.body.include?(success_comment)
          end

          expect(success_comments.count).to eql(2)
        end
      end
    end

    it 'removes the label before adding a comment' do
      VCR.use_cassette('pull_request_annotation_removes_label', record: :once) do
        octokit.add_labels_to_an_issue(
          repository.full_name,
          pull_request.number,
          [ENV['CURRY_SUCCESS_LABEL']]
        )

        pull_request.commit_authors.create!(login: 'brettchalupa')

        annotator = Curry::PullRequestAnnotator.new(pull_request)

        annotator.annotate

        labels = octokit.labels_for_issue(
          repository.full_name,
          pull_request.number
        )

        label_text = ENV['CURRY_SUCCESS_LABEL']

        expect(labels.map(&:name)).to_not include(label_text)
      end
    end
  end
end
