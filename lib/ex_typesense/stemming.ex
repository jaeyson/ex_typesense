defmodule ExTypesense.Stemming do
  @moduledoc since: "1.2.0"

  @moduledoc """
  Stemming specific operations.

  More here: https://typesense.org/docs/latest/api/stemming.html
  """

  @doc """
  Retrieve a stemming dictionary

  Fetch details of a specific stemming dictionary.
  """
  @doc since: "1.2.0"
  @spec get_stemming_dictionary(String.t()) ::
          {:ok, OpenApiTypesense.StemmingDictionary.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def get_stemming_dictionary(dictionary_id) do
    get_stemming_dictionary(dictionary_id, [])
  end

  @doc """
  Same as [get_stemming_dictionary/1](`get_stemming_dictionary/1`)

  ## Options

    * `conn`: The custom connection map or struct you passed

  ## Examples
      iex> conn = %{api_key: xyz, host: ...}
      iex> ExTypesense.get_stemming_dictionary(dictionary_id, conn: conn)

      iex> conn = OpenApiTypesense.Connection.new()
      iex> ExTypesense.get_stemming_dictionary(dictionary_id, conn: conn)

      iex> opts = [conn: conn]
      iex> ExTypesense.get_stemming_dictionary(dictionary_id, opts)
  """
  @doc since: "1.2.0"
  @spec get_stemming_dictionary(String.t(), keyword()) ::
          {:ok, OpenApiTypesense.StemmingDictionary.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def get_stemming_dictionary(dictionary_id, opts) do
    OpenApiTypesense.Stemming.get_stemming_dictionary(dictionary_id, opts)
  end

  @doc """
  Import a stemming dictionary

  ## Options

    * `conn`: The custom connection map or struct you passed
    * `id`: The ID to assign to the dictionary

  ## Example
      iex> body = [
      ...>   %{"word" => "people", "root" => "person"}
      ...>   %{"word" => "children", "root" => "child"}
      ...>   %{"word" => "geese", "root" => "goose"}
      ...> ]
      iex> ExTypesense.import_stemming_dictionary(body, id: "irregular-plurals")

      iex> conn = %{api_key: xyz, host: ...}
      iex> ExTypesense.import_stemming_dictionary(body, id: "irregular-plurals", conn: conn)

      iex> conn = OpenApiTypesense.Connection.new()
      iex> ExTypesense.import_stemming_dictionary(body, id: "irregular-plurals", conn: conn)

      iex> opts = [id: "irregular-plurals", conn: conn]
      iex> ExTypesense.import_stemming_dictionary(body, opts)
  """
  @doc since: "1.2.0"
  @spec import_stemming_dictionary(list(map()), keyword()) ::
          {:ok, String.t()} | {:error, OpenApiTypesense.ApiResponse.t()}
  def import_stemming_dictionary(body, opts) do
    json_body = Jason.encode!(body)
    OpenApiTypesense.Stemming.import_stemming_dictionary(json_body, opts)
  end

  @doc """
  List all stemming dictionaries
  """
  @doc since: "1.2.0"
  @spec list_stemming_dictionaries ::
          {:ok, map} | {:error, OpenApiTypesense.ApiResponse.t()}
  def list_stemming_dictionaries do
    list_stemming_dictionaries([])
  end

  @doc """
  Same as [list_stemming_dictionaries/0](`list_stemming_dictionaries/0`)

  ## Options

    * `conn`: The custom connection map or struct you passed

  ## Examples
      iex> conn = %{api_key: xyz, host: ...}
      iex> ExTypesense.list_stemming_dictionaries(conn: conn)

      iex> conn = OpenApiTypesense.Connection.new()
      iex> ExTypesense.list_stemming_dictionaries(conn: conn)

      iex> opts = [conn: conn]
      iex> ExTypesense.list_stemming_dictionaries(opts)
  """
  @doc since: "1.2.0"
  @spec list_stemming_dictionaries(keyword()) ::
          {:ok, map} | {:error, OpenApiTypesense.ApiResponse.t()}
  def list_stemming_dictionaries(opts) do
    OpenApiTypesense.Stemming.list_stemming_dictionaries(opts)
  end
end
