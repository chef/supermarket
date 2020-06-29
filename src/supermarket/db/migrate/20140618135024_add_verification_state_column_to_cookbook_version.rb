class AddVerificationStateColumnToCookbookVersion < ActiveRecord::Migration[4.2]
  def change
    add_column :cookbook_versions, :verification_state, :string, null: false, default: 'pending'
    add_index :cookbook_versions, :verification_state
  end
end
