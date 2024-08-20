defmodule OpenApiTypesense.FieldEmbed do
  @moduledoc """
  Provides struct and type for a FieldEmbed
  """

  @type t :: %__MODULE__{
          from: [String.t()],
          model_config: OpenApiTypesense.FieldEmbedModelConfig.t()
        }

  defstruct [:from, :model_config]

  @doc false
  @spec __fields__(atom) :: keyword
  def __fields__(type \\ :t)

  def __fields__(:t) do
    [from: [string: :generic], model_config: {OpenApiTypesense.FieldEmbedModelConfig, :t}]
  end
end
