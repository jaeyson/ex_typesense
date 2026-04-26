defmodule ExTypesense.NaturalLanguage do
  @moduledoc since: "2.1.0"

  @moduledoc """
  Natural Language Search in Typesense allows you to transform any free-form sentences a user might type into your search bar, into a structured set of search parameters.

  This feature leverages the magic of Large Language Models (LLMs) to interpret user intent and generate appropriate search parameters like filter conditions, sort orders, and query terms that work with Typesense's search syntax.

  More here: https://typesense.org/docs/latest/api/natural-language-search.html
  """

  @doc """
  Create a NL search model

  Create a new NL search model.

  ## Request Body

  **Content Types**: `application/json`

  The NL search model to be created
  """
  @doc since: "2.1.0"
  @spec create_nl_search_model(map() | OpenApiTypesense.NLSearchModelCreateSchema.t()) ::
          {:ok, OpenApiTypesense.NLSearchModelSchema.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def create_nl_search_model(body) do
    create_nl_search_model(body, [])
  end

  @doc """
  Same as [create_nl_search_model/1](`create_nl_search_model/1`)

  ## Options

    * `conn`: The custom connection map or struct you passed

  """
  @doc since: "2.1.0"
  @spec create_nl_search_model(
          map() | OpenApiTypesense.NLSearchModelCreateSchema.t(),
          keyword()
        ) ::
          {:ok, OpenApiTypesense.NLSearchModelSchema.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def create_nl_search_model(body, opts) do
    OpenApiTypesense.NlSearchModels.create_nl_search_model(body, opts)
  end

  @doc """
  Delete a NL search model

  Delete a specific NL search model by its ID.
  """
  @doc since: "2.1.0"
  @spec delete_nl_search_model(String.t()) ::
          {:ok, OpenApiTypesense.NLSearchModelDeleteSchema.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def delete_nl_search_model(model_id) do
    delete_nl_search_model(model_id, [])
  end

  @doc """
  Same as [delete_nl_search_model/1](`delete_nl_search_model/1`)

  ## Options

    * `conn`: The custom connection map or struct you passed

  """
  @doc since: "2.1.0"
  @spec delete_nl_search_model(String.t(), keyword()) ::
          {:ok, OpenApiTypesense.NLSearchModelDeleteSchema.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def delete_nl_search_model(model_id, opts) do
    OpenApiTypesense.NlSearchModels.delete_nl_search_model(model_id, opts)
  end

  @doc """
  List all NL search models

  Retrieve all NL search models.
  """
  @doc since: "2.1.0"
  @spec retrieve_all_nl_search_models ::
          {:ok, [OpenApiTypesense.NLSearchModelSchema.t()]}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def retrieve_all_nl_search_models do
    retrieve_all_nl_search_models([])
  end

  @doc """
  Same as [retrieve_all_nl_search_models/0](`retrieve_all_nl_search_models/0`)

  ## Options

    * `conn`: The custom connection map or struct you passed

  """
  @doc since: "2.1.0"
  @spec retrieve_all_nl_search_models(keyword()) ::
          {:ok, [OpenApiTypesense.NLSearchModelSchema.t()]}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def retrieve_all_nl_search_models(opts) do
    OpenApiTypesense.NlSearchModels.retrieve_all_nl_search_models(opts)
  end

  @doc """
  Retrieve a NL search model

  Retrieve a specific NL search model by its ID.
  """
  @doc since: "2.1.0"
  @spec retrieve_nl_search_model(String.t()) ::
          {:ok, OpenApiTypesense.NLSearchModelSchema.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def retrieve_nl_search_model(model_id) do
    retrieve_nl_search_model(model_id, [])
  end

  @doc """
  Same as [retrieve_nl_search_model/1](`retrieve_nl_search_model/1`)

  ## Options

    * `conn`: The custom connection map or struct you passed

  """
  @doc since: "2.1.0"
  @spec retrieve_nl_search_model(String.t(), keyword()) ::
          {:ok, OpenApiTypesense.NLSearchModelSchema.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def retrieve_nl_search_model(model_id, opts) do
    OpenApiTypesense.NlSearchModels.retrieve_nl_search_model(model_id, opts)
  end

  @doc """
  Update a NL search model

  Update an existing NL search model.

  ## Request Body

  **Content Types**: `application/json`

  The NL search model fields to update
  """
  @doc since: "2.1.0"
  @spec update_nl_search_model(
          String.t(),
          map() | OpenApiTypesense.NLSearchModelCreateSchema.t()
        ) ::
          {:ok, OpenApiTypesense.NLSearchModelSchema.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def update_nl_search_model(model_id, body) do
    update_nl_search_model(model_id, body, [])
  end

  @doc """
  Same as [update_nl_search_model/2](`update_nl_search_model/2`)

  ## Options

    * `conn`: The custom connection map or struct you passed

  """
  @doc since: "2.1.0"
  @spec update_nl_search_model(
          String.t(),
          map() | OpenApiTypesense.NLSearchModelCreateSchema.t(),
          keyword()
        ) ::
          {:ok, OpenApiTypesense.NLSearchModelSchema.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def update_nl_search_model(model_id, body, opts) do
    OpenApiTypesense.NlSearchModels.update_nl_search_model(model_id, body, opts)
  end
end
