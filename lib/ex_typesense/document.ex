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
  def get_document(conn \\ Connection.new(), module_name, document_id)

  def get_document(conn, module_name, document_id)
      when is_atom(module_name) and is_integer(document_id) do
    collection_name = module_name.__schema__(:source)
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
      ...>    post_id: 34,
      ...>    title: "the quick brown fox",
      ...>    description: "jumps over the lazy dog"
      ...>  }
      iex> ExTypesense.create_document(post)
      {:ok,
        %{
          "id" => "34",
          "collection_name" => "posts",
          "post_id" => 34,
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
      ...>    post_id: 94,
      ...>    title: "the quick brown fox"
      ...>  }
      iex> ExTypesense.create_document(post)
      iex> updated_post =
      ...>  %{
      ...>    id: "94",
      ...>    collection_name: "posts",
      ...>    post_id: 94,
      ...>    title: "test"
      ...>  }
      iex> ExTypesense.update_document(updated_post)
      {:ok,
        %{
          "id" => "94",
          "collection_name" => "posts",
          "post_id" => 94,
          "title" => "test"
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
  Deletes a document by struct.
  """
  @doc since: "0.4.0"
  @spec delete_document_by_struct(Connection.t(), struct()) :: response()
  def delete_document_by_struct(conn \\ Connection.new(), struct) when is_struct(struct) do
    document_id = struct.id
    collection_name = struct.__struct__.__schema__(:source)
    do_delete_document(conn, collection_name, document_id)
  end

  @doc """
  Deletes a document by collection name and document id.

  ## Examples
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
      ...>    post_id: 22,
      ...>    title: "the quick brown fox"
      ...>  }
      iex> ExTypesense.create_document(post)
      iex> ExTypesense.delete_document("posts", 12)
      {:ok,
        %{
          "id" => "12",
          "post_id" => 22,
          "title" => "the quick brown fox",
          "collection_name" => "posts"
        }
      }
  """
  @doc since: "0.4.0"
  @spec delete_document_by_id(Connection.t(), String.t(), integer()) :: response()
  def delete_document_by_id(conn \\ Connection.new(), collection_name, document_id)
      when is_binary(collection_name) and is_integer(document_id) do
    do_delete_document(conn, collection_name, document_id)
  end

  @doc since: "0.4.0"
  @spec do_delete_document(Connection.t(), String.t(), integer()) :: response()
  defp do_delete_document(conn, collection_name, document_id) do
    path =
      Path.join([
        @collections_path,
        collection_name,
        @documents_path,
        Jason.encode!(document_id)
      ])

    HttpClient.request(conn, %{method: :delete, path: path})
  end

  @doc """
  Deletes a document by struct.
  """
  @doc since: "0.3.0"
  @deprecated "use delete_document_by_struct/2"
  @spec delete_document(struct()) :: response()
  def delete_document(struct) when is_struct(struct) do
    document_id = struct.id
    collection_name = struct.__struct__.__schema__(:source)
    do_delete_document(collection_name, document_id)
  end

  @doc """
  Deletes a document by id.

  ## Examples
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
      ...>    post_id: 22,
      ...>    title: "the quick brown fox"
      ...>  }
      iex> ExTypesense.create_document(post)
      iex> ExTypesense.delete_document("posts", 12)
      {:ok,
        %{
          "id" => "12",
          "post_id" => 22,
          "title" => "the quick brown fox",
          "collection_name" => "posts"
        }
      }
  """
  @doc since: "0.3.0"
  @deprecated "use delete_document_by_id/3"
  @spec delete_document(String.t(), integer()) :: response()
  def delete_document(collection_name, document_id)
      when is_binary(collection_name) and is_integer(document_id) do
    do_delete_document(collection_name, document_id)
  end

  @deprecated "use do_delete_document/3"
  defp do_delete_document(collection_name, document_id) do
    path =
      Path.join([
        @collections_path,
        collection_name,
        @documents_path,
        Jason.encode!(document_id)
      ])

    HttpClient.run(:delete, path)
  end
end
