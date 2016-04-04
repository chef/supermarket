class EmailsNeedNotBeUnique < ActiveRecord::Migration
  def change
    remove_index :users, :email
  end
end
