defmodule ExTypesense.MixProject do
  use Mix.Project

  @source_url "https://github.com/jaeyson/ex_typesense"
  @version "0.3.0"

  def project do
    [
      app: :ex_typesense,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
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
      {:ecto, "~> 3.10.2"}
    ]
  end

  defp docs do
    [
      api_reference: false,
      main: "readme",
      source_ref: "v#{@version}",
      source_url: @source_url,
      canonical: "https://hexdocs.pm/ex_typesense",
      extras: [
        "README.md",
        "CHANGELOG.md",
        "LICENSE",
        "Cheatsheet.cheatmd"
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
