defmodule ExTypesense do
  @moduledoc since: "0.1.0"
  @moduledoc """
  Public API functions to interact with Typesense.

  If you want to implement field types for your Ecto schema,
  you may need to encode the schema and add the callback `get_field_types/0`:

  ```elixir
  # this example module can be found at: lib/ex_typesense/test_schema/person.ex
  defmodule App.Person do
    @behaviour ExTypesense

    defimpl Jason.Encoder, for: __MODULE__ do
      def encode(value, opts) do
        value
        |> Map.take([:id, :person_id, :name, :age])
        |> Enum.map(fn {key, val} ->
          cond do
            key === :id -> {key, to_string(Map.get(value, :id))}
            key === :person_id -> {key, Map.get(value, :id)}
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
      field :person_id, :integer, virtual: true
    end

    @impl ExTypesense
    def get_field_types do
      %{
        default_sorting_field: "person_id",
        fields:
          [
            %{name: "person_id", type: "int32"},
            %{name: "name", type: "string"},
            %{name: "age", type: "integer"}
          ]
      }
    end
  end
  ```
  """

  alias ExTypesense.Connection

  @doc """
  A callback function for creating the schema fields in Typesense.
  """
  @callback get_field_types :: map()

  # collection-specific tasks
  defdelegate list_collections(conn \\ Connection.new()), to: ExTypesense.Collection
  defdelegate create_collection(conn \\ Connection.new(), schema), to: ExTypesense.Collection
  defdelegate get_collection(conn \\ Connection.new(), name), to: ExTypesense.Collection

  defdelegate get_collection_name(conn \\ Connection.new(), alias_name),
    to: ExTypesense.Collection

  defdelegate drop_collection(conn \\ Connection.new(), collection_name),
    to: ExTypesense.Collection

  defdelegate update_collection_fields(conn \\ Connection.new(), collection_name, fields),
    to: ExTypesense.Collection

  # collection alias
  defdelegate list_collection_aliases(conn \\ Connection.new()), to: ExTypesense.Collection

  defdelegate get_collection_alias(conn \\ Connection.new(), alias_name),
    to: ExTypesense.Collection

  defdelegate delete_collection_alias(conn \\ Connection.new(), alias_name),
    to: ExTypesense.Collection

  defdelegate upsert_collection_alias(conn \\ Connection.new(), alias_name, collection_name),
    to: ExTypesense.Collection

  # document-specific tasks
  defdelegate get_document(conn \\ Connection.new(), collection_name, document_id),
    to: ExTypesense.Document

  defdelegate create_document(conn \\ Connection.new(), document), to: ExTypesense.Document

  @deprecated "use delete_document_by_id/3"
  defdelegate delete_document(document), to: ExTypesense.Document

  @deprecated "use delete_document_by_struct/2"
  defdelegate delete_document(collection_name, document_id), to: ExTypesense.Document

  defdelegate delete_document_by_struct(conn \\ Connection.new(), struct),
    to: ExTypesense.Document

  defdelegate delete_document_by_id(conn \\ Connection.new(), collection_name, document_id),
    to: ExTypesense.Document

  defdelegate update_document(conn \\ Connection.new(), document), to: ExTypesense.Document
  defdelegate upsert_document(conn \\ Connection.new(), document), to: ExTypesense.Document

  defdelegate index_multiple_documents(conn \\ Connection.new(), documents),
    to: ExTypesense.Document

  defdelegate update_multiple_documents(conn \\ Connection.new(), documents),
    to: ExTypesense.Document

  defdelegate upsert_multiple_documents(conn \\ Connection.new(), documents),
    to: ExTypesense.Document

  # search
  defdelegate search(conn \\ Connection.new(), module_or_collection_name, params),
    to: ExTypesense.Search

  # geo search

  # multisearch
  defdelegate multi_search(conn \\ Connection.new(), searches),
    to: ExTypesense.Multisearch

  # curation

  # synonyms

  # cluster operations
  defdelegate api_stats(conn \\ Connection.new()), to: ExTypesense.Cluster
  defdelegate cluster_metrics(conn \\ Connection.new()), to: ExTypesense.Cluster
  defdelegate health(conn \\ Connection.new()), to: ExTypesense.Cluster
end
