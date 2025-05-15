defmodule Hexcall.CallPipeline do
  use Membrane.Pipeline
  # alias Membrane.{Tee, Funnel, PortAudio}
  alias Hexcall.CallSource
  alias Hexcall.CallSink

  @impl true
  def handle_init(_ctx, opts) do
    spec = [
      #
      # Collecting Mic Input
      #
      child(:webrtc_source, %Membrane.WebRTC.Source{signaling: opts[:ingress_signaling]})
      |> via_out(:output, options: [kind: :audio])
      |> child(:call_sink, %CallSink{roomname: opts[:roomname]}),
      #
      # Receiving Audio to output
      #
      child(:call_source, %CallSource{roomname: opts[:roomname]})
      |> child(:parse, %Membrane.Opus.Parser{
        delimitation: :keep,
        # This doesnt matter for now
        generate_best_effort_timestamps?: false
      })
      |> via_in(:input, options: [kind: :audio])
      |> child(:webrtc_sink, %Membrane.WebRTC.Sink{
        tracks: [:audio],
        signaling: opts[:egress_signaling]
      })
    ]

    {[spec: spec], %{}}
  end
end

# Safety local:
# child(:webrtc_source, %Membrane.WebRTC.Source{signaling: opts[:ingress_signaling]})
# |> via_out(:output, options: [kind: :audio])
# |> child(:to_raw, Membrane.Opus.Decoder)
# |> child(:pa_sink, PortAudio.Sink)

# Over connection:
# child(:webrtc_source, %Membrane.WebRTC.Source{signaling: opts[:ingress_signaling]})
# |> via_out(:output, options: [kind: :audio])
# |> child(:call_sink, %CallSink{receiver: Keyword.get(opts, :receiver, self())}),
#
# child(:call_source, %CallSource{register_name: Keyword.get(opts, :receiver, self())})
# |> child(:to_raw, Membrane.Opus.Decoder)
# |> child(:pa_sink, PortAudio.Sink)

# Encode from RawAudio to Opus
# child(:opus_encoder, %Membrane.Opus.Encoder{
#   application: :voip,
#   input_stream_format: %Membrane.RawAudio{
#     channels: 2,
#     sample_format: :s16le,
#     sample_rate: 48_000
#   }
# }),
