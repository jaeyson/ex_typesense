defmodule ExTypesense.TestSchema.Catalog do
  use Ecto.Schema
  @behaviour ExTypesense

  @moduledoc false

  defimpl Jason.Encoder, for: __MODULE__ do
    def encode(value, opts) do
      value
      |> Map.take([:catalogs_id, :name, :description])
      |> Enum.map(fn {key, val} ->
        if key === :catalogs_id, do: {key, Map.get(value, :id)}, else: {key, val}
      end)
      |> Enum.into(%{})
      |> Jason.Encode.map(opts)
    end
  end

  schema "catalogs" do
    field(:name, :string)
    field(:description, :string)
    field(:catalogs_id, :integer, virtual: true)
  end

  @impl ExTypesense
  def get_field_types do
    primary_field = __MODULE__.__schema__(:source) <> "_id"

    %{
      default_sorting_field: primary_field,
      fields: [
        %{name: primary_field, type: "int32"},
        %{name: "name", type: "string"},
        %{name: "description", type: "string"}
      ]
    }
  end
end
