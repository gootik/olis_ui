export function createPopupState(eventSelector = "[data-olis-field-open-event]") {
  let requested = null;

  return {
    desired(field) {
      return requested ?? field.dataset.open === "true";
    },

    request(field, open, reason) {
      if (requested === open || (requested === null && field.dataset.open === String(open))) {
        return;
      }

      const button = field.querySelector(eventSelector);

      if (button) {
        requested = open;
        button.setAttribute("phx-value-open", String(open));
        button.setAttribute("phx-value-reason", reason);
        button.click();
      }
    },

    sync(field, popup, disabled) {
      if (!popup || disabled) {
        return;
      }

      const open = field.dataset.open === "true";

      if (requested === open) {
        requested = null;
      }

      if (open && !popup.matches(":popover-open")) {
        popup.showPopover();
      } else if (!open && popup.matches(":popover-open")) {
        popup.hidePopover();
      }
    },
  };
}
