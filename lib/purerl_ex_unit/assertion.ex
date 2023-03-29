defmodule PurerlExUnit.Assertion do
  require ExUnit.Assertions, as: Assertions

  def execute({:assert, true}, _index, _test_name), do: {:assertionPassed}

  def execute({:assert, false}, index, test_name) do
    {:assertionFailed, %{index: index, message: "  ❌ #{test_name} [#{index}]"}}
  end

  def execute({:refute, false}, _index, _test_name), do: {:assertionPassed}

  def execute({:refute, true}, index, test_name) do
    {:assertionFailed, %{index: index, message: "  ❌ #{test_name} [#{index}]"}}
  end

  def execute({:assertEqual, %{}} = assertion, index, test_name) do
    run_assertion(assertion, &Kernel.==/2, index, test_name)
  end

  def execute({:assertNotEqual, %{}} = assertion, index, test_name) do
    run_assertion(assertion, &Kernel.!=/2, index, test_name)
  end

  def execute({:assertGreaterThan, %{}} = assertion, index, test_name) do
    run_assertion(assertion, &Kernel.>/2, index, test_name)
  end

  def execute({:assertLessThan, %{}} = assertion, index, test_name) do
    run_assertion(assertion, &Kernel.</2, index, test_name)
  end

  def execute({:assertGreaterThanOrEqual, %{}} = assertion, index, test_name) do
    run_assertion(assertion, &Kernel.>=/2, index, test_name)
  end

  def execute({:assertLessThanOrEqual, %{}} = assertion, index, test_name) do
    run_assertion(assertion, &Kernel.<=/2, index, test_name)
  end

  defp run_assertion({_assertion_type, %{left: left, right: right}}, op, index, test_name) do
    if op.(left, right) do
      {:assertionPassed}
    else
      try do
        Assertions.assert(op.(left, right))
      rescue
        e in ExUnit.AssertionError ->
          %{left: left, right: right} =
            e
            |> ExUnit.Formatter.format_assertion_diff(0, 80, &formatter/2)
            |> Enum.map(fn {key, value} -> {key, Enum.join(value)} end)
            |> Enum.into(%{})

          message = failure_message(test_name, index, "Left:\t#{left}\n    Right:\t#{right}")

          {:assertionFailed, %{index: index, message: message}}

        e ->
          message = failure_message(test_name, index, "Unknown exception: #{inspect(e)}")

          {:assertionFailed, %{index: index, message: message}}
      end
    end
  end

  defp failure_message(test_name, index, extra_data) do
    "❌ #{test_name} [#{index}]\n    #{extra_data}"
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
