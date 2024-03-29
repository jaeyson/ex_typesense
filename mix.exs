defmodule ExTypesense.MixProject do
  use Mix.Project

  @source_url "https://github.com/jaeyson/ex_typesense"
  @version "0.3.5"

  def project do
    [
      app: :ex_typesense,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
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
      extra_applications: [:logger, :ssl, :inets]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.29.4", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.7.0", only: [:dev, :test], runtime: false},
      {:req, "~> 0.3.9"},
      {:ecto, "~> 3.10.2"},
      {:excoveralls, "~> 0.10", only: :test}
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
      extras: [
        "CHANGELOG.md",
        "README.md": [title: "Overview"],
        "guides/running_local_typesense.md": [title: "Running local Typesense"],
        "guides/cheatsheet.cheatmd": [title: "Cheatsheet"],
        "LICENSE.md": [title: "License"]
      ]
    ]
  end

  defp package do
    [
      maintainers: ["Jaeyson Anthony Y."],
      licenses: ["MIT"],
      links: %{
        Github: @source_url,
        Changelog: "https://hexdocs.pm/ex_typesense/changelog.html"
      }
    ]
  end
end
