defmodule ExTypesense do
  @moduledoc since: "1.0.0"

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
  defdelegate list_collections(opts), to: ExTypesense.Collection

  defdelegate create_collection(schema), to: ExTypesense.Collection
  defdelegate create_collection(schema, opts), to: ExTypesense.Collection

  defdelegate create_collection_with_alias(schema), to: ExTypesense.Collection
  defdelegate create_collection_with_alias(schema, opts), to: ExTypesense.Collection

  defdelegate clone_collection(src_coll, new_coll), to: ExTypesense.Collection
  defdelegate clone_collection(src_coll, new_coll, opts), to: ExTypesense.Collection

  defdelegate get_collection(name), to: ExTypesense.Collection
  defdelegate get_collection(coll_name, opts), to: ExTypesense.Collection

  defdelegate drop_collection(name), to: ExTypesense.Collection
  defdelegate drop_collection(name, opts), to: ExTypesense.Collection

  defdelegate update_collection_fields(name, fields), to: ExTypesense.Collection
  defdelegate update_collection_fields(name, fields, opts), to: ExTypesense.Collection
  ##########################################################
  # end collection-specific tasks
  ##########################################################

  ##########################################################
  # start collection alias
  ##########################################################
  defdelegate list_collection_aliases, to: ExTypesense.Collection
  defdelegate list_collection_aliases(opts), to: ExTypesense.Collection

  defdelegate get_collection_alias(alias_name), to: ExTypesense.Collection
  defdelegate get_collection_alias(alias_name, opts), to: ExTypesense.Collection

  defdelegate delete_collection_alias(alias_name), to: ExTypesense.Collection
  defdelegate delete_collection_alias(alias_name, opts), to: ExTypesense.Collection

  defdelegate upsert_collection_alias(alias_name, coll_name), to: ExTypesense.Collection
  defdelegate upsert_collection_alias(alias_name, coll_name, opts), to: ExTypesense.Collection
  ##########################################################
  # end collection alias
  ##########################################################

  ##########################################################
  # start document-specific tasks
  ##########################################################
  defdelegate get_document(coll_name, doc_id), to: ExTypesense.Document
  defdelegate get_document(coll_name, doc_id, opts), to: ExTypesense.Document

  defdelegate index_document(document), to: ExTypesense.Document
  defdelegate index_document(collection_name, document), to: ExTypesense.Document
  defdelegate index_document(collection_name, document, opts), to: ExTypesense.Document

  defdelegate delete_document(document), to: ExTypesense.Document
  defdelegate delete_document(coll_name, doc_id), to: ExTypesense.Document
  defdelegate delete_document(coll_name, doc_id, opts), to: ExTypesense.Document

  defdelegate delete_documents_by_query(collection_name, opts), to: ExTypesense.Document

  defdelegate import_documents(coll_name, documents), to: ExTypesense.Document
  defdelegate import_documents(coll_name, documents, opts), to: ExTypesense.Document

  defdelegate export_documents(coll_name), to: ExTypesense.Document
  defdelegate export_documents(coll_name, opts), to: ExTypesense.Document

  defdelegate delete_all_documents(collection_name), to: ExTypesense.Document
  defdelegate delete_all_documents(collection_name, opts), to: ExTypesense.Document

  defdelegate update_document(document), to: ExTypesense.Document
  defdelegate update_document(document, opts), to: ExTypesense.Document

  defdelegate update_documents_by_query(coll_name, body, opts), to: ExTypesense.Document
  ##########################################################
  # end document-specific tasks
  ##########################################################

  ##########################################################
  # start API keys
  ##########################################################
  defdelegate get_key(key_id), to: ExTypesense.Key
  defdelegate get_key(key_id, opts), to: ExTypesense.Key

  defdelegate delete_key(key_id), to: ExTypesense.Key
  defdelegate delete_key(key_id, opts), to: ExTypesense.Key

  defdelegate create_key(body), to: ExTypesense.Key
  defdelegate create_key(body, opts), to: ExTypesense.Key

  defdelegate list_keys, to: ExTypesense.Key
  defdelegate list_keys(opts), to: ExTypesense.Key
  ##########################################################
  # end API keys
  ##########################################################

  ##########################################################
  # start presets
  ##########################################################
  defdelegate get_preset(preset_id), to: ExTypesense.Preset
  defdelegate get_preset(preset_id, opts), to: ExTypesense.Preset

  defdelegate upsert_preset(preset_id, body), to: ExTypesense.Preset
  defdelegate upsert_preset(preset_id, body, opts), to: ExTypesense.Preset

  defdelegate delete_preset(preset_id), to: ExTypesense.Preset
  defdelegate delete_preset(preset_id, opts), to: ExTypesense.Preset

  defdelegate list_presets, to: ExTypesense.Preset
  defdelegate list_presets(opts), to: ExTypesense.Preset
  ##########################################################
  # end presets
  ##########################################################

  ##########################################################
  # start stopwords
  ##########################################################
  defdelegate list_stopwords, to: ExTypesense.Stopwords
  defdelegate list_stopwords(opts), to: ExTypesense.Stopwords

  defdelegate get_stopword(stop_id), to: ExTypesense.Stopwords
  defdelegate get_stopword(stop_id, opts), to: ExTypesense.Stopwords

  defdelegate upsert_stopword(stop_id, body), to: ExTypesense.Stopwords
  defdelegate upsert_stopword(stop_id, body, opts), to: ExTypesense.Stopwords

  defdelegate delete_stopword(stop_id), to: ExTypesense.Stopwords
  defdelegate delete_stopword(stop_id, opts), to: ExTypesense.Stopwords
  ##########################################################
  # end stopwords
  ##########################################################

  ##########################################################
  # start conversation
  ##########################################################
  defdelegate create_model(body), to: ExTypesense.Conversation
  defdelegate create_model(body, opts), to: ExTypesense.Conversation

  defdelegate list_models, to: ExTypesense.Conversation
  defdelegate list_models(opts), to: ExTypesense.Conversation

  defdelegate get_model(model_id), to: ExTypesense.Conversation
  defdelegate get_model(model_id, opts), to: ExTypesense.Conversation

  defdelegate delete_model(model_id), to: ExTypesense.Conversation
  defdelegate delete_model(model_id, opts), to: ExTypesense.Conversation

  defdelegate update_model(model_id, body), to: ExTypesense.Conversation
  defdelegate update_model(model_id, body, opts), to: ExTypesense.Conversation
  ##########################################################
  # end conversation
  ##########################################################

  ##########################################################
  # start analytics
  ##########################################################
  defdelegate list_analytics_rules, to: ExTypesense.Analytics
  defdelegate list_analytics_rules(opts), to: ExTypesense.Analytics

  defdelegate create_analytics_event(body), to: ExTypesense.Analytics
  defdelegate create_analytics_event(body, opts), to: ExTypesense.Analytics

  defdelegate create_analytics_rule(body), to: ExTypesense.Analytics
  defdelegate create_analytics_rule(body, opts), to: ExTypesense.Analytics

  defdelegate get_analytics_rule(rule_name), to: ExTypesense.Analytics
  defdelegate get_analytics_rule(rule_name, opts), to: ExTypesense.Analytics

  defdelegate upsert_analytics_rule(rule_name, body), to: ExTypesense.Analytics
  defdelegate upsert_analytics_rule(rule_name, body, opts), to: ExTypesense.Analytics

  defdelegate delete_analytics_rule(rule_name), to: ExTypesense.Analytics
  defdelegate delete_analytics_rule(rule_name, opts), to: ExTypesense.Analytics
  ##########################################################
  # end analytics
  ##########################################################

  ##########################################################
  # start debug
  ##########################################################
  defdelegate debug, to: ExTypesense.Debug
  defdelegate debug(opts), to: ExTypesense.Debug
  ##########################################################
  # end debug
  ##########################################################

  ##########################################################
  # start search
  ##########################################################
  defdelegate search(coll_name, opts), to: ExTypesense.Search

  defdelegate search_ecto(coll_name, opts), to: ExTypesense.Search

  defdelegate multi_search(searches), to: ExTypesense.Search
  defdelegate multi_search(searches, opts), to: ExTypesense.Search

  defdelegate multi_search_ecto(searches), to: ExTypesense.Search
  defdelegate multi_search_ecto(searches, opts), to: ExTypesense.Search
  ##########################################################
  # end search
  ##########################################################

  ##########################################################
  # start curation
  ##########################################################
  defdelegate list_overrides(coll_name), to: ExTypesense.Curation
  defdelegate list_overrides(coll_name, opts), to: ExTypesense.Curation

  defdelegate get_override(coll_name, ovr_id), to: ExTypesense.Curation
  defdelegate get_override(coll_name, ovr_id, opts), to: ExTypesense.Curation

  defdelegate upsert_override(coll_name, ovr_id, body), to: ExTypesense.Curation
  defdelegate upsert_override(coll_name, ovr_id, body, opts), to: ExTypesense.Curation

  defdelegate delete_override(coll_name, ovr_id), to: ExTypesense.Curation
  defdelegate delete_override(coll_name, ovr_id, opts), to: ExTypesense.Curation
  ##########################################################
  # end curation
  ##########################################################

  ##########################################################
  # start synonyms
  ##########################################################
  defdelegate list_synonyms(coll_name), to: ExTypesense.Synonym
  defdelegate list_synonyms(coll_name, opts), to: ExTypesense.Synonym

  defdelegate get_synonym(coll_name, syn_id), to: ExTypesense.Synonym
  defdelegate get_synonym(coll_name, syn_id, opts), to: ExTypesense.Synonym

  defdelegate delete_synonym(coll_name, syn_id), to: ExTypesense.Synonym
  defdelegate delete_synonym(coll_name, syn_id, opts), to: ExTypesense.Synonym

  defdelegate upsert_synonym(coll_name, syn_id, body), to: ExTypesense.Synonym
  defdelegate upsert_synonym(coll_name, syn_id, body, opts), to: ExTypesense.Synonym
  ##########################################################
  # end synonyms
  ##########################################################

  ##########################################################
  # start stemming
  ##########################################################
  defdelegate get_stemming_dictionary(dictionary_id), to: ExTypesense.Stemming
  defdelegate get_stemming_dictionary(dictionary_id, opts), to: ExTypesense.Stemming

  defdelegate import_stemming_dictionary(body, opts), to: ExTypesense.Stemming

  defdelegate list_stemming_dictionaries(), to: ExTypesense.Stemming
  defdelegate list_stemming_dictionaries(opts), to: ExTypesense.Stemming
  ##########################################################
  # end stemming
  ##########################################################

  ##########################################################
  # start cluster operations
  ##########################################################
  defdelegate api_stats, to: ExTypesense.Cluster
  defdelegate api_stats(opts), to: ExTypesense.Cluster

  defdelegate cluster_metrics, to: ExTypesense.Cluster
  defdelegate cluster_metrics(opts), to: ExTypesense.Cluster

  defdelegate health, to: ExTypesense.Cluster
  defdelegate health(opts), to: ExTypesense.Cluster

  defdelegate create_snapshot(opts), to: ExTypesense.Cluster

  defdelegate compact_db, to: ExTypesense.Cluster
  defdelegate compact_db(opts), to: ExTypesense.Cluster

  defdelegate clear_cache, to: ExTypesense.Cluster
  defdelegate clear_cache(opts), to: ExTypesense.Cluster

  defdelegate get_schema_changes, to: ExTypesense.Cluster
  defdelegate get_schema_changes(opts), to: ExTypesense.Cluster

  defdelegate toggle_slow_request_log(config), to: ExTypesense.Cluster
  defdelegate toggle_slow_request_log(config, opts), to: ExTypesense.Cluster

  defdelegate vote, to: ExTypesense.Cluster
  defdelegate vote(opts), to: ExTypesense.Cluster
  ##########################################################
  # end cluster operations
  ##########################################################
end
