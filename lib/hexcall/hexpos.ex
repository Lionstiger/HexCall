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

  def new(%{:q => q, :r => r, :s => s} = _map)
      when is_integer(q) and is_integer(r) and is_integer(s) do
    %HexPos{q: q, r: r, s: s}
  end

  def new(%HexPos{} = map) do
    map
  end
end
