defmodule Hexcall.Hexes do
  alias Hexcall.Hives.Hex
  alias Hexcall.Repo
  import Ecto.Query

  @doc """
  Returns the Ecto.Query to load a Hex.
  Calculates the s coordinate which is not persisted.
  Discards some fields we dont need.

  ## Examples

      iex> load_query()
      #Ecto.Query
      <from h0 in Hexcall.Hives.Hex, select:
        %Hexcall.Hives.Hex{
          id: h0.id,
          q: h0.q,
          r: h0.r,
          s: fragment("-? - ?", h0.q, h0.r),
          type: h0.type
        }
      >
  """
  def load_all_query() do
    from h in Hex,
      select: %Hex{
        id: h.id,
        q: h.q,
        r: h.r,
        s: fragment("-? - ?", h.q, h.r),
        type: h.type
      }
  end

  def load_all_query_for_hive(hive_id) do
    from h in Hex,
      where: h.hive_id == ^hive_id,
      select: %Hex{
        id: h.id,
        q: h.q,
        r: h.r,
        s: fragment("-? - ?", h.q, h.r),
        type: h.type
      }
  end

  def load_hexes_for_hive(hivename) do
    Repo.all(load_all_query_for_hive(hivename))
  end

  @doc """
  Creates a Hex.

  ## Examples

      iex> create_hex(%{field: value})
      {:ok, %Hive{}}

      iex> create_hex(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_hex(attrs \\ %{}) do
    %Hex{}
    |> Hex.changeset(attrs)
    |> Repo.insert()
  end

  def create_hex_from_list(list) do
    current_time = DateTime.utc_now(:second)

    new_list =
      Enum.map(list, fn hex ->
        hex
        |> Map.put(:inserted_at, current_time)
        |> Map.put(:updated_at, current_time)
      end)

    Repo.insert_all(Hex, new_list)
  end
end
