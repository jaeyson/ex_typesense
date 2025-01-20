defmodule ExTypesense.Debug do
  @moduledoc since: "1.0.0"

  @moduledoc """
  Provides API endpoint related to debug
  """

  alias OpenApiTypesense.Connection

  @doc """
  Print debugging information
  """
  @doc since: "1.0.0"
  @spec debug :: {:ok, map()} | :error
  def debug do
    debug([])
  end

  @doc """
  Same as [debug/0](`debug/0`)

  ```elixir
  ExTypesense.debug([])

  ExTypesense.debug(%{api_key: xyz, host: ...})

  ExTypesense.debug(OpenApiTypesense.Connection.new())
  ```
  """
  @spec debug(map() | Connection.t() | keyword()) :: {:ok, map()} | :error
  def debug(opts) when is_list(opts) do
    Connection.new() |> debug()
  end

  def debug(conn) do
    debug(conn, [])
  end

  @doc """
  Same as [debug/1](`debug/1`) but passes another connection.

  ```elixir
  ExTypesense.debug(%{api_key: xyz, host: ...}, [])

  ExTypesense.debug(OpenApiTypesense.Connection.new(), [])
  ```
  """
  @spec debug(map() | Connection.t(), keyword()) :: {:ok, map()} | :error
  def debug(conn, opts) do
    OpenApiTypesense.Debug.debug(conn, opts)
  end
end
