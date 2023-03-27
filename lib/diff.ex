defmodule Diff do
  def diff(left, right) do
    diff(left, right, %{enabled: true, diff_type: :cli})
  end

  def diff(left, right, %{diff_type: :cli} = config) do
    # %{enabled: true}
    Diff.Cli.diff(left, right, config)
  end

  def format_sides(left, right, formatter) do
    case format_diff(left, right, formatter) do
      {left, right} ->
        {IO.iodata_to_binary(left), IO.iodata_to_binary(right)}

      nil ->
        {left, right}
    end
  end

  defp format_diff(left, right, formatter) do
    if left && right && formatter.(:diff_enabled?, false) do
      if script = edit_script(left, right) do
        colorize_diff(script, formatter, {[], []})
      end
    end
  end

  defp colorize_diff(script, formatter, acc) when is_list(script) do
    Enum.reduce(script, acc, &colorize_diff(&1, formatter, &2))
  end

  defp colorize_diff({:eq, content}, _formatter, {left, right}) do
    {[left | content], [right | content]}
  end

  defp colorize_diff({:del, content}, formatter, {left, right}) do
    format = colorize_format(content, :diff_delete, :diff_delete_whitespace)
    {[left | formatter.(format, content)], right}
  end

  defp colorize_diff({:ins, content}, formatter, {left, right}) do
    format = colorize_format(content, :diff_insert, :diff_insert_whitespace)
    {left, [right | formatter.(format, content)]}
  end

  defp colorize_format(content, normal, whitespace) do
    if String.trim_leading(content) == "", do: whitespace, else: normal
  end

  defp edit_script(left, right) do
    task = Task.async(ExUnit.Diff, :script, [left, right])

    case Task.yield(task, 1500) || Task.shutdown(task, :brutal_kill) do
      {:ok, script} -> script
      nil -> nil
    end
  end
end
