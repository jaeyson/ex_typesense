defmodule ExTypesense.Document do
  alias ExTypesense.HttpClient

  @moduledoc since: "0.1.0"
  @moduledoc """
  Module for CRUD operations for documents. Refer to this [doc guide](https://typesense.org/docs/latest/api/documents.html).
  """

  @collections_path "/collections"
  @documents_path "/documents"
  @type response :: {:ok, map()} | {:error, map()}

  @doc """
  Get a document from a collection by its document `id`.
  """
  @doc since: "0.1.0"
  @spec get_document(String.t()) :: response()
  def get_document(document_id) do
    path = Path.join([@collections_path, document_id])

    HttpClient.run(:get, path)
  end
end
