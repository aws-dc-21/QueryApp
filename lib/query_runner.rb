require 'csv'

class QueryRunner
  attr_reader :sql

  def initialize(sql)
    @sql = sql
  end

  def empty?
    results.empty?
  end

  def headers
    results.first.keys
  end

  def results
    @results ||= ActiveRecord::Base.connection.select_all(sql)
  end

  def to_csv
    if empty?
      ''
    else
      CSV.generate do |csv|
        csv << headers

        results.each do |result|
          csv << result.values
        end
      end
    end
  end
end
