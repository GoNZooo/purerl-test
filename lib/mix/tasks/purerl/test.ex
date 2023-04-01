defmodule Mix.Tasks.Purerl.Test do
  @moduledoc "Runs `purerl` tests"

  use Mix.Task

  require PureScriptAlias

  PureScriptAlias.alias(PurerlExUnit.ModuleUtilities)

  @impl Mix.Task
  def run(_args) do
    initialize_environment()

    find_purescript_spec_modules()
    |> Enum.map(&ModuleUtilities.pureScriptModuleToErlangModule/1)
    |> Enum.each(fn module -> module.main().() end)

    receive_until_done()
  end

  defp initialize_environment() do
    Application.ensure_all_started(:purerl_ex_unit)
    :gproc.reg({:p, :l, :"PurerlExUnit.Reporter.Bus"})
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

  defp find_purescript_spec_modules() do
    Path.wildcard("test/**/*Spec.purs")
    |> Enum.map(fn path ->
      ModuleUtilities.pureScriptFileToPureScriptModule(%{prefix: {:just, "Test."}}, path)
    end)
  end
end
