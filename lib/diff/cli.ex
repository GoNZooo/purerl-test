defmodule Diff.Cli do
  def diff(left, right, config) do
    formatter = &formatter(&1, &2, config)
    Diff.format_sides(left, right, formatter)
  end

  defp formatter(:diff_enabled?, _, %{enabled: enabled}), do: enabled

  defp formatter(:diff_delete, msg, config), do: colorize(:red, msg, config)

  defp formatter(:diff_delete_whitespace, msg, config),
    do: colorize(IO.ANSI.color_background(2, 0, 0), msg, config)

  defp formatter(:diff_insert, msg, config), do: colorize(:green, msg, config)

  defp formatter(:diff_insert_whitespace, msg, config),
    do: colorize(IO.ANSI.color_background(0, 2, 0), msg, config)

  defp formatter(_, msg, _config), do: msg

  defp colorize(escape, string, %{enabled: enabled}) do
    if enabled do
      [escape, string, :reset]
      |> IO.ANSI.format_fragment(true)
      |> IO.iodata_to_binary()
    else
      string
    end
  end
end
