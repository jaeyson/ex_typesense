defmodule ExTypesense.Conversation do
  @moduledoc since: "1.0.0"

  @moduledoc """
  Typesense has the ability to respond to free-form questions,
  with conversational responses and also maintain context for
  follow-up questions and answers.

  More here: https://typesense.org/docs/latest/api/conversational-search-rag.html
  """

  @doc """
  Create conversation model.

  Typesense currently supports the following LLM platforms:

  - [OpenAI](https://platform.openai.com/docs/models/models-overview)
  - [Cloudflare Workers AI](https://developers.cloudflare.com/workers-ai/models/#text-generation)
  - [vLLM](https://github.com/vllm-project/vllm)(useful when running local LLMs)

  ## Examples
      iex> body = %{
      ...>   "id" => "conv-model-1",
      ...>   "model_name" => "openai/gpt-3.5-turbo",
      ...>   "history_collection" => "conversation_store",
      ...>   "api_key" => "OPENAI_API_KEY",
      ...>   "system_prompt" => "You are an assistant for question-answering. You can only make conversations based on the provided context. If a response cannot be formed strictly using the provided context, politely say you do not have knowledge about that topic.",
      ...>   "max_bytes" => 16_384
      ...> }
      iex> ExTypesense.create_model(body)
  """
  @doc since: "1.0.0"
  @spec create_model(map()) ::
          {:ok, OpenApiTypesense.ConversationModelSchema.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def create_model(body) do
    create_model(body, [])
  end

  @doc """
  Same as [create_model/1](`create_model/1`)

  ## Options

    * `conn`: The custom connection map or struct you passed

  ## Examples
      iex> conn = %{api_key: xyz, host: ...}
      iex> ExTypesense.create_model(body, conn: conn)

      iex> conn = OpenApiTypesense.Connection.new()
      iex> ExTypesense.create_model(body, conn: conn)

      iex> opts = [conn: conn]
      iex> ExTypesense.create_model(body, opts)
  """
  @doc since: "1.0.0"
  @spec create_model(map(), keyword()) ::
          {:ok, OpenApiTypesense.ConversationModelSchema.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def create_model(body, opts) do
    OpenApiTypesense.Conversations.create_conversation_model(body, opts)
  end

  @doc """
  Retrieve a conversation model
  """
  @doc since: "1.0.0"
  @spec get_model(String.t()) :: {:ok, OpenApiTypesense.ConversationModelSchema.t()} | :error
  def get_model(model_id) do
    get_model(model_id, [])
  end

  @doc """
  Same as [get_model/1](`get_model/1`)

  ## Options

    * `conn`: The custom connection map or struct you passed

  ## Examples
      iex> conn = %{api_key: xyz, host: ...}
      iex> ExTypesense.get_model("conv-model-1", conn: conn)

      iex> conn = OpenApiTypesense.Connection.new()
      iex> ExTypesense.get_model("conv-model-1", conn: conn)

      iex> opts = [conn: conn]
      iex> ExTypesense.get_model("conv-model-1", opts)
  """
  @doc since: "1.0.0"
  @spec get_model(String.t(), keyword()) ::
          {:ok, OpenApiTypesense.ConversationModelSchema.t()} | :error
  def get_model(model_id, opts) do
    OpenApiTypesense.Conversations.retrieve_conversation_model(model_id, opts)
  end

  @doc """
  Update a conversation model

  ## Examples
      iex>model_id = "conv-model-1"
      iex> body = %{
      ...>   "id" => model_id,
      ...>   "model_name" => "openai/gpt-3.5-turbo",
      ...>   "history_collection" => "conversation_store",
      ...>   "api_key" => "OPENAI_API_KEY",
      ...>   "system_prompt" => "Hey, you are an **intelligent** assistant for question-answering. You can only make conversations based on the provided context. If a response cannot be formed strictly using the provided context, politely say you do not have knowledge about that topic.",
      ...>  "max_bytes" => 16_384
      ...> }
      iex> ExTypesense.update_model(model_id, body)
  """
  @doc since: "1.0.0"
  @spec update_model(String.t(), map()) ::
          {:ok, OpenApiTypesense.ConversationModelSchema.t()} | :error
  def update_model(model_id, body) do
    update_model(model_id, body, [])
  end

  @doc """
  Same as [update_model/2](`update_model/2`)

  ## Options

    * `conn`: The custom connection map or struct you passed

  ## Examples
      iex> conn = %{api_key: xyz, host: ...}
      iex> ExTypesense.update_model(model_id, body, conn: conn)

      iex> conn = OpenApiTypesense.Connection.new()
      iex> ExTypesense.update_model(model_id, body, conn: conn)

      iex> opts = [conn: conn]
      iex> ExTypesense.update_model(model_id, body, opts)
  """
  @doc since: "1.0.0"
  @spec update_model(String.t(), map(), keyword()) ::
          {:ok, OpenApiTypesense.ConversationModelSchema.t()} | :error
  def update_model(model_id, body, opts) do
    OpenApiTypesense.Conversations.update_conversation_model(model_id, body, opts)
  end

  @doc """
  Retrieve all conversation models
  """
  @doc since: "1.0.0"
  @spec list_models ::
          {:ok, [OpenApiTypesense.ConversationModelSchema.t()]}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def list_models do
    list_models([])
  end

  @doc """
  Same as [list_models/0](`list_models/0`)

  ## Options

    * `conn`: The custom connection map or struct you passed

  ## Examples
      iex> conn = %{api_key: xyz, host: ...}
      iex> ExTypesense.list_models(conn: conn)

      iex> conn = OpenApiTypesense.Connection.new()
      iex> ExTypesense.list_models(conn: conn)

      iex> opts = [conn: conn]
      iex> ExTypesense.list_models(opts)
  """
  @doc since: "1.0.0"
  @spec list_models(keyword()) ::
          {:ok, [OpenApiTypesense.ConversationModelSchema.t()]}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def list_models(opts) do
    OpenApiTypesense.Conversations.retrieve_all_conversation_models(opts)
  end

  @doc """
  Delete a conversation model
  """
  @doc since: "1.0.0"
  @spec delete_model(String.t()) :: {:ok, OpenApiTypesense.ConversationModelSchema.t()} | :error
  def delete_model(model_id) do
    delete_model(model_id, [])
  end

  @doc """
  Same as [delete_model/1](`delete_model/1`)

  ## Options

    * `conn`: The custom connection map or struct you passed

  ## Examples
      iex> conn = %{api_key: xyz, host: ...}
      iex> ExTypesense.delete_model(model_id, conn: conn)

      iex> conn = OpenApiTypesense.Connection.new()
      iex> ExTypesense.delete_model(model_id, conn: conn)

      iex> opts = [conn: conn]
      iex> ExTypesense.delete_model(model_id, opts)
  """
  @doc since: "1.0.0"
  @spec delete_model(String.t(), keyword()) ::
          {:ok, OpenApiTypesense.ConversationModelSchema.t()} | :error
  def delete_model(model_id, opts) do
    OpenApiTypesense.Conversations.delete_conversation_model(model_id, opts)
  end
end
