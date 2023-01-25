defmodule ExTypesense.HttpClient do
  @moduledoc since: "0.1.0"
  @moduledoc """
  Http client for Typesense server.
  """

  @type request_body() :: iodata() | nil
  @type request_method() :: :get | :post | :delete | :patch | :put
  @type request_path() :: String.t()

  @doc """
  Req client.

  ## Examples
      iex> HttpClient.run(:get, "/collections")
      {:ok,
        [%{
          "created_at" => 123456789,
          "default_sorting_field" => "num_employees",
          "fields" => [...],
          "name" => "companies",
          "num_documents" => 0,
          "symbols_to_index" => [],
          "token_separators" => []
        }]
      }
  """
  @doc since: "0.1.0"
  @spec run(request_method(), request_path(), request_body(), map()) ::
          {:ok, map()} | {:error, map()}
  def run(request_method, request_path, body \\ nil, query \\ %{}) do
    url = %URI{
      scheme: Application.get_env(:ex_typesense, :scheme) || "https",
      host: Application.fetch_env!(:ex_typesense, :host),
      port: Application.get_env(:ex_typesense, :port) || 443,
      path: request_path,
      query: URI.encode_query(query)
    }

    response =
      %Req.Request{
        body: body,
        method: request_method,
        url: url
      }
      |> Req.Request.put_header(
        "X-TYPESENSE-API-KEY",
        Application.fetch_env!(:ex_typesense, :api_key)
      )
      |> Req.Request.append_error_steps(retry: &Req.Steps.retry/1)
      |> Req.Steps.encode_body()
      |> Req.Request.run!()

    case response.status in 200..299 do
      true ->
        {:ok, Jason.decode!(response.body)}

      false ->
        {:error, Jason.decode!(response.body)["message"]}
    end
  end

  def get_host, do: Application.get_env(:ex_typesense, :host)
  def get_port, do: Application.get_env(:ex_typesense, :port)
  def get_scheme, do: Application.get_env(:ex_typesense, :scheme)
  def api_key, do: Application.get_env(:ex_typesense, :api_key)
end
