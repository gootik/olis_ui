defmodule HeroUI.Preview.Layout do
  use Phoenix.Component

  def root(assigns) do
    ~H"""
    <!DOCTYPE html>
    <html lang="en">
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <meta name="csrf-token" content={Plug.CSRFProtection.get_csrf_token()} />
        <title>LiveView integration preview</title>
        <link rel="stylesheet" href="/hero_ui.css" />
        <script type="module">
          import {Socket} from "/phoenix.mjs";
          import {LiveSocket} from "/phoenix_live_view.esm.js";
          import {installHeroUI} from "/hero_ui.js";
          installHeroUI();
          const csrf = document.querySelector('meta[name="csrf-token"]').content;
          const socket = new LiveSocket('/live', Socket, {params: {_csrf_token: csrf}});
          socket.connect();
          window.liveSocket = socket;
        </script>
      </head>
      <body style="background:var(--background); color:var(--foreground); padding:2rem">
        {@inner_content}
      </body>
    </html>
    """
  end
end

defmodule HeroUI.Preview.Live do
  use Phoenix.LiveView, layout: false
  import HeroUI

  def mount(_params, _session, socket) do
    rows = [
      %{id: 1, name: "Alex Kim", role: "Designer"},
      %{id: 2, name: "Jane Smith", role: "Developer"},
      %{id: 3, name: "Morgan Lee", role: "Engineer"},
      %{id: 4, name: "Taylor Brown", role: "Product Manager"}
    ]

    socket =
      socket
      |> assign(
        count: 0,
        terms: false,
        alerts: false,
        plan: "starter",
        volume: 40,
        quantity: 1,
        delivery: "standard",
        topics: ["news"],
        rows: rows,
        sort_direction: "ascending",
        page: 1,
        bold: false,
        italic: false,
        workspace: ["alpha"],
        required_choice: nil,
        search_query: "",
        birth_date: "2026-10-15",
        birth_submitted: nil,
        birth_changes: 0,
        stay_start: "2026-10-12",
        stay_end: "2026-10-16",
        submitted_stay: nil,
        appointment: "2026-10-15",
        appointment_changes: 0,
        submitted_appointment: nil,
        animal: "",
        animal_changes: 0,
        submitted_animal: nil,
        animals: ["cat"],
        submitted_animals: nil,
        animals_changes: 0,
        custom_animal: "Otter",
        submitted_custom_animal: nil,
        price: "10",
        feedback: "",
        otp_value: "",
        tag_values: ["news", "travel", "gaming", "shopping"],
        selected_tags: ["news"]
      )
      |> stream(:people, rows)

    {:ok, socket}
  end

  def handle_event("sort_people", %{"sort" => "name"}, socket) do
    direction =
      if socket.assigns.sort_direction == "ascending", do: "descending", else: "ascending"

    rows =
      Enum.sort_by(
        socket.assigns.rows,
        & &1.name,
        if(direction == "ascending", do: :asc, else: :desc)
      )

    {:noreply, assign(socket, rows: rows, sort_direction: direction)}
  end

  def handle_event("add_person", _, socket) do
    {:noreply,
     stream_insert(socket, :people, %{
       id: Enum.random(1..10000),
       name: "Morgan Lee",
       role: "Engineer"
     })}
  end

  def handle_event("page_changed", %{"page" => page}, socket) do
    {page, ""} = Integer.parse(page)
    {:noreply, assign(socket, :page, min(max(page, 1), 10))}
  end

  def handle_event("select_workspace", %{"value" => value}, socket)
      when value in ["alpha", "beta"] do
    {:noreply, assign(socket, :workspace, [value])}
  end

  def handle_event("toggle_format", %{"format" => "bold"}, socket),
    do: {:noreply, update(socket, :bold, &(!&1))}

  def handle_event("toggle_format", %{"format" => "italic"}, socket),
    do: {:noreply, update(socket, :italic, &(!&1))}

  def handle_event("required_submit", %{"choice" => value}, socket),
    do: {:noreply, assign(socket, :required_choice, value)}

  def handle_event("search", %{"query" => value}, socket),
    do: {:noreply, assign(socket, :search_query, value)}

  def handle_event("birth_change", %{"birth_date" => value}, socket),
    do: {:noreply, socket |> assign(:birth_date, value) |> update(:birth_changes, &(&1 + 1))}

  def handle_event("birth_submit", %{"birth_date" => value}, socket),
    do: {:noreply, assign(socket, :birth_submitted, value)}

  def handle_event("set_birth_date", _, socket),
    do: {:noreply, assign(socket, :birth_date, "2026-12-10")}

  def handle_event("stay_change", %{"stay" => stay}, socket),
    do: {:noreply, assign(socket, stay_start: stay["start"], stay_end: stay["end"])}

  def handle_event("stay_submit", %{"stay" => stay}, socket),
    do: {:noreply, assign(socket, :submitted_stay, "#{stay["start"]} – #{stay["end"]}")}

  def handle_event("appointment_change", %{"appointment" => value}, socket),
    do:
      {:noreply, socket |> assign(:appointment, value) |> update(:appointment_changes, &(&1 + 1))}

  def handle_event("appointment_submit", %{"appointment" => value}, socket),
    do: {:noreply, assign(socket, :submitted_appointment, value)}

  def handle_event("set_appointment", _, socket),
    do: {:noreply, assign(socket, :appointment, "2026-11-10")}

  def handle_event("animal_change", %{"animal" => value}, socket),
    do: {:noreply, socket |> assign(:animal, value) |> update(:animal_changes, &(&1 + 1))}

  def handle_event("animal_submit", %{"animal" => value}, socket),
    do: {:noreply, assign(socket, :submitted_animal, value)}

  def handle_event("animals_change", params, socket),
    do:
      {:noreply,
       socket
       |> assign(:animals, Map.get(params, "animals", []))
       |> update(:animals_changes, &(&1 + 1))}

  def handle_event("animals_submit", params, socket),
    do: {:noreply, assign(socket, :submitted_animals, Map.get(params, "animals", []))}

  def handle_event("custom_animal_change", %{"custom_animal" => value}, socket),
    do: {:noreply, assign(socket, :custom_animal, value)}

  def handle_event("custom_animal_submit", %{"custom_animal" => value}, socket),
    do: {:noreply, assign(socket, :submitted_custom_animal, value)}

  def handle_event("set_custom_animal", _, socket),
    do: {:noreply, assign(socket, :custom_animal, "Dragon")}

  def handle_event("price_change", %{"price" => value}, socket),
    do: {:noreply, assign(socket, :price, value)}

  def handle_event("feedback_change", %{"feedback" => value}, socket),
    do: {:noreply, assign(socket, :feedback, value)}

  def handle_event("otp_change", %{"code" => value}, socket),
    do: {:noreply, assign(socket, :otp_value, value)}

  def handle_event("select_tag", %{"value" => value}, socket) do
    selected = socket.assigns.selected_tags
    selected = if value in selected, do: List.delete(selected, value), else: [value | selected]
    {:noreply, assign(socket, :selected_tags, selected)}
  end

  def handle_event("remove_tag", %{"value" => value}, socket) do
    {:noreply,
     assign(socket,
       tag_values: List.delete(socket.assigns.tag_values, value),
       selected_tags: List.delete(socket.assigns.selected_tags, value)
     )}
  end

  def handle_event("increment", _, socket), do: {:noreply, update(socket, :count, &(&1 + 1))}

  def handle_event("settings", params, socket) do
    {:noreply,
     assign(socket,
       terms: params["terms"] == "true",
       alerts: params["alerts"] == "true",
       plan: params["plan"],
       volume: String.to_integer(params["volume"]),
       quantity: params["quantity"],
       delivery: params["delivery"],
       topics: Map.get(params, "topics", [])
     )}
  end

  def render(assigns) do
    ~H"""
    <main style="max-width:40rem;margin:auto">
      <.breadcrumbs>
        <:item label="Home" href="/" /><:item label="Components" href="/#buttons" /><:item label="Preview" />
      </.breadcrumbs>
      <h1 style="font-size:1.5rem;font-weight:600;margin-bottom:1rem">
        LiveView integration preview
      </h1>
      <p style="margin-bottom:1rem">Open the dialog and update its content through LiveView.</p>
      <form id="search-preview" phx-change="search" style="margin-bottom:1.5rem;max-width:336px">
        <.search_field
          id="preview-search"
          name="query"
          label="Search"
          placeholder="Search..."
          value={@search_query}
          full_width
        />
        <p id="search-state">Query: {@search_query}</p>
      </form>
      <div style="display:flex;flex-wrap:wrap;gap:2rem;margin-bottom:1.5rem">
        <.calendar
          id="year-calendar"
          label="Year picker"
          value={~D[2026-10-31]}
          today={~D[2026-10-31]}
          min={~D[2020-01-01]}
          max={~D[2030-12-31]}
          year_picker
        />
        <.calendar
          id="read-only-calendar"
          label="Read-only calendar"
          value={~D[2026-10-15]}
          today={~D[2026-10-31]}
          read_only
        />
        <.calendar
          id="disabled-calendar"
          label="Calendrier désactivé"
          value={~D[2026-10-15]}
          today={~D[2026-10-31]}
          locale="fr-FR"
          disabled
        />
      </div>
      <form
        id="date-field-preview"
        phx-change="birth_change"
        phx-submit="birth_submit"
        style="margin-bottom:1.5rem;max-width:256px"
      >
        <.date_field
          id="birth-date"
          name="birth_date"
          label="Date"
          value={@birth_date}
          description="Choose a date in 2026."
          min={~D[2026-01-01]}
          max={~D[2026-12-31]}
          required
          full_width
        />
        <.button type="submit" size="sm">Submit date field</.button>
        <.button phx-click="set_birth_date" size="sm" variant="secondary">Set December 10</.button>
        <p id="birth-state">
          Date: {@birth_date}; Submitted: {@birth_submitted || "none"}; Changes: {@birth_changes}
        </p>
      </form>
      <div style="max-width:256px;margin-bottom:1.5rem">
        <.date_field
          id="french-date"
          label="Date française"
          locale="fr-FR"
          value={~D[2026-10-15]}
          full_width
        />
      </div>
      <form
        id="range-calendar-preview"
        phx-change="stay_change"
        phx-submit="stay_submit"
        style="margin-bottom:1.5rem"
      >
        <.range_calendar
          id="stay"
          label="Trip dates"
          start_name="stay[start]"
          end_name="stay[end]"
          start_value={@stay_start}
          end_value={@stay_end}
          today={~D[2026-10-31]}
          min={~D[2026-09-01]}
          max={~D[2026-12-31]}
          unavailable_dates={[~D[2026-10-18]]}
          year_picker
          required
        />
        <.button type="submit" size="sm">Submit trip dates</.button>
        <p id="stay-state">
          Start: {@stay_start}; End: {@stay_end}; Submitted: {@submitted_stay || "none"}
        </p>
      </form>
      <form
        id="calendar-preview"
        phx-change="appointment_change"
        phx-submit="appointment_submit"
        style="margin-bottom:1.5rem"
      >
        <.calendar
          id="appointment"
          name="appointment"
          label="Event date"
          value={@appointment}
          today={~D[2026-10-31]}
          min={~D[2026-09-01]}
          max={~D[2026-12-31]}
          unavailable_dates={[~D[2026-10-18]]}
          year_picker
          required
        />
        <.button type="submit" size="sm">Submit date</.button>
        <.button phx-click="set_appointment" size="sm" variant="secondary">Set November 10</.button>
        <p id="appointment-state">
          Date: {@appointment}; Submitted: {@submitted_appointment || "none"}; Changes: {@appointment_changes}
        </p>
      </form>
      <form
        id="animals-preview"
        phx-change="animals_change"
        phx-submit="animals_submit"
        style="margin-bottom:1.5rem;max-width:256px"
      >
        <.combo_box
          id="preview-animals"
          name="animals"
          label="Favorite Animals"
          placeholder="Search animals..."
          selected_placeholder="No animals selected"
          value={@animals}
          selection_mode="multiple"
          required
          full_width
          options={[
            {"Mammals",
             [
               {"Aardvark", "aardvark"},
               {"Cat", "cat"},
               {"Dog", "dog"},
               [key: "Kangaroo", value: "kangaroo", disabled: true],
               {"Panda", "panda"}
             ]},
            {"Other", [{"Snake", "snake"}]}
          ]}
        />
        <.button type="submit" size="sm">Submit animals</.button>
        <p id="animals-state">
          Selected: {Enum.join(@animals, ", ")}; Submitted: {if @submitted_animals,
            do: Enum.join(@submitted_animals, ", "),
            else: "none"}; Changes: {@animals_changes}
        </p>
      </form>
      <form
        id="custom-animal-preview"
        phx-change="custom_animal_change"
        phx-submit="custom_animal_submit"
        style="margin-bottom:1.5rem;max-width:256px"
      >
        <.combo_box
          id="custom-animal"
          name="custom_animal"
          label="Any animal"
          placeholder="Search or type..."
          value={@custom_animal}
          allows_custom_value
          required
          full_width
          options={[
            {"Mammals",
             [{"Cat", "cat"}, {"Dog", "dog"}, [key: "Kangaroo", value: "kangaroo", disabled: true]]},
            {"Other", [{"Snake", "snake"}]}
          ]}
        />
        <.button type="submit" size="sm">Submit custom animal</.button>
        <.button phx-click="set_custom_animal" size="sm" variant="secondary">Set Dragon</.button>
        <p id="custom-animal-state">
          Value: {@custom_animal}; Submitted: {@submitted_custom_animal || "none"}
        </p>
      </form>
      <form
        id="animal-preview"
        phx-change="animal_change"
        phx-submit="animal_submit"
        style="margin-bottom:1.5rem;max-width:256px"
      >
        <.combo_box
          id="preview-animal"
          name="animal"
          label="Favorite Animal"
          placeholder="Search animals..."
          value={@animal}
          required
          full_width
          options={[
            {"Mammals",
             [
               {"Aardvark", "aardvark"},
               {"Cat", "cat"},
               {"Dog", "dog"},
               [key: "Kangaroo", value: "kangaroo", disabled: true],
               {"Panda", "panda"}
             ]},
            {"Other", [{"Snake", "snake"}]}
          ]}
        />
        <.button type="submit" size="sm">Submit animal</.button>
        <p id="animal-state">
          Selected: {@animal}; Submitted: {@submitted_animal || "none"}; Changes: {@animal_changes}
        </p>
      </form>
      <form id="price-preview" phx-change="price_change" style="margin-bottom:1.5rem;max-width:280px">
        <.input_group
          id="preview-price"
          name="price"
          label="Set a price"
          description="What customers would pay"
          type="number"
          value={@price}
          full_width
        >
          <:prefix>$</:prefix>
          <:suffix>USD</:suffix>
        </.input_group>
        <p id="price-state">Price: {@price}</p>
      </form>
      <form
        id="feedback-preview"
        phx-change="feedback_change"
        style="margin-bottom:1.5rem;max-width:360px"
      >
        <.input_group
          id="preview-feedback"
          name="feedback"
          label="Feedback"
          multiline
          rows="3"
          value={@feedback}
          full_width
        >
          <:prefix>✎</:prefix>
          <:suffix><.button phx-click="increment" size="sm" variant="ghost">Update</.button></:suffix>
        </.input_group>
        <p id="feedback-state">Feedback: {@feedback}</p>
      </form>
      <div style="max-width:280px;margin-bottom:1.5rem">
        <.input_group
          id="invalid-amount"
          label="Amount"
          type="number"
          value="-1"
          errors={["Amount must be positive"]}
          full_width
        >
          <:prefix>$</:prefix>
        </.input_group>
      </div>
      <fieldset disabled style="max-width:280px;margin-bottom:1.5rem">
        <.input_group
          id="disabled-price"
          label="Unavailable price"
          type="number"
          value="10"
          full_width
        >
          <:prefix>$</:prefix><:suffix>USD</:suffix>
        </.input_group>
      </fieldset>
      <div style="max-width:280px;margin-bottom:1.5rem">
        <.search_field
          id="invalid-search"
          label="Search error"
          value="x"
          errors={["Enter at least two characters"]}
          full_width
        />
        <.input_otp id="invalid-otp" label="Code error" value="12" errors={["Enter the full code"]} />
      </div>
      <.tag_group
        id="preview-tags"
        label="Topics"
        description="Select or remove topics"
        selection_mode="multiple"
        selected={@selected_tags}
        on_select="select_tag"
        on_remove="remove_tag"
        class="mb-6"
      >
        <:tag :for={value <- @tag_values} value={value} label={String.capitalize(value)} />
        <:tag value="disabled" label="Disabled" disabled />
      </.tag_group>
      <p id="tag-state">Selected topics: {Enum.join(@selected_tags, ", ")}</p>
      <form id="otp-preview" phx-change="otp_change" style="margin-bottom:1.5rem;max-width:280px">
        <.input_otp
          id="preview-otp"
          name="code"
          label="Verify account"
          description="Enter your six-digit code"
          allowed_pattern="[0-9]*"
          value={@otp_value}
        />
        <p id="otp-state">Digits entered: {String.length(@otp_value)}</p>
      </form>
      <.button data-hero-dialog-open="live-modal">Open modal</.button>
      <.button data-hero-dialog-open="live-alert" variant="danger-soft">Open alert dialog</.button>
      <.button data-hero-dialog-open="live-drawer" variant="secondary">Open drawer</.button>
      <.alert_dialog
        id="live-alert"
        title="Confirm update"
        confirm_label="Confirm update"
        on_confirm="increment"
      >
        This will increment the counter.
      </.alert_dialog>
      <.drawer id="live-drawer" title="Drawer settings" placement="right">
        <p id="drawer-count">Drawer updates: {@count}</p>
        <.button phx-click="increment">Update drawer</.button>
      </.drawer>
      <.tooltip id="preview-tip" text="This is a helpful hint" delay={0}>Hover or focus</.tooltip>
      <.popover id="preview-popover" trigger="Open popover" title="Quick settings">
        <p id="popover-count">Popover updates: {@count}</p>
        <.button phx-click="increment">Update popover</.button>
      </.popover>
      <.dropdown id="preview-actions" label="Actions">
        <:item label="Update count" on_click="increment" />
        <:item label="Unavailable" disabled />
        <:item label="Open gallery" href="/" />
      </.dropdown>
      <div style="display:flex; gap:1rem; align-items:center; margin:1rem 0">
        <.avatar
          name="Casey Jones"
          src={if @count > 0, do: "/avatar-demo.svg", else: "/missing-avatar.png"}
        />
        <.avatar name="Alex Kim" color="accent" variant="soft" />
        <.badge_anchor>
          <.avatar name="Jane Doe" /><.badge color="danger" size="sm" placement="top-right">3</.badge>
        </.badge_anchor>
      </div>
      <.alert title="Profile updated" color="success">Your settings are saved.</.alert>
      <div style="display:flex;gap:1rem;margin:1rem 0">
        <.button_group label="Editing actions"><.button variant="secondary">Copy</.button><.button variant="secondary">Paste</.button></.button_group>
        <.toggle_button_group label="Text formatting"><.toggle_button
          pressed={@bold}
          phx-click="toggle_format"
          phx-value-format="bold"
        >Bold</.toggle_button><.toggle_button
          pressed={@italic}
          phx-click="toggle_format"
          phx-value-format="italic"
        >Italic</.toggle_button></.toggle_button_group>
      </div>
      <div style="width:16rem; margin:1rem 0; background:var(--surface); border-radius:1rem">
        <.listbox
          id="workspace-list"
          label="Workspace"
          on_select="select_workspace"
          selected={@workspace}
        >
          <:option value="alpha" label="Alpha" description="Main workspace" />
          <:option value="beta" label="Beta" />
          <:option value="gamma" label="Unavailable" disabled />
        </.listbox>
      </div>
      <p id="workspace-state">Workspace: {Enum.join(@workspace)}</p>
      <p id="format-state">Bold: {to_string(@bold)}; Italic: {to_string(@italic)}</p>
      <p id="outside-count">Updates: {@count}</p>
      <.progress_circle label="Updates" value={min(@count, 10)} max={10} />
      <.meter
        label="Capacity"
        value={min(@count, 10)}
        max={10}
        value_text={"#{min(@count, 10)} of 10"}
      />
      <.tabs id="preview-tabs" label="Account sections">
        <:tab id="profile" label="Profile">
          <p>Profile settings</p>
        </:tab>
        <:tab id="security" label="Security">
          <p id="tab-count">Security updates: {@count}</p><.button phx-click="increment">Update tab</.button>
        </:tab>
        <:tab id="disabled" label="Disabled" disabled>Unavailable</:tab>
      </.tabs>
      <section style="margin-top:2rem">
        <h2>Sortable table</h2>
        <.data_table
          id="people-table"
          label="People"
          rows={@rows}
          sort_event="sort_people"
          sort_by="name"
          sort_direction={@sort_direction}
        >
          <:col :let={person} label="Name" sort_key="name" row_header>{person.name}</:col>
          <:col :let={person} label="Role">{person.role}</:col>
        </.data_table>
        <.pagination page={@page} total_pages={10} on_change="page_changed">
          <:summary>Page {@page} of 10</:summary>
        </.pagination>
        <h2>Streamed table</h2>
        <.data_table id="stream-table" label="Streamed people" rows={@streams.people}>
          <:col :let={person} label="Name">{person.name}</:col>
          <:col :let={person} label="Role">{person.role}</:col>
        </.data_table>
        <.button phx-click="add_person">Add person</.button>
      </section>
      <form
        phx-change="settings"
        style="display:flex; flex-direction:column; gap:1rem; margin-top:2rem"
      >
        <input type="hidden" name="terms" value="false" />
        <.checkbox id="live-terms" name="terms" checked={@terms}>Accept terms</.checkbox>
        <input type="hidden" name="alerts" value="false" />
        <.switch id="live-alerts" name="alerts" checked={@alerts}>Enable alerts</.switch>
        <label for="live-plan" class="label">Plan</label>
        <.select
          id="live-plan"
          name="plan"
          value={@plan}
          options={[{"Starter", "starter"}, {"Pro", "pro"}]}
        />
        <.slider id="live-volume" name="volume" label="Volume" value={@volume} />
        <.number_field
          id="live-quantity"
          name="quantity"
          label="Quantity"
          value={@quantity}
          min={1}
          max={5}
        />
        <.radio_group
          id="delivery"
          name="delivery"
          label="Delivery"
          value={@delivery}
          description="Choose a delivery speed."
        >
          <:option value="standard" label="Standard" description="Three to five days" />
          <:option value="express" label="Express" />
          <:option value="overnight" label="Overnight" disabled />
        </.radio_group>
        <.checkbox_group
          id="topics"
          name="topics"
          label="Interests"
          value={@topics}
          description="Choose any topics you like."
        >
          <:option value="news" label="News" description="Product announcements" />
          <:option value="events" label="Events" />
          <:option value="research" label="Research" disabled />
        </.checkbox_group>
        <p id="topics-state">Interests: {Enum.join(@topics, ", ")}</p>
        <p id="delivery-state">Delivery: {@delivery}</p>
        <p id="range-state">Volume: {@volume}; Quantity: {@quantity}</p>
        <p id="settings-state">
          Terms: {to_string(@terms)}; Alerts: {to_string(@alerts)}; Plan: {@plan}
        </p>
      </form>
      <div style="margin-top:2rem">
        <label for="grouped-plan" class="label">Grouped plans</label>
        <.select
          id="grouped-plan"
          options={[
            {"Basic", [{"Starter", "starter"}, {"Pro", "pro"}]},
            {"Other", [[key: "Disabled", value: "disabled", disabled: true]]}
          ]}
          value="starter"
        />
        <label for="native-multiple" class="label">Multiple choices</label>
        <.select
          id="native-multiple"
          name="multiple[]"
          options={[{"One", "one"}, {"Two", "two"}]}
          multiple
        />
      </div>
      <form
        phx-submit="required_submit"
        style="display:flex; flex-direction:column; gap:.5rem; margin-top:2rem"
      >
        <label for="required-choice" class="label">Required choice</label>
        <.select
          id="required-choice"
          name="choice"
          value={@required_choice}
          prompt="Choose an option"
          options={[{"Alpha", "alpha"}, {"Beta", "beta"}]}
          required
        />
        <.button type="submit">Submit choice</.button>
        <p id="required-result">Submitted: {@required_choice || "none"}</p>
      </form>
      <.modal id="live-modal" title="Live update">
        <p id="count">Server updates: {@count}</p>
        <.button phx-click="increment">Update content</.button>
      </.modal>
    </main>
    """
  end
end

defmodule HeroUI.Preview.WebRouter do
  use Phoenix.Router
  import Phoenix.LiveView.Router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, html: {HeroUI.Preview.Layout, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  scope "/" do
    pipe_through(:browser)
    live("/live-preview", HeroUI.Preview.Live)
  end

  forward("/", HeroUI.Preview.Router)
end

defmodule HeroUI.Preview.Endpoint do
  use Phoenix.Endpoint, otp_app: :hero_ui
  @session_options [store: :cookie, key: "_hero_preview", signing_salt: "previewsession"]
  socket("/live", Phoenix.LiveView.Socket,
    websocket: [connect_info: [session: @session_options]],
    longpoll: false
  )

  plug(Plug.Session, @session_options)
  plug(HeroUI.Preview.WebRouter)
end
