import { installCalendar } from "./calendar.js";
import { installDateField } from "./date_field.js";
import { installDatePicker } from "./date_picker.js";
export { toast, toastPromise, updateToast, dismissToast, clearToasts } from "./toast.js";

/** Install delegated behavior for OlisUI components. Returns a cleanup function. */
export function installOlisUI(root = document) {
  const removeCalendar = installCalendar(root);
  const removeDateField = installDateField(root);
  const removeDatePicker = installDatePicker(root);
  return () => {
    removeCalendar();
    removeDateField();
    removeDatePicker();
  };
}
