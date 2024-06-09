defmodule ExTypesense.HttpClient do
  @moduledoc since: "0.1.0"
  @moduledoc """
  Http client for Typesense server.
  """

  @type request_body() :: iodata() | nil
  @type request_method() :: :get | :post | :delete | :patch | :put
  @type request_path() :: String.t()
  @api_header_name ~c"X-TYPESENSE-API-KEY"

  def get_host, do: Application.get_env(:ex_typesense, :host)
  def get_port, do: Application.get_env(:ex_typesense, :port)
  def get_scheme, do: Application.get_env(:ex_typesense, :scheme)
  def api_key, do: Application.get_env(:ex_typesense, :api_key)

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
      scheme: get_scheme() || "https",
      host: get_host(),
      port: get_port() || 443,
      path: request_path,
      query: URI.encode_query(query)
    }

    response =
      %Req.Request{
        body: body,
        method: request_method,
        url: url
      }
      |> Req.Request.put_header("X-TYPESENSE-API-KEY", api_key())
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

  @spec httpc_run(URI.__struct__(), atom(), String.t(), list()) :: {:ok, map()} | {:error, map()}
  def httpc_run(uri, method, payload, content_type \\ ~c"application/json") do
    uri = %URI{
      scheme: get_scheme(),
      host: get_host(),
      port: get_port(),
      path: uri.path,
      query: uri.query
    }

    api_key = String.to_charlist(api_key())

    headers = [{@api_header_name, api_key}]

    request = {
      URI.to_string(uri),
      headers,
      content_type,
      payload
    }

    :ok = :ssl.start()

    http_opts = [
      ssl: [
        {:versions, [:"tlsv1.2"]},
        verify: :verify_peer,
        cacerts: :public_key.cacerts_get(),
        customize_hostname_check: [
          match_fun: :public_key.pkix_verify_hostname_match_fun(:https)
        ]
      ],
      timeout: 3_600,
      connect_timeout: 3_600
    ]

    case :httpc.request(method, request, http_opts, []) do
      {:ok, {_status_code, _headers, message}} ->
        case Jason.decode(message) do
          {:ok, message} ->
            {:ok, message}

          {:error, %Jason.DecodeError{data: data}} ->
            message =
              data
              |> String.split("\n", trim: true)
              |> Stream.map(&Jason.decode!/1)
              |> Enum.to_list()

            {:ok, message}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end
end
