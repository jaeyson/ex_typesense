Application.put_all_env(
  ex_typesense: [
    api_key: "xyz",
    host: "localhost",
    port: 8108,
    scheme: "http"
  ]
)

ExUnit.start()

ExUnit.after_suite(fn %{failures: 0, skipped: 0, excluded: 0} ->
  [:api_key, :host, :port, :scheme]
  |> Enum.each(&Application.delete_env(:ex_typesense, &1))
end)
