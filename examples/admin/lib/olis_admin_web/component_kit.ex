defmodule OlisAdminWeb.ComponentKit do
  @moduledoc "A collection of interactive workspace controls."
  use Phoenix.Component
  import OlisUI

  def component_kit(assigns) do
    ~H"""
    <div class="grid gap-5 lg:grid-cols-2">
      <.card class="border border-border shadow-none">
        <:content>
          <.typography type="h4">Actions and labels</.typography>
          <p class="mt-1 mb-5 text-sm text-muted">Common controls for managing a workspace.</p>
          <div class="flex flex-wrap items-center gap-3">
            <.button>Primary action</.button><.button variant="secondary">Secondary</.button>
            <.toggle_button>Pin view</.toggle_button>
          </div>
          <div class="mt-5 flex flex-wrap items-center gap-3">
            <.button_group label="View options"><:button>Day</:button><:button>Week</:button><:button>Month</:button></.button_group>
            <.badge color="success" variant="soft">Active</.badge><.chip
              color="warning"
              variant="soft"
            >
              Needs review
            </.chip>
          </div>
          <p class="mt-5 mb-0 text-sm text-muted">
            Quick tip: use
            <.kbd>⌘</.kbd>

            <.kbd>K</.kbd>
            to find a workspace item.
            <.ui_link href="https://hexdocs.pm/phoenix_live_view/">LiveView documentation</.ui_link>
          </p>
        </:content>
      </.card>
      <.card class="border border-border shadow-none">
        <:content>
          <.typography type="h4">Preferences</.typography>
          <p class="mt-1 mb-5 text-sm text-muted">
            Try the controls as you would in a settings form.
          </p>
          <div class="space-y-5">
            <.checkbox id="kit-digest" checked>Send a weekly digest</.checkbox>
            <.radio_group
              id="kit-delivery"
              name="delivery"
              label="Delivery frequency"
              value="weekly"
              orientation="horizontal"
            >
              <:option value="daily" label="Daily" /><:option value="weekly" label="Weekly" /><:option
                value="monthly"
                label="Monthly"
              />
            </.radio_group>
            <.slider id="kit-threshold" label="Low stock threshold" value={40} />
            <.number_field
              id="kit-quantity"
              label="Default reorder quantity"
              value={10}
              min={1}
              max={100}
            />
            <.tag_group
              id="kit-tags"
              label="Channels"
              selection_mode="multiple"
              default_selected_keys={["online"]}
            >
              <:tag value="online" label="Online" /><:tag value="retail" label="Retail" /><:tag
                value="wholesale"
                label="Wholesale"
              />
            </.tag_group>
          </div>
        </:content>
      </.card>
      <.card class="border border-border shadow-none">
        <:content>
          <.typography type="h4">Feedback and progress</.typography>
          <p class="mt-1 mb-5 text-sm text-muted">Communicate status while work is in progress.</p>
          <.alert status="success" title="All systems operational">
            Your workspace is ready to use.
          </.alert>
          <div class="mt-5 space-y-5">
            <.meter label="Storage used" value={68} />
            <div class="flex items-center gap-5">
              <.progress_circle label="Import progress" value={72} /><span class="text-sm text-muted">Importing your catalog</span><.spinner size="sm" />
            </div>
            <.skeleton class="h-4 w-3/4 rounded-full" /><.skeleton class="h-4 w-1/2 rounded-full" />
          </div>
        </:content>
      </.card>
      <.card class="border border-border shadow-none">
        <:content>
          <.typography type="h4">Helpful details</.typography>
          <p class="mt-1 mb-5 text-sm text-muted">Keep supporting information close to the task.</p>
          <.tabs id="kit-tabs" label="Workspace details">
            <:tab id="activity" label="Activity">
              Your recent workspace activity will appear here.
            </:tab>
            <:tab id="notes" label="Notes">Use notes to share context with your team.</:tab>
          </.tabs>
          <.separator class="my-5" />
          <.accordion title="How is this sample saved?">
            Changes are held in your current LiveView session and reset when you reload.
          </.accordion>
          <div class="mt-5">
            <.button variant="secondary" data-olis-dialog-open="kit-drawer">Open help panel</.button>
          </div>
          <.drawer id="kit-drawer" title="Workspace help" placement="right">
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
          <.ui_form :let={form} for={%{"email" => ""}} as={:contact} class="space-y-4">
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
              />
              <.description>Use a shared team address.</.description>
              <.field_error>Example validation message</.field_error>
              <.error_message>Review the contact details.</.error_message>
            </.fieldset>
            <.input_group id="kit-price" label="Shipping price" value="12" type="number">
              <:prefix>$</:prefix><:suffix>USD</:suffix>
            </.input_group>
            <.label for="kit-notes">Delivery notes</.label><.textarea
              id="kit-notes"
              rows="3"
              placeholder="Add a note for your team"
            />
            <.input_otp id="kit-otp" label="Verification code" name="code" />
          </.ui_form>
        </:content>
      </.card>
      <.card class="border border-border shadow-none">
        <:content>
          <.header as="h3">Preferences and team</.header>
          <div class="mt-5 space-y-5">
            <.checkbox_group id="kit-reports" name="reports" label="Reports" value={["sales"]}>
              <:option value="sales" label="Sales" /><:option value="inventory" label="Inventory" />
            </.checkbox_group>
            <.switch_group id="kit-updates" label="Updates">
              <.switch id="kit-email-updates" checked>Email updates</.switch><.switch id="kit-mobile-updates">
                Mobile updates
              </.switch>
            </.switch_group>
            <.radio id="kit-priority" name="priority" value="normal" checked>Normal priority</.radio>
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
          <.header as="h3">Scheduling</.header>
          <p class="mt-1 mb-5 text-sm text-muted">Choose dates and times for a campaign.</p>
          <div class="space-y-5">
            <.date_field id="kit-date" label="Start date" value={~D[2026-11-10]} />
            <.time_field id="kit-time" label="Start time" value="09:00" />
            <.date_picker
              id="kit-datepicker"
              label="Launch date"
              value={~D[2026-11-10]}
              today={~D[2026-10-31]}
            />
            <.calendar
              id="kit-calendar"
              label="Campaign date"
              value={~D[2026-11-10]}
              today={~D[2026-10-31]}
            />
            <.range_calendar
              id="kit-range"
              label="Campaign window"
              start_name="campaign[start]"
              end_name="campaign[end]"
              today={~D[2026-10-31]}
            />
          </div>
        </:content>
      </.card>
      <.card class="border border-border shadow-none">
        <:content>
          <.header as="h3">Catalog and branding</.header>
          <div class="mt-5 space-y-5">
            <.autocomplete
              id="kit-country"
              name="country"
              label="Shipping destination"
              options={[{"Canada", "ca"}, {"United States", "us"}]}
            />
            <.combo_box
              id="kit-category"
              name="category"
              label="Product category"
              options={[{"Home", "home"}, {"Accessories", "accessories"}]}
            />
            <.color_field id="kit-brand" label="Brand color" value="#E34234" />
            <.color_swatch color="#E34234" label="Vermilion" />
            <.color_swatch_picker id="kit-colors" name="color" label="Accent color" value="#E34234">
              <:option value="#E34234" label="Vermilion" /><:option value="#6366F1" label="Iris" />
            </.color_swatch_picker>
            <.listbox
              id="kit-workspaces"
              label="Workspace"
              selection_mode="single"
              default_selected_keys={["northstar"]}
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
                default_selected_keys={["left"]}
              ><.toggle_button value="left">Left</.toggle_button><.toggle_button value="center">Center</.toggle_button></.toggle_button_group><.separator orientation="vertical" /><.button_group label="Editing"><.button variant="secondary">Edit</.button><.button_group_separator /><.button variant="secondary">Copy</.button></.button_group>
            </.toolbar>
            <.disclosure id="kit-details" title="Workspace details">
              Northstar Studio is an example workspace.
            </.disclosure>
            <.disclosure_group id="kit-disclosures">
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
          <.header as="h3">Messages and overlays</.header>
          <p class="mt-1 mb-5 text-sm text-muted">Open contextual panels and send feedback.</p>
          <div class="flex flex-wrap items-center gap-3">
            <.dropdown id="kit-menu" label="More options">
              <:item label="Help center" href="https://hexdocs.pm/phoenix_live_view/" />
            </.dropdown>
            <.popover id="kit-popover" trigger="Quick settings" title="Quick settings">
              Adjust workspace preferences from one place.
            </.popover>
            <.button variant="secondary" data-olis-sheet-open="kit-sheet">Open sheet</.button>
            <.button variant="secondary" data-olis-dialog-open="kit-confirm">Confirm action</.button>
            <.button variant="secondary" phx-click="kit_toast">Show notification</.button>
          </div>
          <.toast_region id="kit-toasts" />
          <.sheet id="kit-sheet" title="Order notes" description="A focused area for a quick task.">
            <p class="text-sm text-muted">Add a note before fulfilling an order.</p><:footer>
              <.button data-olis-sheet-close>Done</.button>
            </:footer>
          </.sheet>
          <.alert_dialog
            id="kit-confirm"
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
