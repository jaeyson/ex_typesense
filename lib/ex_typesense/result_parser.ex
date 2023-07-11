defmodule ExTypesense.ResultParser do
  import Ecto.Query, warn: false

  @moduledoc false

  @spec hits_to_query(Enum.t(), module()) :: Ecto.Query.t()
  def hits_to_query(hits, module_name) do
    case Enum.empty?(hits) do
      true ->
        module_name
        |> where([i], i.id in [])

      false ->
        # this assumes the fk pointing to primary, e.g. post_id
        first_virtual_field = hd(module_name.__schema__(:virtual_fields))

        # this assumes the pk, e.g. posts' "id" that matches fk above
        primary_key = hd(module_name.__schema__(:primary_key))

        values =
          Enum.map(hits, fn %{"document" => document} ->
            document[to_string(first_virtual_field)]
          end)

        module_name
        |> where([i], field(i, ^primary_key) in ^values)
    end
  end
end
