defmodule HexcallWeb.CallLive do
  alias Hexcall.Hexes
  use HexcallWeb, :live_view
  require Logger

  alias HexcallWeb.Components.{Capture, Player, HexCell}
  alias Hexcall.{Hives, HiveManagerPresence, HexPos}

  @impl true
  def mount(%{"hive" => hivename}, _session, socket) do
    # hive = Hives.get_hive_by_name_with_hexes(hivename)
    hive = Hives.get_hive_by_name(hivename)
    hexes = Hexes.load_hexes_for_hive(hive.id)
    # IO.inspect(hexes)

    # This needs to be replaced when Auth is added
    user_id = Ecto.UUID.generate()

    if is_nil(hive) do
      {:ok, redirect(socket, to: "/")}
    else
      socket =
        if connected?(socket) do
          HiveManagerPresence.track_user(socket.root_pid, hivename, user_id)
          HiveManagerPresence.subscribe(hivename)
          HiveManagerPresence.list_positions(hivename)

          ingress_signaling = Membrane.WebRTC.Signaling.new()
          egress_signaling = Membrane.WebRTC.Signaling.new()

          {:ok, _, pid} =
            Membrane.Pipeline.start_link(Hexcall.CallPipeline,
              ingress_signaling: ingress_signaling,
              egress_signaling: egress_signaling,
              hivename: hivename,
              start_position: HexPos.new(-1, -1, -1)
            )

          socket
          |> Capture.attach(
            id: "mediaCapture",
            signaling: ingress_signaling
          )
          |> Player.attach(
            id: "audioPlayer",
            signaling: egress_signaling
          )
          |> assign(:position, %HexPos{q: -1, r: -1, s: -1})
          |> assign(:pipeline, pid)
        else
          socket
        end

      {:ok,
       socket
       |> assign(:user_id, user_id)
       |> assign(:hive_name, hivename)
       |> assign(:hexes, hexes)
       |> assign(:hive, hive), layout: false}
    end
  end

  # Presence Logic

  @impl true
  def handle_event("click", data, socket) do
    new_position = HexPos.new(data)
    user_id = socket.assigns.user_id
    hivename = socket.assigns.hive_name

    case HiveManagerPresence.move(socket.root_pid, hivename, user_id, new_position) do
      {:ok, new_pos = %HexPos{}} ->
        # update pipeline here
        Membrane.Pipeline.call(socket.assigns.pipeline, {:new_position, new_pos})

        {:noreply, socket |> assign(:position, new_pos)}

      {:error, "position taken"} ->
        {:noreply, put_flash(socket, :error, "Position taken")}
    end
  end

  @impl true
  def handle_info({HiveManagerPresence, {:join, presence}}, socket) do
    hex_name = to_string(HexPos.new(presence.pos))
    {:noreply, push_event(socket, "update_hex@" <> hex_name, %{user: presence.user})}
    # {:noreply, stream_insert(socket, :presences, presence)}
  end

  @impl true
  def handle_info({HiveManagerPresence, {:leave, presence}}, socket) do
    hex_name = to_string(HexPos.new(presence.pos))
    {:noreply, push_event(socket, "clear_hex@" <> hex_name, %{})}

    # if presence.metas == [] do
    # {:noreply, stream_delete(socket, :presences, presence)}
    # else
    # {:noreply, stream_insert(socket, :presences, presence)}
    # end
  end
end
