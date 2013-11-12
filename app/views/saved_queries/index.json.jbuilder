json.array!(@saved_queries) do |saved_query|
  json.extract! saved_query, :name, :description, :sql
  json.url saved_query_url(saved_query, format: :json)
end
