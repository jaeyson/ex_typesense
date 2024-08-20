defmodule OpenApiTypesense.SearchOverrideSchema do
  @moduledoc """
  Provides struct and type for a SearchOverrideSchema
  """

  @type t :: %__MODULE__{
          effective_from_ts: integer | nil,
          effective_to_ts: integer | nil,
          excludes: [OpenApiTypesense.SearchOverrideExclude.t()] | nil,
          filter_by: String.t() | nil,
          filter_curated_hits: boolean | nil,
          includes: [OpenApiTypesense.SearchOverrideInclude.t()] | nil,
          metadata: map | nil,
          remove_matched_tokens: boolean | nil,
          replace_query: String.t() | nil,
          rule: OpenApiTypesense.SearchOverrideRule.t(),
          sort_by: String.t() | nil,
          stop_processing: boolean | nil
        }

  defstruct [
    :effective_from_ts,
    :effective_to_ts,
    :excludes,
    :filter_by,
    :filter_curated_hits,
    :includes,
    :metadata,
    :remove_matched_tokens,
    :replace_query,
    :rule,
    :sort_by,
    :stop_processing
  ]

  @doc false
  @spec __fields__(atom) :: keyword
  def __fields__(type \\ :t)

  def __fields__(:t) do
    [
      effective_from_ts: :integer,
      effective_to_ts: :integer,
      excludes: [{OpenApiTypesense.SearchOverrideExclude, :t}],
      filter_by: {:string, :generic},
      filter_curated_hits: :boolean,
      includes: [{OpenApiTypesense.SearchOverrideInclude, :t}],
      metadata: :map,
      remove_matched_tokens: :boolean,
      replace_query: {:string, :generic},
      rule: {OpenApiTypesense.SearchOverrideRule, :t},
      sort_by: {:string, :generic},
      stop_processing: :boolean
    ]
  end
end
