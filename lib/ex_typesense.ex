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
        |> Map.take([:person_id, :name, :age])
        |> Enum.map(fn {key, val} ->
          if key === :person_id do
            {key, Map.get(value, :id)}
          else
            {key, val}
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

  @callback get_field_types :: any()

  # collection-specific tasks
  defdelegate list_collections, to: ExTypesense.Collection
  defdelegate create_collection(schema), to: ExTypesense.Collection
  defdelegate get_collection(name), to: ExTypesense.Collection
  defdelegate get_collection_name(alias_name), to: ExTypesense.Collection
  defdelegate drop_collection(collection_name), to: ExTypesense.Collection
  defdelegate update_collection_fields(collection_name, fields), to: ExTypesense.Collection

  # collection alias
  defdelegate list_collection_aliases, to: ExTypesense.Collection
  defdelegate get_collection_alias(alias_name), to: ExTypesense.Collection
  defdelegate delete_collection_alias(alias_name), to: ExTypesense.Collection
  defdelegate upsert_collection_alias(alias_name, collection_name), to: ExTypesense.Collection

  # document-specific tasks
  defdelegate get_document(collection_name, document_id), to: ExTypesense.Document
  defdelegate create_document(document), to: ExTypesense.Document
  defdelegate delete_document(collection_name, document_id), to: ExTypesense.Document
  defdelegate update_document(document, id), to: ExTypesense.Document
  defdelegate upsert_document(document, id \\ nil), to: ExTypesense.Document
  defdelegate index_multiple_documents(documents), to: ExTypesense.Document
  defdelegate update_multiple_documents(documents), to: ExTypesense.Document
  defdelegate upsert_multiple_documents(docuemnts), to: ExTypesense.Document

  # search
  defdelegate search(collection_name, params), to: ExTypesense.Search

  # geo search

  # multisearch

  # curation

  # synonyms

  # cluster operations
  defdelegate api_stats, to: ExTypesense.Cluster
  defdelegate cluster_metrics, to: ExTypesense.Cluster
  defdelegate health, to: ExTypesense.Cluster
end
