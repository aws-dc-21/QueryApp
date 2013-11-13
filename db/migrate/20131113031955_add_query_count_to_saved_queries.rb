class AddQueryCountToSavedQueries < ActiveRecord::Migration
  def change
    add_column :saved_queries, :query_count, :integer
  end
end
