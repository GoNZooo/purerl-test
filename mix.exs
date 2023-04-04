defmodule PurerlTest.MixProject do
  use Mix.Project

  def project do
    [
      app: :purerl_test,
      version: "0.1.6",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      build_embedded: Mix.env() == :prod,
      deps: deps(),
      compilers: compilers(),
      erlc_paths: erlc_paths(),
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

  defp compilers() do
    if Mix.env() == :prod do
      Mix.compilers()
    else
      [:purerl | Mix.compilers()]
    end
  end

  defp erlc_paths() do
    if Mix.env() == :prod do
      []
    else
      ["output"]
    end
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:purerlex, "~> 0.4.2", only: [:dev, :test]},
      {:gproc, "~> 0.9.0"},
      {:purerl_alias, "~> 0.1.4", only: [:dev, :test], env: Mix.env()},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
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

  # defp releases() do
  #   [
  #     purerl_test: [
  #       steps: [&deduplicate_ebins/1, :assemble]
  #     ]
  #   ]
  # end
  #
  # defp deduplicate_ebins(%Mix.Release{applications: applications} = release) do
  #   # release
  #   # |> Map.put(:applications, Enum.map(applications, &remove_ps_beams/1))
  #
  #   new_applications = Enum.into(applications, %{}, &remove_ps_beams/1)
  #   IO.inspect(applications.purerl_test, label: "purerl_test")
  #   IO.inspect(new_applications.purerl_test, label: "purerl_test")
  #   IO.inspect(applications.purerl_alias, label: "purerl_alias")
  #   IO.inspect(new_applications.purerl_alias, label: "purerl_alias")
  #
  #   %Mix.Release{release | applications: new_applications}
  # end
  #
  # defp remove_ps_beams({application_name, settings}) do
  #   modules = Keyword.get(settings, :modules, [])
  #   path = Keyword.get(settings, :path, nil)
  #
  #   without_ps_beams =
  #     modules
  #     |> Enum.reject(fn name ->
  #       is_ps_module? =
  #         name
  #         |> Atom.to_string()
  #         |> then(fn n -> String.ends_with?(n, "@ps") or String.ends_with?(n, "@foreign") end)
  #
  #       if is_ps_module? do
  #         [path, "ebin", Atom.to_string(name) <> ".beam"] |> Path.join() |> File.rm()
  #       end
  #
  #       is_ps_module?
  #     end)
  #
  #   {application_name, Keyword.put(settings, :modules, without_ps_beams)}
  # end
end
