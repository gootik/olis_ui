import assert from "node:assert/strict";
import { registerOlisAutocomplete } from "../assets/js/alpine/autocomplete.js";
import { registerOlisComboBox } from "../assets/js/alpine/combo_box.js";

globalThis.HTMLElement = class {
  showPopover() {}
};
const providers = {};
const alpine = {
  data(name, factory) {
    providers[name] = factory;
  },
};
registerOlisAutocomplete(alpine);
registerOlisComboBox(alpine);

for (const [name, kind] of [
  ["olisAutocomplete", "autocomplete"],
  ["olisComboBox", "combo"],
]) {
  const sent = [];
  const button = {
    attrs: {},
    setAttribute(key, value) {
      this.attrs[key] = value;
    },
    click() {
      sent.push({ ...this.attrs });
    },
  };
  const native = { disabled: false, getAttribute: () => null };
  const input = { disabled: false };
  const root = {
    dataset: { open: "false" },
    isConnected: false,
    contains: () => true,
    matches: (selector) => selector === `[data-olis-${kind}]`,
    querySelector(selector) {
      if (selector === "[data-olis-field-open-event]") {
        return button;
      }
      if (selector === `[data-olis-${kind}-native]`) {
        return native;
      }
      if (selector === `[data-olis-${kind}-input]`) {
        return input;
      }
      if (selector === `[data-olis-${kind}-popup]`) {
        return popup;
      }
      return null;
    },
  };
  const popup = {
    open: false,
    closest: () => root,
    matches(selector) {
      return selector === ":popover-open" ? this.open : selector === `[data-olis-${kind}-popup]`;
    },
    showPopover() {
      this.open = true;
    },
    hidePopover() {
      this.open = false;
    },
  };
  const component = providers[name]();
  component.$root = root;
  component.init();
  popup.open = true;
  component.toggle({ target: popup });
  assert.equal(sent.at(-1)["phx-value-open"], "true", `${name} requests an open`);
  assert.equal(popup.open, false, `${name} waits for the server`);

  if (kind === "combo") {
    root.dataset.open = "true";
    component.sync();
    root.contains = (target) => target !== "outside";
    component.outside({ target: "outside" });
    assert.equal(sent.at(-1)["phx-value-open"], "false", "outside clicks request dismissal");
  }
}
