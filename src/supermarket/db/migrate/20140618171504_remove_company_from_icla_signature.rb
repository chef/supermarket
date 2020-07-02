class RemoveCompanyFromIclaSignature < ActiveRecord::Migration[4.2]
  def change
    remove_column :icla_signatures, :company, :string
  end
end
