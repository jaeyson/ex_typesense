defmodule ExTypesense.Cluster do
  @moduledoc since: "0.3.0"
  @moduledoc """
  Cluster specific operations.
  """

  alias ExTypesense.Connection
  alias ExTypesense.HttpClient

  @typedoc since: "0.3.0"
  @type response() :: any() | {:ok, any()} | {:error, map()}

  @doc """
  Get health information about a Typesense node.
  """
  @doc since: "0.3.0"
  @spec health(Connection.t()) :: response()
  def health(conn \\ Connection.new()) do
    case HttpClient.request(conn, %{method: :get, path: "/health"}) do
      {:ok, %{"ok" => true}} ->
        {:ok, true}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Get stats about API endpoints.

  This endpoint returns average requests per second and latencies for all requests in the last 10 seconds.
  """
  @doc since: "0.3.0"
  @spec api_stats(Connection.t()) :: response()
  def api_stats(connection \\ Connection.new()) do
    HttpClient.request(connection, %{method: :get, path: "/stats.json"})
  end

  @doc """
  Get current RAM, CPU, Disk & Network usage metrics.
  """
  @doc since: "0.3.0"
  @spec cluster_metrics(Connection.t()) :: response()
  def cluster_metrics(connection \\ Connection.new()) do
    HttpClient.request(connection, %{method: :get, path: "/metrics.json"})
  end
end
