defmodule ExTypesense.Document do
  @moduledoc since: "0.1.0"
  @moduledoc """
  Module for CRUD operations for documents. Refer to this [doc guide](https://typesense.org/docs/latest/api/documents.html).
  """

  alias ExTypesense.HttpClient

  @collections_path "/collections"
  @documents_path "/documents"
  @import_path "/import"
  @api_header_name 'X-TYPESENSE-API-KEY'
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

  @doc """
  Indexes multiple documents.

  ## Examples
      iex> posts = Posts |> Repo.all()

      iex> Document.index_multiple_documents(posts)
      [
        %{"success" => true},
        %{"success" => true},
        ...
      ]
  """
  @doc since: "0.1.0"
  @spec index_multiple_documents(list(struct())) :: list(map())
  def index_multiple_documents(list_of_structs) do
    payload =
      list_of_structs
      |> Stream.map(&Jason.encode!/1)
      |> Enum.join("\n")

    collection_name = hd(list_of_structs).__struct__.__schema__(:source)

    path =
      [
        @collections_path,
        collection_name,
        @documents_path,
        @import_path
      ]
      |> Path.join()

    url = %URI{
      host: HttpClient.get_host(),
      port: HttpClient.get_port(),
      scheme: HttpClient.get_scheme(),
      path: path,
      query: "action=create"
    }

    api_key = String.to_charlist(HttpClient.api_key())

    headers = [{@api_header_name, api_key}]
    content_type = 'text/plain;'

    request = {
      URI.to_string(url),
      headers,
      content_type,
      payload
    }

    case :httpc.request(:post, request, [], []) do
      {:ok, {_status_code, _headers, message}} ->
        message
        |> to_string()
        |> String.split("\n")
        |> Stream.map(&Jason.decode!/1)
        |> Enum.to_list()

      {:error, reason} ->
        reason
    end
  end
end
