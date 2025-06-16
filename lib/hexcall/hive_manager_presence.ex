defmodule Hexcall.HiveManagerPresence do
  alias Hexcall.HexPos

  use Phoenix.Presence,
    otp_app: :hexcall,
    pubsub_server: Hexcall.PubSub

  # TODO build functions here for:
  # list users
  #
  def list_positions(hivename) do
    list(hivename) |> Enum.map(fn {_id, presence} -> presence end)
  end

  def track_user(pid, hivename, user_id) do
    track(pid, hivename, user_id, %{id: user_id, pos: %{q: -1, r: -1, s: -1}})
  end

  # @impl true
  # def handle_call({:move, user_id, new_position}, _from, state) do
  #   if map.has_key?(state, new_position) do
  #     {:reply, {:error, "position taken"}, state}
  #   else
  #     new_state =
  #       state
  #       |> Map.reject(fn {_key, value} -> value == user_id end)
  #       |> Map.put(new_position, user_id)

  #     # Send updates here
  #     {:reply, :ok, new_state}
  #   end
  # end
  def subscribe(topic), do: Phoenix.PubSub.subscribe(Hexcall.PubSub, "proxy:" <> topic)

  def move(pid, hive_name, user_id, new_position) do
    positions =
      list(hive_name)
      |> Map.values()
      |> Enum.flat_map(fn %{metas: metas} -> metas end)
      |> Enum.map(fn meta -> HexPos.new(meta[:pos]) end)

    new_position = HexPos.new(new_position)

    if Enum.member?(positions, new_position) do
      {:error, "position taken"}
    else
      update(pid, hive_name, user_id, %{id: user_id, pos: new_position})
      {:ok, new_position}
    end
  end

  def init(_opts) do
    {:ok, %{}}
  end

  def fetch(_topic, presences) do
    for {key, %{metas: [meta | metas]}} <- presences, into: %{} do
      {key, %{metas: [meta | metas], id: meta.id, user: %{name: meta.id}}}
    end
  end

  def handle_metas(topic, %{joins: joins, leaves: leaves}, presences, state) do
    for {user_id, presence} <- joins do
      user_data = %{id: user_id, user: presence.user, metas: Map.fetch!(presences, user_id)}
      msg = {__MODULE__, {:join, user_data}}
      Phoenix.PubSub.local_broadcast(Hexcall.PubSub, "proxy:#{topic}", msg)
    end

    for {user_id, presence} <- leaves do
      metas =
        case Map.fetch(presences, user_id) do
          {:ok, presence_metas} -> presence_metas
          :error -> []
        end

      user_data = %{id: user_id, user: presence.user, metas: metas}
      msg = {__MODULE__, {:leave, user_data}}
      Phoenix.PubSub.local_broadcast(Hexcall.PubSub, "proxy:#{topic}", msg)
    end

    {:ok, state}
  end
end
