defmodule ExTypesense.Document do
  @moduledoc since: "0.1.0"
  @moduledoc """
  Module for CRUD operations for documents. Refer to this [doc guide](https://typesense.org/docs/latest/api/documents.html).
  """

  alias ExTypesense.HttpClient
  import Ecto.Query, warn: false

  @collections_path "collections"
  @documents_path "documents"
  @search_path "search"
  @import_path "import"
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
  Search from a document.

  ## Examples
      iex> Document.search(Something, "umbrella", "title,description")
      {:ok,
       %{
        "facet_counts" => [],
        "found" => 20,
        "hits" => [...],
        "out_of" => 111,
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
  @spec search(module() | String.t(), String.t(), String.t()) :: response()
  def search(collection_name, search_term, query_by) do
    collection_name =
      if is_atom(collection_name) do
        collection_name.__schema__(:source)
      else
        collection_name
      end

    query = %{
      q: search_term,
      query_by: query_by
    }

    path =
      Path.join([
        @collections_path,
        collection_name,
        @documents_path,
        @search_path
      ])

    HttpClient.run(:get, path, nil, query)
  end

  @doc """
  Search from a document. Returns a list of structs or empty.

  ## Examples
      iex> Document.search(Something, "umbrella", "title,description")
      {:ok,
       %{
        "facet_counts" => [],
        "found" => 20,
        "hits" => [...],
        "out_of" => 111,
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
  @spec ecto_search(module(), module(), String.t(), String.t(), String.t()) :: [] | [struct()]
  def ecto_search(module_name, repo, search_term, search_field, query_by) do
    query = %{
      q: search_term,
      query_by: query_by
    }

    path =
      Path.join([
        @collections_path,
        module_name.__schema__(:source),
        @documents_path,
        @search_path
      ])

    {:ok, result} = HttpClient.run(:get, path, nil, query)

    case Enum.empty?(result["hits"]) do
      true ->
        []

      false ->
        values =
          Enum.map(result["hits"], fn %{"document" => document} ->
            get_in(document, ["slug"])
          end)

        search_field = String.to_existing_atom(search_field)

        module_name
        |> where([i], field(i, ^search_field) in ^values)
        |> repo.all()
    end
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

    http_opts = [
      ssl: [
        {:versions, [:"tlsv1.2"]},
        verify: :verify_peer,
        cacerts: :public_key.cacerts_get(),
        customize_hostname_check: [
          match_fun: :public_key.pkix_verify_hostname_match_fun(:https)
        ]
      ],
      timeout: 5_000,
      recv_timeout: 5_000
    ]

    case :httpc.request(:post, request, http_opts, []) do
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
