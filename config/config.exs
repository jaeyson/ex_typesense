import Config

if Mix.env() in [:dev, :test] do
  config :ex_typesense,
    api_key: "xyz",
    host: "localhost",
    port: 8108,
    scheme: "http",
    options: %{}
end
