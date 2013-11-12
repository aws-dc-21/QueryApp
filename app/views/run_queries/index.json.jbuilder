json.array!(@run_queries) do |run_query|
  json.extract! run_query, :sql
  json.url run_query_url(run_query, format: :json)
end
