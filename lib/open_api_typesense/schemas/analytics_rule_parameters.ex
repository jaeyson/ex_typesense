defmodule OpenApiTypesense.AnalyticsRuleParameters do
  @moduledoc """
  Provides struct and type for a AnalyticsRuleParameters
  """

  @type t :: %__MODULE__{
          destination: OpenApiTypesense.AnalyticsRuleParametersDestination.t(),
          limit: integer,
          source: OpenApiTypesense.AnalyticsRuleParametersSource.t()
        }

  defstruct [:destination, :limit, :source]

  @doc false
  @spec __fields__(atom) :: keyword
  def __fields__(type \\ :t)

  def __fields__(:t) do
    [
      destination: {OpenApiTypesense.AnalyticsRuleParametersDestination, :t},
      limit: :integer,
      source: {OpenApiTypesense.AnalyticsRuleParametersSource, :t}
    ]
  end
end
