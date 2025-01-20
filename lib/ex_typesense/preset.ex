defmodule ExTypesense.Preset do
  @moduledoc since: "1.0.0"

  @moduledoc """
  Search presets allow you to store a bunch of search parameters
  together, and reference them by a name. You can then use this
  preset name when you make a search request, instead of passing
  all the search parameters individually in each search request.

  You can then change the preset configuration on the Typesense
  side, to change your search parameters, without having to
  re-deploy your application.

  More here: https://typesense.org/docs/latest/api/search.html#presets
  """

  alias OpenApiTypesense.Connection

  @doc """
  Retrieves all presets.
  """
  @doc since: "1.0.0"
  @spec get_preset(String.t()) ::
          {:ok, OpenApiTypesense.PresetSchema.t()} | {:error, OpenApiTypesense.ApiResponse.t()}
  def get_preset(preset_id) do
    get_preset(preset_id, [])
  end

  @doc """
  Same as [get_preset/1](`get_preset/1`)

  ```elixir
  ExTypesense.get_preset("listing_view", [])
  ExTypesense.get_preset(%{api_key: xyz, host: ...}, "listing_view")
  ExTypesense.get_preset(OpenApiTypesense.Connection.new(), "listing_view")
  ```
  """
  @doc since: "1.0.0"
  @spec get_preset(map() | Connection.t() | String.t(), String.t() | keyword()) ::
          {:ok, OpenApiTypesense.PresetSchema.t()} | {:error, OpenApiTypesense.ApiResponse.t()}
  def get_preset(preset_id, opts) when is_list(opts) do
    Connection.new() |> get_preset(preset_id, opts)
  end

  def get_preset(conn, preset_id) do
    get_preset(conn, preset_id, [])
  end

  @doc """
  Same as [get_preset/2](`get_preset/2`) but passes another connection.

  ```elixir
  ExTypesense.get_preset(%{api_key: xyz, host: ...}, "listing_view", [])
  ExTypesense.get_preset(OpenApiTypesense.Connection.new(), "listing_view", [])
  ```
  """
  @doc since: "1.0.0"
  @spec get_preset(map() | Connection.t(), String.t(), keyword()) ::
          {:ok, OpenApiTypesense.PresetSchema.t()} | {:error, OpenApiTypesense.ApiResponse.t()}
  def get_preset(conn, preset_id, opts) do
    OpenApiTypesense.Presets.retrieve_preset(conn, preset_id, opts)
  end

  @doc """
  Create or update an existing preset.

  ## Examples
      iex> body = %{
      ...>   "value" => %{
      ...>     "searches" => [
      ...>       %{"collection" => "restaurants", "q" => "*", "sort_by" => "popularity"}
      ...>     ]
      ...>   }
      ...> }
      iex> ExTypesense.upsert_preset("listing_view", body)
  """
  @doc since: "1.0.0"
  @spec upsert_preset(String.t(), map()) ::
          {:ok, OpenApiTypesense.PresetSchema.t()} | {:error, OpenApiTypesense.ApiResponse.t()}
  def upsert_preset(preset_id, body) do
    upsert_preset(preset_id, body, [])
  end

  @doc """
  Same as [upsert_preset/2](`upsert_preset/2`)

  ```elixir
  ExTypesense.upsert_preset("listing_view", body, [])
  ExTypesense.upsert_preset(%{api_key: xyz, host: ...}, "listing_view", body)
  ExTypesense.upsert_preset(OpenApiTypesense.Connection.new(), "listing_view", body)
  ```
  """
  @doc since: "1.0.0"
  @spec upsert_preset(
          map() | Connection.t() | String.t(),
          String.t() | map(),
          map() | keyword()
        ) ::
          {:ok, OpenApiTypesense.PresetSchema.t()} | {:error, OpenApiTypesense.ApiResponse.t()}
  def upsert_preset(preset_id, body, opts) when is_list(opts) do
    Connection.new() |> upsert_preset(preset_id, body, opts)
  end

  def upsert_preset(conn, preset_id, body) do
    upsert_preset(conn, preset_id, body, [])
  end

  @doc """
  Same as [upsert_preset/3](`upsert_preset/3`) but passes another connection.

  ```elixir
  ExTypesense.upsert_preset(%{api_key: xyz, host: ...}, "listing_view", body, [])
  ExTypesense.upsert_preset(OpenApiTypesense.Connection.new(), "listing_view", body, [])
  ```
  """
  @doc since: "1.0.0"
  @spec upsert_preset(map() | Connection.t(), String.t(), map(), keyword()) ::
          {:ok, OpenApiTypesense.PresetSchema.t()} | {:error, OpenApiTypesense.ApiResponse.t()}
  def upsert_preset(conn, preset_id, body, opts) do
    OpenApiTypesense.Presets.upsert_preset(conn, preset_id, body, opts)
  end

  @doc """
  Permanently deletes a preset, given it's name.
  """
  @doc since: "1.0.0"
  @spec delete_preset(String.t()) ::
          {:ok, OpenApiTypesense.PresetDeleteSchema.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def delete_preset(preset_id) do
    delete_preset(preset_id, [])
  end

  @doc """
  Same as [delete_preset/1](`delete_preset/1`)

  ```elixir
  ExTypesense.delete_preset("listing_view", [])
  ExTypesense.delete_preset(%{api_key: xyz, host: ...}, "listing_view")
  ExTypesense.delete_preset(OpenApiTypesense.Connection.new(), "listing_view")
  ```
  """
  @doc since: "1.0.0"
  @spec delete_preset(map() | Connection.t() | String.t(), String.t() | keyword()) ::
          {:ok, OpenApiTypesense.PresetDeleteSchema.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def delete_preset(preset_id, opts) when is_list(opts) do
    Connection.new() |> delete_preset(preset_id, opts)
  end

  def delete_preset(conn, preset_id) do
    delete_preset(conn, preset_id, [])
  end

  @doc """
  Same as [delete_preset/2](`delete_preset/2`) but passes another connection.

  ```elixir
  ExTypesense.delete_preset(%{api_key: xyz, host: ...}, "listing_view", [])
  ExTypesense.delete_preset(OpenApiTypesense.Connection.new(), "listing_view", [])
  ```
  """
  @doc since: "1.0.0"
  @spec delete_preset(map() | Connection.t(), String.t(), keyword()) ::
          {:ok, OpenApiTypesense.PresetDeleteSchema.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def delete_preset(conn, preset_id, opts) do
    OpenApiTypesense.Presets.delete_preset(conn, preset_id, opts)
  end

  @doc """
  Retrieves all presets.
  """
  @doc since: "1.0.0"
  @spec list_presets :: {:ok, OpenApiTypesense.PresetsRetrieveSchema.t()} | :error
  def list_presets do
    list_presets([])
  end

  @doc """
  Same as [list_presets/0](`list_presets/0`)

  ```elixir
  ExTypesense.list_presets([])
  ExTypesense.list_presets(%{api_key: xyz, host: ...})
  ExTypesense.list_presets(OpenApiTypesense.Connection.new())
  ```
  """
  @doc since: "1.0.0"
  @spec list_presets(map() | Connection.t() | keyword()) ::
          {:ok, OpenApiTypesense.PresetsRetrieveSchema.t()} | :error
  def list_presets(opts) when is_list(opts) do
    Connection.new() |> list_presets(opts)
  end

  def list_presets(conn) do
    list_presets(conn, [])
  end

  @doc """
  Same as [list_presets/1](`list_presets/1`) but passes another connection.

  ```elixir
  ExTypesense.list_presets(%{api_key: xyz, host: ...}, [])
  ExTypesense.list_presets(OpenApiTypesense.Connection.new(), [])
  ```
  """
  @doc since: "1.0.0"
  @spec list_presets(map() | Connection.t(), keyword()) ::
          {:ok, OpenApiTypesense.PresetsRetrieveSchema.t()} | :error
  def list_presets(conn, opts) do
    OpenApiTypesense.Presets.retrieve_all_presets(conn, opts)
  end
end
