defmodule Hexcall.Hives do
  @moduledoc """
  The Hives context.
  """

  import Ecto.Query, warn: false
  alias Hexcall.Hexes
  alias Hexcall.Repo

  alias Hexcall.Hives.Hive

  @doc """
  Returns the list of hives.

  ## Examples

      iex> list_hives()
      [%Hive{}, ...]

  """
  def list_hives do
    Repo.all(Hive)
    |> Repo.preload(hexes: Hexes.load_all_query())
  end

  @doc """
  Gets a single hive.

  Raises `Ecto.NoResultsError` if the Hive does not exist.

  ## Examples

      iex> get_hive!(123)
      %Hive{}

      iex> get_hive!(456)
      ** (Ecto.NoResultsError)

  """
  def get_hive!(id), do: Repo.get!(Hive, id)

  @doc """
  Gets a single hive by its name.

  Raises `Ecto.NoResultsError` if the Hive does not exist.

  ## Examples

      iex> get_hive_by_name!(breadsticks)
      %Hive{}

      iex> get_hive_by_name!(456)
      ** (Ecto.NoResultsError)

  """
  def get_hive_by_name(name) when is_bitstring(name) do
    Repo.get_by(Hive, name: name)
  end

  @doc """
  Creates a hive.

  ## Examples

      iex> create_hive(%{field: value})
      {:ok, %Hive{}}

      iex> create_hive(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_hive(attrs \\ %{}) do
    %Hive{}
    |> Hive.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a hive.

  ## Examples

      iex> update_hive(hive, %{field: new_value})
      {:ok, %Hive{}}

      iex> update_hive(hive, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_hive(%Hive{} = hive, attrs) do
    hive
    |> Hive.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a hive.

  ## Examples

      iex> delete_hive(hive)
      {:ok, %Hive{}}

      iex> delete_hive(hive)
      {:error, %Ecto.Changeset{}}

  """
  def delete_hive(%Hive{} = hive) do
    Repo.delete(hive)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking hive changes.

  ## Examples

      iex> change_hive(hive)
      %Ecto.Changeset{data: %Hive{}}

  """
  def change_hive(%Hive{} = hive, attrs \\ %{}) do
    Hive.changeset(hive, attrs)
  end
end
