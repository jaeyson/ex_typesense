defmodule ExTypesense.Parser do
  @moduledoc since: "0.1.0"
  @moduledoc """
  Module for converting structs to raw json body or map.
  """

  @type collection() :: %{
          name: String.t(),
          fields: list(map()),
          default_sorting_field: String.t()
        }

  @doc since: "0.1.0"
  @spec struct_to_raw_body(module(), String.t()) :: String.t()
  def struct_to_raw_body(module_name, default_sorting_field \\ "") do
    module_name
    |> struct_to_map(default_sorting_field)
    |> Jason.encode!()
  end

  @doc """
  Converts an ecto schema module (e.g. `Posts`) to a map.

  ## Examples
      default_sorting_field = "title"
      iex> ExTypesense.Parser.struct_to_map(AppModule, default_sorting_field)
      %{
        default_sorting_field: "title",
        fields: [...],
        name: "companies"
      }
  """
  @doc since: "0.1.0"
  @spec struct_to_map(module(), String.t()) :: collection()
  def struct_to_map(module_name, default_sorting_field \\ "") do
    %{
      name: module_name.__schema__(:source),
      fields: get_fields(module_name),
      default_sorting_field: default_sorting_field
    }
  end

  @doc """
  Gets ecto schema fields and turns it into a list of maps as field entries.
  """
  @doc since: "0.1.0"
  @spec get_fields(module()) :: list(map())
  def get_fields(module_name) do
    :fields
    |> module_name.__schema__()
    |> Enum.filter(fn field_name ->
      field_name = to_string(field_name)

      cond do
        String.contains?(field_name, "id") -> false
        String.contains?(field_name, "_id") -> false
        String.contains?(field_name, "inserted_at") -> false
        String.contains?(field_name, "updated_at") -> false
        true -> true
      end
    end)
    |> Enum.map(fn field_name ->
      type =
        :type
        |> module_name.__schema__(field_name)
        |> to_string()

      Map.new([
        {:name, to_string(field_name)},
        {:type, type},
        {:sort, true},
        {:facet, true}
      ])
    end)
  end
end
