class AddAffiliateToStudent < ActiveRecord::Migration[5.0]
  def change
    add_column :students, :affiliate, :integer
  end
end
