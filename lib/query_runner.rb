require 'csv'

class QueryRunner
  attr_reader :sql

  def initialize(sql)
    @sql = sql
  end

  def headers
    results.first ? results.first.keys : []
  end

  def empty?
    headers == []
  end

  def results
    @results ||= ActiveRecord::Base.connection.select_all(sql)
  end

  def to_csv
    CSV.generate do |csv|
      csv << headers

      results.each do |result|
        csv << result.values
      end
    end
  end
end
