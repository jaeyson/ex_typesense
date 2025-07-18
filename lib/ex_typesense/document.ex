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

  ## Options

    * `conn`: The custom connection map or struct you passed

  ## Examples
      iex> conn = %{api_key: xyz, host: ...}
      iex> ExTypesense.get_document("persons", "88", exclude_fields: "name", conn: conn)

      iex> conn = OpenApiTypesense.Connection.new()
      iex> ExTypesense.get_document(MyModule.Accounts.Person, "88", exclude_fields: "name", conn: conn)

      iex> opts = [exclude_fields: "name", conn: conn]
      iex> ExTypesense.get_document(MyModule.Accounts.Person, "88", opts)
  """
  @doc since: "1.0.0"
  @spec get_document(module() | String.t(), String.t(), keyword()) ::
          {:ok, map} | {:error, OpenApiTypesense.ApiResponse.t()}
  def get_document(module, doc_id, opts) when is_atom(module) do
    collection_name = module.__schema__(:source)
    get_document(collection_name, doc_id, opts)
  end

  def get_document(coll_name, doc_id, opts) when is_binary(coll_name) do
    OpenApiTypesense.Documents.get_document(coll_name, doc_id, opts)
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
          {:ok, String.t()} | {:error, OpenApiTypesense.ApiResponse.t()}
  def import_documents(coll_name, docs) do
    import_documents(coll_name, docs, [])
  end

  @doc """
  Same as [import_documents/2](`import_documents/2`).

  ## Options

    * `conn`: The custom connection map or struct you passed

  ## Examples
      iex> conn = %{api_key: xyz, host: ...}
      iex> ExTypesense.import_documents("users", documents, conn: conn)
      iex> ExTypesense.import_documents(MyApp.Accounts.User, documents, conn: conn)

      iex> conn = OpenApiTypesense.Connection.new()
      iex> ExTypesense.import_documents(MyApp.Accounts.User, structs, conn: conn)
      iex> ExTypesense.import_documents("users", [%MyApp.Accounts.User{}], conn: conn)

      iex> opts = [conn: conn]
      iex> ExTypesense.import_documents("users", documents, opts)
  """
  @doc since: "1.0.0"
  @spec import_documents(String.t() | module(), [struct()] | [map()], keyword()) ::
          {:ok, String.t()} | {:error, OpenApiTypesense.ApiResponse.t()}
  def import_documents(module, docs, opts) when is_atom(module) do
    coll_name = module.__schema__(:source)
    import_documents(coll_name, docs, opts)
  end

  def import_documents(coll_name, [struct | _] = structs, opts)
      when structs != [] and is_struct(struct) do
    body =
      Enum.map(structs, fn record ->
        record
        |> Map.from_struct()
        |> Map.drop([:id, :__meta__, :__struct__])
      end)

    import_documents(coll_name, body, opts)
  end

  def import_documents(coll_name, docs, opts) do
    body = Enum.map_join(docs, "\n", &Jason.encode_to_iodata!/1)
    OpenApiTypesense.Documents.import_documents(coll_name, body, opts)
  end

  @doc """
  Indexes a single document using struct or map. When using struct,
  the pk maps to document's id as string.

  > #### on using struct {: .info}
  >
  > Please refer on this [page](`ExTypesense`) for more info on how to
  > setup with Ecto Schema.

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

      iex> doc =
      ...>  %{
      ...>    collection_name: "posts"
      ...>    id: "34", # you can omit this key, Typesense will generate for you.
      ...>    posts_id: 28,
      ...>    title: "the quick brown fox",
      ...>    description: "jumps over the lazy dog"
      ...>  }
      iex> ExTypesense.index_document(doc)
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
  @spec index_document(map() | struct()) ::
          {:ok, map} | {:error, OpenApiTypesense.ApiResponse.t()}
  def index_document(document) do
    index_document(document, [])
  end

  @doc """
  Same as [index_document/1](`index_document/1`).

  ## Options

    * `conn`: The custom connection map or struct you passed

  ## Examples
      iex> conn = %{api_key: xyz, host: ...}
      iex> ExTypesense.index_document("persons", document, conn: conn)

      iex> conn = OpenApiTypesense.Connection.new()
      iex> ExTypesense.index_document(document, conn: conn)
      iex> ExTypesense.index_document(struct, conn: conn)

      iex> opts = [action: "upsert", conn: conn]
      iex> ExTypesense.index_document(struct, opts)
  """
  @spec index_document(map() | struct() | String.t(), map() | keyword()) ::
          {:ok, map} | {:error, OpenApiTypesense.ApiResponse.t()}
  def index_document(record, opts) when is_struct(record) do
    collection_name = record.__struct__.__schema__(:source)
    document = Map.from_struct(record) |> Map.drop([:id, :__meta__, :__struct__])
    OpenApiTypesense.Documents.index_document(collection_name, document, opts)
  end

  def index_document(document, opts) when is_map(document) do
    collection_name = Map.get(document, "collection_name") || Map.get(document, :collection_name)
    index_document(collection_name, document, opts)
  end

  def index_document(collection_name, document) do
    index_document(collection_name, document, [])
  end

  @doc """
  Same as [index_document/2](`get_document/2`).

  ## Examples
      iex> conn = %{api_key: xyz, host: ...}
      iex> ExTypesense.index_document("persons", document, action: "update", conn: conn)

      iex> conn = OpenApiTypesense.Connection.new()
      iex> ExTypesense.index_document("persons", document, conn: conn)

      iex> opts = [action: "upsert", conn: conn]
      iex> ExTypesense.index_document("persons", document, opts)
  """
  @doc since: "1.0.0"
  @spec index_document(String.t(), map(), keyword()) ::
          {:ok, map} | {:error, OpenApiTypesense.ApiResponse.t()}
  def index_document(collection_name, body, opts)
      when is_binary(collection_name) and is_map(body) and is_list(opts) do
    body = Map.drop(body, ["collection_name", :collection_name])
    OpenApiTypesense.Documents.index_document(collection_name, body, opts)
  end

  @doc """
  Update an single document using struct or map. The update can be partial.

  **Note**: the return type for struct and map are different. See examples below.

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
      {:ok,
        %OpenApiTypesense.Documents{
          num_deleted: nil,
          num_updated: 1
        }
      }
  """
  @doc since: "1.0.0"
  @spec update_document(map() | struct()) ::
          {:ok, map} | {:error, OpenApiTypesense.ApiResponse.t()}
  def update_document(document) do
    update_document(document, [])
  end

  @doc """
  Same as [update_document/1](`update_document/1`).

  ## Options

    * `conn`: The custom connection map or struct you passed

  ## Examples
      iex> conn = %{api_key: xyz, host: ...}
      iex> ExTypesense.update_document(document, conn: conn)

      iex> conn = OpenApiTypesense.Connection.new()
      iex> ExTypesense.update_document(%User{...}, conn: conn)

      iex> opts = [dirty_values: "reject", conn: conn]
      iex> ExTypesense.update_document(document, opts)
  """
  @doc since: "1.0.0"
  @spec update_document(map() | struct(), keyword()) ::
          {:ok, map} | {:error, OpenApiTypesense.ApiResponse.t()}
  def update_document(record, opts) when is_struct(record) do
    coll_name = record.__struct__.__schema__(:source)
    field_name = coll_name <> "_id"
    id = Map.get(record, String.to_existing_atom(field_name))
    opts = Keyword.put_new(opts, :filter_by, "#{field_name}:#{id}")
    body = record |> Map.from_struct() |> Map.drop([:id, :__meta__, :__struct__])

    update_documents_by_query(coll_name, body, opts)
  end

  def update_document(document, opts) when is_map(document) do
    coll_name = Map.get(document, "collection_name") || Map.get(document, :collection_name)
    doc_id = Map.get(document, "id") || Map.get(document, :id)
    document = Map.drop(document, ["collection_name", :collection_name])

    OpenApiTypesense.Documents.update_document(coll_name, doc_id, document, opts)
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

    * `conn`: The custom connection map or struct you passed
    * `filter_by`: Filter results by a particular value(s) or logical expressions.
    multiple conditions with &&.
    * `action`: Additional action to perform

  ## Example
      iex> body = %{
      ...>   "tag" => "large",
      ...> }

      iex> conn = %{api_key: xyz, host: ...}
      iex> opts = [filter_by: "num_employees:>1000", conn: conn]
      iex> ExTypesense.update_documents_by_query("companies", body, opts)

      iex> ExTypesense.update_documents_by_query("companies", body, action: "upsert", conn: conn)
  """
  @doc since: "1.0.0"
  @spec update_documents_by_query(String.t() | module(), map(), keyword()) ::
          {:ok, map} | {:error, OpenApiTypesense.ApiResponse.t()}
  def update_documents_by_query(module, body, opts) when is_atom(module) do
    collection_name = module.__schema__(:source)
    update_documents_by_query(collection_name, body, opts)
  end

  def update_documents_by_query(coll_name, body, opts) when is_binary(coll_name) do
    OpenApiTypesense.Documents.update_documents(coll_name, body, opts)
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
  @spec delete_document(map() | struct()) ::
          {:ok, map} | {:error, OpenApiTypesense.ApiResponse.t()}
  def delete_document(document) do
    delete_document(document, ignore_not_found: false)
  end

  @doc """
  Same as [delete_document/1](`delete_document/1`).

  ## Options

    * `conn`: The custom connection map or struct you passed

  ## Examples
      iex> conn = %{api_key: xyz, host: ...}
      iex> ExTypesense.delete_document(document, conn: conn)

      iex> conn = OpenApiTypesense.Connection.new()
      iex> ExTypesense.delete_document(struct, conn: conn)

      iex> opts = [ignore_not_found: true, conn: conn]
      iex> ExTypesense.delete_document(struct, opts)
  """
  @doc since: "1.0.0"
  @spec delete_document(
          map() | Connection.t() | String.t(),
          String.t() | keyword()
        ) ::
          {:ok, map} | {:error, OpenApiTypesense.ApiResponse.t()}
  def delete_document(record, opts) when is_struct(record) do
    coll_name = record.__struct__.__schema__(:source)
    field_name = coll_name <> "_id"
    id = Map.get(record, String.to_existing_atom(field_name))
    opts = Keyword.put_new(opts, :filter_by, "#{field_name}:#{id}")
    delete_documents_by_query(coll_name, opts)
  end

  def delete_document(document, opts) when is_map(document) do
    coll_name = Map.get(document, "collection_name") || Map.get(document, :collection_name)
    field_name = coll_name <> "_id"
    id = Map.get(document, field_name) || Map.get(document, String.to_existing_atom(field_name))
    opts = Keyword.put_new(opts, :filter_by, "#{field_name}:#{id}")
    delete_documents_by_query(coll_name, opts)
  end

  def delete_document(coll_name, doc_id) do
    opts = [ignore_not_found: false]
    OpenApiTypesense.Documents.delete_document(coll_name, doc_id, opts)
  end

  @doc """
  Same as [delete_document/2](`delete_document/2`).

  ## Options

    * `conn`: The custom connection map or struct you passed

  ## Examples
      iex> conn = %{api_key: xyz, host: ...}
      iex> ExTypesense.delete_document("persons", "88", conn: conn)

      iex> conn = OpenApiTypesense.Connection.new()
      iex> ExTypesense.delete_document("persons", "88", conn: conn)

      iex> opts = [ignore_not_found: true, conn: conn]
      iex> ExTypesense.delete_document("persons", "88", opts)
  """
  @doc since: "1.0.0"
  @spec delete_document(String.t(), String.t(), keyword()) ::
          {:ok, map} | {:error, OpenApiTypesense.ApiResponse.t()}
  def delete_document(coll_name, doc_id, opts) when is_binary(coll_name) and is_binary(doc_id) do
    OpenApiTypesense.Documents.delete_document(coll_name, doc_id, opts)
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

  ## Options

    * `conn`: The custom connection map or struct you passed

  ## Examples
      iex> conn = %{api_key: xyz, host: ...}
      iex> ExTypesense.export_documents("persons", conn: conn)
      iex> ExTypesense.export_documents(MyModule.Accounts.Person, conn: conn)

      iex> conn = OpenApiTypesense.Connection.new()
      iex> ExTypesense.export_documents("persons", conn: conn)

      iex> opts = [conn: conn]
      iex> ExTypesense.export_documents(MyModule.Accounts.Person, opts)
  """
  @doc since: "1.0.0"
  @spec export_documents(String.t() | module(), keyword()) ::
          {:ok, String.t()} | {:error, OpenApiTypesense.ApiResponse.t()}
  def export_documents(module, opts) when is_atom(module) do
    collection_name = module.__schema__(:source)
    export_documents(collection_name, opts)
  end

  def export_documents(coll_name, opts) when is_binary(coll_name) do
    OpenApiTypesense.Documents.export_documents(coll_name, opts)
  end

  @doc """
  Deletes documents in a collection by query.

  ## Options

    * `conn`: The custom connection map or struct you passed
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

      iex> conn = %{api_key: xyz, host: ...}
      iex> opts = Keyword.put(query, :conn, conn)
      iex> ExTypesense.delete_documents_by_query(Employee, opts)
  """
  @doc since: "1.0.0"
  @spec delete_documents_by_query(String.t() | module(), keyword()) ::
          {:ok, map} | {:error, OpenApiTypesense.ApiResponse.t()}
  def delete_documents_by_query(module, opts) when is_atom(module) do
    collection_name = module.__schema__(:source)
    delete_documents_by_query(collection_name, opts)
  end

  def delete_documents_by_query(coll_name, opts) when is_binary(coll_name) do
    OpenApiTypesense.Documents.delete_documents(coll_name, opts)
  end

  @doc """
  Deletes all documents in a collection.

  > #### On using this function {: .info}
  >
  > As of this writing (v0.5.0), there's no built-in way of deleting
  > all documents via [Typesense docs](https://github.com/typesense/typesense/issues/1613#issuecomment-1994986258).
  > This function uses [`delete_documents_by_query/2`](`delete_documents_by_query/2`) under the hood.
  """
  @doc since: "1.0.0"
  @spec delete_all_documents(module() | String.t()) ::
          {:ok, map} | {:error, OpenApiTypesense.ApiResponse.t()}
  def delete_all_documents(collection_name) do
    delete_all_documents(collection_name, [])
  end

  @doc """
  Same as [delete_all_documents/1](`delete_all_documents/1`).

  ## Options

    * `conn`: The custom connection map or struct you passed

  ## Examples
      iex> conn = %{api_key: xyz, host: ...}
      iex> ExTypesense.delete_all_documents("persons", conn: conn)

      iex> conn = OpenApiTypesense.Connection.new()
      iex> ExTypesense.delete_all_documents("persons", conn: conn)

      iex> opts = [conn: conn]
      iex> ExTypesense.delete_all_documents(MyModule.Accounts.Person, opts)
  """
  @doc since: "1.0.0"
  @spec delete_all_documents(module() | String.t(), keyword()) ::
          {:ok, map} | {:error, OpenApiTypesense.ApiResponse.t()}
  def delete_all_documents(module, opts) when is_atom(module) do
    coll_name = module.__schema__(:source)
    delete_all_documents(coll_name, opts)
  end

  def delete_all_documents(coll_name, opts) when is_binary(coll_name) do
    opts = Keyword.put_new(opts, :filter_by, "id:!=''")
    delete_documents_by_query(coll_name, opts)
  end
end
