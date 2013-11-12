class DropTableRunQueries < ActiveRecord::Migration
  def change
    drop_table :run_queries
  end
end
