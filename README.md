# HeroUI for LiveView

A starting point for a Phoenix LiveView component library inspired by [HeroUI](https://github.com/heroui-inc/heroui). It uses Phoenix function components and native HTML, with Tailwind CSS v4 and a small JavaScript module for interactive components. The initial API follows HeroUI **v3** naming where practical; this is an independent project and is not affiliated with HeroUI.

This is an early foundation, not a complete port. It currently provides button, input, text field, input group, search field, one-time-code input, combo box, date field, calendar, range calendar, card, chip, checkbox, checkbox group, switch, avatar, progress bar, progress circle, meter, spinner, separator, skeleton, textarea, radio, radio group, keyboard key, link, surface, select, accordion, alert, badge, data table, modal, alert dialog, drawer, tabs, dropdown, tooltip, popover, slider, number field, pagination, button groups, toggle buttons, breadcrumbs, listbox, and tag group components. Exact visual and behavioral parity with HeroUI and more complex interactive components are still to be built.

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
```

Restart the asset watcher after adding the dependency. The components migrated to official styles use HeroUI theme variables such as `--accent`; remaining components currently use `--hui-*` tokens. Set `data-theme="dark"` on a parent element for dark mode.

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

`translate_error/1` is the application's error translation function (Phoenix generators commonly provide one in `CoreComponents`). Errors are explicit so applications control translation and when validation appears. A standalone field needs an `id` and can receive `name`, `value`, and a list of error strings. `text_field` associates its label, description, and errors with the input. Use `.input` directly when composing your own field; give it a label or `aria-label`.

Input groups combine a native input with optional `:prefix` and `:suffix` slots. Pass `multiline` for a textarea, `variant="secondary"` for surfaces, and `full_width` to fill the available width. Slots can contain text, icons, or interactive controls; disable interactive slot controls explicitly when the field is disabled. Like `text_field`, an input group accepts a Phoenix form field and explicit error strings.

```heex
<.input_group field={@form[:price]} label="Price" type="number" full_width>
  <:prefix>$</:prefix>
  <:suffix>USD</:suffix>
</.input_group>
```

For interactive components, install the event delegation once in your application JavaScript (adjust the path to suit your asset setup):

```js
import { installHeroUI } from "../../deps/hero_ui/assets/js/hero_ui.js";
installHeroUI();
```

Open a modal with a button whose `data-hero-dialog-open` matches the modal ID:

```heex
<.button data-hero-dialog-open="edit-profile">Edit profile</.button>
<.modal id="edit-profile" title="Edit profile">
  Update your profile details here.
</.modal>
```

The native dialog contains focus and restores it on close. Escape and backdrop clicks dismiss it by default; `dismissible={false}` disables those dismissals. The Close button is always available. A LiveView mount command preserves the native `open` attribute across updates. Mount the client module once per page; the installer returns a cleanup function for teardown.

Alert dialogs and drawers use the same opener as modals. Alert dialogs require an explicit cancel or confirm action and send `on_confirm` as a LiveView event. Drawers support `top`, `bottom`, `left`, and `right` placement.

```heex
<.button data-hero-dialog-open="confirm-delete">Delete</.button>
<.alert_dialog id="confirm-delete" title="Delete item?" on_confirm="delete" confirm_label="Delete">
  This action cannot be undone.
</.alert_dialog>
```

Tabs use labelled slots and support arrow keys, Home, and End. The `selected` attribute sets the initial selection; subsequent selection is client-managed and preserved through LiveView patches. Tab IDs must be unique within a tab set and at least one tab must be enabled.

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

Dropdowns require a browser with the Popover API. Keyboard users can open with Enter, Space, or arrow keys and navigate items with arrow keys, Home, End, and type-ahead. Escape closes the menu. This initial implementation supports action and link items; sections, selection modes, and submenus are not yet implemented.

Slider and number field use native range and number inputs. They require the JavaScript installer for immediate slider output updates and number-field step buttons. Their inputs submit normally through Phoenix forms. The slider currently supports a single horizontal value; range selection and vertical orientation are not yet implemented.

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

Date fields provide editable month, day, and year segments backed by a native date input. They accept a Phoenix form field, `Date` or ISO date values, `min`, `max`, `required`, `read_only`, `disabled`, and a `locale`. The segment order follows the browser locale; values are submitted as ISO Gregorian dates. Use the arrow keys to move between or adjust segments, type digits to edit, and use Backspace or Delete to clear a segment. The native date input remains available without JavaScript. Partial and invalid dates are blocked from submission when enhanced. Localized digit entry, non-Gregorian calendars, and date-time granularities are not yet supported.

```heex
<.date_field field={@form[:date]} label="Date" min={~D[2026-01-01]} required />
```

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
