defmodule PurerlTest.Assertion do
  require ExUnit.Assertions, as: Assertions

  def execute({:assert, true}, _index), do: {:assertionPassed}

  def execute({:assert, false}, index) do
    {:assertionFailed, %{index: index, message: "  ❌ [#{index}]"}}
  end

  def execute({:refute, false}, _index), do: {:assertionPassed}

  def execute({:refute, true}, index) do
    {:assertionFailed, %{index: index, message: "  ❌ [#{index}]"}}
  end

  def execute({:assertEqual, %{left: left, right: right}}, index) do
    run_assertion(fn -> Assertions.assert(left == right) end, index, right)
  end

  def execute({:assertNotEqual, %{left: left, right: right}}, index) do
    run_assertion(fn -> Assertions.assert(left != right) end, index, right)
  end

  def execute({:assertGreaterThan, %{left: left, right: right}}, index) do
    run_assertion(fn -> Assertions.assert(left > right) end, index, right)
  end

  def execute({:assertLessThan, %{left: left, right: right}}, index) do
    run_assertion(fn -> Assertions.assert(left < right) end, index, right)
  end

  def execute({:assertGreaterThanOrEqual, %{left: left, right: right}}, index) do
    run_assertion(fn -> Assertions.assert(left >= right) end, index, right)
  end

  def execute({:assertLessThanOrEqual, %{left: left, right: right}}, index) do
    run_assertion(fn -> Assertions.assert(left <= right) end, index, right)
  end

  defp run_assertion(assertion_closure, index, right_value) do
    try do
      assertion_closure.()

      {:assertionPassed}
    rescue
      e in ExUnit.AssertionError ->
        e
        |> ExUnit.Formatter.format_assertion_diff(0, 80, &formatter/2)
        |> Enum.map(fn {key, value} -> {key, Enum.join(value)} end)
        |> Enum.into(%{})
        |> case do
          %{left: left, right: right} ->
            message =
              failure_message(index, "#{e.message}:\n    Left:\t#{left}\n    Right:\t#{right}")

            {:assertionFailed, %{index: index, message: message}}

          # This seems to only happen when we have only one value, i.e. they are equal
          %{left: left} ->
            message =
              failure_message(
                index,
                "#{e.message}:\n    #{left} == #{right_value}"
              )

            {:assertionFailed, %{index: index, message: message}}
        end

      e ->
        message = failure_message(index, "Unknown exception: #{inspect(e)}")

        {:assertionFailed, %{index: index, message: message}}
    end
  end

  defp failure_message(index, extra_data), do: "❌ [#{index}]\n    #{extra_data}"

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
