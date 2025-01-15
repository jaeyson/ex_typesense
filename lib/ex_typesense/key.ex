defmodule ExTypesense.Key do
  @moduledoc since: "1.0.0"

  @moduledoc """
  Typesense allows you to create API Keys with fine-grained access
  control. You can restrict access on a per-collection, per-action,
  per-record or even per-field level or a mixture of these.

  More here: https://typesense.org/docs/latest/api/api-keys.html
  """

  alias OpenApiTypesense.Connection

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

  ```elixir
  ExTypesense.get_key(6, [])
  ExTypesense.get_key(%{api_key: xyz, host: ...}, 7)
  ExTypesense.get_key(OpenApiTypesense.Connection.new(), 8)
  ```
  """
  @doc since: "1.0.0"
  @spec get_key(map() | Connection.t() | integer(), integer() | keyword()) ::
          {:ok, OpenApiTypesense.ApiKey.t()} | {:error, OpenApiTypesense.ApiResponse.t()}
  def get_key(key_id, opts) when is_list(opts) do
    Connection.new() |> get_key(key_id, opts)
  end

  def get_key(conn, key_id) do
    get_key(conn, key_id, [])
  end

  @doc """
  Same as [get_key/2](`get_key/2`) but passes another connection.

  ```elixir
  ExTypesense.get_key(%{api_key: xyz, host: ...}, 7, [])
  ExTypesense.get_key(OpenApiTypesense.Connection.new(), 8, [])
  ```
  """
  @doc since: "1.0.0"
  @spec get_key(map() | Connection.t(), integer(), keyword()) ::
          {:ok, OpenApiTypesense.ApiKey.t()} | {:error, OpenApiTypesense.ApiResponse.t()}
  def get_key(conn, key_id, opts) do
    OpenApiTypesense.Keys.get_key(conn, key_id, opts)
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

  ```elixir
  ExTypesense.delete_key(6, [])
  ExTypesense.delete_key(%{api_key: xyz, host: ...}, 7)
  ExTypesense.delete_key(OpenApiTypesense.Connection.new(), 8)
  ```
  """
  @doc since: "1.0.0"
  @spec delete_key(map() | Connection.t() | integer(), integer() | keyword()) ::
          {:ok, OpenApiTypesense.ApiKeyDeleteResponse.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def delete_key(key_id, opts) when is_list(opts) do
    Connection.new() |> delete_key(key_id, opts)
  end

  def delete_key(conn, key_id) do
    delete_key(conn, key_id, [])
  end

  @doc """
  Same as [delete_key/2](`delete_key/2`) but passes another connection.

  ```elixir
  ExTypesense.delete_key(%{api_key: xyz, host: ...}, 7, [])
  ExTypesense.delete_key(OpenApiTypesense.Connection.new(), 8, [])
  ```
  """
  @doc since: "1.0.0"
  @spec delete_key(map() | Connection.t(), integer(), keyword()) ::
          {:ok, OpenApiTypesense.ApiKeyDeleteResponse.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def delete_key(conn, key_id, opts) do
    OpenApiTypesense.Keys.delete_key(conn, key_id, opts)
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

  ```elixir
  ExTypesense.create_key(body, [])
  ExTypesense.create_key(%{api_key: xyz, host: ...}, body)
  ExTypesense.create_key(OpenApiTypesense.Connection.new(), body)
  ```
  """
  @doc since: "1.0.0"
  @spec create_key(map() | Connection.t(), map() | keyword()) ::
          {:ok, OpenApiTypesense.ApiKey.t()} | {:error, OpenApiTypesense.ApiResponse.t()}
  def create_key(body, opts) when is_list(opts) do
    Connection.new() |> create_key(body, opts)
  end

  def create_key(conn, body) do
    create_key(conn, body, [])
  end

  @doc """
  Same as [create_key/2](`create_key/2`) but passes another connection.

  ```elixir
  ExTypesense.create_key(%{api_key: xyz, host: ...}, body, [])
  ExTypesense.create_key(OpenApiTypesense.Connection.new(), body, [])
  ```
  """
  @doc since: "1.0.0"
  @spec create_key(map() | Connection.t(), map(), keyword()) ::
          {:ok, OpenApiTypesense.ApiKey.t()} | {:error, OpenApiTypesense.ApiResponse.t()}
  def create_key(conn, body, opts) do
    OpenApiTypesense.Keys.create_key(conn, body, opts)
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

  ```elixir
  ExTypesense.list_keys([])
  ExTypesense.list_keys(%{api_key: xyz, host: ...})
  ExTypesense.list_keys(OpenApiTypesense.Connection.new())
  ```
  """
  @doc since: "1.0.0"
  @spec list_keys(map() | Connection.t() | keyword()) ::
          {:ok, OpenApiTypesense.ApiKeysResponse.t()} | :error
  def list_keys(opts) when is_list(opts) do
    Connection.new() |> list_keys(opts)
  end

  def list_keys(conn) do
    list_keys(conn, [])
  end

  @doc """
  Same as [list_keys/1](`list_keys/1`) but passes another connection.

  ```elixir
  ExTypesense.list_keys(%{api_key: xyz, host: ...}, [])
  ExTypesense.list_keys(OpenApiTypesense.Connection.new(), [])
  ```
  """
  @doc since: "1.0.0"
  @spec list_keys(map() | Connection.t() | keyword()) ::
          {:ok, OpenApiTypesense.ApiKeysResponse.t()} | :error
  def list_keys(conn, opts) do
    OpenApiTypesense.Keys.get_keys(conn, opts)
  end
end
