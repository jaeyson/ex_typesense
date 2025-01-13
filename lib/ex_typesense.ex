defmodule ExTypesense do
  @moduledoc since: "0.1.0"

  @moduledoc """
  Public API functions to interact with Typesense.

  If you want to implement field types for your Ecto schema,
  you may need to encode the schema and add the callback [`get_field_types/0`](`c:ExTypesense.get_field_types/0`):

  > #### Schema and field types for Ecto {: .info}
  >
  > The code below is when you're using it with Ecto schema.
  > Skip this if you just want plain old maps

  ```elixir
  defmodule App.Person do
    use Ecto.Schema
    @behaviour ExTypesense

    defimpl Jason.Encoder, for: __MODULE__ do
      def encode(value, opts) do
        value
        |> Map.take([:id, :persons_id, :name, :age])
        |> Enum.map(fn {key, val} ->
          cond do
            key === :id -> {key, to_string(Map.get(value, :id))}
            key === :persons_id -> {key, Map.get(value, :id)}
            true -> {key, val}
          end
        end)
        |> Enum.into(%{})
        |> Jason.Encode.map(opts)
      end
    end

    schema "persons" do
      field :name, :string
      field :age, :integer
      field :persons_id, :integer, virtual: true
    end

    @impl ExTypesense
    def get_field_types do
      name = __MODULE__.__schema__(:source)
      primary_field = name <> "_id"

      %{
        name: name,
        default_sorting_field: primary_field,
        fields:
          [
            %{name: primary_field, type: "int32"},
            %{name: "name", type: "string"},
            %{name: "age", type: "integer"}
          ]
      }
    end
  end
  ```
  """

  alias ExTypesense.Connection

  @doc since: "1.0.0"
  @doc """
  A callback function for creating the schema fields in Typesense.

  > #### Where to add {: .info}
  >
  > This function should be added in the Ecto Schema that you
  > will be use to import to Typesense.

  ```elixir
  defmodule MyApp.Accounts.User do
    use Ecto.Schema
    @behaviour ExTypesense

    #... Lots of user-related code + Ecto schema

    @impl ExTypesense
    def get_field_types do
      name = __MODULE__.__schema__(:source)
      primary_field = name <> "_id"

      %{
        name: name,
        default_sorting_field: primary_field,
        fields:
          [
            %{name: primary_field, type: "int32"},
            %{name: "name", type: "string"},
            %{name: "age", type: "integer"}
          ]
      }
    end
  ```
  """
  @callback get_field_types :: map()

  ##########################################################
  # start collection-specific tasks
  ##########################################################
  defdelegate list_collections, to: ExTypesense.Collection
  defdelegate list_collections(conn_or_opts), to: ExTypesense.Collection
  defdelegate list_collections(conn, opts), to: ExTypesense.Collection

  defdelegate create_collection(schema), to: ExTypesense.Collection
  defdelegate create_collection(conn_or_schema, schema_or_opts), to: ExTypesense.Collection
  defdelegate create_collection(conn, schema, opts), to: ExTypesense.Collection

  defdelegate clone_collection(src_coll, new_coll), to: ExTypesense.Collection
  defdelegate clone_collection(conn, src_coll, new_coll), to: ExTypesense.Collection

  defdelegate get_collection(name), to: ExTypesense.Collection
  defdelegate get_collection(conn, coll_name), to: ExTypesense.Collection

  defdelegate get_collection_name(alias_name), to: ExTypesense.Collection
  defdelegate get_collection_name(conn, alias_name), to: ExTypesense.Collection

  defdelegate drop_collection(name), to: ExTypesense.Collection
  defdelegate drop_collection(conn, name), to: ExTypesense.Collection

  defdelegate update_collection_fields(name, fields), to: ExTypesense.Collection
  defdelegate update_collection_fields(conn, name, fields), to: ExTypesense.Collection
  ##########################################################
  # end collection-specific tasks
  ##########################################################

  ##########################################################
  # start collection alias
  ##########################################################
  defdelegate list_collection_aliases(), to: ExTypesense.Collection

  defdelegate get_collection_alias(alias_name), to: ExTypesense.Collection
  defdelegate get_collection_alias(conn, alias_name), to: ExTypesense.Collection

  defdelegate delete_collection_alias(alias_name), to: ExTypesense.Collection
  defdelegate delete_collection_alias(conn, alias_name), to: ExTypesense.Collection

  defdelegate upsert_collection_alias(alias_name, coll_name), to: ExTypesense.Collection
  defdelegate upsert_collection_alias(conn, alias_name, coll_name), to: ExTypesense.Collection
  ##########################################################
  # end collection alias
  ##########################################################

  ##########################################################
  # start document-specific tasks
  ##########################################################
  defdelegate get_document(coll_name, doc_id), to: ExTypesense.Document
  defdelegate get_document(conn, coll_name, doc_id), to: ExTypesense.Document
  defdelegate get_document(conn, coll_name, doc_id, opts), to: ExTypesense.Document

  defdelegate index_document(document), to: ExTypesense.Document
  defdelegate index_document(collection_name, document), to: ExTypesense.Document
  defdelegate index_document(conn, collection_name, document), to: ExTypesense.Document
  defdelegate index_document(conn, collection_name, document, opts), to: ExTypesense.Document

  defdelegate delete_document(document), to: ExTypesense.Document
  defdelegate delete_document(coll_name, doc_id), to: ExTypesense.Document
  defdelegate delete_document(conn, coll_name, doc_id), to: ExTypesense.Document
  defdelegate delete_document(conn, coll_name, doc_id, ignore_not_found), to: ExTypesense.Document

  defdelegate delete_documents_by_query(collection_name, opts), to: ExTypesense.Document
  defdelegate delete_documents_by_query(conn, collection_name, opts), to: ExTypesense.Document

  defdelegate import_documents(documents), to: ExTypesense.Document
  defdelegate import_documents(conn, documents), to: ExTypesense.Document
  defdelegate import_documents(conn, coll_name, documents), to: ExTypesense.Document
  defdelegate import_documents(conn, coll_name, documents, opts), to: ExTypesense.Document

  defdelegate export_documents(coll_name), to: ExTypesense.Document
  defdelegate export_documents(conn, coll_name), to: ExTypesense.Document
  defdelegate export_documents(conn, coll_name, opts), to: ExTypesense.Document

  defdelegate delete_all_documents(collection_name), to: ExTypesense.Document
  defdelegate delete_all_documents(conn, collection_name), to: ExTypesense.Document

  defdelegate update_document(document), to: ExTypesense.Document
  defdelegate update_document(conn, document), to: ExTypesense.Document
  defdelegate update_document(conn, document, opts), to: ExTypesense.Document

  defdelegate update_documents_by_query(coll_name, body, opts), to: ExTypesense.Document
  defdelegate update_documents_by_query(conn, coll_name, body, opts), to: ExTypesense.Document
  ##########################################################
  # end document-specific tasks
  ##########################################################

  ##########################################################
  # start search
  ##########################################################
  defdelegate search(coll_name, opts), to: ExTypesense.Search
  defdelegate search(conn, coll_name, opts), to: ExTypesense.Search

  defdelegate multi_search(searches), to: ExTypesense.Search

  defdelegate multi_search_ecto(searches), to: ExTypesense.Search
  defdelegate multi_search_ecto(conn, searches), to: ExTypesense.Search
  defdelegate multi_search_ecto(conn, searches, opts), to: ExTypesense.Search
  ##########################################################
  # end search
  ##########################################################

  ##########################################################
  # start curation
  ##########################################################
  ##########################################################
  # end curation
  ##########################################################

  ##########################################################
  # start synonyms
  ##########################################################
  ##########################################################
  # end synonyms
  ##########################################################

  ##########################################################
  # start cluster operations
  ##########################################################
  defdelegate api_stats, to: ExTypesense.Cluster
  defdelegate api_stats(conn), to: ExTypesense.Cluster

  defdelegate cluster_metrics, to: ExTypesense.Cluster
  defdelegate cluster_metrics(conn), to: ExTypesense.Cluster

  defdelegate health, to: ExTypesense.Cluster
  defdelegate health(conn), to: ExTypesense.Cluster

  defdelegate create_snapshot(snapshot_path), to: ExTypesense.Cluster
  defdelegate create_snapshot(conn, snapshot_path), to: ExTypesense.Cluster

  defdelegate compact_db, to: ExTypesense.Cluster
  defdelegate compact_db(conn), to: ExTypesense.Cluster

  defdelegate clear_cache, to: ExTypesense.Cluster
  defdelegate clear_cache(conn), to: ExTypesense.Cluster

  defdelegate toggle_slow_request_log(config), to: ExTypesense.Cluster
  defdelegate toggle_slow_request_log(conn, config), to: ExTypesense.Cluster

  defdelegate vote, to: ExTypesense.Cluster
  defdelegate vote(conn), to: ExTypesense.Cluster
  ##########################################################
  # end cluster operations
  ##########################################################
end
