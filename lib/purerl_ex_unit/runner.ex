defmodule PurerlExUnit.Runner do
  @moduledoc """
  Runs assertions in real time from PureScript tests.
  """

  use GenServer

  require ExUnit.Assertions, as: Assertions

  def start_link(_arguments) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def execute(test_name, index, assertion) do
    GenServer.call(
      __MODULE__,
      {:execute, %{test_name: test_name, assertion: assertion, index: index}}
    )
  end

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_call({:execute, %{assertion: {:assert, true}} = test_data}, _from, state) do
    output_success(test_data)

    {:reply, :ok, state}
  end

  def handle_call({:execute, %{assertion: {:assert, false}} = test_data}, _from, state) do
    output_failure(test_data)

    {:reply, :error, state}
  end

  def handle_call({:execute, %{assertion: {:refute, false}} = test_data}, _from, state) do
    output_success(test_data)

    {:reply, :ok, state}
  end

  def handle_call({:execute, %{assertion: {:refute, true}} = test_data}, _from, state) do
    output_failure(test_data)

    {:reply, :error, state}
  end

  def handle_call(
        {:execute, %{assertion: {:assertEqual, %{left: left, right: right}}} = test_data},
        _from,
        state
      ) do
    run_assertion(test_data, left, right, &Kernel.==/2, state)
  end

  def handle_call(
        {:execute, %{assertion: {:assertNotEqual, %{left: left, right: right}}} = test_data},
        _from,
        state
      ) do
    run_assertion(test_data, left, right, &Kernel.!=/2, state)
  end

  def handle_call(
        {:execute, %{assertion: {:assertGreaterThan, %{left: left, right: right}}} = test_data},
        _from,
        state
      ) do
    run_assertion(test_data, left, right, &Kernel.>/2, state)
  end

  def handle_call(
        {:execute, %{assertion: {:assertLessThan, %{left: left, right: right}}} = test_data},
        _from,
        state
      ) do
    run_assertion(test_data, left, right, &Kernel.</2, state)
  end

  def handle_call(
        {
          :execute,
          %{assertion: {:assertGreaterThanOrEqual, %{left: left, right: right}}} = test_data
        },
        _from,
        state
      ) do
    run_assertion(test_data, left, right, &Kernel.>=/2, state)
  end

  def handle_call(
        {:execute,
         %{assertion: {:assertLessThanOrEqual, %{left: left, right: right}}} = test_data},
        _from,
        state
      ) do
    run_assertion(test_data, left, right, &Kernel.<=/2, state)
  end

  defp run_assertion(test_data, left, right, op, state) do
    if op.(left, right) do
      output_success(test_data)

      {:reply, :ok, state}
    else
      output_failure(test_data)

      try do
        Assertions.assert(op.(left, right))
      rescue
        e in ExUnit.AssertionError ->
          IO.puts("    #{e.message}")

          %{left: left, right: right} =
            e
            |> ExUnit.Formatter.format_assertion_diff(0, 80, &formatter/2)
            |> Enum.map(fn {key, value} -> {key, Enum.join(value)} end)
            |> Enum.into(%{})

          IO.puts("    Left:\t#{left}\n    Right:\t#{right}")

          {:reply, :error, state}

        e ->
          IO.puts("    Unknown exception: #{inspect(e)}")
          {:reply, :error, state}
      end
    end
  end

  defp output_success(%{} = test_data) do
    output_test_result(:success, test_data)
  end

  defp output_failure(%{} = test_data) do
    output_test_result(:failure, test_data)
  end

  defp output_test_result(:success, %{test_name: test_name, index: index}) do
    IO.puts("  ✅ #{test_name} [#{index}]")
  end

  defp output_test_result(:failure, %{test_name: test_name, index: index}) do
    IO.puts("  ❌ #{test_name} [#{index}]")
  end

  defp formatter(:diff_enabled?, _default), do: true
  defp formatter(:diff_delete, msg), do: colorize(:red, msg)
  defp formatter(:diff_insert, msg), do: colorize(:green, msg)

  defp formatter(:diff_delete_whitespace, msg) do
    colorize(IO.ANSI.color_background(2, 0, 0), msg)
  end

  defp formatter(:diff_insert_whitespace, msg) do
    colorize(IO.ANSI.color_background(0, 2, 0), msg)
  end

  defp formatter(key, msg) do
    IO.puts("  #{key}: #{msg}")
    msg
  end

  defp colorize(escape, {:doc_cons, value, value2}) do
    colorize(escape, value) <> colorize(escape, value2)
  end

  defp colorize(escape, string) do
    [escape, string, :reset]
    |> IO.ANSI.format_fragment(true)
    |> IO.iodata_to_binary()
  end
end
