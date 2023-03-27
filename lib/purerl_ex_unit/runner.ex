defmodule PurerlExUnit.Runner do
  @moduledoc """
  Runs assertions in real time from PureScript tests.
  """

  use GenServer

  require ExUnit.Assertions, as: Assertions

  def start_link(_arguments) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def execute(test_name, assertion) do
    GenServer.call(
      __MODULE__,
      {:execute, %{test_name: test_name, assertion: assertion}}
    )
  end

  def init(:ok) do
    Application.ensure_started(:ex_unit)

    {:ok, %{}}
  end

  def handle_call({:execute, %{test_name: test_name, assertion: {:assert, true}}}, _from, state) do
    IO.puts("  ✅ #{test_name}")

    {:reply, :ok, state}
  end

  def handle_call({:execute, %{test_name: test_name, assertion: {:assert, false}}}, _from, state) do
    IO.puts("  ❌ #{test_name}")

    {:reply, :error, state}
  end

  def handle_call(
        {:execute,
         %{test_name: test_name, assertion: {:assertEqual, %{left: left, right: right}}}},
        _from,
        state
      ) do
    if left == right do
      IO.puts("  ✅ #{test_name}")

      {:reply, :ok, state}
    else
      IO.puts("  ❌ #{test_name}")

      try do
        Assertions.assert(left == right)
      rescue
        e in ExUnit.AssertionError ->
          IO.puts("    #{e.message}")

          %{left: left, right: right} =
            e
            |> ExUnit.Formatter.format_assertion_diff(0, 80, &formatter/2)
            |> Enum.map(fn {key, value} ->
              {key, Enum.join(value)}
            end)
            |> Enum.into(%{})

          IO.puts("    Left:\t#{left}\n    Right:\t#{right}")

          {:reply, :error, state}

        e ->
          IO.puts("    #{inspect(e)}")
          {:reply, :error, state}
      end
    end
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
