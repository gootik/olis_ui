# HeroUI for LiveView

A starting point for a Phoenix LiveView component library inspired by [HeroUI](https://github.com/heroui-inc/heroui). It uses Phoenix function components and native HTML, with Tailwind CSS v4 and a small JavaScript module for interactive components. The initial API follows HeroUI **v3** naming where practical; this is an independent project and is not affiliated with HeroUI.

This is an early foundation, not a complete port. It currently provides button, close button, input, text field, fieldset, input group, search field, one-time-code input, color field, color swatch, color swatch picker, autocomplete, combo box, date field, time field, date picker, calendar, range calendar, card, chip, checkbox, checkbox group, switch, switch group, avatar, avatar group, progress bar, progress circle, meter, spinner, separator, scroll shadow, skeleton, textarea, radio, radio group, keyboard key, link, surface, select, accordion, disclosure, disclosure group, alert, toast, badge, data table, modal, alert dialog, drawer, sheet, tabs, dropdown, tooltip, popover, slider, number field, pagination, toolbar, button groups, toggle buttons, breadcrumbs, listbox, and tag group components. Exact visual and behavioral parity with HeroUI and more complex interactive components are still to be built.

## Preview

Run `mix deps.get`, `npm ci`, and `mix preview`, then open [http://localhost:4000](http://localhost:4000). Press Ctrl+C twice to stop the server. Set `PORT` to use another port, for example `PORT=4001 mix preview`. The preview is a local development gallery; its example buttons do not perform application actions.

The connected LiveView integration preview is at [http://localhost:4000/live-preview](http://localhost:4000/live-preview).

## Installation

The package is not published yet. Add it as a path dependency while developing locally:

```elixir
{:hero_ui, path: "../olis-components"}
```

Run `mix deps.get`. Import the components in your application's HTML helpers (usually in `lib/my_app_web.ex`):

```elixir
import HeroUI
```

Use Tailwind CSS v4 in the host application, following the [Phoenix installation guide](https://tailwindcss.com/docs/installation/framework-guides/phoenix). Install the official styles package in the directory used by your asset build (`npm install --save-exact @heroui/styles@3.2.7`). Your Tailwind CLI must resolve that package and its dependencies. Add these imports to `assets/css/app.css` (the HeroUI import includes Tailwind):

```css
@import "@heroui/styles/css";
@import "../../deps/hero_ui/assets/css/hero_ui.css";
@source "../../deps/hero_ui/lib";
@source "../../deps/hero_ui/assets/js";
```

Restart the asset watcher after adding the dependency. The components migrated to official styles use HeroUI theme variables such as `--accent`; remaining components currently use `--hui-*` tokens. Set `data-theme="dark"` on a parent element for dark mode. The `dark:` utilities follow the explicit `.dark` class or `data-theme="dark"`, so a light theme remains light even when the operating system prefers dark mode.

## Usage

```heex
<.button phx-click="save">Save changes</.button>
<.button variant="secondary" type="submit">Continue</.button>
<.button variant="danger-soft" disabled>Delete</.button>

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

Use `<.close_button label="Dismiss notification" phx-click="dismiss" />` for an icon-only dismissal action. It defaults to `type="button"` and the accessible label `Close`; pass `disabled`, Tailwind classes, or custom icon content as needed. Like a normal button, it requires a click handler or another dismissal mechanism supplied by the surrounding component.

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

Scroll shadows fade the edges of a constrained scrollable region. Set a height or width with Tailwind classes, and give the region a label and `tabindex="0"` when keyboard users need to scroll it. Use `orientation="horizontal"`, `hide_scrollbar`, `size`, or `offset` as needed. `visibility` can explicitly select `top`, `bottom`, `left`, `right`, `both`, or `none`; the default `auto` follows scroll position. With `installHeroUI`, automatic changes dispatch a bubbling `hero:scroll-shadow-change` event and can also send a LiveView event via `on_visibility_change`, with a `"visibility"` parameter. The callback fires on changes after the initial measurement.

```heex
<.scroll_shadow id="activity" class="max-h-48" tabindex="0" role="region" aria-label="Activity">
  <p :for={event <- @events}>{event.message}</p>
</.scroll_shadow>
```

HeroUI's CSS supplies automatic fades without JavaScript in browsers that support scroll-driven animations. In other browsers, install the JavaScript module for automatic detection; explicitly selected visibility also works without it.

Avatar groups inherit `size`, `color`, and `variant` from the group, with per-avatar overrides available. Set `max` to show an automatic overflow count, use `grid` for a wrapping layout, or choose `overlap="ring"` for a solid seam. An explicit `:count` slot replaces the automatic count and supplies its own accessible label. Give meaningful groups a role and label.

```heex
<.avatar_group role="group" aria-label="Project team" max={2} variant="soft">
  <:avatar name="Jane Doe" />
  <:avatar name="Alex Kim" color="accent" />
  <:avatar name="Morgan Lee" />
</.avatar_group>
```

Time fields submit a native ISO time value and progressively enhance to keyboard-editable segments after installing the JavaScript module. They accept a Phoenix form field or `id`, `name`, and `value`, along with `min` and `max` times, validation errors, and `:prefix`/`:suffix` slots. Use `hour_cycle={12}` or `hour_cycle={24}` to override the locale, and `granularity="hour"`, `"minute"`, or `"second"` to choose the smallest displayed unit.

```heex
<.time_field field={@form[:starts_at]} label="Start time" min="09:00" max="17:00" required />
```

Switch groups arrange independent native switches. Add a `label` for a fieldset legend and set `orientation="horizontal"` for a row. Each switch submits its `value` only when checked; include a hidden input when your form needs an explicit unchecked value. Switches also accept `description`, `errors`, `label_position="start"`, and an optional `:icon` slot.

```heex
<.switch_group label="Notifications">
  <input type="hidden" name="updates" value="false" />
  <.switch id="updates" name="updates" checked={@updates}>Product updates</.switch>
</.switch_group>
```

Input groups combine a native input with optional `:prefix` and `:suffix` slots. Pass `multiline` for a textarea, `variant="secondary"` for surfaces, and `full_width` to fill the available width. Slots can contain text, icons, or interactive controls; disable interactive slot controls explicitly when the field is disabled. Like `text_field`, an input group accepts a Phoenix form field and explicit error strings.

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
import { registerHeroUIAlpine } from "../../deps/hero_ui/assets/js/alpine.js";
import { installHeroUI } from "../../deps/hero_ui/assets/js/hero_ui.js";

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

Start Alpine and connect the LiveSocket only once. Search Field, Number Field, Tabs, grouped Accordion, and Disclosure use Alpine for their client-side behavior; other interactive components still use `installHeroUI` while they are migrated. Phoenix LiveView JS commands handle patch-aware client operations where appropriate.

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

Sheets are swipeable modal panels. Open one with `data-hero-sheet-open`, close it with `data-hero-sheet-close` or its built-in close button, and choose `placement="bottom"`, `"top"`, `"left"`, or `"right"`. `detached` adds space around the panel. Use `snap_points` for partial positions; numbers are pixels and strings support `px`, `%`, `vh`, `vw`, `rem`, and `em` units. A fully expanded position is added automatically. Sheets can be nested and use native modal focus containment.

```heex
<.button data-hero-sheet-open="filters">Filters</.button>
<.sheet id="filters" title="Filters" snap_points={[240, "60%"]}>
  Choose the filters to apply.
  <:footer><.button data-hero-sheet-close>Done</.button></:footer>
</.sheet>
```

For LiveView-controlled state, pass `open={@sheet_open}` and `on_open_change="sheet_open_change"`. The event sends `"open"` as `"true"` or `"false"` and a `"reason"` of `"trigger"`, `"close"`, `"backdrop"`, `"escape"`, `"swipe"`, or `"parent"` when an ancestor sheet closes; update the assign in your handler. Omit `open` to manage the sheet in the browser, optionally setting `default_open`. Set `dismissible={false}` to prevent outside, Escape, and swipe dismissal; explicit close buttons still work.

The native dialog contains focus and restores it on close. Escape and backdrop clicks dismiss it by default; `dismissible={false}` disables those dismissals. The Close button is always available. A LiveView mount command preserves the native `open` attribute across updates. Mount the client module once per page; the installer returns a cleanup function for teardown.

Alert dialogs and drawers use the same opener as modals. Alert dialogs require an explicit cancel or confirm action and send `on_confirm` as a LiveView event. Drawers support `top`, `bottom`, `left`, and `right` placement.

```heex
<.button data-hero-dialog-open="confirm-delete">Delete</.button>
<.alert_dialog id="confirm-delete" title="Delete item?" on_confirm="delete" confirm_label="Delete">
  This action cannot be undone.
</.alert_dialog>
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

Dropdowns require a browser with the Popover API and the HeroUI JavaScript installer. Keyboard users can open with Enter, Space, or arrow keys and navigate items with arrow keys, Home, End, and type-ahead. Arrow keys open and close submenus according to text direction; Escape closes the current menu and restores focus.

Slider and number field use native range and number inputs. Install the HeroUI JavaScript for slider pointer interaction and live output, and register the HeroUI Alpine components for number-field step buttons. Inputs submit through Phoenix forms.

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

Toggle buttons are controlled by LiveView: handle `phx-click` and update the `pressed` attribute. Group related buttons with `.button_group` or `.toggle_button_group`; breadcrumbs use `:item` slots and mark the last item as the current page.

Pagination supports either LiveView events (`on_change`) or URL generation (`href={fn page -> ... end}`). The event receives the requested page as `"page"`; the application owns page bounds, loading, and URL state. Use the optional `:summary` slot for result counts.

Tables accept lists or LiveView streams. Give a stream table a unique `id`; the component supplies the stream container and row IDs. For server-driven sorting, add `sort_key` to a column and set `sort_event`, `sort_by`, and `sort_direction`. The event receives the selected key as `"sort"`; your LiveView sorts the data and updates those assigns. Stream empty states must be handled by the caller.

```heex
<.data_table id="people" label="People" rows={@streams.people}>
  <:col :let={person} label="Name" row_header>{person.name}</:col>
  <:col :let={person} label="Role">{person.role}</:col>
</.data_table>
```

Listboxes are server-controlled. `on_select` receives a `"value"` parameter; update the `selected` list in response. They support single or multiple selection, disabled options, descriptions, and keyboard navigation. `installHeroUI` provides the keyboard behavior.

```heex
<.listbox id="workspace" label="Workspace" on_select="select_workspace" selected={[@workspace]}>
  <:option value="alpha" label="Alpha" />
  <:option value="beta" label="Beta" />
</.listbox>
```

Tag groups are also server-controlled. Handle `on_select` and `on_remove` events using their `"value"` parameter, then update the selected list or tag slots. They support `none`, `single`, and `multiple` selection, disabled tags, size and surface variants, and optional custom tag content. With the JavaScript installer, arrow keys move between tags, Enter or Space selects, and Delete or Backspace removes a focused tag. The remove buttons are also individually focusable.

```heex
<.tag_group id="topics" label="Topics" selection_mode="multiple" selected={@topics}
  on_select="toggle_topic" on_remove="remove_topic">
  <:tag value="news" label="News" />
  <:tag value="travel" label="Travel" />
</.tag_group>
```

Single selects progressively enhance to a HeroUI-styled listbox when the JavaScript installer and browser Popover API are available. The native select remains the form control and fallback; multiple selects and size-based listboxes remain native. Associate a `<label for="...">` or provide an accessible label.

Autocomplete combines a select with a search field inside its popover. It accepts the same option formats as `Phoenix.HTML.Form.options_for_select/2`, including groups and disabled options. Set `selection_mode="multiple"` and provide a list for multiple selection; the form name gets a `[]` suffix and an empty selection omits the form key. `clearable` adds a clear button. The JavaScript installer and Popover API provide filtering and keyboard navigation; otherwise the native select remains available.

```heex
<.autocomplete field={@form[:country]} label="Destination" clearable
  options={[{"Canada", "ca"}, {"Japan", "jp"}, {"Spain", "es"}]} />
```

The combo box filters options by label and normally submits selected option keys through a native select. It accepts the same option formats as `Phoenix.HTML.Form.options_for_select/2`, including groups and disabled options; reserve the empty string for no selection. Use a form `phx-change` to receive selection changes and update its `value`. The JavaScript installer and Popover API provide the searchable interface; without them, the native select remains available.

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

With `installHeroUI`, Tab enters the toolbar at one control, arrow keys move between enabled controls, and Home and End move to the first and last controls. Set `orientation="vertical"` for up/down navigation. Text inputs and other controls retain their own arrow-key behavior. Without JavaScript, the controls remain individually reachable with Tab.

Color fields edit hex values using a normal text input. By default they accept three- or six-digit hex values, with or without `#`. With JavaScript installed, blur expands shorthand and uppercases valid values; invalid edits revert to the last committed value, and the swatch follows that value. Set `allow_alpha` to accept four- or eight-digit hex values. Without JavaScript, the input remains usable and native pattern validation checks its value.

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

Toast notifications need one region inside your LiveView and the JavaScript installer. Send a notification from the server with `push_event/3`:

```heex
<.toast_region id="notifications" placement="bottom-end" />
```

```elixir
{:noreply, push_event(socket, "hero:toast", %{
  id: "saved", title: "Changes saved", description: "Your preferences have been updated.",
  variant: "success", timeout: 4000
})}
```

The variants are `default`, `accent`, `success`, `warning`, and `danger`. A timeout of `0` keeps a toast open. Optional `action: %{label: "Undo", event: "undo", params: %{id: "123"}}` renders a LiveView action button; place the region inside the LiveView that handles that event. Use `region` to target a specific region when there is more than one. The stack expands and pauses its timers on hover or focus; Alt+T moves focus to it.

From JavaScript, import `toast`, `updateToast`, `dismissToast`, or `clearToasts` from `hero_ui.js`. `toast("Saved", {variant: "success"})` returns an ID; pass it to `updateToast(id, {title: "Updated"})` or `dismissToast(id)`. LiveView can also push `hero:toast-update`, `hero:toast-close`, and `hero:toast-clear` events. Custom indicator content and promise helpers are not implemented yet.

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

One-time-code fields use one native input for form submission, keyboard editing, paste, and device autofill. The default six slots are grouped three and three; use `length` and `groups` to configure them. `allowed_pattern` is an optional JavaScript regular expression matched against the entire intermediate value, so it should allow partial input as well as the empty string. Native `pattern` can separately specify the final form-validation rule. The JavaScript installer renders the styled slots and emits a bubbling `hero:otp-complete` event with the completed value in `event.detail.value`; without it, the native input remains usable.

```heex
<.input_otp field={@form[:code]} label="Verification code" length={6} groups={[3, 3]}
  allowed_pattern="[0-9]*" pattern="[0-9]{6}" required />
```

Tooltips show plain descriptive text on hover or focus. The trigger slot is rendered inside a button and should not contain another interactive element. Popovers can contain interactive content; both use the browser Popover API and require the JavaScript installer.

```heex
<.tooltip id="save-tip" text="Save your changes">Save help</.tooltip>
<.popover id="details" trigger="Details" title="More information">
  <p>Additional content</p>
</.popover>
```

Avatars use the JavaScript installer to reveal initials if an image fails to load. Badge placement classes can be used inside `.badge_anchor`.

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

## Development

Run `mix deps.get`, `npm ci`, `mix tailwind preview`, `mix format --check-formatted`, and `mix test`. The local preview uses the Phoenix Tailwind Mix integration with a pinned npm CLI; `mix preview` builds the stylesheet at startup. Rebuild or restart the preview after changing CSS. Host Phoenix applications can use their own Tailwind v4 build and watcher.
