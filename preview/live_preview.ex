defmodule OlisUI.Preview.Layout do
  @moduledoc false
  use Phoenix.Component

  def root(assigns) do
    ~H"""
    <!DOCTYPE html>
    <html lang="en" class="scroll-smooth">
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <meta name="csrf-token" content={Plug.CSRFProtection.get_csrf_token()} />
        <title>LiveView integration preview</title>
        <link rel="stylesheet" href="/olis_ui.css" />
        <link rel="stylesheet" href="/preview-fonts/index.css" />
        <script>
          try { document.documentElement.dataset.theme = localStorage.getItem("preview-theme") || "light"; } catch (_) {}
        </script>
        <script type="module">
          import {Socket} from "/phoenix.mjs";
          import {LiveSocket} from "/phoenix_live_view.esm.js";
          import {registerOlisUIAlpine} from "/olis_ui_alpine.js";
          import Alpine from "/alpine.esm.js";
          import collapse from "/alpine-collapse.esm.js";
          window.Alpine = Alpine;
          Alpine.plugin(collapse);
          registerOlisUIAlpine(Alpine);
          Alpine.start();
          const updateNavigation = () => {
            const sections = [...document.querySelectorAll('.lp-intro, .lp-section')];
            const active = sections.filter(section => section.getBoundingClientRect().top <= 160).at(-1) || sections[0];
            document.querySelectorAll('.lp-navigation a[href^="#"]').forEach(link => {
              const selected = link.getAttribute('href') === `#${active?.id}`;
              link.classList.toggle('is-active', selected);
              if (selected) { link.setAttribute('aria-current', 'location'); } else { link.removeAttribute('aria-current'); }
            });
          };
          window.addEventListener('scroll', updateNavigation, {passive: true});
          window.addEventListener('load', updateNavigation);
          window.addEventListener('hashchange', updateNavigation);
          document.addEventListener('phx:update', updateNavigation);
          updateNavigation();
          document.addEventListener('click', event => {
            const toggle = event.target.closest('[data-preview-theme]');
            if (!toggle) { return; }
            const theme = document.documentElement.dataset.theme === 'dark' ? 'light' : 'dark';
            document.documentElement.dataset.theme = theme;
            try { localStorage.setItem('preview-theme', theme); } catch (_) {}
          });
          const csrf = document.querySelector('meta[name="csrf-token"]').content;
          const socket = new LiveSocket('/live', Socket, {
            params: {_csrf_token: csrf},
            dom: {onBeforeElUpdated(from, to) { if (from._x_dataStack) { Alpine.clone(from, to); } }}
          });
          socket.connect();
          window.liveSocket = socket;
        </script>
      </head>
      <body class="lp-body preview-body m-0 bg-[#fafafa] font-preview text-sm text-[#111315] dark:bg-[#08090a] dark:text-white">
        {@inner_content}
      </body>
    </html>
    """
  end
end

