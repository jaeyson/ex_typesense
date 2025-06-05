defmodule ExTypesense.Search do
  @moduledoc since: "0.3.0"
  @moduledoc """
  Module for searching documents.

  More here: https://typesense.org/docs/latest/api/search.html
  """

  alias OpenApiTypesense.MultiSearchResult
  alias OpenApiTypesense.SearchResult

  import Ecto.Query, warn: false

  @doc """
  Search from a document or Ecto Schema.

  ## Options

    * `conn`: The custom connection map or struct you passed
    * Search params can be found [here](https://typesense.org/docs/latest/api/search.html#search-parameters).

  ## Examples
      iex> params = [q: "umbrella", query_by: "title,description"]
      iex> ExTypesense.search(Catalog, params)
      {:ok,
       %OpenApiTypesense.SearchResult{
        found: 0,
        hits: [],
        conversation: nil,
        facet_counts: [],
        found_docs: nil,
        grouped_hits: nil,
        out_of: 0,
        page: 1,
        request_params: %{
          q: "umbrella",
          collection_name: "catalogs",
          first_q: "umbrella",
          per_page: 10
        },
        search_cutoff: false,
        search_time_ms: 1
       }
      }

      iex> params = %{q: "umbrella", query_by: "title,description"}
      iex> ExTypesense.search("catalogs", params)
      {:ok,
       %OpenApiTypesense.SearchResult{
        found: 0,
        hits: [],
        conversation: nil,
        facet_counts: [],
        found_docs: nil,
        grouped_hits: nil,
        out_of: 0,
        page: 1,
        request_params: %{
          q: "umbrella",
          collection_name: "catalogs",
          first_q: "umbrella",
          per_page: 10
        },
        search_cutoff: false,
        search_time_ms: 1
       }
      }

      iex> conn = %{api_key: xyz, host: ...}
      iex> ExTypesense.search("companies", conn: conn)

      iex> conn = OpenApiTypesense.Connection.new()
      iex> ExTypesense.search("companies", conn: conn)

      iex> opts = [conn: conn, q: "hat", ...]
      iex> ExTypesense.search("companies", opts)
  """
  @doc since: "1.0.0"
  @spec search(String.t() | module(), keyword()) ::
          {:ok, OpenApiTypesense.SearchResult.t()} | {:error, OpenApiTypesense.ApiResponse.t()}
  def search(module, opts) when is_atom(module) do
    coll_name = module.__schema__(:source)
    search(coll_name, opts)
  end

  def search(coll_name, opts) when is_binary(coll_name) do
    OpenApiTypesense.Documents.search_collection(coll_name, opts)
  end

  @doc """
  Same as [search/2](`search/2`) but matches Ecto record(s) and returns struct(s).

  ## Options

    * `conn`: The custom connection map or struct you passed

  ## Examples
      iex> conn = %{api_key: xyz, host: ...}
      iex> ExTypesense.search_ecto("companies", conn: conn)

      iex> conn = OpenApiTypesense.Connection.new()
      iex> ExTypesense.search_ecto("companies", conn: conn)

      iex> opts = [conn: conn, ...]
      iex> ExTypesense.search_ecto("companies", opts)
  """
  @doc since: "1.0.0"
  @spec search_ecto(String.t() | module(), keyword()) ::
          Ecto.Query.t() | {:error, OpenApiTypesense.ApiResponse.t()}
  def search_ecto(module, opts) when is_atom(module) do
    coll_name = module.__schema__(:source)
    search_ecto(coll_name, opts)
  end

  def search_ecto(coll_name, opts) when is_binary(coll_name) do
    case search(coll_name, opts) do
      {:ok, %SearchResult{} = result} ->
        hits_to_query(result.hits, coll_name)

      {:error, response} ->
        {:error, response}
    end
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

  > #### ordered results {: .tip}
  >
  > The results array in a multi_search response is guaranteed
  > to be in the same order as the queries you send in the searches
  > array in your request.

  ## Options

    * `conn`: The custom connection map or struct you passed
    * `limit_multi_searches`: Max number of search requests that can be sent in a
    multi-search request. Default 50
    * `x-typesense-api-key`: You can embed a separate search API key for each search
    within a multi_search request. This is useful when you want to apply different
    embedded filters for each collection in individual scoped API keys.
    * `union`: When true, merges the search results from each search query into a
    single ordered set of hits. Default `false`

  ## Examples
      iex> searches = [
      ...>   %{collection: "companies", q: "Loca Cola"},
      ...>   %{collection: Company, q: "Burgler King"},
      ...>   %{collection: Catalog, q: "umbrella"}
      ...> ]
      iex> ExTypesense.multi_search(searches)
      {
        :ok,
        %OpenApiTypesense.MultiSearchResult{
          results: [
            %{
            facet_counts: [],
            found: 0,
            hits: [],
            out_of: 0,
            page: 1,
            request_params: %{
              collection_name: "companies",
              per_page: 10,
              q: "Loca Cola",
              first_q: "Loca Cola"
            },
            search_cutoff: false,
            search_time_ms: 5
            },
            %{
              facet_counts: [],
              found: 0,
              hits: [],
              out_of: 0,
              page: 1,
              request_params: %{
                collection_name: "companies",
                per_page: 10,
                q: "Burgler King",
                first_q: "Burgler King"
              },
              search_cutoff: false,
              search_time_ms: 5
            },
            %{
              facet_counts: [],
              found: 0,
              hits: [],
              out_of: 0,
              page: 1,
              request_params: %{
                collection_name: "catalogs",
                per_page: 10,
                q: "umbrella",
                first_q: "umbrella"
              },
              search_cutoff: false,
              search_time_ms: 5
            }
          ],
          conversation: nil
        }
      }
  """
  @doc since: "1.0.0"
  @spec multi_search(list(map())) ::
          {:ok, OpenApiTypesense.MultiSearchResult.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def multi_search(searches) do
    multi_search(searches, [])
  end

  @doc """
  Same as [multi_search/1](`multi_search/1`)

  ## Options

    * `conn`: The custom connection map or struct you passed

  ## Examples
      iex> opts = [conn: %{api_key: xyz, host: ...}, ...]
      iex> ExTypesense.multi_search(searches, opts)

      iex> opts = [conn: OpenApiTypesense.Connection.new(), ...]
      iex> ExTypesense.multi_search(searches, opts)
  """
  @doc since: "1.0.0"
  @spec multi_search(list(map()), keyword()) ::
          {:ok, OpenApiTypesense.MultiSearchResult.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def multi_search(searches, opts) do
    union = Keyword.get(opts, :union) === true

    searches =
      Enum.map(searches, fn search ->
        if Map.has_key?(search, :collection) do
          coll_name =
            if is_atom(Map.get(search, :collection)) do
              search.collection.__schema__(:source)
            else
              search.collection
            end

          Map.put(search, :collection, coll_name)
        else
          coll_name =
            if is_atom(Map.get(search, "collection")) do
              search["collection"].__schema__(:source)
            else
              search["collection"]
            end

          Map.put(search, "collection", coll_name)
        end
      end)

    OpenApiTypesense.Documents.multi_search(%OpenApiTypesense.MultiSearchSearchesParameter{union: union, searches: searches}, opts)
  end

  @doc """
  Same as [multi_search/1](`multi_search/1`) but returns a list of Ecto queries.

  ## Options (same as [multi_search/1](`multi_search/1`))

    * `limit_multi_searches`: Max number of search requests that can be sent in a
    multi-search request. Default 50
    * `x-typesense-api-key`: You can embed a separate search API key for each search
    within a multi_search request. This is useful when you want to apply different
    embedded filters for each collection in individual scoped API keys.

  ## Examples
      iex> # Do note the collection name isn't string!!!
      iex> searches = [
      ...>   %{collection: Company, q: "Burgler King"},
      ...>   %{collection: Catalog, q: "spoon"}
      ...> ]
      iex> ExTypesense.multi_search_ecto(searches)
  """
  @doc since: "1.0.0"
  @spec multi_search_ecto(list(map())) ::
          list(Ecto.Query.t() | OpenApiTypesense.ApiResponse.t())
  def multi_search_ecto(searches) do
    multi_search_ecto(searches, [])
  end

  @doc """
  Same as [multi_search_ecto/1](`multi_search_ecto/1`)

  ## Options

    * `conn`: The custom connection map or struct you passed

  ## Examples
      iex> opts = [conn: %{api_key: xyz, host: ...}, ...]
      iex> ExTypesense.multi_search_ecto(searches, opts)

      iex> opts = [conn: OpenApiTypesense.Connection.new(), ...]
      iex> ExTypesense.multi_search_ecto(searches, opts)
  """
  @doc since: "1.0.0"
  @spec multi_search_ecto(list(map()), keyword()) ::
          list(Ecto.Query.t() | OpenApiTypesense.ApiResponse.t())
  def multi_search_ecto(searches, opts) do
    case multi_search(searches, opts) do
      {:ok, %MultiSearchResult{results: results}} ->
        Enum.map(results, fn result ->
          case result do
            %{error: message, code: _http_status_code} ->
              %OpenApiTypesense.ApiResponse{message: message}

            _ ->
              collection_name = get_in(result, [:request_params, :collection_name])
              hits_to_query(result.hits, collection_name)
          end
        end)

      {:error, error} ->
        [error]
    end
  end

  @doc false
  @doc since: "1.0.0"
  @spec hits_to_query(Enum.t(), String.t()) :: Ecto.Query.t()
  defp hits_to_query([], schema_name) do
    schema_name
    |> where([i], i.id in [])
  end

  defp hits_to_query(hits, schema_name) do
    values =
      Enum.map(hits, fn %{document: document} ->
        document[schema_name <> "_id"]
      end)

    schema_name
    |> where([i], i.id in ^values)
  end
end
