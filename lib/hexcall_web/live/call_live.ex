defmodule HexcallWeb.CallLive do
  use HexcallWeb, :live_view
  require Logger

  # alias Membrane.WebRTC.Live.{Capture, Player}
  alias HexcallWeb.Components.{Capture, Player, HexCell}
  alias Hexcall.{Hives, HiveManagerPresence, HexPos}

  @impl true
  def mount(%{"hive" => hivename}, _session, socket) do
    socket = stream(socket, :presences, [])
    hive = Hives.get_hive_by_name_with_hexes(hivename)

    # This needs to be replaced when Auth is added
    user_id = Ecto.UUID.generate()

    if is_nil(hive) do
      {:ok, redirect(socket, to: "/")}
    else
      socket =
        if connected?(socket) do
          HiveManagerPresence.track_user(socket.root_pid, hivename, user_id)
          HiveManagerPresence.subscribe(hivename)
          stream(socket, :presences, HiveManagerPresence.list_positions(hivename))

          ingress_signaling = Membrane.WebRTC.Signaling.new()
          egress_signaling = Membrane.WebRTC.Signaling.new()

          Membrane.Pipeline.start_link(Hexcall.CallPipeline,
            ingress_signaling: ingress_signaling,
            egress_signaling: egress_signaling,
            hivename: hivename
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
        else
          socket
        end

      {:ok,
       socket
       # |> stream(socket, :presences, HiveManagerPresence.list_positions(hivename))
       |> assign(:user_id, user_id)
       |> assign(:hive_name, hivename)
       |> assign(:hive, hive)}
    end
  end

  @impl true
  def handle_event("click", data, socket) do
    new_position = HexPos.new(data)
    user_id = socket.assigns.user_id
    hivename = socket.assigns.hive_name

    case HiveManagerPresence.move(socket.root_pid, hivename, user_id, new_position) do
      {:ok, new_pos = %HexPos{}} ->
        {:noreply, socket |> assign(:position, new_pos)}

      {:error, "position taken"} ->
        {:noreply, put_flash(socket, :error, "Position taken")}
    end
  end

  def handle_info({HiveManagerPresence, {:join, presence}}, socket) do
    {:noreply, stream_insert(socket, :presences, presence)}
  end

  def handle_info({HiveManagerPresence, {:leave, presence}}, socket) do
    if presence.metas == [] do
      {:noreply, stream_delete(socket, :presences, presence)}
    else
      {:noreply, stream_insert(socket, :presences, presence)}
    end
  end

  # TODO: Setup receiving streams from other. Somehow merge all incoming audio into single output
  # TODO: Push this stream back down to client via webrtc
end
