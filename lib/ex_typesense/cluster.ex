defmodule ExTypesense.Cluster do
  @moduledoc since: "0.3.0"

  @moduledoc """
  Cluster specific operations.

  More here: https://typesense.org/docs/latest/api/cluster-operations.html
  """

  @doc """
  Get health information about a Typesense node.

  ## Examples
      iex> ExTypesense.health()
  """
  @doc since: "0.3.0"
  @spec health :: {:ok, OpenApiTypesense.HealthStatus.t()} | :error
  def health do
    health([])
  end

  @doc """
  Same as [health/0](`health/0`)

  ## Options

    * `conn`: The custom connection map or struct you passed

  ## Examples
      iex> conn = %{api_key: xyz, host: ...}
      iex> ExTypesense.health(conn: conn)

      iex> conn = OpenApiTypesense.Connection.new()
      iex> ExTypesense.health(conn: conn)

      iex> opts = [conn: conn]
      iex> ExTypesense.health(opts)
  """
  @doc since: "1.0.0"
  @spec health(keyword()) :: {:ok, OpenApiTypesense.HealthStatus.t()} | :error
  def health([]) do
    conn = OpenApiTypesense.Connection.new()
    OpenApiTypesense.Health.health(conn: conn)
  end

  def health(opts) do
    OpenApiTypesense.Health.health(opts)
  end

  @doc """
  Get stats about API endpoints.

  This endpoint returns average requests per second and
  latencies for all requests in the last 10 seconds.

  ## Examples
      iex> ExTypesense.api_stats()
  """
  @doc since: "0.3.0"
  @spec api_stats :: {:ok, OpenApiTypesense.ApiStatsResponse.t()} | :error
  def api_stats do
    api_stats([])
  end

  @doc """
  Same as [api_stats/0](`api_stats/0`)

  ## Options

    * `conn`: The custom connection map or struct you passed

  ## Examples
      iex> conn = %{api_key: xyz, host: ...}
      iex> ExTypesense.api_stats(conn: conn)

      iex> conn = OpenApiTypesense.Connection.new()
      iex> ExTypesense.api_stats(conn: conn)

      iex> opts = [conn: conn]
      iex> ExTypesense.api_stats(opts)
  """
  @doc since: "1.0.0"
  @spec api_stats(keyword()) :: {:ok, OpenApiTypesense.ApiStatsResponse.t()} | :error
  def api_stats([]) do
    conn = OpenApiTypesense.Connection.new()
    OpenApiTypesense.Operations.retrieve_api_stats(conn: conn)
  end

  def api_stats(opts) do
    OpenApiTypesense.Operations.retrieve_api_stats(opts)
  end

  @doc """
  Get current RAM, CPU, Disk & Network usage metrics.

  ## Examples
      iex> ExTypesense.cluster_metrics()
  """
  @doc since: "0.3.0"
  @spec cluster_metrics :: {:ok, map} | :error
  def cluster_metrics do
    cluster_metrics([])
  end

  @doc """
  Same as [cluster_metrics/0](`cluster_metrics/0`)

  ## Options

    * `conn`: The custom connection map or struct you passed

  ## Examples
      iex> conn = %{api_key: xyz, host: ...}
      iex> ExTypesense.cluster_metrics(conn: conn)

      iex> conn = OpenApiTypesense.Connection.new()
      iex> ExTypesense.cluster_metrics(conn: conn)

      iex> opts = [conn: conn]
      iex> ExTypesense.cluster_metrics(opts)
  """
  @doc since: "1.0.0"
  @spec cluster_metrics(keyword()) :: {:ok, map} | :error
  def cluster_metrics(opts) do
    OpenApiTypesense.Operations.retrieve_metrics(opts)
  end

  @doc """
  Creates a point-in-time snapshot of a Typesense node's state and data in the
  specified directory.

  You can then backup the snapshot directory that gets created and later restore
  it as a data directory, as needed.

  ## Options

    * `conn`: The custom connection map or struct you passed
    * `snapshot_path`: The directory on the server where the snapshot should be saved.

  ## Examples
      iex> path = "/path/to/snapshot_dir"
      iex> ExTypesense.create_snapshot(snapshot_path: path)

      iex> conn = %{api_key: xyz, host: ...}
      iex> ExTypesense.create_snapshot(snapshot_path: path, conn: conn)

      iex> conn = OpenApiTypesense.Connection.new()
      iex> ExTypesense.create_snapshot(snapshot_path: path, conn: conn)

      iex> opts = [snapshot_path: path, conn: conn]
      iex> ExTypesense.create_snapshot(opts)
  """
  @doc since: "1.0.0"
  @spec create_snapshot(keyword()) :: {:ok, OpenApiTypesense.SuccessStatus.t()} | :error
  def create_snapshot(opts) do
    OpenApiTypesense.Operations.take_snapshot(opts)
  end

  @doc """
  [Compaction](https://typesense.org/docs/latest/api/cluster-operations.html#compacting-the-on-disk-database)
  of the underlying RocksDB database.

  Typesense uses RocksDB to store your documents on the disk. If you do frequent
  writes or updates, you could benefit from running a compaction of the underlying
  RocksDB database. This could reduce the size of the database and decrease read
  latency. While the database will not block during this operation, we recommend
  running it during off-peak hours.

  ## Examples
      iex> ExTypesense.compact_db()
  """
  @doc since: "1.0.0"
  @spec compact_db :: {:ok, OpenApiTypesense.SuccessStatus.t()} | :error
  def compact_db do
    compact_db([])
  end

  @doc """
  Same as [compact_db/0](`compact_db/0`)

  ## Options

    * `conn`: The custom connection map or struct you passed

  ## Examples
      iex> conn = %{api_key: xyz, host: ...}
      iex> ExTypesense.compact_db(conn: conn)

      iex> conn = OpenApiTypesense.Connection.new()
      iex> ExTypesense.compact_db(conn: conn)

      iex> opts = [conn: conn]
      iex> ExTypesense.compact_db(opts)
  """
  @doc since: "1.0.0"
  @spec compact_db(keyword()) ::
          {:ok, OpenApiTypesense.SuccessStatus.t()} | :error
  def compact_db(opts) do
    OpenApiTypesense.Operations.compact(opts)
  end

  @doc """
  Clears the cache

  Responses of search requests that are sent with
  [`use_cache` parameter](https://typesense.org/docs/latest/api/search.html#caching-parameters)
  are cached in a LRU cache. Clears cache completely.

  ## Examples
      iex> ExTypesense.clear_cache()
  """
  @doc since: "1.0.0"
  @spec clear_cache :: {:ok, OpenApiTypesense.SuccessStatus.t()} | :error
  def clear_cache do
    clear_cache([])
  end

  @doc """
  Same as [clear_cache/0](`clear_cache/0`)

  ## Options

    * `conn`: The custom connection map or struct you passed

  ## Examples
      iex> conn = %{api_key: xyz, host: ...}
      iex> ExTypesense.clear_cache(conn: conn)

      iex> conn = OpenApiTypesense.Connection.new()
      iex> ExTypesense.clear_cache(conn: conn)

      iex> opts = [conn: conn]
      iex> ExTypesense.clear_cache(opts)
  """
  @doc since: "1.0.0"
  @spec clear_cache(keyword()) :: {:ok, OpenApiTypesense.SuccessStatus.t()} | :error
  def clear_cache(opts) do
    OpenApiTypesense.Operations.clear_cache(opts)
  end

  @doc """
  Get the status of in-progress schema change operations

  Returns the status of any ongoing schema change operations. If no schema
  changes are in progress, returns an empty response.

  ## Examples
      iex> ExTypesense.get_schema_changes()
  """
  @doc since: "1.2.0"
  @spec get_schema_changes :: {:ok, [OpenApiTypesense.SchemaChangeStatus.t()]} | :error
  def get_schema_changes do
    get_schema_changes([])
  end

  @doc """
  Same as [get_schema_changes/0](`get_schema_changes/0`) but passes another connection.

  ## Options

    * `conn`: The custom connection map or struct you passed

  ## Examples
      iex> conn = %{api_key: xyz, host: ...}
      iex> ExTypesense.get_schema_changes(conn: conn)

      iex> conn = OpenApiTypesense.Connection.new()
      iex> ExTypesense.get_schema_changes(conn: conn)

      iex> opts = [conn: conn]
      iex> ExTypesense.get_schema_changes(opts)
  """
  @doc since: "1.2.0"
  @spec get_schema_changes(keyword()) :: {:ok, [OpenApiTypesense.SchemaChangeStatus.t()]} | :error
  def get_schema_changes(opts) do
    OpenApiTypesense.Operations.get_schema_changes(opts)
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
  @spec toggle_slow_request_log(map()) :: {:ok, OpenApiTypesense.SuccessStatus.t()} | :error
  def toggle_slow_request_log(config) do
    toggle_slow_request_log(config, [])
  end

  @doc """
  Same as [toggle_slow_request_log/1](`toggle_slow_request_log/1`)

  ## Options

    * `conn`: The custom connection map or struct you passed

  ## Examples
      iex> conn = %{api_key: xyz, host: ...}
      iex> ExTypesense.toggle_slow_request_log(config, conn: conn)

      iex> conn = OpenApiTypesense.Connection.new()
      iex> ExTypesense.toggle_slow_request_log(config, conn: conn)

      iex> opts = [conn: conn]
      iex> ExTypesense.toggle_slow_request_log(config, opts)
  """
  @doc since: "1.0.0"
  @spec toggle_slow_request_log(map(), keyword()) ::
          {:ok, OpenApiTypesense.SuccessStatus.t()} | :error
  def toggle_slow_request_log(config, opts) do
    OpenApiTypesense.Operations.config(config, opts)
  end

  @doc """
  Triggers a follower node to initiate the raft voting process, which
  triggers leader re-election.

  The follower node that you run this operation against will become
  the new leader, once this command succeeds.

  ## Examples
      iex> ExTypesense.vote()
  """
  @spec vote :: {:ok, OpenApiTypesense.SuccessStatus.t()} | :error
  def vote do
    vote([])
  end

  @doc """
  Same as [vote/0](`vote/0`) but passes another connection.

  ## Options

    * `conn`: The custom connection map or struct you passed

  ## Examples
      iex> conn = %{api_key: xyz, host: ...}
      iex> ExTypesense.vote(conn: conn)

      iex> conn = OpenApiTypesense.Connection.new()
      iex> ExTypesense.vote(conn: conn)

      iex> opts = [conn: conn]
      iex> ExTypesense.vote(opts)
  """
  @spec vote(keyword()) :: {:ok, OpenApiTypesense.SuccessStatus.t()} | :error
  def vote(opts) do
    OpenApiTypesense.Operations.vote(opts)
  end
end
