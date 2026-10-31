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
        <link rel="stylesheet" href="/live-preview.css" />
        <script>
          try { document.documentElement.dataset.theme = localStorage.getItem("preview-theme") || "light"; } catch (_) {}
        </script>
        <script type="module">
          import {Socket} from "/phoenix.mjs";
          import {LiveSocket} from "/phoenix_live_view.esm.js";
          import {installHeroUI} from "/hero_ui.js";
          installHeroUI();
          const updateNavigation = () => {
            const sections = [...document.querySelectorAll('.lp-intro, .lp-section')];
            const active = sections.filter(section => section.getBoundingClientRect().top <= 160).at(-1) || sections[0];
            document.querySelectorAll('.lp-sidebar a[href^="#"]').forEach(link => {
              const selected = link.getAttribute('href') === `#${active?.id}`;
              link.classList.toggle('is-active', selected);
              if (selected) link.setAttribute('aria-current', 'location'); else link.removeAttribute('aria-current');
            });
          };
          window.addEventListener('scroll', updateNavigation, {passive: true});
          window.addEventListener('load', updateNavigation);
          window.addEventListener('hashchange', updateNavigation);
          document.addEventListener('phx:update', updateNavigation);
          updateNavigation();
          document.addEventListener('click', event => {
            const toggle = event.target.closest('[data-preview-theme]');
            if (!toggle) return;
            const theme = document.documentElement.dataset.theme === 'dark' ? 'light' : 'dark';
            document.documentElement.dataset.theme = theme;
            try { localStorage.setItem('preview-theme', theme); } catch (_) {}
          });
          const csrf = document.querySelector('meta[name="csrf-token"]').content;
          const socket = new LiveSocket('/live', Socket, {params: {_csrf_token: csrf}});
          socket.connect();
          window.liveSocket = socket;
        </script>
      </head>
      <body class="lp-body">
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
        accent_color: "#8B5CF6",
        submitted_color: nil,
        color_changes: 0,
        toast_count: 0,
        toast_action: "none",
        booking_date: "2026-10-15",
        submitted_booking: nil,
        booking_changes: 0,
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

  def handle_event("color_change", %{"accent_color" => value}, socket),
    do: {:noreply, socket |> assign(:accent_color, value) |> update(:color_changes, &(&1 + 1))}

  def handle_event("color_submit", %{"accent_color" => value}, socket),
    do: {:noreply, assign(socket, :submitted_color, value)}

  def handle_event("set_color", _, socket),
    do: {:noreply, assign(socket, :accent_color, "#3B82F6")}

  def handle_event("show_toast", %{"variant" => variant}, socket)
      when variant in ~w(default accent success warning danger) do
    count = socket.assigns.toast_count + 1

    {:noreply,
     socket
     |> assign(:toast_count, count)
     |> push_event("hero:toast", %{
       id: "preview-#{count}",
       title: "Changes saved",
       description: "Your preferences have been updated.",
       variant: variant,
       timeout: 0,
       action: %{label: "Undo", event: "toast_undo", params: %{id: count}}
     })}
  end

  def handle_event("toast_undo", %{"id" => id}, socket),
    do: {:noreply, assign(socket, :toast_action, "Undo #{id}")}

  def handle_event("booking_change", %{"booking_date" => value}, socket),
    do: {:noreply, socket |> assign(:booking_date, value) |> update(:booking_changes, &(&1 + 1))}

  def handle_event("booking_submit", %{"booking_date" => value}, socket),
    do: {:noreply, assign(socket, :submitted_booking, value)}

  def handle_event("set_booking", _, socket),
    do: {:noreply, assign(socket, :booking_date, "2026-11-10")}

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

  attr(:title, :string, required: true)
  attr(:description, :string, default: nil)
  attr(:class, :string, default: nil)
  slot(:inner_block, required: true)

  defp preview_card(assigns) do
    ~H"""
    <article class={["lp-card", @class]}>
      <header class="lp-card-header">
        <h3>{@title}</h3>
        <p :if={@description}>{@description}</p>
      </header>
      <div class="lp-demo">{render_slot(@inner_block)}</div>
    </article>
    """
  end

  def render(assigns) do
    ~H"""
    <div class="lp-app">
      <header class="lp-topbar">
        <a href="/" class="lp-brand" aria-label="HeroUI for LiveView home"><span class="lp-brand-mark">✦</span><span>HeroUI
        <span>for LiveView</span></span></a>
        <div class="lp-top-actions">
          <span class="lp-live"><span></span> Live playground</span><button
            type="button"
            class="lp-theme"
            data-preview-theme
            aria-label="Toggle light and dark theme"
            title="Toggle theme"
          >◐</button><a class="lp-top-link" href="/">Component gallery
          <span aria-hidden="true">↗</span></a>
        </div>
      </header>
      <div class="lp-layout">
        <aside class="lp-sidebar" aria-label="Preview navigation">
          <p class="lp-nav-label">EXPLORE</p>
          <a class="lp-nav-intro is-active" href="#overview" aria-current="location"><span>Overview</span><span aria-hidden="true">↗</span></a>
          <p class="lp-nav-label lp-nav-spaced">COMPONENTS</p>
          <nav class="lp-nav">
            <a href="#forms">Forms <span>01</span></a><a href="#colors">Colors <span>02</span></a><a href="#dates">Dates &amp; calendars
            <span>03</span></a><a href="#selection">Selection &amp; navigation <span>04</span></a><a href="#overlays">Overlays
            <span>05</span></a><a href="#feedback">Feedback <span>06</span></a><a href="#data">Data display
            <span>07</span></a>
          </nav>
          <div class="lp-sidebar-note">
            <span class="lp-note-icon">✳</span><strong>Made for LiveView</strong><p>
              Try the examples. Changes are handled by a connected Phoenix LiveView.
            </p>
          </div>
        </aside>
        <main class="lp-main">
          <div id="overview" class="lp-intro">
            <div class="lp-intro-copy">
              <p class="lp-eyebrow"><span></span> THE LIVEVIEW PLAYGROUND</p><h1>
                Components,<br /><span>in motion.</span>
              </h1><p>
                Explore the building blocks, try their states, and see how they respond to real LiveView updates.
              </p><div class="lp-intro-actions">
                <a href="#forms" class="lp-primary-link">Explore components
                <span aria-hidden="true">↘</span></a><a href="/" class="lp-secondary-link">View the gallery
                <span aria-hidden="true">↗</span></a>
              </div>
            </div>
            <div class="lp-intro-panel" aria-hidden="true">
              <div class="lp-intro-panel-top"><span>COMPONENT PREVIEW</span><span>✳</span></div><div class="lp-intro-sample">
                <div class="lp-sample-icon">✦</div><div>
                  <strong>Ready to build</strong><small>Thoughtful components, connected.</small>
                </div><span class="lp-sample-check">✓</span>
              </div><div class="lp-intro-meta">
                <span><i></i> LiveView ready</span><span>01 — 07</span>
              </div>
            </div>
          </div>
          <section id="forms" class="lp-section" aria-labelledby="forms-title">
            <div class="lp-section-heading">
              <div>
                <p class="lp-kicker">COMPONENTS</p><h2 id="forms-title">Forms</h2>
              </div><p>Inputs, validation, and searchable choices.</p>
            </div>
            <div class="lp-grid">
              <.preview_card
                title="Search field"
                description="Search with a clear action and LiveView updates."
              >
                <form id="search-preview" phx-change="search">
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
              </.preview_card>
              <.preview_card
                title="Input groups"
                description="Prefix, suffix, and multiline examples."
              >
                <form id="price-preview" phx-change="price_change">
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
                    <:suffix>
                      <.button phx-click="increment" size="sm" variant="ghost">Update</.button>
                    </:suffix>
                  </.input_group>
                  <p id="feedback-state">Feedback: {@feedback}</p>
                </form>
              </.preview_card>
              <.preview_card title="Combo box" description="Choose one animal from a searchable list.">
                <form
                  id="animal-preview"
                  phx-change="animal_change"
                  phx-submit="animal_submit"
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
              </.preview_card>
              <.preview_card
                title="Multiple selection"
                description="Select several options from grouped results."
              >
                <form
                  id="animals-preview"
                  phx-change="animals_change"
                  phx-submit="animals_submit"
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
              </.preview_card>
              <.preview_card title="Custom values" description="Choose an option or enter your own.">
                <form
                  id="custom-animal-preview"
                  phx-change="custom_animal_change"
                  phx-submit="custom_animal_submit"
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
                       [
                         {"Cat", "cat"},
                         {"Dog", "dog"},
                         [key: "Kangaroo", value: "kangaroo", disabled: true]
                       ]},
                      {"Other", [{"Snake", "snake"}]}
                    ]}
                  />
                  <.button type="submit" size="sm">Submit custom animal</.button>
                  <.button phx-click="set_custom_animal" size="sm" variant="secondary">Set Dragon</.button>
                  <p id="custom-animal-state">
                    Value: {@custom_animal}; Submitted: {@submitted_custom_animal || "none"}
                  </p>
                </form>
              </.preview_card>
              <.preview_card
                title="Verification code"
                description="A segmented input for one-time codes."
              >
                <form id="otp-preview" phx-change="otp_change">
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
              </.preview_card>
              <.preview_card
                title="Validation states"
                description="Invalid and disabled field examples."
                class="lp-card-wide"
              >
                <div>
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
                <fieldset disabled>
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
                <div>
                  <.search_field
                    id="invalid-search"
                    label="Search error"
                    value="x"
                    errors={["Enter at least two characters"]}
                    full_width
                  />
                  <.input_otp
                    id="invalid-otp"
                    label="Code error"
                    value="12"
                    errors={["Enter the full code"]}
                  />
                </div>
              </.preview_card>
            </div>
          </section>
          <section id="colors" class="lp-section" aria-labelledby="colors-title">
            <div class="lp-section-heading">
              <div>
                <p class="lp-kicker">COMPONENTS</p><h2 id="colors-title">Colors</h2>
              </div>
              <p>Preview and select colors with accessible controls.</p>
            </div>
            <div class="lp-grid">
              <.preview_card
                title="Color swatches"
                description="Sizes, shapes, and transparent colors."
              >
                <div class="lp-inline">
                  <.color_swatch color="#3B82F6" label="Blue, extra small" size="xs" />
                  <.color_swatch color="#8B5CF6" label="Purple, small" size="sm" />
                  <.color_swatch color="#F43F5E" label="Rose, medium" />
                  <.color_swatch color="#06B6D4" label="Cyan, large" size="lg" />
                  <.color_swatch color="#22C55E" label="Green, extra large" size="xl" />
                  <.color_swatch color="#F43F5E80" label="Translucent rose" shape="square" size="xl" />
                </div>
              </.preview_card>
              <.preview_card
                title="Swatch picker"
                description="Select an accent color and submit it."
                class="lp-card-wide"
              >
                <form
                  id="color-preview"
                  class="lp-palette-example"
                  phx-change="color_change"
                  phx-submit="color_submit"
                >
                  <.color_swatch_picker
                    id="preview-palette"
                    name="accent_color"
                    label="Accent color"
                    value={@accent_color}
                    required
                  >
                    <:option value="#F43F5E" label="Rose" /><:option value="#D946EF" label="Magenta" />
                    <:option value="#8B5CF6" label="Purple" /><:option value="#3B82F6" label="Blue" />
                    <:option value="#06B6D4" label="Cyan" /><:option value="#22C55E" label="Green" />
                    <:option value="#FACC15" label="Yellow" />
                  </.color_swatch_picker>
                  <.button type="submit" size="sm">Submit color</.button>
                  <.button phx-click="set_color" size="sm" variant="secondary">Set blue</.button>
                  <p id="color-state">
                    Selected: {@accent_color}; Submitted: {@submitted_color || "none"}; Changes: {@color_changes}
                  </p>
                </form>
              </.preview_card>
              <.preview_card
                title="Swatch picker states"
                description="Square, disabled, and stacked palettes."
              >
                <.color_swatch_picker
                  id="disabled-palette"
                  label="Disabled palette"
                  value="#3B82F6"
                  shape="square"
                  disabled
                >
                  <:option value="#F43F5E" label="Rose" /><:option value="#3B82F6" label="Blue" /><:option
                    value="#FACC15"
                    label="Yellow"
                  />
                </.color_swatch_picker>
                <div style="margin-top:20px;width:fit-content">
                  <.color_swatch_picker
                    id="stacked-palette"
                    label="Stacked palette"
                    value="#22C55E"
                    layout="stack"
                    size="sm"
                  >
                    <:option value="#F43F5E" label="Rose" /><:option value="#22C55E" label="Green" /><:option
                      value="#FACC15"
                      label="Yellow"
                    />
                  </.color_swatch_picker>
                </div>
              </.preview_card>
            </div>
          </section>
          <section id="dates" class="lp-section" aria-labelledby="dates-title">
            <div class="lp-section-heading">
              <div>
                <p class="lp-kicker">COMPONENTS</p><h2 id="dates-title">Dates &amp; calendars</h2>
              </div><p>Date input and selection, connected to LiveView.</p>
            </div>
            <div class="lp-grid">
              <.preview_card
                title="Date picker"
                description="Type a date or choose one from the calendar."
              >
                <form
                  id="date-picker-preview"
                  phx-change="booking_change"
                  phx-submit="booking_submit"
                >
                  <.date_picker
                    id="booking"
                    name="booking_date"
                    label="Booking date"
                    value={@booking_date}
                    min={~D[2026-09-01]}
                    max={~D[2026-12-31]}
                    today={~D[2026-10-31]}
                    unavailable_dates={[~D[2026-10-18]]}
                    required
                    full_width
                  />
                  <.button type="submit" size="sm">Submit booking</.button>
                  <.button phx-click="set_booking" size="sm" variant="secondary">Set November 10</.button>
                  <p id="booking-state">
                    Date: {@booking_date}; Submitted: {@submitted_booking || "none"}; Changes: {@booking_changes}
                  </p>
                </form>
              </.preview_card>
              <.preview_card
                title="Date fields"
                description="Segmented dates with locale-aware ordering."
              >
                <form
                  id="date-field-preview"
                  phx-change="birth_change"
                  phx-submit="birth_submit"
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
                <div>
                  <.date_field
                    id="french-date"
                    label="Date française"
                    locale="fr-FR"
                    value={~D[2026-10-15]}
                    full_width
                  />
                </div>
              </.preview_card>
              <.preview_card
                title="Calendar"
                description="Select a date, with limits and unavailable days."
              >
                <form
                  id="calendar-preview"
                  phx-change="appointment_change"
                  phx-submit="appointment_submit"
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
              </.preview_card>
              <.preview_card title="Range calendar" description="Select a start and end date.">
                <form
                  id="range-calendar-preview"
                  phx-change="stay_change"
                  phx-submit="stay_submit"
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
              </.preview_card>
              <.preview_card
                title="Calendar states"
                description="Year navigation, read-only, and disabled states."
                class="lp-card-wide"
              >
                <div class="lp-calendar-examples">
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
              </.preview_card>
            </div>
          </section>
          <section id="selection" class="lp-section" aria-labelledby="selection-title">
            <div class="lp-section-heading">
              <div>
                <p class="lp-kicker">COMPONENTS</p><h2 id="selection-title">
                  Selection &amp; navigation
                </h2>
              </div><p>Choices, navigation, and grouped actions.</p>
            </div>
            <div class="lp-grid">
              <.preview_card
                title="Form controls"
                description="Checkboxes, switches, sliders, and more."
              >
                <form
                  phx-change="settings"
                  class="lp-settings"
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
              </.preview_card>
              <.preview_card title="Select" description="Grouped, multiple, and required choices.">
                <div>
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
                  class="lp-settings"
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
              </.preview_card>
              <.preview_card title="Tag group" description="Select or remove topics.">
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
              </.preview_card>
              <.preview_card
                title="Listbox &amp; actions"
                description="Choose a workspace and toggle formatting."
              >
                <div class="lp-inline">
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
                <div class="lp-listbox-surface">
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
              </.preview_card>
              <.preview_card title="Tabs" description="Switch between account sections.">
                <.tabs id="preview-tabs" label="Account sections">
                  <:tab id="profile" label="Profile">
                    <p>Profile settings</p>
                  </:tab>
                  <:tab id="security" label="Security">
                    <p id="tab-count">Security updates: {@count}</p><.button phx-click="increment">Update tab</.button>
                  </:tab>
                  <:tab id="disabled" label="Disabled" disabled>Unavailable</:tab>
                </.tabs>
              </.preview_card>
            </div>
          </section>
          <section id="overlays" class="lp-section" aria-labelledby="overlays-title">
            <div class="lp-section-heading">
              <div>
                <p class="lp-kicker">COMPONENTS</p><h2 id="overlays-title">Overlays</h2>
              </div><p>Dialogs and contextual actions.</p>
            </div>
            <div class="lp-grid">
              <.preview_card
                title="Dialogs &amp; menus"
                description="Open each overlay to explore its behavior."
                class="lp-card-wide"
              >
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
                <.tooltip id="preview-tip" text="This is a helpful hint" delay={0}>
                  Hover or focus
                </.tooltip>
                <.popover id="preview-popover" trigger="Open popover" title="Quick settings">
                  <p id="popover-count">Popover updates: {@count}</p>
                  <.button phx-click="increment">Update popover</.button>
                </.popover>
                <.dropdown id="preview-actions" label="Actions">
                  <:item label="Update count" on_click="increment" />
                  <:item label="Unavailable" disabled />
                  <:item label="Open gallery" href="/" />
                </.dropdown>
              </.preview_card>
            </div>
          </section>
          <section id="feedback" class="lp-section" aria-labelledby="feedback-title">
            <div class="lp-section-heading">
              <div>
                <p class="lp-kicker">COMPONENTS</p><h2 id="feedback-title">Feedback</h2>
              </div><p>Keep people informed about changes.</p>
            </div>
            <div class="lp-grid">
              <.preview_card
                title="Toast notifications"
                description="Send a notification in any of five variants."
              >
                <section aria-label="Toast preview">
                  <.toast_region id="preview-toasts" placement="bottom" />
                  <div class="lp-inline">
                    <.button
                      :for={variant <- ~w(default accent success warning danger)}
                      phx-click="show_toast"
                      phx-value-variant={variant}
                      size="sm"
                      variant="secondary"
                    >{String.capitalize(variant)} toast</.button>
                  </div>
                  <p id="toast-action-state">Action: {@toast_action}</p>
                </section>
              </.preview_card>
              <.preview_card title="Status &amp; identity" description="Alerts, avatars, and badges.">
                <div class="lp-inline">
                  <.avatar
                    name="Casey Jones"
                    src={if @count > 0, do: "/avatar-demo.svg", else: "/missing-avatar.png"}
                  />
                  <.avatar name="Alex Kim" color="accent" variant="soft" />
                  <.badge_anchor>
                    <.avatar name="Jane Doe" /><.badge color="danger" size="sm" placement="top-right">
                      3
                    </.badge>
                  </.badge_anchor>
                </div>
                <.alert title="Profile updated" color="success">Your settings are saved.</.alert>
              </.preview_card>
              <.preview_card title="Progress" description="Visualize the current update count.">
                <.progress_circle label="Updates" value={min(@count, 10)} max={10} />
                <.meter
                  label="Capacity"
                  value={min(@count, 10)}
                  max={10}
                  value_text={"#{min(@count, 10)} of 10"}
                />
              </.preview_card>
            </div>
          </section>
          <section id="data" class="lp-section" aria-labelledby="data-title">
            <div class="lp-section-heading">
              <div>
                <p class="lp-kicker">COMPONENTS</p><h2 id="data-title">Data display</h2>
              </div><p>Tables and pagination with LiveView updates.</p>
            </div>
            <div class="lp-grid">
              <.preview_card
                title="Tables"
                description="Sort, paginate, and add a streamed row."
                class="lp-card-wide"
              >
                <section>
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
              </.preview_card>
            </div>
          </section>
          <footer class="lp-footer">
            <span>HeroUI <span>for LiveView</span></span><a href="#overview">Back to top ↑</a>
          </footer>
          <.modal id="live-modal" title="Live update">
            <p id="count">Server updates: {@count}</p>
            <.button phx-click="increment">Update content</.button>
          </.modal>
        </main>
      </div>
    </div>
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
