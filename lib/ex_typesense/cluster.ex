defmodule ExTypesense.Cluster do
  @moduledoc since: "0.3.0"

  @moduledoc """
  Cluster specific operations.
  """

  alias OpenApiTypesense.Connection

  @doc """
  Get health information about a Typesense node.
  """
  @doc since: "0.3.0"
  @spec health :: {:ok, OpenApiTypesense.HealthStatus.t()} | :error
  def health do
    Connection.new() |> health()
  end

  @doc """
  Same as [health/0](`health/0`) but passes another connection.

  ```elixir
  ExTypesense.health(%{api_key: xyz, host: ...})
  ExTypesense.health(ExTypesense.Connection.new())
  ```
  """
  @doc since: "1.0.0"
  @spec health(map() | OpenApiTypesense.Connection.t()) ::
          {:ok, OpenApiTypesense.HealthStatus.t()} | :error
  def health(conn) do
    OpenApiTypesense.Health.health(conn)
  end

  @doc """
  Get stats about API endpoints.

  This endpoint returns average requests per second and latencies for all requests in the last 10 seconds.
  """
  @doc since: "0.3.0"
  @spec api_stats :: {:ok, OpenApiTypesense.APIStatsResponse.t()} | :error
  def api_stats do
    Connection.new() |> api_stats()
  end

  @doc """
  Same as [api_stats/0](`api_stats/0`) but passes another connection.

  ```elixir
  ExTypesense.api_stats(%{api_key: xyz, host: ...})
  ExTypesense.api_stats(ExTypesense.Connection.new())
  ```
  """
  @doc since: "1.0.0"
  @spec api_stats(map() | OpenApiTypesense.Connection.t()) ::
          {:ok, OpenApiTypesense.APIStatsResponse.t()} | :error
  def api_stats(conn) do
    OpenApiTypesense.Operations.retrieve_api_stats(conn)
  end

  @doc """
  Get current RAM, CPU, Disk & Network usage metrics.
  """
  @doc since: "0.3.0"
  @spec cluster_metrics :: {:ok, map} | :error
  def cluster_metrics do
    Connection.new() |> cluster_metrics()
  end

  @doc """
  Same as [cluster_metrics/0](`cluster_metrics/0`) but passes another connection.

  ```elixir
  ExTypesense.cluster_metrics(%{api_key: xyz, host: ...})
  ExTypesense.cluster_metrics(ExTypesense.Connection.new())
  ```
  """
  @doc since: "1.0.0"
  @spec cluster_metrics(map() | OpenApiTypesense.Connection.t()) :: {:ok, map} | :error
  def cluster_metrics(conn) do
    OpenApiTypesense.Operations.retrieve_metrics(conn)
  end

  @doc """
  Creates a point-in-time snapshot of a Typesense node's state and data in the
  specified directory.

  You can then backup the snapshot directory that gets created and later restore
  it as a data directory, as needed.
  """
  @doc since: "1.0.0"
  @spec create_snapshot(String.t()) ::
          {:ok, OpenApiTypesense.SuccessStatus.t()} | :error
  def create_snapshot(snapshot_path) do
    Connection.new() |> create_snapshot(snapshot_path)
  end

  @doc """
  Same as [create_snapshot/1](`create_snapshot/1`) but passes another connection.

  ```elixir
  ExTypesense.create_snapshot(%{api_key: xyz, host: ...}, "/tmp/typesense-data-snapshot")
  ExTypesense.create_snapshot(ExTypesense.Connection.new(), "/tmp/typesense-data-snapshot")
  ```
  """
  @doc since: "1.0.0"
  @spec create_snapshot(String.t()) ::
          {:ok, OpenApiTypesense.SuccessStatus.t()} | :error
  def create_snapshot(conn, snapshot_path) do
    OpenApiTypesense.Operations.take_snapshot(conn, snapshot_path: snapshot_path)
  end

  @doc """
  [Compaction](https://typesense.org/docs/latest/api/cluster-operations.html#compacting-the-on-disk-database)
  of the underlying RocksDB database.

  Typesense uses RocksDB to store your documents on the disk. If you do frequent
  writes or updates, you could benefit from running a compaction of the underlying
  RocksDB database. This could reduce the size of the database and decrease read
  latency. While the database will not block during this operation, we recommend
  running it during off-peak hours.
  """
  @doc since: "1.0.0"
  @spec compact_db ::
          {:ok, OpenApiTypesense.SuccessStatus.t()} | :error
  def compact_db do
    Connection.new() |> compact_db()
  end

  @doc """
  Same as [compact_db/0](`compact_db/0`) but passes another connection.

  ```elixir
  ExTypesense.compact_db(%{api_key: xyz, host: ...})
  ExTypesense.compact_db(ExTypesense.Connection.new())
  ```
  """
  @doc since: "1.0.0"
  @spec compact_db(map() | OpenApiTypesense.Connection.t()) ::
          {:ok, OpenApiTypesense.SuccessStatus.t()} | :error
  def compact_db(conn) do
    OpenApiTypesense.Operations.compact(conn)
  end

  @doc """
  Clears the cache

  Responses of search requests that are sent with
  [`use_cache` parameter](https://typesense.org/docs/latest/api/search.html#caching-parameters)
  are cached in a LRU cache. Clears cache completely.
  """
  @doc since: "1.0.0"
  @spec clear_cache :: {:ok, OpenApiTypesense.SuccessStatus.t()} | :error
  def clear_cache do
    Connection.new() |> clear_cache()
  end

  @doc """
  Same as [clear_cache/0](`clear_cache/0`) but passes another connection.

  ```elixir
  ExTypesense.clear_cache(%{api_key: xyz, host: ...})
  ExTypesense.clear_cache(ExTypesense.Connection.new())
  ```
  """
  @doc since: "1.0.0"
  @spec clear_cache(map() | OpenApiTypesense.Connection.t()) ::
          {:ok, OpenApiTypesense.SuccessStatus.t()} | :error
  def clear_cache(conn) do
    OpenApiTypesense.Operations.clear_cache(conn)
  end

  @doc """
  Enable logging of requests that take over a defined threshold of time.

  Slow requests are logged to the primary log file, with the prefix `SLOW REQUEST`.
  Default is `-1` which disables slow request logging.

  ## Example
      iex> config = %{"log_slow_requests_time_ms" => 2_000}
      iex> ExTypesense.toggle_slow_request_log(config)

  """
  @doc since: "1.0.0"
  @spec toggle_slow_request_log(map()) ::
          {:ok, OpenApiTypesense.SuccessStatus.t()} | :error
  def toggle_slow_request_log(config) do
    Connection.new() |> toggle_slow_request_log(config)
  end

  @doc """
  Same as [toggle_slow_request_log/1](`toggle_slow_request_log/1`) but passes another connection.

  ```elixir
  ExTypesense.toggle_slow_request_log(%{api_key: xyz, host: ...}, config)
  ExTypesense.toggle_slow_request_log(ExTypesense.Connection.new(), config)
  ```
  """
  @doc since: "1.0.0"
  @spec toggle_slow_request_log(map() | OpenApiTypesense.Connection.t(), map()) ::
          {:ok, OpenApiTypesense.SuccessStatus.t()} | :error
  def toggle_slow_request_log(conn, config) do
    OpenApiTypesense.Operations.config(conn, config)
  end

  @doc """
  Triggers a follower node to initiate the raft voting process, which triggers leader re-election.

  Triggers a follower node to initiate the raft voting process, which triggers leader re-election. The follower node that you run this operation against will become the new leader, once this command succeeds.
  """
  @spec vote :: {:ok, OpenApiTypesense.SuccessStatus.t()} | :error
  def vote do
    Connection.new() |> vote()
  end

  @doc """
  Same as [vote/0](`vote/0`) but passes another connection.

  ```elixir
  ExTypesense.vote(%{api_key: xyz, host: ...})
  ExTypesense.vote(ExTypesense.Connection.new())
  ```
  """
  @spec vote(map() | OpenApiTypesense.Connection.t()) ::
          {:ok, OpenApiTypesense.SuccessStatus.t()} | :error
  def vote(conn) do
    OpenApiTypesense.Operations.vote(conn)
  end
end
