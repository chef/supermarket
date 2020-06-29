class AddProviderToAccounts < ActiveRecord::Migration[4.2]
  def change
    add_column :accounts, :provider, :string, index: true
  end
end
