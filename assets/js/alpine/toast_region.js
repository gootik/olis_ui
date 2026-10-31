import { olisToastRegion } from "../toast.js";

export function registerOlisToastRegion(Alpine) {
  Alpine.data("olisToastRegion", olisToastRegion);
}
