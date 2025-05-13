defmodule Hexcall.CallSource do
  alias Membrane.Opus
  use Membrane.Source

  require Membrane.Logger

  def_output_pad(:output,
    flow_control: :push,
    accepted_format: _any
  )

  def_options(
    register_name: [
      description: "The name under which the element's process will be registered",
      spec: atom()
    ]
  )

  @impl true
  def handle_init(_ctx, opts) do
    Process.register(self(), opts.register_name)
    {[], %{buffered: []}}
  end

  @impl true
  def handle_playing(_ctx, state) do
    {actions, state} = send_buffers(state)

    {[stream_format: {:output, %Membrane.RemoteStream{content_format: Opus, type: :packetized}}] ++
       actions, state}

    # {[stream_format: {:output, %Membrane.RemoteStream{type: :bytestream}}] ++ actions, state}
  end

  @impl true
  def handle_info({:message, _source, message}, ctx, state) do
    state = %{state | buffered: state.buffered ++ [message]}

    if ctx.playback == :playing do
      send_buffers(state)
    else
      {[], state}
    end
  end

  @impl true
  def handle_info(msg, _ctx, state) do
    Membrane.Logger.warning("Unknown message received: #{inspect(msg)}")
    {[], state}
  end

  defp send_buffers(state) do
    actions =
      Enum.map(state.buffered, fn message ->
        {:buffer, {:output, message}}
      end)

    {actions, %{state | buffered: []}}
  end
end
