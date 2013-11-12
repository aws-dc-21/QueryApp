class CreateSavedQueries < ActiveRecord::Migration
  def change
    create_table :saved_queries do |t|
      t.string :name
      t.string :description
      t.text :sql

      t.timestamps
    end
  end
end
