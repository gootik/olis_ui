import { heroToastRegion } from "../toast.js";

export function registerHeroToastRegion(Alpine) {
  Alpine.data('heroToastRegion', heroToastRegion);
}
