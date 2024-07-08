defmodule ExTypesense.Search do
  @moduledoc since: "0.3.0"
  @moduledoc """
  Module for searching documents.
  """

  alias ExTypesense.Connection
  alias ExTypesense.HttpClient
  alias ExTypesense.ResultParser
  import Ecto.Query, warn: false

  @root_path "/"
  @collections_path @root_path <> "collections"
  @documents_path "documents"
  @search_path "search"
  @type response :: Ecto.Query.t() | {:ok, map()} | {:error, map()}

  @doc """
  Search from a document.

  ## Examples
      iex> params = %{q: "umbrella", query_by: "title,description"}
      iex> ExTypesense.search(Something, params)
      {:ok,
       %{
        "facet_counts" => [],
        "found" => 0,
        "hits" => [],
        "out_of" => 0,
        "page" => 1,
        "request_params" => %{
          "collection_name" => "something",
          "per_page" => 10,
          "q" => "umbrella"
        },
        "search_cutoff" => false,
        "search_time_ms" => 5
       }
      }

  """
  @doc since: "0.1.0"
  @spec search(Connection.t(), module() | String.t(), map()) :: response()
  def search(conn \\ Connection.new(), collection_name, params)

  def search(conn, collection_name, params) when is_atom(collection_name) and is_map(params) do
    collection = collection_name.__schema__(:source)

    path =
      Path.join([
        @collections_path,
        collection,
        @documents_path,
        @search_path
      ])

    {:ok, result} = HttpClient.request(conn, %{method: :get, path: path, query: params})

    ResultParser.hits_to_query(result["hits"], collection_name)
  end

  def search(conn, collection_name, params) when is_binary(collection_name) and is_map(params) do
    path =
      Path.join([
        @collections_path,
        collection_name,
        @documents_path,
        @search_path
      ])

    HttpClient.request(conn, %{method: :get, path: path, query: params})
  end
end
