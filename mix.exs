defmodule PurerlTest.MixProject do
  use Mix.Project

  def project do
    [
      app: :purerl_test,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      build_embedded: Mix.env() == :prod,
      deps: deps(),
      compilers: [:purerl | Mix.compilers()],
      erlc_paths: ["output"],
      package: package(),
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {:purerlTest_application@ps, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:purerlex, "~> 0.4.2"},
      {:gproc, "~> 0.9.0"},
      {:purerl_alias, "~> 0.1.3"}
    ]
  end

  defp package() do
    [
      maintainers: ["Rickard Andersson"],
      description: "A testing library for PureScript (`purerl`) projects.",
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/GoNZooo/purerl-test"
      },
      files: [
        "lib",
        "mix.exs",
        "README.md",
        "LICENSE",
        "src",
        "spago.dhall",
        "packages.dhall",
        "test"
      ]
    ]
  end

  defp docs() do
    [main: "PurerlTest"]
  end
end
