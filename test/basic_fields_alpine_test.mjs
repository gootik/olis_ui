import assert from "node:assert/strict";
import { registerOlisSearchField } from "../assets/js/alpine/search_field.js";
import { registerOlisNumberField } from "../assets/js/alpine/number_field.js";

const providers = {};
const Alpine = { data: (name, factory) => (providers[name] = factory) };
registerOlisSearchField(Alpine);
registerOlisNumberField(Alpine);

const searchInput = new EventTarget();
searchInput.value = "orders";
searchInput.readOnly = false;
searchInput.matches = () => false;
searchInput.focus = () => (searchInput.focused = true);
let searches = 0;
searchInput.addEventListener("input", () => searches++);
const search = providers.olisSearchField();
search.$refs = { input: searchInput };
search.sync();
search.clear();
assert.equal(searchInput.value, "");
assert.equal(searches, 1);
assert.equal(searchInput.focused, true);

function numberInput(value) {
  return {
    value,
    readOnly: false,
    matches: () => false,
    cloneNode() {
      return numberInput(this.value);
    },
    stepUp() {
      this.value = String(Math.min(Number(this.value) + 1, 2));
    },
    stepDown() {
      this.value = String(Math.max(Number(this.value) - 1, 0));
    },
    dispatchEvent() {
      this.events = (this.events || 0) + 1;
    },
  };
}
const input = numberInput("1");
const number = providers.olisNumberField();
number.$refs = { input };
number.sync();
number.step("up");
assert.equal(input.value, "2");
assert.equal(input.events, 1);
assert.equal(number.cannotIncrease, true);
input.readOnly = true;
number.step("down");
assert.equal(input.value, "2");
