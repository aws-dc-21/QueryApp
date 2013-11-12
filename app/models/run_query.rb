require 'active_model'

class RunQuery
  include ActiveModel::Model

  attr_reader :sql
  validates :sql, :presence => true

  def initialize(attrs = {})
    @sql = attrs[:sql]
  end
end
