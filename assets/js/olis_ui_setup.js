import { registerOlisUIAlpine } from "./alpine.js";
import { installOlisUI } from "./olis_ui.js";

/** Create the startup and LiveView patch hooks for an application's Alpine instance. */
export function createOlisUI(Alpine, collapse) {
  let started = false;

  return {
    start() {
      if (started) {
        return Alpine;
      }

      if (window.Alpine && window.Alpine !== Alpine) {
        throw new Error(
          "An Alpine instance is already present. Register OlisUI with that instance instead of starting a second one.",
        );
      }

      window.Alpine = Alpine;
      Alpine.plugin(collapse);
      registerOlisUIAlpine(Alpine);
      Alpine.start();
      installOlisUI();
      started = true;

      return Alpine;
    },

    beforeUpdate(from, to) {
      if (from._x_dataStack) {
        Alpine.clone(from, to);
      }
    },
  };
}
