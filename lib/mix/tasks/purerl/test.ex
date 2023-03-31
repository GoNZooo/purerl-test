defmodule Mix.Tasks.Purerl.Test do
  @moduledoc "Runs `purerl` tests"

  use Mix.Task

  @impl Mix.Task
  def run(_args) do
    Application.ensure_all_started(:purerl_ex_unit)
    :gproc.reg({:p, :l, :"PurerlExUnit.Reporter.Bus"})

    erlang_modules = Enum.map(find_test_modules(), &purs_module_to_erlang_module/1)

    for module <- erlang_modules do
      module.main().()
    end

    receive_until_done()
  end

  defp receive_until_done() do
    receive do
      {:msg, {:allDone, 0 = _exit_code}} ->
        IO.puts("🎉 All done!")

      {:msg, {:allDone, exit_code}} ->
        IO.puts("❌ Done with failures.")
        exit({:shutdown, exit_code})

      _other ->
        receive_until_done()
    end
  end

  defp find_test_modules() do
    Path.wildcard("test/**/*Spec.purs") |> Enum.map(&purs_file_to_purs_module/1)
  end

  defp purs_file_to_purs_module(prefix \\ "Test.", file) do
    last_component = Path.basename(file, ".purs")

    case Path.split(Path.dirname(file)) do
      ["test"] ->
        prefix <> last_component

      ["test" | rest] ->
        middle_components = Enum.map(rest, &uppercase_first_letter/1)
        prefix <> Enum.join(middle_components, ".") <> "." <> last_component

      _ ->
        raise "Unexpected path: #{file}"
    end
  end

  defp purs_module_to_erlang_module(module) do
    module
    |> String.split(".")
    |> Enum.map(&lowercase_first_letter/1)
    |> Enum.join("_")
    |> then(fn name -> "#{name}@ps" end)
    |> String.to_atom()
  end

  defp uppercase_first_letter(string) do
    String.upcase(String.first(string)) <> String.slice(string, 1..-1)
  end

  defp lowercase_first_letter(string) do
    String.downcase(String.first(string)) <> String.slice(string, 1..-1)
  end
end
