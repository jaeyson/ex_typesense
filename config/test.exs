import Config

config :open_api_typesense,
  api_key: "xyz",
  host: "localhost",
  port: 8108,
  scheme: "http",
  options: [
    max_retries: 0,
    retry: false
  ]
