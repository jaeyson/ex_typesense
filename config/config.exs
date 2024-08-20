import Config

if Mix.env() in [:dev, :test] do
  config :ex_typesense,
    api_key: "xyz",
    host: "localhost",
    port: 8108,
    scheme: "http"

import Config

config :oapi_generator,
  default: [
    output: [
      base_module: OpenApiTypesense,
      location: "lib/open_api_typesense",
      operation_subdirectory: "operations/",
      schema_subdirectory: "schemas/"      
    ]
  ]
end
