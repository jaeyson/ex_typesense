defmodule ExTypesense.Collection do
  @moduledoc since: "0.1.0"
  @moduledoc """
  Module for creating, listing and deleting collections and aliases.

  In Typesense, a [Collection](https://typesense.org/docs/latest/api/collections.html) is a group of related [Documents](https://typesense.org/docs/latest/api/documents.html) that is roughly equivalent to a table in a relational database. When we create a collection, we give it a name and describe the fields that will be indexed when a document is added to the collection.
  """

  alias ExTypesense.Connection
  alias ExTypesense.HttpClient

  defmodule Field do
    @moduledoc since: "0.1.0"
    @derive Jason.Encoder
    @enforce_keys [:name, :type]

    defstruct [
      :facet,
      :index,
      :infix,
      :locale,
      :name,
      :nested,
      :nested_array,
      :num_dim,
      :optional,
      :sort,
      :type,
      :vec_dist,
      :store,
      :reference,
      :range_index,
      :stem
    ]

    @typedoc since: "0.1.0"
    @type t() :: %__MODULE__{
            facet: boolean(),
            index: boolean(),
            infix: boolean(),
            locale: String.t(),
            name: String.t(),
            nested: boolean(),
            nested_array: integer(),
            num_dim: integer(),
            optional: boolean(),
            sort: boolean(),
            type: field_type(),
            vec_dist: String.t(),
            store: boolean(),
            reference: String.t(),
            range_index: boolean(),
            stem: boolean()
          }

    @typedoc since: "0.1.0"
    @type field_type() ::
            :string
            | :"string[]"
            | :int32
            | :"int32[]"
            | :int64
            | :"int64[]"
            | :float
            | :"float[]"
            | :bool
            | :"bool[]"
            | :geopoint
            | :"geopoint[]"
            | :object
            | :"object[]"
            | :"string*"
            | :image
            | :auto
  end

  @collections_path "/collections"
  @aliases_path "/aliases"

  @derive Jason.Encoder
  @enforce_keys [
    :created_at,
    :name,
    :fields,
    :default_sorting_field
  ]

  defstruct [
    :created_at,
    :name,
    :default_sorting_field,
    :enable_nested_fields,
    :fields,
    num_documents: 0,
    token_separators: [],
    symbols_to_index: []
  ]

  @type t() :: %__MODULE__{
          created_at: integer(),
          name: String.t(),
          default_sorting_field: String.t(),
          enable_nested_fields: boolean(),
          fields: Field.t(),
          num_documents: integer(),
          token_separators: list(),
          symbols_to_index: list()
        }

  @typedoc since: "0.1.0"
  @type response() :: t() | [t() | map()] | map() | {:error, map()}

  @doc """
  Lists all collections.
  """
  @doc since: "0.1.0"
  @spec list_collections(Connection.t()) :: response()
  def list_collections(conn \\ Connection.new()) do
    case HttpClient.request(conn, %{method: :get, path: @collections_path}) do
      {:ok, collections} ->
        Stream.map(collections, &convert_to_struct/1) |> Enum.to_list()

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Get the collection name by alias.
  """
  @doc since: "0.3.0"
  @spec get_collection_name(Connection.t(), String.t() | module()) :: String.t()
  def get_collection_name(conn \\ Connection.new(), alias_name) do
    conn
    |> get_collection_alias(alias_name)
    |> Map.get("collection_name")
  end

  @doc """
  Get a specific collection by string or module name.
  """
  @doc since: "0.1.0"
  @spec get_collection(Connection.t(), String.t() | module()) :: response()
  def get_collection(conn \\ Connection.new(), name)

  def get_collection(conn, name) when is_atom(name) do
    collection_name = name.__schema__(:source)
    path = Path.join([@collections_path, collection_name])
    do_get_collection(conn, path)
  end

  def get_collection(conn, name) when is_binary(name) do
    path = Path.join([@collections_path, name])
    do_get_collection(conn, path)
  end

  defp do_get_collection(conn, path) do
    case HttpClient.request(conn, %{method: :get, path: path}) do
      {:ok, collection} ->
        convert_to_struct(collection)

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Create collection from a map, or module name. Collection name is matched on table name if using Ecto schema by default.

  Please refer to these [list of schema params](https://typesense.org/docs/latest/api/collections.html#schema-parameters).

  ## Examples
      iex> schema = %{
      ...>   name: "companies",
      ...>   fields: [
      ...>     %{name: "company_name", type: "string"},
      ...>     %{name: "company_id", type: "int32"},
      ...>     %{name: "country", type: "string", facet: true}
      ...>   ],
      ...>   default_sorting_field: "company_id"
      ...> }
      iex> ExTypesense.create_collection(schema)
      %ExTypesense.Collection{
        created_at: 1234567890,
        default_sorting_field: "company_id",
        fields: [...],
        name: "companies",
        num_documents: 0,
        symbols_to_index: [],
        token_separators: []
      }

      iex> ExTypesense.create_collection(Person)
      %ExTypesense.Collection{
        created_at: 1234567890,
        default_sorting_field: "person_id",
        fields: [...],
        name: "persons",
        num_documents: 0,
        symbols_to_index: [],
        token_separators: []
      }
  """
  @doc since: "0.1.0"
  @spec create_collection(Connection.t(), schema :: module() | map()) :: response()
  def create_collection(conn \\ Connection.new(), schema)

  def create_collection(conn, schema) when is_atom(schema) do
    schema =
      schema.get_field_types()
      |> Map.put(:name, schema.__schema__(:source))

    do_create_collection(conn, schema)
  end

  def create_collection(conn, schema) when is_map(schema) do
    schema = Map.put(schema, :name, schema[:name])

    do_create_collection(conn, schema)
  end

  def create_collection(_conn, _schema), do: {:error, "wrong argument(s) passed"}

  defp do_create_collection(conn, schema) do
    body = Jason.encode!(schema)

    case HttpClient.request(conn, %{method: :post, path: @collections_path, body: body}) do
      {:ok, collection} ->
        convert_to_struct(collection)

      {:error, reason} ->
        {:error, reason}
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
      %ExTypesense.Collection{
        created_at: 1234567890,
        name: companies,
        default_sorting_field: "company_id",
        fields: [...],
        num_documents: 0,
        symbols_to_index: [],
        token_separators: []
      }

      iex> ExTypesense.update_collection_fields(Company, fields)
      %ExTypesense.Collection{
        created_at: 1234567890,
        name: companies,
        default_sorting_field: "company_id",
        fields: [...],
        num_documents: 0,
        symbols_to_index: [],
        token_separators: []
      }
  """
  @doc since: "0.1.0"
  @spec update_collection_fields(Connection.t(), name :: String.t() | module(), map()) ::
          response()
  def update_collection_fields(conn \\ Connection.new(), name, fields \\ %{})

  def update_collection_fields(conn, name, fields) when is_atom(name) do
    collection_name = name.__schema__(:source)

    path = Path.join([@collections_path, collection_name])
    do_update_collection_fields(conn, path, Jason.encode!(fields))
  end

  def update_collection_fields(conn, name, fields) when is_binary(name) do
    path = Path.join([@collections_path, name])
    do_update_collection_fields(conn, path, Jason.encode!(fields))
  end

  def update_collection_fields(_conn, _name, _schema), do: {:error, "wrong argument(s) passed"}

  defp do_update_collection_fields(conn, path, body) do
    case HttpClient.request(conn, %{method: :patch, path: path, body: body}) do
      {:ok, collection} ->
        convert_to_struct(collection)

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Permanently drops a collection by collection name or module name.

  **Note**: dropping a collection does not remove the referenced alias, only the indexed documents.
  """
  @doc since: "0.1.0"
  @spec drop_collection(Connection.t(), name :: String.t() | module()) :: response()
  def drop_collection(conn \\ Connection.new(), name)

  def drop_collection(conn, name) when is_atom(name) do
    collection_name = name.__schema__(:source)

    path = Path.join([@collections_path, collection_name])
    do_drop_collection(conn, path)
  end

  def drop_collection(conn, name) when is_binary(name) do
    path = Path.join([@collections_path, name])
    do_drop_collection(conn, path)
  end

  defp do_drop_collection(conn, path) do
    case HttpClient.request(conn, %{method: :delete, path: path}) do
      {:ok, collection} ->
        convert_to_struct(collection)

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  List all aliases and the corresponding collections that they map to.
  """
  @doc since: "0.1.0"
  @spec list_collection_aliases(Connection.t()) :: response()
  def list_collection_aliases(conn \\ Connection.new()) do
    case HttpClient.request(conn, %{method: :get, path: @aliases_path}) do
      {:ok, %{"aliases" => aliases}} ->
        aliases

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Get a specific collection alias by string or module name.
  """
  @doc since: "0.1.0"
  @spec get_collection_alias(Connection.t(), String.t() | module()) :: response()
  def get_collection_alias(conn \\ Connection.new(), alias_name)

  def get_collection_alias(conn, alias_name) when is_atom(alias_name) do
    path = Path.join([@aliases_path, alias_name.__schema__(:source)])
    do_get_collection_alias(conn, path)
  end

  def get_collection_alias(conn, alias_name) when is_binary(alias_name) do
    path = Path.join([@aliases_path, alias_name])
    do_get_collection_alias(conn, path)
  end

  def get_collection_alias(_conn, _alias_name), do: {:error, "wrong argument(s) passed"}

  # @spec do_get_collection_alias(String.t()) :: response()
  defp do_get_collection_alias(conn, path) do
    case HttpClient.request(conn, %{method: :get, path: path}) do
      {:ok, collection_alias} ->
        collection_alias

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Upserts a collection alias.
  """
  @doc since: "0.1.0"
  @spec upsert_collection_alias(Connection.t(), String.t() | module(), String.t()) :: response()
  def upsert_collection_alias(conn \\ Connection.new(), alias_name, collection_name)

  def upsert_collection_alias(conn, alias_name, collection_name) when is_atom(alias_name) do
    path = Path.join([@aliases_path, alias_name.__schema__(:source)])
    body = Jason.encode!(%{collection_name: collection_name})
    do_upsert_collection_alias(conn, path, body)
  end

  def upsert_collection_alias(conn, alias_name, collection_name) when is_binary(alias_name) do
    path = Path.join([@aliases_path, alias_name])
    body = Jason.encode!(%{collection_name: collection_name})
    do_upsert_collection_alias(conn, path, body)
  end

  def upsert_collection_alias(_conn, _alias_name, _collection_name),
    do: {:error, "wrong argument(s) passed"}

  defp do_upsert_collection_alias(conn, path, body) do
    case HttpClient.request(conn, %{method: :put, path: path, body: body}) do
      {:ok, collection_alias} ->
        collection_alias

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Deletes a collection alias. The collection itself
  is not affected by this action.
  """
  @doc since: "0.1.0"
  @spec delete_collection_alias(Connection.t(), String.t() | module()) :: response()
  def delete_collection_alias(conn \\ Connection.new(), alias_name)

  def delete_collection_alias(conn, alias_name) when is_atom(alias_name) do
    path = Path.join([@aliases_path, alias_name.__schema__(:source)])
    do_delete_collection_alias(conn, path)
  end

  def delete_collection_alias(conn, alias_name) when is_binary(alias_name) do
    path = Path.join([@aliases_path, alias_name])
    do_delete_collection_alias(conn, path)
  end

  def delete_collection_alias(_conn, _alias_name), do: {:error, "wrong argument(s) passed"}

  defp do_delete_collection_alias(conn, path) do
    case HttpClient.request(conn, %{method: :delete, path: path}) do
      {:ok, collection_alias} ->
        collection_alias

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp convert_to_struct(collection) do
    collection =
      Map.new(collection, fn {k, v} ->
        if k === :fields do
          Map.new(v, fn {k, v} -> {String.to_existing_atom(k), v} end)
        else
          {String.to_existing_atom(k), v}
        end
      end)

    struct(__MODULE__, collection)
  end
end
