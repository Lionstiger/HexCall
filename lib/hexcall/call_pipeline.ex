defmodule Hexcall.CallPipeline do
  use Membrane.Pipeline

  alias Membrane.WebRTC

  @impl true
  def handle_init(_ctx, opts) do
    spec =
      [
        child(:webrtc, %WebRTC.Source{
          signaling: {
            :whip,
            token: "whip_it!", # TODO: Set actual token here
            port: opts[:port],
            ip: :any,
            # serve_static: "#{__DIR__}/assets/browser_to_file"
          },
          depayload_rtp: true
        }),

        get_child(:webrtc)
        |> via_out(:output, options: [kind: :audio])
        |> child(:parser, Membrane.Opus.Parser)
        |> child(:ogg, Membrane.Ogg.Muxer)
        |> child(:sink, %Membrane.File.Sink{location: "recording.opus"})

      ]

    {[spec: spec], %{}}
  end

  @impl true
  def handle_element_end_of_stream(:sink, :input, _ctx, state) do
    {[terminate: :normal], state}
  end

  @impl true
  def handle_element_end_of_stream(_element, _pad, _ctx, state) do
    {[], state}
  end
end
