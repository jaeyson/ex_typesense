defmodule ExTypesense.Cluster do
  @moduledoc since: "0.3.0"

  @moduledoc """
  Cluster specific operations.

  More here: https://typesense.org/docs/latest/api/cluster-operations.html
  """

  alias OpenApiTypesense.Connection

  @doc """
  Get health information about a Typesense node.
  """
  @doc since: "0.3.0"
  @spec health :: {:ok, OpenApiTypesense.HealthStatus.t()} | :error
  def health do
    health([])
  end

  @doc """
  Same as [health/0](`health/0`)

  ```elixir
  ExTypesense.health([])

  ExTypesense.health(%{api_key: xyz, host: ...})

  ExTypesense.health(OpenApiTypesense.Connection.new())
  ```
  """
  @doc since: "1.0.0"
  @spec health(map() | Connection.t() | keyword()) ::
          {:ok, OpenApiTypesense.HealthStatus.t()} | :error
  def health(opts) when is_list(opts) do
    Connection.new() |> health(opts)
  end

  def health(conn) do
    health(conn, [])
  end

  @doc """
  Same as [health/1](`health/1`) but passes another connection.

  ```elixir
  ExTypesense.health(%{api_key: xyz, host: ...}, [])

  ExTypesense.health(OpenApiTypesense.Connection.new(), [])
  ```
  """
  @doc since: "1.0.0"
  @spec health(map() | Connection.t(), keyword()) ::
          {:ok, OpenApiTypesense.HealthStatus.t()} | :error
  def health(conn, opts) do
    OpenApiTypesense.Health.health(conn, opts)
  end

  @doc """
  Get stats about API endpoints.

  This endpoint returns average requests per second and
  latencies for all requests in the last 10 seconds.
  """
  @doc since: "0.3.0"
  @spec api_stats :: {:ok, OpenApiTypesense.ApiStatsResponse.t()} | :error
  def api_stats do
    api_stats([])
  end

  @doc """
  Same as [api_stats/0](`api_stats/0`)

  ```elixir
  ExTypesense.api_stats([])

  ExTypesense.api_stats(%{api_key: xyz, host: ...})

  ExTypesense.api_stats(OpenApiTypesense.Connection.new())
  ```
  """
  @doc since: "1.0.0"
  @spec api_stats(map() | Connection.t() | keyword()) ::
          {:ok, OpenApiTypesense.ApiStatsResponse.t()} | :error
  def api_stats(opts) when is_list(opts) do
    Connection.new() |> api_stats(opts)
  end

  def api_stats(conn) do
    api_stats(conn, [])
  end

  @doc """
  Same as [api_stats/1](`api_stats/1`) but passes another connection.

  ```elixir
  ExTypesense.api_stats(%{api_key: xyz, host: ...}, [])

  ExTypesense.api_stats(OpenApiTypesense.Connection.new(), [])
  ```
  """
  @doc since: "1.0.0"
  @spec api_stats(map() | Connection.t(), keyword()) ::
          {:ok, OpenApiTypesense.ApiStatsResponse.t()} | :error
  def api_stats(conn, opts) do
    OpenApiTypesense.Operations.retrieve_api_stats(conn, opts)
  end

  @doc """
  Get current RAM, CPU, Disk & Network usage metrics.
  """
  @doc since: "0.3.0"
  @spec cluster_metrics :: {:ok, map} | :error
  def cluster_metrics do
    cluster_metrics([])
  end

  @doc """
  Same as [cluster_metrics/0](`cluster_metrics/0`)

  ```elixir
  ExTypesense.cluster_metrics([])

  ExTypesense.cluster_metrics(%{api_key: xyz, host: ...})

  ExTypesense.cluster_metrics(OpenApiTypesense.Connection.new())
  ```
  """
  @doc since: "1.0.0"
  @spec cluster_metrics(map() | Connection.t() | keyword()) :: {:ok, map} | :error
  def cluster_metrics(opts) when is_list(opts) do
    Connection.new() |> cluster_metrics(opts)
  end

  def cluster_metrics(conn) do
    cluster_metrics(conn, [])
  end

  @doc """
  Same as [cluster_metrics/1](`cluster_metrics/1`) but passes another connection.

  ```elixir
  ExTypesense.cluster_metrics(%{api_key: xyz, host: ...}, [])

  ExTypesense.cluster_metrics(OpenApiTypesense.Connection.new(), [])
  ```
  """
  @doc since: "1.0.0"
  @spec cluster_metrics(map() | Connection.t(), keyword()) :: {:ok, map} | :error
  def cluster_metrics(conn, opts) do
    OpenApiTypesense.Operations.retrieve_metrics(conn, opts)
  end

  @doc """
  Creates a point-in-time snapshot of a Typesense node's state and data in the
  specified directory.

  You can then backup the snapshot directory that gets created and later restore
  it as a data directory, as needed.

  ## Options

    * `snapshot_path`: The directory on the server where the snapshot should be saved.

  """
  @doc since: "1.0.0"
  @spec create_snapshot(keyword()) ::
          {:ok, OpenApiTypesense.SuccessStatus.t()} | :error
  def create_snapshot(opts) when is_list(opts) do
    Connection.new() |> create_snapshot(opts)
  end

  @doc """
  Same as [create_snapshot/1](`create_snapshot/1`) but passes another connection.

  ```elixir
  ExTypesense.create_snapshot(%{api_key: xyz, host: ...}, snapshot_path: "/tmp/typesense-data-snapshot")

  ExTypesense.create_snapshot(OpenApiTypesense.Connection.new(), snapshot_path: "/tmp/typesense-data-snapshot")
  ```
  """
  @doc since: "1.0.0"
  @spec create_snapshot(map() | Connection.t(), keyword()) ::
          {:ok, OpenApiTypesense.SuccessStatus.t()} | :error
  def create_snapshot(conn, opts) do
    OpenApiTypesense.Operations.take_snapshot(conn, opts)
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
    compact_db([])
  end

  @doc """
  Same as [compact_db/0](`compact_db/0`)

  ```elixir
  ExTypesense.compact_db([])

  ExTypesense.compact_db(%{api_key: xyz, host: ...})

  ExTypesense.compact_db(OpenApiTypesense.Connection.new())
  ```
  """
  @doc since: "1.0.0"
  @spec compact_db(map() | Connection.t() | keyword()) ::
          {:ok, OpenApiTypesense.SuccessStatus.t()} | :error
  def compact_db(opts) when is_list(opts) do
    Connection.new() |> compact_db(opts)
  end

  def compact_db(conn) do
    compact_db(conn, [])
  end

  @doc """
  Same as [compact_db/1](`compact_db/1`) but passes another connection.

  ```elixir
  ExTypesense.compact_db(%{api_key: xyz, host: ...}, [])

  ExTypesense.compact_db(OpenApiTypesense.Connection.new(), [])
  ```
  """
  @doc since: "1.0.0"
  @spec compact_db(map() | Connection.t(), keyword()) ::
          {:ok, OpenApiTypesense.SuccessStatus.t()} | :error
  def compact_db(conn, opts) do
    OpenApiTypesense.Operations.compact(conn, opts)
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
    clear_cache([])
  end

  @doc """
  Same as [clear_cache/0](`clear_cache/0`)

  ```elixir
  ExTypesense.clear_cache([])

  ExTypesense.clear_cache(%{api_key: xyz, host: ...})

  ExTypesense.clear_cache(OpenApiTypesense.Connection.new())
  ```
  """
  @doc since: "1.0.0"
  @spec clear_cache(map() | Connection.t() | keyword()) ::
          {:ok, OpenApiTypesense.SuccessStatus.t()} | :error
  def clear_cache(opts) when is_list(opts) do
    Connection.new() |> clear_cache(opts)
  end

  def clear_cache(conn) do
    clear_cache(conn, [])
  end

  @doc """
  Same as [clear_cache/1](`clear_cache/1`) but passes another connection.

  ```elixir
  ExTypesense.clear_cache(%{api_key: xyz, host: ...}, [])

  ExTypesense.clear_cache(OpenApiTypesense.Connection.new(), [])
  ```
  """
  @doc since: "1.0.0"
  @spec clear_cache(map() | Connection.t(), keyword()) ::
          {:ok, OpenApiTypesense.SuccessStatus.t()} | :error
  def clear_cache(conn, opts) do
    OpenApiTypesense.Operations.clear_cache(conn, opts)
  end

  @doc """
  Get the status of in-progress schema change operations

  Returns the status of any ongoing schema change operations. If no schema
  changes are in progress, returns an empty response.
  """
  @doc since: "1.2.0"
  @spec get_schema_changes :: {:ok, [OpenApiTypesense.SchemaChangeStatus.t()]} | :error
  def get_schema_changes do
    get_schema_changes([])
  end

  @doc """
  Same as [get_schema_changes/0](`get_schema_changes/0`) but passes another connection.

  ```elixir
  ExTypesense.get_schema_changes([])

  ExTypesense.get_schema_changes(%{api_key: xyz, host: ...})

  ExTypesense.get_schema_changes(OpenApiTypesense.Connection.new())
  ```
  """
  @doc since: "1.2.0"
  @spec get_schema_changes(map() | Connection.t() | keyword()) ::
          {:ok, [OpenApiTypesense.SchemaChangeStatus.t()]} | :error
  def get_schema_changes(opts) when is_list(opts) do
    Connection.new() |> get_schema_changes(opts)
  end

  def get_schema_changes(conn) do
    get_schema_changes(conn, [])
  end

  @doc """
  Same as [get_schema_changes/1](`get_schema_changes/1`) but passes another connection.

  ```elixir
  ExTypesense.get_schema_changes(%{api_key: xyz, host: ...}, [])

  ExTypesense.get_schema_changes(OpenApiTypesense.Connection.new(), [])
  ```
  """
  @doc since: "1.2.0"
  @spec get_schema_changes(map() | Connection.t(), keyword()) ::
          {:ok, [OpenApiTypesense.SchemaChangeStatus.t()]} | :error
  def get_schema_changes(conn, opts) do
    OpenApiTypesense.Operations.get_schema_changes(conn, opts)
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
    toggle_slow_request_log(config, [])
  end

  @doc """
  Same as [toggle_slow_request_log/1](`toggle_slow_request_log/1`)

  ```elixir
  ExTypesense.toggle_slow_request_log(config, [])

  ExTypesense.toggle_slow_request_log(%{api_key: xyz, host: ...}, config)

  ExTypesense.toggle_slow_request_log(OpenApiTypesense.Connection.new(), config)
  ```
  """
  @doc since: "1.0.0"
  @spec toggle_slow_request_log(map() | Connection.t(), map() | keyword()) ::
          {:ok, OpenApiTypesense.SuccessStatus.t()} | :error
  def toggle_slow_request_log(config, opts) when is_list(opts) do
    Connection.new() |> toggle_slow_request_log(config, opts)
  end

  def toggle_slow_request_log(conn, config) do
    toggle_slow_request_log(conn, config, [])
  end

  @doc """
  Same as [toggle_slow_request_log/2](`toggle_slow_request_log/2`) but passes another connection.

  ```elixir
  ExTypesense.toggle_slow_request_log(%{api_key: xyz, host: ...}, config, [])

  ExTypesense.toggle_slow_request_log(OpenApiTypesense.Connection.new(), config, [])
  ```
  """
  @doc since: "1.0.0"
  @spec toggle_slow_request_log(map() | Connection.t(), map(), keyword()) ::
          {:ok, OpenApiTypesense.SuccessStatus.t()} | :error
  def toggle_slow_request_log(conn, config, opts) do
    OpenApiTypesense.Operations.config(conn, config, opts)
  end

  @doc """
  Triggers a follower node to initiate the raft voting process, which
  triggers leader re-election.

  The follower node that you run this operation against will become
  the new leader, once this command succeeds.
  """
  @spec vote :: {:ok, OpenApiTypesense.SuccessStatus.t()} | :error
  def vote do
    vote([])
  end

  @doc """
  Same as [vote/0](`vote/0`) but passes another connection.

  ```elixir
  ExTypesense.vote([])

  ExTypesense.vote(%{api_key: xyz, host: ...})

  ExTypesense.vote(OpenApiTypesense.Connection.new())
  ```
  """
  @spec vote(map() | Connection.t() | keyword()) ::
          {:ok, OpenApiTypesense.SuccessStatus.t()} | :error
  def vote(opts) when is_list(opts) do
    Connection.new() |> vote(opts)
  end

  def vote(conn) do
    vote(conn, [])
  end

  @doc """
  Same as [vote/1](`vote/1`) but passes another connection.

  ```elixir
  ExTypesense.vote(%{api_key: xyz, host: ...}, [])

  ExTypesense.vote(OpenApiTypesense.Connection.new(), [])
  ```
  """
  @spec vote(map() | Connection.t(), keyword()) ::
          {:ok, OpenApiTypesense.SuccessStatus.t()} | :error
  def vote(conn, opts) do
    OpenApiTypesense.Operations.vote(conn, opts)
  end
end
