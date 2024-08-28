defmodule OpenApiTypesense.PresetsRetrieveSchema do
  @moduledoc """
  Provides struct and type for a PresetsRetrieveSchema
  """

  @type t :: %__MODULE__{presets: [OpenApiTypesense.PresetSchema.t()]}

  defstruct [:presets]

  @doc false
  @spec __fields__(atom) :: keyword
  def __fields__(type \\ :t)

  def __fields__(:t) do
    [presets: [{OpenApiTypesense.PresetSchema, :t}]]
  end
end
