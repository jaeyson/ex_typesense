defmodule OpenApiTypesense.CollectionUpdateSchema do
  @moduledoc """
  Provides struct and type for a CollectionUpdateSchema
  """

  @type t :: %__MODULE__{fields: [OpenApiTypesense.Field.t()]}

  defstruct [:fields]

  @doc false
  @spec __fields__(atom) :: keyword
  def __fields__(type \\ :t)

  def __fields__(:t) do
    [fields: [{OpenApiTypesense.Field, :t}]]
  end
end
