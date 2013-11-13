require 'query_runner'

describe QueryRunner do
  let(:query_runner) { QueryRunner.new(nil) }

  before do
    stub_const('ActiveRecord::Base', double)
  end

  describe '#to_csv' do
    it 'generates CSV from the database results' do
      results = [{ 'foo' => 1, 'bar' => 2 },
                 { 'foo' => 3, 'bar' => 4 }]

      ActiveRecord::Base.
        stub(:connection) { double(:select_all => results) }

      expect(query_runner.to_csv).to eq(<<CSV)
foo,bar
1,2
3,4
CSV
    end
  end
end
