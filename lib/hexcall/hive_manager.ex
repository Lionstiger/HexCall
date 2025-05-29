defmodule Hexcall.HiveManager do
  use GenServer

  @moduledoc """
  Holds all current users in a hive and their position.
  """

  # Client Functions

  @doc """
  Start a hive and return its pid.
  If it already exists, the pid is still returned.
  """
  def start(hivename) when is_bitstring(hivename) do
    case DynamicSupervisor.start_child(
           {:via, PartitionSupervisor, {Hexcall.DynamicSupervisors, self()}},
           {Hexcall.HiveManager, hivename}
         ) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
      any -> any
    end
  end

  @doc """
  Start a hive directly.
  Returns a result tuple: {:ok , <pid>}
  """
  def start_link(state \\ [], hivename) when is_bitstring(hivename) do
    GenServer.start_link(__MODULE__, state, name: {:global, hivename})
  end

  @doc """
  Retrieve the current hive state.
  Returns a map with the current users and their positions.
  """
  def get_state(pid) do
    GenServer.call(pid, :get_state)
  end

  @doc """
  Moves the user to the hex
  """
  def move(pid, user_id, new_position) do
    GenServer.call(pid, {:move, user_id, new_position})
  end

  @doc """
  Removes the user from the hive.
  """
  def leave(pid, user_id) do
    GenServer.cast(pid, {:leave, user_id})
  end

  # Callback

  @impl true
  def init(_) do
    initial_state = %{}
    {:ok, initial_state}
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call({:move, user_id, new_position}, _from, state) do
    if Map.has_key?(state, new_position) do
      {:reply, {:error, "position taken"}, state}
    else
      new_state =
        state
        |> Map.reject(fn {_key, value} -> value == user_id end)
        |> Map.put(new_position, user_id)

      # Send updates here
      {:reply, :ok, new_state}
    end
  end

  @impl true
  def handle_cast({:leave, user_id}, state) do
    new_state = Map.reject(state, fn {_key, value} -> value == user_id end)
    {:noreply, new_state}
  end

  # TODO: receive and dispend position updates via pubsub topics
end
