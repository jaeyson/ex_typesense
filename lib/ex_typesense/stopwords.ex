defmodule ExTypesense.Stopwords do
  @moduledoc since: "1.0.0"

  @moduledoc """
  Stopwords are keywords which will be removed from search
  query while searching.

  > #### During indexing {: .info}
  >
  > Stopwords are **NOT** dropped during indexing.

  More here: https://typesense.org/docs/latest/api/stopwords.html
  """

  alias OpenApiTypesense.Connection

  @doc """
  Retrieve the details of a stopwords set, given it's name.
  """
  @doc since: "1.0.0"
  @spec get_stopword(String.t()) ::
          {:ok, OpenApiTypesense.StopwordsSetRetrieveSchema.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def get_stopword(stop_id) do
    get_stopword(stop_id, [])
  end

  @doc """
  Same as [get_stopword/1](`get_stopword/1`)

  ```elixir
  ExTypesense.get_stopword("stopword_set_countries", [])
  ExTypesense.get_stopword(%{api_key: xyz, host: ...}, "stopword_set_countries")
  ExTypesense.get_stopword(OpenApiTypesense.Connection.new(), "stopword_set_countries")
  ```
  """
  @doc since: "1.0.0"
  @spec get_stopword(map() | Connection.t() | String.t(), String.t() | keyword()) ::
          {:ok, OpenApiTypesense.StopwordsSetRetrieveSchema.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def get_stopword(stop_id, opts) when is_list(opts) do
    Connection.new() |> get_stopword(stop_id, opts)
  end

  def get_stopword(conn, stop_id) do
    get_stopword(conn, stop_id, [])
  end

  @doc """
  Same as [get_stopword/2](`get_stopword/2`) but passes another connection.

  ```elixir
  ExTypesense.get_stopword(%{api_key: xyz, host: ...}, "stopword_set_countries", [])
  ExTypesense.get_stopword(OpenApiTypesense.Connection.new(), "stopword_set_countries", [])
  ```
  """
  @doc since: "1.0.0"
  @spec get_stopword(map() | Connection.t(), String.t(), keyword()) ::
          {:ok, OpenApiTypesense.StopwordsSetRetrieveSchema.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def get_stopword(conn, stop_id, opts) do
    OpenApiTypesense.Stopwords.retrieve_stopwords_set(conn, stop_id, opts)
  end

  @doc """
  Upserts a stopwords set.

  ## Examples
      iex> body = %{
      ...>   "stopwords" => [
      ...>     "Bustin Jieber",
      ...>     "Pelvis Presly",
      ...>     "Tinus Lorvalds",
      ...>     "Britney Smears"
      ...>   ],
      ...>   "locale" => "en"
      ...> }
      iex> ExTypesense.upsert_override("stopwords-famous-person", body)
  """
  @doc since: "1.0.0"
  @spec upsert_stopword(String.t(), map()) ::
          {:ok, OpenApiTypesense.StopwordsSetSchema.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def upsert_stopword(stop_id, body) do
    upsert_stopword(stop_id, body, [])
  end

  @doc """
  Same as [upsert_stopword/2](`upsert_stopword/2`)

  ```elixir
  ExTypesense.upsert_stopword("stopword_set_countries", body, [])
  ExTypesense.upsert_stopword(%{api_key: xyz, host: ...}, "stopword_set_countries", body)
  ExTypesense.upsert_stopword(OpenApiTypesense.Connection.new(), "stopword_set_countries", body)
  ```
  """
  @doc since: "1.0.0"
  @spec upsert_stopword(
          map() | Connection.t() | String.t(),
          String.t() | map(),
          map() | keyword()
        ) ::
          {:ok, OpenApiTypesense.StopwordsSetSchema.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def upsert_stopword(stop_id, body, opts) when is_list(opts) do
    Connection.new() |> upsert_stopword(stop_id, body, opts)
  end

  def upsert_stopword(conn, stop_id, body) do
    upsert_stopword(conn, stop_id, body, [])
  end

  @doc """
  Same as [upsert_stopword/3](`upsert_stopword/3`) but passes another connection.

  ```elixir
  ExTypesense.upsert_stopword(%{api_key: xyz, host: ...}, "stopword_set_countries", body, [])
  ExTypesense.upsert_stopword(OpenApiTypesense.Connection.new(), "stopword_set_countries", body, [])
  ```
  """
  @doc since: "1.0.0"
  @spec upsert_stopword(map() | Connection.t(), String.t(), map(), keyword()) ::
          {:ok, OpenApiTypesense.StopwordsSetSchema.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def upsert_stopword(conn, stop_id, body, opts) do
    OpenApiTypesense.Stopwords.upsert_stopwords_set(conn, stop_id, body, opts)
  end

  @doc """
  Retrieves all stopwords sets.
  """
  @doc since: "1.0.0"
  @spec list_stopwords :: {:ok, OpenApiTypesense.StopwordsSetsRetrieveAllSchema.t()} | :error
  def list_stopwords do
    list_stopwords([])
  end

  @doc """
  Same as [list_stopwords/0](`list_stopwords/0`)

  ```elixir
  ExTypesense.list_stopwords([])
  ExTypesense.list_stopwords(%{api_key: xyz, host: ...})
  ExTypesense.list_stopwords(OpenApiTypesense.Connection.new())
  ```
  """
  @doc since: "1.0.0"
  @spec list_stopwords(map() | Connection.t() | keyword()) ::
          {:ok, OpenApiTypesense.StopwordsSetsRetrieveAllSchema.t()} | :error
  def list_stopwords(opts) when is_list(opts) do
    Connection.new() |> list_stopwords(opts)
  end

  def list_stopwords(conn) do
    list_stopwords(conn, [])
  end

  @doc """
  Same as [list_stopwords/1](`list_stopwords/1`) but passes another connection.

  ```elixir
  ExTypesense.list_stopwords(%{api_key: xyz, host: ...}, [])
  ExTypesense.list_stopwords(OpenApiTypesense.Connection.new(), [])
  ```
  """
  @doc since: "1.0.0"
  @spec list_stopwords(map() | Connection.t(), keyword()) ::
          {:ok, OpenApiTypesense.StopwordsSetsRetrieveAllSchema.t()} | :error
  def list_stopwords(conn, opts) do
    OpenApiTypesense.Stopwords.retrieve_stopwords_sets(conn, opts)
  end

  @doc """
  Permanently deletes a stopwords set, given it's name.
  """
  @doc since: "1.0.0"
  @spec delete_stopword(String.t()) ::
          {:ok, map} | {:error, OpenApiTypesense.ApiResponse.t()}
  def delete_stopword(stop_id) do
    delete_stopword(stop_id, [])
  end

  @doc """
  Same as [delete_stopword/1](`delete_stopword/1`)

  ```elixir
  ExTypesense.delete_stopword("stopword_set_countries", [])
  ExTypesense.delete_stopword(%{api_key: xyz, host: ...}, "stopword_set_countries")
  ExTypesense.delete_stopword(OpenApiTypesense.Connection.new(), "stopword_set_countries")
  ```
  """
  @doc since: "1.0.0"
  @spec delete_stopword(map() | Connection.t() | String.t(), String.t() | keyword()) ::
          {:ok, map} | {:error, OpenApiTypesense.ApiResponse.t()}
  def delete_stopword(stop_id, opts) when is_list(opts) do
    Connection.new() |> delete_stopword(stop_id, opts)
  end

  def delete_stopword(conn, stop_id) do
    delete_stopword(conn, stop_id, [])
  end

  @doc """
  Same as [delete_stopword/2](`delete_stopword/2`) but passes another connection.

  ```elixir
  ExTypesense.delete_stopword(%{api_key: xyz, host: ...}, "stopword_set_countries", [])
  ExTypesense.delete_stopword(OpenApiTypesense.Connection.new(), "stopword_set_countries", [])
  ```
  """
  @doc since: "1.0.0"
  @spec delete_stopword(map() | Connection.t(), String.t(), keyword()) ::
          {:ok, map} | {:error, OpenApiTypesense.ApiResponse.t()}
  def delete_stopword(conn, stop_id, opts) do
    OpenApiTypesense.Stopwords.delete_stopwords_set(conn, stop_id, opts)
  end
end
