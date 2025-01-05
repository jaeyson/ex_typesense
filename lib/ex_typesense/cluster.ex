defmodule ExTypesense.Cluster do
  @moduledoc since: "0.3.0"
  @moduledoc """
  Cluster specific operations.
  """

  @doc """
  Get health information about a Typesense node.
  """
  @doc since: "0.3.0"
  @spec health :: {:ok, OpenApiTypesense.HealthStatus.t()} | :error
  def health do
    ExTypesense.Connection.new() |> health()
  end

  @doc since: "0.8.0"
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
    ExTypesense.Connection.new() |> api_stats()
  end

  @doc since: "0.8.0"
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
    ExTypesense.Connection.new() |> cluster_metrics()
  end

  @doc since: "0.8.0"
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
  @doc since: "0.8.0"
  @spec create_snapshot(String.t()) ::
          {:ok, OpenApiTypesense.SuccessStatus.t()} | :error
  def create_snapshot(snapshot_path) do
    ExTypesense.Connection.new() |> create_snapshot(snapshot_path)
  end

  @doc since: "0.8.0"
  @spec create_snapshot(String.t()) ::
          {:ok, OpenApiTypesense.SuccessStatus.t()} | :error
  def create_snapshot(conn, snapshot_path) do
    OpenApiTypesense.Operations.take_snapshot(conn, snapshot_path: snapshot_path)
  end
end
