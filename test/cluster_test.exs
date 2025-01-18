defmodule ClusterTest do
  use ExUnit.Case, async: true

  alias OpenApiTypesense.APIStatsResponse
  alias OpenApiTypesense.Connection
  alias OpenApiTypesense.HealthStatus
  alias OpenApiTypesense.SuccessStatus

  @rate_limit :timer.seconds(5)

  setup_all do
    conn = Connection.new()
    map_conn = %{api_key: "xyz", host: "localhost", port: 8108, scheme: "http"}

    %{conn: conn, map_conn: map_conn}
  end

  @tag ["27.1": true, "26.0": true, "0.25.2": true]
  test "health", %{conn: conn, map_conn: map_conn} do
    assert {:ok, %HealthStatus{ok: true}} = ExTypesense.health()
    assert {:ok, _} = ExTypesense.health([])
    assert {:ok, _} = ExTypesense.health(conn)
    assert {:ok, _} = ExTypesense.health(map_conn)
    assert {:ok, _} = ExTypesense.health(conn, [])
    assert {:ok, _} = ExTypesense.health(map_conn, [])
  end

  @tag ["27.1": true, "26.0": true, "0.25.2": true]
  test "api status", %{conn: conn, map_conn: map_conn} do
    assert {:ok, %APIStatsResponse{}} = ExTypesense.api_stats()
    assert {:ok, _} = ExTypesense.api_stats([])
    assert {:ok, _} = ExTypesense.api_stats(conn)
    assert {:ok, _} = ExTypesense.api_stats(map_conn)
    assert {:ok, _} = ExTypesense.api_stats(conn, [])
    assert {:ok, _} = ExTypesense.api_stats(map_conn, [])
  end

  @tag ["27.1": true, "26.0": true, "0.25.2": true]
  test "cluster metrics", %{conn: conn, map_conn: map_conn} do
    assert {:ok, %{}} = ExTypesense.cluster_metrics()
    assert {:ok, _} = ExTypesense.cluster_metrics([])
    assert {:ok, _} = ExTypesense.cluster_metrics(conn)
    assert {:ok, _} = ExTypesense.cluster_metrics(map_conn)
    assert {:ok, _} = ExTypesense.cluster_metrics(conn, [])
    assert {:ok, _} = ExTypesense.cluster_metrics(map_conn, [])
  end

  @tag ["27.1": true, "26.0": true, "0.25.2": true]
  test "create snapshot", %{conn: conn, map_conn: map_conn} do
    opts = [snapshot_path: "/tmp/typesense-data-snapshot"]

    assert {:ok, %SuccessStatus{success: true}} = ExTypesense.create_snapshot(opts)

    Process.sleep(@rate_limit)
    assert {:ok, %SuccessStatus{success: true}} = ExTypesense.create_snapshot(conn, opts)

    Process.sleep(@rate_limit)
    assert {:ok, %SuccessStatus{success: true}} = ExTypesense.create_snapshot(map_conn, opts)
  end

  @tag ["27.1": true, "26.0": true, "0.25.2": true]
  test "compact DB", %{conn: conn, map_conn: map_conn} do
    assert {:ok, %SuccessStatus{success: true}} = ExTypesense.compact_db()
    assert {:ok, _} = ExTypesense.compact_db([])
    assert {:ok, _} = ExTypesense.compact_db(conn)
    assert {:ok, _} = ExTypesense.compact_db(map_conn)
    assert {:ok, _} = ExTypesense.compact_db(conn, [])
    assert {:ok, _} = ExTypesense.compact_db(map_conn, [])
  end

  @tag ["27.1": true, "26.0": true, "0.25.2": true]
  test "clear cache", %{conn: conn, map_conn: map_conn} do
    assert {:ok, %SuccessStatus{success: true}} = ExTypesense.clear_cache()
    assert {:ok, _} = ExTypesense.clear_cache([])
    assert {:ok, _} = ExTypesense.clear_cache(conn)
    assert {:ok, _} = ExTypesense.clear_cache(map_conn)
    assert {:ok, _} = ExTypesense.clear_cache(conn, [])
    assert {:ok, _} = ExTypesense.clear_cache(map_conn, [])
  end

  @tag ["27.1": true, "26.0": true, "0.25.2": true]
  test "toggle slow request log", %{conn: conn, map_conn: map_conn} do
    config = %{"log_slow_requests_time_ms" => 2_000}
    assert {:ok, %SuccessStatus{success: true}} = ExTypesense.toggle_slow_request_log(config)
    assert {:ok, _} = ExTypesense.toggle_slow_request_log(config, [])
    assert {:ok, _} = ExTypesense.toggle_slow_request_log(conn, config)
    assert {:ok, _} = ExTypesense.toggle_slow_request_log(map_conn, config)
    assert {:ok, _} = ExTypesense.toggle_slow_request_log(conn, config, [])
    assert {:ok, _} = ExTypesense.toggle_slow_request_log(map_conn, config, [])
  end

  @tag ["27.1": true, "26.0": true, "0.25.2": true]
  test "re-elect leader (vote)", %{conn: conn, map_conn: map_conn} do
    assert {:ok, %SuccessStatus{success: false}} = ExTypesense.vote()
    assert {:ok, _} = ExTypesense.vote([])
    assert {:ok, _} = ExTypesense.vote(conn)
    assert {:ok, _} = ExTypesense.vote(map_conn)
    assert {:ok, _} = ExTypesense.vote(conn, [])
    assert {:ok, _} = ExTypesense.vote(map_conn, [])
  end
end
