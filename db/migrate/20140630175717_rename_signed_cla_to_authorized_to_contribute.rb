class RenameSignedClaToAuthorizedToContribute < ActiveRecord::Migration
  def change
    rename_column :curry_commit_authors, :signed_cla, :authorized_to_contribute
  end
end
