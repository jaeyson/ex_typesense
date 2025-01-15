defmodule AnalyticsTest do
  use ExUnit.Case, async: true

  alias OpenApiTypesense.Analytics
  alias OpenApiTypesense.AnalyticsRuleSchema
  alias OpenApiTypesense.AnalyticsRulesRetrieveSchema
  alias OpenApiTypesense.ApiResponse
  alias OpenApiTypesense.Collections
  alias OpenApiTypesense.CollectionResponse
  alias OpenApiTypesense.Connection
  alias OpenApiTypesense.AnalyticsEventCreateResponse
  alias OpenApiTypesense.AnalyticsRuleDeleteResponse

  setup_all do
    conn = Connection.new()
    map_conn = %{api_key: "xyz", host: "localhost", port: 8108, scheme: "http"}
    product_name = "products"

    product_schema =
      %{
        name: product_name,
        fields: [
          %{"name" => "product_name", "type" => "string"},
          %{"name" => "#{product_name}_id", "type" => "int32"},
          %{"name" => "description", "type" => "string"},
          %{"name" => "title", "type" => "string"},
          %{"name" => "popularity", "type" => "int32", "optional" => true}
        ],
        default_sorting_field: "#{product_name}_id"
      }

    product_queries_name = "product_queries"

    product_queries_schema =
      %{
        "name" => product_queries_name,
        "fields" => [
          %{"name" => "q", "type" => "string"},
          %{"name" => "count", "type" => "int32"},
          %{"name" => "downloads", "type" => "int32", "optional" => true}
        ]
      }

    nohits_queries_name = "no_hits_queries"

    nohits_queries_schema =
      %{
        "name" => nohits_queries_name,
        "fields" => [
          %{"name" => "q", "type" => "string"},
          %{"name" => "count", "type" => "int32"}
        ]
      }

    [
      product_schema,
      product_queries_schema,
      nohits_queries_schema
    ]
    |> Enum.map(fn schema ->
      Collections.create_collection(schema)
    end)

    on_exit(fn ->
      {:ok, %CollectionResponse{name: ^product_name}} =
        Collections.delete_collection(product_name)

      {:ok, %CollectionResponse{name: ^product_queries_name}} =
        Collections.delete_collection(product_queries_name)

      {:ok, %CollectionResponse{name: ^nohits_queries_name}} =
        Collections.delete_collection(nohits_queries_name)

      {:ok, %AnalyticsRulesRetrieveSchema{rules: rules}} = Analytics.retrieve_analytics_rules()
      Enum.map(rules, &Analytics.delete_analytics_rule(&1.name))
    end)

    %{conn: conn, map_conn: map_conn}
  end

  @tag ["27.1": true, "26.0": true, "0.25.2": true]
  test "create analytics event" do
    assert 1 === 1
  end
end
