defmodule ExTypesense.Document do
  @moduledoc since: "0.1.0"

  @moduledoc """
  Module for CRUD operations for documents. Refer to this
  [doc guide](https://typesense.org/docs/latest/api/documents.html).
  """

  alias OpenApiTypesense.Connection

  @doc """
  Fetch an individual document from a collection by using its ID.

  ## Options

    * `include_fields`: (Comma-separated values) List of fields that should be present in the returned document.
    * `exclude_fields`: (Comma-separated values) List of fields that should not be present in the returned document.

  ## Examples
      iex> schema = %{
      ...>   name: "posts",
      ...>   fields: [
      ...>     %{name: "title", type: "string"}
      ...>   ],
      ...> }
      ...> ExTypesense.create_collection(schema)
      ...> post = %{
      ...>    id: "22"
      ...>    posts_id: 444,
      ...>    collection_name: "posts",
      ...>    title: "the quick brown fox"
      ...> }
      iex> ExTypesense.index_document(post)
      iex> ExTypesense.get_document("posts", "22", exclude_fields: "title,posts_id")
      {:ok,
        %{
          id: "22",
          collection_name: "posts"
        }
      }
  """
  @doc since: "1.0.0"
  @spec get_document(module() | String.t(), String.t()) ::
          {:ok, map} | {:error, OpenApiTypesense.ApiResponse.t()}
  def get_document(collection_name, document_id) when is_binary(document_id) do
    get_document(collection_name, document_id, [])
  end

  @doc """
  Same as [get_document/2](`get_document/2`).

  ```elixir
  ExTypesense.get_document("persons", "88", exclude_fields: "name")

  ExTypesense.get_document(MyModule.Accounts.Person, "88", exclude_fields: "name")

  ExTypesense.get_document(%{api_key: xyz, host: ...}, MyModule.Accounts.Person, "88")

  ExTypesense.get_document(OpenApiTypesense.Connection.new(), MyModule.Accounts.Person, "88")
  ```
  """
  @doc since: "1.0.0"
  @spec get_document(
          map() | Connection.t() | module() | String.t(),
          String.t() | module(),
          String.t() | keyword()
        ) ::
          {:ok, map} | {:error, OpenApiTypesense.ApiResponse.t()}
  def get_document(collection_name, document_id, opts) when is_list(opts) do
    Connection.new() |> get_document(collection_name, document_id, opts)
  end

  def get_document(conn, coll_name, doc_id) do
    get_document(conn, coll_name, doc_id, [])
  end

  @doc """
  Same as [get_document/3](`get_document/3`) but passes another connection.

  ```elixir
  ExTypesense.get_document(%{api_key: xyz, host: ...}, "persons", "88", exclude_fields: "name")

  ExTypesense.get_document(OpenApiTypesense.Connection.new(), MyModule.Accounts.Person, "88", exclude_fields: "name")
  ```
  """
  @doc since: "1.0.0"
  @spec get_document(map() | Connection.t(), module() | String.t(), String.t(), keyword()) ::
          {:ok, map} | {:error, OpenApiTypesense.ApiResponse.t()}
  def get_document(conn, module, doc_id, opts) when is_atom(module) do
    collection_name = module.__schema__(:source)
    get_document(conn, collection_name, doc_id, opts)
  end

  def get_document(conn, coll_name, doc_id, opts) do
    OpenApiTypesense.Documents.get_document(conn, coll_name, doc_id, opts)
  end

  @doc """
  Imports/Indexes multiple documents via maps.

  You can feed the output file from a Typesense export operation directly as import.

  ## Options

    * `batch_size`: Batch size parameter controls the number of documents that should
    be imported at a time. A larger value will speed up deletions, but will impact
    performance of other operations running on the server.
    * `return_id`: Returning the id of the imported documents. If you want the import
    response to return the ingested document's id in the response, you can use the
    return_id parameter.
    * `remote_embedding_batch_size`: Max size of each batch that will be sent to remote
    APIs while importing multiple documents at once. Using lower amount will lower
    timeout risk, but increase number of requests made. Default is 200.
    * `remote_embedding_timeout_ms`: How long to wait until an API call to a remote
    embedding service is considered a timeout during indexing. Default is 60_000 ms
    * `remote_embedding_num_tries`: The number of times to retry an API call to a remote
    embedding service on failure during indexing. Default is 2.
    * `return_doc`: Returns the entire document back in response.
    * `action`: Additional action to perform
    * `dirty_values`: Dealing with Dirty Data

  ## Examples
      iex> schema = %{
      ...>   name: "posts",
      ...>   fields: [
      ...>     %{name: "title", type: "string"}
      ...>   ],
      ...> }
      ...> ExTypesense.create_collection(schema)

      # doesn't matter if atom or string keys
      # import using a list of maps
      iex> posts = [
      ...>   %{title: "the quick brown fox"},
      ...>   %{title: "jumps over the lazy dog"}
      ...> ]
      ...> ExTypesense.import_documents("posts", posts)
      {:ok, [%{"success" => true}, %{"success" => true}]}

      # import using Ecto records
      iex> posts = MyApp.Blog.Post |> Repo.all()
      ...> ExTypesense.import_documents("posts", posts)
  """
  @doc since: "1.0.0"
  @spec import_documents(String.t() | module(), [struct()] | [map()]) ::
          {:ok, [map()]} | {:error, OpenApiTypesense.ApiResponse.t()}
  def import_documents(coll_name, docs) do
    import_documents(coll_name, docs, [])
  end

  @doc """
  Same as [import_documents/2](`import_documents/2`).

  ```elixir
  ExTypesense.import_documents("users", documents, [])

  ExTypesense.import_documents(MyApp.Accounts.User, documents, [])

  ExTypesense.import_documents(%{api_key: xyz, host: ...}, MyApp.Accounts.User, structs)

  ExTypesense.import_documents(OpenApiTypesense.Connection.new(), "users", [%MyApp.Accounts.User{}])

  ExTypesense.import_documents(OpenApiTypesense.Connection.new(), "users", documents)
  ```
  """
  @doc since: "1.0.0"
  @spec import_documents(
          map() | Connection.t() | String.t() | module(),
          String.t() | [struct()] | [map()],
          [struct()] | [map()] | keyword()
        ) ::
          {:ok, [map()]} | {:error, OpenApiTypesense.ApiResponse.t()}
  def import_documents(conn, coll_name, documents) when is_map(conn) and is_list(documents) do
    import_documents(conn, coll_name, documents, [])
  end

  def import_documents(coll_name, docs, opts) when is_list(docs) and is_list(opts) do
    Connection.new() |> import_documents(coll_name, docs, opts)
  end

  @doc """
  Same as [import_documents/3](`import_documents/3`) but passes another connection.

  ```elixir
  ExTypesense.import_documents(%{api_key: xyz, host: ...}, "companies", documents, batch_size: 100)

  ExTypesense.import_documents(OpenApiTypesense.Connection.new(), MyApp.Account.Person, structs, [])
  ```
  """
  @doc since: "1.0.0"
  @spec import_documents(
          map() | Connection.t(),
          String.t() | module(),
          [struct()] | [map()],
          keyword()
        ) ::
          {:ok, [map()]} | {:error, OpenApiTypesense.ApiResponse.t()}
  def import_documents(conn, module, docs, opts) when is_atom(module) do
    coll_name = module.__schema__(:source)
    import_documents(conn, coll_name, docs, opts)
  end

  def import_documents(conn, coll_name, [struct | _] = structs, opts)
      when structs != [] and is_struct(struct) do
    body =
      Enum.map(structs, fn record ->
        record
        |> Map.from_struct()
        |> Map.drop([:id, :__meta__, :__struct__])
      end)

    import_documents(conn, coll_name, body, opts)
  end

  def import_documents(conn, coll_name, docs, opts) do
    OpenApiTypesense.Documents.import_documents(conn, coll_name, docs, opts)
  end

  @doc """
  Indexes a single document using struct or map. When using struct,
  the pk maps to document's id as string.

  > #### indexing your document as a map {: .info}
  >
  > when using maps as documents using [`index_document/1`](`index_document/1`),
  > you should pass a key named `collection_name`.

  ## Options

    * `action`: "create" (default), "upsert", "update", "emplace"
    * `dirty_values`: Dealing with Dirty Data

  ## Examples
      iex> schema = %{
      ...>   name: "posts",
      ...>   fields: [
      ...>     %{name: "title", type: "string"}
      ...>     %{name: "posts_id", type: "int32"}
      ...>     %{name: "description", type: "string"}
      ...>   ],
      ...> }
      iex> ExTypesense.create_collection(schema)
      iex> body =
      ...>  %{
      ...>    id: "34", # you can omit this key, Typesense will generate for you.
      ...>    posts_id: 28,
      ...>    title: "the quick brown fox",
      ...>    description: "jumps over the lazy dog"
      ...>  }
      iex> ExTypesense.index_document("posts", body)
      {:ok,
        %{
          id: "34",
          posts_id: 28,
          title: "the quick brown fox",
          description: "jumps over the lazy dog"
        }
      }

      iex> MyApp.Blog.Post |> ExTypesense.create_collection()
      iex> post = MyApp.Blog.get_post!(24)
      iex> ExTypesense.index_document(post)
  """
  @doc since: "1.0.0"
  @spec index_document(struct()) ::
          {:ok, map} | {:error, OpenApiTypesense.ApiResponse.t()}
  def index_document(document) when not is_struct(document) and is_map(document) do
    collection_name = Map.get(document, "collection_name") || Map.get(document, :collection_name)
    index_document(collection_name, document)
  end

  def index_document(record) do
    index_document(record, [])
  end

  @doc """
  Same as [index_document/1](`index_document/1`).

  ```elixir
  ExTypesense.index_document("persons", document)

  ExTypesense.index_document(%{api_key: xyz, host: ...}, document)

  ExTypesense.index_document(OpenApiTypesense.Connection.new(), struct)

  ExTypesense.index_document(struct, action: "upsert")
  ```
  """
  @spec index_document(
          map() | Connection.t() | String.t() | struct(),
          map() | struct() | keyword()
        ) ::
          {:ok, map} | {:error, OpenApiTypesense.ApiResponse.t()}
  def index_document(document, opts)
      when not is_struct(document) and is_map(document) and is_list(opts) do
    collection_name = Map.get(document, "collection_name") || Map.get(document, :collection_name)
    index_document(collection_name, document, opts)
  end

  def index_document(record, opts) when is_struct(record) and is_list(opts) do
    Connection.new() |> index_document(record, opts)
  end

  def index_document(conn_or_coll_name, record_or_document) do
    index_document(conn_or_coll_name, record_or_document, [])
  end

  @doc """
  Same as [index_document/2](`get_document/2`).

  ```elixir
  ExTypesense.index_document("persons", document, action: "update")

  ExTypesense.index_document(%{api_key: xyz, host: ...}, "persons", document)

  ExTypesense.index_document(OpenApiTypesense.Connection.new(), %MyApp.Accounts.Person{...}, action: "upsert")
  ```
  """
  @doc since: "1.0.0"
  @spec index_document(
          map() | Connection.t() | String.t(),
          String.t() | map() | struct(),
          map() | keyword()
        ) ::
          {:ok, map} | {:error, OpenApiTypesense.ApiResponse.t()}
  def index_document(coll_name, body, opts) when is_binary(coll_name) and is_list(opts) do
    Connection.new() |> index_document(coll_name, body, opts)
  end

  def index_document(conn, document, opts)
      when not is_struct(document) and is_map(document) and is_list(opts) do
    collection_name = Map.get(document, "collection_name") || Map.get(document, :collection_name)
    index_document(conn, collection_name, document, opts)
  end

  def index_document(conn, record, opts) when is_struct(record) do
    collection_name = record.__struct__.__schema__(:source)
    record = Map.from_struct(record) |> Map.drop([:id, :__meta__, :__struct__])
    OpenApiTypesense.Documents.index_document(conn, collection_name, record, opts)
  end

  def index_document(conn, collection_name, body) do
    index_document(conn, collection_name, body, [])
  end

  @doc """
  Same as [get_document/3](`get_document/3`) but passes another connection.

  ```elixir
  ExTypesense.index_document(%{api_key: xyz, host: ...}, "persons", documents, action: "update")

  ExTypesense.index_document(OpenApiTypesense.Connection.new(), "persons", documents, [])
  ```
  """
  @doc since: "1.0.0"
  @spec index_document(
          map() | Connection.t(),
          String.t(),
          map(),
          keyword()
        ) ::
          {:ok, map} | {:error, OpenApiTypesense.ApiResponse.t()}
  def index_document(conn, collection_name, body, opts)
      when is_binary(collection_name) and is_map(body) and is_list(opts) do
    OpenApiTypesense.Documents.index_document(conn, collection_name, body, opts)
  end

  @doc """
  Update an single document using struct or map. The update can be partial.

  > #### indexing your document as a map {: .info}
  >
  > when using map as document, you should pass a key named `collection_name`.

  ## Options

    * `dirty_values`: Dealing with Dirty Data

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
      iex> ExTypesense.index_document(post)
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
          id: "94",
          collection_name: "posts",
          posts_id: 94,
          title: "sample post"
        }
      }

      iex> person = Accounts.fetch_person!(12)
      ...> ExTypesense.update_document(person)
  """
  @doc since: "1.0.0"
  @spec update_document(struct() | map()) ::
          {:ok, map} | {:error, OpenApiTypesense.ApiResponse.t()}
  def update_document(document) do
    update_document(document, [])
  end

  @doc """
  Same as [update_document/1](`update_document/1`).

  ```elixir
  ExTypesense.update_document(document, [])
  ExTypesense.update_document(%{api_key: xyz, host: ...}, %User{...})
  ExTypesense.update_document(OpenApiTypesense.Connection.new(), document)
  ```
  """
  @doc since: "1.0.0"
  @spec update_document(map() | Connection.t() | struct() | map(), struct() | map() | keyword()) ::
          {:ok, map} | {:error, OpenApiTypesense.ApiResponse.t()}
  def update_document(document, opts) when is_list(opts) do
    Connection.new() |> update_document(document, opts)
  end

  def update_document(conn, document) do
    update_document(conn, document, [])
  end

  @doc """
  Same as [update_document/2](`update_document/2`) but passes another connection.

  ```elixir
  ExTypesense.update_document(%{api_key: xyz, host: ...}, document, [])
  ExTypesense.update_document(OpenApiTypesense.Connection.new(), [])
  ```
  """
  @doc since: "1.0.0"
  @spec update_document(map() | Connection.t(), map() | struct(), keyword()) ::
          {:ok, map} | {:error, OpenApiTypesense.ApiResponse.t()}
  def update_document(conn, record, opts) when is_struct(record) do
    coll_name = record.__struct__.__schema__(:source)
    field_name = coll_name <> "_id"
    id = Map.get(record, String.to_existing_atom(field_name))
    opts = Keyword.put_new(opts, :filter_by, "#{field_name}:#{id}")
    body = record |> Map.from_struct() |> Map.drop([:id, :__meta__, :__struct__])

    update_documents_by_query(conn, coll_name, body, opts)
  end

  def update_document(conn, document, opts) when is_map(document) do
    coll_name = Map.get(document, "collection_name") || Map.get(document, :collection_name)
    doc_id = Map.get(document, "id") || Map.get(document, :id)
    OpenApiTypesense.Documents.update_document(conn, coll_name, doc_id, document, opts)
  end

  @doc """
  Update documents with conditional query

  The filter_by query parameter is used to filter to specify a condition against which the
  documents are matched. The request body contains the fields that should be updated for
  any documents that match the filter condition. This endpoint is only available if the
  Typesense server is version `0.25.0.rc12` or later.

  See: https://typesense.org/docs/latest/api/search.html#filter-parameters
  regarding `filter_by` option.

  ## Options

    * `filter_by`: Filter results by a particular value(s) or logical expressions.
    multiple conditions with &&.
    * `action`: Additional action to perform

  ## Example
      iex> body = %{
      ...>   "tag" => "large",
      ...> }

      iex> opts = [filter_by; "num_employees:>1000"]

      iex> ExTypesense.update_documents_by_query("companies", body, opts)
  """
  @doc since: "1.0.0"
  @spec update_documents_by_query(String.t() | module(), map(), keyword()) ::
          {:ok, map} | {:error, OpenApiTypesense.ApiResponse.t()}
  def update_documents_by_query(collection_name, body, opts) do
    Connection.new() |> update_documents_by_query(collection_name, body, opts)
  end

  @doc """
  Same as [update_documents_by_query/3](`update_documents_by_query/3`) but passes another connection.

  ```elixir
  ExTypesense.update_documents_by_query(%{api_key: xyz, host: ...}, "companies", body, action: "upsert")

  ExTypesense.update_documents_by_query(OpenApiTypesense.Connection.new(), MyApp.Accounts.User, body, opts)
  ```
  """
  @doc since: "1.0.0"
  @spec update_documents_by_query(
          map() | Connection.t(),
          String.t() | module(),
          map(),
          keyword()
        ) ::
          {:ok, map} | {:error, OpenApiTypesense.ApiResponse.t()}
  def update_documents_by_query(conn, module, body, opts) when is_atom(module) do
    collection_name = module.__schema__(:source)
    update_documents_by_query(conn, collection_name, body, opts)
  end

  def update_documents_by_query(conn, collection_name, body, opts) do
    OpenApiTypesense.Documents.update_documents(conn, collection_name, body, opts)
  end

  @doc """
  Delete an individual document from a collection by using its document ID.

  ## Options

    * `ignore_not_found`: (Boolean) Ignore the error and treat the deletion as success.
    This option is only available when payload is _map_, not _struct_.

  > #### Deleting a document by id {: .info}
  >
  > Deleting a document means the Typesense document ID, **NOT** the
  > ID of the record itself. If you want to delete the ID of record,
  > use [`ExTypesense.delete_documents_by_query/2`](`ExTypesense.delete_documents_by_query/2`)


  ## Examples
      iex> ExTypesense.create_collection(Post)
      iex> post = Post |> limit(1) |> Repo.one()
      iex> ExTypesense.index_document(post)
      {:ok,
        %{
          id: "1",
          posts_id: 99,
          title: "our first post",
          collection_name: "posts"
        }
      }
      iex> ExTypesense.delete_document(post)

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
      iex> ExTypesense.index_document(post)
      iex> ExTypesense.delete_document("posts", "12", ignore_not_found: true)
      {:ok,
        %{
          id: "12",
          posts_id: 22,
          title: "the quick brown fox",
          collection_name: "posts"
        }
      }
  """
  @doc since: "1.0.0"
  @spec delete_document(struct()) ::
          {:ok, map} | {:error, OpenApiTypesense.ApiResponse.t()}
  def delete_document(record) when is_struct(record) do
    delete_document(record, [])
  end

  @doc """
  Same as [delete_document/1](`delete_document/1`).

  ```elixir
  ExTypesense.delete_document("persons", "88")

  ExTypesense.delete_document(%{api_key: xyz, host: ...}, struct)

  ExTypesense.delete_document(OpenApiTypesense.Connection.new(), struct)

  ExTypesense.delete_document(struct, ignore_not_found: true)
  ```
  """
  @doc since: "1.0.0"
  @spec delete_document(
          map() | Connection.t() | String.t(),
          struct() | String.t() | keyword()
        ) ::
          {:ok, map} | {:error, OpenApiTypesense.ApiResponse.t()}
  def delete_document(document, opts) when is_list(opts) do
    Connection.new() |> delete_document(document, opts)
  end

  def delete_document(conn, document) do
    delete_document(conn, document, ignore_not_found: false)
  end

  @doc """
  Same as [delete_document/2](`delete_document/2`).

  ```elixir
  ExTypesense.delete_document("persons", "88", ignore_not_found: true)

  ExTypesense.delete_document(%{api_key: xyz, host: ...}, struct, ignore_not_found: false)

  ExTypesense.delete_document(OpenApiTypesense.Connection.new(), "personse", "88")
  ```
  """
  @doc since: "1.0.0"
  @spec delete_document(
          map() | Connection.t() | String.t(),
          struct() | String.t(),
          String.t() | keyword()
        ) ::
          {:ok, map} | {:error, OpenApiTypesense.ApiResponse.t()}
  def delete_document(coll_name, doc_id, opts)
      when is_binary(coll_name) and is_list(opts) do
    Connection.new() |> delete_document(coll_name, doc_id, opts)
  end

  def delete_document(conn, record, opts) when is_struct(record) do
    coll_name = record.__struct__.__schema__(:source)
    field_name = coll_name <> "_id"
    id = Map.get(record, String.to_existing_atom(field_name))
    opts = Keyword.put_new(opts, :filter_by, "#{field_name}:#{id}")
    delete_documents_by_query(conn, coll_name, opts)
  end

  def delete_document(conn, document, opts) when is_map(document) do
    coll_name = Map.get(document, "collection_name") || Map.get(document, :collection_name)
    field_name = coll_name <> "_id"
    id = Map.get(document, field_name) || Map.get(document, String.to_existing_atom(field_name))
    opts = Keyword.put_new(opts, :filter_by, "#{field_name}:#{id}")
    delete_documents_by_query(conn, coll_name, opts)
  end

  def delete_document(conn, coll_name, doc_id) do
    delete_document(conn, coll_name, doc_id, ignore_not_found: false)
  end

  @doc """
  Same as [delete_document/3](`delete_document/3`) but passes another connection.

  ```elixir
  ExTypesense.delete_document(%{api_key: xyz, host: ...}, coll_name, doc_id, [])

  ExTypesense.delete_document(OpenApiTypesense.Connection.new(), coll_name, doc_id, [])
  ```
  """
  @doc since: "1.0.0"
  @spec delete_document(
          map() | Connection.t(),
          String.t(),
          String.t(),
          keyword()
        ) ::
          {:ok, map} | {:error, OpenApiTypesense.ApiResponse.t()}
  def delete_document(conn, coll_name, doc_id, opts) when is_list(opts) do
    OpenApiTypesense.Documents.delete_document(conn, coll_name, doc_id, opts)
  end

  @doc """
  Export all documents in a collection in JSON lines format.

  ## Options

    * `filter_by`: Filter conditions for refining your search results. Separate multiple conditions with &&.
    * `include_fields`: List of fields from the document to include in the search result
    * `exclude_fields`: List of fields from the document to exclude in the search result
  """
  @doc since: "1.0.0"
  @spec export_documents(String.t() | module()) ::
          {:ok, String.t()} | {:error, OpenApiTypesense.ApiResponse.t()}
  def export_documents(collection_name) do
    export_documents(collection_name, [])
  end

  @doc """
  Same as [export_documents/1](`export_documents/1`).

  ```elixir
  ExTypesense.export_documents("persons", opts)

  ExTypesense.export_documents(MyModule.Accounts.Person, opts)

  ExTypesense.export_documents(%{api_key: xyz, host: ...}, "persons")

  ExTypesense.export_documents(OpenApiTypesense.Connection.new(), MyModule.Accounts.Person)
  ```
  """
  @doc since: "1.0.0"
  @spec export_documents(String.t() | module(), keyword()) ::
          {:ok, String.t()} | {:error, OpenApiTypesense.ApiResponse.t()}
  def export_documents(collection_name, opts) when is_list(opts) do
    Connection.new() |> export_documents(collection_name, opts)
  end

  def export_documents(conn, collection_name) do
    export_documents(conn, collection_name, [])
  end

  @doc """
  Same as [export_documents/2](`export_documents/2`) but passes another connection.

  ```elixir
  ExTypesense.export_documents(%{api_key: xyz, host: ...}, "persons", opts)

  ExTypesense.export_documents(OpenApiTypesense.Connection.new(), MyModule.Accounts.Person, opts)
  ```
  """
  @doc since: "1.0.0"
  @spec export_documents(
          map() | Connection.t(),
          String.t() | module(),
          keyword()
        ) ::
          {:ok, String.t()} | {:error, OpenApiTypesense.ApiResponse.t()}
  def export_documents(conn, module, opts) when is_atom(module) do
    collection_name = module.__schema__(:source)
    export_documents(conn, collection_name, opts)
  end

  def export_documents(conn, collection_name, opts) do
    OpenApiTypesense.Documents.export_documents(conn, collection_name, opts)
  end

  @doc """
  Deletes documents in a collection by query.

  ## Options

    * `batch_size`: Batch size parameter controls the number of documents
    that should be deleted at a time. A larger value will speed up deletions,
    but will impact performance of other operations running on the server.
    * `filter_by`: Filter results by a particular value(s) or logical
    expressions. multiple conditions with &&.

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
      iex> query = [filter_by: "num_employees:>100", batch_size: 100]
      iex> ExTypesense.delete_documents_by_query(Employee, query)
      {:ok, [...]}
  """
  @doc since: "1.0.0"
  @spec delete_documents_by_query(String.t() | module(), keyword()) ::
          {:ok, map} | {:error, OpenApiTypesense.ApiResponse.t()}
  def delete_documents_by_query(collection_name, opts) when is_list(opts) do
    Connection.new() |> delete_documents_by_query(collection_name, opts)
  end

  @doc """
  Same as [delete_documents_by_query/2](`delete_documents_by_query/2`) but passes another connection.

  ```elixir
  ExTypesense.delete_documents_by_query(%{api_key: xyz, host: ...}, "persons", opts)

  ExTypesense.delete_documents_by_query(OpenApiTypesense.Connection.new(), MyModule.Accounts.Person, opts)
  ```
  """
  @doc since: "1.0.0"
  @spec delete_documents_by_query(
          map() | Connection.t(),
          String.t() | module(),
          keyword()
        ) :: {:ok, map} | {:error, OpenApiTypesense.ApiResponse.t()}
  def delete_documents_by_query(conn, module, opts) when is_atom(module) do
    collection_name = module.__schema__(:source)
    delete_documents_by_query(conn, collection_name, opts)
  end

  def delete_documents_by_query(conn, collection_name, opts) do
    OpenApiTypesense.Documents.delete_documents(conn, collection_name, opts)
  end

  @doc """
  Deletes all documents in a collection.

  > #### On using this function {: .info}
  >
  > As of this writing (v0.5.0), there's no built-in way of deleting
  > all documents via [Typesense docs](https://github.com/typesense/typesense/issues/1613#issuecomment-1994986258).
  > This function uses [`delete_documents_by_query/3`](`delete_documents_by_query/3`) under the hood.
  """
  @doc since: "1.0.0"
  @spec delete_all_documents(module() | String.t()) ::
          {:ok, map} | {:error, OpenApiTypesense.ApiResponse.t()}
  def delete_all_documents(collection_name) do
    delete_all_documents(collection_name, [])
  end

  @doc """
  Same as [delete_all_documents/1](`delete_all_documents/1`).

  ```elixir
  ExTypesense.delete_all_documents("persons", [])

  ExTypesense.delete_all_documents(%{api_key: xyz, host: ...}, "persons")

  ExTypesense.delete_all_documents(OpenApiTypesense.Connection.new(), MyModule.Accounts.Person)
  ```
  """
  @doc since: "1.0.0"
  @spec delete_all_documents(
          map() | Connection.t() | module() | String.t(),
          module() | String.t() | keyword()
        ) ::
          {:ok, map} | {:error, OpenApiTypesense.ApiResponse.t()}
  def delete_all_documents(coll_name, opts) when is_list(opts) do
    Connection.new() |> delete_all_documents(coll_name, opts)
  end

  def delete_all_documents(conn, collection_name) do
    delete_all_documents(conn, collection_name, [])
  end

  @doc """
  Same as [delete_all_documents/2](`delete_all_documents/2`) but passes another connection.

  ```elixir
  ExTypesense.delete_all_documents(%{api_key: xyz, host: ...}, "persons", [])

  ExTypesense.delete_all_documents(OpenApiTypesense.Connection.new(), MyModule.Accounts.Person, [])
  ```
  """
  @doc since: "1.0.0"
  @spec delete_all_documents(
          map() | Connection.t(),
          module() | String.t(),
          keyword()
        ) ::
          {:ok, map} | {:error, OpenApiTypesense.ApiResponse.t()}
  def delete_all_documents(conn, module, opts) when is_atom(module) do
    coll_name = module.__schema__(:source)
    delete_all_documents(conn, coll_name, opts)
  end

  def delete_all_documents(conn, collection_name, opts) do
    opts = Keyword.put_new(opts, :filter_by, "id:!=''")
    delete_documents_by_query(conn, collection_name, opts)
  end
end
