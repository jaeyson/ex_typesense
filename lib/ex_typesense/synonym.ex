defmodule ExTypesense.Synonym do
  @moduledoc since: "1.0.0"

  @moduledoc """
  The synonyms feature allows you to define search terms that should
  be considered equivalent. For eg: when you define a synonym for
  `sneaker` as `shoe`, searching for `sneaker` will now return all records
  with the word `shoe` in them, in addition to records with the word `sneaker`.

  More here: https://typesense.org/docs/latest/api/synonyms.html
  """

  alias OpenApiTypesense.Connection

  @doc """
  List all synonyms associated with a given collection.

  > #### Error {: .info}
  >
  > By default, **ALL** synonyms are returned, but you can use the
  > `offset` and `limit` parameters to paginate on the listing.

  ## Options

    * `limit`: Limit results in paginating on collection listing.
    * `offset`: Skip a certain number of results and start after that.

  """
  @doc since: "1.0.0"
  @spec list_synonyms(String.t() | module()) ::
          {:ok, OpenApiTypesense.SearchSynonymsResponse.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def list_synonyms(collection_name) do
    Connection.new() |> list_synonyms(collection_name)
  end

  @doc """
  Same as [list_synonyms/1](`list_synonyms/1`).

  ```elixir
  ExTypesense.list_synonyms("persons", [])
  ExTypesense.list_synonyms(%{api_key: xyz, host: ...}, "persons")
  ExTypesense.list_synonyms(OpenApiTypesense.Connection.new(), MyApp.Accounts.Person)
  ```
  """
  @doc since: "1.0.0"
  @spec list_synonyms(
          map() | Connection.t() | String.t() | module(),
          String.t() | module() | keyword()
        ) ::
          {:ok, OpenApiTypesense.SearchSynonymsResponse.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def list_synonyms(coll_name, opts) when is_list(opts) do
    Connection.new() |> list_synonyms(coll_name, opts)
  end

  def list_synonyms(conn, coll_name) do
    list_synonyms(conn, coll_name, [])
  end

  @doc """
  Same as [list_synonyms/2](`list_synonyms/2`) but passes another connection.

  ```elixir
  ExTypesense.list_synonyms(%{api_key: xyz, host: ...}, "persons", limit: 10)
  ExTypesense.list_synonyms(OpenApiTypesense.Connection.new(), MyApp.Accounts.Person, [])
  ```
  """
  @doc since: "1.0.0"
  @spec list_synonyms(map() | Connection.t(), String.t() | module(), keyword()) ::
          {:ok, OpenApiTypesense.SearchSynonymsResponse.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def list_synonyms(conn, module, opts) when is_atom(module) do
    coll_name = module.__schema__(:source)
    list_synonyms(conn, coll_name, opts)
  end

  def list_synonyms(conn, coll_name, opts) do
    OpenApiTypesense.Synonyms.get_search_synonyms(conn, coll_name, opts)
  end

  @doc """
  Retrieve a single synonym from a collection.
  """
  @doc since: "1.0.0"
  @spec get_synonym(String.t() | module(), String.t()) ::
          {:ok, OpenApiTypesense.SearchSynonym.t()} | {:error, OpenApiTypesense.ApiResponse.t()}
  def get_synonym(coll_name, syn_id) do
    get_synonym(coll_name, syn_id, [])
  end

  @doc """
  Same as [get_synonym/2](`get_synonym/2`).

  ```elixir
  ExTypesense.get_synonym("cars", "sedan-synonym", [])
  ExTypesense.get_synonym(%{api_key: xyz, host: ...}, "cars", "sedan-synonym")
  ExTypesense.get_synonym(OpenApiTypesense.Connection.new(), MyApp.Vehicle.Car, "sedan-synonym")
  ```
  """
  @doc since: "1.0.0"
  @spec get_synonym(
          map() | Connection.t() | String.t() | module(),
          String.t(),
          String.t() | keyword()
        ) ::
          {:ok, OpenApiTypesense.SearchSynonym.t()} | {:error, OpenApiTypesense.ApiResponse.t()}
  def get_synonym(coll_name, syn_id, opts) when is_list(opts) do
    Connection.new() |> get_synonym(coll_name, syn_id, opts)
  end

  def get_synonym(conn, coll_name, syn_id) do
    get_synonym(conn, coll_name, syn_id, [])
  end

  @doc """
  Same as [get_synonym/3](`get_synonym/3`) but passes another connection.

  ```elixir
  ExTypesense.get_synonym(%{api_key: xyz, host: ...}, "cars", "sedan-synonym", [])
  ExTypesense.get_synonym(OpenApiTypesense.Connection.new(), MyApp.Vehicle.Car, "sedan-synonym", [])
  ```
  """
  @doc since: "1.0.0"
  @spec get_synonym(map() | Connection.t(), String.t() | module(), String.t(), keyword()) ::
          {:ok, OpenApiTypesense.SearchSynonym.t()} | {:error, OpenApiTypesense.ApiResponse.t()}
  def get_synonym(conn, module, syn_id, opts) when is_atom(module) do
    coll_name = module.__schema__(:source)
    get_synonym(conn, coll_name, syn_id, opts)
  end

  def get_synonym(conn, coll_name, syn_id, opts) do
    OpenApiTypesense.Synonyms.get_search_synonym(conn, coll_name, syn_id, opts)
  end

  @doc """
  Delete a single synonym from a collection.
  """
  @doc since: "1.0.0"
  @spec delete_synonym(String.t() | module(), String.t()) ::
          {:ok, OpenApiTypesense.SearchSynonymDeleteResponse.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def delete_synonym(coll_name, syn_id) do
    delete_synonym(coll_name, syn_id, [])
  end

  @doc """
  Same as [delete_synonym/2](`delete_synonym/2`).

  ```elixir
  ExTypesense.delete_synonym("cars", "sedan-synonym", [])
  ExTypesense.delete_synonym(%{api_key: xyz, host: ...}, "cars", "sedan-synonym")
  ExTypesense.delete_synonym(OpenApiTypesense.Connection.new(), MyApp.Vehicle.Car, "sedan-synonym")
  ```
  """
  @doc since: "1.0.0"
  @spec delete_synonym(
          map() | Connection.t() | String.t() | module(),
          String.t(),
          String.t() | keyword()
        ) ::
          {:ok, OpenApiTypesense.SearchSynonymDeleteResponse.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def delete_synonym(coll_name, syn_id, opts) when is_list(opts) do
    Connection.new() |> delete_synonym(coll_name, syn_id, opts)
  end

  def delete_synonym(conn, coll_name, syn_id) do
    delete_synonym(conn, coll_name, syn_id, [])
  end

  @doc """
  Same as [delete_synonym/3](`delete_synonym/3`) but passes another connection.

  ```elixir
  ExTypesense.delete_synonym(%{api_key: xyz, host: ...}, "cars", "sedan-synonym", [])
  ExTypesense.delete_synonym(OpenApiTypesense.Connection.new(), MyApp.Vehicle.Car, "sedan-synonym", [])
  ```
  """
  @doc since: "1.0.0"
  @spec delete_synonym(map() | Connection.t(), String.t() | module(), String.t(), keyword()) ::
          {:ok, OpenApiTypesense.SearchSynonymDeleteResponse.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def delete_synonym(conn, module, syn_id, opts) when is_atom(module) do
    coll_name = module.__schema__(:source)
    delete_synonym(conn, coll_name, syn_id, opts)
  end

  def delete_synonym(conn, coll_name, syn_id, opts) do
    OpenApiTypesense.Synonyms.delete_search_synonym(conn, coll_name, syn_id, opts)
  end

  @doc """
  Create or update a synonym

  ## Examples
      iex> body = %{
      ...>   "synonyms" => ["blazer", "coat", "jacket"],
      ...> }

      iex> ExTypesense.upsert_synonym("products", "coat-synonyms", body)
  """
  @doc since: "1.0.0"
  @spec upsert_synonym(String.t() | module(), String.t(), map()) ::
          {:ok, OpenApiTypesense.SearchSynonym.t()} | {:error, OpenApiTypesense.ApiResponse.t()}
  def upsert_synonym(coll_name, syn_id, body) do
    Connection.new() |> upsert_synonym(coll_name, syn_id, body)
  end

  @doc """
  Same as [upsert_synonym/3](`upsert_synonym/3`).

  ```elixir
  ExTypesense.upsert_synonym("persons", "coat-synonyms", body, [])
  ExTypesense.upsert_synonym(%{api_key: xyz, host: ...}, "persons", "coat-synonyms", body)
  ExTypesense.upsert_synonym(OpenApiTypesense.Connection.new(), MyApp.Accounts.Person, "coat-synonyms", body)
  ```
  """
  @doc since: "1.0.0"
  @spec upsert_synonym(
          map() | Connection.t() | String.t() | module(),
          String.t() | module(),
          String.t() | map(),
          map() | keyword()
        ) ::
          {:ok, OpenApiTypesense.SearchSynonym.t()} | {:error, OpenApiTypesense.ApiResponse.t()}
  def upsert_synonym(coll_name, syn_id, body, opts) when is_list(opts) do
    Connection.new() |> upsert_synonym(coll_name, syn_id, body, opts)
  end

  def upsert_synonym(conn, coll_name, syn_id, body) do
    upsert_synonym(conn, coll_name, syn_id, body, [])
  end

  @doc """
  Same as [upsert_synonym/4](`upsert_synonym/4`) but passes another connection.

  ```elixir
  ExTypesense.upsert_synonym(%{api_key: xyz, host: ...}, "persons", "coat-synonyms", body, [])
  ExTypesense.upsert_synonym(OpenApiTypesense.Connection.new(), MyApp.Accounts.Person, "coat-synonyms", body, [])
  ```
  """
  @doc since: "1.0.0"
  @spec upsert_synonym(
          map() | Connection.t(),
          String.t() | module(),
          String.t(),
          map(),
          keyword()
        ) ::
          {:ok, OpenApiTypesense.SearchSynonym.t()} | {:error, OpenApiTypesense.ApiResponse.t()}
  def upsert_synonym(conn, module, syn_id, body, opts) when is_atom(module) do
    coll_name = module.__schema__(:source)
    upsert_synonym(conn, coll_name, syn_id, body, opts)
  end

  def upsert_synonym(conn, coll_name, syn_id, body, opts) do
    OpenApiTypesense.Synonyms.upsert_search_synonym(conn, coll_name, syn_id, body, opts)
  end
end
