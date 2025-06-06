defmodule ExTypesense.Collection do
  @moduledoc since: "0.1.0"

  @moduledoc """
  Module for creating, listing and deleting collections and aliases.

  In Typesense, a [Collection](https://typesense.org/docs/latest/api/collections.html)
  is a group of related [Documents](https://typesense.org/docs/latest/api/documents.html)
  that is roughly equivalent to a table in a relational database. When
  we create a collection, we give it a name and describe the fields
  that will be indexed when a document is added to the collection.

  More here: https://typesense.org/docs/latest/api/collections.html
  """

  @doc """
  Returns a summary of all your collections. The collections are returned
  sorted by creation date, with the most recent collections appearing first.

  ## Examples
      iex> ExTypesense.list_collections()
  """
  @doc since: "1.0.0"
  @spec list_collections :: {:ok, [OpenApiTypesense.CollectionResponse.t()]} | :error
  def list_collections do
    list_collections([])
  end

  @doc """
  Same as [list_collections/0](`list_collections/0`) but passes another connection or option.

  ## Options

  * `conn`: The custom connection map or struct you passed
  * `limit`: Limit results in paginating on collection listing.
  * `offset`: Skip a certain number of results and start after that.
  * `exclude_fields`: Exclude the field definitions from being returned in the response.

  ## Examples
      iex> conn = %{api_key: xyz, host: ...}
      iex> ExTypesense.list_collections(conn: conn)

      iex> conn = OpenApiTypesense.Connection.new()
      iex> ExTypesense.list_collections(conn: conn)

      iex> opts = [exclude_fields: "fields", limit: 10, conn: conn]
      iex> ExTypesense.list_collections(opts)
  """
  @doc since: "1.0.0"
  @spec list_collections(keyword()) ::
          {:ok, [OpenApiTypesense.CollectionResponse.t()]} | :error
  def list_collections(opts) do
    OpenApiTypesense.Collections.get_collections(opts)
  end

  @doc """
  Creates collection with timestamped name and points to an alias.

  > #### Use case {: .warning}
  >
  > When using this function, it will append
  > a timestamp in name and adds an alias based on schema name.
  > E.g. if table name is "bricks", then collection name is "bricks-1738558695"
  > and alias name is "bricks". The reason for this addition can be useful
  > when encountering like [full re-indexing](https://typesense.org/docs/guide/syncing-data-into-typesense.html#full-re-indexing)

  > One common use-case for aliases is to reindex your data in the
  > background on a new collection and then switch your application
  > to it without any changes to your code. [Source](https://typesense.org/docs/latest/api/collection-alias.html#use-case)

  ## Options

    * `conn`: The custom connection map or struct you passed

  ## Examples
      iex> schema = %{
      ...>   name: "companies",
      ...>   fields: [
      ...>     %{name: "company_name", type: "string"},
      ...>     %{name: "companies_id", type: "int32"},
      ...>     %{name: "country", type: "string", facet: true}
      ...>   ],
      ...>   default_sorting_field: "companies_id"
      ...> }
      iex> ExTypesense.create_collection_with_alias(schema)

      iex> ExTypesense.create_collection_with_alias(Person)
  """
  @doc since: "1.1.0"
  @spec create_collection_with_alias(map() | module()) ::
          {:ok, OpenApiTypesense.CollectionResponse.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def create_collection_with_alias(schema) do
    create_collection_with_alias(schema, [])
  end

  @doc """
  Same as [create_collection_with_alias/1](`create_collection_with_alias/1`) but passes another connection or opts.

  ## Examples
      iex> conn = %{api_key: xyz, host: ...}
      iex> ExTypesense.create_collection_with_alias(schema, conn: conn)

      iex> conn = OpenApiTypesense.Connection.new()
      iex> ExTypesense.create_collection_with_alias(schema, conn: conn)

      iex> opts = [conn: conn]
      iex> ExTypesense.create_collection_with_alias(schema, opts)
  """
  @doc since: "1.1.0"
  @spec create_collection_with_alias(map() | module(), keyword()) ::
          {:ok, OpenApiTypesense.CollectionResponse.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def create_collection_with_alias(module, opts) when is_atom(module) do
    schema = module.get_field_types()
    create_collection_with_alias(schema, opts)
  end

  def create_collection_with_alias(schema, opts) when is_map(schema) do
    coll_name = Map.get(schema, "name") || Map.get(schema, :name)
    coll_name_ts = "#{coll_name}-#{DateTime.utc_now() |> DateTime.to_unix()}"
    updated_schema = Map.put(schema, :name, coll_name_ts)
    coll = create_collection(updated_schema, opts)
    upsert_collection_alias(coll_name, coll_name_ts, opts)

    coll
  end

  @doc """
  Create collection from a map, or module name. Collection name
  is matched on table name if using Ecto schema by default.

  Please refer to these [list of schema params](https://typesense.org/docs/latest/api/collections.html#schema-parameters).

  ## Examples
      iex> schema = %{
      ...>   name: "companies",
      ...>   fields: [
      ...>     %{name: "company_name", type: "string"},
      ...>     %{name: "companies_id", type: "int32"},
      ...>     %{name: "country", type: "string", facet: true}
      ...>   ],
      ...>   default_sorting_field: "companies_id"
      ...> }
      iex> ExTypesense.create_collection(schema)
      {:ok, %OpenApiTypesense.CollectionResponse{
        created_at: 1234567890,
        default_sorting_field: "companies_id",
        fields: [...],
        name: "companies",
        num_documents: 0,
        symbols_to_index: [],
        token_separators: []
      }}

      iex> ExTypesense.create_collection(Person)
      {:ok, %OpenApiTypesense.CollectionResponse{
        created_at: 1234567890,
        default_sorting_field: "persons_id",
        fields: [...],
        name: "persons",
        num_documents: 0,
        symbols_to_index: [],
        token_separators: []
      }}
  """
  @doc since: "1.0.0"
  @spec create_collection(map() | module()) ::
          {:ok, OpenApiTypesense.CollectionResponse.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def create_collection(schema) do
    create_collection(schema, [])
  end

  @doc """
  Same as [create_collection/1](`create_collection/1`) but passes another connection or opts.

  ## Options

    * `conn`: The custom connection map or struct you passed
    * `src_name` (optional): Clone an existing collection's schema (documents are not copied), overrides and synonyms. This option is used primarily by [`clone_collection/2`](`clone_collection/2`).

  ## Examples
      iex> conn = %{api_key: xyz, host: ...}
      iex> ExTypesense.create_collection(schema, conn: conn)

      iex> conn = OpenApiTypesense.Connection.new()
      iex> ExTypesense.create_collection(schema, conn: conn)

      iex> opts = [src_name: "companies", conn: conn]
      iex> ExTypesense.create_collection(schema, opts)
  """
  @doc since: "1.0.0"
  @spec create_collection(map() | module(), keyword()) ::
          {:ok, OpenApiTypesense.CollectionResponse.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def create_collection(module, opts) when is_atom(module) do
    schema = module.get_field_types()
    create_collection(schema, opts)
  end

  def create_collection(schema, opts) when is_map(schema) do
    OpenApiTypesense.Collections.create_collection(schema, opts)
  end

  @doc """
  Clone an existing collection's schema (documents are not copied),
  overrides and synonyms. The actual documents in the collection are
  not copied, so this is primarily useful for creating new
  collections from an existing reference template.

  ## Examples
      iex> ExTypesense.clone_collection(MyModule.Accounts.User, "persons")
      iex> ExTypesense.clone_collection("persons", "accounts")
  """
  @doc since: "1.0.0"
  @spec clone_collection(String.t() | module(), String.t()) ::
          {:ok, OpenApiTypesense.CollectionResponse.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def clone_collection(src_coll, new_coll) do
    clone_collection(src_coll, new_coll, [])
  end

  @doc """
  Same as [clone_collection/2](`clone_collection/2`)

  ## Options

    * `conn`: The custom connection map or struct you passed

  ## Examples
      iex> conn = %{api_key: xyz, host: ...}
      iex> ExTypesense.clone_collection("persons", "accounts", conn: conn)

      iex> conn = OpenApiTypesense.Connection.new()
      iex> ExTypesense.clone_collection(MyModule.Accounts.User, "persons", conn: conn)

      iex> opts = [conn: conn]
      iex> ExTypesense.clone_collection(MyModule.Accounts.User, "persons", opts)
  """
  @doc since: "1.0.0"
  @spec clone_collection(String.t() | module(), keyword()) ::
          {:ok, OpenApiTypesense.CollectionResponse.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def clone_collection(module, new_coll, opts) when is_atom(module) do
    src_coll = module.__schema__(:source)
    clone_collection(src_coll, new_coll, opts)
  end

  def clone_collection(src_coll, new_coll, opts) when is_binary(src_coll) do
    opts = Keyword.put_new(opts, :src_name, src_coll)
    body = struct(OpenApiTypesense.CollectionSchema, %{"name" => new_coll})
    create_collection(body, opts)
  end

  @doc """
  Get a specific collection by string or module name.

  ## Examples
      iex> ExTypesense.get_collection(MyModule.Accounts.User)
      iex> ExTypesense.get_collection("persons")
  """
  @doc since: "1.0.0"
  @spec get_collection(String.t() | module()) ::
          {:ok, OpenApiTypesense.CollectionResponse.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def get_collection(coll_name) do
    get_collection(coll_name, [])
  end

  @doc """
  Same as [get_collection/1](`get_collection/1`)

  ## Options

    * `conn`: The custom connection map or struct you passed

  ## Examples
      iex> conn = %{api_key: xyz, host: ...}
      iex> ExTypesense.get_collection("persons", conn: conn)

      iex> conn = OpenApiTypesense.Connection.new()
      iex> ExTypesense.get_collection(MyModule.Accounts.User, conn: conn)

      iex> opts = [conn: conn]
      iex> ExTypesense.get_collection(MyModule.Accounts.User, opts)
  """
  @doc since: "1.0.0"
  @spec get_collection(String.t() | module(), keyword()) ::
          {:ok, OpenApiTypesense.CollectionResponse.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def get_collection(module, opts) when is_atom(module) do
    collection_name = module.__schema__(:source)
    get_collection(collection_name, opts)
  end

  def get_collection(coll_name, opts) when is_binary(coll_name) do
    OpenApiTypesense.Collections.get_collection(coll_name, opts)
  end

  @doc """
  Make changes in a collection's fields: adding, removing
  or updating an existing field(s). Key name is `drop` to
  indicate which field is removed (example described below).
  Only `fields` can only be updated at the moment.

  > #### Typesense special field `id` {: .info}
  >
  > Typesense supports updating all fields
  > except the `id` field (since it's a special field
  > within Typesense). Do not confuse `id` of Typesense
  > with Ecto Schema or DB record(s).


  > #### Which version supports this function {: .info}
  >
  > We can update the collection's fields, starting on version
  > [27.0.rc22](https://github.com/typesense/typesense/issues/1700#issuecomment-2200125617)
  > and above.

  ## Examples
      iex> fields = %{
      ...>  fields: [
      ...>    %{name: "num_employees", drop: true},
      ...>    %{name: "company_category", type: "string"},
      ...>  ],
      ...> }
      iex> ExTypesense.update_collection_fields("companies", fields)
      %OpenApiTypesense.CollectionUpdateSchema{
        fields: [
          ...
        ]
      }
  """
  @doc since: "1.0.0"
  @spec update_collection_fields(String.t() | module(), map()) ::
          {:ok, OpenApiTypesense.CollectionUpdateSchema.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def update_collection_fields(name, fields) do
    update_collection_fields(name, fields, [])
  end

  @doc """
  Same as [update_collection_fields/2](`update_collection_fields/2`)

  ## Options

    * `conn`: The custom connection map or struct you passed

  ## Examples
      iex> conn = %{api_key: xyz, host: ...}
      iex> ExTypesense.update_collection_fields("persons", fields, conn: conn)

      iex> conn = OpenApiTypesense.Connection.new()
      iex> ExTypesense.update_collection_fields("persons", fields, conn: conn)

      iex> opts = [conn: conn]
      iex> ExTypesense.get_collection("persons", fields, opts)
  """
  @doc since: "1.0.0"
  @spec update_collection_fields(String.t() | module(), map(), keyword()) ::
          {:ok, OpenApiTypesense.CollectionUpdateSchema.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def update_collection_fields(module, fields, opts) when is_atom(module) do
    name = module.__schema__(:source)
    update_collection_fields(name, fields, opts)
  end

  def update_collection_fields(name, fields, opts) when is_binary(name) do
    OpenApiTypesense.Collections.update_collection(name, fields, opts)
  end

  @doc """
  Permanently drops a collection by collection name or module name.

  This action **cannot** be undone. For large collections, this might
  have an impact on read latencies.

  > #### alias not affected {: .tip}
  >
  > dropping a collection does not remove the referenced
  > alias, only the indexed documents.

  ## Examples
      iex> ExTypesense.drop_collection("persons")

      iex> ExTypesense.drop_collection(MyModule.Accounts.User)
  """
  @doc since: "1.0.0"
  @spec drop_collection(String.t() | module()) ::
          {:ok, OpenApiTypesense.CollectionResponse.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def drop_collection(collection_name) do
    drop_collection(collection_name, [])
  end

  @doc """
  Same as [drop_collection/2](`drop_collection/2`)

  ## Options

    * `conn`: The custom connection map or struct you passed

  ## Examples
      iex> conn = %{api_key: xyz, host: ...}
      iex> ExTypesense.drop_collection("persons", conn: conn)

      iex> ExTypesense.drop_collection("persons", conn: conn)

      iex> opts = [conn: conn]
      iex> ExTypesense.drop_collection(MyModule.Accounts.User, opts)
  """
  @doc since: "1.0.0"
  @spec drop_collection(String.t() | module(), keyword()) ::
          {:ok, OpenApiTypesense.CollectionResponse.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def drop_collection(module, opts) when is_atom(module) do
    name = module.__schema__(:source)
    drop_collection(name, opts)
  end

  def drop_collection(name, opts) when is_binary(name) do
    OpenApiTypesense.Collections.delete_collection(name, opts)
  end

  @doc """
  List all aliases and the corresponding collections that they map to.

  ## Examples
      iex> ExTypesense.list_collection_aliases()
  """
  @doc since: "1.0.0"
  @spec list_collection_aliases :: {:ok, OpenApiTypesense.CollectionAliasesResponse.t()} | :error
  def list_collection_aliases do
    list_collection_aliases([])
  end

  @doc """
  Same as [list_collection_aliases/0](`list_collection_aliases/0`)

  ## Options

    * `conn`: The custom connection map or struct you passed

  ## Examples
      iex> conn = %{api_key: xyz, host: ...}
      iex> ExTypesense.list_collection_aliases(conn: conn)

      iex> conn = OpenApiTypesense.Connection.new()
      iex> ExTypesense.list_collection_aliases(conn: conn)

      iex> opts = [conn: conn]
      iex> ExTypesense.list_collection_aliases(opts)
  """
  @doc since: "1.0.0"
  @spec list_collection_aliases(keyword()) ::
          {:ok, OpenApiTypesense.CollectionAliasesResponse.t()} | :error
  def list_collection_aliases(opts) do
    OpenApiTypesense.Collections.get_aliases(opts)
  end

  @doc """
  Get a specific collection by alias.

  ## Examples
      iex> ExTypesense.get_collection_alias("persons_sept_8_2019")
  """
  @doc since: "1.0.0"
  @spec get_collection_alias(String.t() | module()) ::
          {:ok, OpenApiTypesense.CollectionAlias.t()} | {:error, OpenApiTypesense.ApiResponse.t()}
  def get_collection_alias(alias_name) do
    get_collection_alias(alias_name, [])
  end

  @doc """
  Same as [get_collection_alias/1](`get_collection_alias/1`)

  ## Options

    * `conn`: The custom connection map or struct you passed

  ## Examples
      iex> conn = %{api_key: xyz, host: ...}
      iex> ExTypesense.get_collection_alias("persons_sept_8_2019", conn: conn)

      iex> conn = OpenApiTypesense.Connection.new()
      iex> ExTypesense.get_collection_alias("persons_sept_8_2019", conn: conn)

      iex> opts = [conn: conn]
      iex> ExTypesense.get_collection_alias("persons_sept_8_2019", opts)
  """
  @doc since: "1.0.0"
  @spec get_collection_alias(String.t() | module(), keyword()) ::
          {:ok, OpenApiTypesense.CollectionAlias.t()} | {:error, OpenApiTypesense.ApiResponse.t()}
  def get_collection_alias(module, opts) when is_atom(module) do
    alias_name = module.__schema__(:source)
    get_collection_alias(alias_name, opts)
  end

  def get_collection_alias(alias_name, opts) when is_binary(alias_name) do
    OpenApiTypesense.Collections.get_alias(alias_name, opts)
  end

  @doc """
  Upserts a collection alias.

  An alias is a virtual collection name that points to a real collection. If you're familiar
  with symbolic links on Linux, it's very similar to that. Aliases are useful when you want
  to reindex your data in the background on a new collection and switch your application to
  it without any changes to your code.

  `collection_name` can either be a string or module name

  ## Examples
      iex> ExTypesense.upsert_collection_alias("persons_sept_8_2019", "persons")
  """
  @doc since: "1.0.0"
  @spec upsert_collection_alias(String.t(), String.t() | module()) ::
          {:ok, OpenApiTypesense.CollectionAlias.t()} | {:error, OpenApiTypesense.ApiResponse.t()}
  def upsert_collection_alias(alias_name, collection_name) do
    upsert_collection_alias(alias_name, collection_name, [])
  end

  @doc """
  Same as [upsert_collection_alias/2](`upsert_collection_alias/2`)

  ## Options

    * `conn`: The custom connection map or struct you passed

  ## Examples
      iex> conn = %{api_key: xyz, host: ...}
      iex> ExTypesense.upsert_collection_alias("persons_sept_8_2019", "persons", conn: conn)

      iex> conn = OpenApiTypesense.Connection.new()
      iex> ExTypesense.upsert_collection_alias("persons_sept_8_2019", MyModule.Accounts.Person, conn: conn)

      iex> opts = [conn: conn]
      iex> ExTypesense.upsert_collection_alias("persons_sept_8_2019", "persons", opts)
  """
  @doc since: "1.0.0"
  @spec upsert_collection_alias(String.t(), String.t() | module(), keyword()) ::
          {:ok, OpenApiTypesense.CollectionAlias.t()} | {:error, OpenApiTypesense.ApiResponse.t()}
  def upsert_collection_alias(alias_name, module, opts) when is_atom(module) do
    collection_name = module.__schema__(:source)
    upsert_collection_alias(alias_name, collection_name, opts)
  end

  def upsert_collection_alias(alias_name, coll_name, opts) when is_binary(coll_name) do
    body = struct(OpenApiTypesense.CollectionAliasSchema, %{"collection_name" => coll_name})
    OpenApiTypesense.Collections.upsert_alias(alias_name, body, opts)
  end

  @doc """
  Deletes a collection alias. The collection itself
  is not affected by this action.

  ## Examples
      iex> ExTypesense.delete_collection_alias("persons_sept_8_2019")
  """
  @doc since: "1.0.0"
  @spec delete_collection_alias(String.t()) ::
          {:ok, OpenApiTypesense.CollectionAlias.t()} | {:error, OpenApiTypesense.ApiResponse.t()}
  def delete_collection_alias(alias_name) when is_binary(alias_name) do
    delete_collection_alias(alias_name, [])
  end

  @doc """
  Same as [delete_collection_alias/1](`delete_collection_alias/1`)

  ## Options

    * `conn`: The custom connection map or struct you passed

  ## Examples
      iex> conn = %{api_key: xyz, host: ...}
      iex> ExTypesense.delete_collection_alias("persons_sept_8_2019", conn: conn)

      iex> conn = OpenApiTypesense.Connection.new()
      iex> ExTypesense.delete_collection_alias("persons_sept_8_2019", conn: conn)

      iex> opts = [conn: conn]
      iex> ExTypesense.delete_collection_alias("persons_sept_8_2019", opts)
  """
  @doc since: "1.0.0"
  @spec delete_collection_alias(String.t(), keyword()) ::
          {:ok, OpenApiTypesense.CollectionAlias.t()} | {:error, OpenApiTypesense.ApiResponse.t()}
  def delete_collection_alias(alias_name, opts) do
    OpenApiTypesense.Collections.delete_alias(alias_name, opts)
  end
end
