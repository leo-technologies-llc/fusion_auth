defmodule FusionAuth.MixProject do
  use Mix.Project

  @version "0.3.0"
  @url "https://github.com/leo-technologies-llc/fusion_auth"
  @name "FusionAuth"
  @description "Elixir SDK for #{@name}"

  def project do
    [
      app: :fusion_auth,
      version: @version,
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      name: @name,
      source_url: "https://github.com/leo-technologies-llc/fusion_auth",
      docs: [main: @name, source_ref: "v#{@version}", source_url: @url],
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.24", only: :dev, runtime: false},
      {:tesla, "~> 1.4.2"},
      {:hackney, "~> 1.18"},
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.5"},
      {:recase, "~> 0.7.0"},
      {:excoveralls, "~> 0.14", only: :test},
      {:faker, "~> 0.17", only: :test}
    ]
  end

  defp package() do
    [
      description: @description,
      files: ["lib", "config", "mix.exs", "README*"],
      maintainers: [
        "Brennan Karrer",
        "Shawn Liang",
        "Christopher Kempton",
        "Maurice Roy",
        "Axl Jon Dela Cruz"
      ],
      licenses: ["MIT"],
      links: %{github: @url}
    ]
  end
end
