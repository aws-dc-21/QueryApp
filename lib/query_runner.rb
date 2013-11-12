class QueryRunner
  attr_reader :sql

  def initialize(sql)
    @sql = sql
  end

  def headers
    results.first.keys
  end

  def results
    @results ||= ActiveRecord::Base.connection.select_all(sql)
  end
end
