defmodule ExTypesense.Search do
  @moduledoc since: "0.3.0"
  @moduledoc """
  Module for searching documents.
  """

  alias ExTypesense.HttpClient
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
  @spec search(module() | String.t(), map()) :: response()
  def search(module_name, params) when is_atom(module_name) and is_map(params) do
    collection_name = module_name.__schema__(:source)

    path =
      Path.join([
        @collections_path,
        collection_name,
        @documents_path,
        @search_path
      ])

    {:ok, result} = HttpClient.run(:get, path, nil, params)

    case Enum.empty?(result["hits"]) do
      true ->
        module_name
        |> where([i], i.id in [])

      false ->
        # this assumes the fk pointing to primary, e.g. post_id
        first_virtual_field = hd(module_name.__schema__(:virtual_fields))

        # this assumes the pk, e.g. posts' "id" that matches fk above
        primary_key = hd(module_name.__schema__(:primary_key))

        values =
          Enum.map(result["hits"], fn %{"document" => document} ->
            document[to_string(first_virtual_field)]
          end)

        module_name
        |> where([i], field(i, ^primary_key) in ^values)
    end
  end

  def search(collection_name, params) when is_binary(collection_name) and is_map(params) do
    path =
      Path.join([
        @collections_path,
        collection_name,
        @documents_path,
        @search_path
      ])

    HttpClient.run(:get, path, nil, params)
  end
end
