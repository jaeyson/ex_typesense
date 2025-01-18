defmodule ExTypesense.Conversation do
  @moduledoc since: "1.0.0"

  @moduledoc """
  Typesense has the ability to respond to free-form questions,
  with conversational responses and also maintain context for
  follow-up questions and answers.

  More here: https://typesense.org/docs/latest/api/conversational-search-rag.html
  """

  alias OpenApiTypesense.Connection

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

  ```elixir
  ExTypesense.create_model(body, [])

  ExTypesense.create_model(%{api_key: xyz, host: ...}, body)

  ExTypesense.create_model(OpenApiTypesense.Connection.new(), body)
  ```
  """
  @doc since: "1.0.0"
  @spec create_model(map() | Connection.t(), map() | keyword()) ::
          {:ok, OpenApiTypesense.ConversationModelSchema.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def create_model(body, opts) when is_list(opts) do
    Connection.new() |> create_model(body, opts)
  end

  def create_model(conn, body) do
    create_model(conn, body, [])
  end

  @doc """
  Same as [create_model/2](`create_model/2`) but passes another connection.

  ```elixir
  ExTypesense.create_model(%{api_key: xyz, host: ...}, body, [])

  ExTypesense.create_model(OpenApiTypesense.Connection.new(), body, [])
  ```
  """
  @doc since: "1.0.0"
  @spec create_model(map() | Connection.t(), map() | keyword()) ::
          {:ok, OpenApiTypesense.ConversationModelSchema.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def create_model(conn, body, opts) do
    OpenApiTypesense.Conversations.create_conversation_model(conn, body, opts)
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

  ```elixir
  ExTypesense.get_model("conv-model-1", [])

  ExTypesense.get_model(%{api_key: xyz, host: ...}, "conv-model-1")

  ExTypesense.get_model(OpenApiTypesense.Connection.new(), "conv-model-1")
  ```
  """
  @doc since: "1.0.0"
  @spec get_model(map() | Connection.t() | String.t(), String.t() | keyword()) ::
          {:ok, OpenApiTypesense.ConversationModelSchema.t()} | :error
  def get_model(model_id, opts) when is_list(opts) do
    Connection.new() |> get_model(model_id, opts)
  end

  def get_model(conn, model_id) do
    get_model(conn, model_id, [])
  end

  @doc """
  Same as [get_model/2](`get_model/2`) but passes another connection.

  ```elixir
  ExTypesense.get_model(%{api_key: xyz, host: ...}, "conv-model-1", [])

  ExTypesense.get_model(OpenApiTypesense.Connection.new(), "conv-model-1", [])
  ```
  """
  @doc since: "1.0.0"
  @spec get_model(map() | ConnString.t(), String.t(), keyword()) ::
          {:ok, OpenApiTypesense.ConversationModelSchema.t()} | :error
  def get_model(conn, model_id, opts) do
    OpenApiTypesense.Conversations.retrieve_conversation_model(conn, model_id, opts)
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

  ```elixir
  ExTypesense.update_model(model_id, body, [])

  ExTypesense.update_model(%{api_key: xyz, host: ...}, model_id, body)

  ExTypesense.update_model(OpenApiTypesense.Connection.new(), model_id, body)
  ```
  """
  @doc since: "1.0.0"
  @spec update_model(
          map() | Connection.t() | String.t(),
          String.t() | map(),
          map() | keyword()
        ) ::
          {:ok, OpenApiTypesense.ConversationModelSchema.t()} | :error
  def update_model(model_id, body, opts) when is_list(opts) do
    Connection.new() |> update_model(model_id, body, opts)
  end

  def update_model(conn, model_id, body) do
    update_model(conn, model_id, body, [])
  end

  @doc """
  Same as [update_model/3](`update_model/3`) but passes another connection.

  ```elixir
  ExTypesense.update_model(%{api_key: xyz, host: ...}, model_id, body, [])

  ExTypesense.update_model(OpenApiTypesense.Connection.new(), model_id, body, [])
  ```
  """
  @doc since: "1.0.0"
  @spec update_model(map() | Connection.t(), String.t(), map(), keyword()) ::
          {:ok, OpenApiTypesense.ConversationModelSchema.t()} | :error
  def update_model(conn, model_id, body, opts) do
    OpenApiTypesense.Conversations.update_conversation_model(conn, model_id, body, opts)
  end

  @doc """
  Retrieve all conversation models
  """
  @doc since: "1.0.0"
  @spec list_models ::
          {:ok, [OpenApiTypesense.ConversationModelSchema.t()]} | :error
  def list_models do
    list_models([])
  end

  @doc """
  Same as [list_models/0](`list_models/0`)

  ```elixir
  ExTypesense.list_models([])

  ExTypesense.list_models(%{api_key: xyz, host: ...})

  ExTypesense.list_models(OpenApiTypesense.Connection.new())
  ```
  """
  @doc since: "1.0.0"
  @spec list_models(map() | Connection.t() | keyword()) ::
          {:ok, OpenApiTypesense.ConversationModelSchema.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def list_models(opts) when is_list(opts) do
    Connection.new() |> list_models(opts)
  end

  def list_models(conn) do
    list_models(conn, [])
  end

  @doc """
  Same as [list_models/1](`list_models/1`) but passes another connection.

  ```elixir
  ExTypesense.list_models(%{api_key: xyz, host: ...}, [])

  ExTypesense.list_models(OpenApiTypesense.Connection.new(), [])
  ```
  """
  @doc since: "1.0.0"
  @spec list_models(map() | Connection.t(), keyword()) ::
          {:ok, OpenApiTypesense.ConversationModelSchema.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def list_models(conn, opts) do
    OpenApiTypesense.Conversations.retrieve_all_conversation_models(conn, opts)
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

  ```elixir
  ExTypesense.delete_model(model_id, [])

  ExTypesense.delete_model(%{api_key: xyz, host: ...}, model_id)

  ExTypesense.delete_model(OpenApiTypesense.Connection.new(), model_id)
  ```
  """
  @doc since: "1.0.0"
  @spec delete_model(map() | Connection.t() | String.t(), String.t() | keyword()) ::
          {:ok, OpenApiTypesense.ConversationModelSchema.t()} | :error
  def delete_model(model_id, opts) when is_list(opts) do
    Connection.new() |> delete_model(model_id, opts)
  end

  def delete_model(conn, model_id) do
    delete_model(conn, model_id, [])
  end

  @doc """
  Same as [delete_model/2](`delete_model/2`) but passes another connection.

  ```elixir
  ExTypesense.delete_model(%{api_key: xyz, host: ...}, model_id, [])

  ExTypesense.delete_model(OpenApiTypesense.Connection.new(), model_id, [])
  ```
  """
  @doc since: "1.0.0"
  @spec delete_model(map() | Connection.t(), String.t(), keyword()) ::
          {:ok, OpenApiTypesense.ConversationModelSchema.t()} | :error
  def delete_model(conn, model_id, opts) do
    OpenApiTypesense.Conversations.delete_conversation_model(conn, model_id, opts)
  end
end
