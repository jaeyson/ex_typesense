defmodule ExTypesense.Search do
  @moduledoc since: "0.3.0"
  @moduledoc """
  Module for searching documents.

  More here: https://typesense.org/docs/latest/api/search.html
  """

  alias ExTypesense.Connection
  alias ExTypesense.HttpClient
  alias ExTypesense.ResultParser
  import Ecto.Query, warn: false

  @root_path "/"
  @collections_path @root_path <> "collections"
  @documents_path "documents"
  @search_path "search"
  @multi_search_path "/multi_search"

  @typedoc since: "0.1.0"
  @type response :: {:ok, map()} | {:error, map()} | {:error, String.t()}

  @doc """
  Search from a document or Ecto Schema.
  Search params can be found [here](https://typesense.org/docs/latest/api/search.html#search-parameters).

  ## Examples
      iex> params = %{q: "umbrella", query_by: "title,description"}
      iex> ExTypesense.search(Catalog, params)
      {:ok,
       %{
        "facet_counts" => [],
        "found" => 0,
        "hits" => [],
        "out_of" => 0,
        "page" => 1,
        "request_params" => %{
          "collection_name" => "catalogs",
          "per_page" => 10,
          "q" => "umbrella"
        },
        "search_cutoff" => false,
        "search_time_ms" => 5
       }
      }

      iex> params = %{q: "umbrella", query_by: "title,description"}
      iex> ExTypesense.search("catalogs", params)
      {:ok,
       %{
        "facet_counts" => [],
        "found" => 0,
        "hits" => [],
        "out_of" => 0,
        "page" => 1,
        "request_params" => %{
          "collection_name" => "catalogs",
          "per_page" => 10,
          "q" => "umbrella"
        },
        "search_cutoff" => false,
        "search_time_ms" => 5
       }
      }

  """
  @doc since: "0.1.0"
  @spec search(Connection.t(), module() | String.t(), map()) :: Ecto.Query.t() | response()
  def search(conn \\ Connection.new(), module_or_collection_name, params)

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

  @doc """
  Perform [multiple/federated](https://typesense.org/docs/latest/api/federated-multi-search.html)
  searches at once.
  Search params can be found [here](https://typesense.org/docs/latest/api/search.html#search-parameters).

  > #### Federated search {: .info}
  >
  > This is especially useful to avoid round-trip network latencies
  > incurred otherwise if each of these requests are sent in separate
  > HTTP requests.
  >
  > You can also use this feature to do a **federated search** across
  > multiple collections in a single HTTP request. For eg: in an
  > ecommerce products dataset, you can show results from both a
  > "products" collection, and a "brands" collection to the user, by
  > searching them in parallel with a multi_search request.

  ## Options

    * `limit_multi_searches`: Max number of search requests that can be sent in a
    multi-search request. Default 50
    * `x-typesense-api-key`: You can embed a separate search API key for each search
    within a multi_search request. This is useful when you want to apply different
    embedded filters for each collection in individual scoped API keys.

  ## Examples
      iex> searches = [
      ...>   %{collection: "companies", q: "Loca Cola"},
      ...>   %{collection: Company, q: "Burgler King"},
      ...>   %{collection: Catalog, q: "umbrella"}
      ...> ]
      iex> ExTypesense.multi_search(searches)
      {:ok,
       [
         %{
           "facet_counts" => [],
           "found" => 0,
           "hits" => [],
           "out_of" => 0,
           "page" => 1,
           "request_params" => %{
             "collection_name" => "companies",
             "per_page" => 10,
             "q" => "Loca Cola"
           },
           "search_cutoff" => false,
           "search_time_ms" => 5
         },
         %{
           "facet_counts" => [],
           "found" => 0,
           "hits" => [],
           "out_of" => 0,
           "page" => 1,
           "request_params" => %{
             "collection_name" => "companies",
             "per_page" => 10,
             "q" => "Burgler King"
           },
           "search_cutoff" => false,
           "search_time_ms" => 5
         },
         %{
           "facet_counts" => [],
           "found" => 0,
           "hits" => [],
           "out_of" => 0,
           "page" => 1,
           "request_params" => %{
             "collection_name" => "companies",
             "per_page" => 10,
             "q" => "umbrella"
           },
           "search_cutoff" => false,
           "search_time_ms" => 5
         }
       ]
      }
  """
  @doc since: "1.0.0"
  @spec multi_search(Connection.t(), [map()]) :: response()
  def multi_search(conn \\ Connection.new(), searches) do
    path = @multi_search_path

    searches =
      Enum.map(searches, fn %{collection: name} = search ->
        collection_name =
          case is_binary(name) do
            true -> name
            false -> name.__schema__(:source)
          end

        Map.put(search, :collection, collection_name)
      end)

    HttpClient.request(
      conn,
      %{
        method: :post,
        path: path,
        body: Jason.encode!(%{searches: searches})
      }
    )
  end

  @doc since: "1.0.0"
  @spec multi_search_ecto(Connection.t(), [map()]) :: Ecto.Query.t()
  def multi_search_ecto(conn \\ Connection.new(), searches) do
    {:ok, %{"results" => results}} = multi_search(conn, searches)

    Enum.map(results, fn result ->
      collection_name = get_in(result, ["request_params", "collection_name"])
      ResultParser.hits_to_query(result["hits"], collection_name)
    end)
  end
end
