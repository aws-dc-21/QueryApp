class SavedQuery < ActiveRecord::Base
  validates :name, :presence => true
  validates :sql, :presence => true
end
