defmodule ExTypesense.Connection do
  @moduledoc since: "0.4.0"
  @moduledoc """
  Fetches credentials either from application env or map.
  """

  @doc since: "0.8.0"
  @spec get_host :: String.t() | nil
  def get_host, do: Application.get_env(:ex_typesense, :host)

  @doc since: "0.8.0"
  @spec get_options :: Keyword.t()
  def get_options, do: Application.get_env(:ex_typesense, :options, %{})

  @doc since: "0.8.0"
  @spec get_scheme :: String.t() | nil
  def get_scheme, do: Application.get_env(:ex_typesense, :scheme)

  @doc since: "0.8.0"
  @spec get_port :: non_neg_integer() | nil
  def get_port do
    Application.get_env(:ex_typesense, :port)
  end

  @doc """
  Returns the Typesense's API key

  > #### Warning {: .warning}
  >
  > Even if `api_key` is hidden in `Connection` struct, this
  > function will still return the key and accessible inside
  > shell (assuming bad actors [pun unintended `:/`] can get in as well).
  """
  @doc since: "0.8.0"
  @spec api_key :: String.t() | nil
  def api_key, do: Application.get_env(:ex_typesense, :api_key)

  @doc """
  Setting new connection or using the default config.

  > #### On using this function {: .info}
  > Functions e.g. `ExTypesense.search` don't need to explicitly pass this
  > unless you want to use another connection. See `README` for more details.
  > Also, `api_key` is hidden when invoking this function.

  ## Examples
      iex> conn = ExTypesense.Connection.new()
      %OpenApiTypesense.Connection{
        host: "localhost",
        port: 8108,
        scheme: "http",
        ...
      }
  """

  @doc since: "0.4.0"
  @spec new(connection :: map()) :: OpenApiTypesense.Connection.t()
  def new(connection \\ defaults()) when is_map(connection) do
    OpenApiTypesense.Connection.new(connection)
  end

  @doc since: "0.4.3"
  @spec defaults :: map()
  defp defaults do
    %{
      host: get_host(),
      api_key: api_key(),
      port: get_port(),
      scheme: get_scheme()
    }
  end
end
