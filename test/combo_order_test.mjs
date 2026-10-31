import assert from "node:assert/strict";
import { selectedLabels } from "../assets/js/alpine/combo_box.js";

const options = [
  { value: "cat", textContent: "Cat" },
  { value: "dog", textContent: "Dog" },
];
assert.deepEqual(selectedLabels(["dog", "cat"], options), ["Dog", "Cat"]);
assert.deepEqual(selectedLabels(["cat", "dog"], options), ["Cat", "Dog"]);
assert.deepEqual(selectedLabels(["missing", "cat"], options), ["Cat"]);