defmodule OlisUI.Preview.Live do
  use Phoenix.LiveView, layout: false
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
  import OlisUI.Toast
  import OlisUI.Typography

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
        button_pending: false,
        button_actions: 0,
        button_submissions: 0,
        button_group_action: "none",
        close_button_count: 0,
        terms: false,
        alerts: false,
        switch_news: true,
        switch_read_only: true,
        switch_marketing: false,
        switch_updates: true,
        plan: "starter",
        volume: 40,
        quantity: 1,
        delivery: "standard",
        topics: ["news"],
        rows: rows,
        table_selected: ["person-1"],
        table_resize: "none",
        table_widths: %{"name" => 220, "role" => 200},
        listbox_selected: ["email"],
        listbox_action: "none",
        stream_has_more: true,
        sort_direction: "ascending",
        page: 1,
        bold: false,
        italic: false,
        toggle_group_formats: ["bold"],
        toggle_group_disabled: false,
        toggle_favorite: false,
        toggle_following: true,
        toggle_inherited: false,
        toggle_override: false,
        toggle_alignment: ["left"],
        underline: false,
        disclosure_expanded: ["account"],
        multiple_disclosures: ["first"],
        project_open: false,
        disclosure_last: "none",
        controlled_sheet_open: false,
        sheet_snap_index: 0,
        sheet_last: "none",
        controlled_drawer_open: false,
        drawer_last: "none",
        controlled_modal_open: false,
        overlay_open: %{},
        modal_last: "none",
        controlled_popover_open: false,
        popover_last: "none",
        toolbar_action: "none",
        tabs_selection: "overview",
        preview_tab: "profile",
        overflow_tab: "overview",
        vertical_tab: "account",
        dropdown_submenus: [],
        dropdown_sort: "newest",
        dropdown_columns: ["name", "status"],
        dropdown_format: ["bold"],
        dropdown_last: "none",
        fieldset_saved: nil,
        workspace: ["alpha"],
        required_choice: nil,
        required_value: nil,
        grouped_plan: "starter",
        multiple_choices: [],
        search_query: "",
        brand_color: "#0485F7",
        submitted_brand_color: nil,
        brand_color_changes: 0,
        hue: 300,
        saturation: 100,
        lightness: 25,
        accent_color: "#8B5CF6",
        submitted_color: nil,
        color_changes: 0,
        toast_count: 0,
        toasts: [],
        toast_action: "none",
        scroll_visibility: "waiting",
        scroll_entries: Enum.to_list(1..8),
        animal: "",
        country: "",
        country_submitted: nil,
        countries: ["us"],
        countries_submitted: nil,
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
        selected_tags: ["news"],
        local_tag_selection: ["news"],
        stream_selected: [],
        local_tag_values: ["news", "travel", "gaming"]
      )
      |> stream(:people, rows)

    {:ok, socket}
  end

  def handle_event("table_selection", %{"keys" => encoded}, socket),
    do: {:noreply, assign(socket, :table_selected, Jason.decode!(encoded))}

  def handle_event("stream_selection", %{"keys" => keys}, socket),
    do: {:noreply, assign(socket, :stream_selected, Jason.decode!(keys))}

  def handle_event(
        "table_resize",
        %{"column" => key, "width" => width, "widths" => widths},
        socket
      ),
      do:
        {:noreply,
         assign(socket, table_resize: "#{key}: #{width}px", table_widths: Jason.decode!(widths))}

  def handle_event("listbox_selection", %{"keys" => keys}, socket),
    do: {:noreply, assign(socket, :listbox_selected, Jason.decode!(keys))}

  def handle_event("listbox_action", %{"value" => value}, socket),
    do: {:noreply, assign(socket, :listbox_action, value)}

  def handle_event("popover_change", %{"open" => open, "reason" => reason}, socket),
    do: {:noreply, assign(socket, controlled_popover_open: open == "true", popover_last: reason)}

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
       id: Enum.random(1..10_000),
       name: "Morgan Lee",
       role: "Engineer"
     })}
  end

  def handle_event("clear_people", _, socket),
    do: {:noreply, stream(socket, :people, [], reset: true)}

  def handle_event("load_more_people", _, socket) do
    {:noreply,
     socket
     |> assign(:stream_has_more, false)
     |> stream_insert(:people, %{id: 101, name: "Jordan Park", role: "Researcher"})}
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

  def handle_event("toggle_format", %{"format" => "underline"}, socket),
    do: {:noreply, update(socket, :underline, &(!&1))}

  def handle_event("project_toggle", %{"expanded" => expanded}, socket),
    do: {:noreply, assign(socket, :project_open, expanded == "true")}

  def handle_event("multiple_disclosures", %{"key" => key, "expanded" => expanded}, socket) do
    keys =
      if expanded == "true",
        do: [key | socket.assigns.multiple_disclosures],
        else: List.delete(socket.assigns.multiple_disclosures, key)

    {:noreply, assign(socket, :multiple_disclosures, keys)}
  end

  def handle_event("disclosure_toggle", %{"key" => key, "expanded" => expanded}, socket)
      when key in ~w(account billing security) do
    keys = if expanded == "true", do: [key], else: []
    {:noreply, assign(socket, disclosure_expanded: keys, disclosure_last: "#{key}: #{expanded}")}
  end

  def handle_event("open_billing", _, socket),
    do:
      {:noreply,
       assign(socket, disclosure_expanded: ["billing"], disclosure_last: "billing: true")}

  def handle_event("overlay_change", %{"id" => id, "open" => open}, socket) do
    socket = update(socket, :overlay_open, &Map.put(&1, id, open == "true"))

    socket =
      if id == "view-menu" and open == "false",
        do: assign(socket, :dropdown_submenus, []),
        else: socket

    {:noreply, socket}
  end

  def handle_event("sheet_snap_change", %{"index" => index}, socket),
    do: {:noreply, assign(socket, :sheet_snap_index, String.to_integer(index))}

  def handle_event("sheet_open_change", %{"open" => open, "reason" => reason}, socket),
    do:
      {:noreply,
       assign(socket, controlled_sheet_open: open == "true", sheet_last: "#{open}: #{reason}")}

  def handle_event("drawer_open_change", %{"open" => open, "reason" => reason}, socket),
    do:
      {:noreply,
       assign(socket, controlled_drawer_open: open == "true", drawer_last: "#{open}: #{reason}")}

  def handle_event("modal_open_change", %{"open" => open, "reason" => reason}, socket),
    do:
      {:noreply,
       assign(socket, controlled_modal_open: open == "true", modal_last: "#{open}: #{reason}")}

  def handle_event("toolbar_action", %{"action" => action}, socket)
      when action in ~w(Copy Cut Undo Redo),
      do: {:noreply, assign(socket, :toolbar_action, action)}

  def handle_event("tabs_selection", %{"key" => key}, socket)
      when key in ~w(overview analytics reports),
      do: {:noreply, assign(socket, :tabs_selection, key)}

  def handle_event("preview_tab", %{"key" => key}, socket),
    do: {:noreply, assign(socket, :preview_tab, key)}

  def handle_event("overflow_tab", %{"key" => key}, socket),
    do: {:noreply, assign(socket, :overflow_tab, key)}

  def handle_event("vertical_tab", %{"key" => key}, socket),
    do: {:noreply, assign(socket, :vertical_tab, key)}

  def handle_event("dropdown_submenus", %{"keys" => keys}, socket),
    do: {:noreply, assign(socket, :dropdown_submenus, Jason.decode!(keys))}

  def handle_event("dropdown_sort", %{"key" => key}, socket),
    do: {:noreply, assign(socket, :dropdown_sort, key)}

  def handle_event("fieldset_save", %{"profile" => %{"name" => name}}, socket),
    do: {:noreply, assign(socket, :fieldset_saved, name)}

  def handle_event("dropdown_columns", %{"key" => key, "selected" => selected}, socket) do
    values = Enum.reject(socket.assigns.dropdown_columns, &(&1 == key))

    {:noreply,
     assign(socket, :dropdown_columns, if(selected == "true", do: values ++ [key], else: values))}
  end

  def handle_event("dropdown_format", %{"keys" => keys}, socket),
    do: {:noreply, assign(socket, :dropdown_format, Jason.decode!(keys))}

  def handle_event("dropdown_action", %{"key" => key}, socket),
    do: {:noreply, assign(socket, :dropdown_last, key)}

  def handle_event("select_examples", params, socket),
    do:
      {:noreply,
       assign(socket,
         grouped_plan: params["grouped"],
         multiple_choices: Map.get(params, "multiple", [])
       )}

  def handle_event("required_change", %{"choice" => value}, socket),
    do: {:noreply, assign(socket, :required_value, value)}

  def handle_event("required_submit", %{"choice" => value}, socket),
    do: {:noreply, assign(socket, :required_choice, value)}

  def handle_event("search", %{"query" => value}, socket),
    do: {:noreply, assign(socket, :search_query, value)}

  def handle_event("search_example", _, socket),
    do: {:noreply, assign(socket, :search_query, "Phoenix")}

  def handle_event("brand_color_change", %{"brand_color" => value}, socket),
    do:
      {:noreply, socket |> assign(:brand_color, value) |> update(:brand_color_changes, &(&1 + 1))}

  def handle_event("brand_color_submit", %{"brand_color" => value}, socket),
    do: {:noreply, assign(socket, :submitted_brand_color, value)}

  def handle_event("set_brand_color", _, socket),
    do: {:noreply, assign(socket, :brand_color, "#8B5CF6")}

  def handle_event("color_channels", %{"channels" => channels}, socket) do
    values =
      for {key, max} <- [{:hue, 360}, {:saturation, 100}, {:lightness, 100}], into: %{} do
        value =
          case Integer.parse(Map.get(channels, Atom.to_string(key), "")) do
            {number, ""} when number >= 0 and number <= max -> number
            _ -> socket.assigns[key]
          end

        {key, value}
      end

    {:noreply, assign(socket, values)}
  end

  def handle_event("color_change", %{"accent_color" => value}, socket),
    do: {:noreply, socket |> assign(:accent_color, value) |> update(:color_changes, &(&1 + 1))}

  def handle_event("color_submit", %{"accent_color" => value}, socket),
    do: {:noreply, assign(socket, :submitted_color, value)}

  def handle_event("set_color", _, socket),
    do: {:noreply, assign(socket, :accent_color, "#3B82F6")}

  def handle_event("show_toast", %{"variant" => variant}, socket)
      when variant in ~w(default accent success warning danger) do
    count = socket.assigns.toast_count + 1

    toast = %{
      id: "preview-#{count}",
      title: "Changes saved",
      description: "Your preferences have been updated.",
      variant: variant,
      timeout: 0,
      action: %{label: "Undo", event: "toast_undo", params: %{id: count}}
    }

    {:noreply, socket |> assign(:toast_count, count) |> update(:toasts, &[toast | &1])}
  end

  def handle_event("toast_undo", %{"id" => id}, socket),
    do: {:noreply, assign(socket, :toast_action, "Undo #{id}")}

  def handle_event("dismiss_toast", %{"id" => id}, socket),
    do: {:noreply, update(socket, :toasts, &Enum.reject(&1, fn toast -> toast.id == id end))}

  def handle_event("show_toast_star", _, socket) do
    toast = %{
      id: "star-#{System.unique_integer([:positive])}",
      title: "Added to favorites",
      indicator: "star",
      timeout: 4000
    }

    {:noreply, update(socket, :toasts, &[toast | &1])}
  end

  def handle_event("scroll_visibility", %{"visibility" => visibility}, socket),
    do: {:noreply, assign(socket, :scroll_visibility, visibility)}

  def handle_event("toggle_scroll_entries", _, socket) do
    entries = if length(socket.assigns.scroll_entries) > 2, do: [1, 2], else: Enum.to_list(1..8)
    {:noreply, assign(socket, :scroll_entries, entries)}
  end

  def handle_event("animal_change", %{"animal" => value}, socket),
    do: {:noreply, socket |> assign(:animal, value) |> update(:animal_changes, &(&1 + 1))}

  def handle_event("country_change", %{"country" => value}, socket),
    do: {:noreply, assign(socket, :country, value)}

  def handle_event("country_submit", %{"country" => value}, socket),
    do: {:noreply, assign(socket, :country_submitted, value)}

  def handle_event("countries_change", params, socket),
    do: {:noreply, assign(socket, :countries, Map.get(params, "countries", []))}

  def handle_event("countries_submit", params, socket),
    do: {:noreply, assign(socket, :countries_submitted, Map.get(params, "countries", []))}

  def handle_event("set_country", _, socket),
    do: {:noreply, assign(socket, :country, "jp")}

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

  def handle_event("clear_feedback", _, socket),
    do: {:noreply, assign(socket, :feedback, "")}

  def handle_event("otp_change", %{"code" => value}, socket),
    do: {:noreply, assign(socket, :otp_value, value)}

  def handle_event("select_tag", %{"keys" => keys}, socket) do
    {:noreply, assign(socket, :selected_tags, Jason.decode!(keys))}
  end

  def handle_event("preview_local_tag_selection", %{"keys" => keys}, socket),
    do: {:noreply, assign(socket, :local_tag_selection, Jason.decode!(keys))}

  def handle_event("preview_remove_local_tag", %{"value" => value}, socket),
    do:
      {:noreply,
       socket
       |> update(:local_tag_values, &List.delete(&1, value))
       |> update(:local_tag_selection, &List.delete(&1, value))}

  def handle_event("remove_tag", %{"value" => value}, socket) do
    {:noreply,
     assign(socket,
       tag_values: List.delete(socket.assigns.tag_values, value),
       selected_tags: List.delete(socket.assigns.selected_tags, value)
     )}
  end

  def handle_event("preview_toggle", %{"key" => key}, socket)
      when key in ~w(favorite following inherited override),
      do: {:noreply, update(socket, String.to_existing_atom("toggle_" <> key), &(!&1))}

  def handle_event("preview_alignment", %{"keys" => keys}, socket),
    do: {:noreply, assign(socket, :toggle_alignment, Jason.decode!(keys))}

  def handle_event("preview_toggle_group_disabled", _, socket),
    do: {:noreply, update(socket, :toggle_group_disabled, &(!&1))}

  def handle_event("preview_toggle_group_change", %{"keys" => encoded}, socket) do
    case Jason.decode(encoded) do
      {:ok, keys} when is_list(keys) -> {:noreply, assign(socket, :toggle_group_formats, keys)}
      _ -> {:noreply, socket}
    end
  end

  def handle_event("increment", _, socket), do: {:noreply, update(socket, :count, &(&1 + 1))}

  def handle_event("preview_button_action", _, socket),
    do: {:noreply, update(socket, :button_actions, &(&1 + 1))}

  def handle_event("preview_button_submit", _, socket),
    do: {:noreply, update(socket, :button_submissions, &(&1 + 1))}

  def handle_event("preview_button_pending", _, socket),
    do: {:noreply, update(socket, :button_pending, &(!&1))}

  def handle_event("preview_button_group", %{"value" => value}, socket),
    do: {:noreply, assign(socket, :button_group_action, value)}

  def handle_event("close_button_clicked", _, socket),
    do: {:noreply, update(socket, :close_button_count, &(&1 + 1))}

  def handle_event("toggle_switch_read_only", _, socket),
    do: {:noreply, update(socket, :switch_read_only, &(!&1))}

  def handle_event("switch_group_change", params, socket) do
    {:noreply,
     assign(socket,
       switch_news: params["news"] == "true",
       switch_marketing: params["marketing"] == "true",
       switch_updates: params["updates"] == "true"
     )}
  end

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
    <article class={[
      "lp-card min-w-0 overflow-visible rounded-xl border border-[#e5e7eb] bg-white dark:border-[#23252a] dark:bg-[#0f1011]",
      @class == "lp-card-wide" && "min-[700px]:col-span-2",
      @class
    ]}>
      <header class="lp-card-header min-h-[76px] border-b border-[#e5e7eb] px-6 py-4 dark:border-[#23252a] [&_h3]:m-0 [&_h3]:text-sm [&_h3]:font-[510] [&_h3]:tracking-[-.01em] [&_p]:mb-0 [&_p]:mt-1.5 [&_p]:text-xs [&_p]:leading-5 [&_p]:text-[#62666d] dark:[&_p]:text-[#8a8f98]">
        <h3>{@title}</h3>
        <p :if={@description}>{@description}</p>
      </header>
      <div class="lp-demo min-w-0 px-6 py-6 max-[620px]:px-4 [&>form]:max-w-full [&>div]:max-w-full [&>fieldset]:max-w-full [&_form>button]:mt-3 [&_form>button]:mr-1 [&_form+form]:mt-6 [&_form+div]:mt-6 [&_fieldset+div]:mt-6 [&_section>h2]:mb-3 [&_section>h2]:text-sm [&_section>h2]:font-[510] [&_section>h2:not(:first-child)]:mt-6 [&_section>button]:mt-4 [&>button]:mr-1.5 [&>button]:mb-2">
        {render_slot(@inner_block)}
      </div>
    </article>
    """
  end

  def render(assigns) do
    ~H"""
    <div class="lp-app min-h-screen">
      <header class="lp-topbar sticky top-0 z-30 flex h-16 items-center justify-between border-b border-[#e5e7eb] bg-[#fafafa] px-6 dark:border-[#23252a] dark:bg-[#08090a] sm:px-10">
        <a
          href="/"
          class="lp-brand inline-flex items-center gap-2 whitespace-nowrap text-base font-[510] tracking-[-.01em] text-[#111315] no-underline dark:text-white [&>span:last-child>span]:font-normal [&>span:last-child>span]:text-[#62666d] dark:[&>span:last-child>span]:text-[#8a8f98]"
          aria-label="OlisUI for LiveView home"
        ><span class="lp-brand-mark grid size-7 place-items-center rounded-md bg-[#111315] text-base leading-none text-white dark:bg-white dark:text-[#08090a]">✦</span><span>OlisUI
        <span>for LiveView</span></span></a>
        <div class="lp-top-actions flex items-center gap-4 sm:gap-6">
          <span class="lp-live inline-flex items-center gap-2 whitespace-nowrap text-xs text-[#62666d] dark:text-[#8a8f98] max-[620px]:hidden [&>span]:inline-block [&>span]:size-1.5 [&>span]:rounded-full [&>span]:bg-[#8a8f98]"><span></span>
          Live playground</span><button
            type="button"
            class="lp-theme grid size-8 cursor-pointer place-items-center rounded-md border border-[#d8dadd] bg-transparent text-base text-[#111315] hover:bg-[#e9eaec] dark:border-[#23252a] dark:text-[#d0d6e0] dark:hover:bg-[#161718]"
            data-preview-theme
            aria-label="Toggle light and dark theme"
            title="Toggle theme"
          >◐</button><a
            class="lp-top-link whitespace-nowrap text-[13px] font-[510] text-[#111315] no-underline hover:underline dark:text-[#d0d6e0] max-[620px]:hidden [&>span]:ml-1 [&>span]:text-[#8a8f98]"
            href="/"
          >Component gallery <span aria-hidden="true">↗</span></a>
        </div>
      </header>
      <div class="lp-layout mx-auto max-w-[1200px]">
        <nav
          class="lp-navigation sticky top-16 z-20 flex items-center gap-2 overflow-x-auto border-b border-[#e5e7eb] bg-[#fafafa] px-6 py-2 dark:border-[#23252a] dark:bg-[#08090a] sm:px-10"
          aria-label="Preview navigation"
        >
          <a
            class="lp-nav-intro is-active shrink-0 rounded-md px-3 py-2 text-[13px] text-[#62666d] no-underline hover:text-[#111315] aria-[current=location]:bg-[#e9eaec] aria-[current=location]:text-[#111315] dark:text-[#8a8f98] dark:hover:text-white dark:aria-[current=location]:bg-[#161718] dark:aria-[current=location]:text-white [&>span:last-child]:hidden"
            href="#overview"
            aria-current="location"
          ><span>Overview</span><span aria-hidden="true">↗</span></a>
          <div class="lp-nav flex items-center gap-1">
            <a
              class="flex items-center gap-2 whitespace-nowrap rounded-md px-3 py-2 text-[13px] text-[#62666d] no-underline hover:text-[#111315] aria-[current=location]:bg-[#e9eaec] aria-[current=location]:text-[#111315] dark:text-[#8a8f98] dark:hover:text-white dark:aria-[current=location]:bg-[#161718] dark:aria-[current=location]:text-white [&>span]:hidden"
              href="#forms"
            >Forms <span>01</span></a><a
              class="flex items-center gap-2 whitespace-nowrap rounded-md px-3 py-2 text-[13px] text-[#62666d] no-underline hover:text-[#111315] aria-[current=location]:bg-[#e9eaec] aria-[current=location]:text-[#111315] dark:text-[#8a8f98] dark:hover:text-white dark:aria-[current=location]:bg-[#161718] dark:aria-[current=location]:text-white [&>span]:hidden"
              href="#colors"
            >Colors <span>02</span></a><a
              class="flex items-center gap-2 whitespace-nowrap rounded-md px-3 py-2 text-[13px] text-[#62666d] no-underline hover:text-[#111315] aria-[current=location]:bg-[#e9eaec] aria-[current=location]:text-[#111315] dark:text-[#8a8f98] dark:hover:text-white dark:aria-[current=location]:bg-[#161718] dark:aria-[current=location]:text-white [&>span]:hidden"
              href="#selection"
            >Selection &amp; navigation <span>04</span></a><a
              class="flex items-center gap-2 whitespace-nowrap rounded-md px-3 py-2 text-[13px] text-[#62666d] no-underline hover:text-[#111315] aria-[current=location]:bg-[#e9eaec] aria-[current=location]:text-[#111315] dark:text-[#8a8f98] dark:hover:text-white dark:aria-[current=location]:bg-[#161718] dark:aria-[current=location]:text-white [&>span]:hidden"
              href="#overlays"
            >Overlays <span>05</span></a><a
              class="flex items-center gap-2 whitespace-nowrap rounded-md px-3 py-2 text-[13px] text-[#62666d] no-underline hover:text-[#111315] aria-[current=location]:bg-[#e9eaec] aria-[current=location]:text-[#111315] dark:text-[#8a8f98] dark:hover:text-white dark:aria-[current=location]:bg-[#161718] dark:aria-[current=location]:text-white [&>span]:hidden"
              href="#feedback"
            >Feedback <span>06</span></a><a
              class="flex items-center gap-2 whitespace-nowrap rounded-md px-3 py-2 text-[13px] text-[#62666d] no-underline hover:text-[#111315] aria-[current=location]:bg-[#e9eaec] aria-[current=location]:text-[#111315] dark:text-[#8a8f98] dark:hover:text-white dark:aria-[current=location]:bg-[#161718] dark:aria-[current=location]:text-white [&>span]:hidden"
              href="#data"
            >Data display <span>07</span></a>
          </div>
        </nav>
        <main class="lp-main min-w-0 px-6 sm:px-10">
          <div
            id="overview"
            class="lp-intro grid scroll-mt-32 grid-cols-[minmax(0,1fr)_minmax(260px,360px)] items-center gap-12 border-b border-[#e5e7eb] py-20 dark:border-[#23252a] max-[720px]:grid-cols-1 max-[720px]:gap-8 max-[620px]:py-14"
          >
            <div class="lp-intro-copy [&>h1]:m-0 [&>h1]:text-[clamp(48px,6vw,72px)] [&>h1]:font-[510] [&>h1]:leading-none [&>h1]:tracking-[-.022em] [&>h1>span]:text-[#8a8f98] [&>p:not(.lp-eyebrow)]:mb-0 [&>p:not(.lp-eyebrow)]:mt-5 [&>p:not(.lp-eyebrow)]:max-w-[480px] [&>p:not(.lp-eyebrow)]:text-base [&>p:not(.lp-eyebrow)]:leading-6 [&>p:not(.lp-eyebrow)]:text-[#62666d] dark:[&>p:not(.lp-eyebrow)]:text-[#8a8f98]">
              <p class="lp-eyebrow mb-6 mt-0 flex items-center gap-2 text-[11px] font-[510] uppercase tracking-[.08em] text-[#62666d] dark:text-[#8a8f98] [&>span]:inline-block [&>span]:size-1.5 [&>span]:rounded-full [&>span]:bg-[#8a8f98]">
                <span></span> THE LIVEVIEW PLAYGROUND
              </p><h1>
                Components,<br /><span>in motion.</span>
              </h1><p>
                Explore the building blocks, try their states, and see how they respond to real LiveView updates.
              </p><div class="lp-intro-actions mt-8 flex flex-wrap items-center gap-6">
                <a
                  href="#forms"
                  class="lp-primary-link inline-flex items-center gap-6 rounded-md bg-accent px-4 py-2.5 text-sm font-[510] text-accent-foreground no-underline hover:bg-accent-hover"
                >Explore components <span aria-hidden="true">↘</span></a><a
                  href="/"
                  class="lp-secondary-link text-[13px] font-[510] text-[#111315] no-underline hover:underline dark:text-[#d0d6e0] [&>span]:ml-1 [&>span]:text-[#8a8f98]"
                >View the gallery <span aria-hidden="true">↗</span></a>
              </div>
            </div>
            <div
              class="lp-intro-panel rounded-xl border border-[#e5e7eb] bg-white p-6 dark:border-[#23252a] dark:bg-[#0f1011]"
              aria-hidden="true"
            >
              <div class="lp-intro-panel-top flex items-center justify-between text-[10px] font-[510] tracking-[.08em] text-[#62666d] dark:text-[#8a8f98] [&>span:last-child]:text-base">
                <span>COMPONENT PREVIEW</span><span>✳&#xFE0E;</span>
              </div><div class="lp-intro-sample my-4 flex items-center gap-3 rounded-md border border-[#e5e7eb] bg-[#fafafa] p-4 dark:border-[#23252a] dark:bg-[#161718] [&_strong]:block [&_strong]:text-[13px] [&_strong]:font-[510] [&_small]:mt-1 [&_small]:block [&_small]:text-xs [&_small]:text-[#8a8f98]">
                <div class="lp-sample-icon grid size-9 shrink-0 place-items-center rounded-md bg-[#e9eaec] text-base text-[#62666d] dark:bg-[#23252a] dark:text-[#d0d6e0]">
                  ✦
                </div><div>
                  <strong>Ready to build</strong><small>Thoughtful components, connected.</small>
                </div><span class="lp-sample-check ml-auto text-[#8a8f98]">✓</span>
              </div><div class="lp-intro-meta flex items-center justify-between text-[11px] text-[#8a8f98] [&>span:first-child]:flex [&>span:first-child]:items-center [&>span:first-child]:gap-2 [&_i]:inline-block [&_i]:size-1.5 [&_i]:rounded-full [&_i]:bg-[#8a8f98]">
                <span><i></i> LiveView ready</span><span>01 — 07</span>
              </div>
            </div>
          </div>
          <section
            id="forms"
            class="lp-section scroll-mt-32 pt-20 pb-4 max-[620px]:pt-14"
            aria-labelledby="forms-title"
          >
            <div class="lp-section-heading mb-6 flex items-end justify-between gap-6 max-[620px]:block [&_h2]:m-0 [&_h2]:text-[32px] [&_h2]:font-[510] [&_h2]:leading-[1.13] [&_h2]:tracking-[-.022em] [&>p]:m-0 [&>p]:text-right [&>p]:text-[13px] [&>p]:leading-5 [&>p]:text-[#62666d] dark:[&>p]:text-[#8a8f98] max-[620px]:[&>p]:mt-2 max-[620px]:[&>p]:text-left">
              <div>
                <p class="lp-kicker mb-3 mt-0 text-[10px] font-[510] tracking-[.08em] text-[#62666d] dark:text-[#8a8f98]">
                  COMPONENTS
                </p><h2 id="forms-title">Forms</h2>
              </div><p>Inputs, validation, and searchable choices.</p>
            </div>
            <div class="lp-grid grid grid-cols-1 items-start gap-4 min-[700px]:grid-cols-2">
              <.preview_card title="Fieldset" description="Related fields, descriptions, and actions.">
                <form phx-submit="fieldset_save">
                  <.fieldset
                    id="profile-fieldset"
                    legend="Profile settings"
                    description="Update your profile information."
                  >
                    <.text_field
                      id="profile-name"
                      name="profile[name]"
                      label="Name"
                      placeholder="John Doe"
                      required
                    />
                    <.text_field
                      id="profile-email"
                      name="profile[email]"
                      label="Email"
                      type="email"
                      placeholder="john@example.com"
                      required
                    />
                    <:actions>
                      <.button type="submit">Save changes</.button>
                      <.button type="reset" variant="secondary">Reset</.button>
                    </:actions>
                  </.fieldset>
                </form>
                <p
                  :if={@fieldset_saved}
                  id="fieldset-saved"
                  class="mt-3 mb-0 text-xs text-zinc-500 dark:text-zinc-400"
                >
                  Saved profile for {@fieldset_saved}.
                </p>
                <.fieldset
                  id="disabled-fieldset"
                  legend="Disabled group"
                  disabled
                  class="mt-6 border-t border-separator pt-4"
                >
                  <.text_field
                    id="disabled-fieldset-input"
                    name="disabled_example"
                    label="Name"
                    value="Unavailable"
                  />
                  <:actions><.button>Save</.button></:actions>
                </.fieldset>
              </.preview_card>
              <.preview_card
                title="Text fields"
                description="Labels, help text, validation, and multiline input."
              >
                <div class="flex flex-col gap-5">
                  <.text_field
                    id="preview-username"
                    label="Username"
                    placeholder="Choose a username"
                    description="This is visible on your profile."
                    required
                  />
                  <.text_field
                    id="preview-email-error"
                    label="Email"
                    type="email"
                    value="not-an-email"
                    description="We'll never share your email."
                    errors={["Please enter a valid email address."]}
                  />
                  <.text_field
                    id="preview-bio"
                    label="Bio"
                    multiline
                    rows={3}
                    placeholder="Tell us about yourself"
                    description="A short introduction."
                  />
                  <.text_field
                    id="preview-account-id"
                    label="Account ID"
                    value="USR-12345"
                    description="This field cannot be edited."
                    disabled
                  />
                </div>
              </.preview_card>
              <.preview_card
                title="Form primitives"
                description="Compose Phoenix forms with standalone labels, descriptions, and errors."
              >
                <.ui_form
                  :let={form}
                  for={%{"email" => "not-an-email"}}
                  as={:preview}
                  class="flex flex-col gap-3"
                >
                  <div class="flex flex-col gap-1">
                    <.label for={form[:email].id}>Email</.label>
                    <.input
                      id={form[:email].id}
                      name={form[:email].name}
                      value={form[:email].value}
                      type="email"
                      invalid
                      aria-describedby="composed-email-help composed-email-error"
                    />
                    <.description id="composed-email-help">
                      We'll send your receipt here.
                    </.description>
                    <.field_error id="composed-email-error">
                      Enter a valid email address.
                    </.field_error>
                  </div>
                  <.error_message>Some items need your attention.</.error_message>
                </.ui_form>
              </.preview_card>
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
                  <p
                    id="search-state"
                    class="mt-3 mb-0 break-words text-[11px] leading-[1.55] text-zinc-500 dark:text-zinc-400"
                  >
                    Query: {@search_query}
                  </p>
                  <div class="mt-3 flex gap-2">
                    <.button size="sm" variant="secondary" phx-click="search_example">Set example</.button>
                  </div>
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
                  <p
                    id="price-state"
                    class="mt-3 mb-0 break-words text-[11px] leading-[1.55] text-zinc-500 dark:text-zinc-400"
                  >
                    Price: {@price}
                  </p>
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
                    rows="2"
                    value={@feedback}
                    placeholder="Share your feedback..."
                    full_width
                  >
                    <:prefix>✎</:prefix>
                    <:suffix>
                      <.button phx-click="clear_feedback" size="sm" variant="ghost">Clear</.button>
                    </:suffix>
                  </.input_group>
                  <p
                    id="feedback-state"
                    class="mt-3 mb-0 break-words text-[11px] leading-[1.55] text-zinc-500 dark:text-zinc-400"
                  >
                    Feedback: {@feedback}
                  </p>
                </form>
              </.preview_card>
              <.preview_card title="Autocomplete" description="Search within a select menu.">
                <form id="country-preview" phx-change="country_change" phx-submit="country_submit">
                  <.autocomplete
                    id="country"
                    open={Map.get(@overlay_open, "country", false)}
                    on_open_change="overlay_change"
                    name="country"
                    label="Destination"
                    value={@country}
                    options={[
                      {"Americas", [{"Canada", "ca"}, {"United States", "us"}]},
                      {"Asia & Europe",
                       [
                         {"Japan", "jp"},
                         {"Spain", "es"},
                         [key: "France", value: "fr", disabled: true]
                       ]}
                    ]}
                    placeholder="Select a destination"
                    search_placeholder="Search destinations..."
                    description="Choose a destination."
                    clearable
                    required
                    full_width
                  />
                  <.button type="submit" size="sm">Submit destination</.button>
                  <.button phx-click="set_country" size="sm" variant="secondary">Set Japan</.button>
                  <p
                    id="country-state"
                    class="mt-3 mb-0 break-words text-[11px] leading-[1.55] text-zinc-500 dark:text-zinc-400"
                  >
                    Selected: {@country}; Submitted: {@country_submitted || "none"}
                  </p>
                </form>
              </.preview_card>
              <.preview_card
                title="Multiple autocomplete"
                description="Select several items from the filtered list."
              >
                <form
                  id="countries-preview"
                  phx-change="countries_change"
                  phx-submit="countries_submit"
                >
                  <.autocomplete
                    id="countries"
                    open={Map.get(@overlay_open, "countries", false)}
                    on_open_change="overlay_change"
                    name="countries"
                    label="Places to visit"
                    value={@countries}
                    options={[
                      {"Canada", "ca"},
                      {"United States", "us"},
                      {"Japan", "jp"},
                      {"Spain", "es"}
                    ]}
                    selection_mode="multiple"
                    placeholder="Select places"
                    clearable
                    full_width
                  />
                  <.button type="submit" size="sm">Submit places</.button>
                  <p
                    id="countries-state"
                    class="mt-3 mb-0 break-words text-[11px] leading-[1.55] text-zinc-500 dark:text-zinc-400"
                  >
                    Selected: {Enum.join(@countries, ", ")}; Submitted: {if @countries_submitted,
                      do: Enum.join(@countries_submitted, ", "),
                      else: "none"}
                  </p>
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
                    open={Map.get(@overlay_open, "preview-animal", false)}
                    on_open_change="overlay_change"
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
                  <p
                    id="animal-state"
                    class="mt-3 mb-0 break-words text-[11px] leading-[1.55] text-zinc-500 dark:text-zinc-400"
                  >
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
                    open={Map.get(@overlay_open, "preview-animals", false)}
                    on_open_change="overlay_change"
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
                  <p
                    id="animals-state"
                    class="mt-3 mb-0 break-words text-[11px] leading-[1.55] text-zinc-500 dark:text-zinc-400"
                  >
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
                    open={Map.get(@overlay_open, "custom-animal", false)}
                    on_open_change="overlay_change"
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
                  <p
                    id="custom-animal-state"
                    class="mt-3 mb-0 break-words text-[11px] leading-[1.55] text-zinc-500 dark:text-zinc-400"
                  >
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
                  <p
                    id="otp-state"
                    class="mt-3 mb-0 break-words text-[11px] leading-[1.55] text-zinc-500 dark:text-zinc-400"
                  >
                    Digits entered: {String.length(@otp_value)}
                  </p>
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
          <section
            id="colors"
            class="lp-section scroll-mt-32 pt-20 pb-4 max-[620px]:pt-14"
            aria-labelledby="colors-title"
          >
            <div class="lp-section-heading mb-6 flex items-end justify-between gap-6 max-[620px]:block [&_h2]:m-0 [&_h2]:text-[32px] [&_h2]:font-[510] [&_h2]:leading-[1.13] [&_h2]:tracking-[-.022em] [&>p]:m-0 [&>p]:text-right [&>p]:text-[13px] [&>p]:leading-5 [&>p]:text-[#62666d] dark:[&>p]:text-[#8a8f98] max-[620px]:[&>p]:mt-2 max-[620px]:[&>p]:text-left">
              <div>
                <p class="lp-kicker mb-3 mt-0 text-[10px] font-[510] tracking-[.08em] text-[#62666d] dark:text-[#8a8f98]">
                  COMPONENTS
                </p><h2 id="colors-title">Colors</h2>
              </div>
              <p>Preview and select colors with accessible controls.</p>
            </div>
            <div class="lp-grid grid grid-cols-1 items-start gap-4 min-[700px]:grid-cols-2 lp-grid--colors">
              <.preview_card
                title="Color swatches"
                description="Sizes, shapes, and transparent colors."
              >
                <div class="lp-inline flex flex-wrap items-center gap-2.5">
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
                  class="lp-palette-example !max-w-[272px]"
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
                  <p
                    id="color-state"
                    class="mt-3 mb-0 break-words text-[11px] leading-[1.55] text-zinc-500 dark:text-zinc-400"
                  >
                    Selected: {@accent_color}; Submitted: {@submitted_color || "none"}; Changes: {@color_changes}
                  </p>
                </form>
              </.preview_card>
              <.preview_card
                title="Color field"
                description="Edit and preview a hex color."
              >
                <form
                  id="brand-color-preview"
                  class="lp-color-field-example !max-w-[280px]"
                  phx-change="brand_color_change"
                  phx-submit="brand_color_submit"
                >
                  <.color_field
                    id="brand-color"
                    name="brand_color"
                    label="Color"
                    value={@brand_color}
                    description="Enter a hex color."
                    required
                    full_width
                  />
                  <.button type="submit" size="sm">Submit color</.button>
                  <.button phx-click="set_brand_color" size="sm" variant="secondary">Set purple</.button>
                  <p
                    id="brand-color-state"
                    class="mt-3 mb-0 break-words text-[11px] leading-[1.55] text-zinc-500 dark:text-zinc-400"
                  >
                    Value: {@brand_color}; Submitted: {@submitted_brand_color || "none"}; Changes: {@brand_color_changes}
                  </p>
                </form>
              </.preview_card>
              <.preview_card
                title="Color channels"
                description="Edit HSL channels as numeric form values."
                class="lp-card-wide"
              >
                <form id="color-channels-preview" phx-change="color_channels">
                  <div class="flex flex-wrap gap-3">
                    <.color_field
                      id="color-hue"
                      name="channels[hue]"
                      label="Hue"
                      channel="hue"
                      value={@hue}
                      class="lp-channel-field w-[100px]"
                    >
                      <:suffix>°</:suffix>
                    </.color_field>
                    <.color_field
                      id="color-saturation"
                      name="channels[saturation]"
                      label="Saturation"
                      channel="saturation"
                      value={@saturation}
                      class="lp-channel-field w-[100px]"
                    >
                      <:suffix>%</:suffix>
                    </.color_field>
                    <.color_field
                      id="color-lightness"
                      name="channels[lightness]"
                      label="Lightness"
                      channel="lightness"
                      value={@lightness}
                      class="lp-channel-field w-[100px]"
                    >
                      <:suffix>%</:suffix>
                    </.color_field>
                  </div>
                  <div class="lp-inline mt-4.5 mt-4.5 flex flex-wrap items-center gap-2.5">
                    <.color_swatch
                      color={"hsl(#{@hue} #{@saturation}% #{@lightness}%)"}
                      label="Current HSL color"
                    />
                    <span id="channels-state">HSL: {@hue}°, {@saturation}%, {@lightness}%</span>
                  </div>
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
                <div class="mt-5 w-fit">
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
          <section
            id="selection"
            class="lp-section scroll-mt-32 pt-20 pb-4 max-[620px]:pt-14"
            aria-labelledby="selection-title"
          >
            <div class="lp-section-heading mb-6 flex items-end justify-between gap-6 max-[620px]:block [&_h2]:m-0 [&_h2]:text-[32px] [&_h2]:font-[510] [&_h2]:leading-[1.13] [&_h2]:tracking-[-.022em] [&>p]:m-0 [&>p]:text-right [&>p]:text-[13px] [&>p]:leading-5 [&>p]:text-[#62666d] dark:[&>p]:text-[#8a8f98] max-[620px]:[&>p]:mt-2 max-[620px]:[&>p]:text-left">
              <div>
                <p class="lp-kicker mb-3 mt-0 text-[10px] font-[510] tracking-[.08em] text-[#62666d] dark:text-[#8a8f98]">
                  COMPONENTS
                </p><h2 id="selection-title">
                  Selection &amp; navigation
                </h2>
              </div><p>Choices, navigation, and grouped actions.</p>
            </div>
            <div class="lp-grid grid grid-cols-1 items-start gap-4 min-[700px]:grid-cols-2">
              <.preview_card
                title="Buttons"
                description="Variants, sizes, and a focusable pending state."
              >
                <div class="flex flex-wrap gap-2">
                  <.button
                    :for={variant <- ~w(primary secondary tertiary outline ghost danger danger-soft)}
                    variant={variant}
                  >{String.capitalize(variant)}</.button>
                </div>
                <div class="mt-4 flex flex-wrap items-center gap-2">
                  <.button size="sm" variant="secondary">Small</.button>
                  <.button size="md" variant="secondary">Medium</.button>
                  <.button size="lg" variant="secondary">Large</.button>
                  <.button variant="secondary" disabled>Disabled</.button>
                </div>
                <div class="mt-4 flex flex-wrap items-center gap-2">
                  <.button
                    id="preview-pending-button"
                    pending={@button_pending}
                    phx-click="preview_button_action"
                  >Save changes</.button>
                  <.button
                    id="preview-toggle-pending"
                    variant="secondary"
                    phx-click="preview_button_pending"
                  >{if @button_pending, do: "End pending", else: "Set pending"}</.button>
                </div>
                <form
                  id="pending-button-form"
                  phx-submit="preview_button_submit"
                  class="mt-3 flex flex-wrap items-center gap-2"
                >
                  <.input
                    id="pending-button-input"
                    name="button_example"
                    aria-label="Example value"
                    placeholder="Example value"
                  />
                  <.button id="preview-pending-submit" type="submit" pending={@button_pending}>Submit</.button>
                </form>
                <p id="button-state" class="mt-3 mb-0 text-xs text-zinc-500 dark:text-zinc-400">
                  Pending: {to_string(@button_pending)}; Actions: {@button_actions}; Submissions: {@button_submissions}
                </p>
              </.preview_card>
              <.preview_card
                title="Button groups"
                description="Shared styles, separators, and individual overrides."
              >
                <div class="flex flex-col items-start gap-4">
                  <.button_group label="Editing actions" variant="secondary" size="sm" show_separators>
                    <:button on_click="preview_button_group" value="copy">Copy</:button>
                    <:button on_click="preview_button_group" value="cut">Cut</:button>
                    <:button on_click="preview_button_group" value="paste">Paste</:button>
                  </.button_group>
                  <.button_group label="Disabled group" variant="secondary" disabled show_separators>
                    <:button>Disabled</:button>
                    <:button disabled={false} on_click="preview_button_group" value="available">Available</:button>
                  </.button_group>
                  <.button_group
                    label="Vertical actions"
                    orientation="vertical"
                    variant="outline"
                    show_separators
                  >
                    <:button>Top</:button><:button>Middle</:button><:button>Bottom</:button>
                  </.button_group>
                </div>
                <p id="button-group-state" class="mt-3 mb-0 text-xs text-zinc-500 dark:text-zinc-400">
                  Action: {@button_group_action}
                </p>
              </.preview_card>
              <.preview_card
                title="Form controls"
                description="Checkboxes, switches, sliders, and more."
              >
                <form
                  phx-change="settings"
                  class="lp-settings flex flex-col gap-[14px]"
                >
                  <input type="hidden" name="terms" value="false" />
                  <.checkbox id="live-terms" name="terms" checked={@terms}>Accept terms</.checkbox>
                  <input type="hidden" name="alerts" value="false" />
                  <.switch id="live-alerts" name="alerts" checked={@alerts}>Enable alerts</.switch>
                  <label
                    for="live-plan"
                    class="label text-sm font-medium text-foreground [&.label--required]:after:ms-0.5 [&.label--required]:after:text-danger [&.label--required]:after:content-['*'] [[data-required=true]:not([role=group]):not([role=radiogroup]):not([role=checkboxgroup])>&]:after:ms-0.5 [[data-required=true]:not([role=group]):not([role=radiogroup]):not([role=checkboxgroup])>&]:after:text-danger [[data-required=true]:not([role=group]):not([role=radiogroup]):not([role=checkboxgroup])>&]:after:content-['*'] [[data-required=true]:not([data-slot=radio]):not([data-slot=checkbox])>&]:after:ms-0.5 [[data-required=true]:not([data-slot=radio]):not([data-slot=checkbox])>&]:after:text-danger [[data-required=true]:not([data-slot=radio]):not([data-slot=checkbox])>&]:after:content-['*'] [&.label--disabled]:status-disabled [[data-disabled=true]_&]:status-disabled [&.label--invalid]:text-danger [[data-invalid=true]_&]:text-danger [[aria-invalid=true]_&]:text-danger"
                  >Plan</label>
                  <.select
                    id="live-plan"
                    open={Map.get(@overlay_open, "live-plan", false)}
                    on_open_change="overlay_change"
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
                  <p
                    id="topics-state"
                    class="mt-3 mb-0 break-words text-[11px] leading-[1.55] text-zinc-500 dark:text-zinc-400"
                  >
                    Interests: {Enum.join(@topics, ", ")}
                  </p>
                  <p
                    id="delivery-state"
                    class="mt-3 mb-0 break-words text-[11px] leading-[1.55] text-zinc-500 dark:text-zinc-400"
                  >
                    Delivery: {@delivery}
                  </p>
                  <p
                    id="range-state"
                    class="mt-3 mb-0 break-words text-[11px] leading-[1.55] text-zinc-500 dark:text-zinc-400"
                  >
                    Volume: {@volume}; Quantity: {@quantity}
                  </p>
                  <p
                    id="settings-state"
                    class="mt-3 mb-0 break-words text-[11px] leading-[1.55] text-zinc-500 dark:text-zinc-400"
                  >
                    Terms: {to_string(@terms)}; Alerts: {to_string(@alerts)}; Plan: {@plan}
                  </p>
                </form>
              </.preview_card>
              <.preview_card
                title="Checkbox states"
                description="Selected, indeterminate, and invalid choices."
              >
                <div class="flex flex-col gap-4">
                  <.checkbox id="preview-checkbox-mixed" indeterminate>
                    Select all notifications
                  </.checkbox>
                  <.checkbox id="preview-checkbox-mixed-invalid" indeterminate invalid>
                    Invalid selection
                  </.checkbox>
                </div>
              </.preview_card>
              <.preview_card title="Number fields" description="Bounds, step values, and validation.">
                <div class="flex flex-col gap-5">
                  <.number_field
                    id="preview-number-step"
                    label="Quantity"
                    value={4}
                    min={0}
                    max={10}
                    step={2}
                    description="Choose between 0 and 10."
                    full_width
                  />
                  <.number_field
                    id="preview-number-invalid"
                    label="Discount"
                    value={15}
                    min={0}
                    max={10}
                    errors={["Enter a value between 0 and 10."]}
                    full_width
                  />
                  <.number_field
                    id="preview-number-readonly"
                    label="Read-only"
                    value={5}
                    read_only
                    variant="secondary"
                    full_width
                  />
                  <fieldset disabled>
                    <.number_field id="preview-number-disabled" label="Disabled" value={3} full_width />
                  </fieldset>
                </div>
              </.preview_card>
              <.preview_card title="Close button" description="Default, disabled, and custom icons.">
                <div class="flex items-center gap-4">
                  <.close_button label="Dismiss example" phx-click="close_button_clicked" />
                  <.close_button label="Disabled close" disabled />
                  <.close_button label="Dismiss with custom icon" phx-click="close_button_clicked">
                    <OlisUI.Icon.icon name="circle-xmark" />
                  </.close_button>
                </div>
                <p id="close-button-state" class="mt-3 mb-0 text-xs text-zinc-500 dark:text-zinc-400">
                  Clicked: {@close_button_count}
                </p>
              </.preview_card>
              <.preview_card
                title="Sliders"
                description="Ranges, steps, marks, and vertical controls."
              >
                <div class="flex flex-col gap-8">
                  <.slider
                    id="preview-price-range"
                    name="price_range"
                    label="Price range"
                    value={[20, 80]}
                    step={10}
                    show_steps
                    marks={[{0, "$0"}, {50, "$50"}, {100, "$100"}]}
                  />
                  <div class="flex h-64 items-stretch gap-10">
                    <.slider
                      id="preview-brightness"
                      label="Brightness"
                      value={40}
                      step={10}
                      orientation="vertical"
                      show_steps
                      marks={[0, 50, 100]}
                    />
                    <.slider
                      id="preview-disabled-slider"
                      label="Disabled"
                      value={30}
                      orientation="vertical"
                      disabled
                    />
                  </div>
                </div>
              </.preview_card>
              <.preview_card
                title="Switches"
                description="Sizes, disabled states, and a label-free control."
              >
                <div class="flex flex-col items-start gap-4">
                  <.switch id="switch-preview-small" size="sm">Small</.switch>
                  <.switch id="switch-preview-medium" checked>Medium</.switch>
                  <.switch id="switch-preview-large" size="lg">Large</.switch>
                  <.switch id="switch-preview-disabled" checked disabled>Disabled</.switch>
                  <.switch
                    id="switch-preview-readonly"
                    name="readonly_preference"
                    checked
                    read_only={@switch_read_only}
                  >
                    Read-only setting
                  </.switch>
                  <.button
                    id="switch-readonly-toggle"
                    size="sm"
                    variant="secondary"
                    phx-click="toggle_switch_read_only"
                  >{if @switch_read_only, do: "Make editable", else: "Make read-only"}</.button>
                  <.switch id="switch-preview-icon-only" aria-label="Toggle sound" />
                </div>
              </.preview_card>
              <.preview_card
                title="Switch groups"
                description="Group independent settings vertically or horizontally."
              >
                <form phx-change="switch_group_change">
                  <.switch_group
                    id="notifications-group"
                    label="Notifications"
                    description="Choose which updates you receive."
                  >
                    <input type="hidden" name="news" value="false" />
                    <.switch
                      id="switch-news"
                      name="news"
                      checked={@switch_news}
                      description="Important account activity."
                    >
                      Account updates
                    </.switch>
                    <input type="hidden" name="marketing" value="false" />
                    <.switch id="switch-marketing" name="marketing" checked={@switch_marketing}>
                      Marketing emails
                    </.switch>
                    <input type="hidden" name="updates" value="false" />
                    <.switch id="switch-updates" name="updates" checked={@switch_updates}>
                      Product news
                    </.switch>
                  </.switch_group>
                  <p
                    id="switch-group-state"
                    class="mt-3 mb-0 break-words text-[11px] leading-[1.55] text-zinc-500 dark:text-zinc-400"
                  >
                    Account: {to_string(@switch_news)}; Marketing: {to_string(@switch_marketing)}; Product: {to_string(
                      @switch_updates
                    )}
                  </p>
                </form>
                <.switch_group
                  orientation="horizontal"
                  class="mt-5 flex-wrap"
                  aria-label="Display options"
                >
                  <.switch id="switch-grid" size="sm" checked>Grid</.switch>
                  <.switch id="switch-labels" size="sm" label_position="start">Labels</.switch>
                </.switch_group>
              </.preview_card>
              <.preview_card title="Select" description="Grouped, multiple, and required choices.">
                <form phx-change="select_examples">
                  <label
                    for="grouped-plan"
                    class="label text-sm font-medium text-foreground [&.label--required]:after:ms-0.5 [&.label--required]:after:text-danger [&.label--required]:after:content-['*'] [[data-required=true]:not([role=group]):not([role=radiogroup]):not([role=checkboxgroup])>&]:after:ms-0.5 [[data-required=true]:not([role=group]):not([role=radiogroup]):not([role=checkboxgroup])>&]:after:text-danger [[data-required=true]:not([role=group]):not([role=radiogroup]):not([role=checkboxgroup])>&]:after:content-['*'] [[data-required=true]:not([data-slot=radio]):not([data-slot=checkbox])>&]:after:ms-0.5 [[data-required=true]:not([data-slot=radio]):not([data-slot=checkbox])>&]:after:text-danger [[data-required=true]:not([data-slot=radio]):not([data-slot=checkbox])>&]:after:content-['*'] [&.label--disabled]:status-disabled [[data-disabled=true]_&]:status-disabled [&.label--invalid]:text-danger [[data-invalid=true]_&]:text-danger [[aria-invalid=true]_&]:text-danger"
                  >Grouped plans</label>
                  <.select
                    name="grouped"
                    id="grouped-plan"
                    open={Map.get(@overlay_open, "grouped-plan", false)}
                    on_open_change="overlay_change"
                    options={[
                      {"Basic", [{"Starter", "starter"}, {"Pro", "pro"}]},
                      {"Other", [[key: "Disabled", value: "disabled", disabled: true]]}
                    ]}
                    value={@grouped_plan}
                  />
                  <label
                    for="native-multiple"
                    class="label text-sm font-medium text-foreground [&.label--required]:after:ms-0.5 [&.label--required]:after:text-danger [&.label--required]:after:content-['*'] [[data-required=true]:not([role=group]):not([role=radiogroup]):not([role=checkboxgroup])>&]:after:ms-0.5 [[data-required=true]:not([role=group]):not([role=radiogroup]):not([role=checkboxgroup])>&]:after:text-danger [[data-required=true]:not([role=group]):not([role=radiogroup]):not([role=checkboxgroup])>&]:after:content-['*'] [[data-required=true]:not([data-slot=radio]):not([data-slot=checkbox])>&]:after:ms-0.5 [[data-required=true]:not([data-slot=radio]):not([data-slot=checkbox])>&]:after:text-danger [[data-required=true]:not([data-slot=radio]):not([data-slot=checkbox])>&]:after:content-['*'] [&.label--disabled]:status-disabled [[data-disabled=true]_&]:status-disabled [&.label--invalid]:text-danger [[data-invalid=true]_&]:text-danger [[aria-invalid=true]_&]:text-danger"
                  >Multiple choices</label>
                  <.select
                    id="native-multiple"
                    name="multiple[]"
                    value={@multiple_choices}
                    options={[{"One", "one"}, {"Two", "two"}]}
                    multiple
                  />
                </form>
                <form
                  phx-change="required_change"
                  phx-submit="required_submit"
                  class="lp-settings flex flex-col gap-[14px]"
                >
                  <label
                    for="required-choice"
                    class="label text-sm font-medium text-foreground [&.label--required]:after:ms-0.5 [&.label--required]:after:text-danger [&.label--required]:after:content-['*'] [[data-required=true]:not([role=group]):not([role=radiogroup]):not([role=checkboxgroup])>&]:after:ms-0.5 [[data-required=true]:not([role=group]):not([role=radiogroup]):not([role=checkboxgroup])>&]:after:text-danger [[data-required=true]:not([role=group]):not([role=radiogroup]):not([role=checkboxgroup])>&]:after:content-['*'] [[data-required=true]:not([data-slot=radio]):not([data-slot=checkbox])>&]:after:ms-0.5 [[data-required=true]:not([data-slot=radio]):not([data-slot=checkbox])>&]:after:text-danger [[data-required=true]:not([data-slot=radio]):not([data-slot=checkbox])>&]:after:content-['*'] [&.label--disabled]:status-disabled [[data-disabled=true]_&]:status-disabled [&.label--invalid]:text-danger [[data-invalid=true]_&]:text-danger [[aria-invalid=true]_&]:text-danger"
                  >Required choice</label>
                  <.select
                    id="required-choice"
                    open={Map.get(@overlay_open, "required-choice", false)}
                    on_open_change="overlay_change"
                    name="choice"
                    value={@required_value}
                    prompt="Choose an option"
                    options={[{"Alpha", "alpha"}, {"Beta", "beta"}]}
                    required
                  />
                  <.button type="submit">Submit choice</.button>
                  <p
                    id="required-result"
                    class="mt-3 mb-0 break-words text-[11px] leading-[1.55] text-zinc-500 dark:text-zinc-400"
                  >
                    Submitted: {@required_choice || "none"}
                  </p>
                </form>
              </.preview_card>
              <.preview_card title="Tag group" description="Select or remove topics.">
                <.tag_group
                  id="preview-tags"
                  label="Topics"
                  description="Select or remove topics"
                  selection_mode="multiple"
                  selected_keys={@selected_tags}
                  on_selection_change="select_tag"
                  on_remove="remove_tag"
                  class="mb-6"
                >
                  <:tag :for={value <- @tag_values} value={value} label={String.capitalize(value)} />
                  <:tag value="disabled" label="Disabled" disabled />
                </.tag_group>
                <p
                  id="tag-state"
                  class="mt-3 mb-0 break-words text-[11px] leading-[1.55] text-zinc-500 dark:text-zinc-400"
                >
                  Selected topics: {Enum.join(@selected_tags, ", ")}
                </p>
                <.tag_group
                  id="preview-tags-local"
                  label="Topics selection"
                  selection_mode="multiple"
                  selected_keys={@local_tag_selection}
                  on_selection_change="preview_local_tag_selection"
                  on_remove="preview_remove_local_tag"
                >
                  <:tag
                    :for={value <- @local_tag_values}
                    value={value}
                    label={String.capitalize(value)}
                  />
                  <:tag value="disabled" label="Disabled" disabled />
                  <:remove_button value="travel" label="Remove Travel from selection">
                    <OlisUI.Icon.icon name="circle-xmark" />
                  </:remove_button>
                </.tag_group>
                <p id="local-tag-state" class="mt-3 mb-0 text-xs text-zinc-500 dark:text-zinc-400">
                  Selected: {Enum.join(@local_tag_selection, ", ")}
                </p>
              </.preview_card>
              <.preview_card
                title="Toggle buttons"
                description="LiveView-controlled selection states."
              >
                <div class="flex flex-wrap items-center gap-2">
                  <.toggle_button
                    id="toggle-preview-local"
                    pressed={@toggle_favorite}
                    phx-click="preview_toggle"
                    phx-value-key="favorite"
                  >Favorite</.toggle_button>
                  <.toggle_button
                    id="toggle-preview-initial"
                    variant="ghost"
                    pressed={@toggle_following}
                    phx-click="preview_toggle"
                    phx-value-key="following"
                  >Following</.toggle_button>
                  <.toggle_button disabled>Disabled</.toggle_button>
                </div>
                <p class="mt-4 mb-2 text-xs text-muted">Group size and disabled state</p>
                <.toggle_button_group
                  label="Group inheritance"
                  size="sm"
                  disabled={@toggle_group_disabled}
                >
                  <.toggle_button
                    id="toggle-group-inherited"
                    pressed={@toggle_inherited}
                    phx-click="preview_toggle"
                    phx-value-key="inherited"
                  >Inherited small</.toggle_button>
                  <.toggle_button
                    id="toggle-group-override"
                    size="lg"
                    pressed={@toggle_override}
                    phx-click="preview_toggle"
                    phx-value-key="override"
                  >Explicit large</.toggle_button>
                </.toggle_button_group>
                <.button
                  id="toggle-group-disabled-control"
                  size="sm"
                  variant="secondary"
                  phx-click="preview_toggle_group_disabled"
                >{if @toggle_group_disabled, do: "Enable group", else: "Disable group"}</.button>
                <p class="mt-4 mb-2 text-xs text-muted">Single selection (LiveView)</p>
                <.toggle_button_group
                  label="Alignment"
                  selection_mode="single"
                  selected_keys={@toggle_alignment}
                  on_selection_change="preview_alignment"
                  disallow_empty_selection
                >
                  <.toggle_button value="left">Left</.toggle_button>
                  <.toggle_button value="center">Center</.toggle_button>
                  <.toggle_button value="right">Right</.toggle_button>
                </.toggle_button_group>
                <p class="mt-4 mb-2 text-xs text-muted">Multiple selection (LiveView)</p>
                <.toggle_button_group
                  label="Text style"
                  selection_mode="multiple"
                  selected_keys={@toggle_group_formats}
                  on_selection_change="preview_toggle_group_change"
                >
                  <.toggle_button value="bold">Bold</.toggle_button>
                  <.toggle_button value="italic">Italic</.toggle_button>
                  <.toggle_button value="underline">Underline</.toggle_button>
                </.toggle_button_group>
                <p id="toggle-group-state" class="mt-2 mb-0 text-xs text-muted">
                  Selected: {Enum.join(@toggle_group_formats, ", ")}
                </p>
              </.preview_card>
              <.preview_card
                title="Listbox & actions"
                description="Choose a workspace and toggle formatting."
              >
                <div class="lp-inline flex flex-wrap items-center gap-2.5">
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
                <div class="lp-listbox-surface mt-[18px] w-full max-w-64 rounded-[14px] bg-[var(--surface)]">
                  <.listbox
                    id="workspace-list"
                    label="Workspace"
                    on_selection_change="select_workspace"
                    selected_keys={@workspace}
                  >
                    <:option value="alpha" label="Alpha" description="Main workspace" />
                    <:option value="beta" label="Beta" />
                    <:option value="gamma" label="Unavailable" disabled />
                  </.listbox>
                </div>
                <p
                  id="workspace-state"
                  class="mt-3 mb-0 break-words text-[11px] leading-[1.55] text-zinc-500 dark:text-zinc-400"
                >
                  Workspace: {Enum.join(@workspace)}
                </p>
                <p
                  id="format-state"
                  class="mt-3 mb-0 break-words text-[11px] leading-[1.55] text-zinc-500 dark:text-zinc-400"
                >
                  Bold: {to_string(@bold)}; Italic: {to_string(@italic)}
                </p>
                <p
                  id="outside-count"
                  class="mt-3 mb-0 break-words text-[11px] leading-[1.55] text-zinc-500 dark:text-zinc-400"
                >
                  Updates: {@count}
                </p>
              </.preview_card>
              <.preview_card
                title="Listbox sections"
                description="LiveView selection and actions."
              >
                <.listbox
                  id="notification-list"
                  label="Notifications"
                  selection_mode="multiple"
                  selected_keys={@listbox_selected}
                  on_selection_change="listbox_selection"
                  on_action="listbox_action"
                >
                  <:section
                    label="Delivery"
                    items={[
                      %{value: "email", label: "Email", description: "Send updates by email"},
                      %{value: "push", label: "Push notifications"}
                    ]}
                  />
                  <:section
                    label="Other"
                    items={[
                      %{value: "sms", label: "SMS", disabled: true},
                      %{value: "none", label: "Mute notifications", variant: "danger"}
                    ]}
                  />
                </.listbox>
                <p id="listbox-selection-state" class="mt-3 text-xs text-muted">
                  Selected: {Enum.join(@listbox_selected, ", ")}; Action: {@listbox_action}
                </p>
              </.preview_card>
              <.preview_card
                title="Toolbar"
                description="Use arrow keys to move between related controls."
                class="lp-card-wide"
              >
                <div class="lp-toolbar-examples flex flex-wrap items-start gap-8">
                  <div>
                    <.toolbar id="preview-toolbar" label="Text formatting">
                      <.toggle_button_group label="Text style">
                        <.toggle_button
                          icon_only
                          aria-label="Bold"
                          pressed={@bold}
                          phx-click="toggle_format"
                          phx-value-format="bold"
                        ><OlisUI.Icon.icon name="bold" class="size-4" /></.toggle_button>
                        <.toggle_button
                          icon_only
                          aria-label="Italic"
                          pressed={@italic}
                          phx-click="toggle_format"
                          phx-value-format="italic"
                        ><OlisUI.Icon.icon name="italic" class="size-4" /></.toggle_button>
                        <.toggle_button
                          icon_only
                          aria-label="Underline"
                          pressed={@underline}
                          phx-click="toggle_format"
                          phx-value-format="underline"
                        ><OlisUI.Icon.icon name="underline" class="size-4" /></.toggle_button>
                      </.toggle_button_group>
                      <.separator orientation="vertical" />
                      <.button_group label="Editing">
                        <.button
                          icon_only
                          variant="tertiary"
                          aria-label="Copy"
                          phx-click="toolbar_action"
                          phx-value-action="Copy"
                        ><OlisUI.Icon.icon name="copy" class="size-4" /></.button>
                        <.button
                          icon_only
                          variant="tertiary"
                          aria-label="Cut"
                          phx-click="toolbar_action"
                          phx-value-action="Cut"
                        ><OlisUI.Icon.icon name="scissors" class="size-4" /></.button>
                      </.button_group>
                    </.toolbar>
                    <p
                      id="toolbar-state"
                      class="mt-3 mb-0 break-words text-[11px] leading-[1.55] text-zinc-500 dark:text-zinc-400"
                    >
                      Bold: {to_string(@bold)}; Italic: {to_string(@italic)}; Underline: {to_string(
                        @underline
                      )}; Action: {@toolbar_action}
                    </p>
                  </div>
                  <.toolbar id="vertical-toolbar" label="History" orientation="vertical" attached>
                    <.button
                      icon_only
                      variant="tertiary"
                      aria-label="Undo"
                      phx-click="toolbar_action"
                      phx-value-action="Undo"
                    ><OlisUI.Icon.icon name="arrow-rotate-left" class="size-4" /></.button>
                    <.button
                      icon_only
                      variant="tertiary"
                      aria-label="Redo"
                      phx-click="toolbar_action"
                      phx-value-action="Redo"
                    ><OlisUI.Icon.icon name="arrow-rotate-right" class="size-4" /></.button>
                    <.button icon_only variant="tertiary" aria-label="Unavailable" disabled>×</.button>
                  </.toolbar>
                </div>
              </.preview_card>
              <.preview_card title="Disclosure" description="Expand a section to reveal more detail.">
                <.disclosure
                  id="project-disclosure"
                  title="Project details"
                  open={@project_open}
                  on_toggle="project_toggle"
                >
                  <p>Share the details your team needs, when they need them.</p>
                </.disclosure>
                <div class="mt-4">
                  <.disclosure id="disabled-disclosure" title="Unavailable" disabled>
                    <p>This content is not available.</p>
                  </.disclosure>
                </div>
              </.preview_card>
              <.preview_card
                title="Disclosure group"
                description="One section at a time, controlled by LiveView."
                class="lp-card-wide"
              >
                <.disclosure_group
                  id="account-disclosures"
                  class="lp-disclosure-group [&>.olis-disclosure:not(:first-child)]:mt-2"
                  expanded_keys={@disclosure_expanded}
                  on_toggle="disclosure_toggle"
                >
                  <:item key="account" title="Account">
                    <p>Manage your profile and personal details.</p>
                  </:item>
                  <:item key="billing" title="Billing">
                    <p>Review payment methods and invoices.</p>
                  </:item>
                  <:item key="security" title="Security">
                    <p>Update your password and sign-in preferences.</p>
                  </:item>
                </.disclosure_group>
                <.button phx-click="open_billing" size="sm" variant="tertiary" class="mt-4">Open billing</.button>
                <p
                  id="disclosure-state"
                  class="mt-3 mb-0 break-words text-[11px] leading-[1.55] text-zinc-500 dark:text-zinc-400"
                >
                  Expanded: {Enum.join(@disclosure_expanded, ", ")}; Last: {@disclosure_last}
                </p>
              </.preview_card>
              <.preview_card
                title="Multiple disclosures"
                description="Keep several sections open at once."
              >
                <.disclosure_group
                  id="multiple-disclosures"
                  class="lp-disclosure-group [&>.olis-disclosure:not(:first-child)]:mt-2"
                  expanded_keys={@multiple_disclosures}
                  on_toggle="multiple_disclosures"
                >
                  <:item key="first" title="First section">
                    <p>LiveView manages each expanded section.</p>
                  </:item>
                  <:item key="second" title="Second section">
                    <p>Opening this one leaves the first open.</p>
                  </:item>
                  <:item key="third" title="Unavailable" disabled>
                    <p>This section is disabled.</p>
                  </:item>
                </.disclosure_group>
              </.preview_card>
              <.preview_card title="Tabs" description="Switch between account sections.">
                <.tabs
                  id="preview-tabs"
                  label="Account sections"
                  selected_key={@preview_tab}
                  on_selection_change="preview_tab"
                >
                  <:tab id="profile" label="Profile">
                    <p>Profile settings</p>
                  </:tab>
                  <:tab id="security" label="Security">
                    <p id="tab-count">Security updates: {@count}</p><.button phx-click="increment">Update tab</.button>
                  </:tab>
                  <:tab id="disabled" label="Disabled" disabled>Unavailable</:tab>
                </.tabs>
              </.preview_card>
              <.preview_card
                title="Controlled tabs"
                description="Manual activation and server-controlled selection."
              >
                <.tabs
                  id="controlled-tabs"
                  label="Reports"
                  variant="secondary"
                  activation_mode="manual"
                  selected_key={@tabs_selection}
                  on_selection_change="tabs_selection"
                >
                  <:tab id="overview" label="Overview">Overview of your project.</:tab>
                  <:tab id="analytics" label="Analytics">Analytics for your project.</:tab>
                  <:tab id="reports" label="Reports">Your latest reports.</:tab>
                </.tabs>
                <p
                  id="tabs-selection-state"
                  class="mt-3 mb-0 text-xs text-zinc-500 dark:text-zinc-400"
                >
                  Selected: {@tabs_selection}
                </p>
                <.button
                  size="sm"
                  variant="secondary"
                  class="mt-3"
                  phx-click="tabs_selection"
                  phx-value-key="reports"
                >Select reports</.button>
              </.preview_card>
              <.preview_card title="Scrollable tabs" description="Overflow controls and separators.">
                <.tabs
                  id="overflow-tabs"
                  label="Workspace sections"
                  selected_key={@overflow_tab}
                  on_selection_change="overflow_tab"
                  show_separators
                  class="w-full"
                >
                  <:tab id="overview" label="Overview">Workspace overview.</:tab>
                  <:tab id="activity" label="Activity">Recent activity.</:tab>
                  <:tab id="members" label="Members">Workspace members.</:tab>
                  <:tab id="billing" label="Billing">Billing details.</:tab>
                  <:tab id="settings" label="Settings">Workspace settings.</:tab>
                </.tabs>
              </.preview_card>
              <.preview_card title="Vertical tabs" description="A compact navigation layout.">
                <.tabs
                  id="vertical-tabs"
                  label="Account settings"
                  selected_key={@vertical_tab}
                  on_selection_change="vertical_tab"
                  orientation="vertical"
                  variant="secondary"
                  align="start"
                >
                  <:tab id="account" label="Account">Manage your account.</:tab>
                  <:tab id="security" label="Security">Security settings.</:tab>
                  <:tab id="notifications" label="Notifications">Notification settings.</:tab>
                </.tabs>
              </.preview_card>
            </div>
          </section>
          <section
            id="overlays"
            class="lp-section scroll-mt-32 pt-20 pb-4 max-[620px]:pt-14"
            aria-labelledby="overlays-title"
          >
            <div class="lp-section-heading mb-6 flex items-end justify-between gap-6 max-[620px]:block [&_h2]:m-0 [&_h2]:text-[32px] [&_h2]:font-[510] [&_h2]:leading-[1.13] [&_h2]:tracking-[-.022em] [&>p]:m-0 [&>p]:text-right [&>p]:text-[13px] [&>p]:leading-5 [&>p]:text-[#62666d] dark:[&>p]:text-[#8a8f98] max-[620px]:[&>p]:mt-2 max-[620px]:[&>p]:text-left">
              <div>
                <p class="lp-kicker mb-3 mt-0 text-[10px] font-[510] tracking-[.08em] text-[#62666d] dark:text-[#8a8f98]">
                  COMPONENTS
                </p><h2 id="overlays-title">Overlays</h2>
              </div><p>Dialogs and contextual actions.</p>
            </div>
            <div class="lp-grid grid grid-cols-1 items-start gap-4 min-[700px]:grid-cols-2">
              <.preview_card
                title="Sheets"
                description="Swipe an edge panel or snap it between sizes."
              >
                <div class="flex flex-wrap gap-2">
                  <.button data-olis-sheet-open="preview-sheet">Bottom sheet</.button>
                  <.button data-olis-sheet-open="preview-sheet-right" variant="secondary">Right sheet</.button>
                  <.button data-olis-sheet-open="preview-sheet-top" variant="secondary">Top sheet</.button>
                  <.button data-olis-sheet-open="preview-sheet-left" variant="secondary">Left sheet</.button>
                  <.button data-olis-sheet-open="preview-sheet-snap" variant="secondary">Snap points</.button>
                  <.button data-olis-sheet-open="preview-sheet-controlled" variant="secondary">Controlled</.button>
                </div>
                <p
                  id="sheet-state"
                  class="mt-3 mb-0 break-words text-[11px] leading-[1.55] text-zinc-500 dark:text-zinc-400"
                >
                  Last controlled change: {@sheet_last}
                </p>
                <.sheet
                  id="preview-sheet"
                  open={Map.get(@overlay_open, "preview-sheet", false)}
                  on_open_change="overlay_change"
                  title="Sheet title"
                  class="max-w-[420px]"
                  description="A focused space for a quick task."
                >
                  <p class="mt-3 text-sm text-muted">
                    Drag the handle to dismiss, or open a nested sheet.
                  </p>
                  <.button
                    data-olis-sheet-open="preview-sheet-nested"
                    class="mt-4"
                    variant="secondary"
                  >Open nested sheet</.button>
                  <.button phx-click="increment" class="mt-4" variant="secondary">Update count: {@count}</.button>
                  <.sheet
                    id="preview-sheet-nested"
                    open={Map.get(@overlay_open, "preview-sheet-nested", false)}
                    on_open_change="overlay_change"
                    title="Nested sheet"
                    class="max-w-[380px]"
                  >
                    <p class="text-sm text-muted">Close this sheet to return to the previous one.</p>
                    <:footer>
                      <.button data-olis-sheet-close variant="secondary">Done</.button>
                    </:footer>
                  </.sheet>
                  <:footer>
                    <.button data-olis-sheet-close variant="secondary">Cancel</.button><.button data-olis-sheet-close>Confirm</.button>
                  </:footer>
                </.sheet>
                <.sheet
                  id="preview-sheet-right"
                  open={Map.get(@overlay_open, "preview-sheet-right", false)}
                  on_open_change="overlay_change"
                  title="Details"
                  placement="right"
                  detached
                >
                  <p class="text-sm text-muted">A detached sheet can appear from any edge.</p>
                  <:footer><.button data-olis-sheet-close variant="secondary">Done</.button></:footer>
                </.sheet>
                <.sheet
                  id="preview-sheet-top"
                  open={Map.get(@overlay_open, "preview-sheet-top", false)}
                  on_open_change="overlay_change"
                  title="Top sheet"
                  placement="top"
                  class="max-w-[420px]"
                >
                  <p class="text-sm text-muted">This sheet opens from the top edge.</p>
                  <:footer><.button data-olis-sheet-close variant="secondary">Done</.button></:footer>
                </.sheet>
                <.sheet
                  id="preview-sheet-left"
                  open={Map.get(@overlay_open, "preview-sheet-left", false)}
                  on_open_change="overlay_change"
                  title="Left sheet"
                  placement="left"
                >
                  <p class="text-sm text-muted">This sheet opens from the left edge.</p>
                  <:footer><.button data-olis-sheet-close variant="secondary">Done</.button></:footer>
                </.sheet>
                <.sheet
                  id="preview-sheet-snap"
                  open={Map.get(@overlay_open, "preview-sheet-snap", false)}
                  on_open_change="overlay_change"
                  title="Explore updates"
                  class="max-w-[420px]"
                  snap_points={[220, "55%"]}
                  snap_index={@sheet_snap_index}
                  on_snap_change="sheet_snap_change"
                >
                  <div class="space-y-4 text-sm text-muted">
                    <p :for={i <- 1..30}>Update {i}: swipe up to expand and scroll this sheet.</p>
                  </div>
                  <:footer><.button data-olis-sheet-close variant="secondary">Done</.button></:footer>
                </.sheet>
                <.sheet
                  id="preview-sheet-controlled"
                  title="Controlled sheet"
                  class="max-w-[420px]"
                  open={@controlled_sheet_open}
                  on_open_change="sheet_open_change"
                >
                  <p class="text-sm text-muted">LiveView controls whether this sheet is open.</p>
                  <:footer><.button data-olis-sheet-close variant="secondary">Done</.button></:footer>
                </.sheet>
              </.preview_card>
              <.preview_card
                title="Dropdown menus"
                description="Sections, selection, and nested actions."
              >
                <div class="flex flex-wrap gap-2">
                  <.dropdown
                    id="view-menu"
                    open_submenus={@dropdown_submenus}
                    on_submenus_change="dropdown_submenus"
                    open={Map.get(@overlay_open, "view-menu", false)}
                    on_open_change="overlay_change"
                    label="View options"
                    on_action="dropdown_action"
                  >
                    <:section
                      label="Sort by"
                      selection_mode="single"
                      selected_keys={[@dropdown_sort]}
                      on_selection_change="dropdown_sort"
                      items={[
                        %{key: "newest", label: "Newest first"},
                        %{key: "oldest", label: "Oldest first"}
                      ]}
                    />
                    <:section
                      label="Visible columns"
                      selection_mode="multiple"
                      selected_keys={@dropdown_columns}
                      on_selection_change="dropdown_columns"
                      items={[
                        %{key: "name", label: "Name"},
                        %{key: "status", label: "Status"},
                        %{key: "owner", label: "Owner"}
                      ]}
                    />
                    <:section
                      label="Share"
                      items={[
                        %{
                          label: "Share project",
                          items: [
                            %{key: "email", label: "Email", description: "Send a link"},
                            %{key: "copy", label: "Copy link", shortcut: "⌘ C"},
                            %{label: "More", items: [%{key: "export", label: "Export"}]}
                          ]
                        }
                      ]}
                    />
                  </.dropdown>
                  <.dropdown
                    id="format-menu"
                    open={Map.get(@overlay_open, "format-menu", false)}
                    on_open_change="overlay_change"
                    label="Formatting"
                    selection_mode="multiple"
                    selected_keys={@dropdown_format}
                    on_selection_change="dropdown_format"
                  >
                    <:item key="bold" label="Bold" /><:item key="italic" label="Italic" /><:item
                      key="underline"
                      label="Underline"
                    />
                  </.dropdown>
                </div>
                <p
                  id="dropdown-state"
                  class="mt-3 mb-0 break-words text-[11px] leading-[1.55] text-zinc-500 dark:text-zinc-400"
                >
                  Sort: {@dropdown_sort}; Columns: {Enum.join(@dropdown_columns, ", ")}; Action: {@dropdown_last}
                </p>
              </.preview_card>
              <.preview_card title="Tooltips" description="Hover or focus to see each placement.">
                <div class="flex flex-wrap gap-2">
                  <.tooltip
                    :for={side <- ~w(top bottom left right)}
                    id={"tooltip-#{side}"}
                    open={Map.get(@overlay_open, "tooltip-#{side}", false)}
                    on_open_change="overlay_change"
                    text={"#{String.capitalize(side)} tooltip"}
                    placement={side}
                    delay={0}
                    close_delay={0}
                  >
                    {String.capitalize(side)}
                  </.tooltip>
                  <.tooltip
                    id="tooltip-rich"
                    open={Map.get(@overlay_open, "tooltip-rich", false)}
                    on_open_change="overlay_change"
                    show_arrow
                    delay={0}
                    close_delay={0}
                  >
                    <:trigger :let={attrs}>
                      <.button variant="secondary" {attrs}>Rich tooltip</.button>
                    </:trigger>
                    <:content><strong>Helpful detail:</strong> save your changes.</:content>
                  </.tooltip>
                </div>
              </.preview_card>
              <.preview_card
                title="Dialogs & menus"
                description="Open each overlay to explore its behavior."
                class="lp-card-wide"
              >
                <div class="space-y-5">
                  <div>
                    <p class="mb-2 text-xs font-medium text-muted">Modals</p>
                    <div class="flex flex-wrap gap-2">
                      <.button data-olis-dialog-open="live-modal">Open modal</.button>
                      <.button data-olis-dialog-open="live-modal-controlled" variant="secondary">Controlled modal</.button>
                      <.button data-olis-dialog-open="live-modal-bottom" variant="secondary">Bottom modal</.button>
                      <.button data-olis-dialog-open="live-alert" variant="danger-soft">Open alert dialog</.button>
                    </div>
                    <p id="modal-state" class="mt-2 mb-0 text-xs text-muted">
                      Last modal change: {@modal_last}
                    </p>
                  </div>
                  <div>
                    <p class="mb-2 text-xs font-medium text-muted">Drawers</p>
                    <div class="flex flex-wrap gap-2">
                      <.button data-olis-dialog-open="live-drawer" variant="secondary">Open drawer</.button>
                      <.button data-olis-dialog-open="live-drawer-blur" variant="secondary">Blurred drawer</.button>
                      <.button data-olis-dialog-open="live-drawer-clear" variant="secondary">Transparent drawer</.button>
                      <.button data-olis-dialog-open="live-drawer-controlled" variant="secondary">Controlled drawer</.button>
                    </div>
                    <p id="drawer-state" class="mt-2 mb-0 text-xs text-muted">
                      Last drawer change: {@drawer_last}
                    </p>
                  </div>
                </div>
                <.alert_dialog
                  id="live-alert"
                  title="Confirm update"
                  confirm_label="Confirm update"
                  on_confirm="increment"
                  open={Map.get(@overlay_open, "live-alert", false)}
                  on_open_change="overlay_change"
                >
                  This will increment the counter.
                </.alert_dialog>
                <.drawer
                  id="live-drawer"
                  title="Drawer settings"
                  placement="right"
                  open={Map.get(@overlay_open, "live-drawer", false)}
                  on_open_change="overlay_change"
                  show_handle
                >
                  <p id="drawer-count">Drawer updates: {@count}</p>
                  <.button phx-click="increment">Update drawer</.button>
                </.drawer>
                <.drawer
                  id="live-drawer-controlled"
                  title="Controlled drawer"
                  show_handle
                  open={@controlled_drawer_open}
                  on_open_change="drawer_open_change"
                >
                  <p>LiveView controls whether this drawer is open.</p>
                  <:close :let={attrs}><.button variant="secondary" {attrs}>Done</.button></:close>
                </.drawer>
                <.drawer
                  id="live-drawer-blur"
                  open={Map.get(@overlay_open, "live-drawer-blur", false)}
                  on_open_change="overlay_change"
                  title="Blurred backdrop"
                  placement="left"
                  backdrop="blur"
                >
                  <p>Review the panel with a blurred backdrop.</p>
                </.drawer>
                <.drawer
                  id="live-drawer-clear"
                  open={Map.get(@overlay_open, "live-drawer-clear", false)}
                  on_open_change="overlay_change"
                  title="Transparent backdrop"
                  placement="bottom"
                  backdrop="transparent"
                >
                  <p>Review the panel with a transparent backdrop.</p>
                </.drawer>
                <div class="mt-5">
                  <p class="mb-2 text-xs font-medium text-muted">Popovers & menus</p>
                  <div class="flex flex-wrap items-center gap-2">
                    <.tooltip
                      id="preview-tip"
                      open={Map.get(@overlay_open, "preview-tip", false)}
                      on_open_change="overlay_change"
                      text="This is a helpful hint"
                      delay={0}
                    >
                      Hover or focus
                    </.tooltip>
                    <.popover
                      id="preview-popover"
                      open={Map.get(@overlay_open, "preview-popover", false)}
                      on_open_change="overlay_change"
                      trigger="Open popover"
                      title="Quick settings"
                    >
                      <p id="popover-count">Popover updates: {@count}</p>
                      <.button phx-click="increment">Update popover</.button>
                    </.popover>
                    <.popover
                      id="preview-popover-custom"
                      open={Map.get(@overlay_open, "preview-popover-custom", false)}
                      on_open_change="overlay_change"
                      title="Project details"
                      placement="top"
                      show_arrow
                      show_close={false}
                      content_class="w-64"
                    >
                      <:trigger_content :let={attrs}>
                        <.button variant="secondary" {attrs}>Project details</.button>
                      </:trigger_content>
                      <p class="m-0 text-sm text-muted">Review the project before continuing.</p>
                    </.popover>
                    <.popover
                      id="preview-popover-controlled"
                      trigger="Controlled popover"
                      title="Notifications"
                      open={@controlled_popover_open}
                      on_open_change="popover_change"
                      placement="right"
                      content_class="w-64"
                    >
                      <p class="m-0 text-sm text-muted">Open state is controlled by LiveView.</p>
                    </.popover>
                    <.dropdown
                      id="preview-actions"
                      open={Map.get(@overlay_open, "preview-actions", false)}
                      on_open_change="overlay_change"
                      label="Actions"
                    >
                      <:item label="Update count" on_click="increment" />
                      <:item label="Unavailable" disabled />
                      <:item label="Open gallery" href="/" />
                    </.dropdown>
                  </div>
                  <p id="popover-state" class="mt-2 mb-0 text-xs text-muted">
                    Last popover change: {@popover_last}
                  </p>
                </div>
              </.preview_card>
            </div>
          </section>
          <section
            id="feedback"
            class="lp-section scroll-mt-32 pt-20 pb-4 max-[620px]:pt-14"
            aria-labelledby="feedback-title"
          >
            <div class="lp-section-heading mb-6 flex items-end justify-between gap-6 max-[620px]:block [&_h2]:m-0 [&_h2]:text-[32px] [&_h2]:font-[510] [&_h2]:leading-[1.13] [&_h2]:tracking-[-.022em] [&>p]:m-0 [&>p]:text-right [&>p]:text-[13px] [&>p]:leading-5 [&>p]:text-[#62666d] dark:[&>p]:text-[#8a8f98] max-[620px]:[&>p]:mt-2 max-[620px]:[&>p]:text-left">
              <div>
                <p class="lp-kicker mb-3 mt-0 text-[10px] font-[510] tracking-[.08em] text-[#62666d] dark:text-[#8a8f98]">
                  COMPONENTS
                </p><h2 id="feedback-title">Feedback</h2>
              </div><p>Keep people informed about changes.</p>
            </div>
            <div class="lp-grid grid grid-cols-1 items-start gap-4 min-[700px]:grid-cols-2">
              <.preview_card
                title="Toast notifications"
                description="Send a notification in any of five variants."
              >
                <section aria-label="Toast preview">
                  <.toast_region
                    id="preview-toasts"
                    placement="bottom"
                    toasts={@toasts}
                    on_dismiss="dismiss_toast"
                  >
                    <:indicator name="star"><span class="text-lg text-warning">★</span></:indicator>
                  </.toast_region>
                  <div class="lp-inline flex flex-wrap items-center gap-2.5">
                    <.button
                      :for={variant <- ~w(default accent success warning danger)}
                      phx-click="show_toast"
                      phx-value-variant={variant}
                      size="sm"
                      variant="secondary"
                    >{String.capitalize(variant)} toast</.button>
                    <.button phx-click="show_toast_star" size="sm" variant="secondary">Custom indicator</.button>
                  </div>
                  <p
                    id="toast-action-state"
                    class="mt-3 mb-0 break-words text-[11px] leading-[1.55] text-zinc-500 dark:text-zinc-400"
                  >
                    Action: {@toast_action}
                  </p>
                </section>
              </.preview_card>
              <.preview_card title="Chips" description="Variants, sizes, and icons.">
                <div class="flex flex-col gap-4">
                  <div class="flex flex-wrap items-center gap-2">
                    <.chip>Default</.chip>
                    <.chip color="accent" variant="primary">New</.chip>
                    <.chip color="success" variant="soft">Published</.chip>
                    <.chip color="warning" variant="tertiary">Pending</.chip>
                  </div>
                  <div class="flex flex-wrap items-center gap-2">
                    <.chip size="sm">Small</.chip><.chip>Medium</.chip><.chip size="lg">Large</.chip>
                  </div>
                  <div class="flex flex-wrap items-center gap-2">
                    <.chip color="success" variant="soft">
                      <:prefix>
                        <span aria-hidden="true" class="size-1.5 rounded-full bg-current"></span>
                      </:prefix>
                      Online
                    </.chip>
                    <.chip color="accent" variant="soft">
                      Verified
                      <:suffix>
                        <OlisUI.Icon.icon name="check" class="size-3" />
                      </:suffix>
                    </.chip>
                  </div>
                </div>
              </.preview_card>
              <.preview_card title="Status & identity" description="Alerts, avatars, and badges.">
                <div class="lp-inline flex flex-wrap items-center gap-2.5">
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
              </.preview_card>
              <.preview_card
                title="Alerts"
                description="Status messages with optional actions and custom indicators."
                class="lp-card-wide"
              >
                <div class="grid grid-cols-1 gap-3 min-[621px]:grid-cols-2">
                  <.alert
                    :for={status <- ~w(default accent success warning danger)}
                    status={status}
                    title={"#{String.capitalize(status)} notification"}
                  >
                    <:description>Your changes are ready to review.</:description>
                  </.alert>
                  <.alert status="warning" title="Payment expires soon" role="alert">
                    <:description>Update your billing details.</:description>
                    <:actions><.button size="sm" variant="secondary">Review</.button></:actions>
                  </.alert>
                </div>
              </.preview_card>
              <.preview_card
                title="Avatar group"
                description="Stack teammates with an overflow count, or display them in a grid."
              >
                <div class="flex flex-col items-start gap-5">
                  <.avatar_group
                    role="group"
                    aria-label="Project team"
                    max={3}
                    color="accent"
                    variant="soft"
                  >
                    <:avatar name="Jane Doe" />
                    <:avatar name="Alex Kim" color="success" />
                    <:avatar name="Morgan Lee" color="warning" />
                    <:avatar name="Sam Rivera" />
                    <:avatar name="Casey Jones" />
                  </.avatar_group>
                  <.avatar_group role="group" aria-label="Reviewers" size="sm" overlap="ring">
                    <:avatar name="Jane Doe" />
                    <:avatar name="Alex Kim" />
                    <:avatar name="Morgan Lee" />
                    <:count label="9 more reviewers">+9</:count>
                  </.avatar_group>
                  <.avatar_group
                    role="group"
                    aria-label="Contributors"
                    grid
                    color="accent"
                    variant="soft"
                  >
                    <:avatar name="Jane Doe" />
                    <:avatar name="Alex Kim" color="success" />
                    <:avatar name="Morgan Lee" color="warning" />
                    <:avatar name="Sam Rivera" color="danger" />
                  </.avatar_group>
                </div>
              </.preview_card>
              <.preview_card
                title="Progress & meter"
                description="Determinate, indeterminate, and label-free indicators."
              >
                <div class="space-y-5">
                  <.progress_bar label="Uploading" value={60} />
                  <.progress_bar aria-label="Background upload" value={45} show_value={false} />
                  <.progress_bar label="Processing" indeterminate />
                  <.meter label="Capacity" value={7} max={10} value_text="7 of 10 GB" />
                  <div class="flex items-center gap-4">
                    <.progress_circle label="Updates" value={min(@count, 10)} max={10} />
                    <.progress_circle label="Loading" indeterminate color="success" />
                    <.progress_circle label="Complete" value={75} show_label />
                  </div>
                </div>
              </.preview_card>
            </div>
          </section>
          <section
            id="data"
            class="lp-section scroll-mt-32 pt-20 pb-4 max-[620px]:pt-14"
            aria-labelledby="data-title"
          >
            <div class="lp-section-heading mb-6 flex items-end justify-between gap-6 max-[620px]:block [&_h2]:m-0 [&_h2]:text-[32px] [&_h2]:font-[510] [&_h2]:leading-[1.13] [&_h2]:tracking-[-.022em] [&>p]:m-0 [&>p]:text-right [&>p]:text-[13px] [&>p]:leading-5 [&>p]:text-[#62666d] dark:[&>p]:text-[#8a8f98] max-[620px]:[&>p]:mt-2 max-[620px]:[&>p]:text-left">
              <div>
                <p class="lp-kicker mb-3 mt-0 text-[10px] font-[510] tracking-[.08em] text-[#62666d] dark:text-[#8a8f98]">
                  COMPONENTS
                </p><h2 id="data-title">Data display</h2>
              </div><p>Tables and pagination with LiveView updates.</p>
            </div>
            <div class="lp-grid grid grid-cols-1 items-start gap-4 min-[700px]:grid-cols-2">
              <.preview_card
                title="Cards"
                description="Four surface variants with composable sections."
                class="lp-card-wide"
              >
                <div class="grid grid-cols-1 gap-3 min-[621px]:grid-cols-2">
                  <.card
                    :for={variant <- ~w(default secondary tertiary transparent)}
                    id={"card-#{variant}"}
                    variant={variant}
                    role="article"
                    aria-labelledby={"card-title-#{variant}"}
                  >
                    <:title id={"card-title-#{variant}"}>{String.capitalize(variant)}</:title>
                    <:description>Project overview</:description>
                    <:content>
                      <p class="m-0 text-sm text-muted">A surface for related content.</p>
                    </:content>
                    <:footer><.button size="sm" variant="secondary">View details</.button></:footer>
                  </.card>
                </div>
              </.preview_card>
              <.preview_card
                title="Surfaces"
                description="Semantic backgrounds for grouping content."
                class="lp-card-wide"
              >
                <div class="grid grid-cols-1 gap-3 min-[621px]:grid-cols-2">
                  <.surface
                    :for={variant <- ~w(default secondary tertiary transparent)}
                    id={"surface-#{variant}"}
                    variant={variant}
                    class={[
                      "flex flex-col gap-3 rounded-3xl p-6",
                      variant == "transparent" && "border border-border"
                    ]}
                  >
                    <p class="m-0 text-sm font-medium">{String.capitalize(variant)} surface</p>
                    <p class="m-0 text-sm text-muted">A background for related content.</p>
                  </.surface>
                </div>
              </.preview_card>
              <.preview_card
                title="Typography"
                description="Semantic type, muted text, and inline code."
              >
                <div class="space-y-3">
                  <.typography type="h4">Clear hierarchy</.typography>
                  <.typography type="body-sm" color="muted">
                    Readable content with sensible defaults.
                  </.typography>
                  <.typography type="code">mix phx.server</.typography>
                  <.typography_prose>
                    <p>Prose can include <strong>emphasis</strong> and inline links.</p>
                  </.typography_prose>
                </div>
              </.preview_card>
              <.preview_card
                title="Breadcrumbs & shortcuts"
                description="A navigation trail and keyboard hints."
              >
                <div class="space-y-4">
                  <.breadcrumbs label="Example navigation">
                    <:item label="Overview" href="#overview" />
                    <:item label="Components" href="#data" />
                    <:item label="Current" />
                  </.breadcrumbs>
                  <p class="m-0 flex items-center gap-2 text-sm text-muted">
                    Shortcut example
                    <.kbd>⌘</.kbd><.kbd>K</.kbd>
                  </p>
                </div>
              </.preview_card>
              <.preview_card
                title="Labels & links"
                description="Associated labels and navigation states."
              >
                <div class="flex flex-col gap-3">
                  <.label for="primitive-email" required>Email address</.label>
                  <.input
                    id="primitive-email"
                    type="email"
                    placeholder="you@example.com"
                    required
                    full_width
                  />
                  <div class="flex flex-wrap gap-4">
                    <.ui_link href="#overview">Overview</.ui_link>
                    <.ui_link href="https://elixir-lang.org" target="_blank" rel="noopener noreferrer">Elixir
                    <.link_icon /></.ui_link>
                    <.ui_link href="#overview" disabled>Unavailable</.ui_link>
                  </div>
                </div>
              </.preview_card>
              <.preview_card
                title="Skeleton"
                description="Shimmer, pulse, and static loading placeholders."
              >
                <div class="grid gap-4 sm:grid-cols-3">
                  <div :for={animation <- ~w(shimmer pulse none)} class="space-y-3">
                    <p class="m-0 text-sm font-medium">{String.capitalize(animation)}</p>
                    <.skeleton animation_type={animation} class="h-16 w-full rounded-xl" />
                    <.skeleton animation_type={animation} class="h-3 w-4/5" />
                    <.skeleton animation_type={animation} class="h-3 w-3/5" />
                  </div>
                </div>
              </.preview_card>
              <.preview_card title="Spinners" description="Sizes and semantic colors.">
                <div class="flex flex-wrap items-center gap-4">
                  <.spinner size="sm" label="Loading small" />
                  <.spinner label="Loading medium" />
                  <.spinner size="lg" color="success" label="Loading success" />
                  <.spinner size="xl" color="danger" label="Loading danger" />
                </div>
              </.preview_card>
              <.preview_card
                title="Empty state & header"
                description="Section labels and empty results."
              >
                <.header as="h3">Projects</.header>
                <.empty_state />
                <.empty_state as="p">Try a different search.</.empty_state>
              </.preview_card>
              <.preview_card title="Scroll shadow" description="Fade edges as content scrolls.">
                <.scroll_shadow
                  id="activity-scroll"
                  class="h-44 rounded-xl border border-zinc-200 p-4 dark:border-zinc-700"
                  tabindex="0"
                  role="region"
                  aria-label="Activity feed"
                  on_visibility_change="scroll_visibility"
                >
                  <div class="space-y-3">
                    <p
                      :for={entry <- @scroll_entries}
                      class="text-sm leading-relaxed text-zinc-600 dark:text-zinc-300"
                    >
                      {entry}. A small update from your project team.
                    </p>
                  </div>
                </.scroll_shadow>
                <div class="mt-4 flex flex-wrap items-center gap-3">
                  <.button phx-click="toggle_scroll_entries" size="sm" variant="secondary">Toggle content length</.button>
                  <p id="scroll-shadow-state" class="text-xs text-zinc-500 dark:text-zinc-400">
                    Visibility: {@scroll_visibility}
                  </p>
                </div>
                <.scroll_shadow
                  id="horizontal-scroll"
                  orientation="horizontal"
                  hide_scrollbar
                  class="mt-5 w-full rounded-xl border border-zinc-200 p-3 dark:border-zinc-700"
                  tabindex="0"
                  role="region"
                  aria-label="Project categories"
                >
                  <div class="flex w-max gap-2">
                    <.chip
                      :for={label <- ["Design", "Engineering", "Research", "Product", "Marketing"]}
                      variant="soft"
                    >
                      {label}
                    </.chip>
                  </div>
                </.scroll_shadow>
              </.preview_card>
              <.preview_card
                title="Pagination"
                description="Numbered pages or compact previous and next controls."
              >
                <div class="flex flex-col gap-4">
                  <.pagination
                    page={@page}
                    total_pages={10}
                    on_change="page_changed"
                    label="Numbered pages"
                  />
                  <.pagination
                    page={@page}
                    total_pages={10}
                    on_change={Phoenix.LiveView.JS.push("page_changed")}
                    label="Compact pages"
                    show_pages={false}
                  >
                    <:summary>Page {@page} of 10</:summary>
                  </.pagination>
                </div>
              </.preview_card>
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
                    row_id={fn person -> "person-#{person.id}" end}
                    row_label={fn person -> person.name end}
                    selection_mode="multiple"
                    selected_keys={@table_selected}
                    on_selection_change="table_selection"
                    on_column_resize="table_resize"
                    sort_event="sort_people"
                    sort_by="name"
                    sort_direction={@sort_direction}
                  >
                    <:col
                      :let={person}
                      label="Name"
                      key="name"
                      sort_key="name"
                      row_header
                      resizable
                      width={@table_widths["name"]}
                      min_width={100}
                      max_width={400}
                    >
                      {person.name}
                    </:col>
                    <:col
                      :let={person}
                      label="Role"
                      key="role"
                      resizable
                      width={@table_widths["role"]}
                      min_width={100}
                      max_width={400}
                    >
                      {person.role}
                    </:col>
                    <:footer>
                      <.pagination
                        class="max-w-full overflow-x-auto"
                        page={@page}
                        total_pages={10}
                        on_change="page_changed"
                      >
                        <:summary>Page {@page} of 10</:summary>
                      </.pagination>
                    </:footer>
                  </.data_table>
                  <p id="table-selection-state" class="mt-2 text-xs text-muted">
                    Selected: {Enum.join(@table_selected, ", ")}
                  </p>
                  <p id="table-resize-state" class="mt-2 text-xs text-muted">
                    Last resized column: {@table_resize}
                  </p>
                  <h2>Streamed table</h2>
                  <.data_table
                    id="stream-table"
                    label="Streamed people"
                    selected_keys={@stream_selected}
                    on_selection_change="stream_selection"
                    rows={@streams.people}
                    selection_mode="multiple"
                    row_label={fn person -> person.name end}
                    on_load_more="load_more_people"
                    has_more={@stream_has_more}
                  >
                    <:col :let={person} label="Name">{person.name}</:col>
                    <:col :let={person} label="Role">{person.role}</:col>
                    <:empty>No people yet. Add someone to get started.</:empty>
                  </.data_table>
                  <div class="mt-3 flex gap-2">
                    <.button phx-click="add_person">Add person</.button>
                    <.button phx-click="clear_people" variant="secondary">Clear people</.button>
                  </div>
                </section>
              </.preview_card>
            </div>
          </section>
          <footer class="lp-footer mt-20 flex justify-between gap-4 border-t border-[#e5e7eb] py-10 text-xs text-[#62666d] dark:border-[#23252a] dark:text-[#8a8f98] [&>span]:font-[510] [&>span]:text-[#111315] dark:[&>span]:text-white [&>span_span]:font-normal [&>span_span]:text-[#8a8f98] [&>a]:text-[#62666d] [&>a]:no-underline dark:[&>a]:text-[#8a8f98]">
            <span>OlisUI <span>for LiveView</span></span><a href="#overview">Back to top ↑</a>
          </footer>
          <.modal
            id="live-modal"
            title="Live update"
            open={Map.get(@overlay_open, "live-modal", false)}
            on_open_change="overlay_change"
          >
            <p id="count">Server updates: {@count}</p>
            <.button phx-click="increment">Update content</.button>
          </.modal>
          <.modal
            id="live-modal-controlled"
            title="Controlled modal"
            description="LiveView controls this dialog."
            open={@controlled_modal_open}
            on_open_change="modal_open_change"
            backdrop="blur"
            placement="center"
          >
            <p>Choose how you want to continue.</p>
            <:close :let={attrs}><.button variant="secondary" {attrs}>Done</.button></:close>
          </.modal>
          <.modal
            id="live-modal-bottom"
            open={Map.get(@overlay_open, "live-modal-bottom", false)}
            on_open_change="overlay_change"
            title="Bottom modal"
            placement="bottom"
            backdrop="transparent"
          >
            <p>A dialog positioned at the bottom of the viewport.</p>
          </.modal>
        </main>
      </div>
    </div>
    """
  end
end

defmodule OlisUI.Preview.WebRouter do
  @moduledoc false
  use Phoenix.Router
  import Phoenix.LiveView.Router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, html: {OlisUI.Preview.Layout, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  scope "/" do
    pipe_through(:browser)
    live("/live-preview", OlisUI.Preview.Live)
  end

  forward("/", OlisUI.Preview.Router)
end

defmodule OlisUI.Preview.Endpoint do
  use Phoenix.Endpoint, otp_app: :olis_ui
  @session_options [store: :cookie, key: "_olis_preview", signing_salt: "previewsession"]
  socket("/live", Phoenix.LiveView.Socket,
    websocket: [connect_info: [session: @session_options]],
    longpoll: false
  )

  plug(Plug.Session, @session_options)
  plug(OlisUI.Preview.WebRouter)
end
