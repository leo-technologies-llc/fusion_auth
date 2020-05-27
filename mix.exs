defmodule FusionAuth.MixProject do
  use Mix.Project

  def project do
    [
      app: :fusion_auth,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:tesla, "~> 1.3.0"},
      {:hackney, "~> 1.15.2"},
      {:verus_common, git: "git@github.com:Cogility/verus_common"}
    ]
  end
end
