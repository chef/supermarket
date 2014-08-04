#
# Updates the +updated_at+ timestamp of the latest comment on a Pull Request
#
class Curry::UpdateUnauthorizedCommitAuthorComment
  #
  # Creates a new +Curry::UpdateUnauthorizedCommitAuthorComment+
  #
  # @param comment [Curry::PullRequestComment]
  #
  def initialize(comment)
    @comment = comment
  end

  #
  # Performs the action of updating the comment
  #
  def call
    @comment.touch
  end
end
