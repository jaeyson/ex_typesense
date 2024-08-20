defmodule OpenApiTypesense.Health do
  @moduledoc """
  Provides API endpoint related to health
  """

  @default_client OpenApiTypesense.Client

  @doc """
  Checks if Typesense server is ready to accept requests.

  Checks if Typesense server is ready to accept requests.
  """
  @spec health(keyword) :: {:ok, OpenApiTypesense.HealthStatus.t()} | :error
  def health(opts \\ []) do
    client = opts[:client] || @default_client

    client.request(%{
      args: [],
      call: {OpenApiTypesense.Health, :health},
      url: "/health",
      method: :get,
      response: [{200, {OpenApiTypesense.HealthStatus, :t}}],
      opts: opts
    })
  end
end
