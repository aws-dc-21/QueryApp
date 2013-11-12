class CreateRunQueries < ActiveRecord::Migration
  def change
    create_table :run_queries do |t|
      t.text :sql

      t.timestamps
    end
  end
end
