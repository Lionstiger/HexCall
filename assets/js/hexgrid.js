export function hexGridData() {
  return {
    // State variables
    currentScale: 1.0,
    currentTranslateX: 0,
    currentTranslateY: 0,
    isPanning: false,
    startX: 0,
    startY: 0,
    panInitialScrollLeft: 0,
    panInitialScrollTop: 0,

    // Configuration (will be read from data attributes)
    minScale: 0.5,
    maxScale: 3.0,

    // Initialization method
    init() {
      const container = this.$el;
      this.minScale = parseFloat(container.dataset.minScale) || 0.5;
      this.maxScale = parseFloat(container.dataset.maxScale) || 2.0;

      // Set initial transform and scroll state.
      // Needs $nextTick to ensure $refs.grid is available.
      this.$nextTick(() => {
        // On initial load, use current scale (1.0) and current scroll (likely 0,0).
        // This will center the grid if it's smaller than the viewport at scale 1.0.
        this.applyTransformAndScroll(this.currentScale, container.scrollLeft, container.scrollTop);
      });
    },

    /**
     * Applies scale, translation (for centering if needed), and scroll.
     * This function updates reactive properties:
     * - this.currentScale
     * - this.currentTranslateX
     * - this.currentTranslateY
     * And directly sets:
     * - container.scrollLeft
     * - container.scrollTop
     *
     * @param {number} newScale - The target scale.
     * @param {number} targetScrollX - The desired scrollLeft, (e.g. from zoom-to-cursor logic).
     * @param {number} targetScrollY - The desired scrollTop, (e.g. from zoom-to-cursor logic).
     */
    applyTransformAndScroll(newScale, targetScrollX, targetScrollY) {
      const container = this.$el;
      const grid = this.$refs.grid;

      if (!grid) {
        console.warn("Grid element not available in applyTransformAndScroll");
        return;
      }

      // Apply and clamp the new scale
      this.currentScale = Math.max(this.minScale, Math.min(this.maxScale, newScale));

      // Reset translations, will be recalculated if centering is needed
      this.currentTranslateX = 0;
      this.currentTranslateY = 0;

      let finalScrollX = targetScrollX;
      let finalScrollY = targetScrollY;

      const containerWidth = container.clientWidth;
      const containerHeight = container.clientHeight;
      
      // grid.offsetWidth/Height are the dimensions set by the inline style in HEEx
      // (e.g., @total_grid_width, @total_grid_height)
      const gridRenderedWidth = grid.offsetWidth;
      const gridRenderedHeight = grid.offsetHeight;

      const visualGridWidth = gridRenderedWidth * this.currentScale;
      const visualGridHeight = gridRenderedHeight * this.currentScale;

      // If the scaled grid is narrower than the container, center it horizontally.
      // The translation is applied, and scroll for this axis is set to 0.
      if (visualGridWidth < containerWidth) {
        this.currentTranslateX = (containerWidth - visualGridWidth) / 2;
        finalScrollX = 0;
      }
      // Else (scaled grid is wider or equal), currentTranslateX remains 0,
      // and horizontal scroll is determined by targetScrollX (and clamping).

      // If the scaled grid is shorter than the container, center it vertically.
      if (visualGridHeight < containerHeight) {
        this.currentTranslateY = (containerHeight - visualGridHeight) / 2;
        finalScrollY = 0;
      }
      // Else (scaled grid is taller or equal), currentTranslateY remains 0,
      // and vertical scroll is determined by targetScrollY (and clamping).

      // Clamp scroll positions to the actual scrollable range.
      // grid.scrollWidth/Height refers to the total unscaled content size.
      const maxScrollLeft = Math.max(0, grid.scrollWidth - containerWidth);
      const maxScrollTop = Math.max(0, grid.scrollHeight - containerHeight);

      container.scrollLeft = Math.max(0, Math.min(finalScrollX, maxScrollLeft));
      container.scrollTop = Math.max(0, Math.min(finalScrollY, maxScrollTop));
    },

    // --- Zooming Functionality ---
    handleWheel(event) {
      const container = this.$el;
      const oldScale = this.currentScale;

      const delta = event.deltaY * -0.001; // Determine zoom direction and intensity
      let newScale = oldScale + delta;
      // Clamping newScale here is fine, but applyTransformAndScroll also clamps.
      newScale = Math.max(this.minScale, Math.min(this.maxScale, newScale));

      if (newScale === oldScale) return; // No change in scale after clamping

      const containerRect = container.getBoundingClientRect();
      const mouseX = event.clientX - containerRect.left; // Mouse X relative to container viewport
      const mouseY = event.clientY - containerRect.top;  // Mouse Y relative to container viewport

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
      // Prevent panning when clicking on scrollbars or other interactive elements within the container.
      // This check is basic; for more complex content, more specific event target checks might be needed.
      if (event.target !== this.$el && event.target !== this.$refs.grid) {
         // If the click is on a child of the grid (e.g. a hex cell), allow panning.
         // If it's on something else outside the grid but inside the container, might want to prevent.
         // For now, assume if it's not the container itself, it's okay unless it's a scrollbar (hard to detect reliably).
         // The default behavior here is to pan if mousedown is on container or grid or its children.
      }

      this.isPanning = true;
      this.startX = event.clientX;
      this.startY = event.clientY;
      this.panInitialScrollLeft = this.$el.scrollLeft;
      this.panInitialScrollTop = this.$el.scrollTop;
      // `pan-grabbing` class is handled by x-bind:class in template
    },

    handlePanning(event) {
      if (!this.isPanning) return;
      event.preventDefault(); // Prevent text selection, image dragging etc.
      const dx = event.clientX - this.startX;
      const dy = event.clientY - this.startY;
      this.$el.scrollLeft = this.panInitialScrollLeft - dx;
      this.$el.scrollTop = this.panInitialScrollTop - dy;
    },

    stopPanning() {
      if (this.isPanning) {
        this.isPanning = false;
      }
    },
  };
}