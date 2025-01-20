import Config

if config_env() in [:dev, :test] do
  config :open_api_typesense,
    api_key: "xyz",
    host: "localhost",
    port: 8108,
    scheme: "http"
end
