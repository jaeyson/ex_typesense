defmodule ExTypesense.Curation do
  @moduledoc since: "1.0.0"

  @moduledoc """
  While Typesense makes it really easy and intuitive to deliver
  great search results, sometimes you might want to promote
  certain documents over others. Or, you might want to exclude
  certain documents from a query's result set.

  Using overrides, you can include or exclude specific documents
  for a given query.

  More here: https://typesense.org/docs/latest/api/curation.html#create-or-update-an-override
  """

  alias OpenApiTypesense.Connection

  @doc """
  Retrieve the details of a search override, given its id.
  """
  @doc since: "1.0.0"
  @spec get_override(String.t() | module(), String.t()) ::
          {:ok, OpenApiTypesense.SearchOverride.t()} | :error
  def get_override(coll_name, override_id) do
    get_override(coll_name, override_id, [])
  end

  @doc """
  Same as [get_override/2](`get_override/2`)

  ```elixir
  ExTypesense.get_override("helmets", "custom-helmet", [])

  ExTypesense.get_override(%{api_key: xyz, host: ...}, "helmets", "custom-helmet")

  ExTypesense.get_override(OpenApiTypesense.Connection.new(), MyApp.Wearables.Helmet, "custom-helmet")
  ```
  """
  @doc since: "1.0.0"
  @spec get_override(
          map() | Connection.t() | String.t() | module(),
          String.t() | module(),
          String.t() | keyword()
        ) ::
          {:ok, OpenApiTypesense.SearchOverride.t()} | :error
  def get_override(coll_name, override_id, opts) when is_list(opts) do
    Connection.new() |> get_override(coll_name, override_id, opts)
  end

  def get_override(conn, coll_name, override_id) do
    get_override(conn, coll_name, override_id, [])
  end

  @doc """
  Same as [get_override/3](`get_override/3`) but passes another connection.

  ```elixir
  ExTypesense.get_override(%{api_key: xyz, host: ...}, "helmets", "custom-helmet", [])

  ExTypesense.get_override(OpenApiTypesense.Connection.new(), MyApp.Wearables.Helmet, "custom-helmet", [])
  ```
  """
  @doc since: "1.0.0"
  @spec get_override(
          map() | Connection.t(),
          String.t() | module(),
          String.t(),
          keyword()
        ) ::
          {:ok, OpenApiTypesense.SearchOverride.t()} | :error
  def get_override(conn, module, override_id, opts) when is_atom(module) do
    coll_name = module.__schema__(:source)
    get_override(conn, coll_name, override_id, opts)
  end

  def get_override(conn, coll_name, override_id, opts) do
    OpenApiTypesense.Override.get_search_override(conn, coll_name, override_id, opts)
  end

  @doc """
  Create or update an override to promote certain documents over
  others. Using overrides, you can include or exclude specific
  documents for a given query.

  ## Examples
      iex> body = %{
      ...>     "rule" => %{
      ...>       "query" => "Grocter and Pamble",
      ...>       "match" => "exact"
      ...>     },
      ...>     "includes" => [
      ...>       %{"id" => "2", "position" => 44},
      ...>       %{"id" => "4", "position" => 10}
      ...>     ],
      ...>     "excludes" => [
      ...>       %{"id" => "117"}
      ...>     ]
      ...> }
      iex> ExTypesense.upsert_override("companies", "cust-company", body)
  """
  @doc since: "1.0.0"
  @spec upsert_override(String.t() | module(), String.t(), map()) ::
          {:ok, OpenApiTypesense.SearchOverride.t()} | {:error, OpenApiTypesense.ApiResponse.t()}
  def upsert_override(coll_name, override_id, body) do
    upsert_override(coll_name, override_id, body, [])
  end

  @doc """
  Same as [upsert_override/3](`upsert_override/3`)

  ```elixir
  ExTypesense.upsert_override("helmets", "custom-helmet", body, [])

  ExTypesense.upsert_override(%{api_key: xyz, host: ...}, "helmets", "custom-helmet", body)

  ExTypesense.upsert_override(OpenApiTypesense.Connection.new(), MyApp.Wearables.Helmet, "custom-helmet", body)
  ```
  """
  @doc since: "1.0.0"
  @spec upsert_override(
          map() | Connection.t() | String.t() | module(),
          String.t() | module(),
          String.t() | map(),
          map() | keyword()
        ) ::
          {:ok, OpenApiTypesense.SearchOverride.t()} | {:error, OpenApiTypesense.ApiResponse.t()}
  def upsert_override(coll_name, override_id, body, opts) when is_list(opts) do
    Connection.new() |> upsert_override(coll_name, override_id, body, opts)
  end

  def upsert_override(conn, coll_name, override_id, body) do
    upsert_override(conn, coll_name, override_id, body, [])
  end

  @doc """
  Same as [upsert_override/4](`upsert_override/4`) but passes another connection.

  ```elixir
  ExTypesense.upsert_override(%{api_key: xyz, host: ...}, "helmets", "custom-helmet", body, [])

  ExTypesense.upsert_override(OpenApiTypesense.Connection.new(), MyApp.Wearables.Helmet, "custom-helmet", body, [])
  ```
  """
  @doc since: "1.0.0"
  @spec upsert_override(
          map() | Connection.t(),
          String.t() | module(),
          String.t(),
          map(),
          keyword()
        ) ::
          {:ok, OpenApiTypesense.SearchOverride.t()} | {:error, OpenApiTypesense.ApiResponse.t()}
  def upsert_override(conn, module, override_id, body, opts) when is_atom(module) do
    coll_name = module.__schema__(:source)
    upsert_override(conn, coll_name, override_id, body, opts)
  end

  def upsert_override(conn, coll_name, override_id, body, opts) do
    OpenApiTypesense.Curation.upsert_search_override(conn, coll_name, override_id, body, opts)
  end

  @doc """
  Listing all overrides associated with a given collection.

  > #### Error {: .info}
  >
  > By default, **ALL** overrides are returned, but you can use the
  > `offset` and `limit` parameters to paginate on the listing.

  ## Options

    * `limit`: Limit results in paginating on collection listing.
    * `offset`: Skip a certain number of results and start after that.

  """
  @doc since: "1.0.0"
  @spec list_overrides(String.t() | module()) ::
          {:ok, OpenApiTypesense.SearchOverridesResponse.t()} | :error
  def list_overrides(collection_name) do
    list_overrides(collection_name, [])
  end

  @doc """
  Same as [list_overrides/1](`list_overrides/1`).

  ```elixir
  ExTypesense.list_overrides("persons", limit: 10)

  ExTypesense.list_overrides(%{api_key: xyz, host: ...}, "persons")

  ExTypesense.list_overrides(OpenApiTypesense.Connection.new(), MyApp.Accounts.Person)
  ```
  """
  @doc since: "1.0.0"
  @spec list_overrides(
          map() | Connection.t() | String.t() | module(),
          String.t() | module() | keyword()
        ) ::
          {:ok, OpenApiTypesense.SearchOverridesResponse.t()} | :error
  def list_overrides(coll_name, opts) when is_list(opts) do
    Connection.new() |> list_overrides(coll_name, opts)
  end

  def list_overrides(conn, coll_name) do
    list_overrides(conn, coll_name, [])
  end

  @doc """
  Same as [list_overrides/2](`list_overrides/2`) but passes another connection.

  ```elixir
  ExTypesense.list_overrides(%{api_key: xyz, host: ...}, "persons", limit: 10)

  ExTypesense.list_overrides(OpenApiTypesense.Connection.new(), MyApp.Accounts.Person, [])
  ```
  """
  @doc since: "1.0.0"
  @spec list_overrides(map() | Connection.t(), String.t() | module(), keyword()) ::
          {:ok, OpenApiTypesense.SearchOverridesResponse.t()} | :error
  def list_overrides(conn, module, opts) when is_atom(module) do
    coll_name = module.__schema__(:source)
    list_overrides(conn, coll_name, opts)
  end

  def list_overrides(conn, coll_name, opts) do
    OpenApiTypesense.Curation.get_search_overrides(conn, coll_name, opts)
  end

  @doc """
  Delete an override associated with a collection
  """
  @doc since: "1.0.0"
  @spec delete_override(String.t() | module(), String.t()) ::
          {:ok, OpenApiTypesense.SearchOverrideDeleteResponse.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def delete_override(coll_name, override_id) do
    delete_override(coll_name, override_id, [])
  end

  @doc """
  Same as [delete_override/2](`delete_override/2`)

  ```elixir
  ExTypesense.delete_override("persons", "person-override", [])

  ExTypesense.delete_override(%{api_key: xyz, host: ...}, "persons", "person-override")

  ExTypesense.delete_override(OpenApiTypesense.Connection.new(), MyApp.Accounts.Person, "person-override")
  ```
  """
  @doc since: "1.0.0"
  @spec delete_override(
          map() | Connection.t() | String.t() | module(),
          String.t() | module(),
          String.t() | keyword()
        ) ::
          {:ok, OpenApiTypesense.SearchOverrideDeleteResponse.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def delete_override(coll_name, override_id, opts) when is_list(opts) do
    Connection.new() |> delete_override(coll_name, override_id, opts)
  end

  def delete_override(conn, coll_name, override_id) do
    delete_override(conn, coll_name, override_id, [])
  end

  @doc """
  Same as [delete_override/3](`delete_override/3`) but passes another connection.

  ```elixir
  ExTypesense.delete_override(%{api_key: xyz, host: ...}, "persons", "person-override", [])

  ExTypesense.delete_override(OpenApiTypesense.Connection.new(), MyApp.Accounts.Person, "person-override", [])
  ```
  """
  @doc since: "1.0.0"
  @spec delete_override(
          map() | Connection.t(),
          String.t() | module(),
          String.t(),
          keyword()
        ) ::
          {:ok, OpenApiTypesense.SearchOverrideDeleteResponse.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def delete_override(conn, module, override_id, opts) when is_atom(module) do
    coll_name = module.__schema__(:source)
    delete_override(conn, coll_name, override_id, opts)
  end

  def delete_override(conn, coll_name, override_id, opts) do
    OpenApiTypesense.Curation.delete_search_override(conn, coll_name, override_id, opts)
  end
end
