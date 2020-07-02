class AddInstallPreferenceToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :install_preference, :string, default: nil
  end
end
