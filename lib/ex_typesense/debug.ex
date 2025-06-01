defmodule ExTypesense.Debug do
  @moduledoc since: "1.0.0"

  @moduledoc """
  Provides API endpoint related to debug
  """

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

  ## Options

    * `conn`: The custom connection map or struct you passed

  ## Examples
      iex> conn = %{api_key: xyz, host: ...}
      iex> ExTypesense.debug(conn: conn)

      iex> conn = OpenApiTypesense.Connection.new()
      iex> ExTypesense.debug(conn: conn)

      iex> opts = [conn: conn]
      iex> ExTypesense.debug(opts)
  """
  @spec debug(keyword()) :: {:ok, map()} | :error
  def debug(opts) do
    OpenApiTypesense.Debug.debug(opts)
  end
end
