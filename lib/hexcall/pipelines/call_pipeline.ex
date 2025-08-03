defmodule Hexcall.Pipelines.CallPipeline do
  @moduledoc """
  Main pipeline module for HexCall audio processing.

  This module orchestrates the complete audio flow for a HexCall session, handling both
  incoming audio from WebRTC sources and outgoing mixed audio to WebRTC sinks. It connects
  microphone input to a call sink and manages audio mixing from neighboring hex positions
  in the hive.

  The pipeline supports dynamic position updates through the `new_position` call, which
  notifies child components to adjust their audio routing accordingly.
  """
  alias Hexcall.Pipelines.{CallSink, CallMixingBin}
  alias Hexcall.HexPos
  use Membrane.Pipeline

  @impl true
  @doc """
  Initializes the call pipeline with WebRTC source and sink components.

  Sets up the pipeline specification connecting:
  - WebRTC source to CallSink for audio input collection
  - CallMixingBin to WebRTC sink for mixed audio output

  ## Parameters
  - `_ctx`: Pipeline context (unused)
  - `opts`: Options containing ingress_signaling, egress_signaling, hivename, and start_position
  """
  def handle_init(_ctx, opts) do
    spec = [
      #
      # Collecting Mic Input
      #
      child(:webrtc_source, %Membrane.WebRTC.Source{signaling: opts[:ingress_signaling]})
      |> via_out(:output, options: [kind: :audio])
      |> child(:call_sink, %CallSink{hivename: opts[:hivename], position: opts[:start_position]}),
      #
      # Receiving Audio to output
      #
      child(:call_mixing_bin, %CallMixingBin{
        hivename: opts[:hivename],
        position: opts[:start_position]
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
  @doc """
  Handles position updates by notifying child components.

  When a new position is received, this function propagates the update to both
  the call mixing bin and call sink components so they can adjust their subscriptions
  and broadcasting targets accordingly.

  ## Parameters
  - `{:new_position, new_position}`: The new hex position to update to
  - `_ctx`: Call context (unused)
  - `state`: Current pipeline state

  ## Returns
  - `{:reply, :ok}`: Indicates successful handling
  - Notifications to child components to update their positions
  """
  def handle_call({:new_position, %HexPos{} = new_position}, _ctx, state) do
    # TODO change this later to account for meetings and set hexes.

    {[
       {:reply, :ok},
       {:notify_child, {:call_mixing_bin, {:update_position, new_position}}},
       {:notify_child, {:call_sink, {:update_position, new_position}}}
     ], state}
  end
end

# Debug Filter to view data as it flows through the pipeline:
# |> child(%Membrane.Debug.Filter{
#   handle_buffer: fn buffer ->
#     IO.puts("#{System.os_time(:millisecond)}")
#     IO.inspect(buffer, label: "after mixer:")
#   end
# })

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
