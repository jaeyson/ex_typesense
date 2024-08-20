defmodule OpenApiTypesense.FacetCountsCounts do
  @moduledoc """
  Provides struct and type for a FacetCountsCounts
  """

  @type t :: %__MODULE__{
          count: integer | nil,
          highlighted: String.t() | nil,
          parent: map | nil,
          value: String.t() | nil
        }

  defstruct [:count, :highlighted, :parent, :value]

  @doc false
  @spec __fields__(atom) :: keyword
  def __fields__(type \\ :t)

  def __fields__(:t) do
    [count: :integer, highlighted: {:string, :generic}, parent: :map, value: {:string, :generic}]
  end
end
