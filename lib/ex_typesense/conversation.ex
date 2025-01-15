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
  """
  @doc since: "1.0.0"
  @spec create_conversation_model ::
          {:ok, OpenApiTypesense.ConversationModelSchema.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def create_conversation_model do
    nil
  end
end
