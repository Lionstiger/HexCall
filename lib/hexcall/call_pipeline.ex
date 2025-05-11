defmodule Hexcall.CallPipeline do
  use Membrane.Pipeline
  alias Membrane.{Tee, Funnel}
  # use Membrane.ChildrenSpec
  alias Hexcall.CallSource
  alias Hexcall.CallSink

  @impl true
  def handle_init(_ctx, opts) do
    spec = [
      #
      # Define Elements
      #
      child(:webrtc_source, %Membrane.WebRTC.Source{signaling: opts[:ingress_signaling]}),
      child(:webrtc_sink, %Membrane.WebRTC.Sink{
        tracks: [:audio],
        signaling: opts[:egress_signaling]
      }),
      child(:opus_decoder, Membrane.Opus.Decoder),
      child(:opus_encoder, Membrane.Opus.Encoder),
      # child(:opus_decoder_2, Membrane.Opus.Decoder),
      # child(:opus_encoder_2, Membrane.Opus.Encoder),
      # child(:split, Tee.Parallel),
      # child(:funnel, Funnel),
      # child(:call_source, %CallSource{register_name: Keyword.get(opts, :receiver, self())}),
      # child(:call_sink, %CallSink{receiver: Keyword.get(opts, :receiver, self())}),
      #
      # Connect Elements
      #
      get_child(:webrtc_source)
      |> via_out(:output, options: [kind: :audio])
      |> get_child(:opus_decoder)
      |> get_child(:opus_encoder)
      |> via_in(:input, options: [kind: :audio])
      |> get_child(:webrtc_sink)
      # |> child(%Membrane.File.Sink{location: "/tmp/example.exs"})
      # |> get_child(:call_sink),
      # |> get_child(:split),
      # get_child(:split)

      # get_child(:split)
      # |> get_child(:webrtc_sink)
      # get_child(:split)
      # |> get_child(:opus_decoder_2)
      # |> get_child(:opus_encoder_2)
      # |> via_in(:input, options: [kind: :audio])
      # |> get_child(:webrtc_sink)

      # get_child(:call_source)
      # |> get_child(:opus_decoder_2)
      # |> get_child(:opus_encoder_2)
      # |> via_in(:input, options: [kind: :audio])
      # |> get_child(:webrtc_sink)
    ]

    {[spec: spec], %{}}
  end
end
