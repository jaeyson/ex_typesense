defmodule ExTypesense do
  @moduledoc since: "0.1.0"
  @moduledoc """
  Public API functions to interact with Typesense.
  """

  # collection-specific tasks
  defdelegate list_collections, to: ExTypesense.Collection
  defdelegate create_collection(collection), to: ExTypesense.Collection
  defdelegate get_collection(collection_name), to: ExTypesense.Collection
  defdelegate delete_collection(collection_name), to: ExTypesense.Collection
  defdelegate update_collection(collection_name, collection), to: ExTypesense.Collection

  # collection alias
  defdelegate list_collection_aliases, to: ExTypesense.Collection
  defdelegate get_collection_alias(alias_name), to: ExTypesense.Collection
  defdelegate delete_collection_alias(alias_name), to: ExTypesense.Collection
  defdelegate upsert_collection_alias(alias_name, collection_name), to: ExTypesense.Collection

  # document-specific tasks
  defdelegate get_document(document_id), to: ExTypesense.Document
  defdelegate search(collection_name, search_term, query_by), to: ExTypesense.Document

  # search

  # geo search

  # multisearch

  # curation

  # synonyms
end
