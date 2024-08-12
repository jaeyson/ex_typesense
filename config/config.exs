import Config

if Mix.env() in [:dev, :test] do
  config :ex_typesense,
    api_key: "xyz",
    host: "localhost",
    port: 8108,
    scheme: "http"

  config :oapi_generator,
    default: [
      output: [
        base_module: ExTypesense,
        location: "openapi/generator/ExTypesense"
      ]
    ]
end
