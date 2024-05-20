defmodule Mix.Tasks.Typesense do
  use Mix.Task

  @moduledoc since: "0.4.0"
  @moduledoc """
    See:
    - [mix help typesense.create](Mix.Tasks.Typesense.Create.html)
    - [mix help typesense.import](Mix.Tasks.Typesense.Import.html)
  """

  @impl Mix.Task
  @spec run(any()) :: IO.puts()
  def run(_args) do
    IO.puts("""
    Which one?
    #{Enum.join(list_modules(), "\n")}
    """)
  end

  defp list_modules do
    {:ok, modules} = :application.get_key(:ex_typesense, :modules)

    modules
    |> Enum.filter(fn module ->
      case Module.split(module) do
        ["Mix", "Tasks", "Typesense", _module] -> true
        _ -> false
      end
    end)
    |> Enum.map(fn module ->
      [_, _, name, command] = Module.split(module)
      ~s(- mix help #{String.downcase(name)}.#{String.downcase(command)})
    end)
  end
end
