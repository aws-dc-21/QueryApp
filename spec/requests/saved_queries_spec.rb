require 'spec_helper'

describe "SavedQueries" do
  describe "GET /saved_queries" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get saved_queries_path
      response.status.should be(200)
    end
  end
end
