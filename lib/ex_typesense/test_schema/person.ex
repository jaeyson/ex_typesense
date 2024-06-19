defmodule ExTypesense.TestSchema.Person do
  use Ecto.Schema
  @behaviour ExTypesense

  @moduledoc false

  defimpl Jason.Encoder, for: __MODULE__ do
    def encode(value, opts) do
      value
      |> Map.take([:person_id, :name, :country])
      |> Enum.map(fn {key, val} ->
        if key === :person_id, do: {key, Map.get(value, :id)}, else: {key, val}
      end)
      |> Enum.into(%{})
      |> Jason.Encode.map(opts)
    end
  end

  schema "persons" do
    field(:name, :string)
    field(:country, :string)
    field(:person_id, :integer, virtual: true)
  end

  @impl ExTypesense
  def get_field_types do
    %{
      default_sorting_field: "person_id",
      fields: [
        %{name: "person_id", type: "int32"},
        %{name: "name", type: "string"},
        %{name: "country", type: "string"}
      ]
    }
  end
end
