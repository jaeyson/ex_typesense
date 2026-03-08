defmodule ExTypesense.TestSchema.Person do
  use Ecto.Schema
  @behaviour ExTypesense

  @moduledoc false

  defimpl Jason.Encoder, for: __MODULE__ do
    def encode(value, opts) do
      value
      |> Map.take([:persons_id, :name, :country])
      |> Enum.map(fn {key, val} ->
        if key === :persons_id, do: {key, Map.get(value, :id)}, else: {key, val}
      end)
      |> Enum.into(%{})
      |> Jason.Encode.map(opts)
    end
  end

  schema "persons" do
    field(:name, :string)
    field(:country, :string)
    field(:persons_id, :integer, virtual: true)
  end

  @impl ExTypesense
  def get_field_types do
    name = __MODULE__.__schema__(:source)
    primary_field = name <> "_id"

    %{
      name: name,
      default_sorting_field: primary_field,
      fields: [
        %{name: primary_field, type: "int32"},
        %{name: "name", type: "string"},
        %{name: "country", type: "string"}
      ]
    }
  end
end
