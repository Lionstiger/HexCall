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

  # Define grid dimensions
  @grid_width 30
  @grid_height 30

  @total_grid_width @grid_width * @hex_horizontal_spacing + @hex_width / 2
  @total_grid_height @grid_height * @hex_vertical_spacing + @hex_height / 2

  attr :hex_width, :float, default: @hex_width
  attr :hex_height, :float, default: @hex_height

  attr :hex_horizontal_spacing, :float, default: @hex_horizontal_spacing
  attr :hex_vertical_spacing, :float, default: @hex_vertical_spacing

  attr :grid_width, :integer, default: @grid_width
  attr :grid_height, :integer, default: @grid_height

  attr :total_grid_width, :float, default: @total_grid_width
  attr :total_grid_height, :float, default: @total_grid_height

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
          "height: #{@total_grid_height}px;",
          "width: #{@total_grid_width}px;",
          "scale: 1.0;"
        ]}
      >
        <%= for row <- 0..(@grid_height - 1) do %>
          <%= for col <- 0..(@grid_width - 1) do %>
            <.element
              col={col}
              row={row}
              x={
                if rem(row, 2) != 0,
                  do: col * @hex_horizontal_spacing - @hex_horizontal_spacing / 2,
                  else: col * @hex_horizontal_spacing
              }
              y={row * @hex_vertical_spacing}
            />
          <% end %>
        <% end %>
      </div>
    </div>
    """
  end

  attr :x, :float, required: true
  attr :y, :float, required: true

  attr :col, :integer, required: true
  attr :row, :integer, required: true
  attr :grid_width, :integer, default: @grid_width
  attr :grid_height, :integer, default: @grid_height

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
        if @col == 0 or @row == 0 or @row == @grid_width - 1 or @col == @grid_height - 1 do
          "bg-black"
        else
          "bg-#{Enum.random(["red", "blue", "green"])}-500"
        end,
        "hover:bg-zinc-700",
        @class
      ]}
      phx-click="click"
      phx-value-col={@col}
      phx-value-row={@row}
      {@rest}
    />
    """
  end
end

# py-2 px-3
