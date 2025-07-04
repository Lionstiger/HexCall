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
      x-on:touchstart="startPanning($event)"
      x-on:mousemove="handlePanning($event)"
      x-on:touchmove="handlePanning($event)"
      x-on:mouseup="stopPanning()"
      x-on:touchend="stopPanning()"
      x-on:mouseleave="stopPanning()"
      x-resize="handleResize($width,$height)"
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
            x={
              if rem(hex.r, 2) != 0,
                do:
                  calculate_col(hex.q, hex.r) * @hex_horizontal_spacing - @hex_horizontal_spacing / 2,
                else: calculate_col(hex.q, hex.r) * @hex_horizontal_spacing
            }
            y={hex.r * @hex_vertical_spacing}
            hex={hex}
          />
        <% end %>
      </div>
    </div>
    """
  end

  attr :hex, :list, required: true
  attr :x, :float, required: true
  attr :y, :float, required: true
  attr :hex_height, :float, default: @hex_height
  attr :hex_width, :float, default: @hex_width

  def element(assigns) do
    ~H"""
    <div
      id={"hex.#{@hex.q}.#{@hex.r}.#{@hex.s}"}
      phx-hook="HexCell"
      style={"clip-path: polygon(50% 0%, 100% 25%, 100% 75%, 50% 100%, 0% 75%, 0% 25%);
              left: #{@x}px;
              top: #{@y}px;
              width: #{@hex_width}px;
              height: #{@hex_height}px;"
              }
      class={
        [
          "absolute transition-colors duration-200 flex justify-center items-center h-screen select-none",
          case @hex.type do
            # :basic -> "bg-#{Enum.random(["red", "blue", "green"])}-500"
            :basic -> "bg-green-500"
            :group -> "bg-white"
            :meeting -> "bg-white"
            :disabled -> "bg-black"
          end,
          "hover:bg-zinc-700"
        ]
      }
      x-on:mousedown="isClickPossible = true"
      x-on:mousemove="isClickPossible = false"
      x-bind:phx-click="isClickPossible ? 'click' : ''"
      phx-value-q={@hex.q}
      phx-value-r={@hex.r}
      phx-value-s={@hex.s}
    />
    """
  end

  defp calculate_col(q, r) do
    q + div(r + 1 * rem(r, 2), 2)
  end
end
