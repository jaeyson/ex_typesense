defmodule ExTypesense.Key do
  @moduledoc since: "1.0.0"

  @moduledoc """
  Typesense allows you to create API Keys with fine-grained access
  control. You can restrict access on a per-collection, per-action,
  per-record or even per-field level or a mixture of these.

  More here: https://typesense.org/docs/latest/api/api-keys.html
  """

  @doc """
  Retrieve (metadata about) all keys.
  """
  @doc since: "1.0.0"
  @spec get_key(integer()) ::
          {:ok, OpenApiTypesense.ApiKey.t()} | {:error, OpenApiTypesense.ApiResponse.t()}
  def get_key(key_id) do
    get_key(key_id, [])
  end

  @doc """
  Same as [get_key/1](`get_key/1`)

  ## Options

    * `conn`: The custom connection map or struct you passed

  ## Examples
      iex> conn = %{api_key: xyz, host: ...}
      iex> ExTypesense.get_key(6, conn: conn)

      iex> conn = OpenApiTypesense.Connection.new()
      iex> ExTypesense.get_key(7, conn: conn)

      iex> opts = [conn: conn]
      iex> ExTypesense.get_key(8, opts)
  """
  @doc since: "1.0.0"
  @spec get_key(integer(), keyword()) ::
          {:ok, OpenApiTypesense.ApiKey.t()} | {:error, OpenApiTypesense.ApiResponse.t()}
  def get_key(key_id, opts) do
    OpenApiTypesense.Keys.get_key(key_id, opts)
  end

  @doc """
  Delete an API key given its ID.
  """
  @doc since: "1.0.0"
  @spec delete_key(integer()) ::
          {:ok, OpenApiTypesense.ApiKeyDeleteResponse.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def delete_key(key_id) do
    delete_key(key_id, [])
  end

  @doc """
  Same as [delete_key/1](`delete_key/1`)

  ## Options

    * `conn`: The custom connection map or struct you passed

  ## Examples
      iex> conn = %{api_key: xyz, host: ...}
      iex> ExTypesense.delete_key(6, conn: conn)

      iex> conn = OpenApiTypesense.Connection.new()
      iex> ExTypesense.delete_key(7, conn: conn)

      iex> opts = [conn: conn]
      iex> ExTypesense.delete_key(8, opts)
  """
  @doc since: "1.0.0"
  @spec delete_key(integer(), keyword()) ::
          {:ok, OpenApiTypesense.ApiKeyDeleteResponse.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def delete_key(key_id, opts) do
    OpenApiTypesense.Keys.delete_key(key_id, opts)
  end

  @doc """
  Typesense allows you to create API Keys with fine-grained
  access control. You can restrict access on a per-collection,
  per-action, per-record or even per-field level or a mixture
  of these.

  ## Examples
      iex> body = %{
      ...>   actions: ["documents:search"],
      ...>   collections: ["companies"],
      ...>   description: "Search-only companies key"
      ...> }
      iex> ExTypesense.create_key(body)
  """
  @doc since: "1.0.0"
  @spec create_key(map()) ::
          {:ok, OpenApiTypesense.ApiKey.t()} | {:error, OpenApiTypesense.ApiResponse.t()}
  def create_key(body) do
    create_key(body, [])
  end

  @doc """
  Same as [create_key/1](`create_key/1`)

  ## Options

    * `conn`: The custom connection map or struct you passed

  ## Examples
      iex> conn = %{api_key: xyz, host: ...}
      iex> ExTypesense.create_key(body, conn: conn)

      iex> conn = OpenApiTypesense.Connection.new()
      iex> ExTypesense.create_key(body, conn: conn)

      iex> opts = [conn: conn]
      iex> ExTypesense.create_key(body, opts)
  """
  @doc since: "1.0.0"
  @spec create_key(map(), keyword()) ::
          {:ok, OpenApiTypesense.ApiKey.t()} | {:error, OpenApiTypesense.ApiResponse.t()}
  def create_key(body, opts) do
    OpenApiTypesense.Keys.create_key(body, opts)
  end

  @doc """
  Retrieve (metadata about) all keys.
  """
  @doc since: "1.0.0"
  @spec list_keys :: {:ok, OpenApiTypesense.ApiKeysResponse.t()} | :error
  def list_keys do
    list_keys([])
  end

  @doc """
  Same as [list_keys/0](`list_keys/0`)

  ## Options

    * `conn`: The custom connection map or struct you passed

  ## Examples
      iex> conn = %{api_key: xyz, host: ...}
      iex> ExTypesense.list_keys(conn: conn)

      iex> conn = OpenApiTypesense.Connection.new()
      iex> ExTypesense.list_keys(conn: conn)

      iex> opts = [conn: conn]
      iex> ExTypesense.list_keys(opts)
  """
  @doc since: "1.0.0"
  @spec list_keys(keyword()) ::
          {:ok, OpenApiTypesense.ApiKeysResponse.t()} | :error
  def list_keys(opts) do
    OpenApiTypesense.Keys.get_keys(opts)
  end
end
