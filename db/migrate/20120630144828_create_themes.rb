class CreateThemes < ActiveRecord::Migration
  def change
    create_table :themes do |t|
      t.integer :user_id
      t.integer :company_id
      t.string :theme_name

      t.timestamps
    end
  end
end
