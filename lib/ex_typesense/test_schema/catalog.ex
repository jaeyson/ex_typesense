defmodule ExTypesense.TestSchema.Catalog do
  use Ecto.Schema
  @behaviour ExTypesense

  @moduledoc false

  defimpl Jason.Encoder, for: __MODULE__ do
    def encode(value, opts) do
      value
      |> Map.take([:catalog_id, :name, :description])
      |> Enum.map(fn {key, val} ->
        if key === :catalog_id, do: {key, Map.get(value, :id)}, else: {key, val}
      end)
      |> Enum.into(%{})
      |> Jason.Encode.map(opts)
    end
  end

  schema "catalogs" do
    field(:name, :string)
    field(:description, :string)
    field(:catalog_id, :integer, virtual: true)
  end

  @impl ExTypesense
  def get_field_types do
    %{
      default_sorting_field: "catalog_id",
      fields: [
        %{name: "catalog_id", type: "int32"},
        %{name: "name", type: "string"},
        %{name: "description", type: "string"}
      ]
    }
  end
end
