defmodule OlisAdminWeb.ComponentKit do
  @moduledoc "A collection of interactive workspace controls."
  use Phoenix.Component, global_prefixes: ~w(x-)
  import OlisUI.Base
  import OlisUI.Button
  import OlisUI.Checks
  import OlisUI.Color
  import OlisUI.Controls
  import OlisUI.Disclosure
  import OlisUI.Display
  import OlisUI.Dropdown
  import OlisUI.Feedback
  import OlisUI.Floating
  import OlisUI.Forms
  import OlisUI.Groups
  import OlisUI.NumberField
  import OlisUI.Overlays
  import OlisUI.Pagination
  import OlisUI.Progress
  import OlisUI.Select
  import OlisUI.Selection
  import OlisUI.Slider
  import OlisUI.Table
  import OlisUI.Tabs
  import OlisUI.Typography
  attr(:page, :integer, default: 1)
  attr(:state, :map, required: true)
  attr(:selected_tab, :string, required: true)
  attr(:channels, :list, required: true)
  attr(:workspace, :list, required: true)
  attr(:alignment, :list, required: true)
  attr(:pinned, :boolean, required: true)
  attr(:saved_open, :boolean, required: true)
  attr(:details_open, :boolean, required: true)
  attr(:disclosures, :list, required: true)
  attr(:overlays, :map, required: true)

  def component_kit(assigns) do
    entries = [
      %{name: "Everyday Tote", category: "Accessories", stock: "124"},
      %{name: "Linen Throw", category: "Home", stock: "48"},
      %{name: "Studio Mug Set", category: "Home", stock: "16"},
      %{name: "Travel Bottle", category: "Accessories", stock: "82"},
      %{name: "Ceramic Pour Over", category: "Home", stock: "31"},
      %{name: "Pocket Journal", category: "Stationery", stock: "76"}
    ]

    teams =
      Enum.filter(
        ["Northstar Studio", "Retail Operations", "Creative Team"],
        &String.contains?(String.downcase(&1), String.downcase(assigns.state.query))
      )

    assigns =
      assign(assigns, entries: Enum.slice(entries, (assigns.page - 1) * 2, 2), teams: teams)

    ~H"""
    <div class="grid gap-5 lg:grid-cols-2">
      <.card class="border border-border shadow-none">
        <:content>
          <.typography type="h4">Actions and labels</.typography>
          <p class="mt-1 mb-5 text-sm text-muted">Common controls for managing a workspace.</p>
          <div class="flex flex-wrap items-center gap-3">
            <.button phx-click="kit_toast">Save changes</.button><.button
              variant="secondary"
              data-olis-dialog-open="kit-drawer"
            >Open help</.button>
            <.toggle_button pressed={@pinned} phx-click="kit_pin">Pin view</.toggle_button>
          </div>
          <div class="mt-5 flex flex-wrap items-center gap-3">
            <div>
              <.button_group label="View options" variant="secondary">
                <:button :for={period <- ~w(Day Week Month)} on_click="kit_period" value={period}>{period}</:button>
              </.button_group>
              <p class="mt-2 mb-0 text-xs text-muted">Selected view: {@state.period}</p>
            </div>
            <.badge color="success" variant="soft">Active</.badge><.chip
              color="warning"
              variant="soft"
            >
              Needs review
            </.chip>
          </div>
          <p class="mt-5 mb-0 text-sm text-muted">
            Shortcut example:
            <.kbd>⌘</.kbd>

            <.kbd>K</.kbd>
            (shown as an example).
            <.ui_link href="https://hexdocs.pm/phoenix_live_view/">LiveView documentation</.ui_link>
          </p>
        </:content>
      </.card>
      <.card class="border border-border shadow-none">
        <:content>
          <.typography type="h4">Preferences</.typography>
          <p class="mt-1 mb-5 text-sm text-muted">
            Changes are held in your current LiveView session.
          </p>
          <form phx-change="kit_preferences" class="space-y-5">
            <.checkbox id="kit-digest" name="digest" checked={@state.digest}>
              Send a weekly digest
            </.checkbox>
            <.radio_group
              id="kit-delivery"
              name="delivery"
              label="Delivery frequency"
              value={@state.delivery}
              orientation="horizontal"
            >
              <:option value="daily" label="Daily" /><:option value="weekly" label="Weekly" /><:option
                value="monthly"
                label="Monthly"
              />
            </.radio_group>
            <.slider
              id="kit-threshold"
              name="threshold"
              label="Low stock threshold"
              value={@state.threshold}
            />
            <.number_field
              id="kit-quantity"
              label="Default reorder quantity"
              name="quantity"
              value={@state.quantity}
              min={1}
              max={100}
            />
          </form>
          <.tag_group
            id="kit-tags"
            label="Channels"
            selection_mode="multiple"
            selected_keys={@channels}
            on_selection_change="kit_channels"
          >
            <:tag value="online" label="Online" /><:tag value="retail" label="Retail" /><:tag
              value="wholesale"
              label="Wholesale"
            />
          </.tag_group>
        </:content>
      </.card>
      <.card class="border border-border shadow-none">
        <:content>
          <.typography type="h4">Feedback and progress</.typography>
          <p class="mt-1 mb-5 text-sm text-muted">
            Example status, progress, and loading states for a catalog import.
          </p>
          <.alert status="success" title="All systems operational">
            Your workspace is ready to use.
          </.alert>
          <div class="mt-5 space-y-5">
            <.meter label="Storage used" value={68} />
            <div class="flex items-center gap-5">
              <.progress_circle label="Import progress" value={72} /><span class="text-sm text-muted">Example import progress</span><.spinner size="sm" />
            </div>
            <.skeleton class="h-4 w-3/4 rounded-full" /><.skeleton class="h-4 w-1/2 rounded-full" />
          </div>
        </:content>
      </.card>
      <.card class="border border-border shadow-none">
        <:content>
          <.typography type="h4">Helpful details</.typography>
          <p class="mt-1 mb-5 text-sm text-muted">Keep supporting information close to the task.</p>
          <.tabs
            id="kit-tabs"
            label="Workspace details"
            selected_key={@selected_tab}
            on_selection_change="kit_tab"
          >
            <:tab id="activity" label="Activity">
              Your recent workspace activity will appear here.
            </:tab>
            <:tab id="notes" label="Notes">Use notes to share context with your team.</:tab>
          </.tabs>
          <.separator class="my-5" />
          <.disclosure
            id="kit-saved"
            title="How is this sample saved?"
            open={@saved_open}
            on_toggle="kit_disclosure"
          >
            Changes are held in your current LiveView session and reset when you reload.
          </.disclosure>
          <div class="mt-5">
            <.button variant="secondary" data-olis-dialog-open="kit-drawer">Open help panel</.button>
          </div>
          <.drawer
            id="kit-drawer"
            title="Workspace help"
            placement="right"
            open={Map.get(@overlays, "kit-drawer", false)}
            on_open_change="kit_overlay"
          >
            <p class="text-sm text-muted">
              This example uses local sample data. Explore the dashboard, create an order, and change the settings to see the components working together.
            </p>
          </.drawer>
        </:content>
      </.card>
      <.card class="border border-border shadow-none">
        <:content>
          <.header as="h3">Form building blocks</.header>
          <p class="mt-1 mb-5 text-sm text-muted">Compose fields for a custom workspace form.</p>
          <.ui_form
            :let={form}
            for={%{"email" => @state.contact_email}}
            as={:contact}
            class="space-y-4"
            phx-change="kit_contact_change"
            phx-submit="kit_contact_submit"
          >
            <.fieldset
              id="kit-contact"
              legend="Contact details"
              description="Used for delivery updates."
            >
              <.label for={form[:email].id}>Email</.label>
              <.input
                id={form[:email].id}
                name={form[:email].name}
                type="email"
                placeholder="you@example.com"
                value={@state.contact_email}
              />
              <.description>Use a shared team address.</.description>
              <span :if={@state.contact_submitted && !String.contains?(@state.contact_email, "@")}><.field_error>
                Enter a valid email address.
              </.field_error></span>
              <span :if={@state.contact_submitted && !String.contains?(@state.contact_email, "@")}><.error_message>
                Review the contact details.
              </.error_message></span>
            </.fieldset>
            <.input_group
              id="kit-price"
              name="contact[price]"
              label="Shipping price"
              value={@state.contact_price}
              type="number"
            >
              <:prefix>$</:prefix><:suffix>USD</:suffix>
            </.input_group>
            <.label for="kit-notes">Delivery notes</.label><.textarea
              id="kit-notes"
              name="contact[notes]"
              value={@state.contact_notes}
              rows="3"
              placeholder="Add a note for your team"
            />
            <.input_otp
              id="kit-otp"
              label="Verification code"
              name="contact[code]"
              value={@state.contact_code}
            />
            <.button type="submit">Check contact details</.button>
            <p
              :if={@state.contact_submitted && String.contains?(@state.contact_email, "@")}
              role="status"
              class="text-sm text-muted"
            >
              Contact details look good.
            </p>
          </.ui_form>
        </:content>
      </.card>
      <.card class="border border-border shadow-none">
        <:content>
          <.header as="h3">Preferences and team</.header>
          <p class="mt-1 mb-0 text-sm text-muted">
            Changes are held in your current LiveView session.
          </p>
          <form phx-change="kit_team_preferences" class="mt-5 space-y-5">
            <.checkbox_group id="kit-reports" name="reports" label="Reports" value={@state.reports}>
              <:option value="sales" label="Sales" /><:option value="inventory" label="Inventory" />
            </.checkbox_group>
            <.switch_group id="kit-updates" label="Updates">
              <.switch id="kit-email-updates" name="email_updates" checked={@state.email_updates}>
                Email updates
              </.switch><.switch
                id="kit-mobile-updates"
                name="mobile_updates"
                checked={@state.mobile_updates}
              >
                Mobile updates
              </.switch>
            </.switch_group>
            <.radio
              id="kit-priority"
              name="priority"
              value="normal"
              checked={@state.priority == "normal"}
            >
              Normal priority
            </.radio>
          </form>
          <div class="mt-5 space-y-5">
            <.avatar_group role="group" aria-label="Workspace team" max={3}>
              <:avatar name="Olivia Martin" /><:avatar name="Jackson Lee" /><:avatar name="Mia Chen" />
            </.avatar_group>
            <.badge_anchor>
              <.avatar name="Olivia Martin" /><.badge color="success" placement="bottom-right">
                Online
              </.badge>
            </.badge_anchor>
          </div>
        </:content>
      </.card>
      <.card class="border border-border shadow-none">
        <:content>
          <.header as="h3">Catalog and branding</.header>
          <form phx-change="kit_catalog" class="mt-5 space-y-5">
            <.autocomplete
              id="kit-country"
              open={Map.get(@overlays, "kit-country", false)}
              on_open_change="kit_overlay"
              name="country"
              value={@state.country}
              label="Shipping destination"
              options={[{"Canada", "ca"}, {"United States", "us"}]}
            />
            <.combo_box
              id="kit-category"
              open={Map.get(@overlays, "kit-category", false)}
              on_open_change="kit_overlay"
              name="category"
              value={@state.category}
              label="Product category"
              options={[{"Home", "home"}, {"Accessories", "accessories"}]}
            />
            <.color_field id="kit-brand" name="brand" label="Brand color" value={@state.brand} />
            <.color_swatch color="#D43A2C" label="Vermilion" />
            <.color_swatch_picker
              id="kit-colors"
              name="color"
              label="Accent color"
              value={@state.color}
            >
              <:option value="#D43A2C" label="Vermilion" /><:option value="#6366F1" label="Iris" />
            </.color_swatch_picker>
          </form>
          <div class="mt-5 space-y-5">
            <.listbox
              id="kit-workspaces"
              label="Workspace"
              selection_mode="single"
              selected_keys={@workspace}
              on_selection_change="kit_workspace"
            >
              <:option value="northstar" label="Northstar" /><:option value="studio" label="Studio" />
            </.listbox>
          </div>
        </:content>
      </.card>
      <.card class="border border-border shadow-none">
        <:content>
          <.header as="h3">Navigation and content</.header>
          <div class="mt-5 space-y-5">
            <.breadcrumbs label="Workspace location">
              <:item label="Workspace" href="/" /><:item label="UI kit" />
            </.breadcrumbs>
            <.surface variant="secondary" class="rounded-xl p-4">
              <.typography_prose>
                <p>Document decisions and share <strong>useful context</strong> with your team.</p>
              </.typography_prose><.ui_link href="https://elixir-lang.org">Elixir <.link_icon /></.ui_link>
            </.surface>
            <.toolbar id="kit-toolbar" label="Text formatting">
              <.toggle_button_group
                label="Alignment"
                selection_mode="single"
                selected_keys={@alignment}
                on_selection_change="kit_alignment"
              ><.toggle_button value="left">Left</.toggle_button><.toggle_button value="center">Center</.toggle_button></.toggle_button_group><.separator orientation="vertical" /><.button_group label="Editing"><.button
                variant="secondary"
                data-olis-dialog-open="kit-edit-note"
              >Edit</.button><.button_group_separator /><.button
                variant="secondary"
                phx-click="kit_toast"
              >Save</.button></.button_group>
            </.toolbar>
            <.disclosure
              id="kit-details"
              title="Workspace details"
              open={@details_open}
              on_toggle="kit_disclosure"
            >
              Northstar Studio is an example workspace.
            </.disclosure>
            <.disclosure_group
              id="kit-disclosures"
              expanded_keys={@disclosures}
              on_toggle="kit_disclosure"
            >
              <:item key="billing" title="Billing">Manage your plan and invoices.</:item><:item
                key="security"
                title="Security"
              >
                Manage access to your workspace.
              </:item>
            </.disclosure_group>
            <.scroll_shadow
              id="kit-activity"
              class="h-24 rounded-xl border border-border p-3"
              tabindex="0"
              role="region"
              aria-label="Recent activity"
            >
              <p
                :for={
                  event <- [
                    "Order received",
                    "Catalog updated",
                    "Report generated",
                    "Inventory checked"
                  ]
                }
                class="text-sm text-muted"
              >
                {event}
              </p>
            </.scroll_shadow>
            <.chip>
              <.chip_label>Featured</.chip_label>
            </.chip>
            <.empty_state as="p">No additional activity to show.</.empty_state>
          </div>
        </:content>
      </.card>
      <.card class="border border-border shadow-none">
        <:content>
          <.header as="h3">Catalog table</.header>
          <p class="mt-1 mb-5 text-sm text-muted">Browse a small sample inventory with pagination.</p>
          <.data_table id="kit-inventory" label="Sample inventory" rows={@entries}>
            <:col :let={item} label="Product" row_header>{item.name}</:col>
            <:col :let={item} label="Category">{item.category}</:col>
            <:col :let={item} label="In stock">{item.stock}</:col>
            <:footer>
              <.pagination page={@page} total_pages={3} on_change="kit_page" size="sm">
                <:summary>Page {@page} of 3</:summary>
              </.pagination>
            </:footer>
          </.data_table>
          <div class="mt-5"><.progress_bar label="Inventory reviewed" value={67} /></div>
        </:content>
      </.card>
      <.card class="border border-border shadow-none">
        <:content>
          <.header as="h3">Find a workspace</.header>
          <p class="mt-1 mb-5 text-sm text-muted">
            Search a local directory and try an annotated form.
          </p>
          <form phx-change="kit_search">
            <.search_field
              id="kit-workspace-search"
              name="query"
              value={@state.query}
              label="Search teams"
              placeholder="Search by name"
            />
          </form>
          <ul class="mt-4 space-y-2 text-sm text-muted">
            <li :for={team <- @teams}>{team}</li>
          </ul>
          <p :if={@teams == []} class="text-sm text-muted">No teams match your search.</p>
          <form phx-change="kit_project" class="mt-5 space-y-4">
            <.text_field
              id="kit-project-name"
              name="project_name"
              label="Project name"
              value={@state.project_name}
            />
            <div>
              <.label for="kit-plan">Plan</.label><.select
                id="kit-plan"
                open={Map.get(@overlays, "kit-plan", false)}
                on_open_change="kit_overlay"
                name="project_plan"
                options={[{"Standard", "standard"}, {"Priority", "priority"}]}
                value={@state.project_plan}
              />
            </div>
            <.tooltip
              id="kit-plan-help"
              open={Map.get(@overlays, "kit-plan-help", false)}
              on_open_change="kit_overlay"
              text="Select the plan that fits this project."
            >
              About plans
            </.tooltip>
          </form>
        </:content>
      </.card>
      <.card class="border border-border shadow-none">
        <:content>
          <.header as="h3">Messages and overlays</.header>
          <p class="mt-1 mb-5 text-sm text-muted">Open contextual panels and send feedback.</p>
          <div class="flex flex-wrap items-center gap-3">
            <.dropdown
              id="kit-menu"
              label="More options"
              open={Map.get(@overlays, "kit-menu", false)}
              on_open_change="kit_overlay"
            >
              <:item label="Help center" href="https://hexdocs.pm/phoenix_live_view/" />
            </.dropdown>
            <.popover
              id="kit-popover"
              open={Map.get(@overlays, "kit-popover", false)}
              on_open_change="kit_overlay"
              trigger="Quick settings"
              title="Quick settings"
            >
              <form phx-change="kit_popover_alerts">
                <.switch id="kit-popover-alerts" name="alerts" checked={@state.popover_alerts}>
                  Show workspace alerts
                </.switch>
              </form>
            </.popover>
            <.button variant="secondary" data-olis-dialog-open="kit-edit-note">Edit note</.button>
            <.button variant="secondary" data-olis-sheet-open="kit-sheet">Open sheet</.button>
            <.button variant="secondary" data-olis-dialog-open="kit-confirm">Confirm action</.button>
            <.button variant="secondary" phx-click="kit_toast">Show notification</.button>
          </div>
          <div
            :if={@state.notice_visible}
            class="mt-5 flex items-center justify-between gap-3 rounded-xl border border-border p-3"
          >
            <span class="text-sm text-muted">Your workspace is ready.</span><.close_button
              label="Dismiss message"
              phx-click="kit_dismiss_notice"
            />
          </div>
          <.modal
            id="kit-edit-note"
            open={Map.get(@overlays, "kit-edit-note", false)}
            on_open_change="kit_overlay"
            title="Edit order note"
            description="A focused editing task managed by LiveView."
          >
            <form phx-change="kit_note_change" phx-submit="kit_note_save" class="space-y-4">
              <.text_field id="kit-order-note" name="note" label="Note" value={@state.note} />
              <.button type="submit">Save note</.button>
              <p :if={@state.saved_note} role="status" class="text-sm text-muted">
                Saved in this example: {@state.saved_note}
              </p>
            </form>
          </.modal>
          <.sheet
            id="kit-sheet"
            open={Map.get(@overlays, "kit-sheet", false)}
            on_open_change="kit_overlay"
            title="Order notes"
            description="A focused area for a quick task."
          >
            <p class="text-sm text-muted">Add a note before fulfilling an order.</p><:footer>
              <.button data-olis-sheet-close>Done</.button>
            </:footer>
          </.sheet>
          <.alert_dialog
            id="kit-confirm"
            open={Map.get(@overlays, "kit-confirm", false)}
            on_open_change="kit_overlay"
            title="Confirm update"
            on_confirm="kit_toast"
            confirm_label="Confirm"
          >
            Apply this sample update to the workspace?
          </.alert_dialog>
        </:content>
      </.card>
    </div>
    """
  end
end
