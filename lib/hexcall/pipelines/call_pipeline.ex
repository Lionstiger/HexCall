defmodule Hexcall.Pipelines.CallPipeline do
  alias Hexcall.HexPos
  use Membrane.Pipeline
  # alias Membrane.{Tee, Funnel, PortAudio}
  alias Hexcall.Pipelines.CallSource
  alias Hexcall.Pipelines.CallSink

  @impl true
  def handle_init(_ctx, opts) do
    spec = [
      #
      # Collecting Mic Input
      #
      child(:webrtc_source, %Membrane.WebRTC.Source{signaling: opts[:ingress_signaling]})
      |> via_out(:output, options: [kind: :audio])
      |> child(:call_sink, %CallSink{hivename: opts[:hivename], listeners: []}),
      #
      # Receiving Audio to output
      #
      child(:call_source, %CallSource{hivename: opts[:hivename], position: opts[:start_position]})
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

    {[spec: spec], %{listeners: []}}
  end

  @impl true
  def handle_call({:new_position, %HexPos{} = new_position}, _ctx, state) do
    # TODO change this later to account for meetings and set hexes.
    new_listeners = HexPos.get_neighbors(new_position)

    {[
       {:reply, :ok},
       {:notify_child, {:call_source, {:update_position, new_position}}},
       {:notify_child, {:call_sink, {:update_listeners, new_listeners}}}
     ], state}
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
