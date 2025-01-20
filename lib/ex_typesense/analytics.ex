defmodule ExTypesense.Analytics do
  @moduledoc since: "0.3.0"

  @moduledoc """
  Typesense can aggregate search queries for both analytics
  purposes and for query suggestions.

  More here: https://typesense.org/docs/latest/api/analytics-query-suggestions.html
  """

  alias OpenApiTypesense.Connection

  @doc """
  Creates an analytics rule

  When an analytics rule is created, we give it a name and
  describe the type, the source collections and the
  destination collection.

  ## Examples
      iex> body = %{
      ...>   "name" => name,
      ...>   "type" => "counter",
      ...>   "params" => %{
      ...>     "source" => %{
      ...>       "collections" => ["products"],
      ...>       "events" => [
      ...>         %{"type" => "click", "weight" => 1, "name" => event_name}
      ...>       ]
      ...>     },
      ...>     "destination" => %{
      ...>       "collection" => "products",
      ...>       "counter_field" => "popularity"
      ...>     }
      ...>   }
      ...> }

      iex> ExTypesense.create_analytics_rule(body)
  """
  @doc since: "1.0.0"
  @spec create_analytics_rule(map()) ::
          {:ok, OpenApiTypesense.AnalyticsRuleSchema.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def create_analytics_rule(body) do
    create_analytics_rule(body, [])
  end

  @doc """
  Same as [create_analytics_rule/1](`create_analytics_rule/1`)

  ```elixir
  ExTypesense.create_analytics_rule(body, [])

  ExTypesense.create_analytics_rule(%{api_key: xyz, host: ...}, body)

  ExTypesense.create_analytics_rule(OpenApiTypesense.Connection.new(), body)
  ```
  """
  @doc since: "1.0.0"
  @spec create_analytics_rule(map() | Connection.t(), map() | keyword()) ::
          {:ok, OpenApiTypesense.AnalyticsRuleSchema.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def create_analytics_rule(body, opts) when is_list(opts) do
    Connection.new() |> create_analytics_rule(body, opts)
  end

  def create_analytics_rule(conn, body) do
    create_analytics_rule(conn, body, [])
  end

  @doc """
  Same as [create_analytics_rule/2](`create_analytics_rule/2`) but passes another connection.

  ```elixir
  ExTypesense.create_analytics_rule(%{api_key: xyz, host: ...}, body, [])

  ExTypesense.create_analytics_rule(OpenApiTypesense.Connection.new(), body, [])
  ```
  """
  @doc since: "1.0.0"
  @spec create_analytics_rule(map() | Connection.t(), map(), keyword()) ::
          {:ok, OpenApiTypesense.AnalyticsRuleSchema.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def create_analytics_rule(conn, body, opts) do
    OpenApiTypesense.Analytics.create_analytics_rule(conn, body, opts)
  end

  @doc """
  Create an analytics event

  Sending events for analytics e.g rank search results based on popularity.

  ## Examples
      iex> body =
      ...>   %{
      ...>     "name" => event_name,
      ...>     "type" => "click",
      ...>     "data" => %{
      ...>       "q" => "nike_shoes",
      ...>       "doc_id" => "2468",
      ...>       "user_id" => "9903"
      ...>     }
      ...>   }
      iex> ExTypesense.create_analytics_event(body)
  """
  @doc since: "1.0.0"
  @spec create_analytics_event(map()) ::
          {:ok, OpenApiTypesense.AnalyticsEventCreateResponse.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def create_analytics_event(body) do
    create_analytics_event(body, [])
  end

  @doc """
  Same as [create_analytics_event/1](`create_analytics_event/1`)

  ```elixir
  ExTypesense.create_analytics_event(body, [])

  ExTypesense.create_analytics_event(%{api_key: xyz, host: ...}, body)

  ExTypesense.create_analytics_event(OpenApiTypesense.Connection.new(), body)
  ```
  """
  @doc since: "1.0.0"
  @spec create_analytics_event(map() | Connection.t(), map() | keyword()) ::
          {:ok, OpenApiTypesense.AnalyticsEventCreateResponse.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def create_analytics_event(body, opts) when is_list(opts) do
    Connection.new() |> create_analytics_event(body, opts)
  end

  def create_analytics_event(conn, body) do
    create_analytics_event(conn, body, [])
  end

  @doc """
  Same as [create_analytics_event/2](`create_analytics_event/2`) but passes another connection.

  ```elixir
  ExTypesense.create_analytics_event(%{api_key: xyz, host: ...}, body, [])

  ExTypesense.create_analytics_event(OpenApiTypesense.Connection.new(), body, [])
  ```
  """
  @doc since: "1.0.0"
  @spec create_analytics_event(map() | Connection.t(), map(), keyword()) ::
          {:ok, OpenApiTypesense.AnalyticsEventCreateResponse.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def create_analytics_event(conn, body, opts) do
    OpenApiTypesense.Analytics.create_analytics_event(conn, body, opts)
  end

  @doc """
  Retrieve the details of all analytics rules
  """
  @doc since: "1.0.0"
  @spec list_analytics_rules :: {:ok, OpenApiTypesense.AnalyticsRulesRetrieveSchema.t()} | :error
  def list_analytics_rules do
    list_analytics_rules([])
  end

  @doc """
  Same as [list_analytics_rules/0](`list_analytics_rules/0`)

  ```elixir
  ExTypesense.list_analytics_rules([])

  ExTypesense.list_analytics_rules(%{api_key: xyz, host: ...})

  ExTypesense.list_analytics_rules(OpenApiTypesense.Connection.new())
  ```
  """
  @doc since: "1.0.0"
  @spec list_analytics_rules(map() | Connection.t() | keyword()) ::
          {:ok, OpenApiTypesense.AnalyticsRulesRetrieveSchema.t()} | :error
  def list_analytics_rules(opts) when is_list(opts) do
    Connection.new() |> list_analytics_rules(opts)
  end

  def list_analytics_rules(conn) do
    list_analytics_rules(conn, [])
  end

  @doc """
  Same as [list_analytics_rules/1](`list_analytics_rules/1`) but passes another connection.

  ```elixir
  ExTypesense.list_analytics_rules(%{api_key: xyz, host: ...}, [])

  ExTypesense.list_analytics_rules(OpenApiTypesense.Connection.new(), [])
  ```
  """
  @doc since: "1.0.0"
  @spec list_analytics_rules(map() | Connection.t(), keyword()) ::
          {:ok, OpenApiTypesense.AnalyticsRulesRetrieveSchema.t()} | :error
  def list_analytics_rules(conn, opts) do
    OpenApiTypesense.Analytics.retrieve_analytics_rules(conn, opts)
  end

  @doc """
  Retrieve the details of an analytics rule, given it's name
  """
  @doc since: "1.0.0"
  @spec get_analytics_rule(String.t()) ::
          {:ok, OpenApiTypesense.AnalyticsRuleSchema.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def get_analytics_rule(rule_name) do
    get_analytics_rule(rule_name, [])
  end

  @doc """
  Same as [get_analytics_rule/1](`get_analytics_rule/1`)

  ```elixir
  ExTypesense.get_analytics_rule(rule_name, [])

  ExTypesense.get_analytics_rule(%{api_key: xyz, host: ...}, rule_name)

  ExTypesense.get_analytics_rule(OpenApiTypesense.Connection.new(), rule_name)
  ```
  """
  @doc since: "1.0.0"
  @spec get_analytics_rule(map() | Connection.t() | String.t(), String.t() | keyword()) ::
          {:ok, OpenApiTypesense.AnalyticsRuleSchema.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def get_analytics_rule(rule_name, opts) when is_list(opts) do
    Connection.new() |> get_analytics_rule(rule_name, opts)
  end

  def get_analytics_rule(conn, rule_name) do
    get_analytics_rule(conn, rule_name, [])
  end

  @doc """
  Same as [get_analytics_rule/2](`get_analytics_rule/2`) but passes another connection.

  ```elixir
  ExTypesense.get_analytics_rule(%{api_key: xyz, host: ...}, rule_name, [])

  ExTypesense.get_analytics_rule(OpenApiTypesense.Connection.new(), rule_name, [])
  ```
  """
  @doc since: "1.0.0"
  @spec get_analytics_rule(map() | Connection.t(), String.t(), keyword()) ::
          {:ok, OpenApiTypesense.AnalyticsRuleSchema.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def get_analytics_rule(conn, rule_name, opts) do
    OpenApiTypesense.Analytics.retrieve_analytics_rule(conn, rule_name, opts)
  end

  @doc """
  Upserts an analytics rule with the given name.
  """
  @doc since: "1.0.0"
  @spec upsert_analytics_rule(String.t(), map()) ::
          {:ok, OpenApiTypesense.AnalyticsRuleSchema.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def upsert_analytics_rule(rule_name, body) do
    upsert_analytics_rule(rule_name, body, [])
  end

  @doc since: "1.0.0"
  @spec upsert_analytics_rule(
          map() | Connection.t() | String.t(),
          String.t() | map(),
          map() | keyword()
        ) ::
          {:ok, OpenApiTypesense.AnalyticsRuleSchema.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def upsert_analytics_rule(rule_name, body, opts) when is_list(opts) do
    Connection.new() |> upsert_analytics_rule(rule_name, body, opts)
  end

  def upsert_analytics_rule(conn, rule_name, body) do
    upsert_analytics_rule(conn, rule_name, body, [])
  end

  @doc since: "1.0.0"
  @spec upsert_analytics_rule(map() | Connection.t(), String.t(), map(), keyword()) ::
          {:ok, OpenApiTypesense.AnalyticsRuleSchema.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def upsert_analytics_rule(conn, rule_name, body, opts) do
    OpenApiTypesense.Analytics.upsert_analytics_rule(conn, rule_name, body, opts)
  end

  @doc """
  Delete an analytics rule

  Permanently deletes an analytics rule, given it's name
  """
  @doc since: "1.0.0"
  @spec delete_analytics_rule(String.t()) ::
          {:ok, OpenApiTypesense.AnalyticsRuleDeleteResponse.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def delete_analytics_rule(rule_name) do
    delete_analytics_rule(rule_name, [])
  end

  @doc """
  Same as [delete_analytics_rule/1](`delete_analytics_rule/1`)

  ```elixir
  ExTypesense.delete_analytics_rule(rule_name, [])

  ExTypesense.delete_analytics_rule(%{api_key: xyz, host: ...}, rule_name)

  ExTypesense.delete_analytics_rule(OpenApiTypesense.Connection.new(), rule_name)
  ```
  """
  @doc since: "1.0.0"
  @spec delete_analytics_rule(map() | Connection.t() | String.t(), String.t() | keyword()) ::
          {:ok, OpenApiTypesense.AnalyticsRuleDeleteResponse.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def delete_analytics_rule(rule_name, opts) when is_list(opts) do
    Connection.new() |> delete_analytics_rule(rule_name, opts)
  end

  def delete_analytics_rule(conn, rule_name) do
    delete_analytics_rule(conn, rule_name, [])
  end

  @doc """
  Same as [delete_analytics_rule/2](`delete_analytics_rule/2`) but passes another connection.

  ```elixir
  ExTypesense.delete_analytics_rule(%{api_key: xyz, host: ...}, rule_name, [])

  ExTypesense.delete_analytics_rule(OpenApiTypesense.Connection.new(), rule_name, [])
  ```
  """
  @doc since: "1.0.0"
  @spec delete_analytics_rule(map() | Connection.t(), String.t(), keyword()) ::
          {:ok, OpenApiTypesense.AnalyticsRuleDeleteResponse.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def delete_analytics_rule(conn, rule_name, opts) do
    OpenApiTypesense.Analytics.delete_analytics_rule(conn, rule_name, opts)
  end
end
