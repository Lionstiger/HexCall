defmodule HexcallWeb.Components.HexCell do
  use Phoenix.Component

  # Define base hexagon dimensions (should match CSS)
  @hex_width 200.0
  @hex_height 230.94
  # Adjust these based on your desired spacing and overlap for the hex grid layout
  # Horizontal distance between hex centers in the same row
  # @hex_horizontal_spacing @hex_width * 0.75
  @hex_horizontal_spacing @hex_width * 1.14
  # Vertical distance between hex centers in adjacent columns (approx hexHeight * sqrt(3)/2)
  @hex_vertical_spacing @hex_height * 0.86

  attr :hex_width, :float, default: @hex_width
  attr :hex_height, :float, default: @hex_height

  attr :hex_horizontal_spacing, :float, default: @hex_horizontal_spacing
  attr :hex_vertical_spacing, :float, default: @hex_vertical_spacing

  attr :grid_width, :integer, required: true
  attr :grid_height, :integer, required: true

  attr :hexes, :list, required: true

  def grid(assigns) do
    ~H"""
    <div
      id="hex-grid-container"
      class="overflow-hidden w-screen h-screen bg-gray-100 pan-grab"
      x-data="hexGridData()"
      x-init="init()"
      x-on:wheel.prevent="handleWheel($event)"
      x-on:mousedown="startPanning($event)"
      x-on:mousemove="handlePanning($event)"
      x-on:mouseup="stopPanning()"
      x-on:mouseleave="stopPanning()"
      x-bind:class="{ 'pan-grabbing': isPanning }"
      data-hex-width={@hex_width}
      data-hex-height={@hex_height}
      data-hex-horizontal-spacing={@hex_horizontal_spacing}
      data-hex-vertical-spacing={@hex_vertical_spacing}
      data-min-scale="0.3"
      data-max-scale="2.0"
    >
      <div
        id="hex-grid"
        class="relative origin-top-left"
        x-ref="grid"
        style={[
          "height: #{@grid_height * @hex_vertical_spacing + @hex_height / 2}px;",
          "width: #{@grid_width * @hex_horizontal_spacing + @hex_width / 2}px;",
          "scale: 1.0;"
        ]}
      >
        <%= for hex <- @hexes do %>
          <.element
            type={hex.type}
            row={hex.r}
            col={calculate_col(hex.q, hex.r)}
            r={hex.r}
            q={hex.q}
            s={-hex.q - hex.r}
            x={
              if rem(hex.r, 2) != 0,
                do:
                  calculate_col(hex.q, hex.r) * @hex_horizontal_spacing - @hex_horizontal_spacing / 2,
                else: calculate_col(hex.q, hex.r) * @hex_horizontal_spacing
            }
            y={hex.r * @hex_vertical_spacing}
          />
        <% end %>
      </div>
    </div>
    """
  end

  attr :x, :float, required: true
  attr :y, :float, required: true

  attr :col, :integer, required: true
  attr :row, :integer, required: true

  attr :r, :integer, required: true
  attr :q, :integer, required: true
  attr :s, :integer, required: true

  attr :type, :atom, required: true

  attr :hex_height, :float, default: @hex_height
  attr :hex_width, :float, default: @hex_width
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(disabled form name value)

  def element(assigns) do
    ~H"""
    <input
      type="button"
      id={"hex-"<> Integer.to_string(@col) <>"-"<> Integer.to_string(@row)}
      style={"clip-path: polygon(50% 0%, 100% 25%, 100% 75%, 50% 100%, 0% 75%, 0% 25%);
              left: #{@x}px;
              top: #{@y}px;
              width: #{@hex_width}px;
              height: #{@hex_height}px;"
              }
      class={[
        "absolute transition-colors duration-200",
        case @type do
          :basic -> "bg-#{Enum.random(["red", "blue", "green"])}-500"
          :group -> "bg-white"
          :meeting -> "bg-white"
          :disabled -> "bg-black"
        end,
        "hover:bg-zinc-700",
        @class
      ]}
      x-on:mousedown="isClickPossible = true"
      x-on:mousemove="isClickPossible = false"
      x-bind:phx-click="isClickPossible ? 'click' : ''"
      phx-value-r={@r}
      phx-value-q={@q}
      phx-value-s={@s}
      {@rest}
    />
    """
  end

  defp calculate_col(q, r) do
    q + div(r + 1 * rem(r, 2), 2)
  end
end
