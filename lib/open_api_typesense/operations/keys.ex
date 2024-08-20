defmodule OpenApiTypesense.Keys do
  @moduledoc """
  Provides API endpoints related to keys
  """

  @default_client OpenApiTypesense.Client

  @doc """
  Create an API Key

  Create an API Key with fine-grain access control. You can restrict access on both a per-collection and per-action level. The generated key is returned only during creation. You want to store this key carefully in a secure place.
  """
  @spec create_key(OpenApiTypesense.ApiKeySchema.t(), keyword) ::
          {:ok, OpenApiTypesense.ApiKey.t()} | {:error, OpenApiTypesense.ApiResponse.t()}
  def create_key(body, opts \\ []) do
    client = opts[:client] || @default_client

    client.request(%{
      args: [body: body],
      call: {OpenApiTypesense.Keys, :create_key},
      url: "/keys",
      body: body,
      method: :post,
      request: [{"application/json", {OpenApiTypesense.ApiKeySchema, :t}}],
      response: [
        {201, {OpenApiTypesense.ApiKey, :t}},
        {400, {OpenApiTypesense.ApiResponse, :t}},
        {409, {OpenApiTypesense.ApiResponse, :t}}
      ],
      opts: opts
    })
  end

  @doc """
  Delete an API key given its ID.
  """
  @spec delete_key(integer, keyword) ::
          {:ok, OpenApiTypesense.ApiKey.t()} | {:error, OpenApiTypesense.ApiResponse.t()}
  def delete_key(keyId, opts \\ []) do
    client = opts[:client] || @default_client

    client.request(%{
      args: [keyId: keyId],
      call: {OpenApiTypesense.Keys, :delete_key},
      url: "/keys/#{keyId}",
      method: :delete,
      response: [
        {200, {OpenApiTypesense.ApiKey, :t}},
        {400, {OpenApiTypesense.ApiResponse, :t}},
        {404, {OpenApiTypesense.ApiResponse, :t}}
      ],
      opts: opts
    })
  end

  @doc """
  Retrieve (metadata about) a key

  Retrieve (metadata about) a key. Only the key prefix is returned when you retrieve a key. Due to security reasons, only the create endpoint returns the full API key.
  """
  @spec get_key(integer, keyword) ::
          {:ok, OpenApiTypesense.ApiKey.t()} | {:error, OpenApiTypesense.ApiResponse.t()}
  def get_key(keyId, opts \\ []) do
    client = opts[:client] || @default_client

    client.request(%{
      args: [keyId: keyId],
      call: {OpenApiTypesense.Keys, :get_key},
      url: "/keys/#{keyId}",
      method: :get,
      response: [{200, {OpenApiTypesense.ApiKey, :t}}, {404, {OpenApiTypesense.ApiResponse, :t}}],
      opts: opts
    })
  end

  @doc """
  Retrieve (metadata about) all keys.
  """
  @spec get_keys(keyword) :: {:ok, OpenApiTypesense.ApiKeysResponse.t()} | :error
  def get_keys(opts \\ []) do
    client = opts[:client] || @default_client

    client.request(%{
      args: [],
      call: {OpenApiTypesense.Keys, :get_keys},
      url: "/keys",
      method: :get,
      response: [{200, {OpenApiTypesense.ApiKeysResponse, :t}}],
      opts: opts
    })
  end
end
