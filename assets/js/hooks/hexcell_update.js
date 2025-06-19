export function update_hexcell() {
  return {
    async mounted() {
      const hex_name = this.el.id;
      this.handleEvent("update_hex@" + hex_name, (payload) => {
        // console.warn(payload);
        this.el.textContent = payload.user.name;
      });
      this.handleEvent("clear_hex@" + hex_name, (_payload) => {
        // console.warn("clearing hex " + hex_name);
        this.el.textContent = "";
      });
    },
  };
}
