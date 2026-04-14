defmodule ExTypesense.Synonym do
  @moduledoc since: "1.0.0"

  @moduledoc """
  The synonyms feature allows you to define search terms that should
  be considered equivalent. For eg: when you define a synonym for
  `sneaker` as `shoe`, searching for `sneaker` will now return all records
  with the word `shoe` in them, in addition to records with the word `sneaker`.

  More here: https://typesense.org/docs/latest/api/synonyms.html
  """

  @doc """
  List all synonyms associated with a given collection.

  > #### Error {: .info}
  >
  > By default, **ALL** synonyms are returned, but you can use the
  > `offset` and `limit` parameters to paginate on the listing.

  ## Options

    * `limit`: Limit results in paginating on collection listing.
    * `offset`: Skip a certain number of results and start after that.

  """
  @doc since: "1.0.0"
  @deprecated "Please use `retrieve_synonym_set_items` or `retrieve_synonym_sets` when using Typesense v30.0+"
  @spec list_synonyms(String.t() | module()) ::
          {:ok, OpenApiTypesense.SearchSynonymsResponse.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def list_synonyms(collection_name) do
    list_synonyms(collection_name, [])
  end

  @doc """
  Same as [list_synonyms/1](`list_synonyms/1`).

  ## Options

    * `conn`: The custom connection map or struct you passed

  ## Examples
      iex> conn = %{api_key: xyz, host: ...}
      iex> ExTypesense.list_synonyms("persons", conn: conn)

      iex> conn = OpenApiTypesense.Connection.new()
      iex> ExTypesense.list_synonyms("persons", conn: conn)

      iex> opts = [conn: conn]
      iex> ExTypesense.list_synonyms(MyApp.Accounts.Person, opts)
  """
  @doc since: "1.0.0"
  @deprecated "Please use `retrieve_synonym_set_items` or `retrieve_synonym_sets` when using Typesense v30.0+"
  @spec list_synonyms(String.t() | module(), keyword()) ::
          {:ok, OpenApiTypesense.SearchSynonymsResponse.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def list_synonyms(module, opts) when is_atom(module) do
    coll_name = module.__schema__(:source)
    list_synonyms(coll_name, opts)
  end

  def list_synonyms(coll_name, opts) when is_binary(coll_name) do
    OpenApiTypesense.Synonyms.get_search_synonyms(coll_name, opts)
  end

  @doc """
  List all synonym sets

  Retrieve all synonym sets
  """
  @doc since: "2.2.0"
  @spec retrieve_synonym_sets ::
          {:ok, [OpenApiTypesense.SynonymSetSchema.t()]} | :error
  def retrieve_synonym_sets do
    retrieve_synonym_sets([])
  end

  @doc """
  Same as [retrieve_synonym_sets/0](`retrieve_synonym_sets/0`).

  ## Options

    * `conn`: The custom connection map or struct you passed

  """
  @doc since: "2.2.0"
  @spec retrieve_synonym_sets(opts :: keyword) ::
          {:ok, [OpenApiTypesense.SynonymSetSchema.t()]} | :error
  def retrieve_synonym_sets(opts) do
    OpenApiTypesense.Synonyms.retrieve_synonym_sets(opts)
  end

  @doc """
  List items in a synonym set

  Retrieve all synonym items in a set
  """
  @doc since: "2.2.0"
  @spec retrieve_synonym_set_items(synonym_set_name :: String.t()) ::
          {:ok, [OpenApiTypesense.SynonymItemSchema.t()]}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def retrieve_synonym_set_items(synonym_set_name) do
    retrieve_synonym_set_items(synonym_set_name, [])
  end

  @doc """
  Same as [retrieve_synonym_set_items/1](`retrieve_synonym_set_items/1`).

  ## Options

    * `conn`: The custom connection map or struct you passed

  """
  @doc since: "2.2.0"
  @spec retrieve_synonym_set_items(synonym_set_name :: String.t(), opts :: keyword) ::
          {:ok, [OpenApiTypesense.SynonymItemSchema.t()]}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def retrieve_synonym_set_items(synonym_set_name, opts) do
    OpenApiTypesense.Synonyms.retrieve_synonym_set_items(synonym_set_name, opts)
  end

  @doc """
  Retrieve a single synonym from a collection.
  """
  @doc since: "1.0.0"
  @deprecated "Please use `retrieve_synonym_set` or `retrieve_synonym_set_item` when using Typesense v30.0+"
  @spec get_synonym(String.t() | module(), String.t()) ::
          {:ok, OpenApiTypesense.SearchSynonym.t()} | {:error, OpenApiTypesense.ApiResponse.t()}
  def get_synonym(coll_name, syn_id) do
    get_synonym(coll_name, syn_id, [])
  end

  @doc """
  Same as [get_synonym/2](`get_synonym/2`).

  ## Options

    * `conn`: The custom connection map or struct you passed

  ## Examples
      iex> conn = %{api_key: xyz, host: ...}
      iex> ExTypesense.get_synonym("cars", "sedan-synonym", conn: conn)

      iex> conn = OpenApiTypesense.Connection.new()
      iex> ExTypesense.get_synonym("cars", "sedan-synonym", conn: conn)

      iex> opts = [conn: conn]
      iex> ExTypesense.get_synonym(MyApp.Vehicle.Car, "sedan-synonym", opts)
  """
  @doc since: "1.0.0"
  @deprecated "Please use `retrieve_synonym_set` or `retrieve_synonym_set_item` when using Typesense v30.0+"
  @spec get_synonym(String.t() | module(), String.t(), keyword()) ::
          {:ok, OpenApiTypesense.SearchSynonym.t()} | {:error, OpenApiTypesense.ApiResponse.t()}
  def get_synonym(module, syn_id, opts) when is_atom(module) do
    coll_name = module.__schema__(:source)
    get_synonym(coll_name, syn_id, opts)
  end

  def get_synonym(coll_name, syn_id, opts) when is_binary(coll_name) do
    OpenApiTypesense.Synonyms.get_search_synonym(coll_name, syn_id, opts)
  end

  @doc """
  Retrieve a synonym set

  Retrieve a specific synonym set by its name
  """
  @doc since: "2.2.0"
  @spec retrieve_synonym_set(synonym_set_name :: String.t()) ::
          {:ok, OpenApiTypesense.SynonymSetSchema.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def retrieve_synonym_set(synonym_set_name) do
    retrieve_synonym_set(synonym_set_name, [])
  end

  @doc """
  Same as [retrieve_synonym_set/1](`retrieve_synonym_set/1`).

  ## Options

    * `conn`: The custom connection map or struct you passed

  """
  @doc since: "2.2.0"
  @spec retrieve_synonym_set(synonym_set_name :: String.t(), opts :: keyword) ::
          {:ok, OpenApiTypesense.SynonymSetSchema.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def retrieve_synonym_set(synonym_set_name, opts) do
    OpenApiTypesense.Synonyms.retrieve_synonym_set(synonym_set_name, opts)
  end

  @doc """
  Retrieve a synonym set item

  Retrieve a specific synonym item by its id
  """
  @doc since: "2.2.0"
  @spec retrieve_synonym_set_item(
          synonym_set_name :: String.t(),
          item_id :: String.t()
        ) ::
          {:ok, OpenApiTypesense.SynonymItemSchema.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def retrieve_synonym_set_item(synonym_set_name, item_id) do
    retrieve_synonym_set_item(synonym_set_name, item_id, [])
  end

  @doc """
  Same as [retrieve_synonym_set_item/2](`retrieve_synonym_set_item/2`).

  ## Options

    * `conn`: The custom connection map or struct you passed

  """
  @doc since: "2.2.0"
  @spec retrieve_synonym_set_item(
          synonym_set_name :: String.t(),
          item_id :: String.t(),
          opts :: keyword
        ) ::
          {:ok, OpenApiTypesense.SynonymItemSchema.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def retrieve_synonym_set_item(synonym_set_name, item_id, opts) do
    OpenApiTypesense.Synonyms.retrieve_synonym_set_item(synonym_set_name, item_id, opts)
  end

  @doc """
  Delete a single synonym from a collection.
  """
  @doc since: "1.0.0"
  @deprecated "Please use `delete_synonym_set` or `delete_synonym_set_item` when using Typesense v30.0+"
  @spec delete_synonym(String.t() | module(), String.t()) ::
          {:ok, OpenApiTypesense.SearchSynonymDeleteResponse.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def delete_synonym(coll_name, syn_id) do
    delete_synonym(coll_name, syn_id, [])
  end

  @doc """
  Same as [delete_synonym/2](`delete_synonym/2`).

  ## Options

    * `conn`: The custom connection map or struct you passed

  ## Examples
      iex> conn = %{api_key: xyz, host: ...}
      iex> ExTypesense.delete_synonym("cars", "sedan-synonym", conn: conn)

      iex> conn = OpenApiTypesense.Connection.new()
      iex> ExTypesense.delete_synonym("cars", "sedan-synonym", conn: conn)

      iex> opts = [conn: conn]
      iex> ExTypesense.delete_synonym(MyApp.Vehicle.Car, "sedan-synonym", opts)
  """
  @doc since: "1.0.0"
  @deprecated "Please use `delete_synonym_set` or `delete_synonym_set_item` when using Typesense v30.0+"
  @spec delete_synonym(String.t() | module(), String.t(), keyword()) ::
          {:ok, OpenApiTypesense.SearchSynonymDeleteResponse.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def delete_synonym(module, syn_id, opts) when is_atom(module) do
    coll_name = module.__schema__(:source)
    delete_synonym(coll_name, syn_id, opts)
  end

  def delete_synonym(coll_name, syn_id, opts) when is_binary(coll_name) do
    OpenApiTypesense.Synonyms.delete_search_synonym(coll_name, syn_id, opts)
  end

  @doc """
  Delete a synonym set

  Delete a specific synonym set by its name
  """
  @doc since: "2.2.0"
  @spec delete_synonym_set(synonym_set_name :: String.t()) ::
          {:ok, OpenApiTypesense.SynonymSetDeleteSchema.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def delete_synonym_set(synonym_set_name) do
    delete_synonym_set(synonym_set_name, [])
  end

  @doc """
  Delete a synonym set

  Delete a specific synonym set by its name
  """
  @doc since: "2.2.0"
  @spec delete_synonym_set(synonym_set_name :: String.t(), opts :: keyword) ::
          {:ok, OpenApiTypesense.SynonymSetDeleteSchema.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def delete_synonym_set(synonym_set_name, opts) do
    OpenApiTypesense.Synonyms.delete_synonym_set(synonym_set_name, opts)
  end

  @doc """
  Delete a synonym set item

  Delete a specific synonym item by its id
  """
  @doc since: "2.2.0"
  @spec delete_synonym_set_item(
          synonym_set_name :: String.t(),
          item_id :: String.t()
        ) ::
          {:ok, OpenApiTypesense.SynonymItemDeleteSchema.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def delete_synonym_set_item(synonym_set_name, item_id) do
    delete_synonym_set_item(synonym_set_name, item_id, [])
  end

  @doc """
  Same as [delete_synonym_set/2](`delete_synonym_set/2`).

  ## Options

    * `conn`: The custom connection map or struct you passed

  """
  @doc since: "2.2.0"
  @spec delete_synonym_set_item(
          synonym_set_name :: String.t(),
          item_id :: String.t(),
          opts :: keyword
        ) ::
          {:ok, OpenApiTypesense.SynonymItemDeleteSchema.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def delete_synonym_set_item(synonym_set_name, item_id, opts) do
    OpenApiTypesense.Synonyms.delete_synonym_set_item(synonym_set_name, item_id, opts)
  end

  @doc """
  Create or update a synonym

  ## Examples
      iex> body = %{
      ...>   "synonyms" => ["blazer", "coat", "jacket"],
      ...> }

      iex> ExTypesense.upsert_synonym("products", "coat-synonyms", body)
  """
  @doc since: "1.0.0"
  @deprecated "Please use `upsert_synonym_set` or `upsert_synonym_set_item` when using Typesense v30.0+"
  @spec upsert_synonym(String.t() | module(), String.t(), map()) ::
          {:ok, OpenApiTypesense.SearchSynonym.t()} | {:error, OpenApiTypesense.ApiResponse.t()}
  def upsert_synonym(coll_name, syn_id, body) do
    upsert_synonym(coll_name, syn_id, body, [])
  end

  @doc """
  Same as [upsert_synonym/3](`upsert_synonym/3`).

  ## Options

    * `conn`: The custom connection map or struct you passed

  ## Examples
      iex> conn = %{api_key: xyz, host: ...}
      iex> ExTypesense.upsert_synonym("persons", "coat-synonyms", body, conn: conn)

      iex> conn = OpenApiTypesense.Connection.new()
      iex> ExTypesense.upsert_synonym("persons", "coat-synonyms", body, conn: conn)

      iex> opts = [conn: conn]
      iex> ExTypesense.upsert_synonym(MyApp.Accounts.Person, "coat-synonyms", body, opts)
  """
  @doc since: "1.0.0"
  @deprecated "Please use `upsert_synonym_set` or `upsert_synonym_set_item` when using Typesense v30.0+"
  @spec upsert_synonym(String.t() | module(), String.t(), map(), keyword()) ::
          {:ok, OpenApiTypesense.SearchSynonym.t()} | {:error, OpenApiTypesense.ApiResponse.t()}
  def upsert_synonym(module, syn_id, body, opts) when is_atom(module) do
    coll_name = module.__schema__(:source)
    upsert_synonym(coll_name, syn_id, body, opts)
  end

  def upsert_synonym(coll_name, syn_id, body, opts) when is_binary(coll_name) do
    OpenApiTypesense.Synonyms.upsert_search_synonym(coll_name, syn_id, body, opts)
  end

  @doc """
  Create or update a synonym set

  Create or update a synonym set with the given name

  ## Request Body

  **Content Types**: `application/json`

  The synonym set to be created/updated
  """
  @doc since: "2.2.0"
  @spec upsert_synonym_set(
          synonym_set_name :: String.t(),
          body :: OpenApiTypesense.SynonymSetCreateSchema.t()
        ) ::
          {:ok, OpenApiTypesense.SynonymSetSchema.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def upsert_synonym_set(synonym_set_name, body) do
    upsert_synonym_set(synonym_set_name, body, [])
  end

  @doc """
  Same as [upsert_synonym_set/2](`upsert_synonym_set/2`).

  ## Options

    * `conn`: The custom connection map or struct you passed

  """
  @doc since: "2.2.0"
  @spec upsert_synonym_set(
          synonym_set_name :: String.t(),
          body :: OpenApiTypesense.SynonymSetCreateSchema.t(),
          opts :: keyword
        ) ::
          {:ok, OpenApiTypesense.SynonymSetSchema.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def upsert_synonym_set(synonym_set_name, body, opts) do
    OpenApiTypesense.Synonyms.upsert_synonym_set(synonym_set_name, body, opts)
  end

  @doc """
  Create or update a synonym set item

  Create or update a synonym set item with the given id

  ## Request Body

  **Content Types**: `application/json`

  The synonym item to be created/updated
  """
  @doc since: "2.2.0"
  @spec upsert_synonym_set_item(
          synonym_set_name :: String.t(),
          item_id :: String.t(),
          body :: OpenApiTypesense.SynonymItemUpsertSchema.t()
        ) ::
          {:ok, OpenApiTypesense.SynonymItemSchema.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def upsert_synonym_set_item(synonym_set_name, item_id, body) do
    upsert_synonym_set_item(synonym_set_name, item_id, body, [])
  end

  @doc """
  Same as [upsert_synonym_set_item/3](`upsert_synonym_set_item/3`).

  ## Options

    * `conn`: The custom connection map or struct you passed

  """
  @doc since: "2.2.0"
  @spec upsert_synonym_set_item(
          synonym_set_name :: String.t(),
          item_id :: String.t(),
          body :: OpenApiTypesense.SynonymItemUpsertSchema.t(),
          opts :: keyword
        ) ::
          {:ok, OpenApiTypesense.SynonymItemSchema.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def upsert_synonym_set_item(synonym_set_name, item_id, body, opts) do
    OpenApiTypesense.Synonyms.upsert_synonym_set_item(synonym_set_name, item_id, body, opts)
  end
end
