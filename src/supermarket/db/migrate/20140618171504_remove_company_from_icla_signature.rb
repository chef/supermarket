class RemoveCompanyFromIclaSignature < ActiveRecord::Migration
  def change
    remove_column :icla_signatures, :company, :string
  end
end
