defmodule ExTypesense.Connection do
  @moduledoc since: "0.4.0"
  @moduledoc """
  Fetches credentials either from application env or map.
  """

  alias ExTypesense.HttpClient

  @derive {Inspect, except: [:api_key]}
  defstruct [:host, :api_key, :port, :scheme]

  @typedoc since: "0.4.0"
  @type t() :: %{
          host: binary() | nil,
          api_key: binary() | nil,
          port: non_neg_integer() | nil,
          scheme: binary() | nil
        }

  @doc """
  Setting new connection or using the default config.

  > #### On using this function {: .info}
  > Functions e.g. `ExTypesense.search` don't need to explicitly pass this
  > unless you want to use another connection. See `README` for more details.
  > Also, `api_key` is hidden when invoking this function.

  ## Examples
      iex> conn = ExTypesense.Connection.new()
      %ExTypesense.Connection{
        host: "localhost",
        port: 8108,
        scheme: "http",
        ...
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
