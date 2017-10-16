class AddTagsToAffiliates < ActiveRecord::Migration[5.0]
  def change
    add_column :affiliates, :tags, :string
  end
end
