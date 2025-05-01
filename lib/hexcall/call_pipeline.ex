defmodule Hexcall.CallPipeline do
  use Membrane.Pipeline

  @impl true
  def handle_init(_ctx, opts) do
    spec =
      child(:webrtc_source, %Membrane.WebRTC.Source{
        # allowed_video_codecs: [],
        signaling: opts[:ingress_signaling]
      })
      |> via_out(:output, options: [kind: :audio])
      |> child(:opus_decoder, Membrane.Opus.Decoder)
      |> child(:opus_encoder, Membrane.Opus.Encoder)
      |> via_in(:input, options: [kind: :audio])
      |> child(:webrtc_sink, %Membrane.WebRTC.Sink{
        # video_codec: [],
        tracks: [:audio],
        signaling: opts[:egress_signaling]
      })
    {[spec: spec], %{}}
  end

end
      # |> via_in(:input, options: [kind: :audio])
      # |> via_out(:output, options: [kind: :audio])
