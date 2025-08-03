defmodule Hexcall.Pipelines.CallSourceBin do
  @moduledoc """
  Membrane bin module for handling audio source processing from a specific hex position.

  This module encapsulates the complete audio processing chain for a single hex position,
  including receiving Opus-encoded audio, decoding it, and parsing it into raw audio format.
  It acts as a wrapper around `CallSourceInput` and manages the audio decoding pipeline.
  """

  alias Hexcall.Pipelines.CallSourceInput
  use Membrane.Bin

  @raw_format %Membrane.RawAudio{
    channels: 1,
    sample_rate: 48_000,
    sample_format: :s16le
  }
  def_options(
    hivename: [
      description: "Name of the Hive we subscribe to, to receive buffers from",
      spec: String.t()
    ],
    position: [
      description: "Current Position to listen at",
      spec: HexPos
    ]
  )

  def_output_pad(:output,
    accepted_format: @raw_format,
    availability: :always
  )

  @impl true
  @doc """
  Initializes the source bin with a complete audio processing pipeline.

  Sets up the pipeline specification connecting:
  - CallSourceInput to receive audio buffers from Phoenix channels
  - Opus decoder to decode incoming Opus-encoded audio
  - Raw audio parser to convert decoded audio to the expected format

  ## Parameters
  - `_ctx`: Bin context (unused)
  - `opts`: Options containing hivename and position for channel topic creation

  ## Returns
  - Pipeline specification connecting all child components
  - Empty state map
  """
  def handle_init(_ctx, opts) do
    source_topic = "audio:#{opts.hivename}:#{opts.position}"

    spec = [
      child(%CallSourceInput{source_topic: source_topic})
      |> child(%Membrane.Opus.Decoder{sample_rate: @raw_format.sample_rate})
      |> child(%Membrane.RawAudioParser{stream_format: @raw_format, overwrite_pts?: true})
      |> bin_output(:output)
    ]

    {[spec: spec], %{}}
  end
end
