defmodule Mix.Tasks.Purerl.Test do
  @moduledoc "Runs `purerl` tests"

  use Mix.Task

  require Logger
  require PurerlAlias

  PurerlAlias.alias(PurerlTest.ModuleUtilities, as: Utilities)

  @impl Mix.Task
  def run(arguments) do
    Mix.Task.run("compile")
    debug? = "debug" in arguments

    if debug? do
      Logger.debug("Running `purerl` tests in '#{File.cwd!()}': #{inspect(arguments)}")
    end

    initialize_environment()

    Utilities.findPureScriptSpecModules().()
    |> Enum.map(&Utilities.pureScriptModuleToErlangModule/1)
    |> Enum.each(fn module ->
      if debug? do
        Logger.debug("Running tests in #{inspect(module)}")
      end

      module.main().()
    end)

    receive_until_done(debug?)
  end

  defp initialize_environment() do
    Application.ensure_all_started(:purerl_test)
    :gproc.ensure_reg({:p, :l, :"PurerlTest.Reporter.Bus"})
  end

  defp receive_until_done(debug?) do
    receive do
      {:msg, {:allDone, 0 = _exit_code}} ->
        IO.puts("🎉 All done!")

      {:msg, {:allDone, exit_code}} ->
        IO.puts("❌ Done with failures.")
        exit({:shutdown, exit_code})

      other ->
        if debug? do
          IO.puts("Received: #{inspect(other)}")
        end

        receive_until_done(debug?)
    end
  end
end
