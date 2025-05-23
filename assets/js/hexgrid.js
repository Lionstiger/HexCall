export function hexGridData() {
  return {
    // State
    scrollingIntensity: 0.001,
    isPanning: false,
    startX: 0,
    startY: 0,
    panInitialScrollLeft: 0,
    panInitialScrollTop: 0,

    // Initialization method
    init() {
      const container = this.$el;
      this.minScale = parseFloat(container.dataset.minScale);
      this.maxScale = parseFloat(container.dataset.maxScale);
      const absoluteMinScaleFallback = 0.05;

      this.$nextTick(() => {
        // console.log("mango nexttick");
        const grid = this.$refs.grid;
        if (!grid) {
          console.warn("HexGrid: Grid element not available in init.");
        } else {
          const scaleToFitWidth = container.clientWidth / grid.offsetWidth;
          const scaleToFitHeight = container.clientHeight / grid.offsetHeight;
          const calculatedScaleToFit = Math.min(
            scaleToFitWidth,
            scaleToFitHeight,
          );
          this.minScale = Math.max(
            absoluteMinScaleFallback,
            calculatedScaleToFit,
          );
        }
        if (this.minScale > this.maxScale) {
          console.warn(
            `HexGrid: Calculated minScale (${this.minScale}) was greater than maxScale (${this.maxScale}). Adjusting minScale to be equal to maxScale.`,
          );
          this.minScale = this.maxScale;
        }
      });
    },

    applyTransformAndScroll(newScale, targetScrollX, targetScrollY) {
      const container = this.$el;
      const grid = this.$refs.grid;

      if (!grid) {
        console.warn(
          "HexGrid: Grid element not available in applyTransformAndScroll",
        );
        return;
      }

      // Set the grid to the new scale
      grid.style.scale = newScale;

      // Initialize scroll targets from the parameters
      let finalScrollX = targetScrollX;
      let finalScrollY = targetScrollY;

      grid_dimensions = grid.getBoundingClientRect();
      const visualGridWidth = grid_dimensions.width;
      const visualGridHeight = grid_dimensions.height;

      let translate_x = 0;
      let translate_y = 0;

      // If the scaled grid is narrower than the container, center it horizontally.
      // The translation is applied, and scroll for this axis is set to 0.
      if (visualGridWidth < container.clientWidth) {
        const left_offset = (container.clientWidth - visualGridWidth) / 2;
        translate_x = left_offset / newScale; // This accounts for scale affecting transforms
        finalScrollX = 0;
      }

      // If the scaled grid is shorter than the container, center it vertically.
      // The translation is applied, and scroll for this axis is set to 0.
      if (visualGridHeight < container.clientHeight) {
        const top_offset = (container.clientHeight - visualGridHeight) / 2;
        translate_y = top_offset / newScale; // This accounts for scale affecting transforms
        finalScrollY = 0;
      }

      grid.style.transform =
        "translate(" + translate_x + "px," + translate_y + "px)";

      // --- Apply Scrolling to the Container ---

      // Calculate the maximum scrollable extents based on the visual size of the grid.
      // If the visual grid is smaller than the container, there's no scroll in that dimension (it's centered by translation).
      const maxScrollLeft = Math.max(
        0,
        visualGridWidth -
          container.clientWidth -
          container.dataset.hexWidth / 2,
      );
      const maxScrollTop = Math.max(
        0,
        visualGridHeight -
          container.clientHeight -
          container.dataset.hexHeight / 2,
      );

      // Clamp finalScrollX and finalScrollY to be within valid scrollable range [0, maxScroll]
      // If the content is centered (visualGridWidth < clientWidth), maxScrollLeft will be 0,
      // and finalScrollX was already set to 0, so this clamping is still correct.
      const clampedScrollX = Math.max(0, Math.min(finalScrollX, maxScrollLeft));
      const clampedScrollY = Math.max(0, Math.min(finalScrollY, maxScrollTop));

      // Apply the clamped scroll values to the container
      container.scrollLeft = clampedScrollX;
      container.scrollTop = clampedScrollY;

      // Dynamically adjust overflow to hide scrollbars when content doesn't overflow
      // container.style.overflowX = maxScrollLeft > 0 ? "auto" : "hidden";
      // container.style.overflowY = maxScrollTop > 0 ? "auto" : "hidden";
    },

    // --- Zooming Functionality ---
    handleWheel(event) {
      const container = this.$el;
      const oldScale = parseFloat(this.$refs.grid.style.scale);

      const delta = event.deltaY * -this.scrollingIntensity; // Determine zoom direction and intensity
      let newScale = oldScale + delta;

      //Make sure newScale is smaller than our maxScale and larger than our minScale
      newScale = Math.min(this.maxScale, newScale);
      newScale = Math.max(this.minScale, newScale);

      // If there is no change, we return
      if (newScale === oldScale) return;

      // Collect
      const containerRect = container.getBoundingClientRect();
      const mouseX = event.clientX - containerRect.left; // Mouse X relative to container viewport
      const mouseY = event.clientY - containerRect.top; // Mouse Y relative to container viewport
      const currentScrollLeft = container.scrollLeft;
      const currentScrollTop = container.scrollTop;

      // Calculate the point in the unscaled grid content coordinates that is currently under the mouse
      const gridPointX = (currentScrollLeft + mouseX) / oldScale;
      const gridPointY = (currentScrollTop + mouseY) / oldScale;

      // Calculate the new scroll position needed to keep that gridPoint under the mouse after scaling
      const targetScrollX = gridPointX * newScale - mouseX;
      const targetScrollY = gridPointY * newScale - mouseY;

      // Apply the new scale and adjust scroll/translation
      this.applyTransformAndScroll(newScale, targetScrollX, targetScrollY);
    },

    // --- Panning Functionality ---
    startPanning(event) {
      // Handle if we pan somewhere else and do nothing (for now)
      if (event.target !== this.$el && event.target !== this.$refs.grid) {
      }

      // Set isPanning and set intial panning values
      this.isPanning = true;
      this.startX = event.clientX;
      this.startY = event.clientY;
      this.panInitialScrollLeft = this.$el.scrollLeft;
      this.panInitialScrollTop = this.$el.scrollTop;
    },

    handlePanning(event) {
      if (!this.isPanning) return;
      event.preventDefault(); // Prevent text selection, image dragging etc.

      const container = this.$el;
      const grid = this.$refs.grid;

      if (
        !grid ||
        !grid.style.scale ||
        isNaN(parseFloat(grid.style.scale)) ||
        parseFloat(grid.style.scale) <= 0
      ) {
        this.isPanning = false;
        return;
      }

      const delta_x = event.clientX - this.startX;
      const delta_y = event.clientY - this.startY;
      let newScrollLeft = this.panInitialScrollLeft - delta_x;
      let newScrollTop = this.panInitialScrollTop - delta_y;

      const grid_dimensions = grid.getBoundingClientRect();
      const visualGridWidth = grid_dimensions.width;
      const visualGridHeight = grid_dimensions.height;

      const maxScrollLeft = Math.max(
        0,
        visualGridWidth -
          container.clientWidth -
          container.dataset.hexWidth / 2,
      );
      const maxScrollTop = Math.max(
        0,
        visualGridHeight -
          container.clientHeight -
          container.dataset.hexHeight / 2,
      );

      newScrollLeft = Math.max(0, Math.min(newScrollLeft, maxScrollLeft));
      newScrollTop = Math.max(0, Math.min(newScrollTop, maxScrollTop));

      container.scrollLeft = newScrollLeft;
      container.scrollTop = newScrollTop;
    },

    stopPanning() {
      if (this.isPanning) {
        this.isPanning = false;
      }
    },
  };
}
