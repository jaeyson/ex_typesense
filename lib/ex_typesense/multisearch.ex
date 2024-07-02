defmodule ExTypesense.Multisearch do
  @moduledoc since: "0.4.3"
  @moduledoc """
  Module for performing multiple searches at once. This module is also convenient for vector searches,
  as it works over POST and allows bigger payloads than GET requests.
  """

  alias ExTypesense.Connection
  alias ExTypesense.HttpClient


  @multi_search_path "/multi_search"
  @type response :: {:ok, map()} | {:error, map()}

  @doc """
  Perform multiple searches at once.

  ## Examples
      iex> searches = [
      ...>   %{collection: "companies", params: %{q: "umbrella"}},
      ...>   %{collection: "companies", params: %{q: "rain"}},
      ...>   %{collection: "companies", params: %{q: "sun"}}
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
             "q" => "umbrella"
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
             "q" => "rain"
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
             "q" => "sun"
           },
           "search_cutoff" => false,
           "search_time_ms" => 5
         }
       ]
      }
  """
  @doc since: "0.4.3"
  @spec multi_search(Connection.t(), [map()]) :: response()
  def multi_search(conn, searches) do
    path = @multi_search_path

    response = HttpClient.request(
      conn,
      %{
        method: :post,
        path: path,
        body: Jason.encode!(%{searches: searches})
      }
    )

    response
  end
end
