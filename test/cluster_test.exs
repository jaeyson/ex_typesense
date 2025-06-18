defmodule ClusterTest do
  use ExUnit.Case, async: true

  alias ExTypesense.TestSchema.Credential
  alias OpenApiTypesense.ApiResponse
  alias OpenApiTypesense.APIStatsResponse
  alias OpenApiTypesense.Connection
  alias OpenApiTypesense.HealthStatus
  alias OpenApiTypesense.SuccessStatus

  @rate_limit :timer.seconds(5)
  @forbidden %ApiResponse{
    message: "Forbidden - a valid `x-typesense-api-key` header must be sent."
  }

  setup_all do
    conn = Connection.new()
    map_conn = %{api_key: "xyz", host: "localhost", port: 8108, scheme: "http"}

    %{conn: conn, map_conn: map_conn}
  end

  @tag ["28.0": true, "27.1": true, "27.0": true, "26.0": true]
  test "error: health check with empty credentials" do
    conn = %{api_key: nil, host: nil, port: nil, scheme: nil}

    assert_raise FunctionClauseError, fn ->
      ExTypesense.health(conn: conn)
    end
  end

  @tag ["28.0": true, "27.1": true, "27.0": true, "26.0": true]
  test "new/1 with invalid data type raises ArgumentError" do
    invalid_inputs = [
      nil,
      "string",
      123,
      [],
      [host: "localhost"]
    ]

    for input <- invalid_inputs do
      error =
        assert_raise ArgumentError, fn ->
          Connection.new(input)
        end

      assert error.message === "Expected a map for connection options"
    end
  end

  @tag ["28.0": true, "27.1": true, "27.0": true, "26.0": true]
  test "error: health check, with incorrect port number" do
    conn = %{api_key: "xyz", host: "localhost", port: 8100, scheme: "http"}

    assert {:error, "connection refused"} = ExTypesense.health(conn: conn)
  end

  @tag ["28.0": true, "27.1": true, "27.0": true, "26.0": true]
  test "error: health check, with incorrect host" do
    conn = %{api_key: "xyz", host: "my_test_host", port: 8108, scheme: "http"}

    assert {:error, "non-existing domain"} = ExTypesense.health(conn: conn)
  end

  @tag ["28.0": true, "27.1": true, "27.0": true, "26.0": true]
  test "error: wrong api key was configured" do
    conn = %{
      host: "localhost",
      api_key: "another_key",
      port: 8108,
      scheme: "http"
    }

    assert {:error, @forbidden} = ExTypesense.list_collections(conn: conn)
  end

  @tag ["28.0": true, "27.1": true, "27.0": true, "26.0": true]
  test "error: overriding config with a wrong API key" do
    conn = %{
      host: "localhost",
      api_key: "another_key",
      port: 8108,
      scheme: "http"
    }

    assert {:error, @forbidden} = ExTypesense.list_collections(conn: conn)
  end

  @tag ["28.0": true, "27.1": true, "27.0": true, "26.0": true]
  test "success: Using a struct converted to map and update its keys" do
    conn = %Credential{
      node: "localhost",
      secret_key: "xyz",
      port: 8108,
      scheme: "http"
    }

    conn =
      conn
      |> Map.from_struct()
      |> Map.drop([:node, :secret_key])
      |> Map.put(:host, conn.node)
      |> Map.put(:api_key, conn.secret_key)

    assert {:ok, %HealthStatus{ok: true}} = ExTypesense.health(conn: conn)
  end

  @tag ["28.0": true, "27.1": true, "27.0": true, "26.0": true]
  test "health", %{conn: conn, map_conn: map_conn} do
    assert {:ok, %HealthStatus{ok: true}} = ExTypesense.health()
    assert {:ok, _} = ExTypesense.health([])
    assert {:ok, _} = ExTypesense.health(conn: conn)
    assert {:ok, _} = ExTypesense.health(conn: map_conn)
  end

  @tag ["28.0": true, "27.1": true, "27.0": true, "26.0": true]
  test "api status", %{conn: conn, map_conn: map_conn} do
    assert {:ok, %APIStatsResponse{}} = ExTypesense.api_stats()
    assert {:ok, _} = ExTypesense.api_stats([])
    assert {:ok, _} = ExTypesense.api_stats(conn: conn)
    assert {:ok, _} = ExTypesense.api_stats(conn: map_conn)
  end

  @tag ["28.0": true, "27.1": true, "27.0": true, "26.0": true]
  test "cluster metrics", %{conn: conn, map_conn: map_conn} do
    assert {:ok, %{}} = ExTypesense.cluster_metrics()
    assert {:ok, _} = ExTypesense.cluster_metrics([])
    assert {:ok, _} = ExTypesense.cluster_metrics(conn: conn)
    assert {:ok, _} = ExTypesense.cluster_metrics(conn: map_conn)
  end

  @tag ["28.0": true, "27.1": true, "27.0": true, "26.0": true]
  test "create snapshot", %{conn: conn, map_conn: map_conn} do
    # we have to add sleep timer for github actions
    # otherwise it will return like:
    # {:error,
    #  %OpenApiTypesense.ApiResponse{
    #    message: "Another snapshot is in progress."
    #  }}

    path = "/tmp/typesense-data-snapshot"

    assert {:ok, %SuccessStatus{success: true}} = ExTypesense.create_snapshot(snapshot_path: path)

    Process.sleep(@rate_limit)

    assert {:ok, %SuccessStatus{success: true}} =
             ExTypesense.create_snapshot(snapshot_path: path, conn: conn)

    Process.sleep(@rate_limit)

    assert {:ok, %SuccessStatus{success: true}} =
             ExTypesense.create_snapshot(snapshot_path: path, conn: map_conn)
  end

  @tag ["28.0": true, "27.1": true, "27.0": true, "26.0": true]
  test "compact DB", %{conn: conn, map_conn: map_conn} do
    assert {:ok, %SuccessStatus{success: true}} = ExTypesense.compact_db()
    assert {:ok, _} = ExTypesense.compact_db([])
    assert {:ok, _} = ExTypesense.compact_db(conn: conn)
    assert {:ok, _} = ExTypesense.compact_db(conn: map_conn)
  end

  @tag ["28.0": true, "27.1": true, "27.0": true, "26.0": true]
  test "clear cache", %{conn: conn, map_conn: map_conn} do
    assert {:ok, %SuccessStatus{success: true}} = ExTypesense.clear_cache()
    assert {:ok, _} = ExTypesense.clear_cache([])
    assert {:ok, _} = ExTypesense.clear_cache(conn: conn)
    assert {:ok, _} = ExTypesense.clear_cache(conn: map_conn)
  end

  @tag ["28.0": true, "27.1": true, "27.0": true, "26.0": true]
  test "toggle slow request log", %{conn: conn, map_conn: map_conn} do
    config = %{"log_slow_requests_time_ms" => :timer.seconds(2)}
    assert {:ok, %SuccessStatus{success: true}} = ExTypesense.toggle_slow_request_log(config)
    assert {:ok, _} = ExTypesense.toggle_slow_request_log(config, [])
    assert {:ok, _} = ExTypesense.toggle_slow_request_log(config, conn: conn)
    assert {:ok, _} = ExTypesense.toggle_slow_request_log(config, conn: map_conn)
  end

  @tag ["28.0": true, "27.1": true, "27.0": true, "26.0": true]
  test "re-elect leader (vote)", %{conn: conn, map_conn: map_conn} do
    assert {:ok, %SuccessStatus{success: false}} = ExTypesense.vote()
    assert {:ok, _} = ExTypesense.vote([])
    assert {:ok, _} = ExTypesense.vote(conn: conn)
    assert {:ok, _} = ExTypesense.vote(conn: map_conn)
  end

  @tag ["28.0": true, "27.1": false, "27.0": false, "26.0": false]
  test "success: get schema changes", %{conn: conn, map_conn: map_conn} do
    assert {:ok, schemas} = ExTypesense.get_schema_changes()
    assert length(schemas) >= 0

    assert {:ok, _} = ExTypesense.get_schema_changes([])
    assert {:ok, _} = ExTypesense.get_schema_changes(conn: conn)
    assert {:ok, _} = ExTypesense.get_schema_changes(conn: map_conn)
  end
end
