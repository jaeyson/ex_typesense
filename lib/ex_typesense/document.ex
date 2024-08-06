defmodule ExTypesense.Document do
  @moduledoc since: "0.1.0"
  @moduledoc """
  Module for CRUD operations for documents. Refer to this [doc guide](https://typesense.org/docs/latest/api/documents.html).
  """

  alias ExTypesense.Connection
  alias ExTypesense.HttpClient
  import Ecto.Query, warn: false

  @root_path "/"
  @collections_path @root_path <> "collections"
  @documents_path "documents"
  @import_path "import"

  @typedoc since: "0.1.0"
  @type response :: :ok | {:ok, map()} | {:error, map()}

  @doc """
  Get a document from a collection.

  ## Examples
      iex> schema = %{
      ...>   name: "posts",
      ...>   fields: [
      ...>     %{name: "title", type: "string"}
      ...>   ],
      ...> }
      ...> ExTypesense.create_collection(schema)
      ...> post = %{
      ...>    id: "444",
      ...>    collection_name: "posts",
      ...>    title: "the quick brown fox"
      ...> }
      iex> ExTypesense.create_document(post)
      iex> ExTypesense.get_document("posts", 444)
      {:ok,
        %{
          "id" => "444",
          "collection_name" => "posts",
          "title" => "the quick brown fox",
        }
      }
  """
  @doc since: "0.1.0"
  @spec get_document(Connection.t(), module() | String.t(), integer()) :: response()
  def get_document(conn \\ Connection.new(), collection_name, document_id)

  def get_document(conn, collection_name, document_id)
      when is_atom(collection_name) and is_integer(document_id) do
    collection_name = collection_name.__schema__(:source)
    do_get_document(conn, collection_name, document_id)
  end

  def get_document(conn, collection_name, document_id)
      when is_binary(collection_name) and is_integer(document_id) do
    do_get_document(conn, collection_name, document_id)
  end

  @spec do_get_document(Connection.t(), String.t() | module(), integer()) :: response()
  defp do_get_document(conn, collection_name, document_id) do
    path =
      [
        @collections_path,
        collection_name,
        @documents_path,
        to_string(document_id)
      ]
      |> Path.join()

    HttpClient.request(conn, %{method: :get, path: path})
  end

  @doc """
  Indexes multiple documents via maps.

  **Note**: when using maps as documents, you should pass a key named `collection_name`
  and with the lists of documents named `documents` (example shown below).

  ## Examples
      iex> schema = %{
      ...>   name: "posts",
      ...>   fields: [
      ...>     %{name: "title", type: "string"}
      ...>   ],
      ...> }
      ...> ExTypesense.create_collection(schema)
      ...> posts = %{
      ...>   collection_name: "posts",
      ...>   documents: [
      ...>     %{title: "the quick brown fox"},
      ...>     %{title: "jumps over the lazy dog"}
      ...>   ]
      ...> }
      iex> ExTypesense.index_multiple_documents(posts)
      {:ok, [%{"success" => true}, %{"success" => true}]}
  """
  @doc since: "0.1.0"
  @spec index_multiple_documents(Connection.t(), list(struct()) | map()) :: response()
  def index_multiple_documents(conn \\ Connection.new(), list_of_structs)

  def index_multiple_documents(conn, [struct | _] = list_of_structs)
      when is_struct(struct) do
    collection_name = struct.__struct__.__schema__(:source)
    do_index_multiple_documents(conn, collection_name, "create", list_of_structs)
  end

  def index_multiple_documents(
        conn,
        %{collection_name: collection_name, documents: documents} = map
      )
      when is_map(map) do
    do_index_multiple_documents(conn, collection_name, "create", documents)
  end

  @doc """
  Updates multiple documents via maps.

  **Note**: when using maps as documents, you should pass a key named `collection_name`
  and with the lists of documents named `documents` (example shown below). Also add the `id`
  for each documents.

  ## Examples
      iex> schema = %{
      ...>   name: "posts",
      ...>   fields: [
      ...>     %{name: "title", type: "string"}
      ...>   ],
      ...> }
      iex> ExTypesense.create_collection(schema)
      iex> posts = %{
      ...>   collection_name: "posts",
      ...>   documents: [
      ...>     %{id: "5", title: "the quick brown fox"},
      ...>     %{id: "6", title: "jumps over the lazy dog"}
      ...>   ]
      ...> }
      iex> {:ok, _} = ExTypesense.index_multiple_documents(posts)
      iex> updated_posts = %{
      ...>   collection_name: "posts",
      ...>   documents: [
      ...>     %{id: "5", title: "the quick"},
      ...>     %{id: "6", title: "jumps over"}
      ...>   ]
      ...> }
      iex> ExTypesense.update_multiple_documents(updated_posts)
      {:ok, [%{"success" => true}, %{"success" => true}]}
  """
  @doc since: "0.3.0"
  @spec update_multiple_documents(Connection.t(), list(struct()) | map()) :: response()
  def update_multiple_documents(conn \\ Connection.new(), list_of_structs)

  def update_multiple_documents(conn, [struct | _] = list_of_structs) when is_struct(struct) do
    collection_name = struct.__struct__.__schema__(:source)
    do_index_multiple_documents(conn, collection_name, "update", list_of_structs)
  end

  def update_multiple_documents(
        conn,
        %{collection_name: collection_name, documents: documents} = map
      )
      when is_map(map) do
    do_index_multiple_documents(conn, collection_name, "update", documents)
  end

  @doc """
  Upserts multiple documents via maps. Same with `update_multiple_documents/1` with some
  difference: creates one if not existed, otherwise updates it.

  **Note**: when using maps as documents, you should pass a key named `collection_name`
  and with the lists of documents named `documents` (example shown below). When `id` is added,
  it will update, otherwise creates a new document.
  for each documents.

  ## Examples
      iex> schema = %{
      ...>   name: "posts",
      ...>   fields: [
      ...>     %{name: "title", type: "string"}
      ...>   ],
      ...> }
      iex> ExTypesense.create_collection(schema)
      iex> posts = %{
      ...>   collection_name: "posts",
      ...>   documents: [
      ...>     %{id: "0", title: "the quick"},
      ...>     %{id: "1", title: "jumps over"}
      ...>   ]
      ...> }
      iex> ExTypesense.upsert_multiple_documents(posts)
      {:ok, [%{"success" => true}, %{"success" => true}]}
  """
  @doc since: "0.3.0"
  @spec upsert_multiple_documents(Connection.t(), map()) :: response()
  def upsert_multiple_documents(conn \\ Connection.new(), map)

  def upsert_multiple_documents(
        conn,
        %{collection_name: collection_name, documents: documents} = map
      )
      when is_map(map) do
    do_index_multiple_documents(conn, collection_name, "upsert", documents)
  end

  def upsert_multiple_documents(_, _),
    do: {:error, ~s(It should be type of map, ":documents" key should contain list of maps)}

  @spec do_index_multiple_documents(Connection.t(), String.t(), String.t(), [struct()] | [map()]) ::
          response()
  defp do_index_multiple_documents(conn, collection_name, action, documents) do
    HttpClient.request(conn, %{
      method: :post,
      path: Path.join([@collections_path, collection_name, @documents_path, @import_path]),
      query: %{action: action},
      body: Enum.map_join(documents, "\n", &Jason.encode!/1),
      content_type: "text/plain"
    })
  end

  @doc """
  Indexes a single document using struct or map. When using struct,
  the pk maps to document's id as string.

  **Note**: when using maps as documents, you should pass a key named "collection_name".

  ## Examples
      iex> schema = %{
      ...>   name: "posts",
      ...>   fields: [
      ...>     %{name: "title", type: "string"}
      ...>   ],
      ...> }
      iex> ExTypesense.create_collection(schema)
      iex> post =
      ...>  %{
      ...>    id: "34",
      ...>    collection_name: "posts",
      ...>    posts_id: 34,
      ...>    title: "the quick brown fox",
      ...>    description: "jumps over the lazy dog"
      ...>  }
      iex> ExTypesense.create_document(post)
      {:ok,
        %{
          "id" => "34",
          "collection_name" => "posts",
          "posts_id" => 34,
          "title" => "the quick brown fox",
          "description" => "jumps over the lazy dog"
        }
      }
  """
  @doc since: "0.3.0"
  @spec create_document(Connection.t(), struct() | map() | [struct()] | [map()]) :: response()
  def create_document(conn \\ Connection.new(), struct)

  def create_document(conn, struct) when is_struct(struct) do
    collection_name = struct.__struct__.__schema__(:source)
    path = Path.join([@collections_path, collection_name, @documents_path])
    payload = Jason.encode!(struct)
    do_index_document(conn, path, :post, "create", payload)
  end

  def create_document(conn, document) when is_map(document) do
    collection_name = Map.get(document, :collection_name)
    path = Path.join([@collections_path, collection_name, @documents_path])
    do_index_document(conn, path, :post, "create", Jason.encode!(document))
  end

  @doc """
  Updates a single document using struct or map.

  **Note**: when using maps as documents, you should pass a key named "collection_name".

  ## Examples
      iex> schema = %{
      ...>   name: "posts",
      ...>   fields: [
      ...>     %{name: "title", type: "string"}
      ...>   ],
      ...> }
      iex> ExTypesense.create_collection(schema)
      iex> post =
      ...>  %{
      ...>    id: "94",
      ...>    collection_name: "posts",
      ...>    posts_id: 94,
      ...>    title: "the quick brown fox"
      ...>  }
      iex> ExTypesense.create_document(post)
      iex> updated_post =
      ...>  %{
      ...>    id: "94",
      ...>    collection_name: "posts",
      ...>    posts_id: 94,
      ...>    title: "test"
      ...>  }
      iex> ExTypesense.update_document(updated_post)
      {:ok,
        %{
          "id" => "94",
          "collection_name" => "posts",
          "posts_id" => 94,
          "title" => "sample post"
        }
      }
  """
  @doc since: "0.3.0"
  @spec update_document(Connection.t(), struct() | map()) :: response()
  def update_document(conn \\ Connection.new(), struct)

  def update_document(conn, struct) when is_struct(struct) do
    collection_name = struct.__struct__.__schema__(:source)

    path =
      Path.join([@collections_path, collection_name, @documents_path, Jason.encode!(struct.id)])

    do_index_document(conn, path, :patch, "update", Jason.encode!(struct))
  end

  def update_document(conn, document) when is_map(document) do
    id = String.to_integer(document.id)
    collection_name = Map.get(document, :collection_name)
    path = Path.join([@collections_path, collection_name, @documents_path, Jason.encode!(id)])
    do_index_document(conn, path, :patch, "update", Jason.encode!(document))
  end

  @doc """
  Upserts a single document using struct or map.

  **Note**: when using maps as documents, you should pass a key named "collection_name".

  """
  @doc since: "0.3.0"
  @spec upsert_document(Connection.t(), map() | struct()) :: response()
  def upsert_document(conn \\ Connection.new(), struct)

  def upsert_document(conn, struct) when is_struct(struct) do
    id = to_string(struct.id)
    collection_name = struct.__struct__.__schema__(:source)
    document = Map.put(struct, :id, id) |> Jason.encode!()
    path = Path.join([@collections_path, collection_name, @documents_path])
    do_index_document(conn, path, :post, "upsert", document)
  end

  def upsert_document(conn, document) when is_map(document) do
    collection_name = Map.get(document, :collection_name)
    id = document.id

    document =
      if is_integer(id) do
        document |> Map.put(:id, Jason.encode!(id)) |> Jason.encode!()
      else
        document |> Jason.encode!()
      end

    path = Path.join([@collections_path, collection_name, @documents_path])
    do_index_document(conn, path, :post, "upsert", document)
  end

  @spec do_index_document(Connection.t(), String.t(), atom(), String.t(), String.t()) ::
          response()
  defp do_index_document(conn, path, method, action, document) do
    opts = %{
      method: method,
      path: path,
      query: %{action: action},
      body: document
    }

    HttpClient.request(conn, opts)
  end

  @doc """
  Deletes a document by id or struct.

  > #### Deleting a document by id {: .info}
  >
  > If you are deleting by id, pass it as a tuple (`{"collection_name", 23}`)

  ## Examples
      iex> ExTypesense.create_collection(Post)
      iex> post = Post |> limit(1) |> Repo.one()
      iex> ExTypesense.create_collection(post)
      iex> ExTypesense.delete_document(post)
      {:ok,
        %{
          "id" => "1",
          "posts_id" => 1,
          "title" => "our first post",
          "collection_name" => "posts"
        }
      }

      iex> schema = %{
      ...>   name: "posts",
      ...>   fields: [
      ...>     %{name: "title", type: "string"}
      ...>   ],
      ...> }
      ...> ExTypesense.create_collection(schema)
      iex> post =
      ...>  %{
      ...>    id: "12",
      ...>    collection_name: "posts",
      ...>    posts_id: 22,
      ...>    title: "the quick brown fox"
      ...>  }
      iex> ExTypesense.create_document(post)
      iex> ExTypesense.delete_document({"posts", 12})
      {:ok,
        %{
          "id" => "12",
          "posts_id" => 22,
          "title" => "the quick brown fox",
          "collection_name" => "posts"
        }
      }
  """
  @doc since: "0.3.0"
  @spec delete_document(Connection.t(), struct() | {String.t(), integer()}) :: response()
  def delete_document(conn \\ Connection.new(), struct_or_tuple)

  def delete_document(conn, struct) when is_struct(struct) do
    # document_id = struct.id
    collection_name = struct.__struct__.__schema__(:source)
    # delete_document(conn, {collection_name, document_id})
    filter_by =
      :virtual_fields
      |> struct.__struct__.__schema__()
      |> Enum.filter(&String.contains?(to_string(&1), "_id"))
      |> Enum.map_join(" || ", fn virtual_field ->
        value = Map.get(struct, virtual_field)
        "#{virtual_field}:#{value}"
      end)

    delete_documents_by_query(conn, collection_name, %{filter_by: filter_by})
  end

  def delete_document(conn, {collection_name, document_id} = _tuple)
      when is_binary(collection_name) and is_integer(document_id) do
    do_delete_document(conn, collection_name, document_id)
  end

  @spec do_delete_document(Connection.t(), String.t(), integer()) :: response()
  defp do_delete_document(conn, collection_name, document_id) do
    path =
      Path.join([
        @collections_path,
        collection_name,
        @documents_path,
        Jason.encode!(document_id)
      ])

    opts = %{
      method: :delete,
      path: path
    }

    HttpClient.request(conn, opts)
  end

  @doc """
  Deletes documents in a collection by query.

  > #### [Filter and batch size](https://typesense.org/docs/latest/api/documents.html#delete-by-query) {: .info}
  >
  > To delete all documents in a collection, you can use a filter that
  > matches all documents in your collection. For eg, if you have an
  > int32 field called popularity in your documents, you can use
  > `filter_by: "popularity:>0"` to delete all documents. Or if you have a
  > bool field called `in_stock` in your documents, you can use
  > `filter_by: "in_stock:[true,false]"` to delete all documents.
  >
  > Use the `batch_size` to control the number of documents that should
  > deleted at a time. A larger value will speed up deletions, but will
  > impact performance of other operations running on the server.
  >
  > Filter parameters can be found here: https://typesense.org/docs/latest/api/search.html#filter-parameters

  ## Examples
      iex> query = %{
      ...>   filter_by: "num_employees:>100",
      ...>   batch_size: 100
      ...> }
      iex> ExTypesense.delete_documents_by_query(Employee, query)
      {:ok, %{}}
  """
  @doc since: "0.5.0"
  @spec delete_documents_by_query(
          Connection.t(),
          module() | String.t(),
          %{
            filter_by: String.t(),
            batch_size: integer() | nil
          }
        ) ::
          response()
  def delete_documents_by_query(conn \\ Connection.new(), collection_name, query)

  def delete_documents_by_query(conn, collection_name, %{filter_by: filter_by} = query)
      when not is_nil(filter_by) and is_binary(filter_by) and is_atom(collection_name) do
    collection_name = collection_name.__schema__(:source)
    path = Path.join([@collections_path, collection_name, @documents_path])
    HttpClient.request(conn, %{method: :delete, path: path, query: query})
  end

  def delete_documents_by_query(conn, collection_name, %{filter_by: filter_by} = query)
      when not is_nil(filter_by) and is_binary(filter_by) and is_binary(collection_name) do
    path = Path.join([@collections_path, collection_name, @documents_path])
    HttpClient.request(conn, %{method: :delete, path: path, query: query})
  end

  @doc """
  Deletes all documents in a collection.

  > #### On using this function {: .info}
  > As of this writing (v0.5.0), there's no built-in way of deleting
  > all documents via [Typesense docs](https://github.com/typesense/typesense/issues/1613#issuecomment-1994986258).
  > This function uses `delete_by_query` under the hood.
  """
  @doc since: "0.5.0"
  @spec delete_all_documents(Connection.t(), module() | String.t()) :: response()
  def delete_all_documents(conn \\ Connection.new(), collection_name)

  def delete_all_documents(conn, collection_name) when is_binary(collection_name) do
    delete_documents_by_query(conn, collection_name, %{filter_by: "id:*"})
  end

  def delete_all_documents(conn, collection_name) when is_atom(collection_name) do
    name = collection_name.__schema__(:source)

    virtual_field =
      :virtual_fields
      |> collection_name.__schema__()
      |> Enum.filter(&String.contains?(to_string(&1), "_id"))
      |> hd()
      |> to_string

    delete_documents_by_query(conn, name, %{filter_by: "#{virtual_field}:>=0"})
  end
end
