defmodule Hexcall.Hive.PresenceManager do
  alias Hexcall.HexPos

  use Phoenix.Presence,
    otp_app: :hexcall,
    pubsub_server: Hexcall.PubSub

  def list_positions(hivename) do
    for {_user_id, presence} <- list(hivename) do
      msg = {__MODULE__, {:join, presence}}
      Phoenix.PubSub.local_broadcast(Hexcall.PubSub, "proxy:#{hivename}", msg)
    end

    {:ok}
  end

  def track_user(pid, hivename, user_id) do
    track(pid, hivename, user_id, %{id: user_id, pos: %{q: -1, r: -1, s: -1}})
  end

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
      {key, %{metas: [meta | metas], id: meta.id, user: %{name: meta.id}, pos: meta.pos}}
    end
  end

  def handle_metas(topic, %{joins: joins, leaves: leaves}, presences, state) do
    for {user_id, presence} <- joins do
      msg = {__MODULE__, {:join, presence}}
      Phoenix.PubSub.local_broadcast(Hexcall.PubSub, "proxy:#{topic}", msg)
    end

    for {user_id, presence} <- leaves do
      metas =
        case Map.fetch(presences, user_id) do
          {:ok, presence_metas} -> presence_metas
          :error -> []
        end

      # user_data = %{id: user_id, user: presence.user, metas: metas}
      msg = {__MODULE__, {:leave, presence}}
      Phoenix.PubSub.local_broadcast(Hexcall.PubSub, "proxy:#{topic}", msg)
    end

    {:ok, state}
  end
end
