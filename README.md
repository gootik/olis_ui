# HeroUI for LiveView

A starting point for a Phoenix LiveView component library inspired by [HeroUI](https://github.com/heroui-inc/heroui). It uses Phoenix function components and native HTML, with Tailwind CSS v4 and a small JavaScript module for interactive components. The initial API follows HeroUI **v3** naming where practical; this is an independent project and is not affiliated with HeroUI.

This is an early foundation, not a complete port. It currently provides button, close button, input, text field, fieldset, input group, search field, one-time-code input, color field, color swatch, color swatch picker, autocomplete, combo box, date field, time field, date picker, calendar, range calendar, card, chip, checkbox, checkbox group, switch, switch group, avatar, avatar group, progress bar, progress circle, meter, spinner, separator, scroll shadow, skeleton, textarea, radio, radio group, keyboard key, link, surface, select, accordion, disclosure, disclosure group, alert, toast, badge, data table, modal, alert dialog, drawer, sheet, tabs, dropdown, tooltip, popover, slider, number field, pagination, toolbar, button groups, toggle buttons, breadcrumbs, listbox, and tag group components. Exact visual and behavioral parity with HeroUI and more complex interactive components are still to be built.

## Preview

Run `mix deps.get`, `npm ci`, and `mix preview`, then open [http://localhost:4000](http://localhost:4000). Press Ctrl+C twice to stop the server. Set `PORT` to use another port, for example `PORT=4001 mix preview`. The preview is a local development gallery; its example buttons do not perform application actions.

The connected LiveView integration preview is at [http://localhost:4000/live-preview](http://localhost:4000/live-preview).

For a review, use the sidebar to move between these sections and the top-right control to switch themes:

- **Forms:** text and input groups, search, autocomplete, combo boxes, and validation.
- **Selection & navigation:** buttons, checkboxes, switches, sliders, lists, tags, tabs, and accordions.
- **Overlays:** sheets, dropdowns, tooltips, dialogs, drawers, and popovers.
- **Feedback:** toasts, alerts, chips, avatars, and progress indicators.
- **Data display:** cards, surfaces, typography, breadcrumbs, shortcuts, skeletons, pagination, and tables.
- **Colors** and **Dates & calendars:** the existing color, date, time, and calendar examples. ColorPicker, DatePicker, and DateRangePicker need further work and were deferred.

The live preview includes examples driven by LiveView, including selection, sorting, forms, and notifications. Browser find can locate a component by the title on its preview card. The project is unpublished and the preview is intended for review; it does not establish complete visual, behavior, or accessibility parity with HeroUI.

## Installation

The package is not published yet. The examples below assume your Phoenix project and this checkout are sibling directories, with this checkout named `olis-components`. Add it as a path dependency while developing locally:

```elixir
{:hero_ui, path: "../olis-components"}
```

Run `mix deps.get`. To use the unqualified component names shown below, replace the existing CoreComponents import in your application's HTML helpers (usually in `lib/my_app_web.ex`) with the following, using your application's module name:

```elixir
import MyAppWeb.CoreComponents, except: [button: 1, input: 1, header: 1]
import HeroUI
```

Generated Phoenix templates may rely on the original CoreComponents APIs; update those calls when switching imports. To keep the generated components unchanged, keep the existing import and call HeroUI components explicitly, for example `<HeroUI.button>Save</HeroUI.button>`, instead of importing `HeroUI` globally.

Use Tailwind CSS v4 in the host application, following the [Phoenix installation guide](https://tailwindcss.com/docs/installation/framework-guides/phoenix). Install the official styles package in the directory used by your asset build (`npm install --save-exact @heroui/styles@3.2.7`). Your Tailwind CLI must resolve that package and its dependencies. Add these imports to `assets/css/app.css` (the HeroUI import includes Tailwind):

```css
@import "@heroui/styles/css";
@import "../../../olis-components/assets/css/hero_ui.css";
@source "../../../olis-components/lib";
@source "../../../olis-components/assets/js";
```

These paths are relative to `assets/css/app.css`; adjust them if the checkout is elsewhere. A Git dependency checked out by Mix under `deps/hero_ui` instead uses `../../deps/hero_ui/...`. Restart the asset watcher after adding the dependency. The components migrated to official styles use HeroUI theme variables such as `--accent`; remaining components currently use `--hui-*` tokens. Set `data-theme="dark"` on a parent element for dark mode. The `dark:` utilities follow the explicit `.dark` class or `data-theme="dark"`, so a light theme remains light even when the operating system prefers dark mode.

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

The standalone label, link, typography, and spinner components use HeroUI's styles and native HTML. A required label displays an indicator; set `required` on the input as well. Links accept `href`, `patch`, or `navigate`. Spinners default to the accent color and announce `Loading`; pass a descriptive `label`, or use `decorative` inside an already named control. A switch with `read_only` remains focusable and submits its checked value; preventing user changes requires the HeroUI Alpine setup.

Skeletons accept `animation_type="shimmer"`, `"pulse"`, or `"none"`, for example `<.skeleton animation_type="pulse" class="h-4 w-40" />`. When omitted, Alpine reads the document root's `--skeleton-animation` at initialization; without Alpine or a supported value, shimmer is used. Set `animation_type="none"` on child skeletons inside a parent with `skeleton--shimmer` for a synchronized effect.

Progress bars and meters accept a visible `label`, or `aria-label`/`aria-labelledby` for a label-free indicator. Set `show_value={false}` to display just the track, and use `value_text` for a custom visible and accessible value. Progress bars and circles start at zero; pass `indeterminate` when the amount of progress is unknown (`value={nil}` also remains supported). A circle's label is accessible by default and can be displayed with `show_label`.

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
<.ui_link href="https://heroui.com" target="_blank" rel="noopener noreferrer">HeroUI <.link_icon /></.ui_link>
<.typography type="h2">Your account</.typography>
<.spinner color="success" size="sm" label="Saving" />
```

`pending` keeps a button focusable while suppressing activation and setting `aria-disabled` and `aria-busy`. A pending submit button temporarily uses `type="button"` to prevent implicit form submission. Install Alpine for the pending-state event guard; compose a spinner or other loading content inside the button when desired. Give icon-only buttons an accessible name with `aria-label`, `aria-labelledby`, or visually hidden text.

Use `<.close_button label="Dismiss notification" phx-click="dismiss" />` for an icon-only dismissal action. It defaults to `type="button"` and the accessible label `Close`; pass `disabled`, Tailwind classes, or custom icon content as needed. Like a normal button, it requires a click handler or another dismissal mechanism supplied by the surrounding component.

Cards accept `variant="default"`, `"secondary"`, `"tertiary"`, or `"transparent"`. Use `:title`, `:description`, `:content`, and `:footer` slots for HeroUI's section styles, or pass ordinary content directly. Set `heading_level` to fit the page outline and give the title an `id` when the card needs an accessible name.

Surfaces use the same four semantic background variants as HeroUI. They do not add padding, rounding, or a shadow: compose those with Tailwind classes, for example `<.surface variant="secondary" class="rounded-3xl p-6">…</.surface>`. Pass `variant="secondary"` explicitly to nested inputs when a lower-emphasis field is desired.

```heex
<.card variant="secondary" role="article" aria-labelledby="project-title">
  <:title id="project-title">Project overview</:title>
  <:description>Latest activity</:description>
  <:content>Everything is up to date.</:content>
  <:footer><.button size="sm">View project</.button></:footer>
</.card>
```

Alerts accept `status="default"`, `"accent"`, `"success"`, `"warning"`, or `"danger"` (`color` remains supported). Put the description in the default slot or use `:description`; when both are provided, the named description takes precedence. Customize the icon with `:indicator`, add controls with `:actions`, or use `:title_content` for a title containing markup. The default `role="status"` announces updates politely; use `role="alert"` for urgent messages.

```heex
<.alert status="warning" title="Payment expires soon" role="alert">
  <:description>Update your billing details.</:description>
  <:actions><.button size="sm" phx-click="review_billing">Review</.button></:actions>
</.alert>
```

Chips default to HeroUI's `secondary` variant and wrap their text in a styled label. Use `:prefix` and `:suffix` for icons or other content beside the label, and mark decorative icons `aria-hidden="true"`. For full control over the children, set `wrap_label={false}` and use `.chip_label` where needed.

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

Scroll shadows fade the edges of a constrained scrollable region. Set a height or width with Tailwind classes, and give the region a label and `tabindex="0"` when keyboard users need to scroll it. Use `orientation="horizontal"`, `hide_scrollbar`, `size`, or `offset` as needed. `visibility` can explicitly select `top`, `bottom`, `left`, `right`, `both`, or `none`; the default `auto` follows scroll position. With HeroUI's Alpine providers registered, automatic changes dispatch a bubbling `hero:scroll-shadow-change` event and can also send a LiveView event via `on_visibility_change`, with a `"visibility"` parameter. The callback fires on changes after the initial measurement.

```heex
<.scroll_shadow id="activity" class="max-h-48" tabindex="0" role="region" aria-label="Activity">
  <p :for={event <- @events}>{event.message}</p>
</.scroll_shadow>
```

HeroUI's CSS supplies automatic fades without JavaScript in browsers that support scroll-driven animations. In other browsers, register HeroUI's Alpine providers for automatic detection; explicitly selected visibility also works without it.

Avatar groups inherit `size`, `color`, and `variant` from the group, with per-avatar overrides available. Set `max` to show an automatic overflow count, use `grid` for a wrapping layout, or choose `overlap="ring"` for a solid seam. An explicit `:count` slot replaces the automatic count and supplies its own accessible label. Give meaningful groups a role and label.

```heex
<.avatar_group role="group" aria-label="Project team" max={2} variant="soft">
  <:avatar name="Jane Doe" />
  <:avatar name="Alex Kim" color="accent" />
  <:avatar name="Morgan Lee" />
</.avatar_group>
```

Time fields submit a native ISO time value and progressively enhance to keyboard-editable segments after registering the HeroUI Alpine components. They accept a Phoenix form field or `id`, `name`, and `value`, along with `min` and `max` times, validation errors, and `:prefix`/`:suffix` slots. Use `hour_cycle={12}` or `hour_cycle={24}` to override the locale, and `granularity="hour"`, `"minute"`, or `"second"` to choose the smallest displayed unit.

```heex
<.time_field field={@form[:starts_at]} label="Start time" min="09:00" max="17:00" required />
```

Switch groups arrange independent native switches. Add a `label` for a fieldset legend and set `orientation="horizontal"` for a row. Switches accept `field={@form[:updates]}` or an `id` and `name`. Each switch submits its `value` only when checked; include a hidden input when your form needs an explicit unchecked value. Switches also accept `description`, `errors`, `label_position="start"`, and an optional `:icon` slot. If there is no visible label, provide `aria-label` or `aria-labelledby`.

```heex
<.switch_group label="Notifications">
  <input type="hidden" name="updates" value="false" />
  <.switch id="updates" name="updates" checked={@updates}>Product updates</.switch>
</.switch_group>
```

Input groups combine a native input with optional `:prefix` and `:suffix` slots. Pass `multiline` for a textarea, `variant="secondary"` for surfaces, and `full_width` to fill the available width. Slots can contain text, icons, or interactive controls; disable interactive slot controls explicitly when the field is disabled. Like `text_field`, an input group accepts a Phoenix form field and explicit error strings. With Alpine installed, clicking a noninteractive part of the group focuses its input.

```heex
<.input_group field={@form[:price]} label="Price" type="number" full_width>
  <:prefix>$</:prefix>
  <:suffix>USD</:suffix>
</.input_group>
```

Install Alpine.js and its Collapse plugin in the host application's asset directory with `npm install alpinejs @alpinejs/collapse`. Register the plugin and the HeroUI Alpine components before starting Alpine, and preserve Alpine state when LiveView patches the DOM. Merge the `dom` callback below into your existing `LiveSocket` setup if you already have one:

```js
import Alpine from "alpinejs";
import collapse from "@alpinejs/collapse";
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import { registerHeroUIAlpine } from "../../../olis-components/assets/js/alpine.js";
import { installHeroUI } from "../../../olis-components/assets/js/hero_ui.js";

window.Alpine = Alpine;
Alpine.plugin(collapse);
registerHeroUIAlpine(Alpine);
Alpine.start();
installHeroUI();

const csrf = document.querySelector("meta[name='csrf-token']").content;
const liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrf },
  dom: {
    onBeforeElUpdated(from, to) {
      if (from._x_dataStack) Alpine.clone(from, to);
    }
  }
});
liveSocket.connect();
```

These JavaScript paths are relative to `assets/js/app.js` and follow the sibling checkout layout above. For a Git dependency under `deps/hero_ui`, use `../../deps/hero_ui/...` instead. Start Alpine and connect the LiveSocket only once. Interactive components use the registered Alpine providers; `installHeroUI` remains necessary for Calendar, DateField, and DatePicker. Phoenix LiveView JS commands handle patch-aware client operations where appropriate.

Accordion groups use keyed item slots. By default only one item can be open; use `allows_multiple_expanded` for independent panels. `default_expanded_keys` initializes browser-managed state, while `expanded_keys` and `on_expanded_change` let LiveView control it. The event receives `"key"`, `"expanded"` (`"true"` or `"false"`), and `"keys"` (a JSON-encoded list). Update the assign in the event handler. Set `variant="surface"`, `hide_separator`, `disabled`, or `heading_level` as needed; individual items also accept `disabled`. An optional `:indicator` slot replaces the chevron. The earlier `<.accordion title="...">...</.accordion>` form remains available as a native disclosure.

```heex
<.accordion id="faq" default_expanded_keys={["orders"]}>
  <:item key="orders" title="How do I order?">Add items to your cart and check out.</:item>
  <:item key="returns" title="Can I return an item?">Contact us within 30 days.</:item>
</.accordion>
```

Disclosures use native `<details>` and open and close without JavaScript. A group permits one open item by default; add `allows_multiple_expanded` to allow several. Use `default_expanded_keys` for browser-managed state or pass `expanded_keys` and `on_toggle` to manage state in LiveView. The toggle event sends the item `"key"` and the desired `"expanded"` state as `"true"` or `"false"`; update `expanded_keys` in the event handler. Alpine synchronizes state and LiveView event values. Native CSS animates the disclosure in browsers that support `::details-content` and `interpolate-size`; other browsers open and close it immediately.

```heex
<.disclosure_group id="settings" default_expanded_keys={["account"]}>
  <:item key="account" title="Account">Account settings</:item>
  <:item key="billing" title="Billing">Billing settings</:item>
</.disclosure_group>
```

Open a modal with a button whose `data-hero-dialog-open` matches the modal ID:

```heex
<.button data-hero-dialog-open="edit-profile">Edit profile</.button>
<.modal id="edit-profile" title="Edit profile">
  Update your profile details here.
</.modal>
```

Modal supports `placement="auto" | "top" | "center" | "bottom"`, `backdrop="opaque" | "blur" | "transparent"`, `scroll="inside" | "outside"`, and sizes through `cover` and `full`. `dismissible={false}` prevents backdrop dismissal; `keyboard_dismiss_disabled` separately disables Escape. For LiveView-controlled state, pass `open` and `on_open_change`; the event receives `"open"` and `"reason"`. Use `default_open` for initial client state. Slots can replace the trigger or close button:

```heex
<.modal id="settings" title="Settings" open={@settings_open} on_open_change="settings_open_change">
  <:trigger :let={attrs}><.button {attrs}>Settings</.button></:trigger>
  Update your settings.
  <:close :let={attrs}><.button {attrs}>Done</.button></:close>
</.modal>
```

Sheets are swipeable modal panels managed by the HeroUI Alpine providers. Open one with `data-hero-sheet-open`, close it with `data-hero-sheet-close` or its built-in close button, and choose `placement="bottom"`, `"top"`, `"left"`, or `"right"`. `detached` adds space around the panel. Use `snap_points` for partial positions; numbers are pixels and strings support `px`, `%`, `vh`, `vw`, `rem`, and `em` units. A fully expanded position is added automatically. Sheets can be nested and use native modal focus containment.

```heex
<.button data-hero-sheet-open="filters">Filters</.button>
<.sheet id="filters" title="Filters" snap_points={[240, "60%"]}>
  Choose the filters to apply.
  <:footer><.button data-hero-sheet-close>Done</.button></:footer>
</.sheet>
```

For LiveView-controlled state, pass `open={@sheet_open}` and `on_open_change="sheet_open_change"`. The event sends `"open"` as `"true"` or `"false"` and a `"reason"` of `"trigger"`, `"close"`, `"backdrop"`, `"escape"`, `"swipe"`, or `"parent"` when an ancestor sheet closes; update the assign in your handler. Omit `open` to manage the sheet in the browser, optionally setting `default_open`. Set `dismissible={false}` to prevent outside, Escape, and swipe dismissal; explicit close buttons still work.

The native dialog contains focus and restores it on close. Escape and backdrop clicks dismiss it by default; `dismissible={false}` disables those dismissals. The Close button is always available. The HeroUI Alpine providers manage opening and dismissal, and a LiveView mount command preserves the native `open` attribute across updates.

Alert dialogs and drawers use the same opener as modals. Alert dialogs require an explicit cancel or confirm action and send `on_confirm` as a LiveView event. Drawers support `top`, `bottom`, `left`, and `right` placement and `opaque`, `blur`, or `transparent` backdrops. The default placement is `bottom`, matching HeroUI v3; set `placement="right"` to retain the earlier default. They use the registered HeroUI Alpine providers for opening and dismissal, animate unless reduced motion is requested, and retain native focus containment during exit. Set `dismissible={false}` to prevent backdrop, Escape, and swipe dismissal.

Use `default_open` for initial browser-managed state, or pass `open={@drawer_open}` and `on_open_change="drawer_open_change"` to let LiveView control it. The event carries `"open"` and a `"reason"` (`"trigger"`, `"close"`, `"escape"`, `"backdrop"`, `"swipe"`, or `"native"`); update the assign in the handler. User actions also dispatch a bubbling `hero:drawer-open-change` browser event. For a controlled drawer, these events request a change; the parent decides whether to update `open`. Drag the header or footer to dismiss; `show_handle` adds a visible drag handle. Interactive controls and the scrollable body retain their normal behavior. Set `close_label` to change the default button text, `show_close={false}` to omit it, or provide a `:close` slot with its supplied attributes on your own button.

```heex
<.drawer id="settings" title="Settings" open={@drawer_open} on_open_change="drawer_open_change">
  Update your settings.
  <:close :let={attrs}><.button {attrs}>Done</.button></:close>
</.drawer>
```

```heex
<.button data-hero-dialog-open="confirm-delete">Delete</.button>
<.alert_dialog id="confirm-delete" title="Delete item?" on_confirm="delete" confirm_label="Delete">
  This action cannot be undone.
</.alert_dialog>
```

Pagination accepts an `on_change` LiveView event or `Phoenix.LiveView.JS` command, or a one-argument `href` or `patch` function. The application owns the current page. Use `show_pages={false}` for previous/next navigation, `show_controls={false}` for numbered pages alone, and `:previous_icon` / `:next_icon` to replace the decorative arrows. `page_label` is a function for localizing page labels.

```heex
<.pagination page={@page} total_pages={@total_pages} on_change="page_changed">
  <:summary>Page {@page} of {@total_pages}</:summary>
</.pagination>
```

Tabs use labelled slots and support arrow keys, Home, and End. By default, selection follows focus. Set `activation_mode="manual"` to move focus with arrow keys and select with Enter or Space. The `selected` or `default_selected_key` attribute sets the initial selection; subsequent selection is browser-managed and preserved through LiveView patches. For LiveView-controlled selection, pass `selected_key={@selected}` and `on_selection_change="select_tab"`; the event receives `"key"`, and the handler must update the assign. Set `orientation="vertical"`, `variant="secondary"`, `align="start"` or `"end"`, and `show_separators` as needed. Overflowing lists show scroll controls. Tab IDs must be unique within a tab set and at least one tab must be enabled.

```heex
<.tabs id="settings" label="Settings">
  <:tab id="profile" label="Profile">Profile settings</:tab>
  <:tab id="security" label="Security">Security settings</:tab>
</.tabs>
```

A dropdown uses the browser Popover API and forwards actions to LiveView:

```heex
<.dropdown id="actions" label="Actions">
  <:item label="Duplicate" on_click="duplicate" />
  <:item label="Help" href="/help" />
  <:item label="Delete" on_click="delete" danger />
</.dropdown>
```

Use sections to group items and provide each selectable item with a unique string `key` within its group. Selection can be controlled by LiveView, or managed in the browser with `default_selected_keys`:

```heex
<.dropdown id="view-options" label="View options" on_action="menu_action">
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

`selection_mode` accepts `"none"`, `"single"`, or `"multiple"` on the dropdown, a section, or a submenu item. Each group maintains its own selection. `on_selection_change` receives `"key"`, `"selected"` (`"true"` or `"false"`), and `"keys"` (a JSON-encoded list). When `selected_keys` is supplied, update it in the event handler; otherwise, `default_selected_keys` initializes browser-managed state. An item’s `on_click` or the dropdown’s `on_action` receives its `"key"` when provided. Single-selection and action menus close after selection by default; multiple-selection menus remain open. Override this with `close_on_select`.

Dropdowns require a browser with the Popover API and the HeroUI Alpine providers. Keyboard users can open with Enter, Space, or arrow keys and navigate items with arrow keys, Home, End, and type-ahead. Arrow keys open and close submenus according to text direction; Escape closes the current menu and restores focus.

Slider and number field use native range and number inputs. Register the HeroUI Alpine components for slider pointer interaction and live output, and for number-field step buttons. Inputs submit through Phoenix forms.

Number fields accept `field={@form[:quantity]}` or an `id`, `name`, and `value`, plus `min`, `max`, `step`, `description`, and explicit `errors`. Buttons disable at the reachable bounds and for disabled or read-only inputs. Replace the icons using the `:increment_icon` and `:decrement_icon` slots. The native number input uses the browser's numeric entry behavior; locale-specific currency, percentage, and unit formatting are not yet implemented.

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

Toggle buttons manage their own state with Alpine when `pressed` is omitted; use `default_pressed` for the initial state. To control a toggle from LiveView, pass `pressed`, handle `phx-click`, and update the assign. Group related toggles with `.toggle_button_group`. Set `selection_mode="single"` or `"multiple"` to coordinate children, each with a unique `value`, `data-key`, or `id`; omit it to keep independent toggles. Managed groups support `selected_keys` or `default_selected_keys`, `disallow_empty_selection`, and `on_selection_change`, which receives the full key list as a JSON string in `"keys"`. With Alpine, a group `size` applies to children without an explicit size; `disabled` natively disables every descendant. Breadcrumbs use `:item` slots and mark the last item as the current page.

Pagination supports either LiveView events (`on_change`) or URL generation (`href={fn page -> ... end}`). The event receives the requested page as `"page"`; the application owns page bounds, loading, and URL state. Use the optional `:summary` slot for result counts.

Tables accept lists or LiveView streams. Give a stream table a unique `id`; the component supplies the stream container and row IDs. The `:empty` slot customizes the empty message for both lists and streams, and `:footer` places pagination or other content inside the HeroUI table footer. For server-driven sorting, add `sort_key` to a column and set `sort_event`, `sort_by`, and `sort_direction`. The event receives the selected key as `"sort"`; your LiveView sorts the data and updates those assigns.

With Alpine, tables use grid keyboard navigation: Tab enters the grid, Up and Down move between rows, Right enters cells, and Left returns to the row. Home and End move to the first or last row or cell. Enter or Space activates sorting or selection. To interact with a cell's controls, press Enter to focus the first control; Tab and Shift+Tab move between controls, and Escape returns to the cell. Controls keep their native keyboard behavior while focused. Without Alpine, the native table and its controls remain available.

For infinite loading, give the table an `id`, set `on_load_more` to a LiveView event or JS command, and set `has_more` while another page is available. LiveView's viewport binding requests the next page when the table's end is reached. Set `loading` while fetching to suspend further requests and show a loading indicator; use the `:load_more` slot to customize that content. The LiveView owns fetching, stream insertion, and the `has_more`/`loading` assigns.

Selectable tables use `selection_mode="single"` or `"multiple"`. Supply a stable `row_id` function for list rows; streams use their stream DOM IDs as keys. `row_label` provides meaningful names for the selection controls. Pass `selected_keys` and `on_selection_change` for server-controlled selection, or `default_selected_keys` for Alpine-managed selection. The event receives a JSON-encoded `keys` list; decode it and assign the list back in controlled mode. Select-all applies to currently rendered enabled rows and preserves selections outside the rendered collection. Supply `disabled_keys` to prevent particular rows from being selected.

Add `resizable` to a `:col` to let people adjust its width by dragging the header separator or using the keyboard. `width`, `min_width`, and `max_width` are pixel values; `key` keeps a column’s locally adjusted width associated with that column through LiveView patches. With a sortable header, focus the header and press F2, then Tab to reach its resizer; on the resizer, Left/Right change its width by 10 pixels, Shift changes it by 1 pixel, and Home/End use its bounds. Escape returns to the header. `on_column_resize` receives `"column"`, `"width"`, and JSON `"widths"` after a keyboard adjustment or completed drag. The corresponding `hero:table-column-resize` DOM event bubbles with `{key, width, widths}`.

```heex
<.data_table id="people" rows={@people} label="People" on_column_resize="resize_column">
  <:col :let={person} key="name" label="Name" resizable width={220} min_width={100} max_width={400}>
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

Listboxes support `single`, `multiple`, and `none` selection. Pass `selected_keys` for controlled selection or `default_selected_keys` for browser-managed selection; `on_selection_change` receives JSON-encoded `keys`, `value`, and `selected`. `on_action` receives `value` whenever an option is activated. The legacy `on_select` API remains server-controlled: update `selected` after receiving the `value`. Options support descriptions, disabled states, `text_value` for typeahead, `variant="danger"`, and non-interactive custom slot content. Group options using `:section` with a label and an `items` list. The registered Alpine providers handle keyboard navigation and local state.

```heex
<.listbox id="workspace" label="Workspace" on_select="select_workspace" selected={[@workspace]}>
  <:option value="alpha" label="Alpha" />
  <:option value="beta" label="Beta" />
</.listbox>
```

Tag groups support server-controlled `selected` / `on_select` and `on_remove` events using their `"value"` parameter. For full selection sets, use `selected_keys` for controlled selection or `default_selected_keys` for Alpine-managed selection, with `on_selection_change` receiving a JSON-encoded `"keys"` parameter. Supplying `on_select` without either selected keys or explicit defaults retains the original server-controlled behavior. They support `none`, `single`, and `multiple` selection, disabled tags, size and surface variants, and optional custom tag content. With the registered HeroUI Alpine components, arrow keys move between tags, Enter or Space selects, and Delete or Backspace removes a focused tag. The remove buttons are also individually focusable.

```heex
<.tag_group id="topics" label="Topics" selection_mode="multiple" selected={@topics}
  on_select="toggle_topic" on_remove="remove_topic">
  <:tag value="news" label="News" />
  <:tag value="travel" label="Travel" />
</.tag_group>
```

To customize one remove button, add `<:remove_button value="news" label="Remove news from topics">...</:remove_button>` directly inside the group. Its value matches a `:tag`; use non-interactive icon or text content. Omit the content to retain the default icon, and use `class` for button styling. Removal still uses the group's `on_remove` event.

Single selects progressively enhance to a HeroUI-styled listbox when the HeroUI Alpine providers and browser Popover API are available. The native select remains the form control and fallback; multiple selects and size-based listboxes remain native. Associate a `<label for="...">` or provide an accessible label.

Autocomplete combines a select with a search field inside its popover. It accepts the same option formats as `Phoenix.HTML.Form.options_for_select/2`, including groups and disabled options. Set `selection_mode="multiple"` and provide a list for multiple selection; the form name gets a `[]` suffix and an empty selection omits the form key. `clearable` adds a clear button. The registered HeroUI Alpine components and Popover API provide filtering and keyboard navigation; otherwise the native select remains available.

```heex
<.autocomplete field={@form[:country]} label="Destination" clearable
  options={[{"Canada", "ca"}, {"Japan", "jp"}, {"Spain", "es"}]} />
```

The combo box filters options by label and normally submits selected option keys through a native select. It accepts the same option formats as `Phoenix.HTML.Form.options_for_select/2`, including groups and disabled options; reserve the empty string for no selection. Use a form `phx-change` to receive selection changes and update its `value`. The HeroUI Alpine providers and Popover API provide the searchable interface; without them, the native select remains available.

```heex
<.combo_box field={@form[:animal]} label="Favorite animal" placeholder="Search animals..."
  options={[{"Cat", "cat"}, {"Dog", "dog"}]} required />
```

Set `allows_custom_value` to submit text instead of option keys, including when a suggested option is chosen. With JavaScript disabled this mode remains a text input with a native datalist of enabled suggestions. The form receives ordinary input changes as the user types.

```heex
<.combo_box field={@form[:animal]} label="Any animal" allows_custom_value
  options={[{"Cat", "cat"}, {"Dog", "dog"}]} />
```

For multiple keys, set `selection_mode="multiple"` and supply a list as `value`. The component appends `[]` to the input name, shows the selected labels in selection order, and submits keys in native option order. When no options are selected, the form key is absent; treat it as an empty list. `selected_placeholder` sets the text shown when nothing is selected. Custom text and multiple selection cannot currently be combined.

```heex
<.combo_box field={@form[:animals]} label="Favorite animals" selection_mode="multiple"
  selected_placeholder="No animals selected" options={[{"Cat", "cat"}, {"Dog", "dog"}]} />
```

Toolbars group related controls and support keyboard navigation. Provide a label and compose the controls you need:

```heex
<.toolbar label="Editing actions" attached>
  <.button phx-click="copy" variant="tertiary">Copy</.button>
  <.button phx-click="paste" variant="tertiary">Paste</.button>
</.toolbar>
```

With the HeroUI Alpine providers installed, Tab enters the toolbar at one control, arrow keys move between enabled controls, and Home and End move to the first and last controls. Set `orientation="vertical"` for up/down navigation. Text inputs and other controls retain their own arrow-key behavior. Without JavaScript, the controls remain individually reachable with Tab.

Color fields edit hex values using a normal text input. By default they accept three- or six-digit hex values, with or without `#`. With the HeroUI Alpine providers installed, blur expands shorthand and uppercases valid values; invalid edits revert to the last committed value, and the swatch follows that value. Set `allow_alpha` to accept four- or eight-digit hex values. Without JavaScript, the input remains usable and native pattern validation checks its value.

```heex
<.color_field field={@form[:brand_color]} label="Brand color" required />
<.color_field name="hue" id="hue" label="Hue" channel="hue" value={@hue} />
```

For `red`, `green`, `blue`, `hue`, `saturation`, `lightness`, `brightness`, or `alpha`, the field submits the numeric channel value: RGB channels range from 0–255, hue from 0–360, and percentage channels from 0–100. Use `min`, `max`, and `step` to override these defaults. Unlike HeroUI's React color objects, channel fields do not convert or synchronize a shared color automatically; update the color in your LiveView. Prefix and suffix slots allow custom content, and `show_swatch={false}` hides the default hex preview.

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

Toast notifications need one region inside your LiveView and the registered HeroUI Alpine components. Send a notification from the server with `push_event/3`:

```heex
<.toast_region id="notifications" placement="bottom-end" />
```

```elixir
{:noreply, push_event(socket, "hero:toast", %{
  id: "saved", title: "Changes saved", description: "Your preferences have been updated.",
  variant: "success", timeout: 4000
})}
```

The variants are `default`, `accent`, `success`, `warning`, and `danger`. A timeout of `0` keeps a toast open. Optional `action: %{label: "Undo", event: "undo", params: %{id: "123"}}` renders a LiveView action button; place the region inside the LiveView that handles that event. Use `region` to target a specific region when there is more than one. The stack expands and pauses its timers on hover or focus; Alt+T moves focus to it. Escape collapses the stack and releases focus without dismissing a toast.

From JavaScript, import `toast`, `toastPromise`, `updateToast`, `dismissToast`, or `clearToasts` from `hero_ui.js`. `toast("Saved", {variant: "success"})` returns an ID; pass it to `updateToast(id, {title: "Updated"})` or `dismissToast(id)`. LiveView can also push `hero:toast-update`, `hero:toast-close`, and `hero:toast-clear` events. Set `isLoading: true` in JavaScript or `is_loading: true` in a LiveView event to show a spinner. Loading toasts are persistent unless a timeout is supplied; updating the title or clearing the loading flag starts the region's normal timeout.

`toast.loading` creates a persistent loading toast. `toast.promise` (also exported as `toastPromise`) accepts a promise or a function returning one, shows a spinner, and updates the same toast on success or failure. It returns the toast ID; the supplied promise can be awaited separately. A formatter receives the resolved value or error and returns plain text. Pass `region` or a settlement `timeout` in the third argument; use `timeout: 0` to keep the settled toast open.

```js
toast.promise(uploadFile(), {
  loading: "Uploading…",
  success: file => `${file.name} uploaded`,
  error: "Upload failed"
}, {region: "notifications"});
```

Declare custom decorative indicators on the region, then select one by name in a toast event. Event titles and descriptions remain plain text; arbitrary event HTML is not rendered.

```heex
<.toast_region id="notifications">
  <:indicator name="star"><span class="text-warning">★</span></:indicator>
</.toast_region>
```

```elixir
push_event(socket, "hero:toast", %{title: "Added to favorites", indicator: "star"})
```

Date fields provide editable month, day, and year segments backed by a native date input. They accept a Phoenix form field, `Date` or ISO date values, `min`, `max`, `required`, `read_only`, `disabled`, and a `locale`. The segment order follows the browser locale; values are submitted as ISO Gregorian dates. Use the arrow keys to move between or adjust segments, type digits to edit, and use Backspace or Delete to clear a segment. The native date input remains available without JavaScript. Partial and invalid dates are blocked from submission when enhanced. Localized digit entry, non-Gregorian calendars, and date-time granularities are not yet supported.

```heex
<.date_field field={@form[:date]} label="Date" min={~D[2026-01-01]} required />
```

Date pickers combine the date field with a calendar popover. They accept the same field, value, bounds, and form options, plus `unavailable_dates`, `week_starts_on`, `weeks_in_month`, and `year_picker` (enabled by default). Unavailable dates are rejected both when typed and when chosen in the calendar; validate them on the server too. The popover uses the browser Popover API. Without JavaScript, the native date input remains available.

```heex
<.date_picker field={@form[:appointment]} label="Appointment"
  min={~D[2026-01-01]} unavailable_dates={[~D[2026-06-15]]} />
```

The picker currently selects Gregorian dates. Date-time granularities and non-Gregorian calendar displays remain to be implemented.

Calendars select one Gregorian date and submit an ISO date string through a native date input. They accept `Date` values or ISO strings, `min`, `max`, `unavailable_dates`, `read_only`, and `disabled`. Month and weekday labels use the browser locale unless `locale` is supplied; `week_starts_on` can override the first weekday (`0` is Sunday). Arrow keys move by day or week, Home and End move within a week, and Page Up or Page Down changes months (hold Shift to change years). The JavaScript installer renders the month grid; without it, the native date input remains available. Native date inputs cannot enforce arbitrary `unavailable_dates` without JavaScript, so validate those dates on the server too. Multiple dates and non-Gregorian calendar systems are not implemented yet.

```heex
<.calendar field={@form[:appointment]} label="Appointment date"
  min={~D[2026-01-01]} unavailable_dates={[~D[2026-12-25]]} year_picker required />
```

Set `year_picker` to make the month heading open a scrollable year grid. It respects `min` and `max`; choosing a year navigates the calendar without changing the selected date. Use arrow keys to move in the grid, Home or End to reach the bounds, and Escape to return to the heading.

Range calendars use two native date inputs and submit ISO dates. Pass `start_field` and `end_field` from a Phoenix form, or supply names and values directly:

```heex
<.range_calendar id="stay" label="Trip dates"
  start_field={@form[:start_date]} end_field={@form[:end_date]}
  min={~D[2026-01-01]} unavailable_dates={[~D[2026-06-15]]} />
```

Select a start and end date; selecting an earlier second date reverses the endpoints. By default a range cannot span an unavailable date. Set `allows_non_contiguous_ranges` to permit this. Validate ordering, bounds, and unavailable dates on the server as well, including when JavaScript is unavailable. This implementation displays one Gregorian month at a time; multi-month, week, day, and non-Gregorian views are not yet available.


Search fields accept a Phoenix form field or an explicit `id`, `name`, and `value`. Provide a `label` or an accessible name. With the JavaScript installer, the clear button updates the input and sends a normal input event to LiveView forms; without it, the browser's native search control remains available.

```heex
<.search_field field={@form[:query]} label="Search" placeholder="Search..." />
```

One-time-code fields use one native input for form submission, keyboard editing, paste, and device autofill. The default six slots are grouped three and three; use `length` and `groups` to configure them. `allowed_pattern` is an optional JavaScript regular expression matched against the entire intermediate value, so it should allow partial input as well as the empty string. Native `pattern` can separately specify the final form-validation rule. The registered HeroUI Alpine components render the styled slots and emit a bubbling `hero:otp-complete` event with the completed value in `event.detail.value`; without it, the native input remains usable.

```heex
<.input_otp field={@form[:code]} label="Verification code" length={6} groups={[3, 3]}
  allowed_pattern="[0-9]*" pattern="[0-9]{6}" required />
```

Tooltips show noninteractive descriptions on hover or focus using the HeroUI Alpine providers. The default slot labels a built-in button. Use `:trigger` to wrap one existing focusable element and `:content` for rich inline content. Pass the trigger slot's attributes to the element for a server-rendered `aria-describedby`; Alpine also associates the first focusable element automatically and preserves existing description IDs. Set `placement` to `top`, `bottom`, `left`, or `right`; the tooltip flips when it would overflow. Use `show_arrow` for an arrow. `delay` and `close_delay` are milliseconds and default to the HeroUI theme values. Popovers can contain interactive content and use the HeroUI Alpine providers. Both use the browser Popover API.

```heex
<.tooltip id="save-tip" text="Save your changes">Save help</.tooltip>
<.tooltip id="save-detail" show_arrow>
  <:trigger :let={attrs}><.button {attrs}>Save</.button></:trigger>
  <:content><strong>Save</strong> your changes.</:content>
</.tooltip>
<.popover id="details" trigger="Details" title="More information">
  <p>Additional content</p>
</.popover>
```

Popovers accept `placement` (`"top"`, `"bottom"`, `"left"`, or `"right"`, optionally followed by `" start"` or `" end"`), `offset`, `should_flip`, and `show_arrow`. Use `content_class` for Tailwind sizing and `show_close={false}` for content without the default close button. A `:trigger_content` slot can render a custom button using the yielded attributes. Use `default_open` for initial client state, or `open` with `on_open_change` for LiveView-controlled state; the event receives `open` and `reason`. The browser's Popover API provides light dismissal and Escape handling.

```heex
<.popover id="project-details" title="Project" placement="top" show_arrow show_close={false}>
  <:trigger_content :let={attrs}><.button variant="secondary" {attrs}>Details</.button></:trigger_content>
  <p>Project details</p>
</.popover>
```

Avatars use the HeroUI Alpine providers to reveal initials if an image fails to load. Badge placement classes can be used inside `.badge_anchor`.

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

Run `mix deps.get`, `npm ci`, `mix tailwind preview`, `mix format --check-formatted`, `mix test`, and `node --test test/*alpine_test.mjs`. The local preview uses the Phoenix Tailwind Mix integration with a pinned npm CLI; `mix preview` builds the stylesheet at startup. Rebuild or restart the preview after changing CSS. Host Phoenix applications can use their own Tailwind v4 build and watcher. The automated Elixir and JavaScript suites are supplemented by manual Chromium and Firefox smoke checks; they do not cover every component or browser.
