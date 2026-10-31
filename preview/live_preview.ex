defmodule HeroUI.Preview.Layout do
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
        <link rel="stylesheet" href="/hero_ui.css" />
        <script>
          try { document.documentElement.dataset.theme = localStorage.getItem("preview-theme") || "light"; } catch (_) {}
        </script>
        <script type="module">
          import {Socket} from "/phoenix.mjs";
          import {LiveSocket} from "/phoenix_live_view.esm.js";
          import {installHeroUI} from "/hero_ui.js?v=dropdown";
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
      <body class="lp-body m-0 bg-[#f8f9fb] text-zinc-900 dark:bg-[#101114] dark:text-zinc-100 font-sans text-sm">
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
        close_button_count: 0,
        terms: false,
        alerts: false,
        switch_news: true,
        switch_marketing: false,
        switch_updates: true,
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
        underline: false,
        disclosure_expanded: ["account"],
        disclosure_last: "none",
        controlled_sheet_open: false,
        sheet_last: "none",
        toolbar_action: "none",
        dropdown_sort: "newest",
        dropdown_columns: ["name", "status"],
        dropdown_last: "none",
        fieldset_saved: nil,
        workspace: ["alpha"],
        required_choice: nil,
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
        toast_action: "none",
        booking_date: "2026-10-15",
        submitted_booking: nil,
        booking_changes: 0,
        meeting_time: "09:30",
        meeting_submitted: nil,
        meeting_changes: 0,
        scroll_visibility: "waiting",
        scroll_entries: Enum.to_list(1..8),
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

  def handle_event("toggle_format", %{"format" => "underline"}, socket),
    do: {:noreply, update(socket, :underline, &(!&1))}

  def handle_event("disclosure_toggle", %{"key" => key, "expanded" => expanded}, socket)
      when key in ~w(account billing security) do
    keys = if expanded == "true", do: [key], else: []
    {:noreply, assign(socket, disclosure_expanded: keys, disclosure_last: "#{key}: #{expanded}")}
  end

  def handle_event("open_billing", _, socket),
    do:
      {:noreply,
       assign(socket, disclosure_expanded: ["billing"], disclosure_last: "billing: true")}

  def handle_event("sheet_open_change", %{"open" => open, "reason" => reason}, socket),
    do:
      {:noreply,
       assign(socket, controlled_sheet_open: open == "true", sheet_last: "#{open}: #{reason}")}

  def handle_event("toolbar_action", %{"action" => action}, socket)
      when action in ~w(Copy Cut Undo Redo),
      do: {:noreply, assign(socket, :toolbar_action, action)}

  def handle_event("dropdown_sort", %{"key" => key}, socket),
    do: {:noreply, assign(socket, :dropdown_sort, key)}

  def handle_event("fieldset_save", %{"profile" => %{"name" => name}}, socket),
    do: {:noreply, assign(socket, :fieldset_saved, name)}

  def handle_event("dropdown_columns", %{"key" => key, "selected" => selected}, socket) do
    values = Enum.reject(socket.assigns.dropdown_columns, &(&1 == key))

    {:noreply,
     assign(socket, :dropdown_columns, if(selected == "true", do: values ++ [key], else: values))}
  end

  def handle_event("dropdown_action", %{"key" => key}, socket),
    do: {:noreply, assign(socket, :dropdown_last, key)}

  def handle_event("required_submit", %{"choice" => value}, socket),
    do: {:noreply, assign(socket, :required_choice, value)}

  def handle_event("search", %{"query" => value}, socket),
    do: {:noreply, assign(socket, :search_query, value)}

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

  def handle_event("meeting_change", %{"meeting_time" => value}, socket),
    do: {:noreply, socket |> assign(:meeting_time, value) |> update(:meeting_changes, &(&1 + 1))}

  def handle_event("scroll_visibility", %{"visibility" => visibility}, socket),
    do: {:noreply, assign(socket, :scroll_visibility, visibility)}

  def handle_event("toggle_scroll_entries", _, socket) do
    entries = if length(socket.assigns.scroll_entries) > 2, do: [1, 2], else: Enum.to_list(1..8)
    {:noreply, assign(socket, :scroll_entries, entries)}
  end

  def handle_event("meeting_submit", %{"meeting_time" => value}, socket),
    do: {:noreply, assign(socket, :meeting_submitted, value)}

  def handle_event("set_meeting", _, socket),
    do: {:noreply, assign(socket, :meeting_time, "14:45")}

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

  def handle_event("close_button_clicked", _, socket),
    do: {:noreply, update(socket, :close_button_count, &(&1 + 1))}

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

  attr(:name, :string, required: true)

  defp toolbar_icon(assigns) do
    paths = %{
      "bold" =>
        "M4.25 2.25A.75.75 0 0 0 3.5 3v10c0 .414.336.75.75.75H9.5a3.25 3.25 0 0 0 1.477-6.146A3.25 3.25 0 0 0 8.5 2.25zm3.5 5a1.75 1.75 0 1 0 0-3.5h-2v3.5zm-2 1.5v3.5h3a1.75 1.75 0 1 0 0-3.5z",
      "italic" =>
        "M7.25 2a.75.75 0 0 0 0 1.5h1.317l-2.7 9H4.25a.75.75 0 1 0 0 1.5h4.5a.75.75 0 0 0 0-1.5H7.433l2.7-9h1.617a.75.75 0 0 0 0-1.5z",
      "underline" =>
        "M5 2.75a.75.75 0 0 0-1.5 0V7a4.5 4.5 0 0 0 9 0V2.75a.75.75 0 0 0-1.5 0V7a3 3 0 0 1-6 0zm-.75 9.75a.75.75 0 0 0 0 1.5h7.5a.75.75 0 0 0 0-1.5z",
      "copy" =>
        "M12 2.5H8A1.5 1.5 0 0 0 6.5 4v1H8a3 3 0 0 1 3 3v1.5h1A1.5 1.5 0 0 0 13.5 8V4A1.5 1.5 0 0 0 12 2.5M11 11h1a3 3 0 0 0 3-3V4a3 3 0 0 0-3-3H8a3 3 0 0 0-3 3v1H4a3 3 0 0 0-3 3v4a3 3 0 0 0 3 3h4a3 3 0 0 0 3-3zM4 6.5h4A1.5 1.5 0 0 1 9.5 8v4A1.5 1.5 0 0 1 8 13.5H4A1.5 1.5 0 0 1 2.5 12V8A1.5 1.5 0 0 1 4 6.5",
      "cut" =>
        "M4.5 6a1.5 1.5 0 1 0 0-3 1.5 1.5 0 0 0 0 3m-3-1.5a3 3 0 0 0 4.524 2.585L6.939 8l-.915.915a3 3 0 1 0 1.06 1.06L8.122 8.94l5.501 3.209a.75.75 0 1 0 .756-1.296L9.488 8l4.89-2.852a.75.75 0 0 0-.756-1.296l-5.5 3.209-1.037-1.037A3 3 0 1 0 1.5 4.5m3 5.5a1.5 1.5 0 1 1 0 3 1.5 1.5 0 0 1 0-3",
      "undo" =>
        "M2.47 4.72a.75.75 0 0 0 0 1.06l3 3a.75.75 0 0 0 1.06-1.06L4.81 6H9a3.25 3.25 0 0 1 0 6.5H8A.75.75 0 0 0 8 14h1a4.75 4.75 0 1 0 0-9.5H4.81l1.72-1.72a.75.75 0 0 0-1.06-1.06z",
      "redo" =>
        "M13.53 4.72a.75.75 0 0 1 0 1.06l-3 3a.75.75 0 1 1-1.06-1.06L11.19 6H7a3.25 3.25 0 0 0 0 6.5h1A.75.75 0 0 1 8 14H7a4.75 4.75 0 1 1 0-9.5h4.19L9.47 2.78a.75.75 0 0 1 1.06-1.06z"
    }

    assigns = assign(assigns, :path, Map.fetch!(paths, assigns.name))

    ~H"""
    <svg width="16" height="16" viewBox="0 0 16 16" fill="none" aria-hidden="true"><path
      d={@path}
      fill="currentColor"
      fill-rule="evenodd"
      clip-rule="evenodd"
    /></svg>
    """
  end

  attr(:title, :string, required: true)
  attr(:description, :string, default: nil)
  attr(:class, :string, default: nil)
  slot(:inner_block, required: true)

  defp preview_card(assigns) do
    ~H"""
    <article class={[
      "lp-card min-w-0 overflow-visible rounded-2xl border border-[#e8e8ed] bg-white dark:border-[#303138] dark:bg-[#18191d]",
      @class == "lp-card-wide" && "min-[621px]:col-span-2",
      @class
    ]}>
      <header class="lp-card-header min-h-[76px] border-b border-[#e8e8ed] px-5 pt-[18px] pb-[15px] dark:border-[#303138] [&_h3]:m-0 [&_h3]:text-sm [&_h3]:font-bold [&_h3]:tracking-[-.015em] [&_p]:mb-0 [&_p]:mt-1.5 [&_p]:text-[11px] [&_p]:leading-normal [&_p]:text-zinc-500 dark:[&_p]:text-zinc-400">
        <h3>{@title}</h3>
        <p :if={@description}>{@description}</p>
      </header>
      <div class="lp-demo min-w-0 px-5 py-[22px] max-[620px]:px-4 max-[620px]:py-5 [&>form]:max-w-full [&>div]:max-w-full [&>fieldset]:max-w-full [&_form>button]:mt-3 [&_form>button]:mr-[5px] [&_form+form]:mt-[22px] [&_form+div]:mt-[22px] [&_fieldset+div]:mt-[22px] [&_section>h2]:mb-[14px] [&_section>h2]:text-sm [&_section>h2]:font-bold [&_section>h2:not(:first-child)]:mt-[26px] [&_section>button]:mt-4 [&>button]:mr-1.5 [&>button]:mb-2.5">
        {render_slot(@inner_block)}
      </div>
    </article>
    """
  end

  def render(assigns) do
    ~H"""
    <div class="lp-app min-h-screen">
      <header class="lp-topbar sticky top-0 z-20 flex h-[72px] items-center justify-between border-b border-[#e8e8ed] bg-white px-[4%] dark:border-[#303138] dark:bg-[#18191d] max-[620px]:h-16 max-[620px]:px-4">
        <a
          href="/"
          class="lp-brand inline-flex items-center gap-2.5 whitespace-nowrap text-[15px] font-[750] tracking-[-.035em] text-zinc-900 no-underline dark:text-zinc-100 [&>span:last-child>span]:font-[450] [&>span:last-child>span]:tracking-[-.01em] [&>span:last-child>span]:text-zinc-500 dark:[&>span:last-child>span]:text-zinc-400"
          aria-label="HeroUI for LiveView home"
        ><span class="lp-brand-mark grid size-[31px] place-items-center rounded-[10px] bg-zinc-900 text-[19px] leading-none text-white dark:bg-zinc-100 dark:text-[#18191d]">✦</span><span>HeroUI
        <span>for LiveView</span></span></a>
        <div class="lp-top-actions flex items-center gap-[22px]">
          <span class="lp-live inline-flex items-center gap-[7px] whitespace-nowrap text-xs text-zinc-500 dark:text-zinc-400 max-[620px]:hidden [&>span]:inline-block [&>span]:size-[7px] [&>span]:rounded-full [&>span]:bg-[#17c964]"><span></span>
          Live playground</span><button
            type="button"
            class="lp-theme size-[34px] cursor-pointer rounded-full border border-[#e8e8ed] bg-white text-[17px] text-zinc-900 hover:bg-[#f3f4f6] dark:border-[#303138] dark:bg-[#18191d] dark:text-zinc-100 dark:hover:bg-[#22242a]"
            data-preview-theme
            aria-label="Toggle light and dark theme"
            title="Toggle theme"
          >◐</button><a
            class="lp-top-link whitespace-nowrap text-xs font-[650] text-zinc-900 no-underline dark:text-zinc-100 max-[620px]:hidden [&>span]:ml-[5px] [&>span]:text-zinc-500 dark:[&>span]:text-zinc-400"
            href="/"
          >Component gallery <span aria-hidden="true">↗</span></a>
        </div>
      </header>
      <div class="lp-layout mx-auto grid max-w-[1600px] grid-cols-[220px_minmax(0,1fr)] items-start max-[850px]:block">
        <aside
          class="lp-sidebar sticky top-[72px] h-[calc(100vh-72px)] overflow-auto border-r border-[#e8e8ed] pt-[42px] pr-5 pb-7 pl-7 dark:border-[#303138] max-[850px]:z-[19] max-[850px]:flex max-[850px]:h-auto max-[850px]:items-center max-[850px]:gap-3 max-[850px]:overflow-x-auto max-[850px]:border-r-0 max-[850px]:border-b max-[850px]:bg-white max-[850px]:px-5 max-[850px]:py-2.5 dark:max-[850px]:bg-[#18191d] max-[620px]:top-16 max-[620px]:px-3 max-[620px]:py-2"
          aria-label="Preview navigation"
        >
          <p class="lp-nav-label mx-2.5 mb-3 mt-0 text-[10px] font-[750] tracking-[.1em] text-zinc-500 dark:text-zinc-400 max-[850px]:hidden">
            EXPLORE
          </p>
          <a
            class="lp-nav-intro is-active flex items-center justify-between gap-2.5 rounded-[9px] p-2.5 text-xs font-[550] text-zinc-500 no-underline aria-[current=location]:bg-[#eaf3ff] aria-[current=location]:font-bold aria-[current=location]:text-[#006fee] dark:text-zinc-400 dark:aria-[current=location]:bg-[#162b45] dark:aria-[current=location]:text-[#70b2ff] max-[850px]:shrink-0"
            href="#overview"
            aria-current="location"
          ><span>Overview</span><span aria-hidden="true">↗</span></a>
          <p class="lp-nav-label lp-nav-spaced mx-2.5 mb-3 mt-[34px] text-[10px] font-[750] tracking-[.1em] text-zinc-500 dark:text-zinc-400 max-[850px]:hidden">
            COMPONENTS
          </p>
          <nav class="lp-nav max-[850px]:flex max-[850px]:gap-1">
            <a
              class="flex items-center justify-between gap-2.5 rounded-[9px] p-2.5 text-xs font-[550] text-zinc-500 no-underline hover:bg-[#f3f4f6] hover:text-zinc-900 aria-[current=location]:bg-[#eaf3ff] aria-[current=location]:font-bold aria-[current=location]:text-[#006fee] dark:text-zinc-400 dark:hover:bg-[#22242a] dark:hover:text-zinc-100 dark:aria-[current=location]:bg-[#162b45] dark:aria-[current=location]:text-[#70b2ff] max-[850px]:whitespace-nowrap [&>span]:text-[10px] [&>span]:font-normal [&>span]:text-zinc-500 dark:[&>span]:text-zinc-400 max-[850px]:[&>span]:hidden"
              href="#forms"
            >Forms <span>01</span></a><a
              class="flex items-center justify-between gap-2.5 rounded-[9px] p-2.5 text-xs font-[550] text-zinc-500 no-underline hover:bg-[#f3f4f6] hover:text-zinc-900 aria-[current=location]:bg-[#eaf3ff] aria-[current=location]:font-bold aria-[current=location]:text-[#006fee] dark:text-zinc-400 dark:hover:bg-[#22242a] dark:hover:text-zinc-100 dark:aria-[current=location]:bg-[#162b45] dark:aria-[current=location]:text-[#70b2ff] max-[850px]:whitespace-nowrap [&>span]:text-[10px] [&>span]:font-normal [&>span]:text-zinc-500 dark:[&>span]:text-zinc-400 max-[850px]:[&>span]:hidden"
              href="#colors"
            >Colors <span>02</span></a><a
              class="flex items-center justify-between gap-2.5 rounded-[9px] p-2.5 text-xs font-[550] text-zinc-500 no-underline hover:bg-[#f3f4f6] hover:text-zinc-900 aria-[current=location]:bg-[#eaf3ff] aria-[current=location]:font-bold aria-[current=location]:text-[#006fee] dark:text-zinc-400 dark:hover:bg-[#22242a] dark:hover:text-zinc-100 dark:aria-[current=location]:bg-[#162b45] dark:aria-[current=location]:text-[#70b2ff] max-[850px]:whitespace-nowrap [&>span]:text-[10px] [&>span]:font-normal [&>span]:text-zinc-500 dark:[&>span]:text-zinc-400 max-[850px]:[&>span]:hidden"
              href="#dates"
            >Dates &amp; calendars <span>03</span></a><a
              class="flex items-center justify-between gap-2.5 rounded-[9px] p-2.5 text-xs font-[550] text-zinc-500 no-underline hover:bg-[#f3f4f6] hover:text-zinc-900 aria-[current=location]:bg-[#eaf3ff] aria-[current=location]:font-bold aria-[current=location]:text-[#006fee] dark:text-zinc-400 dark:hover:bg-[#22242a] dark:hover:text-zinc-100 dark:aria-[current=location]:bg-[#162b45] dark:aria-[current=location]:text-[#70b2ff] max-[850px]:whitespace-nowrap [&>span]:text-[10px] [&>span]:font-normal [&>span]:text-zinc-500 dark:[&>span]:text-zinc-400 max-[850px]:[&>span]:hidden"
              href="#selection"
            >Selection &amp; navigation <span>04</span></a><a
              class="flex items-center justify-between gap-2.5 rounded-[9px] p-2.5 text-xs font-[550] text-zinc-500 no-underline hover:bg-[#f3f4f6] hover:text-zinc-900 aria-[current=location]:bg-[#eaf3ff] aria-[current=location]:font-bold aria-[current=location]:text-[#006fee] dark:text-zinc-400 dark:hover:bg-[#22242a] dark:hover:text-zinc-100 dark:aria-[current=location]:bg-[#162b45] dark:aria-[current=location]:text-[#70b2ff] max-[850px]:whitespace-nowrap [&>span]:text-[10px] [&>span]:font-normal [&>span]:text-zinc-500 dark:[&>span]:text-zinc-400 max-[850px]:[&>span]:hidden"
              href="#overlays"
            >Overlays <span>05</span></a><a
              class="flex items-center justify-between gap-2.5 rounded-[9px] p-2.5 text-xs font-[550] text-zinc-500 no-underline hover:bg-[#f3f4f6] hover:text-zinc-900 aria-[current=location]:bg-[#eaf3ff] aria-[current=location]:font-bold aria-[current=location]:text-[#006fee] dark:text-zinc-400 dark:hover:bg-[#22242a] dark:hover:text-zinc-100 dark:aria-[current=location]:bg-[#162b45] dark:aria-[current=location]:text-[#70b2ff] max-[850px]:whitespace-nowrap [&>span]:text-[10px] [&>span]:font-normal [&>span]:text-zinc-500 dark:[&>span]:text-zinc-400 max-[850px]:[&>span]:hidden"
              href="#feedback"
            >Feedback <span>06</span></a><a
              class="flex items-center justify-between gap-2.5 rounded-[9px] p-2.5 text-xs font-[550] text-zinc-500 no-underline hover:bg-[#f3f4f6] hover:text-zinc-900 aria-[current=location]:bg-[#eaf3ff] aria-[current=location]:font-bold aria-[current=location]:text-[#006fee] dark:text-zinc-400 dark:hover:bg-[#22242a] dark:hover:text-zinc-100 dark:aria-[current=location]:bg-[#162b45] dark:aria-[current=location]:text-[#70b2ff] max-[850px]:whitespace-nowrap [&>span]:text-[10px] [&>span]:font-normal [&>span]:text-zinc-500 dark:[&>span]:text-zinc-400 max-[850px]:[&>span]:hidden"
              href="#data"
            >Data display <span>07</span></a>
          </nav>
          <div class="lp-sidebar-note mt-12 rounded-[14px] bg-[#f3f4f6] p-4 dark:bg-[#22242a] max-[850px]:hidden [&_strong]:text-xs [&_p]:mb-0 [&_p]:mt-1.5 [&_p]:text-[11px] [&_p]:leading-[1.6] [&_p]:text-zinc-500 dark:[&_p]:text-zinc-400">
            <span class="lp-note-icon mb-3 block text-[21px] text-[#006fee] dark:text-[#70b2ff]">✳&#xFE0E;</span><strong>Made for LiveView</strong><p>
              Try the examples. Changes are handled by a connected Phoenix LiveView.
            </p>
          </div>
        </aside>
        <main class="lp-main min-w-0 px-[clamp(24px,4.5vw,72px)] max-[850px]:px-6 max-[620px]:px-4">
          <div
            id="overview"
            class="lp-intro grid scroll-mt-[92px] grid-cols-[minmax(0,1fr)_minmax(250px,330px)] items-center gap-12 border-b border-[#e8e8ed] py-[70px] dark:border-[#303138] max-[850px]:scroll-mt-[145px] max-[850px]:gap-[30px] max-[850px]:py-[54px] max-[620px]:block max-[620px]:py-12"
          >
            <div class="lp-intro-copy [&>h1]:m-0 [&>h1]:text-[clamp(42px,5.4vw,68px)] [&>h1]:font-[720] [&>h1]:leading-[1.06] [&>h1]:tracking-[-.06em] max-[620px]:[&>h1]:text-[46px] [&>h1>span]:text-zinc-500 dark:[&>h1>span]:text-zinc-400 [&>p:not(.lp-eyebrow)]:mb-0 [&>p:not(.lp-eyebrow)]:mt-5 [&>p:not(.lp-eyebrow)]:max-w-[420px] [&>p:not(.lp-eyebrow)]:text-sm [&>p:not(.lp-eyebrow)]:leading-[1.7] [&>p:not(.lp-eyebrow)]:text-zinc-500 dark:[&>p:not(.lp-eyebrow)]:text-zinc-400">
              <p class="lp-eyebrow mb-6 mt-0 flex items-center gap-2 text-[10px] font-[750] tracking-[.12em] text-zinc-500 dark:text-zinc-400 [&>span]:inline-block [&>span]:size-[7px] [&>span]:rounded-full [&>span]:bg-[#17c964]">
                <span></span> THE LIVEVIEW PLAYGROUND
              </p><h1>
                Components,<br /><span>in motion.</span>
              </h1><p>
                Explore the building blocks, try their states, and see how they respond to real LiveView updates.
              </p><div class="lp-intro-actions mt-7 flex flex-wrap items-center gap-[22px]">
                <a
                  href="#forms"
                  class="lp-primary-link inline-flex items-center gap-[25px] rounded-[10px] bg-zinc-900 px-[14px] py-3 text-xs font-bold text-white no-underline dark:bg-zinc-100 dark:text-[#18191d]"
                >Explore components <span aria-hidden="true">↘</span></a><a
                  href="/"
                  class="lp-secondary-link text-xs font-bold text-zinc-900 no-underline dark:text-zinc-100 [&>span]:ml-[5px] [&>span]:text-zinc-500 dark:[&>span]:text-zinc-400"
                >View the gallery <span aria-hidden="true">↗</span></a>
              </div>
            </div>
            <div
              class="lp-intro-panel rotate-2 rounded-[20px] border border-[#e8e8ed] bg-white p-[18px] shadow-[0_16px_44px_rgba(24,24,27,0.05)] dark:border-[#303138] dark:bg-[#18191d] max-[620px]:hidden"
              aria-hidden="true"
            >
              <div class="lp-intro-panel-top flex items-center justify-between text-[9px] font-bold tracking-[.09em] text-zinc-500 dark:text-zinc-400 [&>span:last-child]:text-lg [&>span:last-child]:text-[#006fee] dark:[&>span:last-child]:text-[#70b2ff]">
                <span>COMPONENT PREVIEW</span><span>✳&#xFE0E;</span>
              </div><div class="lp-intro-sample my-[15px] flex items-center gap-3 rounded-[13px] border border-[#e8e8ed] px-3 py-5 dark:border-[#303138] [&_strong]:block [&_strong]:text-xs [&_small]:mt-1 [&_small]:block [&_small]:text-[10px] [&_small]:text-zinc-500 dark:[&_small]:text-zinc-400">
                <div class="lp-sample-icon grid size-[38px] shrink-0 place-items-center rounded-xl bg-[#eaf3ff] text-xl text-[#006fee] dark:bg-[#162b45] dark:text-[#70b2ff]">
                  ✦
                </div><div>
                  <strong>Ready to build</strong><small>Thoughtful components, connected.</small>
                </div><span class="lp-sample-check ml-auto font-bold text-[#17c964]">✓</span>
              </div><div class="lp-intro-meta flex items-center justify-between text-[9px] font-[550] text-zinc-500 dark:text-zinc-400 [&>span:first-child]:flex [&>span:first-child]:items-center [&>span:first-child]:gap-1.5 [&_i]:inline-block [&_i]:size-[7px] [&_i]:rounded-full [&_i]:bg-[#17c964]">
                <span><i></i> LiveView ready</span><span>01 — 07</span>
              </div>
            </div>
          </div>
          <section
            id="forms"
            class="lp-section scroll-mt-20 pt-[62px] pb-3 max-[850px]:scroll-mt-[145px] max-[620px]:pt-12"
            aria-labelledby="forms-title"
          >
            <div class="lp-section-heading mb-[22px] flex items-end justify-between gap-6 max-[620px]:block [&_h2]:m-0 [&_h2]:text-[27px] [&_h2]:font-bold [&_h2]:leading-[1.15] [&_h2]:tracking-[-.04em] [&>p]:mb-0.5 [&>p]:mt-0 [&>p]:text-right [&>p]:text-xs [&>p]:leading-normal [&>p]:text-zinc-500 dark:[&>p]:text-zinc-400 max-[620px]:[&>p]:mt-2.5 max-[620px]:[&>p]:text-left">
              <div>
                <p class="lp-kicker mb-[9px] mt-0 text-[10px] font-[750] tracking-[.1em] text-zinc-500 dark:text-zinc-400">
                  COMPONENTS
                </p><h2 id="forms-title">Forms</h2>
              </div><p>Inputs, validation, and searchable choices.</p>
            </div>
            <div class="lp-grid grid grid-cols-1 items-start gap-4 min-[621px]:grid-cols-2 min-[1201px]:grid-cols-3">
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
                    rows="3"
                    value={@feedback}
                    full_width
                  >
                    <:prefix>✎</:prefix>
                    <:suffix>
                      <.button phx-click="increment" size="sm" variant="ghost">Update</.button>
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
            class="lp-section scroll-mt-20 pt-[62px] pb-3 max-[850px]:scroll-mt-[145px] max-[620px]:pt-12"
            aria-labelledby="colors-title"
          >
            <div class="lp-section-heading mb-[22px] flex items-end justify-between gap-6 max-[620px]:block [&_h2]:m-0 [&_h2]:text-[27px] [&_h2]:font-bold [&_h2]:leading-[1.15] [&_h2]:tracking-[-.04em] [&>p]:mb-0.5 [&>p]:mt-0 [&>p]:text-right [&>p]:text-xs [&>p]:leading-normal [&>p]:text-zinc-500 dark:[&>p]:text-zinc-400 max-[620px]:[&>p]:mt-2.5 max-[620px]:[&>p]:text-left">
              <div>
                <p class="lp-kicker mb-[9px] mt-0 text-[10px] font-[750] tracking-[.1em] text-zinc-500 dark:text-zinc-400">
                  COMPONENTS
                </p><h2 id="colors-title">Colors</h2>
              </div>
              <p>Preview and select colors with accessible controls.</p>
            </div>
            <div class="lp-grid lp-grid--colors grid grid-cols-1 items-start gap-4 min-[621px]:grid-cols-2 min-[621px]:[&>.lp-card-wide]:col-span-1">
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
            id="dates"
            class="lp-section scroll-mt-20 pt-[62px] pb-3 max-[850px]:scroll-mt-[145px] max-[620px]:pt-12"
            aria-labelledby="dates-title"
          >
            <div class="lp-section-heading mb-[22px] flex items-end justify-between gap-6 max-[620px]:block [&_h2]:m-0 [&_h2]:text-[27px] [&_h2]:font-bold [&_h2]:leading-[1.15] [&_h2]:tracking-[-.04em] [&>p]:mb-0.5 [&>p]:mt-0 [&>p]:text-right [&>p]:text-xs [&>p]:leading-normal [&>p]:text-zinc-500 dark:[&>p]:text-zinc-400 max-[620px]:[&>p]:mt-2.5 max-[620px]:[&>p]:text-left">
              <div>
                <p class="lp-kicker mb-[9px] mt-0 text-[10px] font-[750] tracking-[.1em] text-zinc-500 dark:text-zinc-400">
                  COMPONENTS
                </p><h2 id="dates-title">Dates &amp; calendars</h2>
              </div><p>Date input and selection, connected to LiveView.</p>
            </div>
            <div class="lp-grid grid grid-cols-1 items-start gap-4 min-[621px]:grid-cols-2 min-[1201px]:grid-cols-3">
              <.preview_card
                title="Time fields"
                description="Enter a time with keyboard-friendly segments."
              >
                <form id="time-field-preview" phx-change="meeting_change" phx-submit="meeting_submit">
                  <.time_field
                    id="meeting-time"
                    name="meeting_time"
                    label="Meeting time"
                    value={@meeting_time}
                    min="09:00"
                    max="17:00"
                    description="Choose a time between 9 AM and 5 PM."
                    required
                    full_width
                  />
                  <.button type="submit" size="sm">Submit time</.button>
                  <.button phx-click="set_meeting" size="sm" variant="secondary">Set 2:45 PM</.button>
                  <p
                    id="meeting-state"
                    class="mt-3 mb-0 break-words text-[11px] leading-[1.55] text-zinc-500 dark:text-zinc-400"
                  >
                    Time: {@meeting_time}; Submitted: {@meeting_submitted || "none"}; Changes: {@meeting_changes}
                  </p>
                </form>
                <div class="mt-5 flex flex-col gap-4">
                  <.time_field
                    id="time-24"
                    label="24-hour time with seconds"
                    value="23:15:30"
                    hour_cycle={24}
                    granularity="second"
                  />
                  <.time_field id="time-disabled" label="Unavailable" value="10:00" disabled />
                  <.time_field id="time-readonly" label="Read only" value="12:15" read_only />
                </div>
              </.preview_card>
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
                  <p
                    id="booking-state"
                    class="mt-3 mb-0 break-words text-[11px] leading-[1.55] text-zinc-500 dark:text-zinc-400"
                  >
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
                  <p
                    id="birth-state"
                    class="mt-3 mb-0 break-words text-[11px] leading-[1.55] text-zinc-500 dark:text-zinc-400"
                  >
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
                  <p
                    id="appointment-state"
                    class="mt-3 mb-0 break-words text-[11px] leading-[1.55] text-zinc-500 dark:text-zinc-400"
                  >
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
                  <p
                    id="stay-state"
                    class="mt-3 mb-0 break-words text-[11px] leading-[1.55] text-zinc-500 dark:text-zinc-400"
                  >
                    Start: {@stay_start}; End: {@stay_end}; Submitted: {@submitted_stay || "none"}
                  </p>
                </form>
              </.preview_card>
              <.preview_card
                title="Calendar states"
                description="Year navigation, read-only, and disabled states."
                class="lp-card-wide"
              >
                <div class="lp-calendar-examples flex flex-wrap gap-7 max-[620px]:gap-6 [&>*]:shrink-0">
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
          <section
            id="selection"
            class="lp-section scroll-mt-20 pt-[62px] pb-3 max-[850px]:scroll-mt-[145px] max-[620px]:pt-12"
            aria-labelledby="selection-title"
          >
            <div class="lp-section-heading mb-[22px] flex items-end justify-between gap-6 max-[620px]:block [&_h2]:m-0 [&_h2]:text-[27px] [&_h2]:font-bold [&_h2]:leading-[1.15] [&_h2]:tracking-[-.04em] [&>p]:mb-0.5 [&>p]:mt-0 [&>p]:text-right [&>p]:text-xs [&>p]:leading-normal [&>p]:text-zinc-500 dark:[&>p]:text-zinc-400 max-[620px]:[&>p]:mt-2.5 max-[620px]:[&>p]:text-left">
              <div>
                <p class="lp-kicker mb-[9px] mt-0 text-[10px] font-[750] tracking-[.1em] text-zinc-500 dark:text-zinc-400">
                  COMPONENTS
                </p><h2 id="selection-title">
                  Selection &amp; navigation
                </h2>
              </div><p>Choices, navigation, and grouped actions.</p>
            </div>
            <div class="lp-grid grid grid-cols-1 items-start gap-4 min-[621px]:grid-cols-2 min-[1201px]:grid-cols-3">
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
              <.preview_card title="Close button" description="Default, disabled, and custom icons.">
                <div class="flex items-center gap-4">
                  <.close_button label="Dismiss example" phx-click="close_button_clicked" />
                  <.close_button label="Disabled close" disabled />
                  <.close_button label="Dismiss with custom icon" phx-click="close_button_clicked">
                    <svg aria-hidden="true" viewBox="0 0 16 16" fill="none"><circle
                      cx="8"
                      cy="8"
                      r="6"
                      stroke="currentColor"
                      stroke-width="1.5"
                    /><path
                      d="m5.5 5.5 5 5m0-5-5 5"
                      stroke="currentColor"
                      stroke-width="1.5"
                      stroke-linecap="round"
                    /></svg>
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
                  class="lp-settings flex flex-col gap-[14px]"
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
                  selected={@selected_tags}
                  on_select="select_tag"
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
                    on_select="select_workspace"
                    selected={@workspace}
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
                        ><.toolbar_icon name="bold" /></.toggle_button>
                        <.toggle_button
                          icon_only
                          aria-label="Italic"
                          pressed={@italic}
                          phx-click="toggle_format"
                          phx-value-format="italic"
                        ><.toolbar_icon name="italic" /></.toggle_button>
                        <.toggle_button
                          icon_only
                          aria-label="Underline"
                          pressed={@underline}
                          phx-click="toggle_format"
                          phx-value-format="underline"
                        ><.toolbar_icon name="underline" /></.toggle_button>
                      </.toggle_button_group>
                      <.separator orientation="vertical" />
                      <.button_group label="Editing">
                        <.button
                          icon_only
                          variant="tertiary"
                          aria-label="Copy"
                          phx-click="toolbar_action"
                          phx-value-action="Copy"
                        ><.toolbar_icon name="copy" /></.button>
                        <.button
                          icon_only
                          variant="tertiary"
                          aria-label="Cut"
                          phx-click="toolbar_action"
                          phx-value-action="Cut"
                        ><.toolbar_icon name="cut" /></.button>
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
                    ><.toolbar_icon name="undo" /></.button>
                    <.button
                      icon_only
                      variant="tertiary"
                      aria-label="Redo"
                      phx-click="toolbar_action"
                      phx-value-action="Redo"
                    ><.toolbar_icon name="redo" /></.button>
                    <.button icon_only variant="tertiary" aria-label="Unavailable" disabled>×</.button>
                  </.toolbar>
                </div>
              </.preview_card>
              <.preview_card title="Disclosure" description="Expand a section to reveal more detail.">
                <.disclosure id="project-disclosure" title="Project details">
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
                  class="lp-disclosure-group [&>.hui-disclosure:not(:first-child)]:mt-2"
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
                  class="lp-disclosure-group [&>.hui-disclosure:not(:first-child)]:mt-2"
                  allows_multiple_expanded
                  default_expanded_keys={["first"]}
                >
                  <:item key="first" title="First section">
                    <p>Each section manages its own expanded state.</p>
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
          <section
            id="overlays"
            class="lp-section scroll-mt-20 pt-[62px] pb-3 max-[850px]:scroll-mt-[145px] max-[620px]:pt-12"
            aria-labelledby="overlays-title"
          >
            <div class="lp-section-heading mb-[22px] flex items-end justify-between gap-6 max-[620px]:block [&_h2]:m-0 [&_h2]:text-[27px] [&_h2]:font-bold [&_h2]:leading-[1.15] [&_h2]:tracking-[-.04em] [&>p]:mb-0.5 [&>p]:mt-0 [&>p]:text-right [&>p]:text-xs [&>p]:leading-normal [&>p]:text-zinc-500 dark:[&>p]:text-zinc-400 max-[620px]:[&>p]:mt-2.5 max-[620px]:[&>p]:text-left">
              <div>
                <p class="lp-kicker mb-[9px] mt-0 text-[10px] font-[750] tracking-[.1em] text-zinc-500 dark:text-zinc-400">
                  COMPONENTS
                </p><h2 id="overlays-title">Overlays</h2>
              </div><p>Dialogs and contextual actions.</p>
            </div>
            <div class="lp-grid grid grid-cols-1 items-start gap-4 min-[621px]:grid-cols-2 min-[1201px]:grid-cols-3">
              <.preview_card
                title="Sheets"
                description="Swipe an edge panel or snap it between sizes."
              >
                <div class="flex flex-wrap gap-2">
                  <.button data-hero-sheet-open="preview-sheet">Bottom sheet</.button>
                  <.button data-hero-sheet-open="preview-sheet-right" variant="secondary">Right sheet</.button>
                  <.button data-hero-sheet-open="preview-sheet-top" variant="secondary">Top sheet</.button>
                  <.button data-hero-sheet-open="preview-sheet-left" variant="secondary">Left sheet</.button>
                  <.button data-hero-sheet-open="preview-sheet-snap" variant="secondary">Snap points</.button>
                  <.button data-hero-sheet-open="preview-sheet-controlled" variant="secondary">Controlled</.button>
                </div>
                <p
                  id="sheet-state"
                  class="mt-3 mb-0 break-words text-[11px] leading-[1.55] text-zinc-500 dark:text-zinc-400"
                >
                  Last controlled change: {@sheet_last}
                </p>
                <.sheet
                  id="preview-sheet"
                  title="Sheet title"
                  class="max-w-[420px]"
                  description="A focused space for a quick task."
                >
                  <p class="mt-3 text-sm text-muted">
                    Drag the handle to dismiss, or open a nested sheet.
                  </p>
                  <.button
                    data-hero-sheet-open="preview-sheet-nested"
                    class="mt-4"
                    variant="secondary"
                  >Open nested sheet</.button>
                  <.button phx-click="increment" class="mt-4" variant="secondary">Update count: {@count}</.button>
                  <.sheet id="preview-sheet-nested" title="Nested sheet" class="max-w-[380px]">
                    <p class="text-sm text-muted">Close this sheet to return to the previous one.</p>
                    <:footer>
                      <.button data-hero-sheet-close variant="secondary">Done</.button>
                    </:footer>
                  </.sheet>
                  <:footer>
                    <.button data-hero-sheet-close variant="secondary">Cancel</.button><.button data-hero-sheet-close>Confirm</.button>
                  </:footer>
                </.sheet>
                <.sheet id="preview-sheet-right" title="Details" placement="right" detached>
                  <p class="text-sm text-muted">A detached sheet can appear from any edge.</p>
                  <:footer><.button data-hero-sheet-close variant="secondary">Done</.button></:footer>
                </.sheet>
                <.sheet id="preview-sheet-top" title="Top sheet" placement="top" class="max-w-[420px]">
                  <p class="text-sm text-muted">This sheet opens from the top edge.</p>
                  <:footer><.button data-hero-sheet-close variant="secondary">Done</.button></:footer>
                </.sheet>
                <.sheet id="preview-sheet-left" title="Left sheet" placement="left">
                  <p class="text-sm text-muted">This sheet opens from the left edge.</p>
                  <:footer><.button data-hero-sheet-close variant="secondary">Done</.button></:footer>
                </.sheet>
                <.sheet
                  id="preview-sheet-snap"
                  title="Explore updates"
                  class="max-w-[420px]"
                  snap_points={[220, "55%"]}
                >
                  <div class="space-y-4 text-sm text-muted">
                    <p :for={i <- 1..30}>Update {i}: swipe up to expand and scroll this sheet.</p>
                  </div>
                  <:footer><.button data-hero-sheet-close variant="secondary">Done</.button></:footer>
                </.sheet>
                <.sheet
                  id="preview-sheet-controlled"
                  title="Controlled sheet"
                  class="max-w-[420px]"
                  open={@controlled_sheet_open}
                  on_open_change="sheet_open_change"
                >
                  <p class="text-sm text-muted">LiveView controls whether this sheet is open.</p>
                  <:footer><.button data-hero-sheet-close variant="secondary">Done</.button></:footer>
                </.sheet>
              </.preview_card>
              <.preview_card
                title="Dropdown menus"
                description="Sections, selection, and nested actions."
              >
                <div class="flex flex-wrap gap-2">
                  <.dropdown id="view-menu" label="View options" on_action="dropdown_action">
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
                    label="Formatting"
                    selection_mode="multiple"
                    default_selected_keys={["bold"]}
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
              <.preview_card
                title="Dialogs & menus"
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
          <section
            id="feedback"
            class="lp-section scroll-mt-20 pt-[62px] pb-3 max-[850px]:scroll-mt-[145px] max-[620px]:pt-12"
            aria-labelledby="feedback-title"
          >
            <div class="lp-section-heading mb-[22px] flex items-end justify-between gap-6 max-[620px]:block [&_h2]:m-0 [&_h2]:text-[27px] [&_h2]:font-bold [&_h2]:leading-[1.15] [&_h2]:tracking-[-.04em] [&>p]:mb-0.5 [&>p]:mt-0 [&>p]:text-right [&>p]:text-xs [&>p]:leading-normal [&>p]:text-zinc-500 dark:[&>p]:text-zinc-400 max-[620px]:[&>p]:mt-2.5 max-[620px]:[&>p]:text-left">
              <div>
                <p class="lp-kicker mb-[9px] mt-0 text-[10px] font-[750] tracking-[.1em] text-zinc-500 dark:text-zinc-400">
                  COMPONENTS
                </p><h2 id="feedback-title">Feedback</h2>
              </div><p>Keep people informed about changes.</p>
            </div>
            <div class="lp-grid grid grid-cols-1 items-start gap-4 min-[621px]:grid-cols-2 min-[1201px]:grid-cols-3">
              <.preview_card
                title="Toast notifications"
                description="Send a notification in any of five variants."
              >
                <section aria-label="Toast preview">
                  <.toast_region id="preview-toasts" placement="bottom" />
                  <div class="lp-inline flex flex-wrap items-center gap-2.5">
                    <.button
                      :for={variant <- ~w(default accent success warning danger)}
                      phx-click="show_toast"
                      phx-value-variant={variant}
                      size="sm"
                      variant="secondary"
                    >{String.capitalize(variant)} toast</.button>
                  </div>
                  <p
                    id="toast-action-state"
                    class="mt-3 mb-0 break-words text-[11px] leading-[1.55] text-zinc-500 dark:text-zinc-400"
                  >
                    Action: {@toast_action}
                  </p>
                </section>
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
                <.alert title="Profile updated" color="success">Your settings are saved.</.alert>
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
          <section
            id="data"
            class="lp-section scroll-mt-20 pt-[62px] pb-3 max-[850px]:scroll-mt-[145px] max-[620px]:pt-12"
            aria-labelledby="data-title"
          >
            <div class="lp-section-heading mb-[22px] flex items-end justify-between gap-6 max-[620px]:block [&_h2]:m-0 [&_h2]:text-[27px] [&_h2]:font-bold [&_h2]:leading-[1.15] [&_h2]:tracking-[-.04em] [&>p]:mb-0.5 [&>p]:mt-0 [&>p]:text-right [&>p]:text-xs [&>p]:leading-normal [&>p]:text-zinc-500 dark:[&>p]:text-zinc-400 max-[620px]:[&>p]:mt-2.5 max-[620px]:[&>p]:text-left">
              <div>
                <p class="lp-kicker mb-[9px] mt-0 text-[10px] font-[750] tracking-[.1em] text-zinc-500 dark:text-zinc-400">
                  COMPONENTS
                </p><h2 id="data-title">Data display</h2>
              </div><p>Tables and pagination with LiveView updates.</p>
            </div>
            <div class="lp-grid grid grid-cols-1 items-start gap-4 min-[621px]:grid-cols-2 min-[1201px]:grid-cols-3">
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
                  <.pagination
                    class="max-w-full overflow-x-auto"
                    page={@page}
                    total_pages={10}
                    on_change="page_changed"
                  >
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
          <footer class="lp-footer mt-[65px] flex justify-between gap-4 border-t border-[#e8e8ed] py-11 text-[11px] text-zinc-500 dark:border-[#303138] dark:text-zinc-400 [&>span]:font-[750] [&>span]:text-zinc-900 dark:[&>span]:text-zinc-100 [&>span_span]:font-normal [&>span_span]:text-zinc-500 dark:[&>span_span]:text-zinc-400 [&>a]:text-zinc-500 [&>a]:no-underline dark:[&>a]:text-zinc-400">
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
