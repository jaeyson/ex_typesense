defmodule OpenApiTypesense.PresetUpsertSchema do
  @moduledoc """
  Provides struct and type for a PresetUpsertSchema
  """

  @type t :: %__MODULE__{
          value:
            OpenApiTypesense.MultiSearchSearchesParameter.t()
            | OpenApiTypesense.SearchParameters.t()
        }

  defstruct [:value]

  @doc false
  @spec __fields__(atom) :: keyword
  def __fields__(type \\ :t)

  def __fields__(:t) do
    [
      value:
        {:union,
         [
           {OpenApiTypesense.MultiSearchSearchesParameter, :t},
           {OpenApiTypesense.SearchParameters, :t}
         ]}
    ]
  end
end
