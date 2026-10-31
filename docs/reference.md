# OlisUI for LiveView

OlisUI is a component library for Phoenix LiveView. It combines Phoenix function components and native HTML with Tailwind CSS and Alpine.js for interactive behavior. The default palette pairs neutral surfaces with an indigo accent.

OlisUI is an early foundation and its APIs are still evolving. It currently provides button, close button, input, text field, fieldset, input group, search field, one-time-code input, color field, color swatch, color swatch picker, autocomplete, combo box, card, chip, checkbox, checkbox group, switch, switch group, avatar, avatar group, progress bar, progress circle, meter, spinner, separator, scroll shadow, skeleton, textarea, radio, radio group, keyboard key, link, surface, select, disclosure, disclosure group, alert, toast, badge, data table, modal, alert dialog, drawer, sheet, tabs, dropdown, tooltip, popover, slider, number field, pagination, toolbar, button groups, toggle buttons, breadcrumbs, listbox, and tag group components. Some advanced component behaviors remain to be built and verified.

## Preview

Run `mix deps.get`, `npm ci`, and `mix preview`, then open [http://localhost:4000](http://localhost:4000). Press Ctrl+C twice to stop the server. Set `PORT` to use another port, for example `PORT=4001 mix preview`. The preview is a local development gallery; its example buttons do not perform application actions.

The connected LiveView integration preview is at [http://localhost:4000/live-preview](http://localhost:4000/live-preview).

For a realistic interactive application, see the separate [admin dashboard example](https://github.com/gootik/olis_ui/tree/main/examples/admin). It runs on port 4001 and demonstrates the components in a commerce workflow.

For a review, use the navigation to move between these sections and the theme control to switch themes:

- **Forms:** text and input groups, search, autocomplete, combo boxes, and validation.
- **Selection & navigation:** buttons, checkboxes, switches, sliders, lists, tags, tabs, and disclosures.
- **Overlays:** sheets, dropdowns, tooltips, dialogs, drawers, and popovers.
- **Feedback:** toasts, alerts, chips, avatars, and progress indicators.
- **Data display:** cards, surfaces, typography, breadcrumbs, shortcuts, skeletons, pagination, and tables.

The live preview includes examples driven by LiveView, including selection, sorting, forms, and notifications. Browser find can locate a component by the title on its preview card.

## Installation

Add OlisUI to your Phoenix app's `mix.exs`.

```elixir
{:olis_ui, "~> 0.1.0"}
```

Fetch dependencies and generate the asset entry points:

```sh
mix deps.get
mix olis_ui.install
```

The installer prints the remaining steps and does not overwrite existing files. Install the asset dependencies in your application's `assets` directory:

```sh
cd assets
npm install --save-exact alpinejs@3.17.5 @alpinejs/collapse@3.17.5 tw-animate-css@1.4.0
```

In `assets/css/app.css`, replace the Tailwind import with `@import "./olis_ui.css";` and keep the rest of your application styles. In `assets/js/app.js`, import and start OlisUI before connecting LiveSocket:

```js
import { olisUI } from "./olis_ui";

olisUI.start();

// Add this to your existing LiveSocket options:
// dom: { onBeforeElUpdated: olisUI.beforeUpdate }
```

If your application already starts Alpine, use the manual setup shown below instead. Import the component modules you need in your LiveView or HTML helpers:

```elixir
import OlisUI.Button
import OlisUI.Forms
```

Resolve any conflicting imports from your application's `CoreComponents`, or use fully qualified names such as `<OlisUI.Button.button>Save</OlisUI.Button.button>`. Available modules are `OlisUI.Base`, `Button`, `Checks`, `Color`, `Controls`, `Disclosure`, `Display`, `Dropdown`, `Feedback`, `Floating`, `Forms`, `Groups`, `Icon`, `NumberField`, `Overlays`, `Pagination`, `Progress`, `Select`, `Selection`, `Slider`, `Table`, `Tabs`, `Toast`, and `Typography` (each under `OlisUI`).

OlisUI uses Tailwind CSS v4; see the [Phoenix installation guide](https://tailwindcss.com/docs/installation/framework-guides/phoenix) if your application does not have it yet. Restart the asset watcher after installation. The component palette defaults to light. Set `data-theme="dark"` on the document root to enable the dark palette and Tailwind `dark:` utilities. Nested light sections inside a dark document do not isolate Tailwind `dark:` utilities.

The type stack prefers Inter Variable, then Inter and system sans-serif fonts. Supply Inter in your application if you want the same typography as the preview; code and keyboard labels use a monospace fallback.

## Usage

```heex
<.button phx-click="save">Save changes</.button>
<.button variant="secondary" type="submit">Continue</.button>
<.button variant="danger-soft" disabled>Delete</.button>
<.button pending={@saving} phx-click="save">Save changes</.button>

<.text_field
  field={@form[:email]}
  label="Email"
  type="email"
  description="We'll send your receipt here."
  errors={if Phoenix.Component.used_input?(@form[:email]), do: Enum.map(@form[:email].errors, &translate_error/1), else: []}
  required
/>

<.card>
  <.chip color="success" variant="soft">Active</.chip>
  <p>Your account is ready.</p>
</.card>
```

`translate_error/1` is the application's error translation function (Phoenix generators commonly provide one in `CoreComponents`). Errors are explicit so applications control translation and when validation appears. A standalone field needs an `id` and can receive `name`, `value`, and a list of error strings. `text_field` associates its label, description, and errors with the input; when invalid, it hides the description and associates the visible errors instead. Use `invalid` to mark a field invalid without an error message, or `multiline` and `rows` for a textarea. If there is no visible `label`, provide `aria-label` or `aria-labelledby`. Use `.input` directly when composing your own field.

`ui_form` delegates to Phoenix's form component, including `:let`, `phx-change`, `phx-submit`, and normal HTTP form options. Its name avoids a conflict with Phoenix's own `.form`; both use the same API. When composing fields yourself, use `.description` for help text, `.field_error` for validation errors, and `.error_message` for errors on non-form components. Link the message IDs to their controls with `aria-describedby`. Field errors are visible by default; set `visible={false}` to hide them. Validation, error translation, and visibility are controlled by the application.

```heex
<.ui_form for={@form} :let={form} phx-change="validate" phx-submit="save" class="space-y-3">
  <.label for={form[:email].id}>Email</.label>
  <.input id={form[:email].id} name={form[:email].name} value={form[:email].value}
    aria-describedby="email-help" />
  <.description id="email-help">We'll send your receipt here.</.description>
  <.button type="submit">Save</.button>
</.ui_form>
```

The standalone label, link, typography, and spinner components use OlisUI's styles and native HTML. A required label displays an indicator; set `required` on the input as well. Links accept `href`, `patch`, or `navigate`. Spinners default to the accent color and announce `Loading`; pass a descriptive `label`, or use `decorative` inside an already named control. A switch with `read_only` remains focusable and submits its checked value; preventing user changes requires the OlisUI Alpine setup.

Skeletons accept `animation_type="shimmer"`, `"pulse"`, or `"none"`, for example `<.skeleton animation_type="pulse" class="h-4 w-40" />`. When omitted, Alpine reads the document root's `--skeleton-animation` at initialization; without Alpine or a supported value, shimmer is used. Set `animation_type="none"` on child skeletons inside a parent with `skeleton--shimmer` for a synchronized effect.

Progress bars and meters accept a visible `label`, or `aria-label`/`aria-labelledby` for a label-free indicator. Set `show_value={false}` to display just the track, and use `value_text` for a custom visible and accessible value. Progress bars and circles start at zero; pass `indeterminate` when the amount of progress is unknown. A circle's label is accessible by default and can be displayed with `show_label`.

```heex
<.progress_bar label="Uploading" value={45} />
<.progress_bar aria-label="Loading" indeterminate show_value={false} />
<.meter label="Storage" value={7} max={10} value_text="7 of 10 GB" />
<.progress_circle label="Uploading" value={75} show_label />
```

```heex
<.label for="email" required>Email</.label>
<.input id="email" type="email" required />
<.ui_link patch="/settings">Settings</.ui_link>
<.ui_link href="https://elixir-lang.org" target="_blank" rel="noopener noreferrer">Elixir <.link_icon /></.ui_link>
<.typography type="h2">Your account</.typography>
<.spinner color="success" size="sm" label="Saving" />
```

`pending` keeps a button focusable while suppressing activation and setting `aria-disabled` and `aria-busy`. A pending submit button temporarily uses `type="button"` to prevent implicit form submission. Install Alpine for the pending-state event guard; compose a spinner or other loading content inside the button when desired. Give icon-only buttons an accessible name with `aria-label`, `aria-labelledby`, or visually hidden text.

Use `<.close_button label="Dismiss notification" phx-click="dismiss" />` for an icon-only dismissal action. It defaults to `type="button"` and the accessible label `Close`; pass `disabled`, Tailwind classes, or custom icon content as needed. Like a normal button, it requires a click handler or another dismissal mechanism supplied by the surrounding component.

Cards accept `variant="default"`, `"secondary"`, `"tertiary"`, or `"transparent"`. Use `:title`, `:description`, `:content`, and `:footer` slots for OlisUI's section styles, or pass ordinary content directly. Set `heading_level` to fit the page outline and give the title an `id` when the card needs an accessible name.

Surfaces support four semantic background variants. They do not add padding, rounding, or a shadow: compose those with Tailwind classes, for example `<.surface variant="secondary" class="rounded-3xl p-6">…</.surface>`. Pass `variant="secondary"` explicitly to nested inputs when a lower-emphasis field is desired.

```heex
<.card variant="secondary" role="article" aria-labelledby="project-title">
  <:title id="project-title">Project overview</:title>
  <:description>Latest activity</:description>
  <:content>Everything is up to date.</:content>
  <:footer><.button size="sm">View project</.button></:footer>
</.card>
```

Alerts accept `status="default"`, `"accent"`, `"success"`, `"warning"`, or `"danger"`. Put the description in the default slot or use `:description`; when both are provided, the named description takes precedence. Customize the icon with `:indicator`, add controls with `:actions`, or use `:title_content` for a title containing markup. The default `role="status"` announces updates politely; use `role="alert"` for urgent messages.

```heex
<.alert status="warning" title="Payment expires soon" role="alert">
  <:description>Update your billing details.</:description>
  <:actions><.button size="sm" phx-click="review_billing">Review</.button></:actions>
</.alert>
```

Chips default to OlisUI's `secondary` variant and wrap their text in a styled label. Use `:prefix` and `:suffix` for icons or other content beside the label, and mark decorative icons `aria-hidden="true"`. For full control over the children, set `wrap_label={false}` and use `.chip_label` where needed.

```heex
<.chip color="success" variant="soft">
  <:prefix><span aria-hidden="true" class="size-1.5 rounded-full bg-current"></span></:prefix>
  Published
</.chip>
```

Group related fields with a native fieldset. Its legend names the group, its description is connected with `aria-describedby`, and `disabled` disables its descendant form controls. Use `:legend_content` instead of `legend` when the legend needs markup; `group_class` and `actions_class` customize the layout.

```heex
<.fieldset id="profile" legend="Profile settings" description="Update your profile information.">
  <.text_field field={@form[:name]} label="Name" required />
  <.text_field field={@form[:email]} label="Email" type="email" />
  <:actions>
    <.button type="submit">Save changes</.button>
    <.button type="reset" variant="secondary">Reset</.button>
  </:actions>
</.fieldset>
```

Scroll shadows fade the edges of a constrained scrollable region. Set a height or width with Tailwind classes, and give the region a label and `tabindex="0"` when keyboard users need to scroll it. Use `orientation="horizontal"`, `hide_scrollbar`, `size`, or `offset` as needed. `visibility` can explicitly select `top`, `bottom`, `left`, `right`, `both`, or `none`; the default `auto` follows scroll position. With OlisUI's Alpine providers registered, automatic changes dispatch a bubbling `olis:scroll-shadow-change` event and can also send a LiveView event via `on_visibility_change`, with a `"visibility"` parameter. The callback fires on changes after the initial measurement.

```heex
<.scroll_shadow id="activity" class="max-h-48" tabindex="0" role="region" aria-label="Activity">
  <p :for={event <- @events}>{event.message}</p>
</.scroll_shadow>
```

OlisUI's CSS supplies automatic fades without JavaScript in browsers that support scroll-driven animations. In other browsers, register OlisUI's Alpine providers for automatic detection; explicitly selected visibility also works without it.

Avatar groups inherit `size`, `color`, and `variant` from the group, with per-avatar overrides available. Set `max` to show an automatic overflow count, use `grid` for a wrapping layout, or choose `overlap="ring"` for a solid seam. An explicit `:count` slot replaces the automatic count and supplies its own accessible label. Give meaningful groups a role and label.

```heex
<.avatar_group role="group" aria-label="Project team" max={2} variant="soft">
  <:avatar name="Jane Doe" />
  <:avatar name="Alex Kim" color="accent" />
  <:avatar name="Morgan Lee" />
</.avatar_group>
```

Switch groups arrange independent native switches. Add a `label` for a fieldset legend and set `orientation="horizontal"` for a row. Switches accept `field={@form[:updates]}` or an `id` and `name`. Each switch submits its `value` only when checked; include a hidden input when your form needs an explicit unchecked value. Switches also accept `description`, `errors`, `label_position="start"`, and an optional `:icon` slot. If there is no visible label, provide `aria-label` or `aria-labelledby`.

```heex
<.switch_group label="Notifications">
  <input type="hidden" name="updates" value="false" />
  <.switch id="updates" name="updates" checked={@updates}>Product updates</.switch>
</.switch_group>
```

Input groups combine a native input with optional `:prefix` and `:suffix` slots. Pass `multiline` for a textarea, `variant="secondary"` for surfaces, and `full_width` to fill the available width. In multiline groups, suffix content appears below the textarea at the trailing edge, leaving the field free to resize vertically. Slots can contain text, icons, or interactive controls; disable interactive slot controls explicitly when the field is disabled. Like `text_field`, an input group accepts a Phoenix form field and explicit error strings. With Alpine installed, clicking a noninteractive part of the group focuses its input.

```heex
<.input_group field={@form[:price]} label="Price" type="number" full_width>
  <:prefix>$</:prefix>
  <:suffix>USD</:suffix>
</.input_group>
```

Install Alpine.js and its Collapse plugin in the host application's asset directory with `npm install alpinejs @alpinejs/collapse`. Register the plugin and the OlisUI Alpine components before starting Alpine, and preserve Alpine state when LiveView patches the DOM. Merge the `dom` callback below into your existing `LiveSocket` setup if you already have one:

```js
import Alpine from "alpinejs";
import collapse from "@alpinejs/collapse";
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import { registerOlisUIAlpine } from "../../../olis-components/assets/js/alpine.js";

window.Alpine = Alpine;
Alpine.plugin(collapse);
registerOlisUIAlpine(Alpine);
Alpine.start();

const csrf = document.querySelector("meta[name='csrf-token']").content;
const liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrf },
  dom: {
    onBeforeElUpdated(from, to) {
      if (from._x_dataStack) {
        Alpine.clone(from, to);
      }
    }
  }
});
liveSocket.connect();
```

These JavaScript paths are relative to `assets/js/app.js` and follow the sibling checkout layout above. For a Git dependency under `deps/olis_ui`, use `../../deps/olis_ui/...` instead. Start Alpine and connect the LiveSocket only once. Interactive components use the registered Alpine providers. Phoenix LiveView JS commands handle patch-aware client operations where appropriate.

Disclosures use native `<details>` and LiveView-managed open state. Pass `open` and `on_toggle` to a disclosure, or `expanded_keys` and `on_toggle` to a group. The event sends the item `"key"` and desired `"expanded"` state as `"true"` or `"false"`; update the assign in the handler. The application decides whether one or several items may be open. Native CSS animates the disclosure in browsers that support `::details-content` and `interpolate-size`; other browsers open and close it immediately.

```heex
<.disclosure_group id="settings" expanded_keys={@expanded_keys} on_toggle="toggle_disclosure">
  <:item key="account" title="Account">Account settings</:item>
  <:item key="billing" title="Billing">Billing settings</:item>
</.disclosure_group>
```

Open a modal with a button whose `data-olis-dialog-open` matches the modal ID:

```heex
<.button data-olis-dialog-open="edit-profile">Edit profile</.button>
<.modal id="edit-profile" title="Edit profile" open={@edit_profile_open} on_open_change="edit_profile_change">
  Update your profile details here.
</.modal>
```

Modal supports `placement="auto" | "top" | "center" | "bottom"`, `backdrop="opaque" | "blur" | "transparent"`, `scroll="inside" | "outside"`, and sizes through `cover` and `full`. `dismissible={false}` prevents backdrop dismissal; `keyboard_dismiss_disabled` separately disables Escape. For LiveView-controlled state, pass `open` and `on_open_change`; the event receives `"open"` and `"reason"`. Slots can replace the trigger or close button:

```heex
<.modal id="settings" title="Settings" open={@settings_open} on_open_change="settings_open_change">
  <:trigger :let={attrs}><.button {attrs}>Settings</.button></:trigger>
  Update your settings.
  <:close :let={attrs}><.button {attrs}>Done</.button></:close>
</.modal>
```

Sheets are swipeable modal panels managed by the OlisUI Alpine providers. Open one with `data-olis-sheet-open`, close it with `data-olis-sheet-close` or its built-in close button, and choose `placement="bottom"`, `"top"`, `"left"`, or `"right"`. `detached` adds space around the panel. Use `snap_points` for partial positions; numbers are pixels and strings support `px`, `%`, `vh`, `vw`, `rem`, and `em` units. A fully expanded position is added automatically. Pass `snap_index` and `on_snap_change` to manage the selected position in LiveView; the event sends an `"index"` into `snap_points`, or `-1` for fully expanded. Sheets can be nested and use native modal focus containment.

```heex
<.button data-olis-sheet-open="filters">Filters</.button>
<.sheet id="filters" title="Filters" snap_points={[240, "60%"]} snap_index={@snap_index} on_snap_change="snap_change" open={@filters_open} on_open_change="filters_change">
  Choose the filters to apply.
  <:footer><.button data-olis-sheet-close>Done</.button></:footer>
</.sheet>
```

For LiveView-controlled state, pass `open={@sheet_open}` and `on_open_change="sheet_open_change"`. The event sends `"open"` as `"true"` or `"false"` and a `"reason"` of `"trigger"`, `"close"`, `"backdrop"`, `"escape"`, `"swipe"`, or `"parent"` when an ancestor sheet closes; update `open` in your handler. Set `dismissible={false}` to prevent outside, Escape, and swipe dismissal; explicit close buttons still work.

The native dialog contains focus and restores it on close. Escape and backdrop clicks dismiss it by default; `dismissible={false}` disables those dismissals. The Close button is always available. The OlisUI Alpine providers manage opening and dismissal, and a LiveView mount command preserves the native `open` attribute across updates.

Alert dialogs and drawers use the same opener as modals. Alert dialogs require an explicit cancel or confirm action and send `on_confirm` as a LiveView event. Drawers support `top`, `bottom`, `left`, and `right` placement and `opaque`, `blur`, or `transparent` backdrops. The default placement is `bottom`. They use the registered OlisUI Alpine providers for opening and dismissal, animate unless reduced motion is requested, and retain native focus containment during exit. Set `dismissible={false}` to prevent backdrop, Escape, and swipe dismissal.

Pass `open={@drawer_open}` and `on_open_change="drawer_open_change"` to let LiveView control it. The event carries `"open"` and a `"reason"` (`"trigger"`, `"close"`, `"escape"`, `"backdrop"`, `"swipe"`, or `"native"`); update the assign in the handler. User actions also dispatch a bubbling `olis:drawer-open-change` browser event. These events request a change; the parent updates `open`. Drag the header or footer to dismiss; `show_handle` adds a visible drag handle. Interactive controls and the scrollable body retain their normal behavior. Set `close_label` to change the default button text, `show_close={false}` to omit it, or provide a `:close` slot with its supplied attributes on your own button.

```heex
<.drawer id="settings" title="Settings" open={@drawer_open} on_open_change="drawer_open_change">
  Update your settings.
  <:close :let={attrs}><.button {attrs}>Done</.button></:close>
</.drawer>
```

```heex
<.button data-olis-dialog-open="confirm-delete">Delete</.button>
<.alert_dialog id="confirm-delete" title="Delete item?" open={@confirm_open} on_open_change="confirm_change" on_confirm="delete" confirm_label="Delete">
  This action cannot be undone.
</.alert_dialog>
```

Pagination accepts an `on_change` LiveView event or `Phoenix.LiveView.JS` command, or a one-argument `href` or `patch` function. The application owns the current page. Use `show_pages={false}` for previous/next navigation, `show_controls={false}` for numbered pages alone, and `:previous_icon` / `:next_icon` to replace the decorative arrows. `page_label` is a function for localizing page labels.

```heex
<.pagination page={@page} total_pages={@total_pages} on_change="page_changed">
  <:summary>Page {@page} of {@total_pages}</:summary>
</.pagination>
```

Tabs use labelled slots and support arrow keys, Home, and End. Pass `selected_key` and `on_selection_change`; the event receives `"key"`, and the handler updates the assign. Set `activation_mode="manual"` to move focus with arrow keys and select with Enter or Space. Set `orientation="vertical"`, `variant="secondary"`, `align="start"` or `"end"`, and `show_separators` as needed. Overflowing lists show scroll controls. Tab IDs must be unique within a tab set and at least one tab must be enabled.

```heex
<.tabs id="settings" label="Settings" selected_key={@selected_tab} on_selection_change="select_tab">
  <:tab id="profile" label="Profile">Profile settings</:tab>
  <:tab id="security" label="Security">Security settings</:tab>
</.tabs>
```

A dropdown uses the browser Popover API and forwards actions to LiveView. Pass `open` and `on_open_change`; update the assign using the event’s `"open"` value:

```heex
<.dropdown id="actions" label="Actions" open={@actions_open} on_open_change="actions_change">
  <:item label="Duplicate" on_click="duplicate" />
  <:item label="Help" href="/help" />
  <:item label="Delete" on_click="delete" danger />
</.dropdown>
```

Use sections to group items and provide each selectable item with a unique string `key` within its group. Selection is managed by LiveView:

```heex
<.dropdown id="view-options" label="View options" open={@view_open} on_open_change="view_change" on_action="menu_action">
  <:section
    label="Columns"
    selection_mode="multiple"
    selected_keys={@columns}
    on_selection_change="columns_changed"
    items={[
      %{key: "name", label: "Name"},
      %{key: "status", label: "Status"}
    ]}
  />
  <:section label="Share" items={[
    %{label: "Share project", items: [
      %{key: "copy", label: "Copy link", shortcut: "⌘ C"},
      %{key: "email", label: "Email", description: "Send a link"}
    ]}
  ]} />
</.dropdown>
```

`selection_mode` accepts `"none"`, `"single"`, or `"multiple"` on the dropdown, a section, or a submenu item. Each group maintains its own selection. `on_selection_change` receives `"key"`, `"selected"` (`"true"` or `"false"`), and `"keys"` (a JSON-encoded list). Update `selected_keys` in the event handler. An item’s `on_click` or the dropdown’s `on_action` receives its `"key"` when provided. Single-selection and action menus close after selection by default; multiple-selection menus remain open. Override this with `close_on_select`.

Dropdowns require a browser with the Popover API and the OlisUI Alpine providers. Keyboard users can open with Enter, Space, or arrow keys and navigate items with arrow keys, Home, End, and type-ahead. Arrow keys open and close submenus according to text direction; Escape closes the current menu and restores focus. For nested menus, pass `open_submenus` and `on_submenus_change`, and assign the event’s JSON-decoded `"keys"` list back to `open_submenus`. Clear it when the dropdown closes.

Slider and number field use native range and number inputs. Register the OlisUI Alpine components for slider pointer interaction and live output, and for number-field step buttons. Inputs submit through Phoenix forms.

Number fields accept `field={@form[:quantity]}` or an `id`, `name`, and `value`, plus `min`, `max`, `step`, `description`, and explicit `errors`. Buttons disable at the reachable bounds and when `disabled` or `read_only` is set. Replace the icons using the `:increment_icon` and `:decrement_icon` slots. The native number input uses the browser's numeric entry behavior; locale-specific currency, percentage, and unit formatting are not yet implemented.

```heex
<.slider id="volume" name="volume" label="Volume" value={30} />
<.slider id="price" name="price" label="Price" value={[20, 80]}
  step={10} show_steps marks={[{0, "$0"}, {50, "$50"}, {100, "$100"}]} />
<div class="h-64">
  <.slider id="brightness" label="Brightness" value={40} orientation="vertical" />
</div>
```

An ascending list creates multiple thumbs and submits each value under `name[]`. Each thumb is a native range input with its own keyboard focus and is constrained by its neighbors. Marks accept numbers or `{value, label}` tuples; marks outside the bounds are omitted. Step dots are decorative and are omitted if more than 1,000 would be needed. Give vertical sliders a container with a defined height. Values and track positions are updated in the browser as the user moves a thumb, and form change events remain available to LiveView.

Button groups accept ordinary button content, or named `:button` slots that inherit the group's `variant`, `size`, `disabled`, and `full_width` settings. Named slots can override those settings; `disabled={false}` re-enables an individual button in a disabled group. Set `show_separators` to add decorative dividers, or use `.button_group_separator` inside manually composed buttons. Named buttons accept `on_click`, `target`, `name`, `value`, `type`, `form`, `pending`, `icon_only`, and `aria_label`.

```heex
<.button_group label="Editing" variant="secondary" size="sm" show_separators>
  <:button on_click="edit" value="copy">Copy</:button>
  <:button on_click="edit" value="paste">Paste</:button>
</.button_group>
```

Toggle buttons use `pressed` and a LiveView click handler to manage state. Group related toggles with `.toggle_button_group`. Set `selection_mode="single"` or `"multiple"` to coordinate children, each with a unique `value`, `data-key`, or `id`; omit it to keep independent toggles. Managed groups use `selected_keys` and `on_selection_change`, which receives the full key list as a JSON string in `"keys"`. With Alpine, a group `size` applies to children without an explicit size; `disabled` natively disables every descendant. Breadcrumbs use `:item` slots and mark the last item as the current page.

Pagination supports either LiveView events (`on_change`) or URL generation (`href={fn page -> ... end}`). The event receives the requested page as `"page"`; the application owns page bounds, loading, and URL state. Use the optional `:summary` slot for result counts.

Tables accept lists or LiveView streams. Give a stream table a unique `id`; the component supplies the stream container and row IDs. The `:empty` slot customizes the empty message for both lists and streams, and `:footer` places pagination or other content inside the OlisUI table footer. For server-driven sorting, add `sort_key` to a column and set `sort_event`, `sort_by`, and `sort_direction`. The event receives the selected key as `"sort"`; your LiveView sorts the data and updates those assigns.

With Alpine, tables use grid keyboard navigation: Tab enters the grid, Up and Down move between rows, Right enters cells, and Left returns to the row. Home and End move to the first or last row or cell. Enter or Space activates sorting or selection. To interact with a cell's controls, press Enter to focus the first control; Tab and Shift+Tab move between controls, and Escape returns to the cell. Controls keep their native keyboard behavior while focused. Without Alpine, the native table and its controls remain available.

For infinite loading, give the table an `id`, set `on_load_more` to a LiveView event or JS command, and set `has_more` while another page is available. LiveView's viewport binding requests the next page when the table's end is reached. Set `loading` while fetching to suspend further requests and show a loading indicator; use the `:load_more` slot to customize that content. The LiveView owns fetching, stream insertion, and the `has_more`/`loading` assigns.

Selectable tables use `selection_mode="single"` or `"multiple"`. Supply a stable `row_id` function for list rows; streams use their stream DOM IDs as keys. `row_label` provides meaningful names for the selection controls. Pass `selected_keys` and `on_selection_change` for LiveView-controlled selection. The event receives a JSON-encoded `keys` list; decode it and assign the list back in controlled mode. Select-all applies to currently rendered enabled rows and preserves selections outside the rendered collection. Supply `disabled_keys` to prevent particular rows from being selected.

Add `resizable` to a `:col` to let people adjust its width by dragging the header separator or using the keyboard. `width`, `min_width`, and `max_width` are pixel values; Give each column a `key` and pass its current width from a LiveView assign. With a sortable header, focus the header and press F2, then Tab to reach its resizer; on the resizer, Left/Right change its width by 10 pixels, Shift changes it by 1 pixel, and Home/End use its bounds. Escape returns to the header. `on_column_resize` receives `"column"`, `"width"`, and JSON `"widths"` after a keyboard adjustment or completed drag. Decode `"widths"` and assign the values back to the columns. The corresponding `olis:table-column-resize` DOM event bubbles with `{key, width, widths}`.

```heex
<.data_table id="people" rows={@people} label="People" on_column_resize="resize_column">
  <:col :let={person} key="name" label="Name" resizable width={@column_widths["name"]} min_width={100} max_width={400}>
    {person.name}
  </:col>
</.data_table>
```

```heex
<.data_table id="people" rows={@people} label="People" row_id={&to_string(&1.id)}
  row_label={& &1.name} selection_mode="multiple" selected_keys={@selected}
  on_selection_change="select_people">
  <:col :let={person} label="Name">{person.name}</:col>
</.data_table>
```

```heex
<.data_table id="people" label="People" rows={@streams.people}>
  <:col :let={person} label="Name" row_header>{person.name}</:col>
  <:col :let={person} label="Role">{person.role}</:col>
</.data_table>
```

Listboxes support `single`, `multiple`, and `none` selection. Pass `selected_keys` for LiveView-controlled selection; `on_selection_change` receives JSON-encoded `keys`, `value`, and `selected`. `on_action` receives `value` whenever an option is activated. Options support descriptions, disabled states, `text_value` for typeahead, `variant="danger"`, and non-interactive custom slot content. Group options using `:section` with a label and an `items` list. The registered Alpine providers handle keyboard navigation.

```heex
<.listbox id="workspace" label="Workspace" on_selection_change="select_workspace" selected_keys={[@workspace]}>
  <:option value="alpha" label="Alpha" />
  <:option value="beta" label="Beta" />
</.listbox>
```

Tag groups support `on_remove` events using their `"value"` parameter. For selection sets, use `selected_keys` for LiveView-controlled selection, with `on_selection_change` receiving a JSON-encoded `"keys"` parameter. They support `none`, `single`, and `multiple` selection, disabled tags, size and surface variants, and optional custom tag content. With the registered OlisUI Alpine components, arrow keys move between tags, Enter or Space selects, and Delete or Backspace removes a focused tag. The remove buttons are also individually focusable.

```heex
<.tag_group id="topics" label="Topics" selection_mode="multiple" selected_keys={@topics}
  on_selection_change="toggle_topic" on_remove="remove_topic">
  <:tag value="news" label="News" />
  <:tag value="travel" label="Travel" />
</.tag_group>
```

To customize one remove button, add `<:remove_button value="news" label="Remove news from topics">...</:remove_button>` directly inside the group. Its value matches a `:tag`; use non-interactive icon or text content. Omit the content to retain the default icon, and use `class` for button styling. Removal still uses the group's `on_remove` event.

Single selects progressively enhance to an OlisUI-styled listbox when the OlisUI Alpine providers and browser Popover API are available. Pass `open` and `on_open_change` to manage the popup in LiveView, and use form `phx-change` to keep the selected value in an assign. The native select remains the form control and fallback; multiple selects and size-based listboxes remain native. Associate a `<label for="...">` or provide an accessible label.

Autocomplete combines a select with a search field inside its popover. Use `open` and `on_open_change` to manage popup visibility in LiveView. It accepts the same option formats as `Phoenix.HTML.Form.options_for_select/2`, including groups and disabled options. Set `selection_mode="multiple"` and provide a list for multiple selection; the form name gets a `[]` suffix and an empty selection omits the form key. `clearable` adds a clear button. The registered OlisUI Alpine components and Popover API provide filtering and keyboard navigation; otherwise the native select remains available.

```heex
<.autocomplete field={@form[:country]} label="Destination" clearable open={@country_open} on_open_change="country_open_change"
  options={[{"Canada", "ca"}, {"Japan", "jp"}, {"Spain", "es"}]} />
```

The combo box filters options by label and normally submits selected option keys through a native select. Use `open` and `on_open_change` to manage popup visibility in LiveView. It accepts the same option formats as `Phoenix.HTML.Form.options_for_select/2`, including groups and disabled options; reserve the empty string for no selection. Use a form `phx-change` to receive selection changes and update its `value`. The OlisUI Alpine providers and Popover API provide the searchable interface; without them, the native select remains available.

```heex
<.combo_box field={@form[:animal]} open={@animal_open} on_open_change="animal_open_change" label="Favorite animal" placeholder="Search animals..."
  options={[{"Cat", "cat"}, {"Dog", "dog"}]} required />
```

Set `allows_custom_value` to submit text instead of option keys, including when a suggested option is chosen. With JavaScript disabled this mode remains a text input with a native datalist of enabled suggestions. The form receives ordinary input changes as the user types.

```heex
<.combo_box field={@form[:animal]} open={@animal_open} on_open_change="animal_open_change" label="Any animal" allows_custom_value
  options={[{"Cat", "cat"}, {"Dog", "dog"}]} />
```

For multiple keys, set `selection_mode="multiple"` and supply a list as `value`. The component appends `[]` to the input name, shows selected labels in the order of the LiveView `value` list and submits keys in native option order. When no options are selected, the form key is absent; treat it as an empty list. `selected_placeholder` sets the text shown when nothing is selected. Custom text and multiple selection cannot currently be combined.

```heex
<.combo_box field={@form[:animals]} open={@animals_open} on_open_change="animals_open_change" label="Favorite animals" selection_mode="multiple"
  selected_placeholder="No animals selected" options={[{"Cat", "cat"}, {"Dog", "dog"}]} />
```

Toolbars group related controls and support keyboard navigation. Provide a label and compose the controls you need:

```heex
<.toolbar label="Editing actions" attached>
  <.button phx-click="copy" variant="tertiary">Copy</.button>
  <.button phx-click="paste" variant="tertiary">Paste</.button>
</.toolbar>
```

With the OlisUI Alpine providers installed, Tab enters the toolbar at one control, arrow keys move between enabled controls, and Home and End move to the first and last controls. Set `orientation="vertical"` for up/down navigation. Text inputs and other controls retain their own arrow-key behavior. Without JavaScript, the controls remain individually reachable with Tab.

Color fields edit hex values using a normal text input. By default they accept three- or six-digit hex values, with or without `#`. With the OlisUI Alpine providers installed, blur expands shorthand and uppercases valid values; invalid edits revert to the last committed value, and the swatch follows that value. Set `allow_alpha` to accept four- or eight-digit hex values. Without JavaScript, the input remains usable and native pattern validation checks its value.

```heex
<.color_field field={@form[:brand_color]} label="Brand color" required />
<.color_field name="hue" id="hue" label="Hue" channel="hue" value={@hue} />
```

For `red`, `green`, `blue`, `hue`, `saturation`, `lightness`, `brightness`, or `alpha`, the field submits the numeric channel value: RGB channels range from 0–255, hue from 0–360, and percentage channels from 0–100. Use `min`, `max`, and `step` to override these defaults. Channel fields do not convert or synchronize a shared color automatically; update the color in your LiveView. Prefix and suffix slots allow custom content, and `show_swatch={false}` hides the default hex preview.

Color swatches display a CSS color with a transparency pattern, in `xs` through `xl` sizes and `circle` or `square` shapes. Color swatch pickers use native radio inputs, so they work with Phoenix form fields, keyboard navigation, and standard form submission without JavaScript. Provide an accessible label for each color:

```heex
<.color_swatch color="#3B82F6" label="Blue" />
<.color_swatch_picker field={@form[:accent]} label="Accent color">
  <:option value="#8B5CF6" label="Purple" />
  <:option value="#3B82F6" label="Blue" />
  <:option value="#FACC15" label="Yellow" disabled />
</.color_swatch_picker>
```

The picker supports `size`, `shape`, `layout="stack"`, `required`, disabled options, descriptions, and errors. The color values must be CSS color strings; values are submitted unchanged. Equivalent hexadecimal forms are matched regardless of letter case or shorthand. If neither a `field` nor `name` is supplied, the picker uses its `id` as the radio group name.

Toast notifications use a LiveView assign and the registered OlisUI Alpine components:

```heex
<.toast_region id="notifications" toasts={@toasts} on_dismiss="dismiss_toast" />
```

```elixir
# Each toast needs a unique string id.
update(socket, :toasts, &[%{id: "saved", title: "Changes saved", variant: "success"} | &1])

def handle_event("dismiss_toast", %{"id" => id}, socket) do
  {:noreply, update(socket, :toasts, &Enum.reject(&1, fn toast -> toast.id == id end))}
end
```

The variants are `default`, `accent`, `success`, `warning`, and `danger`. A toast can include `description`, `timeout` (milliseconds; `0` keeps it open), `is_loading`, or `action: %{label: "Undo", event: "undo", params: %{id: "123"}}`. Dismissal and timeouts request removal through `on_dismiss`; the LiveView owns the list. The stack expands and pauses timers on hover or focus, and Alt+T moves focus to it. Supply named `:indicator` slots and set a toast’s `indicator` to the slot name for custom icons.

Search fields accept a Phoenix form field or an explicit `id`, `name`, and `value`. Provide a `label` or an accessible name. With the OlisUI Alpine providers, the clear button updates the input and sends a normal input event to LiveView forms; without it, the browser's native search control remains available.

```heex
<.search_field field={@form[:query]} label="Search" placeholder="Search..." />
```

One-time-code fields use one native input for form submission, keyboard editing, paste, and device autofill. The default six slots are grouped three and three; use `length` and `groups` to configure them. `allowed_pattern` is an optional JavaScript regular expression matched against the entire intermediate value, so it should allow partial input as well as the empty string. Native `pattern` can separately specify the final form-validation rule. The registered OlisUI Alpine components render the styled slots and emit a bubbling `olis:otp-complete` event with the completed value in `event.detail.value`; without it, the native input remains usable.

```heex
<.input_otp field={@form[:code]} label="Verification code" length={6} groups={[3, 3]}
  allowed_pattern="[0-9]*" pattern="[0-9]{6}" required />
```

Tooltips show noninteractive descriptions on hover or focus using the OlisUI Alpine providers. Pass `open` and `on_open_change` and update `open` in the LiveView event handler. The default slot labels a built-in button. Use `:trigger` to wrap one existing focusable element and `:content` for rich inline content. Pass the trigger slot's attributes to the element for a server-rendered `aria-describedby`; Alpine also associates the first focusable element automatically and preserves existing description IDs. Set `placement` to `top`, `bottom`, `left`, or `right`; the tooltip flips when it would overflow. Use `show_arrow` for an arrow. `delay` and `close_delay` are milliseconds and default to the OlisUI theme values. Popovers can contain interactive content and use the OlisUI Alpine providers. Both use the browser Popover API.

```heex
<.tooltip id="save-tip" text="Save your changes" open={@tip_open} on_open_change="tip_change">Save help</.tooltip>
<.tooltip id="save-detail" open={@detail_tip_open} on_open_change="detail_tip_change" show_arrow>
  <:trigger :let={attrs}><.button {attrs}>Save</.button></:trigger>
  <:content><strong>Save</strong> your changes.</:content>
</.tooltip>
<.popover id="details" trigger="Details" title="More information" open={@details_open} on_open_change="details_change">
  <p>Additional content</p>
</.popover>
```

Popovers accept `placement` (`"top"`, `"bottom"`, `"left"`, or `"right"`, optionally followed by `" start"` or `" end"`), `offset`, `should_flip`, and `show_arrow`. Use `content_class` for Tailwind sizing and `show_close={false}` for content without the default close button. A `:trigger_content` slot can render a custom button using the yielded attributes. Use `open` with `on_open_change` for LiveView-controlled state; the event receives `open` and `reason`. The browser's Popover API provides light dismissal and Escape handling.

```heex
<.popover id="project-details" title="Project" placement="top" show_arrow show_close={false} open={@project_open} on_open_change="project_change">
  <:trigger_content :let={attrs}><.button variant="secondary" {attrs}>Details</.button></:trigger_content>
  <p>Project details</p>
</.popover>
```

Avatars use the OlisUI Alpine providers to reveal initials if an image fails to load. Badge placement classes can be used inside `.badge_anchor`.

A checkbox accepts `indeterminate` for a mixed visual and accessible state. It is independent of `checked`: activating the control changes its checked value while the mixed state remains until the application clears `indeterminate`. Alpine keeps the native checkbox state synchronized.

Checkbox groups render native multi-value inputs and append `[]` to the supplied name. When all options are unchecked, the key is absent from the submitted form; treat it as an empty list. `required` adds an accessible instruction but group-level validation belongs on the server, since HTML checkbox `required` would require every option.

```heex
<.checkbox_group id="topics" name="user[topics]" label="Topics" value={@topics}>
  <:option value="news" label="News" />
  <:option value="events" label="Events" />
</.checkbox_group>
```

Radio groups render native radios in a labelled fieldset, so arrow-key selection and form submission follow browser behavior. Pass options with `:option` slots; optional descriptions, errors, disabled options, and horizontal layout are supported.

```heex
<.radio_group id="delivery" name="delivery" label="Delivery" value={@delivery}>
  <:option value="standard" label="Standard" />
  <:option value="express" label="Express" />
</.radio_group>
```

Checkbox and switch are native controls; include your own hidden input when your form needs an explicit unchecked value. Progress bars and progress circles accept `label`, `value`, `min`, and `max`; omit `value` for an indeterminate indicator. Meters represent a value in a known range and accept optional `value_text` for units.

Buttons default to `type="button"`; specify `type="submit"` for forms. Icon-only buttons need an accessible name, for example `<.button icon_only aria-label="Close">…</.button>`. Standard HTML and `phx-*` attributes are forwarded to the underlying element. The `class` attribute adds application classes.

Section headers and empty states are available as standalone components. The header renders a `<header>` by default; use `as="h2"` or another supported tag to match the document outline. The empty state defaults to “No results found”; pass `message` or slot content to customize it, and supply a `role` or live-region attributes when appropriate for the context.

```heex
<.header as="h2">Projects</.header>
<.empty_state role="status">No projects match your search.</.empty_state>
```

## Development

Install dependencies with `mix deps.get` and `npm ci`. Run the library checks with:

```sh
mix format --check-formatted
mix credo
mix test
npm run format:check
npm run lint
npm run lint:css
npm run test:js
```

Credo's component complexity limit reflects the existing HEEx-heavy module and is a baseline for future refactoring, not a claim that every component is simple.

The local preview uses the Phoenix Tailwind Mix integration with a pinned npm CLI; `mix preview` builds the stylesheet at startup. Rebuild or restart the preview after changing CSS. Host Phoenix applications can use their own Tailwind v4 build and watcher. Automated tests do not cover every component or browser.
