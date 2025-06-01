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

  ## Options

    * `conn`: The custom connection map or struct you passed

  ## Examples
      iex> conn = %{api_key: xyz, host: ...}
      iex> ExTypesense.get_override("helmets", "custom-helmet", conn: conn)

      iex> conn = OpenApiTypesense.Connection.new()
      iex> ExTypesense.get_override("helmets", "custom-helmet", conn: conn)

      iex> opts = [conn: conn]
      iex> ExTypesense.get_override(MyApp.Wearables.Helmet, "custom-helmet", opts)
  """
  @doc since: "1.0.0"
  @spec get_override(String.t() | module(), String.t(), keyword()) ::
          {:ok, OpenApiTypesense.SearchOverride.t()} | :error
  def get_override(module, override_id, opts) when is_atom(module) do
    coll_name = module.__schema__(:source)
    get_override(coll_name, override_id, opts)
  end

  def get_override(coll_name, override_id, opts) when is_binary(coll_name) do
    OpenApiTypesense.Override.get_search_override(coll_name, override_id, opts)
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

  ## Options

    * `conn`: The custom connection map or struct you passed

  ## Examples
      iex> conn = %{api_key: xyz, host: ...}
      iex> ExTypesense.upsert_override("helmets", "custom-helmet", body, conn: conn)

      iex> conn = OpenApiTypesense.Connection.new()
      iex> ExTypesense.upsert_override("helmets", "custom-helmet", body, conn: conn)

      iex> opts = [conn: conn]
      iex> ExTypesense.upsert_override(MyApp.Wearables.Helmet, "custom-helmet", body, opts)
  """
  @doc since: "1.0.0"
  @spec upsert_override(String.t() | module(), String.t(), map(), keyword()) ::
          {:ok, OpenApiTypesense.SearchOverride.t()} | {:error, OpenApiTypesense.ApiResponse.t()}
  def upsert_override(module, override_id, body, opts) when is_atom(module) do
    coll_name = module.__schema__(:source)
    upsert_override(coll_name, override_id, body, opts)
  end

  def upsert_override(coll_name, override_id, body, opts) when is_binary(coll_name) do
    OpenApiTypesense.Curation.upsert_search_override(coll_name, override_id, body, opts)
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

  ## Options

    * `conn`: The custom connection map or struct you passed

  ## Examples
      iex> conn = %{api_key: xyz, host: ...}
      iex> ExTypesense.list_overrides("persons", limit: 10, conn: conn)

      iex> conn = OpenApiTypesense.Connection.new()
      iex> ExTypesense.list_overrides("persons", conn: conn)

      iex> opts = [conn: conn]
      iex> ExTypesense.list_overrides(MyApp.Accounts.Person, opts)
  """
  @doc since: "1.0.0"
  @spec list_overrides(String.t() | module(), keyword()) ::
          {:ok, OpenApiTypesense.SearchOverridesResponse.t()} | :error
  def list_overrides(module, opts) when is_atom(module) do
    coll_name = module.__schema__(:source)
    list_overrides(coll_name, opts)
  end

  def list_overrides(coll_name, opts) when is_binary(coll_name) do
    OpenApiTypesense.Curation.get_search_overrides(coll_name, opts)
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

  ## Options

    * `conn`: The custom connection map or struct you passed

  ## Examples
      iex> conn = %{api_key: xyz, host: ...}
      iex> ExTypesense.delete_override("persons", "person-override", conn: conn)

      iex> conn = OpenApiTypesense.Connection.new()
      iex> ExTypesense.delete_override("persons", "person-override", conn: conn)

      iex> opts = [conn: conn]
      iex> ExTypesense.delete_override(MyApp.Accounts.Person, "person-override", opts)
  """
  @doc since: "1.0.0"
  @spec delete_override(String.t() | module(), String.t(), keyword()) ::
          {:ok, OpenApiTypesense.SearchOverrideDeleteResponse.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def delete_override(module, override_id, opts) when is_atom(module) do
    coll_name = module.__schema__(:source)
    delete_override(coll_name, override_id, opts)
  end

  def delete_override(coll_name, override_id, opts) when is_binary(coll_name) do
    OpenApiTypesense.Curation.delete_search_override(coll_name, override_id, opts)
  end
end
