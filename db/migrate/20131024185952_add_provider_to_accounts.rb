class AddProviderToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :provider, :string, index: true
  end
end
