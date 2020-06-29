class AddUniqueIndexToSystemEmailOnName < ActiveRecord::Migration[5.1]
  def change
    add_index :system_emails, :name, unique: true
  end
end
