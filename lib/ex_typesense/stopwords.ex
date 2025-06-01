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

  ## Options

    * `conn`: The custom connection map or struct you passed

  ## Examples
      iex> conn = %{api_key: xyz, host: ...}
      iex> ExTypesense.get_stopword("stopword_set_countries", conn: conn)

      iex> conn = OpenApiTypesense.Connection.new()
      iex> ExTypesense.get_stopword("stopword_set_countries", conn: conn)

      iex> opts = [conn: conn]
      iex> ExTypesense.get_stopword("stopword_set_countries", opts)
  """
  @doc since: "1.0.0"
  @spec get_stopword(String.t(), keyword()) ::
          {:ok, OpenApiTypesense.StopwordsSetRetrieveSchema.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def get_stopword(stop_id, opts) do
    OpenApiTypesense.Stopwords.retrieve_stopwords_set(stop_id, opts)
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

  ## Options

    * `conn`: The custom connection map or struct you passed

  ## Examples
      iex> conn = %{api_key: xyz, host: ...}
      iex> ExTypesense.upsert_stopword("stopword_set_countries", body, conn: conn)

      iex> conn = OpenApiTypesense.Connection.new()
      iex> ExTypesense.upsert_stopword("stopword_set_countries", body, conn: conn)

      iex> opts = [conn: conn]
      iex> ExTypesense.upsert_stopword("stopword_set_countries", body, opts)
  """
  @doc since: "1.0.0"
  @spec upsert_stopword(String.t(), map(), keyword()) ::
          {:ok, OpenApiTypesense.StopwordsSetSchema.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def upsert_stopword(stop_id, body, opts) do
    OpenApiTypesense.Stopwords.upsert_stopwords_set(stop_id, body, opts)
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

  ## Options

    * `conn`: The custom connection map or struct you passed

  ## Examples
      iex> conn = %{api_key: xyz, host: ...}
      iex> ExTypesense.list_stopwords(conn: conn)

      iex> conn = OpenApiTypesense.Connection.new()
      iex> ExTypesense.list_stopwords(conn: conn)

      iex> opts = [conn: conn]
      iex> ExTypesense.list_stopwords(opts)
  """
  @doc since: "1.0.0"
  @spec list_stopwords(keyword()) ::
          {:ok, OpenApiTypesense.StopwordsSetsRetrieveAllSchema.t()} | :error
  def list_stopwords(opts) do
    OpenApiTypesense.Stopwords.retrieve_stopwords_sets(opts)
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

  ## Options

    * `conn`: The custom connection map or struct you passed

  ## Examples
      iex> conn = %{api_key: xyz, host: ...}
      iex> ExTypesense.delete_stopword("stopword_set_countries", conn: conn)

      iex> conn = OpenApiTypesense.Connection.new()
      iex> ExTypesense.delete_stopword("stopword_set_countries", conn: conn)

      iex> opts = [conn: conn]
      iex> ExTypesense.delete_stopword("stopword_set_countries", opts)
  """
  @doc since: "1.0.0"
  @spec delete_stopword(String.t(), keyword()) ::
          {:ok, map} | {:error, OpenApiTypesense.ApiResponse.t()}
  def delete_stopword(stop_id, opts) do
    OpenApiTypesense.Stopwords.delete_stopwords_set(stop_id, opts)
  end
end
