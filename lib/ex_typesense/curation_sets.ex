defmodule ExTypesense.CurationSets do
  @moduledoc since: "2.2.0"

  @moduledoc """
  Provides API endpoints related to curation sets
  """

  @doc """
  Delete a curation set

  Delete a specific curation set by its name
  """
  @doc since: "2.2.0"
  @spec delete_curation_set(curation_set_name :: String.t()) ::
          {:ok, OpenApiTypesense.CurationSetDeleteSchema.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def delete_curation_set(curation_set_name) do
    delete_curation_set(curation_set_name, [])
  end

  @doc """
  Same as [delete_curation_set/1](`delete_curation_set/1`)

  ## Options

    * `conn`: The custom connection map or struct you passed

  """
  @doc since: "2.2.0"
  @spec delete_curation_set(curation_set_name :: String.t(), opts :: keyword) ::
          {:ok, OpenApiTypesense.CurationSetDeleteSchema.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def delete_curation_set(curation_set_name, opts) do
    OpenApiTypesense.CurationSets.delete_curation_set(curation_set_name, opts)
  end

  @doc """
  Delete a curation set item

  Delete a specific curation item by its id
  """
  @doc since: "2.2.0"
  @spec delete_curation_set_item(
          curation_set_name :: String.t(),
          item_id :: String.t()
        ) ::
          {:ok, OpenApiTypesense.CurationItemDeleteSchema.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def delete_curation_set_item(curation_set_name, item_id) do
    delete_curation_set_item(curation_set_name, item_id, [])
  end

  @doc """
  Same as [delete_curation_set_item/2](`delete_curation_set_item/2`)

  ## Options

    * `conn`: The custom connection map or struct you passed

  """
  @doc since: "2.2.0"
  @spec delete_curation_set_item(
          curation_set_name :: String.t(),
          item_id :: String.t(),
          opts :: keyword
        ) ::
          {:ok, OpenApiTypesense.CurationItemDeleteSchema.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def delete_curation_set_item(curation_set_name, item_id, opts) do
    OpenApiTypesense.CurationSets.delete_curation_set_item(curation_set_name, item_id, opts)
  end

  @doc """
  Retrieve a curation set

  Retrieve a specific curation set by its name
  """
  @doc since: "2.2.0"
  @spec retrieve_curation_set(curation_set_name :: String.t()) ::
          {:ok, OpenApiTypesense.CurationSetSchema.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def retrieve_curation_set(curation_set_name) do
    retrieve_curation_set(curation_set_name, [])
  end

  @doc """
  Same as [retrieve_curation_set/1](`retrieve_curation_set/1`)

  ## Options

    * `conn`: The custom connection map or struct you passed

  """
  @doc since: "2.2.0"
  @spec retrieve_curation_set(curation_set_name :: String.t(), opts :: keyword) ::
          {:ok, OpenApiTypesense.CurationSetSchema.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def retrieve_curation_set(curation_set_name, opts) do
    OpenApiTypesense.CurationSets.retrieve_curation_set(curation_set_name, opts)
  end

  @doc """
  Retrieve a curation set item

  Retrieve a specific curation item by its id
  """
  @doc since: "2.2.0"
  @spec retrieve_curation_set_item(
          curation_set_name :: String.t(),
          item_id :: String.t()
        ) ::
          {:ok, OpenApiTypesense.CurationItemSchema.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def retrieve_curation_set_item(curation_set_name, item_id) do
    retrieve_curation_set_item(curation_set_name, item_id, [])
  end

  @doc """
  Same as [retrieve_curation_set_item/2](`retrieve_curation_set_item/2`)

  ## Options

    * `conn`: The custom connection map or struct you passed

  """
  @doc since: "2.2.0"
  @spec retrieve_curation_set_item(
          curation_set_name :: String.t(),
          item_id :: String.t(),
          opts :: keyword
        ) ::
          {:ok, OpenApiTypesense.CurationItemSchema.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def retrieve_curation_set_item(curation_set_name, item_id, opts) do
    OpenApiTypesense.CurationSets.retrieve_curation_set_item(curation_set_name, item_id, opts)
  end

  @doc """
  List items in a curation set

  Retrieve all curation items in a set
  """
  @doc since: "2.2.0"
  @spec retrieve_curation_set_items(curation_set_name :: String.t()) ::
          {:ok, [OpenApiTypesense.CurationItemSchema.t()]}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def retrieve_curation_set_items(curation_set_name) do
    retrieve_curation_set_items(curation_set_name, [])
  end

  @doc """
  Same as [retrieve_curation_set_items/1](`retrieve_curation_set_items/1`)

  ## Options

    * `conn`: The custom connection map or struct you passed

  """
  @doc since: "2.2.0"
  @spec retrieve_curation_set_items(curation_set_name :: String.t(), opts :: keyword) ::
          {:ok, [OpenApiTypesense.CurationItemSchema.t()]}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def retrieve_curation_set_items(curation_set_name, opts) do
    OpenApiTypesense.CurationSets.retrieve_curation_set_items(curation_set_name, opts)
  end

  @doc """
  List all curation sets

  Retrieve all curation sets
  """
  @doc since: "2.2.0"
  @spec retrieve_curation_sets ::
          {:ok, [OpenApiTypesense.CurationSetSchema.t()]} | :error
  def retrieve_curation_sets do
    retrieve_curation_sets([])
  end

  @doc """
  Same as [retrieve_curation_sets/0](`retrieve_curation_sets/0`)

  ## Options

    * `conn`: The custom connection map or struct you passed

  """
  @doc since: "2.2.0"
  @spec retrieve_curation_sets(opts :: keyword) ::
          {:ok, [OpenApiTypesense.CurationSetSchema.t()]} | :error
  def retrieve_curation_sets(opts) do
    OpenApiTypesense.CurationSets.retrieve_curation_sets(opts)
  end

  @doc """
  Create or update a curation set

  Create or update a curation set with the given name

  ## Request Body

  **Content Types**: `application/json`

  The curation set to be created/updated
  """
  @doc since: "2.2.0"
  @spec upsert_curation_set(
          curation_set_name :: String.t(),
          body :: OpenApiTypesense.CurationSetCreateSchema.t()
        ) ::
          {:ok, OpenApiTypesense.CurationSetSchema.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def upsert_curation_set(curation_set_name, body) do
    upsert_curation_set(curation_set_name, body, [])
  end

  @doc """
  Same as [upsert_curation_set/2](`upsert_curation_set/2`)

  ## Options

    * `conn`: The custom connection map or struct you passed

  """
  @doc since: "2.2.0"
  @spec upsert_curation_set(
          curation_set_name :: String.t(),
          body :: OpenApiTypesense.CurationSetCreateSchema.t(),
          opts :: keyword
        ) ::
          {:ok, OpenApiTypesense.CurationSetSchema.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def upsert_curation_set(curation_set_name, body, opts) do
    OpenApiTypesense.CurationSets.upsert_curation_set(curation_set_name, body, opts)
  end

  @doc """
  Create or update a curation set item

  Create or update a curation set item with the given id

  ## Request Body

  **Content Types**: `application/json`

  The curation item to be created/updated
  """
  @doc since: "2.2.0"
  @spec upsert_curation_set_item(
          curation_set_name :: String.t(),
          item_id :: String.t(),
          body :: OpenApiTypesense.CurationItemCreateSchema.t()
        ) ::
          {:ok, OpenApiTypesense.CurationItemSchema.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def upsert_curation_set_item(curation_set_name, item_id, body) do
    upsert_curation_set_item(curation_set_name, item_id, body, [])
  end

  @doc """
  Same as [upsert_curation_set_item/3](`upsert_curation_set_item/3`)

  ## Options

    * `conn`: The custom connection map or struct you passed

  """
  @doc since: "2.2.0"
  @spec upsert_curation_set_item(
          curation_set_name :: String.t(),
          item_id :: String.t(),
          body :: OpenApiTypesense.CurationItemCreateSchema.t(),
          opts :: keyword
        ) ::
          {:ok, OpenApiTypesense.CurationItemSchema.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def upsert_curation_set_item(curation_set_name, item_id, body, opts) do
    OpenApiTypesense.CurationSets.upsert_curation_set_item(curation_set_name, item_id, body, opts)
  end
end
