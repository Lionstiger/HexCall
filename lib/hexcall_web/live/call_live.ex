defmodule HexcallWeb.CallLive do
  use HexcallWeb, :live_view
  require Logger

  alias Membrane.WebRTC.Live.{Capture, Player}

  @impl true
  def mount(%{"room" => room}, _session, socket) do
    socket =
      if connected?(socket) do
        ingress_signaling = Membrane.WebRTC.Signaling.new()
        egress_signaling = Membrane.WebRTC.Signaling.new()

        Membrane.Pipeline.start_link(Hexcall.CallPipeline,
          ingress_signaling: ingress_signaling,
          egress_signaling: egress_signaling,
          roomname: room
        )

        socket
        |> Capture.attach(
          id: "mediaCapture",
          signaling: ingress_signaling,
          video?: false,
          audio?: true,
          preview?: false
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

  # @impl true
  # def handle_event("webrtc_signaling", data, _socket) do
  #   IO.inspect(data)
  # end

  # TODO: Setup receiving streams from other. Somehow merge all incoming audio into single output
  # TODO: Push this stream back down to client via webrtc

  # TODO: Send Position updates to RoomManager

  @impl true
  def render(assigns) do
    ~H"""
    <h3>Captured stream preview</h3>
    <Capture.live_render socket={@socket} capture_id="mediaCapture" />
    <h3>Stream sent by the server</h3>
    <Player.live_render socket={@socket} player_id="audioPlayer" />

    <div x-data="{ muted: false,
                   muteUnmute() {
                     this.muted = !this.muted;
                     mediaCapture.srcObject.getAudioTracks().forEach(track => {
                       track.enabled = !this.muted;
                     });
                     console.log('Muted: ', this.muted);
                   }
                 }">
      <button
        id="muteButton"
        @click="muteUnmute()"
        x-text="muted ? 'Unmute' : 'Mute'"
        x-bind:class="{
           'bg-green-500 hover:bg-green-700': muted,
           'bg-red-500 hover:bg-red-700': !muted
         }"
        class="text-white font-bold py-2 px-4"
      >
      </button>
    </div>
    """
  end
end
