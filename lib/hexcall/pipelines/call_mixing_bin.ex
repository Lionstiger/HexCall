defmodule Hexcall.Pipelines.CallMixingBin do
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
           |> via_in(:input, options: [live?: true])
           |> get_child(:mixer)
         end)}
      ]

    remove_specs =
      [{:remove_children, Enum.map(hexes_to_remove, fn hex -> {:source_bin, "#{hex}"} end)}]

    {remove_specs ++ add_specs, state |> Map.put(:position, new_position)}
  end
end
