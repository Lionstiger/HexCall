defmodule Hexcall.HexPos do
  alias Hexcall.HexPos
  defstruct [:q, :r, :s]

  def new(%{"q" => q_str, "r" => r_str, "s" => s_str} = _map)
      when is_binary(q_str) and is_binary(r_str) and is_binary(s_str) do
    case {Integer.parse(q_str), Integer.parse(r_str), Integer.parse(s_str)} do
      {{q_int, ""}, {r_int, ""}, {s_int, ""}} ->
        %HexPos{q: q_int, r: r_int, s: s_int}

      _ ->
        {:error, :invalid_format}
    end
  end

  def new(%HexPos{} = map) do
    map
  end

  def new(%{:q => q, :r => r, :s => s} = _map)
      when is_integer(q) and is_integer(r) and is_integer(s) do
    %HexPos{q: q, r: r, s: s}
  end

  def new(q, r, s) when is_integer(q) and is_integer(r) and is_integer(s) do
    %HexPos{q: q, r: r, s: s}
  end

  def get_neighbors(%HexPos{} = hex) do
    Enum.map(0..5, fn x -> neighbour(hex, x) end)
  end

  defp neighbour(hex, dir) do
    add(hex, direction(dir))
  end

  defp add(first, second) do
    HexPos.new(first.q + second.q, first.r + second.r, first.s + second.s)
  end

  defp direction(dir) do
    case dir do
      0 -> HexPos.new(+1, -1, 0)
      1 -> HexPos.new(+1, 0, -1)
      2 -> HexPos.new(0, +1, -1)
      3 -> HexPos.new(-1, +1, 0)
      4 -> HexPos.new(-1, 0, +1)
      5 -> HexPos.new(0, -1, +1)
      _ -> :error
    end
  end
end

defimpl String.Chars, for: Hexcall.HexPos do
  def to_string(%Hexcall.HexPos{q: q, r: r, s: s}) do
    "hex.#{Integer.to_string(q)}.#{Integer.to_string(r)}.#{Integer.to_string(s)}"
  end
end
