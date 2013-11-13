class ChangeSavedQueryDescriptionToText < ActiveRecord::Migration
  def change
    change_column :saved_queries, :description, :text
  end
end
