class AddInstallPreferenceToUser < ActiveRecord::Migration
  def change
    add_column :users, :install_preference, :string, default: nil
  end
end
