defmodule ExTypesense.Cluster do
  @moduledoc since: "0.4.0"
  @moduledoc """
  Cluster specific operations.
  """

  alias ExTypesense.HttpClient

  @type response() :: any() | {:ok, any()} | {:error, map()}

  @doc """
  Get health information about a Typesense node.
  """
  @doc since: "0.4.0"
  @spec health :: response()
  def health do
    case HttpClient.run(:get, "/health") do
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
  @doc since: "0.4.0"
  @spec api_stats :: response()
  def api_stats do
    HttpClient.run(:get, "/stats.json")
  end

  @doc """
  Get current RAM, CPU, Disk & Network usage metrics.
  """
  @doc since: "0.4.0"
  @spec cluster_metrics :: response()
  def cluster_metrics do
    HttpClient.run(:get, "/metrics.json")
  end
end
