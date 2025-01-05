defmodule ExTypesense.Collection do
  @moduledoc since: "0.1.0"
  @moduledoc """
  Module for creating, listing and deleting collections and aliases.

  In Typesense, a [Collection](https://typesense.org/docs/latest/api/collections.html) is a group of related
  [Documents](https://typesense.org/docs/latest/api/documents.html) that is roughly equivalent to a table in
  a relational database. When we create a collection, we give it a name and describe the fields that will be
  indexed when a document is added to the collection.
  """

  @doc """
  Returns a summary of all your collections. The collections are returned
  sorted by creation date, with the most recent collections appearing first.

  ## Options

  * `limit`: Limit results in paginating on collection listing.
  * `offset`: Skip a certain number of results and start after that.
  * `exclude_fields`: Exclude the field definitions from being returned in the response.
  """
  @doc since: "0.8.0"
  @spec list_collections :: {:ok, [OpenApiTypesense.CollectionResponse.t()]} | :error
  def list_collections do
    ExTypesense.Connection.new() |> list_collections()
  end

  @doc """
  Same as [list_collections/0](`list_collections/0`) but passes another connection or option.

  ```elixir
  ExTypesense.list_collections(ExTypesense.Connection.new())

  ExTypesense.list_collections(%{api_key: xyz, host: ...})

  ExTypesense.list_collections(exclude_fields: "fields", limit: 10)
  ```
  """
  @doc since: "0.8.0"
  @spec list_collections(map() | OpenApiTypesense.Connection.t() | keyword()) ::
          {:ok, [OpenApiTypesense.CollectionResponse.t()]} | :error
  def list_collections(opts) when is_list(opts) do
    ExTypesense.Connection.new() |> list_collections(opts)
  end

  def list_collections(conn) when is_map(conn) or is_struct(conn) do
    list_collections(conn, [])
  end

  @doc """
  Same as [list_collections/1](`list_collections/1`) but passes another connection.

  ```elixir
  ExTypesense.list_collections(%{api_key: xyz, host: ...}, limit: 10)

  ExTypesense.list_collections(ExTypesense.Connection.new(), exclude_fields: "fields", limit: 10)
  ```
  """
  @doc since: "0.8.0"
  @spec list_collections(map() | OpenApiTypesense.Connection.t(), keyword()) ::
          {:ok, [OpenApiTypesense.CollectionResponse.t()]} | :error
  def list_collections(conn, opts) when is_map(conn) or is_struct(conn) do
    OpenApiTypesense.Collections.get_collections(conn, opts)
  end

  @doc """
  Create collection from a map, or module name. Collection name is matched on table name if using Ecto schema by default.

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
      %OpenApiTypesense.CollectionResponse{
        created_at: 1234567890,
        default_sorting_field: "companies_id",
        fields: [...],
        name: "companies",
        num_documents: 0,
        symbols_to_index: [],
        token_separators: []
      }

      iex> ExTypesense.create_collection(Person)
      %OpenApiTypesense.CollectionResponse{
        created_at: 1234567890,
        default_sorting_field: "persons_id",
        fields: [...],
        name: "persons",
        num_documents: 0,
        symbols_to_index: [],
        token_separators: []
      }
  """
  @doc since: "0.8.0"
  @spec create_collection(map() | module()) ::
          {:ok, [OpenApiTypesense.CollectionResponse.t()]} | :error
  def create_collection(schema) do
    ExTypesense.Connection.new() |> create_collection(schema)
  end

  @doc """
  Same as [create_collection/1](`create_collection/1`) but passes another connection or opts.

  ```elixir
  ExTypesense.create_collection(%{api_key: xyz, host: ...}, schema)

  ExTypesense.create_collection(ExTypesense.Connection.new(), MyModule.Context)
  ```
  """
  @doc since: "0.8.0"
  @spec create_collection(map() | OpenApiTypesense.Connection.t(), map() | module() | keyword()) ::
          {:ok, [OpenApiTypesense.CollectionResponse.t()]} | :error
  def create_collection(schema, opts) when is_map(schema) and is_list(opts) do
    ExTypesense.Connection.new() |> create_collection(schema, opts)
  end

  def create_collection(conn, schema) do
    create_collection(conn, schema, [])
  end

  @doc """
  Same as [create_collection/1](`create_collection/1`) but passes another connection or opts.

  ```elixir
  ExTypesense.create_collection(%{api_key: xyz, host: ...}, schema, opts)

  ExTypesense.create_collection(ExTypesense.Connection.new(), MyModule.Context, opts)
  ```
  """
  @doc since: "0.8.0"
  @spec create_collection(map() | OpenApiTypesense.Connection.t(), map() | module(), keyword()) ::
          {:ok, [OpenApiTypesense.CollectionResponse.t()]} | :error
  def create_collection(conn, schema, opts) when is_map(schema) do
    OpenApiTypesense.Collections.create_collection(conn, schema, opts)
  end

  def create_collection(conn, module_name, opts) when is_atom(module_name) do
    schema = module_name.get_field_types()
    OpenApiTypesense.Collections.create_collection(conn, schema, opts)
  end

  @doc """
  Clone an existing collection's schema (documents are not copied),
  overrides and synonyms. The actual documents in the collection are not copied,
  so this is primarily useful for creating new collections from an existing reference template.

  ```elixir
  ExTypesense.clone_collection("persons", MyModule.Accounts.User)
  ExTypesense.clone_collection("persons", "accounts")
  ExTypesense.clone_collection(MyModule.Perishable.Fruit, "clone_fruits")
  ExTypesense.clone_collection(MyModule.Vehicle.Sedan, MyModule.Vehicle.Convertible)
  ```
  """
  @doc since: "0.8.0"
  @spec clone_collection(String.t() | module(), String.t() | module()) ::
          {:ok, [OpenApiTypesense.CollectionResponse.t()]} | :error
  def clone_collection(src_coll, new_coll) do
    ExTypesense.Connection.new() |> create_collection(src_coll, new_coll)
  end

  @doc """
  Same as [clone_collection/2](`clone_collection/2`) but passes another connection.

  ```elixir
  ExTypesense.clone_collection(%{api_key: xyz, host: ...}, "persons", "accounts")
  ExTypesense.clone_collection(ExTypesense.Connection.new(), "persons", MyModule.Accounts.User)
  ```
  """
  @doc since: "0.8.0"
  @spec clone_collection(
          map() | OpenApiTypesense.Connection.t(),
          String.t() | module(),
          String.t() | module()
        ) ::
          {:ok, [OpenApiTypesense.CollectionResponse.t()]} | :error
  def clone_collection(conn, src_coll, new_coll) when is_struct(conn) or is_map(conn) do
    [src_coll, new_coll] = stringify_collection_name(src_coll, new_coll)
    body = %{"name" => new_coll}
    create_collection(conn, body, src_name: src_coll)
  end

  defp stringify_collection_name(src_coll, new_coll) do
    cond do
      is_binary(src_coll) and is_atom(new_coll) ->
        [src_coll, new_coll.__schema__(:source)]

      is_atom(src_coll) and is_binary(new_coll) ->
        [src_coll.__schema__(:source), new_coll]

      is_atom(src_coll) and is_atom(new_coll) ->
        [src_coll.__schema__(:source), new_coll.__schema__(:source)]

      true ->
        [src_coll, new_coll]
    end
  end

  @doc """
  Get a specific collection by string or module name.
  """
  @doc since: "0.8.0"
  @spec get_collection(String.t() | module()) ::
          {:ok, OpenApiTypesense.CollectionResponse.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def get_collection(collection_name) do
    ExTypesense.Connection.new() |> get_collection(collection_name)
  end

  @doc """
  Same as [get_collection/1](`get_collection/1`) but passes another connection.

  ```elixir
  ExTypesense.get_collection(%{api_key: xyz, host: ...}, "persons")
  ExTypesense.get_collection(ExTypesense.Connection.new(), MyModule.Accounts.User)
  ```
  """
  @doc since: "0.8.0"
  @spec get_collection(map() | OpenApiTypesense.Connection.t(), String.t() | module()) ::
          {:ok, OpenApiTypesense.CollectionResponse.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def get_collection(conn, collection_name) when is_binary(collection_name) do
    OpenApiTypesense.Collections.get_collection(conn, collection_name)
  end

  def get_collection(conn, module) when is_atom(module) do
    collection_name = module.__schema__(:source)
    OpenApiTypesense.Collections.get_collection(conn, collection_name)
  end

  @doc """
  Get the collection name by alias.
  """
  @doc since: "0.8.0"
  @spec get_collection_name(String.t()) :: String.t() | nil
  def get_collection_name(alias_name) do
    ExTypesense.Connection.new() |> get_collection_name(alias_name)
  end

  @doc """
  Same as [get_collection_name/1](`get_collection_name/1`) but passes another connection.

  ```elixir
  ExTypesense.get_collection_name(%{api_key: xyz, host: ...}, "persons_sept_8_2019")
  ExTypesense.get_collection_name(ExTypesense.Connection.new(), "persons_sept_8_2019")
  ```
  """
  @doc since: "0.8.0"
  @spec get_collection_name(map() | OpenApiTypesense.Connection.t(), String.t()) ::
          String.t() | nil
  def get_collection_name(conn, alias_name) do
    case OpenApiTypesense.Collections.get_alias(conn, alias_name) do
      {:ok, alias} ->
        Map.get(alias, "collection_name")

      {:error, _} ->
        nil
    end
  end

  @doc """
  Make changes in a collection's fields: adding, removing
  or updating an existing field(s). Key name is `drop` to
  indicate which field is removed (example described below).
  Only `fields` can only be updated at the moment.

  > **Note**: Typesense supports updating all fields
  > except the `id` field (since it's a special field
  > within Typesense).

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
  @doc since: "0.8.0"
  @spec update_collection_fields(String.t() | module(), map()) ::
          {:ok, OpenApiTypesense.CollectionUpdateSchema.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def update_collection_fields(name, fields) do
    ExTypesense.Connection.new() |> update_collection_fields(name, fields)
  end

  @doc """
  Same as [update_collection_fields/2](`update_collection_fields/2`) but passes another connection.

  ```elixir
  ExTypesense.update_collection_fields(%{api_key: xyz, host: ...}, "persons", fields)
  ExTypesense.update_collection_fields(ExTypesense.Connection.new(), MyModule.Accounts.User, fields)
  ```
  """
  @doc since: "0.8.0"
  @spec update_collection_fields(
          map() | OpenApiTypesense.Connection.t(),
          String.t() | module(),
          map()
        ) ::
          {:ok, OpenApiTypesense.CollectionUpdateSchema.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def update_collection_fields(conn, name, fields) when is_binary(name) do
    OpenApiTypesense.Collections.update_collection(conn, name, fields)
  end

  def update_collection_fields(conn, module, fields) when is_atom(module) do
    name = module.__schema__(:source)
    OpenApiTypesense.Collections.update_collection(conn, name, fields)
  end

  @doc """
  Permanently drops a collection by collection name or module name.
  This action **cannot** be undone. For large collections, this might
  have an impact on read latencies.

  **Note**: dropping a collection does not remove the referenced
  alias, only the indexed documents.
  """
  @doc since: "0.8.0"
  @spec drop_collection(String.t() | module()) ::
          {:ok, OpenApiTypesense.CollectionResponse.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def drop_collection(collection_name) do
    ExTypesense.Connection.new() |> drop_collection(collection_name)
  end

  @doc """
  Same as [update_collection_fields/2](`update_collection_fields/2`) but passes another connection.

  ```elixir
  ExTypesense.drop_collection(%{api_key: xyz, host: ...}, "persons")
  ExTypesense.drop_collection(ExTypesense.Connection.new(), MyModule.Accounts.User)
  ```
  """
  @doc since: "0.8.0"
  @spec drop_collection(map() | OpenApiTypesense.Connection.t(), String.t() | module()) ::
          {:ok, OpenApiTypesense.CollectionResponse.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def drop_collection(conn, name) when is_binary(name) do
    OpenApiTypesense.Collections.delete_collection(conn, name)
  end

  def drop_collection(conn, module) when is_atom(module) do
    name = module.__schema__(:source)
    OpenApiTypesense.Collections.delete_collection(conn, name)
  end

  @doc """
  List all aliases and the corresponding collections that they map to.
  """
  @doc since: "0.8.0"
  @spec list_collection_aliases :: {:ok, OpenApiTypesense.CollectionAliasesResponse.t()} | :error
  def list_collection_aliases do
    ExTypesense.Connection.new() |> list_collection_aliases()
  end

  @doc """
  Same as [list_collection_aliases/0](`list_collection_aliases/0`) but passes another connection.

  ```elixir
  ExTypesense.list_collection_aliases(%{api_key: xyz, host: ...})
  ExTypesense.list_collection_aliases(ExTypesense.Connection.new())
  ```
  """
  @doc since: "0.8.0"
  @spec list_collection_aliases(map() | OpenApiTypesense.Connection.t()) ::
          {:ok, OpenApiTypesense.CollectionAliasesResponse.t()} | :error
  def list_collection_aliases(conn) do
    OpenApiTypesense.Collections.get_aliases(conn)
  end

  @doc """
  Get a specific collection alias by string or module name.
  """
  @doc since: "0.8.0"
  @spec get_collection_alias(String.t() | module()) ::
          {:ok, OpenApiTypesense.CollectionAlias.t()} | {:error, OpenApiTypesense.ApiResponse.t()}
  def get_collection_alias(alias_name) do
    ExTypesense.Connection.new() |> get_collection_alias(alias_name)
  end

  @doc """
  Same as [get_collection_alias/1](`get_collection_alias/1`) but passes another connection.

  ```elixir
  ExTypesense.get_collection_alias(%{api_key: xyz, host: ...}, "persons_sept_8_2019")
  ExTypesense.get_collection_alias(ExTypesense.Connection.new(), "persons_sept_8_2019")
  ```
  """
  @doc since: "0.8.0"
  @spec get_collection_alias(map() | OpenApiTypesense.Connection.t(), String.t() | module()) ::
          {:ok, OpenApiTypesense.CollectionAlias.t()} | {:error, OpenApiTypesense.ApiResponse.t()}
  def get_collection_alias(conn, alias_name) when is_binary(alias_name) do
    OpenApiTypesense.Collections.get_alias(conn, alias_name)
  end

  def get_collection_alias(conn, module) when is_atom(module) do
    alias_name = module.__schema__(:source)
    OpenApiTypesense.Collections.get_alias(conn, alias_name)
  end

  @doc """
  Upserts a collection alias.

  An alias is a virtual collection name that points to a real collection. If you're familiar
  with symbolic links on Linux, it's very similar to that. Aliases are useful when you want
  to reindex your data in the background on a new collection and switch your application to
  it without any changes to your code.

  `collection_name` can either be a string or module name
  """
  @doc since: "0.8.0"
  @spec upsert_collection_alias(String.t(), String.t() | module()) ::
          {:ok, OpenApiTypesense.CollectionAlias.t()} | {:error, OpenApiTypesense.ApiResponse.t()}
  def upsert_collection_alias(alias_name, collection_name) do
    ExTypesense.Connection.new() |> upsert_collection_alias(alias_name, collection_name)
  end

  @doc """
  Same as [upsert_collection_alias/2](`upsert_collection_alias/2`) but passes another connection.

  ```elixir
  ExTypesense.upsert_collection_alias(%{api_key: xyz, host: ...}, "persons_sept_8_2019", "persons")
  ExTypesense.upsert_collection_alias(ExTypesense.Connection.new(), "persons_sept_8_2019", MyModule.Accounts.Person)
  ```
  """
  @doc since: "0.8.0"
  @spec upsert_collection_alias(
          map() | OpenApiTypesense.Connection.t(),
          String.t(),
          String.t() | module()
        ) ::
          {:ok, OpenApiTypesense.CollectionAlias.t()} | {:error, OpenApiTypesense.ApiResponse.t()}
  def upsert_collection_alias(conn, alias_name, collection_name)
      when is_binary(collection_name) do
    body = %{"collection_name" => collection_name}
    OpenApiTypesense.Collections.upsert_alias(conn, alias_name, body)
  end

  def upsert_collection_alias(conn, alias_name, module) when is_atom(module) do
    collection_name = module.__schema__(:source)
    body = %{"collection_name" => collection_name}
    OpenApiTypesense.Collections.upsert_alias(conn, alias_name, body)
  end

  @doc """
  Deletes a collection alias. The collection itself
  is not affected by this action.
  """
  @doc since: "0.8.0"
  @spec delete_collection_alias(String.t()) ::
          {:ok, OpenApiTypesense.CollectionAlias.t()} | {:error, OpenApiTypesense.ApiResponse.t()}
  def delete_collection_alias(alias_name) when is_binary(alias_name) do
    ExTypesense.Connection.new() |> delete_collection_alias(alias_name)
  end

  @doc """
  Same as [delete_collection_alias/1](`delete_collection_alias/1`) but passes another connection.

  ```elixir
  ExTypesense.delete_collection_alias(%{api_key: xyz, host: ...}, "persons_sept_8_2019")
  ExTypesense.delete_collection_alias(ExTypesense.Connection.new(), "persons_sept_8_2019")
  ```
  """
  @doc since: "0.8.0"
  @spec delete_collection_alias(map() | OpenApiTypesense.Connection.t(), String.t()) ::
          {:ok, OpenApiTypesense.CollectionAlias.t()} | {:error, OpenApiTypesense.ApiResponse.t()}
  def delete_collection_alias(conn, alias_name) when is_binary(alias_name) do
    OpenApiTypesense.Collections.delete_alias(conn, alias_name)
  end
end
