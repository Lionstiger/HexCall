// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html";
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "../vendor/topbar";
// import VoiceControl from "./hooks/audio_connection"
import { update_hexcell } from "./hooks/hexcell_update";
import { createCaptureHook } from "./hooks/capture";
import { createPlayerHook } from "./hooks/player";
import { hexGridData } from "./hexgrid";

let Hooks = {};

// We need to set this before we initialize Alpine
window.hexGridData = hexGridData;
// Import and enable Alpine here
import Alpine from "alpinejs";
import resize from "@alpinejs/resize";
Alpine.plugin(resize);
Alpine.start();
window.Alpine = Alpine;

const iceServers = [{ urls: "stun:stun.l.google.com:19302" }];
// const iceServers = []; //Use this for local Peering
Hooks.Capture = createCaptureHook(iceServers);
Hooks.Player = createPlayerHook(iceServers);
Hooks.HexCell = update_hexcell();
// Hooks.VoiceControl= VoiceControl;

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {
  hooks: Hooks,
  // longPollFallbackMs: 99999,
  params: { _csrf_token: csrfToken },
  dom: {
    onBeforeElUpdated(from, to) {
      if (from._x_dataStack) {
        window.Alpine.clone(from, to);
      }
    },
  },
});

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (_info) => topbar.show(300));
window.addEventListener("phx:page-loading-stop", (_info) => topbar.hide());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;
