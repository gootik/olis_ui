import { Socket } from "/vendor/phoenix/phoenix.mjs";
import { LiveSocket } from "/vendor/liveview/phoenix_live_view.esm.js";
import Alpine from "/vendor/alpine/module.esm.js";
import collapse from "/vendor/collapse/module.esm.js";
import { registerOlisUIAlpine } from "/ui/alpine.js";

window.Alpine = Alpine;
Alpine.plugin(collapse);
registerOlisUIAlpine(Alpine);
Alpine.start();

const csrfToken = document.querySelector('meta[name="csrf-token"]').content;
const liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  dom: {
    onBeforeElUpdated(from, to) {
      if (from._x_dataStack) {
        Alpine.clone(from, to);
      }
    },
  },
});

liveSocket.connect();

window.addEventListener("phx:download-csv", (event) => {
  const file = new Blob([event.detail.csv], { type: "text/csv;charset=utf-8" });
  const url = URL.createObjectURL(file);
  const link = document.createElement("a");
  link.href = url;
  link.download = "northstar-orders.csv";
  link.click();
  URL.revokeObjectURL(url);
});
