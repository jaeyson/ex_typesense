defmodule ExTypesense.Analytics do
  @moduledoc since: "0.3.0"

  @moduledoc """
  Typesense can aggregate search queries for both analytics
  purposes and for query suggestions.

  More here: https://typesense.org/docs/latest/api/analytics-query-suggestions.html
  """

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
          | {:ok,
             OpenApiTypesense.AnalyticsRule.t()
             | [map | OpenApiTypesense.AnalyticsRule.t()]}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def create_analytics_rule(body) do
    create_analytics_rule(body, [])
  end

  @doc """
  Same as [create_analytics_rule/1](`create_analytics_rule/1`)

  ## Options

    * `conn`: The custom connection map or struct you passed

  ## Examples
      iex> conn = %{api_key: xyz, host: ...}
      iex> ExTypesense.create_analytics_rule(body, conn: conn)

      iex> conn = OpenApiTypesense.Connection.new()
      iex> ExTypesense.create_analytics_rule(body, conn: conn)

      iex> opts = [conn: conn]
      iex> ExTypesense.create_analytics_rule(body, opts)
  """
  @doc since: "1.0.0"
  @spec create_analytics_rule(map(), keyword()) ::
          {:ok, OpenApiTypesense.AnalyticsRuleSchema.t()}
          | {:ok,
             OpenApiTypesense.AnalyticsRule.t()
             | [map | OpenApiTypesense.AnalyticsRule.t()]}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def create_analytics_rule(body, opts) do
    OpenApiTypesense.Analytics.create_analytics_rule(body, opts)
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

  ## Options

    * `conn`: The custom connection map or struct you passed

  ## Examples
      iex> conn = %{api_key: xyz, host: ...}
      iex> ExTypesense.create_analytics_event(body, conn: conn)

      iex> conn = OpenApiTypesense.Connection.new()
      iex> ExTypesense.create_analytics_event(body, conn: conn)

      iex> opts = [conn: conn]
      iex> ExTypesense.create_analytics_event(body, opts)
  """
  @doc since: "1.0.0"
  @spec create_analytics_event(map(), keyword()) ::
          {:ok, OpenApiTypesense.AnalyticsEventCreateResponse.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def create_analytics_event(body, opts) do
    OpenApiTypesense.Analytics.create_analytics_event(body, opts)
  end

  @doc """
  Retrieve the details of all analytics rules

  ## Examples
      iex> ExTypesense.list_analytics_rules()
  """
  @doc since: "1.0.0"
  @spec list_analytics_rules ::
          {:ok, [OpenApiTypesense.AnalyticsRule.t()]}
          | {:ok, OpenApiTypesense.AnalyticsRulesRetrieveSchema.t()}
          | :error
  def list_analytics_rules do
    list_analytics_rules([])
  end

  @doc """
  Same as [list_analytics_rules/0](`list_analytics_rules/0`)

  ## Options

    * `conn`: The custom connection map or struct you passed

  ## Examples
      iex> conn = %{api_key: xyz, host: ...}
      iex> ExTypesense.list_analytics_rules(conn: conn)

      iex> conn = OpenApiTypesense.Connection.new()
      iex> ExTypesense.list_analytics_rules(conn: conn)

      iex> opts = [conn: conn]
      iex> ExTypesense.list_analytics_rules(opts)
  """
  @doc since: "1.0.0"
  @spec list_analytics_rules(keyword()) ::
          {:ok, [OpenApiTypesense.AnalyticsRule.t()]}
          | {:ok, OpenApiTypesense.AnalyticsRulesRetrieveSchema.t()}
          | :error
  def list_analytics_rules(opts) do
    OpenApiTypesense.Analytics.retrieve_analytics_rules(opts)
  end

  @doc """
  Retrieve the details of an analytics rule, given it's name

  ## Examples
      iex> ExTypesense.get_analytics_rule(rule_name)
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

  ## Options

    * `conn`: The custom connection map or struct you passed

  ## Examples
      iex> conn = %{api_key: xyz, host: ...}
      iex> ExTypesense.get_analytics_rule(rule_name, conn: conn)

      iex> conn = OpenApiTypesense.Connection.new()
      iex> ExTypesense.get_analytics_rule(rule_name, conn: conn)

      iex> opts = [conn: conn]
      iex> ExTypesense.get_analytics_rule(rule_name, opts)
  """
  @doc since: "1.0.0"
  @spec get_analytics_rule(String.t(), keyword()) ::
          {:ok, OpenApiTypesense.AnalyticsRuleSchema.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def get_analytics_rule(rule_name, opts) do
    OpenApiTypesense.Analytics.retrieve_analytics_rule(rule_name, opts)
  end

  @doc """
  Upserts an analytics rule with the given name.
  """
  @doc since: "1.0.0"
  @spec upsert_analytics_rule(String.t(), map()) ::
          {:ok, OpenApiTypesense.AnalyticsRule.t()}
          | {:ok, OpenApiTypesense.AnalyticsRuleSchema.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def upsert_analytics_rule(rule_name, body) do
    upsert_analytics_rule(rule_name, body, [])
  end

  @doc """
  Same as [upsert_analytics_rule/2](`upsert_analytics_rule/2`)

  ## Options

    * `conn`: The custom connection map or struct you passed

  ## Examples
      iex> conn = %{api_key: xyz, host: ...}
      iex> ExTypesense.upsert_analytics_rule(rule_name, body, conn: conn)

      iex> conn = OpenApiTypesense.Connection.new()
      iex> ExTypesense.upsert_analytics_rule(rule_name, body, conn: conn)

      iex> opts = [conn: conn]
      iex> ExTypesense.upsert_analytics_rule(rule_name, body, opts)
  """
  @doc since: "1.0.0"
  @spec upsert_analytics_rule(String.t(), map(), keyword()) ::
          {:ok, OpenApiTypesense.AnalyticsRule.t()}
          | {:ok, OpenApiTypesense.AnalyticsRuleSchema.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def upsert_analytics_rule(rule_name, body, opts) do
    OpenApiTypesense.Analytics.upsert_analytics_rule(rule_name, body, opts)
  end

  @doc """
  Delete an analytics rule

  Permanently deletes an analytics rule, given it's name
  """
  @doc since: "1.0.0"
  @spec delete_analytics_rule(String.t()) ::
          {:ok, OpenApiTypesense.AnalyticsRuleDeleteResponse.t()}
          | {:ok, OpenApiTypesense.AnalyticsRule.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def delete_analytics_rule(rule_name) do
    delete_analytics_rule(rule_name, [])
  end

  @doc """
  Same as [delete_analytics_rule/1](`delete_analytics_rule/1`)

  ## Options

    * `conn`: The custom connection map or struct you passed

  ## Examples
      iex> conn = %{api_key: xyz, host: ...}
      iex> ExTypesense.delete_analytics_rule(rule_name, conn: conn)

      iex> conn = OpenApiTypesense.Connection.new()
      iex> ExTypesense.delete_analytics_rule(rule_name, conn: conn)

      iex> opts = [conn: conn]
      iex> ExTypesense.delete_analytics_rule(rule_name, opts)
  """
  @doc since: "1.0.0"
  @spec delete_analytics_rule(String.t(), keyword()) ::
          {:ok, OpenApiTypesense.AnalyticsRuleDeleteResponse.t()}
          | {:ok, OpenApiTypesense.AnalyticsRule.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def delete_analytics_rule(rule_name, opts) do
    OpenApiTypesense.Analytics.delete_analytics_rule(rule_name, opts)
  end

  @doc """
  Flush in-memory analytics to disk

  Triggers a flush of analytics data to persistent storage.

  """
  @doc since: "2.1.0"
  @spec flush_analytics ::
          {:ok, OpenApiTypesense.AnalyticsEventCreateResponse.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def flush_analytics do
    flush_analytics([])
  end

  @doc """
  Same as [flush_analytics/0](`flush_analytics/0`)

  ## Options

    * `conn`: The custom connection map or struct you passed

  """
  @doc since: "2.1.0"
  @spec flush_analytics(opts :: keyword) ::
          {:ok, OpenApiTypesense.AnalyticsEventCreateResponse.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def flush_analytics(opts) do
    OpenApiTypesense.Analytics.flush_analytics(opts)
  end

  @doc """
  Retrieve analytics events

  Retrieve the most recent events for a user and rule.

  ## Options

    * `user_id`
    * `name`: Analytics rule name
    * `n`: Number of events to return (max 1000)

  """
  @doc since: "2.1.0"
  @spec get_analytics_events ::
          {:ok, OpenApiTypesense.AnalyticsEventsResponse.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def get_analytics_events do
    get_analytics_events([])
  end

  @doc """
  Same as [get_analytics_events/0](`get_analytics_events/0`)

  ## Options

    * `conn`: The custom connection map or struct you passed

  """
  @doc since: "2.1.0"
  @spec get_analytics_events(opts :: keyword) ::
          {:ok, OpenApiTypesense.AnalyticsEventsResponse.t()}
          | {:error, OpenApiTypesense.ApiResponse.t()}
  def get_analytics_events(opts) do
    OpenApiTypesense.Analytics.get_analytics_events(opts)
  end

  @doc """
  Get analytics subsystem status

  Returns sizes of internal analytics buffers and queues.
  """
  @doc since: "2.1.0"
  @spec get_analytics_status ::
          {:ok, OpenApiTypesense.AnalyticsStatus.t()} | {:error, OpenApiTypesense.ApiResponse.t()}
  def get_analytics_status do
    get_analytics_status([])
  end

  @doc """
  Same as [get_analytics_status/0](`get_analytics_status/0`)

  ## Options

    * `conn`: The custom connection map or struct you passed

  """
  @doc since: "2.1.0"
  @spec get_analytics_status(opts :: keyword) ::
          {:ok, OpenApiTypesense.AnalyticsStatus.t()} | {:error, OpenApiTypesense.ApiResponse.t()}
  def get_analytics_status(opts) do
    OpenApiTypesense.Analytics.get_analytics_status(opts)
  end
end
