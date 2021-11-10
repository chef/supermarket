class AddDeprecationReasonToCookbooks < ActiveRecord::Migration[6.1]
  def change
    add_column :cookbooks, :deprecation_reason, :string
  end
end
