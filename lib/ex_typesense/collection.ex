defmodule ExTypesense.Collection do
  alias ExTypesense.HttpClient

  defmodule Schema do
    @derive Jason.Encoder
    @enforce_keys [:name, :type]
    defstruct [
      :facet,
      :index,
      :infix,
      :locale,
      :name,
      :optional,
      :sort,
      :type
    ]

    @type t() :: %__MODULE__{
            facet: boolean(),
            index: boolean(),
            infix: boolean(),
            locale: String.t(),
            name: String.t(),
            optional: boolean(),
            sort: boolean(),
            type: field_type()
          }

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
  end

  @moduledoc since: "0.1.0"
  @moduledoc """
  Module for creating, listing and deleting collections and aliases.

  In Typesense, a [Collection](https://typesense.org/docs/latest/api/collections.html) is a group of related [Documents](https://typesense.org/docs/latest/api/documents.html) that is roughly equivalent to a table in a relational database. When we create a collection, we give it a name and describe the fields that will be indexed when a document is added to the collection.
  """

  @collections_path "/collections"
  @alias_path "/aliases"

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
    :fields,
    num_documents: 0,
    token_separators: [],
    symbols_to_index: []
  ]

  @type t() :: %__MODULE__{
          created_at: String.t(),
          name: String.t(),
          default_sorting_field: String.t(),
          fields: Schema.t(),
          num_documents: integer(),
          token_separators: list(),
          symbols_to_index: list()
        }

  @type response() :: {:ok, %__MODULE__{}} | {:ok, map()} | {:error, map()}

  @doc """
  Lists all collections.
  """
  @doc since: "0.1.0"
  @spec list_collections() :: response()
  def list_collections do
    case HttpClient.run(:get, @collections_path) do
      {:ok, collections} ->
        {:ok, Enum.map(collections, &map_to_struct/1)}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Get a specific collection using collection name.
  """
  @doc since: "0.1.0"
  @spec get_collection(String.t()) :: response()
  def get_collection(collection_name) do
    path = Path.join([@collections_path, collection_name])

    case HttpClient.run(:get, path) do
      {:ok, collection} ->
        {:ok, map_to_struct(collection)}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Create collection from map or `Collection` struct.

  ## Examples
       collection =
        %{
         name: "companies",
         fields: [
           %{name: "company_name", type: "string"},
           %{name: "num_employees", type: "int32"},
           %{name: "country", type: "string", facet: true}
         ],
         default_sorting_field: "num_employees"
        }
      iex> ExTypesense.create_collection(collection)
      %{
        "created_at" => 1234567890,
        "default_sorting_field" => "num_employees",
        "fields" => [...],
        "name" => "companies",
        "num_documents" => 0,
        "symbols_to_index" => [],
        "token_separators" => []
      }

      iex> %Collection{name: "company", fields: [...]}
      {:ok,
        %{
          "created_at" => 1234567891,
          "default_sorting_field" => "num_employees",
          "fields" => [...],
          "name" => "companies",
          "num_documents" => 0,
          "symbols_to_index" => [],
          "token_separators" => []
        }
      }
  """
  @doc since: "0.1.0"
  @spec create_collection(collection :: map() | %__MODULE__{}) :: response()
  def create_collection(collection) do
    body = Jason.encode!(collection)

    case HttpClient.run(:post, @collections_path, body) do
      {:ok, collection} ->
        {:ok, map_to_struct(collection)}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Make changes in a collection's fields: adding, removing
  or updating an existing field(s). Key name is `drop` to
  indicate which field is removed (example described below).

  > **Note**: Typesense supports updating all fields
  > except the `id` field (since it's a special field
  > within Typesense).

  ## Examples
       collection =
        %{
         fields: [
           %{name: "num_employees", drop: true},
           %{name: "company_category", type: "string"},
         ],
        }

      iex> ExTypesense.update_collection(collection)
      {:ok,
        %{
          "fields" => [
            %{"drop" => true, "name" => "num_employees"},
            %{
              "facet" => false,
              "index" => true,
              ...
            }
          ]
        }
      }
  """
  @doc since: "0.1.0"
  @spec update_collection(String.t(), collection :: map() | %__MODULE__{}) :: response()
  def update_collection(collection_name, collection) do
    path = Path.join([@collections_path, collection_name])
    body = Jason.encode!(collection)

    case HttpClient.run(:patch, path, body) do
      {:ok, collection} ->
        {:ok, map_to_struct(collection)}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Deletes a collection using collection name.
  """
  @doc since: "0.1.0"
  @spec delete_collection(String.t()) :: response()
  def delete_collection(collection_name) do
    path = Path.join([@collections_path, collection_name])

    case HttpClient.run(:delete, path) do
      {:ok, collection} ->
        {:ok, map_to_struct(collection)}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  List all aliases and the corresponding collections that they map to.
  """
  @doc since: "0.1.0"
  @spec list_collection_aliases() :: response()
  def list_collection_aliases do
    HttpClient.run(:get, @alias_path)
  end

  @doc """
  Get a specific collection alias.
  """
  @doc since: "0.1.0"
  @spec get_collection_alias(String.t()) :: response()
  def get_collection_alias(alias_name) do
    path = Path.join([@collections_path, alias_name])

    HttpClient.run(:get, path)
  end

  @doc """
  Upserts a collection alias.
  """
  @doc since: "0.1.0"
  @spec upsert_collection_alias(String.t(), String.t()) :: response()
  def upsert_collection_alias(alias_name, collection_name) do
    path = Path.join([@collections_path, alias_name])
    body = Jason.encode!(%{collection_name: collection_name})

    HttpClient.run(:put, path, body)
  end

  @doc """
  Deletes a collection alias. The collection itself
  is not affected by this action.
  """
  @doc since: "0.1.0"
  @spec delete_collection_alias(String.t()) :: response()
  def delete_collection_alias(alias_name) do
    path = Path.join([@collections_path, alias_name])

    HttpClient.run(:delete, path)
  end

  @spec map_to_struct(map()) :: %__MODULE__{}
  def map_to_struct(collection) do
    collection =
      collection
      |> Map.new(fn {key, val} ->
        if key === "fields" do
          # converting %{"name" => "sample", ...}
          # to %{name: "sample", ...}
          # finally into %Schema struct
          # because struct doesn't accept
          # string keys, but atoms instead.
          fields =
            Enum.map(val, fn map ->
              schema =
                Map.new(map, fn {field_key, field_val} ->
                  {String.to_atom(field_key), field_val}
                end)

              struct(Schema, schema)
            end)

          {:fields, fields}
        else
          {String.to_atom(key), val}
        end
      end)

    struct(__MODULE__, collection)
  end
end
