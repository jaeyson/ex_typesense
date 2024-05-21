defmodule ExTypesense.Connection do
  @derive {Inspect, except: [:api_key]}
  defstruct host: ExTypesense.HttpClient.get_host(),
            api_key: ExTypesense.HttpClient.api_key(),
            port: ExTypesense.HttpClient.get_port(),
            scheme: ExTypesense.HttpClient.get_scheme()

  @type t() :: %__MODULE__{}

  @spec new(connection :: struct()) :: ExTypesense.Connection.t()
  def new(connection \\ %__MODULE__{}) when is_struct(connection) do
    %__MODULE__{
      host: Map.get(connection, :host),
      api_key: Map.get(connection, :api_key),
      port: Map.get(connection, :port),
      scheme: Map.get(connection, :scheme)
    }
  end
end
