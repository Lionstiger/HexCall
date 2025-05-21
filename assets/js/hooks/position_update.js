const HexPosition = {
  // Define the Alpine.js component data and methods
  hexGridData() {
    return {
      // State variables
      currentScale: 1.0,
      isPanning: false,
      startX: 0,
      startY: 0,
      scrollLeft: 0,
      scrollTop: 0,

      // Configuration (will be read from data attributes)
      hexWidth: 0,
      hexHeight: 0,
      hexHorizontalSpacing: 0,
      hexVerticalSpacing: 0,
      minScale: 0.5,
      maxScale: 3.0,

      // Initialization method
      init() {
        // Read configuration from data attributes on the element Alpine is initialized on
        const container = this.$el; // The element with x-data (hex-grid-container)
        this.hexWidth = parseFloat(container.dataset.hexWidth);
        this.hexHeight = parseFloat(container.dataset.hexHeight);
        this.hexHorizontalSpacing = parseFloat(
          container.dataset.hexHorizontalSpacing,
        );
        this.hexVerticalSpacing = parseFloat(
          container.dataset.hexVerticalSpacing,
        );
        this.minScale = parseFloat(container.dataset.minScale);
        this.maxScale = parseFloat(container.dataset.maxScale);

        // Set initial scroll position if needed (e.g., center the grid)
        // this.$el.scrollLeft = (this.$el.scrollWidth - this.$el.clientWidth) / 2;
        // this.$el.scrollTop = (this.$el.scrollHeight - this.$el.clientHeight) / 2;
      },

      // --- Zooming Functionality ---
      handleWheel(event) {
        const container = this.$el;
        const grid = this.$refs.grid;

        const delta = event.deltaY * -0.01; // Determine zoom direction and intensity
        const newScale = Math.max(
          this.minScale,
          Math.min(this.maxScale, this.currentScale + delta),
        );

        if (newScale === this.currentScale) return; // No change

        // Calculate the position in the grid that is currently under the mouse cursor
        const containerRect = container.getBoundingClientRect();
        const mouseX = event.clientX - containerRect.left;
        const mouseY = event.clientY - containerRect.top;

        // Calculate the scroll position relative to the grid content
        const scrollX = container.scrollLeft;
        const scrollY = container.scrollTop;

        // Calculate the point in the grid content coordinates (before scaling)
        const gridPointX = (scrollX + mouseX) / this.currentScale;
        const gridPointY = (scrollY + mouseY) / this.currentScale;

        // Update the scale (Alpine will handle updating the style via x-bind)
        this.currentScale = newScale;

        // Calculate the new scroll position needed to keep the gridPoint under the mouse
        const newScrollX = gridPointX * newScale - mouseX;
        const newScrollY = gridPointY * newScale - mouseY;

        // Apply the new scroll position
        container.scrollLeft = newScrollX;
        container.scrollTop = newScrollY;
      },

      // --- Panning Functionality ---
      startPanning(event) {
        this.isPanning = true;
        this.startX = event.clientX;
        this.startY = event.clientY;
        this.scrollLeft = this.$el.scrollLeft;
        this.scrollTop = this.$el.scrollTop;
      },

      handlePanning(event) {
        if (!this.isPanning) return;
        event.preventDefault(); // Prevent selection while dragging
        const x = event.clientX - this.startX;
        const y = event.clientY - this.startY;
        this.$el.scrollLeft = this.scrollLeft - x;
        this.$el.scrollTop = this.scrollTop - y;
      },

      stopPanning() {
        this.isPanning = false;
      },
    };
  },

  // TODO: On load we request the full set of positions (map and users)

  // TODO: When we move, update the position and send it up to RoomManager
  // TODO: move other people around when pubsub updates their position
};
export default HexPosition;
