defmodule ExTypesense.ResultParser do
  import Ecto.Query, warn: false

  @moduledoc false

  @doc since: "0.1.0"
  @spec hits_to_query(Enum.t(), module()) :: Ecto.Query.t()
  def hits_to_query(hits, module_name) do
    if Enum.empty?(hits) do
      module_name
      |> where([i], i.id in [])
    else
      primary_field = module_name.__schema__(:source) <> "_id"

      values =
        Enum.map(hits, fn %{"document" => document} ->
          document[primary_field]
        end)

      module_name
      |> where([i], i.id in ^values)
    end
  end
end
