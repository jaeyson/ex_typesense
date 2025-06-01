defmodule AnalyticsTest do
  use ExUnit.Case, async: true

  alias OpenApiTypesense.AnalyticsEventCreateResponse
  alias OpenApiTypesense.AnalyticsRuleDeleteResponse
  alias OpenApiTypesense.AnalyticsRuleSchema
  alias OpenApiTypesense.AnalyticsRulesRetrieveSchema
  alias OpenApiTypesense.ApiResponse
  alias OpenApiTypesense.CollectionResponse
  alias OpenApiTypesense.Connection

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
      ExTypesense.create_collection(schema)
    end)

    on_exit(fn ->
      {:ok, %CollectionResponse{name: ^product_name}} =
        ExTypesense.drop_collection(product_name)

      {:ok, %CollectionResponse{name: ^product_queries_name}} =
        ExTypesense.drop_collection(product_queries_name)

      {:ok, %CollectionResponse{name: ^nohits_queries_name}} =
        ExTypesense.drop_collection(nohits_queries_name)

      {:ok, %AnalyticsRulesRetrieveSchema{rules: rules}} = ExTypesense.list_analytics_rules()
      Enum.map(rules, &ExTypesense.delete_analytics_rule(&1.name))
    end)

    %{conn: conn, map_conn: map_conn}
  end

  @tag ["28.0": true, "27.1": true, "27.0": true, "26.0": true]
  test "error: create analytics rule with non-existent collection", %{
    conn: conn,
    map_conn: map_conn
  } do
    name = "products_missing_query"
    collection_name = "non_existent_collection"

    body =
      %{
        "name" => name,
        "type" => "counter",
        "params" => %{
          "source" => %{
            "collections" => ["products"]
          },
          "destination" => %{
            "collection" => collection_name
          }
        }
      }

    assert {:error, %ApiResponse{message: _}} = ExTypesense.create_analytics_rule(body)
    assert {:error, _} = ExTypesense.create_analytics_rule(body, [])
    assert {:error, _} = ExTypesense.create_analytics_rule(body, conn: conn)
    assert {:error, _} = ExTypesense.create_analytics_rule(body, conn: map_conn)
  end

  @tag ["28.0": true, "27.1": true, "27.0": true, "26.0": true]
  test "success: upsert analytics rule", %{conn: conn, map_conn: map_conn} do
    name = "product_no_hits"

    body =
      %{
        "type" => "nohits_queries",
        "params" => %{
          "source" => %{
            "collections" => ["products"]
          },
          "destination" => %{
            "collection" => "no_hits_queries"
          },
          "limit" => 1_000
        }
      }

    assert {:ok, %AnalyticsRuleSchema{name: ^name}} =
             ExTypesense.upsert_analytics_rule(name, body)

    assert {:ok, %AnalyticsRuleSchema{name: ^name}} =
             ExTypesense.upsert_analytics_rule(name, body, [])

    assert {:ok, %AnalyticsRuleSchema{name: ^name}} =
             ExTypesense.upsert_analytics_rule(name, body, conn: conn)

    assert {:ok, %AnalyticsRuleSchema{name: ^name}} =
             ExTypesense.upsert_analytics_rule(name, body, conn: map_conn)
  end

  @tag ["28.0": true, "27.1": true, "27.0": true, "26.0": true]
  test "error: create analytics rule with wrong field" do
    name = "products_test_query"
    field_name = "wrong_field"

    body =
      %{
        "name" => name,
        "type" => "counter",
        "params" => %{
          "source" => %{
            "collections" => ["products"],
            "events" => [
              %{"type" => "click", "weight" => 1, "name" => "products_downloads_event"}
            ]
          },
          "destination" => %{
            "collection" => "product_queries",
            "counter_field" => field_name
          }
        }
      }

    assert {:error, %ApiResponse{message: _}} = ExTypesense.create_analytics_rule(body)
  end

  @tag ["28.0": true, "27.1": true, "27.0": true, "26.0": true]
  test "success: list analytics rules", %{conn: conn, map_conn: map_conn} do
    assert {:ok, %AnalyticsRulesRetrieveSchema{rules: rules}} =
             ExTypesense.list_analytics_rules()

    assert length(rules) >= 0

    assert {:ok, %AnalyticsRulesRetrieveSchema{rules: _}} =
             ExTypesense.list_analytics_rules([])

    assert {:ok, %AnalyticsRulesRetrieveSchema{rules: _}} =
             ExTypesense.list_analytics_rules(conn: conn)

    assert {:ok, %AnalyticsRulesRetrieveSchema{rules: _}} =
             ExTypesense.list_analytics_rules(conn: map_conn)
  end

  @tag ["28.0": true, "27.1": true, "27.0": true, "26.0": false]
  test "success (v27.1): create analytics rule and event", %{conn: conn, map_conn: map_conn} do
    name = "product_popularity"

    event_name = "products_click_event#{System.unique_integer()}"

    body =
      %{
        "name" => name,
        "type" => "counter",
        "params" => %{
          "source" => %{
            "collections" => ["products"],
            "events" => [
              %{"type" => "click", "weight" => 1, "name" => event_name}
            ]
          },
          "destination" => %{
            "collection" => "products",
            "counter_field" => "popularity"
          }
        }
      }

    assert {:ok, %AnalyticsRuleSchema{name: ^name}} = ExTypesense.create_analytics_rule(body)
    assert {:ok, %AnalyticsRuleSchema{name: ^name}} = ExTypesense.get_analytics_rule(name)

    assert {:ok, %AnalyticsRuleSchema{name: ^name}} =
             ExTypesense.get_analytics_rule(name, [])

    assert {:ok, %AnalyticsRuleSchema{name: ^name}} =
             ExTypesense.get_analytics_rule(name, conn: conn)

    assert {:ok, %AnalyticsRuleSchema{name: ^name}} =
             ExTypesense.get_analytics_rule(name, conn: map_conn)

    body =
      %{
        "name" => event_name,
        "type" => "click",
        "data" => %{
          "q" => "nike_shoes",
          "doc_id" => "2468",
          "user_id" => "9903"
        }
      }

    # Here's the reason why v26.0 is not tested
    # Docs v26.0: https://typesense.org/docs/26.0/api/analytics-query-suggestions.html#sending-click-events
    # Problem: the response JSON body is actually {"ok": true
    # where it is missing a closing curly bracket "}"
    assert {:ok, %AnalyticsEventCreateResponse{ok: true}} =
             ExTypesense.create_analytics_event(body)

    assert {:ok, %AnalyticsEventCreateResponse{ok: true}} =
             ExTypesense.create_analytics_event(body, [])

    assert {:ok, %AnalyticsEventCreateResponse{ok: true}} =
             ExTypesense.create_analytics_event(body, conn: conn)

    assert {:ok, %AnalyticsEventCreateResponse{ok: true}} =
             ExTypesense.create_analytics_event(body, conn: map_conn)

    assert {:ok, %AnalyticsRuleDeleteResponse{name: ^name}} =
             ExTypesense.delete_analytics_rule(name)

    assert {:error, %ApiResponse{message: _}} = ExTypesense.delete_analytics_rule(name, [])

    assert {:error, %ApiResponse{message: _}} =
             ExTypesense.delete_analytics_rule(name, conn: conn)

    assert {:error, %ApiResponse{message: _}} =
             ExTypesense.delete_analytics_rule(name, conn: map_conn)
  end
end
