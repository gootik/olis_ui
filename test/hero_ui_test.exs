defmodule HeroUITest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  test "button renders a safe default and forwards LiveView attributes" do
    html =
      render_component(&HeroUI.button/1, %{
        inner_block: [%{inner_block: fn _, _ -> "Save" end}],
        "phx-click": "save"
      })

    assert html =~ ~s(type="button")
    assert html =~ ~s(phx-click="save")
    assert html =~ "button--primary"
  end

  test "field connects its label, description and errors" do
    html =
      render_component(&HeroUI.text_field/1, %{
        id: "email",
        name: "user[email]",
        label: "Email",
        description: "For receipts",
        errors: ["is invalid"]
      })

    assert html =~ ~s(for="email")
    assert html =~ ~s(aria-invalid="true")
    assert html =~ ~s(aria-describedby="email-description email-errors")
    assert html =~ "is invalid"
  end

  test "input group connects form fields, adornments, and visible errors" do
    form = Phoenix.Component.to_form(%{"price" => "10"}, as: :order)

    html =
      render_component(&HeroUI.input_group/1, %{
        field: form[:price],
        label: "Price",
        description: "Before tax",
        errors: ["is invalid"],
        prefix: [%{inner_block: fn _, _ -> "$" end}],
        suffix: [%{inner_block: fn _, _ -> "USD" end}]
      })

    assert html =~ ~s(for="order_price")
    assert html =~ ~s(name="order[price]")
    assert html =~ ~s(value="10")
    assert html =~ ~s(aria-describedby="order_price-errors")
    assert html =~ "input-group__prefix"
    assert html =~ "input-group__suffix"
    assert html =~ ~s(data-visible="true")

    multiline =
      render_component(&HeroUI.input_group/1, %{
        id: "note",
        label: "Note",
        multiline: true,
        value: "<test>"
      })

    assert multiline =~ "<textarea"
    assert multiline =~ "&lt;test&gt;"
  end

  test "form field supplies its id, name and value" do
    form = Phoenix.Component.to_form(%{"email" => "hello@example.com"}, as: :user)
    html = render_component(&HeroUI.text_field/1, %{field: form[:email], label: "Email"})
    assert html =~ ~s(id="user_email")
    assert html =~ ~s(name="user[email]")
    assert html =~ ~s(value="hello@example.com")
  end

  test "search field connects form data and validation feedback" do
    form = Phoenix.Component.to_form(%{"query" => "phoenix"}, as: :search)

    html =
      render_component(&HeroUI.search_field/1, %{
        field: form[:query],
        label: "Search",
        description: "Enter a query",
        errors: ["is too short"]
      })

    assert html =~ ~s(id="search_query")
    assert html =~ ~s(name="search[query]")
    assert html =~ ~s(value="phoenix")
    assert html =~ ~s(for="search_query")
    assert html =~ ~s(aria-describedby="search_query-errors")
    assert html =~ ~s(data-hero-search-clear)
    assert html =~ ~s(data-invalid="true")
    assert html =~ ~s(data-visible="true")
  end

  test "one-time-code input submits one value and renders configurable groups" do
    form = Phoenix.Component.to_form(%{"code" => "12"}, as: :verification)

    html =
      render_component(&HeroUI.input_otp/1, %{
        field: form[:code],
        label: "Verification code",
        length: 4,
        groups: [2, 2],
        errors: ["is invalid"]
      })

    assert html =~ ~s(for="verification_code")
    assert html =~ ~s(name="verification[code]")
    assert html =~ ~s(value="12")
    assert html =~ ~s(maxlength="4")
    assert html =~ ~s(autocomplete="one-time-code")
    assert html =~ ~s(aria-describedby="verification_code-errors")
    assert html =~ ~s(data-visible="true")
    assert length(Regex.scan(~r/data-hero-otp-index=/, html)) == 4
    assert length(Regex.scan(~r/input-otp__separator/, html)) == 1

    assert_raise ArgumentError, fn ->
      render_component(&HeroUI.input_otp/1, %{id: "invalid", length: 4, groups: [3, 3]})
    end
  end

  test "tag group renders controlled selection and independent removal actions" do
    tags = [
      %{value: "news", label: "News", inner_block: nil},
      %{value: "travel", label: "Travel", disabled: true}
    ]

    html =
      render_component(&HeroUI.tag_group/1, %{
        id: "topics",
        label: "Topics",
        tag: tags,
        selection_mode: "multiple",
        selected: ["news"],
        on_select: "select",
        on_remove: "remove"
      })

    assert html =~ ~s(role="grid")
    assert html =~ ~s(aria-multiselectable="true")
    assert html =~ ~s(aria-selected="true")
    assert html =~ ~s(aria-disabled="true")
    assert html =~ ~s(aria-label="Remove News")
    assert html =~ ~r/<button\b[^>]*\svalue="news"/s
    assert html =~ ~s(phx-click="remove")

    assert_raise ArgumentError, fn ->
      render_component(&HeroUI.tag_group/1, %{
        id: "bad",
        label: "Bad",
        tag: tags,
        selection_mode: "single"
      })
    end
  end

  test "checkbox and switch render native controls" do
    slot = [%{inner_block: fn _, _ -> "Notifications" end}]

    checkbox =
      render_component(&HeroUI.checkbox/1, %{
        id: "check",
        name: "enabled",
        checked: true,
        inner_block: slot
      })

    assert checkbox =~ ~s(type="checkbox")
    assert checkbox =~ ~s(checked)
    assert checkbox =~ ~s(for="check")
    switch = render_component(&HeroUI.switch/1, %{id: "switch", inner_block: slot})
    assert switch =~ ~s(role="switch")
    assert switch =~ "Notifications"
  end

  test "progress reports determinate and indeterminate values" do
    html = render_component(&HeroUI.progress_bar/1, %{label: "Upload", value: 25, max: 50})
    assert html =~ ~s(aria-valuenow="25")
    assert html =~ "50%"
    indeterminate = render_component(&HeroUI.progress_bar/1, %{label: "Loading"})
    refute indeterminate =~ "aria-valuenow"
    assert indeterminate =~ "progress-bar__fill"

    assert_raise ArgumentError, fn ->
      render_component(&HeroUI.progress_bar/1, %{label: "Upload", value: 101})
    end
  end

  test "textarea escapes its value and radio keeps native form semantics" do
    html = render_component(&HeroUI.textarea/1, %{id: "notes", value: "<hello>"})
    assert html =~ "&lt;hello&gt;"
    slot = [%{inner_block: fn _, _ -> "Pro" end}]

    radio =
      render_component(&HeroUI.radio/1, %{
        id: "pro",
        name: "plan",
        value: "pro",
        inner_block: slot
      })

    assert radio =~ ~s(type="radio")
    assert radio =~ ~s(name="plan")
    assert radio =~ ~s(value="pro")
  end

  test "select marks the selected option and accordion uses native disclosure" do
    select =
      render_component(&HeroUI.select/1, %{
        id: "plan",
        name: "plan",
        options: [{"Starter", "starter"}, {"Pro", "pro"}],
        value: "pro"
      })

    assert select =~ ~s(selected value="pro")
    slot = [%{inner_block: fn _, _ -> "Details" end}]
    accordion = render_component(&HeroUI.accordion/1, %{title: "More", inner_block: slot})
    assert accordion =~ "<details"
    assert accordion =~ "<summary"
    assert accordion =~ "Details"
  end

  test "combo box retains a named native select and connected label" do
    form = Phoenix.Component.to_form(%{"animal" => "dog"}, as: :pet)

    html =
      render_component(&HeroUI.combo_box/1, %{
        field: form[:animal],
        label: "Animal",
        options: [{"Cat", "cat"}, {"Dog", "dog"}],
        required: true,
        errors: ["choose an animal"]
      })

    assert html =~ ~s(for="pet_animal")
    assert html =~ ~s(name="pet[animal]")
    assert html =~ ~s(selected value="dog")
    assert html =~ ~s(aria-describedby="pet_animal-errors")
    assert html =~ ~s(role="combobox")
    assert html =~ ~s(aria-controls="pet_animal-listbox")
    assert html =~ ~s(data-hero-combo-native)
  end

  test "custom combo box has a text input and datalist without JavaScript" do
    html =
      render_component(&HeroUI.combo_box/1, %{
        id: "pet",
        name: "animal",
        label: "Animal",
        value: "Otter",
        allows_custom_value: true,
        options: [
          {"Mammals", [{"Cat", "cat"}, [key: "Kangaroo", value: "kangaroo", disabled: true]]}
        ]
      })

    assert html =~ ~r/<input\b[^>]*\sid="pet"[^>]*\sname="animal"[^>]*\svalue="Otter"/s
    assert html =~ ~s(list="pet-suggestions")
    assert html =~ ~s(<datalist id="pet-suggestions">)
    assert html =~ ~s(<option value="Cat">)
    refute html =~ ~s(<option value="Kangaroo">)
  end

  test "multiple combo box submits a list with selected options and required validation" do
    html =
      render_component(&HeroUI.combo_box/1, %{
        id: "pets",
        name: "pets",
        label: "Pets",
        selection_mode: "multiple",
        value: ["cat", "dog"],
        options: [{"Cat", "cat"}, {"Dog", "dog"}],
        required: true,
        selected_placeholder: "None"
      })

    assert html =~ ~s(name="pets[]")
    assert html =~ ~s(multiple)
    assert html =~ ~s(selected value="cat")
    assert html =~ ~s(selected value="dog")
    assert html =~ ~s(aria-multiselectable="true")
    assert html =~ ~s(data-hero-combo-value)

    assert_raise ArgumentError, fn ->
      render_component(&HeroUI.combo_box/1, %{
        id: "bad",
        label: "Bad",
        selection_mode: "multiple",
        value: "cat",
        options: []
      })
    end
  end

  test "date field renders a constrained native form field with enhanced segments" do
    form = Phoenix.Component.to_form(%{"day" => "2026-10-15"}, as: :event)

    html =
      render_component(&HeroUI.date_field/1, %{
        field: form[:day],
        label: "Event date",
        description: "Pick a date",
        min: ~D[2026-01-01],
        max: ~D[2026-12-31],
        required: true,
        errors: ["is invalid"]
      })

    assert html =~ ~s(name="event[day]")
    assert html =~ ~s(value="2026-10-15")
    assert html =~ ~s(min="2026-01-01")
    assert html =~ ~s(max="2026-12-31")
    assert html =~ ~s(aria-describedby="event_day-description event_day-errors")
    assert html =~ ~s(data-hero-date-segments)
    assert html =~ "is invalid"

    assert_raise ArgumentError, fn ->
      render_component(&HeroUI.date_field/1, %{
        id: "bad",
        label: "Bad",
        min: ~D[2026-12-01],
        max: ~D[2026-01-01]
      })
    end
  end

  test "calendar renders a named native date input with constraints and accessible feedback" do
    form = Phoenix.Component.to_form(%{"day" => "2026-10-15"}, as: :event)

    html =
      render_component(&HeroUI.calendar/1, %{
        field: form[:day],
        label: "Event date",
        min: ~D[2026-09-01],
        max: ~D[2026-12-31],
        unavailable_dates: [~D[2026-10-18]],
        year_picker: true,
        errors: ["is unavailable"],
        required: true
      })

    assert html =~ ~s(for="event_day")
    assert html =~ ~s(name="event[day]")
    assert html =~ ~s(type="date")
    assert html =~ ~s(value="2026-10-15")
    assert html =~ ~s(min="2026-09-01")
    assert html =~ ~s(max="2026-12-31")
    assert html =~ "2026-10-18"
    assert html =~ ~s(aria-describedby="event_day-errors")
    assert html =~ ~s(data-hero-calendar-view)
    assert html =~ ~s(data-year-picker="true")

    assert_raise ArgumentError, fn ->
      render_component(&HeroUI.calendar/1, %{
        id: "bad",
        label: "Bad",
        min: ~D[2026-12-01],
        max: ~D[2026-01-01]
      })
    end

    invalid =
      render_component(&HeroUI.calendar/1, %{
        id: "invalid-day",
        label: "Date",
        value: "not-a-date",
        errors: ["is invalid"]
      })

    assert invalid =~ "is invalid"
    refute invalid =~ ~s(value="not-a-date")
  end

  test "range calendar renders two form fields and their constraints" do
    form = Phoenix.Component.to_form(%{"start" => "2026-10-12", "end" => "2026-10-16"}, as: :stay)

    html =
      render_component(&HeroUI.range_calendar/1, %{
        id: "stay",
        label: "Trip dates",
        start_field: form[:start],
        end_field: form[:end],
        min: ~D[2026-09-01],
        max: ~D[2026-12-31],
        unavailable_dates: [~D[2026-10-18]],
        required: true,
        errors: ["Invalid range"],
        year_picker: true
      })

    assert html =~ ~s(name="stay[start]")
    assert html =~ ~s(name="stay[end]")
    assert html =~ ~s(value="2026-10-12")
    assert html =~ ~s(value="2026-10-16")
    assert html =~ ~s(for="stay_start")
    assert html =~ ~s(for="stay_end")
    assert html =~ ~s(data-range="true")
    assert html =~ ~s(class="range-calendar")
    assert html =~ ~s(aria-describedby="stay-errors")
    assert html =~ "2026-10-18"

    assert_raise ArgumentError, fn ->
      render_component(&HeroUI.range_calendar/1, %{
        id: "bad",
        label: "Bad",
        min: ~D[2026-12-01],
        max: ~D[2026-01-01]
      })
    end
  end

  test "components use official HeroUI classes and expose invalid input state" do
    slot = [%{inner_block: fn _, _ -> "Ready" end}]

    chip =
      render_component(&HeroUI.chip/1, %{color: "success", variant: "soft", inner_block: slot})

    assert chip =~ "chip--success"
    assert chip =~ "chip--soft"
    assert chip =~ "chip__label"
    input = render_component(&HeroUI.input/1, %{id: "email", invalid: true, full_width: true})
    assert input =~ ~s(data-invalid="true")
    assert input =~ "input--full-width"
  end

  test "modal has an accessible title and supports disabling dismissal" do
    slot = [%{inner_block: fn _, _ -> "Details" end}]

    html =
      render_component(&HeroUI.modal/1, %{
        id: "edit",
        title: "Edit profile",
        dismissible: false,
        inner_block: slot
      })

    assert html =~ ~s(<dialog)
    assert html =~ ~s(aria-labelledby="edit-title")
    assert html =~ ~s(data-dismissible="false")
    assert html =~ "data-hero-dialog-close"
    assert html =~ "Details"
    assert html =~ "phx-mounted"
  end

  test "tabs connect tabs and panels and select the first enabled item" do
    tabs = [
      %{id: "one", label: "One", disabled: true, inner_block: fn _, _ -> "First" end},
      %{id: "two", label: "Two", inner_block: fn _, _ -> "Second" end}
    ]

    html = render_component(&HeroUI.tabs/1, %{id: "settings", label: "Settings", tab: tabs})
    assert html =~ ~s(aria-label="Settings")
    assert html =~ ~s(id="settings-tab-two")
    assert html =~ ~s(aria-controls="settings-panel-two")
    assert html =~ ~s(aria-labelledby="settings-tab-two")
    assert html =~ ~s(aria-selected="true")

    assert_raise ArgumentError, fn ->
      render_component(&HeroUI.tabs/1, %{id: "invalid", label: "Invalid", tab: [hd(tabs)]})
    end
  end

  test "checkbox variants and switch sizes use HeroUI control markup" do
    slot = [%{inner_block: fn _, _ -> "Option" end}]

    checkbox =
      render_component(&HeroUI.checkbox/1, %{
        id: "option",
        variant: "secondary",
        invalid: true,
        inner_block: slot
      })

    assert checkbox =~ "checkbox--secondary"
    assert checkbox =~ "checkbox__control"
    assert checkbox =~ ~s(aria-invalid="true")

    switch =
      render_component(&HeroUI.switch/1, %{
        id: "setting",
        size: "lg",
        disabled: true,
        inner_block: slot
      })

    assert switch =~ "switch--lg"
    assert switch =~ "switch__thumb"
    assert switch =~ ~s(data-disabled="true")
  end

  test "dropdown renders native popover semantics and disabled items" do
    html =
      render_component(&HeroUI.dropdown/1, %{
        id: "actions",
        label: "Actions",
        item: [
          %{label: "Edit", on_click: "edit"},
          %{label: "Unavailable", disabled: true},
          %{label: "Help", href: "/help"}
        ]
      })

    assert html =~ ~s(popovertarget="actions-menu")
    assert html =~ ~s(aria-haspopup="menu")
    assert html =~ ~s(popover="auto")
    assert html =~ ~s(phx-click="edit")
    assert html =~ ~s(href="/help")
    assert html =~ "disabled"
  end

  test "select forwards native attributes and uses HeroUI variant and invalid state" do
    html =
      render_component(&HeroUI.select/1, %{
        id: "plan",
        variant: "secondary",
        invalid: true,
        disabled: true,
        options: [{"Pro", "pro"}]
      })

    assert html =~ "select--secondary"
    assert html =~ "select__trigger"
    assert html =~ ~s(aria-invalid="true")
    assert html =~ "disabled"
  end

  test "alert dialogs label their descriptions and drawers identify their placement" do
    slot = [%{inner_block: fn _, _ -> "Details" end}]

    alert =
      render_component(&HeroUI.alert_dialog/1, %{
        id: "confirm",
        title: "Confirm?",
        on_confirm: "confirm",
        inner_block: slot
      })

    assert alert =~ ~s(role="alertdialog")
    assert alert =~ ~s(aria-describedby="confirm-description")
    assert alert =~ ~s(phx-click="confirm")
    assert alert =~ ~s(data-dismissible="false")

    drawer =
      render_component(&HeroUI.drawer/1, %{
        id: "settings",
        title: "Settings",
        placement: "left",
        inner_block: slot
      })

    assert drawer =~ "drawer__dialog"
    assert drawer =~ ~s(data-placement="left")
    assert drawer =~ ~s(aria-labelledby="settings-title")
  end

  test "progress circle and meter describe their ranges and use HeroUI styles" do
    circle =
      render_component(&HeroUI.progress_circle/1, %{
        label: "Upload",
        value: 5,
        min: 0,
        max: 10,
        size: "lg",
        color: "success"
      })

    assert circle =~ ~s(role="progressbar")
    assert circle =~ ~s(aria-valuenow="5")
    assert circle =~ "progress-circle--lg"
    assert circle =~ "progress-circle--success"
    assert circle =~ "progress-circle__fill-circle"
    waiting = render_component(&HeroUI.progress_circle/1, %{label: "Waiting"})
    refute waiting =~ "aria-valuenow"

    meter =
      render_component(&HeroUI.meter/1, %{
        label: "Storage",
        value: 25,
        min: 10,
        max: 40,
        value_text: "25 GB"
      })

    assert meter =~ ~s(role="meter")
    assert meter =~ ~s(aria-valuetext="25 GB")
    assert meter =~ "width: 50.0%"

    assert_raise ArgumentError, fn ->
      render_component(&HeroUI.meter/1, %{label: "Bad", value: 0, min: 10, max: 20})
    end

    assert_raise ArgumentError, fn ->
      render_component(&HeroUI.progress_circle/1, %{label: "Bad", value: 0, min: 10, max: 10})
    end
  end

  test "tooltip and popover associate their trigger and content" do
    slot = [%{inner_block: fn _, _ -> "More" end}]

    tooltip =
      render_component(&HeroUI.tooltip/1, %{id: "tip", text: "Helpful text", inner_block: slot})

    assert tooltip =~ ~s(aria-describedby="tip-content")
    assert tooltip =~ ~s(role="tooltip")
    assert tooltip =~ "Helpful text"

    popover =
      render_component(&HeroUI.popover/1, %{
        id: "details",
        trigger: "Open",
        title: "Details",
        inner_block: slot
      })

    assert popover =~ ~s(popovertarget="details-content")
    assert popover =~ ~s(aria-labelledby="details-title")
    assert popover =~ ~s(role="dialog")
  end

  test "slider and number field expose native form controls" do
    slider =
      render_component(&HeroUI.slider/1, %{
        id: "volume",
        name: "volume",
        label: "Volume",
        value: 25
      })

    assert slider =~ ~s(type="range")
    assert slider =~ ~s(for="volume")
    assert slider =~ "--hui-slider-percent: 25.0%"

    assert_raise ArgumentError, fn ->
      render_component(&HeroUI.slider/1, %{id: "s", label: "Slider", value: 5, step: 0})
    end

    field =
      render_component(&HeroUI.number_field/1, %{
        id: "quantity",
        name: "quantity",
        label: "Quantity",
        min: 1,
        max: 5,
        value: 2
      })

    assert field =~ ~s(type="number")
    assert field =~ ~s(aria-label="Increase Quantity")
    assert field =~ ~s(data-hero-number-step="down")
  end

  test "avatar, alert and badge use HeroUI structures" do
    avatar =
      render_component(&HeroUI.avatar/1, %{
        name: "Casey Jones",
        src: "/photo.png",
        color: "accent",
        variant: "soft"
      })

    assert avatar =~ ~s(aria-label="Casey Jones")
    assert avatar =~ "avatar__fallback--accent"
    assert avatar =~ ">CJ</span>"
    assert avatar =~ "data-hero-avatar-image"
    slot = [%{inner_block: fn _, _ -> "Saved" end}]

    alert =
      render_component(&HeroUI.alert/1, %{title: "Success", color: "success", inner_block: slot})

    assert alert =~ "alert--success"
    assert alert =~ "alert-default-icon"

    badge =
      render_component(&HeroUI.badge/1, %{
        color: "danger",
        variant: "soft",
        placement: "top-right",
        inner_block: slot
      })

    assert badge =~ "badge--danger"
    assert badge =~ "badge--soft"
    assert badge =~ "badge--top-right"
  end

  test "table exposes sorting and renders row headers and empty states" do
    cols = [
      %{label: "Name", sort_key: "name", row_header: true, inner_block: fn _, row -> row.name end}
    ]

    html =
      render_component(&HeroUI.data_table/1, %{
        id: "people",
        label: "People",
        rows: [%{name: "Jane"}],
        col: cols,
        sort_event: "sort",
        sort_by: "name",
        sort_direction: "descending"
      })

    assert html =~ ~s(aria-sort="descending")
    assert html =~ ~s(phx-value-sort="name")
    assert html =~ ~s(scope="row")
    assert html =~ "table-root--primary"
    assert html =~ "Jane"

    empty =
      render_component(&HeroUI.data_table/1, %{
        label: "People",
        rows: [],
        col: cols,
        empty_message: "Nothing here"
      })

    assert empty =~ "Nothing here"
  end

  test "pagination renders bounded pages and accessible current state" do
    html =
      render_component(&HeroUI.pagination/1, %{page: 5, total_pages: 10, on_change: "change_page"})

    assert html =~ ~s(aria-label="Pagination")
    assert html =~ ~s(aria-current="page")
    assert html =~ ~s(phx-value-page="5")
    assert html =~ ~s(phx-click="change_page")
    assert html =~ "pagination__ellipsis"

    links =
      render_component(&HeroUI.pagination/1, %{
        page: 1,
        total_pages: 3,
        href: fn n -> "/people?page=#{n}" end
      })

    assert links =~ ~s(href="/people?page=2")
    assert links =~ ~s(aria-disabled="true")
    empty = render_component(&HeroUI.pagination/1, %{page: 1, total_pages: 0, on_change: "page"})
    refute empty =~ ~s(aria-current="page")

    assert_raise ArgumentError, fn ->
      render_component(&HeroUI.pagination/1, %{page: 11, total_pages: 10, on_change: "page"})
    end
  end

  test "radio groups label options, preserve values and associate errors" do
    options = [
      %{value: "standard", label: "Standard", description: "Three days"},
      %{value: "express", label: "Express", disabled: true}
    ]

    html =
      render_component(&HeroUI.radio_group/1, %{
        id: "delivery",
        name: "delivery",
        label: "Delivery",
        value: "standard",
        description: "Choose one",
        errors: ["is required"],
        option: options
      })

    assert html =~ "radio-group--primary"
    assert html =~ "radio__control"
    assert html =~ ~s(aria-labelledby="delivery-option-c3RhbmRhcmQ-label")
    assert html =~ ~s(aria-describedby="delivery-description delivery-errors")
    assert html =~ ~s(name="delivery")
    assert html =~ "Three days"
    assert html =~ "is required"
    assert html =~ "disabled"

    assert_raise ArgumentError, fn ->
      render_component(&HeroUI.radio_group/1, %{
        id: "duplicate",
        name: "x",
        label: "X",
        option: [hd(options), hd(options)]
      })
    end
  end

  test "checkbox group uses list names, distinct labels and descriptions" do
    options = [
      %{value: "news", label: "News", description: "Updates"},
      %{value: "events", label: "Events", disabled: true}
    ]

    html =
      render_component(&HeroUI.checkbox_group/1, %{
        id: "topics",
        name: "user[topics]",
        label: "Topics",
        value: ["news"],
        required: true,
        description: "Select topics",
        errors: ["Choose one"],
        option: options
      })

    assert html =~ ~s(name="user[topics][]")
    assert html =~ ~s(aria-labelledby="topics-option-bmV3cw-label")
    assert html =~ ~s(aria-describedby="topics-description topics-required topics-errors")
    assert html =~ "Updates"
    assert html =~ "Choose one"
    assert html =~ "checkbox-group"

    assert_raise ArgumentError, fn ->
      render_component(&HeroUI.checkbox_group/1, %{
        id: "duplicate",
        name: "x",
        label: "X",
        option: [hd(options), hd(options)]
      })
    end
  end

  test "button groups, toggles, and breadcrumbs expose semantic state" do
    slot = [%{inner_block: fn _, _ -> "Bold" end}]

    toggle =
      render_component(&HeroUI.toggle_button/1, %{
        pressed: true,
        inner_block: slot,
        "phx-click": "toggle"
      })

    assert toggle =~ ~s(aria-pressed="true")
    assert toggle =~ ~s(data-selected="true")
    assert toggle =~ ~s(phx-click="toggle")

    group =
      render_component(&HeroUI.toggle_button_group/1, %{label: "Formatting", inner_block: slot})

    assert group =~ ~s(role="group")
    assert group =~ ~s(aria-label="Formatting")

    crumbs =
      render_component(&HeroUI.breadcrumbs/1, %{
        item: [%{label: "Home", href: "/"}, %{label: "Settings"}]
      })

    assert crumbs =~ ~s(href="/")
    assert crumbs =~ ~s(aria-current="page")
    assert crumbs =~ "breadcrumbs__separator"
  end

  test "listbox renders selected, disabled, and described options" do
    options = [
      %{value: "alpha", label: "Alpha", description: "Primary"},
      %{value: "beta", label: "Beta", disabled: true}
    ]

    html =
      render_component(&HeroUI.listbox/1, %{
        id: "spaces",
        label: "Spaces",
        on_select: "choose",
        selected: ["alpha"],
        option: options
      })

    assert html =~ ~s(role="listbox")
    assert html =~ ~s(aria-label="Spaces")
    assert html =~ ~s(aria-selected="true")
    assert html =~ ~s(aria-disabled="true")
    assert html =~ ~s(phx-value-value="alpha")
    assert html =~ "Primary"

    assert_raise ArgumentError, fn ->
      render_component(&HeroUI.listbox/1, %{
        id: "x",
        label: "X",
        on_select: "choose",
        option: [hd(options), hd(options)]
      })
    end
  end

  test "select retains native control and provides enhancement hooks" do
    html =
      render_component(&HeroUI.select/1, %{
        id: "plan",
        name: "plan",
        options: [{"Starter", "starter"}]
      })

    assert html =~ ~s(<select)
    assert html =~ ~s(name="plan")
    assert html =~ "data-hero-native-select"
    assert html =~ ~s(aria-controls="plan-listbox")
    assert html =~ ~s(popover="auto")
    assert html =~ ~s(phx-update="ignore")
  end
end
