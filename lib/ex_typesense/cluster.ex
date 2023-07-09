defmodule ExTypesense.Cluster do
  alias ExTypesense.HttpClient

  @moduledoc """
  Cluster specific operations.
  """

  @type response() :: any() | {:ok, any()} | {:error, map()}

  @doc """
  Get health information about a Typesense node.
  """
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
  @spec api_stats :: response()
  def api_stats do
    HttpClient.run(:get, "/stats.json")
  end

  @doc """
  Get current RAM, CPU, Disk & Network usage metrics.
  """
  @spec cluster_metrics :: response()
  def cluster_metrics do
    HttpClient.run(:get, "/metrics.json")
  end
end
