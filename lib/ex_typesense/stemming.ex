defmodule ExTypesense.Stemming do
  @moduledoc since: "1.2.0"

  @moduledoc """
  Stemming specific operations.

  More here: https://typesense.org/docs/latest/api/stemming.html
  """

  alias OpenApiTypesense.Connection

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

  ```elixir
  ExTypesense.get_stemming_dictionary(dictionary_id, [])

  ExTypesense.get_stemming_dictionary(%{api_key: xyz, host: ...}, dictionary_id)

  ExTypesense.get_stemming_dictionary(OpenApiTypesense.Connection.new(), dictionary_id)
  ```
  """
  @doc since: "1.2.0"
  @spec get_stemming_dictionary(map() | Connection.t() | String.t(), String.t() | keyword()) ::
          {:ok, OpenApiTypesense.StemmingDictionary.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def get_stemming_dictionary(dictionary_id, opts) when is_list(opts) do
    get_stemming_dictionary(Connection.new(), dictionary_id, opts)
  end

  def get_stemming_dictionary(conn, dictionary_id) do
    get_stemming_dictionary(conn, dictionary_id, [])
  end

  @doc """
  Same as [get_stemming_dictionary/2](`get_stemming_dictionary/2`) but passes another connection.

  ```elixir
  ExTypesense.get_stemming_dictionary(%{api_key: xyz, host: ...}, dictionary_id, [])

  ExTypesense.get_stemming_dictionary(OpenApiTypesense.Connection.new(), dictionary_id, [])
  ```
  """
  @doc since: "1.2.0"
  @spec get_stemming_dictionary(map() | Connection.t(), String.t(), keyword()) ::
          {:ok, OpenApiTypesense.StemmingDictionary.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def get_stemming_dictionary(conn, dictionary_id, opts) do
    OpenApiTypesense.Stemming.get_stemming_dictionary(conn, dictionary_id, opts)
  end

  @doc """
  Import a stemming dictionary

  ## Options

    * `id`: The ID to assign to the dictionary

  ## Example
      iex> body = [
      ...>   %{"word" => "people", "root" => "person"}
      ...>   %{"word" => "children", "root" => "child"}
      ...>   %{"word" => "geese", "root" => "goose"}
      ...> ]
      iex> ExTypesense.import_stemming_dictionary(body, id: "irregular-plurals")
  """
  @doc since: "1.2.0"
  @spec import_stemming_dictionary(list(map()), keyword()) ::
          {:ok, String.t()} | {:error, OpenApiTypesense.ApiResponse.t()}
  def import_stemming_dictionary(body, opts) when is_list(opts) do
    Connection.new() |> import_stemming_dictionary(body, opts)
  end

  @doc """
  Same as [import_stemming_dictionary/2](`import_stemming_dictionary/2`) but passes another connection.

  Either one of:
  - `import_stemming_dictionary(%{api_key: xyz, host: ...}, body, id: "something")`
  - `import_stemming_dictionary(dictionary_id, Connection.new(), body, id: "some-id")`
  """
  @doc since: "1.2.0"
  @spec import_stemming_dictionary(map() | Connection.t(), list(map()), keyword()) ::
          {:ok, String.t()} | {:error, OpenApiTypesense.ApiResponse.t()}
  def import_stemming_dictionary(conn, body, opts) do
    OpenApiTypesense.Stemming.import_stemming_dictionary(conn, body, opts)
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

  ```elixir
  ExTypesense.list_stemming_dictionaries([])

  ExTypesense.list_stemming_dictionaries(%{api_key: xyz, host: ...})

  ExTypesense.list_stemming_dictionaries(OpenApiTypesense.Connection.new())
  ```
  """
  @doc since: "1.2.0"
  @spec list_stemming_dictionaries(map() | Connection.t() | keyword()) ::
          {:ok, map} | {:error, OpenApiTypesense.ApiResponse.t()}
  def list_stemming_dictionaries(opts) when is_list(opts) do
    list_stemming_dictionaries(Connection.new(), opts)
  end

  def list_stemming_dictionaries(conn) do
    list_stemming_dictionaries(conn, [])
  end

  @doc """
  Same as [list_stemming_dictionaries/1](`list_stemming_dictionaries/1`) but passes another connection.

  ```elixir
  ExTypesense.list_stemming_dictionaries(%{api_key: xyz, host: ...}, [])

  ExTypesense.list_stemming_dictionaries(OpenApiTypesense.Connection.new(), [])
  ```
  """
  @doc since: "1.2.0"
  @spec list_stemming_dictionaries(map() | Connection.t(), keyword()) ::
          {:ok, map} | {:error, OpenApiTypesense.ApiResponse.t()}
  def list_stemming_dictionaries(conn, opts) do
    OpenApiTypesense.Stemming.list_stemming_dictionaries(conn, opts)
  end
end
