defmodule ExTypesense.Connection do
  @moduledoc since: "0.4.0"
  @moduledoc """
  Fetches credentials either from application env or map.
  """

  alias ExTypesense.HttpClient

  defstruct [:host, :api_key, :port, :scheme]

  @typedoc since: "0.4.0"
  @type t() :: %{
          host: binary() | nil,
          api_key: binary() | nil,
          port: non_neg_integer() | nil,
          scheme: binary() | nil
        }

  @doc """
  Fetches credentials either from application env or map.

  ## Examples

  Using the default credential from local development Typesense instance:

      iex> conn = ExTypesense.Connection.new()
      %ExTypesense.Connection{
        host: "localhost",
        api_key: "xyz",
        port: 8108,
        scheme: "http"
      }

  """
  @doc since: "0.4.0"
  @spec new(connection :: t() | map()) :: ExTypesense.Connection.t()
  def new(connection \\ defaults()) when is_map(connection) do
    %ExTypesense.Connection{
      host: Map.get(connection, :host),
      api_key: Map.get(connection, :api_key),
      port: Map.get(connection, :port),
      scheme: Map.get(connection, :scheme)
    }
  end

  @doc since: "0.4.3"
  @spec defaults :: map()
  defp defaults do
    %{
      host: HttpClient.get_host(),
      api_key: HttpClient.api_key(),
      port: HttpClient.get_port(),
      scheme: HttpClient.get_scheme()
    }
  end
end
