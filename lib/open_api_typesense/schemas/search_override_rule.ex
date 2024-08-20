defmodule OpenApiTypesense.SearchOverrideRule do
  @moduledoc """
  Provides struct and type for a SearchOverrideRule
  """

  @type t :: %__MODULE__{
          filter_by: String.t() | nil,
          match: String.t() | nil,
          query: String.t() | nil,
          tags: [String.t()] | nil
        }

  defstruct [:filter_by, :match, :query, :tags]

  @doc false
  @spec __fields__(atom) :: keyword
  def __fields__(type \\ :t)

  def __fields__(:t) do
    [
      filter_by: {:string, :generic},
      match: {:enum, ["exact", "contains"]},
      query: {:string, :generic},
      tags: [string: :generic]
    ]
  end
end
