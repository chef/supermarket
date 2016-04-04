class AddVerificationStateColumnToCookbookVersion < ActiveRecord::Migration
  def change
    add_column :cookbook_versions, :verification_state, :string, null: false, default: 'pending'
    add_index :cookbook_versions, :verification_state
  end
end
