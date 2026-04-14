defmodule AnalyticsTest do
  use ExUnit.Case, async: true

  alias OpenApiTypesense.AnalyticsEventCreateResponse
  alias OpenApiTypesense.AnalyticsEventsResponse
  alias OpenApiTypesense.AnalyticsRule
  alias OpenApiTypesense.AnalyticsRulesRetrieveSchema
  alias OpenApiTypesense.ApiResponse
  alias OpenApiTypesense.CollectionResponse
  alias OpenApiTypesense.Connection
  alias OpenApiTypesense.AnalyticsStatus

  setup_all do
    conn = Connection.new()
    map_conn = %{api_key: "xyz", host: "localhost", port: 8108, scheme: "http"}
    product_name = "analytics_products"

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

      case ExTypesense.list_analytics_rules() do
        {:ok, %AnalyticsRulesRetrieveSchema{rules: rules}} ->
          Enum.map(rules, &ExTypesense.delete_analytics_rule(&1.name))

        {:ok, rules} when is_list(rules) ->
          Enum.map(rules, &ExTypesense.delete_analytics_rule(&1.name))
      end
    end)

    %{conn: conn, map_conn: map_conn}
  end

  @tag ["30.0": true]
  test "error (v30.0): create analytics rule with non-existent collection", %{
    conn: conn,
    map_conn: map_conn
  } do
    name = "products_missing_query"
    collection_name = "non_existent_collection"

    body =
      %{
        "name" => name,
        "collection" => "analytics_products",
        "type" => "popular_queries",
        "event_type" => "search",
        "params" => %{
          "destination_collection" => collection_name,
          "expand_query" => false,
          "limit" => 1_000,
          "capture_search_requests" => true
        }
      }

    assert {:error, %ApiResponse{message: message}} = ExTypesense.create_analytics_rule(body)

    assert String.contains?(String.downcase(message), [
             "does not exist"
           ]) === true

    assert {:error, _} = ExTypesense.create_analytics_rule(body, [])
    assert {:error, _} = ExTypesense.create_analytics_rule(body, conn: conn)
    assert {:error, _} = ExTypesense.create_analytics_rule(body, conn: map_conn)
  end

  @tag ["30.0": true]
  test "success (v30.0): upsert analytics rule", %{conn: conn, map_conn: map_conn} do
    name = "product_no_hits"

    body =
      %{
        "name" => name,
        "type" => "nohits_queries",
        "collection" => "analytics_products",
        "event_type" => "search",
        "params" => %{
          "destination_collection" => "product_queries",
          "expand_query" => false,
          "limit" => 1_000,
          "capture_search_requests" => true
        }
      }

    assert {:ok, %AnalyticsRule{name: ^name}} = ExTypesense.upsert_analytics_rule(name, body)
    assert {:ok, %AnalyticsRule{name: ^name}} = ExTypesense.upsert_analytics_rule(name, body, [])

    assert {:ok, %AnalyticsRule{name: ^name}} =
             ExTypesense.upsert_analytics_rule(name, body, conn: conn)

    assert {:ok, %AnalyticsRule{name: ^name}} =
             ExTypesense.upsert_analytics_rule(name, body, conn: map_conn)
  end

  @tag ["30.0": true]
  test "success (v30.0): flush analytics", %{conn: conn, map_conn: map_conn} do
    response = {:ok, %AnalyticsEventCreateResponse{ok: true}}

    assert ^response = ExTypesense.flush_analytics()
    assert ^response = ExTypesense.flush_analytics([])
    assert ^response = ExTypesense.flush_analytics(conn: conn)
    assert ^response = ExTypesense.flush_analytics(map_conn: map_conn)
  end

  @tag ["30.0": true]
  test "error (v30.0): get analytics events", %{conn: conn, map_conn: map_conn} do
    reason = {:error, %ApiResponse{message: "Missing required parameter 'user_id'."}}

    assert ^reason = ExTypesense.get_analytics_events()
    assert ^reason = ExTypesense.get_analytics_events([])

    reason = {:error, %ApiResponse{message: "Rule not found"}}

    opts = [user_id: "9903", name: "product_popularity", n: 1]
    assert ^reason = ExTypesense.get_analytics_events(opts)
    assert ^reason = ExTypesense.get_analytics_events(opts ++ [conn: conn])
    assert ^reason = ExTypesense.get_analytics_events(opts ++ [map_conn: map_conn])
  end

  @tag ["30.0": true]
  test "success (v30.0): get analytics status", %{conn: conn, map_conn: map_conn} do
    status = %AnalyticsStatus{
      doc_counter_events: 0,
      doc_log_events: 0,
      log_prefix_queries: 0,
      nohits_prefix_queries: 0,
      popular_prefix_queries: 0,
      query_counter_events: 0,
      query_log_events: 0
    }

    assert {:ok, ^status} = ExTypesense.get_analytics_status()
    assert {:ok, ^status} = ExTypesense.get_analytics_status([])
    assert {:ok, ^status} = ExTypesense.get_analytics_status(conn: conn)
    assert {:ok, ^status} = ExTypesense.get_analytics_status(map_conn: map_conn)
  end

  @tag ["30.0": true]
  test "success (v30.0): send click events", %{conn: conn, map_conn: map_conn} do
    name = "products_clicks"

    body =
      %{
        "name" => name,
        "type" => "counter",
        "collection" => "analytics_products",
        "event_type" => "click",
        "params" => %{
          "destination_collection" => "analytics_products",
          "counter_field" => "popularity",
          "weight" => 1
        }
      }

    assert {:ok, %AnalyticsRule{name: ^name}} = ExTypesense.create_analytics_rule(body)
    assert {:ok, %AnalyticsRule{name: ^name}} = ExTypesense.get_analytics_rule(name)
    assert {:ok, %AnalyticsRule{name: ^name}} = ExTypesense.get_analytics_rule(name, [])

    assert {:ok, %AnalyticsRule{name: ^name}} =
             ExTypesense.get_analytics_rule(name, conn: conn)

    assert {:ok, %AnalyticsRule{name: ^name}} = ExTypesense.get_analytics_rule(name, [])

    assert {:ok, %AnalyticsRule{name: ^name}} =
             ExTypesense.get_analytics_rule(name, conn: map_conn)

    body =
      %{
        "name" => name,
        "event_type" => "click",
        "data" => %{
          "doc_id" => "1024",
          "user_id" => "111112"
        }
      }

    # Here's the reason why v26.0 is not tested
    # Docs v26.0: https://typesense.org/docs/26.0/api/analytics-query-suggestions.html#sending-click-events
    # Problem: the response JSON body is actually {"ok": true
    # where it is missing a closing curly bracket "}"
    response = {:ok, %AnalyticsEventCreateResponse{ok: true}}
    assert ^response = ExTypesense.create_analytics_event(body)
    assert ^response = ExTypesense.create_analytics_event(body, [])
    assert ^response = ExTypesense.create_analytics_event(body, conn: conn)
    assert ^response = ExTypesense.create_analytics_event(body, conn: map_conn)

    assert {:ok, %AnalyticsRule{name: ^name}} =
             ExTypesense.delete_analytics_rule(name)

    error = {:error, %ApiResponse{message: "Rule not found"}}
    assert ^error = ExTypesense.delete_analytics_rule(name, [])
    assert ^error = ExTypesense.delete_analytics_rule(name, conn: conn)
    assert ^error = ExTypesense.delete_analytics_rule(name, conn: map_conn)
  end

  @tag ["29.0": true, "28.0": true, "27.1": true, "27.0": true, "26.0": false]
  test "error (v29.0): flush analytics", %{conn: conn, map_conn: map_conn} do
    error = {:error, %ApiResponse{message: "Not Found"}}
    assert ^error = ExTypesense.flush_analytics()
    assert ^error = ExTypesense.flush_analytics([])
    assert ^error = ExTypesense.flush_analytics(conn: conn)
    assert ^error = ExTypesense.flush_analytics(map_conn: map_conn)
  end

  @tag ["29.0": true, "28.0": true, "27.1": true, "27.0": true, "26.0": true]
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

  @tag ["29.0": true, "28.0": true, "27.1": true, "27.0": true, "26.0": true]
  test "success (v29.0): upsert analytics rule", %{conn: conn, map_conn: map_conn} do
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

    assert {:ok, %AnalyticsRule{name: ^name}} = ExTypesense.upsert_analytics_rule(name, body)
    assert {:ok, %AnalyticsRule{name: ^name}} = ExTypesense.upsert_analytics_rule(name, body, [])

    assert {:ok, %AnalyticsRule{name: ^name}} =
             ExTypesense.upsert_analytics_rule(name, body, conn: conn)

    assert {:ok, %AnalyticsRule{name: ^name}} =
             ExTypesense.upsert_analytics_rule(name, body, conn: map_conn)
  end

  @tag ["29.0": true, "28.0": true, "27.1": true, "27.0": true, "26.0": true]
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

  @tag [
    "30.1": true,
    "30.0": true,
    "29.0": true,
    "28.0": true,
    "27.1": true,
    "27.0": true,
    "26.0": true
  ]
  test "success (v29.0): list analytics rules", %{conn: conn, map_conn: map_conn} do
    case ExTypesense.list_analytics_rules() do
      {:ok, []} ->
        assert {:ok, []} = ExTypesense.list_analytics_rules([])
        assert {:ok, []} = ExTypesense.list_analytics_rules(conn: conn)
        assert {:ok, []} = ExTypesense.list_analytics_rules(conn: map_conn)

      {:ok, [first | _]} when is_struct(first, AnalyticsRule) ->
        assert {:ok, _rules} = ExTypesense.list_analytics_rules([])
        assert {:ok, _rules} = ExTypesense.list_analytics_rules(conn: conn)
        assert {:ok, _rules} = ExTypesense.list_analytics_rules(conn: map_conn)
    end
  end

  @tag ["29.0": true, "28.0": true, "27.1": false, "27.0": false, "26.0": false]
  test "success (v28.0) : get analytics events", %{conn: conn, map_conn: map_conn} do
    events_response = {:ok, %AnalyticsEventsResponse{events: []}}

    assert ^events_response = ExTypesense.get_analytics_events()
    assert ^events_response = ExTypesense.get_analytics_events([])
    assert ^events_response = ExTypesense.get_analytics_events(conn: conn)
    assert ^events_response = ExTypesense.get_analytics_events(map_conn: map_conn)
  end

  @tag ["29.0": true, "28.0": true, "27.1": true, "27.0": true, "26.0": false]
  test "success (v29.0): get analytics status", %{conn: conn, map_conn: map_conn} do
    reason = {:error, %ApiResponse{message: "Not Found"}}
    assert ^reason = ExTypesense.get_analytics_status()
    assert ^reason = ExTypesense.get_analytics_status([])
    assert ^reason = ExTypesense.get_analytics_status(conn: conn)
    assert ^reason = ExTypesense.get_analytics_status(map_conn: map_conn)
  end

  @tag ["29.0": true, "28.0": true, "27.1": true, "27.0": true]
  test "success (v29.0): create analytics rule and event", %{conn: conn, map_conn: map_conn} do
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

    assert {:ok, %AnalyticsRule{name: ^name}} = ExTypesense.create_analytics_rule(body)
    assert {:ok, %AnalyticsRule{name: ^name}} = ExTypesense.get_analytics_rule(name)
    assert {:ok, %AnalyticsRule{name: ^name}} = ExTypesense.get_analytics_rule(name, [])
    assert {:ok, %AnalyticsRule{name: ^name}} = ExTypesense.get_analytics_rule(name, conn: conn)

    assert {:ok, %AnalyticsRule{name: ^name}} =
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

    assert {:ok, %AnalyticsEventCreateResponse{ok: true}} =
             ExTypesense.create_analytics_event(body)

    assert {:ok, %AnalyticsEventCreateResponse{ok: true}} =
             ExTypesense.create_analytics_event(body, [])

    assert {:ok, %AnalyticsEventCreateResponse{ok: true}} =
             ExTypesense.create_analytics_event(body, conn: conn)

    assert {:ok, %AnalyticsEventCreateResponse{ok: true}} =
             ExTypesense.create_analytics_event(body, conn: map_conn)

    assert {:ok, %AnalyticsRule{name: ^name}} = ExTypesense.delete_analytics_rule(name)

    assert {:error, %ApiResponse{message: _}} = ExTypesense.delete_analytics_rule(name, [])

    assert {:error, %ApiResponse{message: _}} =
             ExTypesense.delete_analytics_rule(name, conn: conn)

    assert {:error, %ApiResponse{message: _}} =
             ExTypesense.delete_analytics_rule(name, conn: map_conn)
  end
end
