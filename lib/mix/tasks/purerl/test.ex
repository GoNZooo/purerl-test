defmodule Mix.Tasks.Purerl.Test do
  @moduledoc "Runs `purerl` tests"

  use Mix.Task

  require PurerlAlias

  PurerlAlias.alias(PurerlTest.ModuleUtilities, as: Utilities)

  @impl Mix.Task
  def run(_args) do
    initialize_environment()

    Utilities.findPureScriptSpecModules().()
    |> Enum.map(&Utilities.pureScriptModuleToErlangModule/1)
    |> Enum.each(fn module -> module.main().() end)

    receive_until_done()
  end

  defp initialize_environment() do
    Application.ensure_all_started(:purerl_test)
    :gproc.reg({:p, :l, :"PurerlTest.Reporter.Bus"})
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
end
