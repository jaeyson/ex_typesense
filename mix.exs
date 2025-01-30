defmodule ExTypesense.MixProject do
  use Mix.Project

  @source_url "https://github.com/jaeyson/ex_typesense"
  @version "1.0.1"

  def project do
    [
      app: :ex_typesense,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      consolidate_protocols: Mix.env() not in [:dev, :test],
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      description: "Typesense client for Elixir with support for importing your Ecto schemas.",
      docs: docs(),
      package: package(),
      name: "ExTypesense",
      source_url: @source_url
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.34", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:ecto, "~> 3.12"},
      {:excoveralls, "~> 0.18", only: :test, runtime: false},
      {:mix_audit, "~> 2.1", only: :test, runtime: false},
      {:open_api_typesense, "~> 0.6"}
    ]
  end

  defp docs do
    [
      api_reference: false,
      main: "readme",
      source_ref: "v#{@version}",
      source_url: @source_url,
      canonical: "https://hexdocs.pm/ex_typesense",
      formatters: ["html"],
      docs: [
        deps: [
          open_api_typesense: "https://hexdocs.pm/open_api_typesense/"
        ]
      ],
      extras: [
        "CHANGELOG.md",
        "README.md",
        "guides/running_local_typesense.md": [title: "Running local Typesense"],
        "guides/cheatsheet.cheatmd": [title: "Cheatsheet"],
        "LICENSE.md": [title: "License"],
        "CONTRIBUTING.md": [title: "Contributing"],
        "CODE_OF_CONDUCT.md": [title: "Code of Conduct"]
      ]
    ]
  end

  defp package do
    [
      maintainers: ["Jaeyson Anthony Y."],
      licenses: ["MIT"],
      links: %{
        "Github" => @source_url,
        "Changelog" => "https://hexdocs.pm/ex_typesense/changelog.html",
        "Typesense website" => "https://typesense.org",
        "Typesense documentation" => "https://https://typesense.org/docs"
      }
    ]
  end
end
