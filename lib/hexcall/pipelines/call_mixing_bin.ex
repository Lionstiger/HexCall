defmodule Hexcall.Pipelines.CallMixingBin do
  @moduledoc """
  Membrane bin module for mixing audio from neighboring hex positions.

  This module manages audio mixing by subscribing to neighboring hex positions
  in the hive and combining their audio streams. It uses a live audio mixer
  to process multiple audio sources and converts the mixed output to Opus format
  for transmission.

  Supports dynamic position updates by adding/removing source bins for neighbors
  as the position changes.
  """

  alias Hexcall.Pipelines.CallSourceBin
  alias Hexcall.HexPos
  use Membrane.Bin

  @raw_format %Membrane.RawAudio{
    channels: 1,
    sample_rate: 48_000,
    sample_format: :s16le
  }

  def_output_pad(:output,
    accepted_format: _any,
    availability: :always
  )

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

  @impl true
  @doc """
  Initializes the mixing bin with audio mixer, Opus encoder, and parser components.

  Sets up the pipeline specification connecting:
  - LiveAudioMixer to combine multiple audio sources
  - Opus encoder to encode mixed audio for transmission
  - Opus parser to handle packet delimitation and timestamps

  ## Parameters
  - `_ctx`: Bin context (unused)
  - `opts`: Options containing hivename and position

  ## Returns
  - Pipeline specification
  - State with hivename and position
  """
  def handle_init(_ctx, opts) do
    spec =
      [
        child(:mixer, %Membrane.LiveAudioMixer{
          stream_format: @raw_format
        })
        |> child(:to_opus, %Membrane.Opus.Encoder{
          application: :voip,
          input_stream_format: @raw_format
        })
        |> child(:parse, %Membrane.Opus.Parser{
          delimitation: :keep,
          generate_best_effort_timestamps?: true
        })
        |> bin_output(:output)
      ]

    {[spec: spec], %{hivename: opts.hivename, position: opts.position}}
  end

  @impl true
  @doc """
  Handles position updates by dynamically adding/removing source bins for neighbors.

  Calculates the difference between current and new neighbor positions, then:
  - Removes source bins for positions no longer in range
  - Adds source bins for new positions in range

  ## Parameters
  - `{:update_position, new_position}`: The new hex position to update to
  - `_context`: Context information (unused)
  - `state`: Current bin state containing hivename and position

  ## Returns
  - Specification updates for adding and removing child source bins
  - Updated state with new position
  """
  def handle_parent_notification({:update_position, new_position}, _context, state) do
    current_neighbors =
      if state.position == %HexPos{q: -1, r: -1, s: -1} do
        %MapSet{}
      else
        MapSet.new(HexPos.get_neighbors(state.position))
      end

    new_neighbors = MapSet.new(HexPos.get_neighbors(new_position))
    hexes_to_remove = MapSet.difference(current_neighbors, new_neighbors)

    hexes_to_add =
      MapSet.difference(new_neighbors, MapSet.intersection(current_neighbors, new_neighbors))

    add_specs =
      [
        {:spec,
         Enum.map(hexes_to_add, fn hex ->
           child({:source_bin, "#{hex}"}, %CallSourceBin{hivename: state.hivename, position: hex})
           |> via_in(:input, options: [offset: :live])
           |> get_child(:mixer)
         end)}
      ]

    remove_specs =
      [{:remove_children, Enum.map(hexes_to_remove, fn hex -> {:source_bin, "#{hex}"} end)}]

    {remove_specs ++ add_specs, state |> Map.put(:position, new_position)}
  end
end
