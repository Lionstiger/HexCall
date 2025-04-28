defmodule HexcallWeb.CallLive do
  use HexcallWeb, :live_view
  require Logger

  alias Membrane.WebRTC.Live.{Capture, Player}


  @impl true
  def mount(_params, _session, socket) do
    # if connected?(socket) do
    # TODO: setup webrtc connection (both ways) here
    # TODO: sign up to room position topic
    # else
    # {:ok, socket}
    # end

    socket =
      if connected?(socket) do
        ingress_signaling = Membrane.WebRTC.Signaling.new()
        egress_signaling = Membrane.WebRTC.Signaling.new()

        Membrane.Pipeline.start_link(Hexcall.CallPipeline,
          ingress_signaling: ingress_signaling,
          egress_signaling: egress_signaling
        )

        socket
        |> Capture.attach(
          id: "mediaCapture",
          signaling: ingress_signaling,
          video?: false,
          audio?: true
        )
        |> Player.attach(
          id: "audioPlayer",
          signaling: egress_signaling
        )
      else
        socket
      end

    {:ok, socket}

  end

  # TODO: setup pipeline to parse uploaded audio

  # TODO: Setup receiving streams from other. Somehow merge all incoming audio into single output
  # TODO: Push this stream back down to client via webrtc

  # TODO: Use pubsub to handle who audio is send to and who audio is received from

  # TODO: Send Position updates to RoomManager

  # @impl true
  # def render(assigns) do
  #   ~H"""
  #   <div class="call-container">
  #     <div id="audio-controls" phx-hook="AudioCall" class="p-4">
  #       <button id="toggle-audio" class="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600">
  #         Start Microphone
  #       </button>
  #       <div class="mt-2 text-sm text-gray-600">
  #         Click the button above to start/stop your microphone
  #       </div>
  #     </div>
  #   </div>
  #   """
  # end

  @impl true
  def render(assigns) do
    ~H"""
    <h3>Captured stream preview</h3>
    <Capture.live_render socket={@socket} capture_id="mediaCapture" />
    <h3>Stream sent by the server</h3>
    <Player.live_render socket={@socket} player_id="audioPlayer" />
    """
  end
end
