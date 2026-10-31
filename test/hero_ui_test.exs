defmodule HeroUITest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest
  import Phoenix.Component, only: [sigil_H: 2]

  test "surface exposes HeroUI background variants without imposing layout" do
    slot = [%{inner_block: fn _, _ -> "Content" end}]

    for variant <- ~w(default secondary tertiary transparent) do
      html = render_component(&HeroUI.surface/1, %{variant: variant, inner_block: slot})
      assert html =~ "surface--#{variant}"
      assert html =~ ~s(data-slot="surface")
      refute html =~ "hui-surface"
    end

    custom =
      render_component(&HeroUI.surface/1, %{
        class: "rounded-3xl p-6",
        rest: %{"data-slot" => "custom-surface", "aria-label" => "Overview"},
        inner_block: slot
      })

    assert custom =~ ~s(data-slot="custom-surface")
    assert custom =~ ~s(aria-label="Overview")
    assert custom =~ "rounded-3xl p-6"
  end

  test "ui_form delegates to Phoenix forms, including captured form data and HTTP options" do
    html =
      render_component(&HeroUI.ui_form/1, %{
        for: %{"email" => "person@example.com"},
        as: :account,
        action: "/accounts",
        method: "put",
        csrf_token: "test-token",
        rest: %{"phx-submit" => "save", "class" => "space-y-4"},
        inner_block: [
          %{inner_block: fn _, form -> "#{form.name}:#{form[:email].value}" end}
        ]
      })

    assert html =~ ~s(action="/accounts")
    assert html =~ ~s(method="post")
    assert html =~ ~r/name="_method"[^>]*value="put"/
    assert html =~ ~r/name="_csrf_token"[^>]*value="test-token"/
    assert html =~ ~s(phx-submit="save")
    assert html =~ ~s(class="space-y-4")
    assert html =~ "account:person@example.com"
  end

  test "standalone descriptions and errors use HeroUI styles and explicit visibility" do
    content = [%{inner_block: fn _, _ -> "Helpful message" end}]

    description =
      render_component(&HeroUI.description/1, %{
        class: "custom",
        rest: %{id: "help"},
        inner_block: content
      })

    assert description =~ ~s(class="description custom")
    assert description =~ ~s(id="help")
    assert description =~ ~s(data-slot="description")

    error = render_component(&HeroUI.field_error/1, %{inner_block: content})
    assert error =~ ~s(class="field-error )
    assert error =~ ~s(data-slot="field-error")
    assert error =~ ~s(data-visible="true")
    refute error =~ " hidden"

    hidden = render_component(&HeroUI.field_error/1, %{visible: false, inner_block: content})
    assert hidden =~ "hidden"
    refute hidden =~ "data-visible"

    message = render_component(&HeroUI.error_message/1, %{inner_block: content})
    assert message =~ ~s(class="error-message )
    assert message =~ ~s(data-slot="error-message")
  end

  test "label applies HeroUI form states and associates with the control" do
    html =
      render_component(&HeroUI.label/1, %{
        for: "email",
        required: true,
        disabled: true,
        invalid: true,
        inner_block: [%{inner_block: fn _, _ -> "Email" end}]
      })

    assert html =~ ~s(for="email")
    assert html =~ "label--required"
    assert html =~ "label--disabled"
    assert html =~ "label--invalid"
    assert html =~ ~s(data-slot="label")
  end

  test "link supports LiveView navigation, disabled state, and optional icon" do
    slot = [%{inner_block: fn _, _ -> "Settings" end}]
    html = render_component(&HeroUI.ui_link/1, %{patch: "/settings", inner_block: slot})
    assert html =~ ~s(href="/settings")
    assert html =~ ~s(data-phx-link="patch")
    assert html =~ ~s(data-slot="link")

    disabled =
      render_component(&HeroUI.ui_link/1, %{
        href: "/settings",
        disabled: true,
        rest: %{"phx-click" => "navigate", "tabindex" => "0"},
        inner_block: slot
      })

    assert disabled =~ ~s(aria-disabled="true")
    assert disabled =~ ~s(tabindex="-1")
    refute disabled =~ ~s(href=)
    refute disabled =~ ~s(phx-click=)

    icon = render_component(&HeroUI.link_icon/1, %{})
    assert icon =~ ~s(data-slot="link-icon")
    assert icon =~ ~s(data-default-icon="true")
    assert icon =~ ~s(data-slot="link-default-icon")

    assert_raise ArgumentError, ~r/exactly one/, fn ->
      render_component(&HeroUI.ui_link/1, %{href: "/one", patch: "/two", inner_block: slot})
    end
  end

  test "skeleton supports the HeroUI animation variants and theme default" do
    for animation <- ~w(shimmer pulse none) do
      html = render_component(&HeroUI.skeleton/1, %{animation_type: animation, class: "h-4"})
      assert html =~ "skeleton--#{animation}"
      assert html =~ "h-4"
      assert html =~ ~s(aria-hidden="true")
      refute html =~ "x-data"
    end

    default = render_component(&HeroUI.skeleton/1, %{})
    assert default =~ "skeleton--shimmer"
    assert default =~ "--skeleton-animation"
    assert default =~ "x-bind:class"
  end

  test "spinners use HeroUI gradients with unique IDs and accessible states" do
    first = render_component(&HeroUI.spinner/1, %{color: "success", size: "lg"})
    second = render_component(&HeroUI.spinner/1, %{})
    assert first =~ ~s(role="status")
    assert first =~ ~s(aria-label="Loading")
    assert first =~ "spinner--success"
    assert first =~ "spinner--lg"
    assert first =~ ~s(data-slot="spinner-icon")
    [_, first_id] = Regex.run(~r/<linearGradient\s+id="([^"]+)-1"/, first)
    [_, second_id] = Regex.run(~r/<linearGradient\s+id="([^"]+)-1"/, second)
    refute first_id == second_id
    assert first =~ "url(##{first_id}-1)"

    decorative = render_component(&HeroUI.spinner/1, %{decorative: true})
    assert decorative =~ ~s(aria-hidden="true")
    refute decorative =~ ~s(role="status")
  end

  test "typography uses semantic tags while supporting visual overrides" do
    slot = [%{inner_block: fn _, _ -> "Hello" end}]
    heading = render_component(&HeroUI.typography/1, %{type: "h2", inner_block: slot})
    assert heading =~ "<h2 "
    assert heading =~ "typography--h2"

    body =
      render_component(&HeroUI.typography/1, %{
        type: "body-sm",
        as: "span",
        color: "muted",
        align: "end",
        weight: "medium",
        truncate: true,
        inner_block: slot
      })

    assert body =~ "<span "
    assert body =~ "typography--body-sm"
    assert body =~ "typography--color-muted"
    assert body =~ "typography--align-end"
    assert body =~ "typography--weight-medium"
    assert body =~ "typography--truncate"

    assert render_component(&HeroUI.typography_prose/1, %{inner_block: slot}) =~
             ~s(data-slot="prose")

    assert_raise ArgumentError, ~r/invalid typography/, fn ->
      render_component(&HeroUI.typography/1, %{type: "body", as: "script", inner_block: slot})
    end
  end

  test "pending buttons stay focusable and cannot act as submit buttons" do
    content = [%{inner_block: fn _, _ -> "Save" end}]

    html =
      render_component(&HeroUI.button/1, %{pending: true, type: "submit", inner_block: content})

    assert html =~ ~s(type="button")
    assert html =~ ~s(aria-disabled="true")
    assert html =~ ~s(aria-busy="true")
    assert html =~ ~s(data-pending="true")
    assert html =~ ~s(data-slot="button")
    assert html =~ ~s(x-data="{}")
    refute html =~ ~r/<button[^>]*\sdisabled(?:=|\s|>)/

    normal =
      render_component(&HeroUI.button/1, %{
        type: "submit",
        inner_block: content,
        rest: %{"data-slot" => "custom-button"}
      })

    assert normal =~ ~s(type="submit")
    assert normal =~ ~s(data-slot="custom-button")
    refute normal =~ ~s(data-pending="true")
  end

  test "button groups apply shared defaults and allow individual overrides" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <HeroUI.button_group label="Actions" variant="secondary" size="sm" disabled show_separators>
        <:button on_click="action" value="copy">Copy</:button>
        <:button disabled={false} variant="outline" on_click="action" value="paste">Paste</:button>
      </HeroUI.button_group>
      """)

    assert html =~ ~s(data-slot="button-group")
    assert html =~ ~s(aria-label="Actions")
    assert html =~ "button--secondary"
    assert html =~ "button--outline"
    assert length(Regex.scan(~r/button--sm/, html)) == 2
    assert length(Regex.scan(~r/<button[^>]*\sdisabled(?:=|\s|>)/s, html)) == 1
    assert length(Regex.scan(~r/data-slot="button-group-separator"/, html)) == 1
    assert html =~ ~s(phx-click="action")
    assert html =~ ~s(value="paste")
  end

  test "card supports HeroUI variants and composable sections" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <HeroUI.card
        variant="secondary"
        heading_level={2}
        header_class="gap-1"
        id="profile-card"
        role="article"
        aria-labelledby="profile-title"
      >
        <:title id="profile-title" class="font-semibold">Profile</:title>
        <:description>Account details</:description>
        <:content class="gap-2">
          <p>Body content</p>
        </:content>
        <:footer><button type="button">Save</button></:footer>
      </HeroUI.card>
      """)

    assert html =~ ~s(id="profile-card")
    assert html =~ ~s(aria-labelledby="profile-title")
    assert html =~ ~s(id="profile-title")
    assert html =~ "card--secondary"
    assert html =~ ~s(data-slot="card-header")
    assert html =~ ~r/<h2[^>]*data-slot="card-title"[^>]*>\s*Profile\s*<\/h2>/s
    assert html =~ ~s(data-slot="card-description")
    assert html =~ ~s(data-slot="card-content")
    assert html =~ ~s(data-slot="card-footer")
    assert html =~ "Body content"

    legacy =
      render_component(&HeroUI.card/1, %{
        inner_block: [%{inner_block: fn _, _ -> Phoenix.HTML.raw("<p>Legacy content</p>") end}]
      })

    assert legacy =~ "card--default"
    assert legacy =~ "<p>Legacy content</p>"
    refute legacy =~ ~s(data-slot="card-content")
  end

  test "close button provides an accessible default and accepts custom icons" do
    default = render_component(&HeroUI.close_button/1, %{})
    assert default =~ ~s(type="button")
    assert default =~ ~s(aria-label="Close")
    assert default =~ ~s(data-slot="close-button-icon")
    assert default =~ "close-button--default"

    custom =
      render_component(&HeroUI.close_button/1, %{
        disabled: true,
        rest: %{"aria-label" => "Dismiss notification", "data-slot" => "custom-close"},
        inner_block: [
          %{inner_block: fn _, _ -> Phoenix.HTML.raw("<svg data-custom-icon></svg>") end}
        ]
      })

    assert custom =~ ~s(aria-label="Dismiss notification")
    assert custom =~ ~s(data-slot="custom-close")
    assert custom =~ ~s(disabled)
    assert custom =~ "data-custom-icon"
    refute custom =~ ~s(data-slot="close-button-icon")
  end

  test "fieldset labels its group, combines descriptions, and disables native controls" do
    html =
      render_component(&HeroUI.fieldset/1, %{
        id: "profile",
        legend: "Profile",
        description: "Public details",
        disabled: true,
        rest: %{"aria-describedby" => "additional-help"},
        inner_block: [%{inner_block: fn _, _ -> Phoenix.HTML.raw("<input name=\"name\">") end}],
        actions: [%{inner_block: fn _, _ -> "Save" end}]
      })

    assert html =~ ~s(<fieldset id="profile" disabled)
    assert html =~ ~s(aria-describedby="additional-help profile-description")

    assert html =~
             ~r/<legend class="fieldset__legend" data-slot="fieldset-legend">\s*Profile\s*<\/legend>/

    assert html =~ ~s(id="profile-description")
    assert html =~ ~s(data-slot="fieldset-field-group")
    assert html =~ ~s(data-slot="fieldset-actions")

    custom =
      render_component(&HeroUI.fieldset/1, %{
        id: "custom",
        legend_content: [%{inner_block: fn _, _ -> "Custom legend" end}],
        inner_block: [%{inner_block: fn _, _ -> "Fields" end}]
      })

    assert custom =~ "Custom legend"

    assert_raise ArgumentError, ~r/requires a legend/, fn ->
      render_component(&HeroUI.fieldset/1, %{
        id: "missing",
        inner_block: [%{inner_block: fn _, _ -> "" end}]
      })
    end
  end

  test "sheet renders labelled modal content, placement, and snap configuration" do
    html =
      render_component(&HeroUI.sheet/1, %{
        id: "details",
        title: "Details",
        description: "More information",
        placement: "right",
        detached: true,
        snap_points: [200, "50%"],
        open: false,
        on_open_change: "sheet_change",
        inner_block: [%{inner_block: fn _, _ -> "Sheet body" end}],
        footer: [%{inner_block: fn _, _ -> "Footer" end}]
      })

    assert html =~ ~s(<dialog id="details")
    assert html =~ ~s(aria-labelledby="details-title")
    assert html =~ ~s(aria-describedby="details-description")
    assert html =~ ~s(data-placement="right")
    assert html =~ ~s(data-detached="true")
    assert html =~ ~s(data-controlled="true")
    assert html =~ ~s(data-controlled-open="false")
    assert html =~ ~s(data-snap-points-json="[200,&quot;50%&quot;]")
    assert html =~ ~s(phx-click="sheet_change")
    assert html =~ ~s(x-data="heroSheet")
    assert html =~ ~s|x-on:touchmove="touchmove($event)"|
    assert html =~ "Sheet body"
    assert html =~ "Footer"

    assert_raise ArgumentError, ~r/snap points/, fn ->
      render_component(&HeroUI.sheet/1, %{
        id: "bad",
        title: "Bad",
        snap_points: ["bad"],
        inner_block: [%{inner_block: fn _, _ -> "" end}]
      })
    end

    assert_raise ArgumentError, ~r/snap points/, fn ->
      render_component(&HeroUI.sheet/1, %{
        id: "bad",
        title: "Bad",
        snap_points: ["0px"],
        inner_block: [%{inner_block: fn _, _ -> "" end}]
      })
    end

    assert_raise ArgumentError, ~r/cannot use open and default_open/, fn ->
      render_component(&HeroUI.sheet/1, %{
        id: "bad",
        title: "Bad",
        open: false,
        default_open: true,
        inner_block: [%{inner_block: fn _, _ -> "" end}]
      })
    end
  end

  test "switches connect descriptions and errors and switch groups preserve independent controls" do
    switch =
      render_component(&HeroUI.switch/1, %{
        id: "news",
        name: "news",
        checked: true,
        description: "Account activity",
        errors: ["is unavailable"],
        label_position: "start",
        inner_block: [%{inner_block: fn _, _ -> "Updates" end}]
      })

    assert switch =~ ~s(role="switch")
    assert switch =~ ~s(aria-labelledby="news-label")
    assert switch =~ ~s(aria-describedby="news-description news-errors")
    assert switch =~ ~s(aria-invalid="true")
    assert switch =~ "-order-1"
    assert switch =~ "Account activity"

    group =
      render_component(&HeroUI.switch_group/1, %{
        id: "preferences",
        label: "Preferences",
        description: "Control updates",
        orientation: "horizontal",
        disabled: true,
        inner_block: [%{inner_block: fn _, _ -> Phoenix.HTML.raw(switch) end}]
      })

    assert group =~ "switch-group--horizontal"
    assert group =~ ~s(data-slot="switch-group-items")
    assert group =~ ~s(aria-describedby="preferences-description")
    assert group =~ ~r/<fieldset[^>]*disabled/
    assert group =~ "Preferences"
    assert group =~ ~s(name="news")

    assert_raise ArgumentError, ~r/requires an id/, fn ->
      render_component(&HeroUI.switch_group/1, %{
        description: "Missing id",
        inner_block: [%{inner_block: fn _, _ -> "" end}]
      })
    end
  end

  test "switch binds a Phoenix field and permits an accessible name without visible text" do
    form = Phoenix.Component.to_form(%{"updates" => "true"}, as: :account)

    html =
      render_component(&HeroUI.switch/1, %{
        field: form[:updates],
        rest: %{"aria-label" => "Email updates", "aria-describedby" => "external-help"},
        description: "News and updates"
      })

    assert html =~ ~s(id="account_updates")
    assert html =~ ~s(name="account[updates]")
    assert html =~ ~r/<input[^>]*checked/
    assert html =~ ~s(aria-label="Email updates")
    refute html =~ ~s(aria-labelledby="account_updates-label")
    assert html =~ ~s(aria-describedby="external-help account_updates-description")
    assert html =~ ~s(data-slot="switch-control")

    unchecked =
      render_component(&HeroUI.switch/1, %{
        field: form[:updates],
        checked: false,
        rest: %{"aria-label" => "Email updates"}
      })

    refute unchecked =~ ~r/<input[^>]*\schecked(?:\s|>|=)/

    assert_raise ArgumentError, ~r/requires a label/, fn ->
      render_component(&HeroUI.switch/1, %{id: "unlabelled"})
    end

    assert_raise ArgumentError, ~r/requires an id or field/, fn ->
      render_component(&HeroUI.switch/1, %{rest: %{"aria-label" => "Missing id"}})
    end
  end

  test "read-only switches preserve native form controls and expose aria state" do
    slot = [%{inner_block: fn _, _ -> "Locked" end}]

    readonly =
      render_component(&HeroUI.switch/1, %{
        id: "locked",
        name: "locked",
        checked: true,
        read_only: true,
        inner_block: slot
      })

    assert readonly =~ ~s(aria-readonly="true")
    assert readonly =~ ~s(data-readonly="true")
    assert readonly =~ ~s(name="locked")
    assert readonly =~ ~r/<input[^>]*checked/
    refute readonly =~ ~r/<input[^>]*\sdisabled(?:\s|>|=)/
    assert readonly =~ "x-on:click.capture"

    external =
      render_component(&HeroUI.switch/1, %{
        id: "external",
        rest: %{"aria-label" => "Locked", "aria-readonly" => "true"}
      })

    assert external =~ ~s(data-readonly="true")
  end

  test "autocomplete keeps a native form control and renders searchable enhancement" do
    form = Phoenix.Component.to_form(%{"country" => "jp"}, as: :trip)

    html =
      render_component(&HeroUI.autocomplete/1, %{
        field: form[:country],
        label: "Destination",
        options: [{"Japan", "jp"}, [key: "France", value: "fr", disabled: true]],
        description: "Choose a destination",
        required: true,
        clearable: true
      })

    assert html =~ ~s(name="trip[country]")
    assert html =~ ~s(selected value="jp")
    assert html =~ ~s(disabled value="fr")
    assert html =~ ~s(aria-describedby="trip_country-description")
    assert html =~ ~s(data-hero-autocomplete-native)
    assert html =~ ~s(data-hero-autocomplete-search)
    assert html =~ ~s(data-hero-autocomplete-clear)
    assert html =~ ~s(x-data="heroAutocomplete")
    assert html =~ ~s|x-on:reset.document="reset($event)"|
    assert html =~ ~s(popover="auto")

    multiple =
      render_component(&HeroUI.autocomplete/1, %{
        id: "places",
        name: "places",
        label: "Places",
        options: [{"Japan", "jp"}, {"Spain", "es"}],
        selection_mode: "multiple",
        value: ["jp", "es"]
      })

    assert multiple =~ ~s(name="places[]")
    assert multiple =~ ~s(aria-multiselectable="true")
    assert multiple =~ ~s(selected value="jp")
    assert multiple =~ ~s(selected value="es")

    assert_raise ArgumentError, ~r/requires a list value/, fn ->
      render_component(&HeroUI.autocomplete/1, %{
        id: "bad",
        label: "Bad",
        options: [],
        selection_mode: "multiple",
        value: "jp"
      })
    end
  end

  test "scroll shadows render automatic and controlled fade configurations" do
    content = [%{inner_block: fn _, _ -> "Scrollable content" end}]

    auto =
      render_component(&HeroUI.scroll_shadow/1, %{
        id: "feed",
        inner_block: content,
        class: "max-h-48",
        on_visibility_change: "edges"
      })

    assert auto =~ ~s(data-scroll-shadow-mode="auto")
    assert auto =~ ~s(x-data="heroScrollShadow")
    assert auto =~ ~s|x-on:phx:update.window="schedule()"|
    assert auto =~ ~s|x-on:scroll="schedule()"|
    assert auto =~ "scroll-shadow--vertical"
    assert auto =~ "scroll-shadow--fade"
    assert auto =~ ~s(data-scroll-shadow-size="40")
    assert auto =~ ~s(phx-click="edges")
    assert auto =~ "Scrollable content"
    refute auto =~ ~s(style=)

    manual =
      render_component(&HeroUI.scroll_shadow/1, %{
        inner_block: content,
        orientation: "horizontal",
        visibility: "both",
        size: 60,
        offset: 8,
        hide_scrollbar: true
      })

    assert manual =~ "scroll-shadow--horizontal"
    assert manual =~ "scroll-shadow--hide-scrollbar"
    assert manual =~ ~s(data-scroll-shadow-mode="manual")
    assert manual =~ ~s(data-left-right-scroll="true")
    assert manual =~ "--scroll-shadow-size: 60px"
    assert manual =~ "--scroll-shadow-offset: 8px"

    disabled =
      render_component(&HeroUI.scroll_shadow/1, %{
        inner_block: content,
        visibility: "both",
        enabled: false
      })

    assert disabled =~ ~s(data-scroll-shadow-mode="manual")
    refute disabled =~ ~s(data-top-bottom-scroll="true")

    assert_raise ArgumentError, ~r/non-negative integers/, fn ->
      render_component(&HeroUI.scroll_shadow/1, %{inner_block: content, size: -1})
    end
  end

  test "time field renders native form values and validation semantics" do
    form = Phoenix.Component.to_form(%{"starts_at" => "09:30"}, as: :meeting)

    html =
      render_component(&HeroUI.time_field/1, %{
        field: form[:starts_at],
        label: "Starts at",
        min: "09:00",
        max: ~T[17:00:00],
        description: "Office hours",
        errors: ["is too early"],
        required: true,
        hour_cycle: 24,
        granularity: "second"
      })

    assert html =~ ~s(type="time")
    assert html =~ ~s(name="meeting[starts_at]")
    assert html =~ ~s(value="09:30")
    assert html =~ ~s(min="09:00:00")
    assert html =~ ~s(max="17:00:00")
    assert html =~ ~s(step="1")
    assert html =~ ~s(data-hour-cycle="24")
    assert html =~ ~s(x-data="heroTimeField")
    assert html =~ ~s|x-on:reset.document="reset($event)"|
    assert html =~ ~s(aria-invalid="true")
    assert html =~ ~s(aria-describedby="meeting_starts_at-description meeting_starts_at-errors")
    assert html =~ "is too early"

    assert_raise ArgumentError, ~r/min must not exceed max/, fn ->
      render_component(&HeroUI.time_field/1, %{
        id: "invalid",
        label: "Time",
        min: "18:00",
        max: "09:00"
      })
    end

    assert_raise ArgumentError, ~r/bounds must be ISO 8601 times/, fn ->
      render_component(&HeroUI.time_field/1, %{id: "invalid", label: "Time", min: "25:00"})
    end
  end

  test "avatar groups inherit styles, limit visible avatars, and expose a count" do
    people = [
      %{name: "Jane Doe"},
      %{name: "Alex Kim", color: "success"},
      %{name: "Morgan Lee"}
    ]

    html =
      render_component(&HeroUI.avatar_group/1, %{
        avatar: people,
        size: "lg",
        color: "accent",
        variant: "soft",
        max: 2,
        role: "group",
        "aria-label": "Project team"
      })

    assert html =~ ~s(role="group")
    assert html =~ ~s(aria-label="Project team")
    assert html =~ "avatar-group--clip"
    assert html =~ "avatar--lg"
    assert html =~ "avatar--soft"
    assert html =~ "avatar__fallback--accent"
    assert html =~ "avatar__fallback--success"
    assert html =~ ~s(aria-label="Jane Doe")
    refute html =~ ~s(aria-label="Morgan Lee")
    assert html =~ ~s(aria-label="1 more")
    assert html =~ "+1"

    custom =
      render_component(&HeroUI.avatar_group/1, %{
        avatar: people,
        max: 1,
        grid: true,
        count: [%{label: "Nine more reviewers", inner_block: fn _, _ -> "+9" end}]
      })

    assert custom =~ "avatar-group--grid"
    refute custom =~ "avatar-group--clip"
    assert custom =~ ~s(aria-label="Nine more reviewers")
    assert custom =~ "+9"
    refute custom =~ "+2"

    none = render_component(&HeroUI.avatar_group/1, %{avatar: people, max: 0, overlap: "ring"})
    assert none =~ "avatar-group--ring"
    assert none =~ ~s(aria-label="3 more")
    refute none =~ ~s(aria-label="Jane Doe")

    assert_raise ArgumentError, ~r/non-negative integer/, fn ->
      render_component(&HeroUI.avatar_group/1, %{avatar: people, max: -1})
    end
  end

  test "disclosures render native state, accessible content, and disabled triggers" do
    html =
      render_component(&HeroUI.disclosure/1, %{
        id: "details",
        title: "Details",
        open: true,
        disabled: true,
        inner_block: [%{inner_block: fn _, _ -> "More information" end}]
      })

    assert html =~ ~s(id="details")
    assert html =~ ~s(aria-controls="details-content")
    assert html =~ ~s(aria-labelledby="details-trigger")
    assert html =~ ~s(aria-expanded="true")
    assert html =~ ~s(x-data="heroDisclosure")
    assert html =~ ~s|x-bind:phx-value-expanded="(!expanded).toString()"|
    assert html =~ ~s(aria-disabled="true")
    assert html =~ ~s(tabindex="-1")
    assert html =~ "More information"
    assert html =~ ~r/<details[^>]*\sopen(?:=|\s|>)/
  end

  test "disclosure groups enforce unique keys and support exclusive or multiple expansion" do
    items = [
      %{key: "one", title: "One", inner_block: fn _, _ -> "First" end},
      %{key: "two", title: "Two", inner_block: fn _, _ -> "Second" end}
    ]

    html =
      render_component(&HeroUI.disclosure_group/1, %{
        id: "group",
        item: items,
        expanded_keys: ["one"],
        on_toggle: "toggle"
      })

    assert length(Regex.scan(~r/name="group-disclosure-group"/, html)) == 2
    assert length(Regex.scan(~r/<details[^>]*\sopen(?:=|\s|>)/, html)) == 1
    assert html =~ ~s(phx-value-key="one")
    assert html =~ ~s(phx-click="toggle")

    multiple =
      render_component(&HeroUI.disclosure_group/1, %{
        id: "multiple",
        item: items,
        allows_multiple_expanded: true,
        default_expanded_keys: ["one", "two"]
      })

    assert length(Regex.scan(~r/<details[^>]*\sopen(?:=|\s|>)/, multiple)) == 2
    refute multiple =~ ~s(name="multiple-disclosure-group")

    assert_raise ArgumentError, ~r/keys must be unique/, fn ->
      render_component(&HeroUI.disclosure_group/1, %{
        id: "duplicate",
        item: [hd(items), hd(items)]
      })
    end

    assert_raise ArgumentError, ~r/at most one expanded key/, fn ->
      render_component(&HeroUI.disclosure_group/1, %{
        id: "exclusive",
        item: items,
        expanded_keys: ["one", "two"]
      })
    end
  end

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
    assert html =~ ~s(aria-describedby="email-errors")
    assert html =~ ~s(class="textfield textfield--full-width)
    assert html =~ ~s(data-invalid="true")
    assert html =~ ~s(data-slot="field-error")
    assert html =~ "is invalid"

    multiline =
      render_component(&HeroUI.text_field/1, %{
        id: "bio",
        name: "bio",
        label: "Biography",
        value: "Hello",
        multiline: true,
        description: "Tell us more",
        rest: %{"rows" => 4, "required" => true, "aria-describedby" => "extra-help"}
      })

    assert multiline =~ "<textarea"
    assert multiline =~ ~s(rows="4")
    assert multiline =~ ~s(data-required="true")
    assert multiline =~ ~s(aria-describedby="extra-help bio-description")
    assert multiline =~ "Hello</textarea>"

    accessible =
      render_component(&HeroUI.text_field/1, %{id: "search", rest: %{"aria-label" => "Search"}})

    assert accessible =~ ~s(aria-label="Search")

    assert_raise ArgumentError, ~r/requires a label/, fn ->
      render_component(&HeroUI.text_field/1, %{id: "unlabelled"})
    end
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
    assert html =~ ~s(x-data="heroInputGroup")
    assert html =~ ~s|x-on:click="focusInput($event)"|

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
    assert html =~ ~s(x-data="heroSearchField")
    assert html =~ ~s|x-on:click="clear()"|
    assert html =~ ~s(x-bind:disabled="empty || locked")
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
    assert html =~ ~s(x-data="heroInputOTP")
    assert html =~ ~s|x-on:compositionend="onInput($event)"|

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
        selection_mode: "single",
        selected: ["news", "travel"]
      })
    end
  end

  test "tag group customizes remove buttons per tag without changing removal semantics" do
    tags = [%{value: "news", label: "News"}, %{value: "travel", label: "Travel", disabled: true}]

    html =
      render_component(&HeroUI.tag_group/1, %{
        id: "topics-custom",
        label: "Topics",
        tag: tags,
        on_remove: "remove",
        remove_button: [
          %{
            value: "news",
            label: "Delete news",
            class: "custom-remove",
            inner_block: fn _, _ -> "Custom icon" end
          },
          %{value: "removed", label: "Removed item"}
        ]
      })

    assert html =~ ~s(aria-label="Delete news")
    assert html =~ "custom-remove"
    assert html =~ "Custom icon"
    assert html =~ ~s(aria-label="Remove Travel")
    assert html =~ ~r/<button\b[^>]*aria-label="Delete news"[^>]*phx-click="remove"/s
    assert html =~ ~r/<button\b[^>]*aria-label="Remove Travel"[^>]*disabled/s

    label_only =
      render_component(
        fn assigns ->
          ~H"""
          <HeroUI.tag_group id="label-only" label="Topics" on_remove="remove">
            <:tag value="news" label="News" />
            <:remove_button value="news" label="Delete news" />
          </HeroUI.tag_group>
          """
        end,
        %{}
      )

    assert label_only =~ ~s(aria-label="Delete news")
    assert label_only =~ ~s(<svg aria-hidden="true")

    no_remove =
      render_component(&HeroUI.tag_group/1, %{
        id: "no-remove",
        label: "Topics",
        tag: tags,
        remove_button: [%{value: "news", label: "Delete news"}]
      })

    refute no_remove =~ "data-hero-tag-remove"

    assert_raise ArgumentError, ~r/remove button values must be unique/, fn ->
      render_component(&HeroUI.tag_group/1, %{
        id: "duplicate",
        label: "Topics",
        tag: tags,
        remove_button: [%{value: "news"}, %{value: "news"}]
      })
    end

    assert_raise ArgumentError, ~r/remove button labels must not be empty/, fn ->
      render_component(&HeroUI.tag_group/1, %{
        id: "blank",
        label: "Topics",
        tag: tags,
        remove_button: [%{value: "news", label: " "}]
      })
    end
  end

  test "tag group accepts LiveView JS commands for selection and removal" do
    html =
      render_component(&HeroUI.tag_group/1, %{
        id: "languages",
        label: "Languages",
        tag: [%{value: "elixir", label: "Elixir"}],
        selection_mode: "multiple",
        on_select: Phoenix.LiveView.JS.push("select_tag"),
        on_remove: Phoenix.LiveView.JS.push("remove_tag")
      })

    assert html =~ "select_tag"
    assert html =~ "remove_tag"
    assert html =~ ~s(phx-value-value="elixir")
    assert html =~ ~s(aria-keyshortcuts="Delete Backspace")
  end

  test "tag group supports controlled keys and uncontrolled defaults" do
    tags = [%{value: "news", label: "News"}, %{value: "travel", label: "Travel"}]

    uncontrolled =
      render_component(&HeroUI.tag_group/1, %{
        id: "topics-local",
        label: "Topics",
        tag: tags,
        selection_mode: "multiple",
        default_selected_keys: ["news"],
        on_selection_change: Phoenix.LiveView.JS.push("changed")
      })

    assert uncontrolled =~ ~s(data-controlled="false")
    assert uncontrolled =~ "topics-local-selection-event"
    assert uncontrolled =~ "changed"
    assert uncontrolled =~ ~r/aria-label="News"[^>]*aria-selected="true"/s

    controlled =
      render_component(&HeroUI.tag_group/1, %{
        id: "topics-control",
        label: "Topics",
        tag: tags,
        selection_mode: "single",
        selected_keys: ["travel"],
        on_selection_change: "changed"
      })

    assert controlled =~ ~s(data-controlled="true")
    assert controlled =~ ~r/aria-label="Travel"[^>]*aria-selected="true"/s

    legacy =
      render_component(&HeroUI.tag_group/1, %{
        id: "topics-legacy",
        label: "Topics",
        tag: tags,
        selection_mode: "multiple",
        on_select: "select"
      })

    assert legacy =~ ~s(data-controlled="true")
    assert legacy =~ ~s(phx-click="select")

    assert_raise ArgumentError, ~r/selected or selected_keys/, fn ->
      render_component(&HeroUI.tag_group/1, %{
        id: "bad",
        label: "Bad",
        tag: tags,
        selected: [],
        selected_keys: []
      })
    end

    assert_raise ArgumentError, ~r/unique strings/, fn ->
      render_component(&HeroUI.tag_group/1, %{
        id: "bad",
        label: "Bad",
        tag: tags,
        default_selected_keys: ["news", "news"]
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
    default = render_component(&HeroUI.progress_bar/1, %{label: "Loading"})
    assert default =~ ~s(aria-valuenow="0")

    indeterminate =
      render_component(&HeroUI.progress_bar/1, %{label: "Loading", indeterminate: true})

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

  test "accordion groups render keyed panels and controlled expansion" do
    assigns = %{}

    heex =
      rendered_to_string(~H"""
      <HeroUI.accordion id="heex-example">
        <:item key="first" title="First">First panel</:item>
        <:item key="second" title="Second">Second panel</:item>
      </HeroUI.accordion>
      """)

    assert heex =~ "First panel"

    items = [
      %{key: "orders", title: "Orders", inner_block: fn _, _ -> "Order details" end},
      %{
        key: "returns",
        title: "Returns",
        disabled: true,
        inner_block: fn _, _ -> "Return details" end
      }
    ]

    html =
      render_component(&HeroUI.accordion/1, %{
        id: "faq",
        item: items,
        expanded_keys: ["orders"],
        on_expanded_change: "faq_change",
        variant: "surface",
        hide_separator: true,
        heading_level: 2
      })

    assert html =~ ~s(data-controlled="true")
    assert html =~ ~s(data-expanded-keys="[&quot;orders&quot;]")
    assert html =~ ~s(aria-expanded="true")
    assert html =~ ~s(aria-controls="faq-panel-b3JkZXJz")
    assert html =~ ~r/<div[^>]*data-key="returns"[^>]*\sinert/s
    assert html =~ ~s(data-hide-separator="true")
    assert html =~ ~s(phx-click="faq_change")
    assert html =~ "accordion--surface"
    assert html =~ "<h2"
    assert html =~ ~s(x-data="heroAccordion")

    assert_raise ArgumentError, ~r/at most one/, fn ->
      render_component(&HeroUI.accordion/1, %{
        id: "faq",
        item: items,
        default_expanded_keys: ["orders", "returns"]
      })
    end

    assert_raise ArgumentError, ~r/distinct item keys/, fn ->
      render_component(&HeroUI.accordion/1, %{
        id: "faq",
        item: items,
        expanded_keys: ["missing"]
      })
    end
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
    assert html =~ ~s(x-data="heroComboBox")
    assert html =~ ~s|x-on:input="input($event)"|
    assert html =~ ~s|x-on:reset.window="reset($event)"|
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

  test "toolbars expose labelled orientation and attached styling" do
    inner = [%{inner_block: fn _, _ -> "Actions" end}]

    html =
      render_component(&HeroUI.toolbar/1, %{
        id: "tools",
        label: "Editing",
        orientation: "vertical",
        attached: true,
        inner_block: inner
      })

    assert html =~ ~s(role="toolbar")
    assert html =~ ~s(aria-label="Editing")
    assert html =~ ~s(aria-orientation="vertical")
    assert html =~ "toolbar--vertical"
    assert html =~ "toolbar--attached"
    assert html =~ "data-hero-toolbar"
    assert html =~ ~s(x-data="heroToolbar")
    assert html =~ ~s|x-on:keydown="onKeyDown($event)"|
    assert html =~ "Actions"

    assert_raise ArgumentError, fn ->
      render_component(&HeroUI.toolbar/1, %{inner_block: inner})
    end
  end

  test "color fields expose normalized hex input and bounded channel input" do
    form = Phoenix.Component.to_form(%{"color" => "#abc"}, as: :theme)

    html =
      render_component(&HeroUI.color_field/1, %{
        field: form[:color],
        label: "Brand color",
        description: "Enter a color",
        required: true
      })

    assert html =~ ~s(name="theme[color]")
    assert html =~ ~s(value="#AABBCC")
    assert html =~ ~s(aria-describedby="theme_color-description")
    assert html =~ ~s(data-hero-color-preview)
    assert html =~ ~s(data-channel="hex")
    assert html =~ ~s(x-data="heroColorField")
    assert html =~ ~s|x-on:submit.window.capture="submit($event)"|
    assert html =~ "pattern=\"#?([0-9A-Fa-f]{3}|[0-9A-Fa-f]{6})\""

    alpha =
      render_component(&HeroUI.color_field/1, %{
        id: "alpha",
        label: "Alpha color",
        value: "#abcd",
        allow_alpha: true
      })

    assert alpha =~ ~s(value="#AABBCCDD")

    channel =
      render_component(&HeroUI.color_field/1, %{
        id: "hue",
        label: "Hue",
        channel: "hue",
        value: 120
      })

    assert channel =~ ~s(type="number")
    assert channel =~ ~s(min="0")
    assert channel =~ ~s(max="360")
    refute channel =~ ~s(data-hero-color-preview)

    invalid =
      render_component(&HeroUI.color_field/1, %{
        id: "bad-color",
        label: "Color",
        value: "invalid",
        errors: ["Invalid color"]
      })

    assert invalid =~ ~s(value="invalid")
    assert invalid =~ "Invalid color"
    assert invalid =~ "#E4E4E7"
  end

  test "color swatches and palettes expose native, labelled form controls" do
    swatch =
      render_component(&HeroUI.color_swatch/1, %{
        color: "#ff000080",
        label: "Translucent red",
        size: "lg",
        shape: "square"
      })

    assert swatch =~ "color-swatch--square"
    assert swatch =~ "color-swatch--lg"
    assert swatch =~ ~s(aria-label="Translucent red")
    assert swatch =~ "--color-swatch-current: #ff000080"

    form = Phoenix.Component.to_form(%{"accent" => "#8B5CF6"}, as: :theme)

    options = [
      %{value: "#8B5CF6", label: "Purple"},
      %{value: "#FACC15", label: "Yellow", disabled: true}
    ]

    html =
      render_component(&HeroUI.color_swatch_picker/1, %{
        field: form[:accent],
        label: "Accent",
        description: "Pick one",
        required: true,
        option: options
      })

    assert html =~ ~s(name="theme[accent]")
    assert html =~ ~s(aria-label="Purple")
    assert html =~ ~s(aria-label="Yellow")
    assert html =~ ~s(aria-describedby="theme_accent-description")
    assert html =~ ~s(data-light-color="true")
    assert html =~ ~r/value="#8B5CF6"[^>]*checked/
    assert html =~ ~r/value="#FACC15"[^>]*disabled/

    equivalent =
      render_component(&HeroUI.color_swatch_picker/1, %{
        id: "equivalent",
        label: "Accent",
        value: "#8b5cf6ff",
        option: options
      })

    assert equivalent =~ ~r/value="#8B5CF6"[^>]*checked/

    assert_raise ArgumentError, fn ->
      render_component(&HeroUI.color_swatch_picker/1, %{
        id: "dup",
        label: "Colors",
        option: [hd(options), hd(options)]
      })
    end

    assert_raise ArgumentError, fn ->
      render_component(&HeroUI.color_swatch/1, %{color: "red; background: url(evil)"})
    end
  end

  test "toast region exposes placement and queue settings" do
    html =
      render_component(&HeroUI.toast_region/1, %{
        id: "alerts",
        placement: "top-end",
        max_visible: 2,
        timeout: 0,
        width: 360
      })

    assert html =~ ~s(class="toast-region toast-region--top-end")
    assert html =~ ~s(data-max-visible="2")
    assert html =~ ~s(data-timeout="0")
    assert html =~ ~s(--toast-width: 360px)
    assert html =~ ~s(role="region")
    assert html =~ ~s(phx-update="ignore")
    assert html =~ ~s(x-for="item in items")
    assert html =~ ~s|x-bind:phx-click="actionCommand(item)"|
    assert html =~ ~s(data-slot="spinner")

    assigns = %{}

    custom =
      rendered_to_string(~H"""
      <HeroUI.toast_region id="custom-toasts">
        <:indicator name="star"><span>★</span></:indicator>
      </HeroUI.toast_region>
      """)

    assert custom =~ "data-indicators=\"[&quot;star&quot;]\""
    assert custom =~ "<span>★</span>"

    assert_raise ArgumentError, ~r/indicator names/, fn ->
      render_component(&HeroUI.toast_region/1, %{
        id: "invalid-indicators",
        indicator: [%{name: "bad name", inner_block: fn _, _ -> "!" end}]
      })
    end

    assert_raise ArgumentError, fn ->
      render_component(&HeroUI.toast_region/1, %{id: "bad", max_visible: 0})
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

  test "date picker renders a single form value and a detached calendar" do
    form = Phoenix.Component.to_form(%{"day" => "2026-10-15"}, as: :event)

    html =
      render_component(&HeroUI.date_picker/1, %{
        field: form[:day],
        label: "Event date",
        min: ~D[2026-09-01],
        max: ~D[2026-12-31],
        unavailable_dates: [~D[2026-10-18]],
        required: true
      })

    assert length(Regex.scan(~r/name="event\[day\]"/, html)) == 1
    assert html =~ ~s(data-hero-date-picker-trigger)
    assert html =~ ~s(aria-controls="event_day-picker-popover")
    assert html =~ ~s(form="event_day-picker-detached")
    assert html =~ ~s(data-hero-calendar)
    assert html =~ "2026-10-18"
    assert html =~ ~s(value="2026-10-15")
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

  test "chips wrap plain text and support composed leading and trailing content" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <HeroUI.chip color="success" title="Published status">
        <:prefix><svg data-test-icon="leading" aria-hidden="true"></svg></:prefix>
        Published
        <:suffix><svg data-test-icon="trailing" aria-hidden="true"></svg></:suffix>
      </HeroUI.chip>
      """)

    assert html =~ ~s(data-slot="chip")
    assert html =~ ~s(data-slot="chip-label")
    assert html =~ "chip--secondary"
    assert html =~ "chip--success"
    assert html =~ ~s(title="Published status")

    assert html =~
             ~r/data-test-icon="leading".*data-slot="chip-label".*Published.*data-test-icon="trailing"/s

    composed =
      rendered_to_string(~H"""
      <HeroUI.chip wrap_label={false}>
        <span data-test-custom>Custom</span><HeroUI.chip_label class="font-bold">
          Text
        </HeroUI.chip_label>
      </HeroUI.chip>
      """)

    assert length(Regex.scan(~r/data-slot="chip-label"/, composed)) == 1
    assert composed =~ ~r/data-test-custom.*data-slot="chip-label"/s
    assert composed =~ "font-bold"
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
    assert html =~ ~s(x-data="heroDialog")
    assert html =~ ~s|x-on:cancel="onCancel($event)"|
    assert html =~ "Details"
    assert html =~ "phx-mounted"
  end

  test "modal composes controlled state, placement, backdrop and scroll variants" do
    slot = [%{inner_block: fn _, _ -> "Details" end}]

    html =
      render_component(&HeroUI.modal/1, %{
        id: "settings",
        title: "Settings",
        description: "Change settings.",
        open: true,
        on_open_change: "toggle",
        placement: "top",
        backdrop: "blur",
        scroll: "outside",
        size: "cover",
        show_close: false,
        inner_block: slot
      })

    assert html =~ ~s(data-controlled="true")
    assert html =~ ~s(data-controlled-open="true")
    assert html =~ ~s(data-placement="top")
    assert html =~ ~s(data-backdrop="blur")
    assert html =~ ~s(data-scroll="outside")
    assert html =~ "modal__dialog--cover"
    assert html =~ "modal__body--scroll-outside"
    assert html =~ "backdrop:backdrop-blur-md"
    assert html =~ ~s(aria-describedby="settings-description")
    assert html =~ ~s(phx-click="toggle")
    refute html =~ "data-hero-dialog-close"

    assert_raise ArgumentError, ~r/cannot use open and default_open/, fn ->
      render_component(&HeroUI.modal/1, %{
        id: "bad",
        title: "Bad",
        open: false,
        default_open: true,
        inner_block: slot
      })
    end

    assigns = %{}

    composed =
      rendered_to_string(~H"""
      <HeroUI.modal id="compose" title="Composed" keyboard_dismiss_disabled>
        <:trigger :let={attrs}><HeroUI.button {attrs}>Launch</HeroUI.button></:trigger>
        Content
        <:close :let={attrs}><HeroUI.button {attrs}>Done</HeroUI.button></:close>
      </HeroUI.modal>
      """)

    assert composed =~ ~s(data-keyboard-dismiss-disabled="true")
    assert composed =~ ~s(data-hero-dialog-open="compose")
    assert composed =~ "data-hero-dialog-close"
    assert composed =~ ">Done</button>"
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
    assert html =~ ~s(x-data="heroTabs")
    assert html =~ ~s(data-controlled="false")

    controlled =
      render_component(&HeroUI.tabs/1, %{
        id: "controlled",
        label: "Settings",
        tab: tabs,
        selected_key: "two",
        on_selection_change: "select_tab",
        activation_mode: "manual",
        orientation: "vertical",
        align: "start",
        show_separators: true
      })

    assert controlled =~ ~s(data-selected-key="two")
    assert controlled =~ ~s(data-controlled="true")
    assert controlled =~ ~s(data-activation-mode="manual")
    assert controlled =~ ~s(phx-click="select_tab")
    assert controlled =~ "tabs--align-start"
    assert controlled =~ ~s(data-slot="tabs-separator")

    assert_raise ArgumentError, ~r/cannot be combined/, fn ->
      render_component(&HeroUI.tabs/1, %{
        id: "ambiguous",
        label: "Settings",
        tab: tabs,
        selected_key: "two",
        selected: "two"
      })
    end

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

  test "indeterminate checkbox exposes a mixed state independently of checked" do
    slot = [%{inner_block: fn _, _ -> "Select all" end}]

    mixed =
      render_component(&HeroUI.checkbox/1, %{
        id: "all",
        name: "all",
        checked: true,
        indeterminate: true,
        invalid: true,
        inner_block: slot
      })

    assert mixed =~ ~s(data-indeterminate="true")
    assert mixed =~ ~s(aria-checked="mixed")
    assert mixed =~ ~s(aria-invalid="true")
    assert mixed =~ ~s(name="all")
    assert mixed =~ ~r/<input[^>]*\schecked(?:\s|>|=)/
    assert mixed =~ ~s(data-slot="checkbox-default-indicator--indeterminate")
    refute mixed =~ ~s(data-slot="checkbox-default-indicator--checkmark")

    ordinary = render_component(&HeroUI.checkbox/1, %{id: "one", inner_block: slot})
    refute ordinary =~ ~s(aria-checked="mixed")
    refute ordinary =~ ~s(data-indeterminate="true")
    assert ordinary =~ ~s(data-slot="checkbox-default-indicator--checkmark")
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

  test "dropdown supports selection groups and nested submenus" do
    html =
      render_component(&HeroUI.dropdown/1, %{
        id: "view",
        label: "View",
        on_action: "action",
        section: [
          %{
            label: "Sort",
            selection_mode: "single",
            selected_keys: ["recent"],
            on_selection_change: "sort",
            items: [%{key: "recent", label: "Recent"}, %{key: "old", label: "Old"}]
          },
          %{
            label: "Share",
            items: [
              %{label: "Share via", items: [%{key: "copy", label: "Copy", shortcut: "⌘ C"}]}
            ]
          }
        ]
      })

    assert html =~ ~s(role="menuitemradio")
    assert html =~ ~s(x-data="heroDropdown")
    assert html =~ ~s|x-on:click.capture="click($event)"|
    assert html =~ ~s|x-on:keydown="keydown($event)"|
    assert html =~ ~s|x-on:toggle.capture="toggle($event)"|
    assert html =~ ~s|x-on:scroll.window.capture="reposition()"|
    assert html =~ ~s|x-on:phx:update.document="reposition()"|
    assert html =~ ~r/data-hero-dropdown-submenu-trigger[\s\S]*?phx-mounted=/
    assert html =~ ~s(aria-checked="true")
    assert html =~ ~s(phx-click="sort")
    assert html =~ ~s(phx-click="action")
    assert html =~ ~s(aria-label="Sort")
    assert html =~ ~s(data-hero-dropdown-submenu-trigger)
    assert html =~ ~s(aria-label="Share via")
    assert html =~ "⌘ C"

    assert_raise ArgumentError, ~r/unique nonempty string keys/, fn ->
      render_component(&HeroUI.dropdown/1, %{
        id: "bad",
        label: "Bad",
        selection_mode: "multiple",
        item: [%{key: "same", label: "One"}, %{key: "same", label: "Two"}]
      })
    end

    assert_raise ArgumentError, ~r/at most one selected key/, fn ->
      render_component(&HeroUI.dropdown/1, %{
        id: "bad",
        label: "Bad",
        selection_mode: "single",
        selected_keys: ["one", "two"],
        item: [%{key: "one", label: "One"}, %{key: "two", label: "Two"}]
      })
    end
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
    assert html =~ ~s(x-data="heroSelect")
    assert html =~ ~s|x-on:invalid.capture="invalid($event)"|
    assert html =~ ~s|x-on:phx:update.window="sync()"|
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
    assert alert =~ ~s(x-data="heroDialog")

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
    assert drawer =~ ~s(data-hero-drawer)
    assert drawer =~ ~s(x-data="heroDrawer")
    assert drawer =~ ~s|x-on:cancel.prevent="onCancel()"|
    assert drawer =~ ~s(data-slot="drawer-dialog")
    assert drawer =~ ~s(data-slot="drawer-body")
    assert drawer =~ ~s(data-backdrop="opaque")
    assert drawer =~ "backdrop:bg-backdrop"
    assert drawer =~ ~s(data-controlled="false")
    assert drawer =~ ~s|x-on:pointerdown="pointerDown($event)"|
    assert drawer =~ "touch-pan-y"

    default_drawer =
      render_component(&HeroUI.drawer/1, %{
        id: "default-drawer",
        title: "Default",
        inner_block: slot
      })

    assert default_drawer =~ ~s(data-placement="bottom")

    with_handle =
      render_component(&HeroUI.drawer/1, %{
        id: "handle",
        title: "Handle",
        placement: "bottom",
        show_handle: true,
        inner_block: slot
      })

    assert with_handle =~ ~s(data-slot="drawer-handle")
    assert with_handle =~ "touch-pan-x"
    refute drawer =~ ~s(data-slot="drawer-handle")

    controlled =
      render_component(&HeroUI.drawer/1, %{
        id: "controlled",
        title: "Controlled",
        open: true,
        on_open_change: "drawer_change",
        target: "#settings",
        close_label: "Dismiss",
        inner_block: slot
      })

    assert controlled =~ ~s(data-controlled="true")
    assert controlled =~ ~s(data-controlled-open="true")
    assert controlled =~ ~s(phx-click="drawer_change")
    assert controlled =~ ~s(phx-target="#settings")
    assert controlled =~ ">Dismiss</button>"

    no_close =
      render_component(&HeroUI.drawer/1, %{
        id: "no-close",
        title: "No close",
        show_close: false,
        inner_block: slot
      })

    refute no_close =~ "data-hero-dialog-close"

    assert_raise ArgumentError, ~r/cannot use open and default_open/, fn ->
      render_component(&HeroUI.drawer/1, %{
        id: "bad-drawer",
        title: "Bad",
        open: false,
        default_open: true,
        inner_block: slot
      })
    end

    assigns = %{}

    composed =
      rendered_to_string(~H"""
      <HeroUI.drawer id="custom-close" title="Custom">
        Details
        <:close :let={attrs}><HeroUI.button {attrs}>Done</HeroUI.button></:close>
      </HeroUI.drawer>
      """)

    assert composed =~ "data-hero-dialog-close"
    assert composed =~ ">Done</button>"

    blurred =
      render_component(&HeroUI.drawer/1, %{
        id: "blur",
        title: "Blur",
        backdrop: "blur",
        inner_block: slot
      })

    assert blurred =~ ~s(data-backdrop="blur")
    assert blurred =~ "backdrop:backdrop-blur-md"

    transparent =
      render_component(&HeroUI.drawer/1, %{
        id: "clear",
        title: "Clear",
        backdrop: "transparent",
        inner_block: slot
      })

    assert transparent =~ ~s(data-backdrop="transparent")
    assert transparent =~ "backdrop:bg-transparent"
    refute drawer =~ ~s(data-hero-dialog="")
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

    waiting =
      render_component(&HeroUI.progress_circle/1, %{label: "Waiting", indeterminate: true})

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

  test "progress indicators support accessible track-only and custom output states" do
    track =
      render_component(&HeroUI.progress_bar/1, %{
        value: 45,
        show_value: false,
        rest: %{"aria-label" => "Upload progress", id: "upload-progress"}
      })

    assert track =~ ~s(aria-label="Upload progress")
    assert track =~ ~s(id="upload-progress")
    assert track =~ ~s(aria-valuenow="45")
    assert track =~ ~s(aria-valuetext="45%")
    refute track =~ "progress-bar__output"
    refute track =~ ~s(data-slot="label")

    custom =
      render_component(&HeroUI.progress_bar/1, %{
        label: "Upload",
        value: 5,
        max: 10,
        value_text: "5 of 10 files"
      })

    assert custom =~ ~s(aria-valuetext="5 of 10 files")
    assert custom =~ "5 of 10 files</span>"

    meter =
      render_component(&HeroUI.meter/1, %{
        value: 25,
        show_value: false,
        rest: %{"aria-labelledby" => "capacity-title", "data-slot" => "custom-meter"}
      })

    assert meter =~ ~s(aria-labelledby="capacity-title")
    assert meter =~ ~s(data-slot="custom-meter")
    assert meter =~ ~s(aria-valuetext="25%")
    refute meter =~ "aria-label="
    refute meter =~ "meter__output"

    circle =
      render_component(&HeroUI.progress_circle/1, %{
        label: "Uploading",
        show_label: true,
        value: 75,
        value_text: "Three quarters complete"
      })

    assert circle =~ ~s(aria-valuetext="Three quarters complete")
    assert circle =~ ~s(data-slot="label")
    assert circle =~ "Uploading</span>"

    assert_raise ArgumentError, ~r/provide label/, fn ->
      render_component(&HeroUI.progress_bar/1, %{})
    end
  end

  test "tooltip and popover associate their trigger and content" do
    slot = [%{inner_block: fn _, _ -> "More" end}]

    tooltip =
      render_component(&HeroUI.tooltip/1, %{id: "tip", text: "Helpful text", inner_block: slot})

    assert tooltip =~ ~s(aria-describedby="tip-content")
    assert tooltip =~ ~s(role="tooltip")
    assert tooltip =~ "Helpful text"
    assert tooltip =~ ~s(x-data="heroTooltip")
    assert tooltip =~ ~s(data-requested-placement="top")
    assert tooltip =~ ~s(data-slot="tooltip-content")

    composed =
      render_component(&HeroUI.tooltip/1, %{
        id: "composed-tip",
        show_arrow: true,
        trigger: [
          %{
            inner_block: fn _, attrs ->
              Phoenix.HTML.raw(
                ~s|<a href="/docs" aria-describedby="#{attrs["aria-describedby"]}">Docs</a>|
              )
            end
          }
        ],
        content: [%{inner_block: fn _, _ -> Phoenix.HTML.raw("<strong>Details</strong>") end}]
      })

    assert composed =~ ~s(aria-describedby="composed-tip-content")
    assert composed =~ ~s(data-slot="overlay-arrow")
    assert composed =~ ~s(data-offset="7")
    assert composed =~ "<strong>Details</strong>"
    refute composed =~ "<button"

    assigns = %{}

    heex =
      rendered_to_string(~H"""
      <HeroUI.tooltip id="heex-tip" show_arrow>
        <:trigger :let={attrs}><HeroUI.button {attrs}>Save</HeroUI.button></:trigger>
        <:content><strong>Save</strong> the changes.</:content>
      </HeroUI.tooltip>
      """)

    assert heex =~ ~s(aria-describedby="heex-tip-content")
    assert heex =~ "<strong>Save</strong>"

    assert_raise ArgumentError, ~r/either text or a content slot/, fn ->
      render_component(&HeroUI.tooltip/1, %{id: "missing-content", inner_block: slot})
    end

    left =
      render_component(&HeroUI.tooltip/1, %{
        id: "left-tip",
        text: "Left",
        placement: "left",
        delay: 0,
        close_delay: 250,
        inner_block: slot
      })

    assert left =~ ~s(data-requested-placement="left")
    assert left =~ ~s(data-delay="0")
    assert left =~ ~s(data-close-delay="250")

    assert_raise ArgumentError, ~r/close delay must be nonnegative/, fn ->
      render_component(&HeroUI.tooltip/1, %{
        id: "bad-tip",
        text: "Bad",
        close_delay: -1,
        inner_block: slot
      })
    end

    popover =
      render_component(&HeroUI.popover/1, %{
        id: "details",
        trigger: "Open",
        title: "Details",
        inner_block: slot
      })

    assert popover =~ ~s(popovertarget="details-content")
    assert popover =~ ~s(x-data="heroPopover")
    assert popover =~ ~s|x-on:toggle="toggle($event)"|
    assert popover =~ ~s(aria-labelledby="details-title")
    assert popover =~ ~s(role="dialog")
  end

  test "popover supports custom triggers, placement, arrows and controlled state" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <HeroUI.popover
        id="custom-popover"
        title="Details"
        placement="right start"
        show_arrow
        show_close={false}
        open={false}
        on_open_change="popover_change"
      >
        <:trigger_content :let={attrs}><HeroUI.button {attrs}>Custom</HeroUI.button></:trigger_content>
        <p>More information</p>
      </HeroUI.popover>
      """)

    assert html =~ ~s(popovertarget="custom-popover-content")
    assert html =~ ~s(aria-controls="custom-popover-content")
    assert html =~ ~s(data-requested-placement="right start")
    assert html =~ ~s(data-offset="8")
    assert html =~ ~s(data-should-flip="true")
    assert html =~ ~s(data-controlled="true")
    assert html =~ ~s(data-controlled-open="false")
    assert html =~ ~s(data-slot="popover-overlay-arrow")
    assert html =~ ~s(phx-click="popover_change")
    refute html =~ "data-hero-popover-close"

    content = [%{inner_block: fn _, _ -> "Content" end}]

    assert_raise ArgumentError, ~r/either trigger/, fn ->
      render_component(&HeroUI.popover/1, %{id: "missing", title: "Missing", inner_block: content})
    end

    assert_raise ArgumentError, ~r/cannot use open and default_open/, fn ->
      render_component(&HeroUI.popover/1, %{
        id: "bad",
        title: "Bad",
        trigger: "Open",
        open: false,
        default_open: true,
        inner_block: content
      })
    end

    assert_raise ArgumentError, ~r/offset must be nonnegative/, fn ->
      render_component(&HeroUI.popover/1, %{
        id: "bad",
        title: "Bad",
        trigger: "Open",
        offset: -1,
        inner_block: content
      })
    end
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
    assert slider =~ ~s(x-data="heroSlider")
    assert slider =~ ~s|x-on:input.capture="input($event)"|
    assert slider =~ ~s(for="volume")
    assert slider =~ "width: 25.0%"

    range =
      render_component(&HeroUI.slider/1, %{
        id: "price",
        name: "price",
        label: "Price",
        value: [20, 80],
        step: 10,
        show_steps: true,
        marks: [0, {50, "Mid"}, 100],
        orientation: "vertical"
      })

    assert range =~ ~s(name="price[]")
    assert range =~ ~s(aria-label="Price 1")
    assert range =~ ~s(aria-label="Price 2")
    assert range =~ ~s(data-orientation="vertical")
    assert range =~ "height: 60.0%"
    assert range =~ ~s(data-slot="slider-step")
    assert range =~ "Mid"

    fractional =
      render_component(&HeroUI.slider/1, %{
        id: "fractional",
        label: "Fractional",
        value: 0.2,
        min: 0,
        max: 0.3,
        step: 0.1,
        show_steps: true
      })

    assert length(Regex.scan(~r/data-slot="slider-step"/, fractional)) == 4

    assert_raise ArgumentError, fn ->
      render_component(&HeroUI.slider/1, %{id: "s", label: "Slider", value: [80, 20]})
    end

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
    assert field =~ ~s(x-data="heroNumberField")
    assert field =~ ~s(data-slot="number-field-increment-button-icon")

    form = Phoenix.Component.to_form(%{"quantity" => "3"}, as: :order)

    validation =
      render_component(&HeroUI.number_field/1, %{
        field: form[:quantity],
        label: "Quantity",
        description: "Choose a quantity",
        errors: ["is invalid"],
        rest: %{"aria-describedby" => "additional-help"}
      })

    assert validation =~ ~s(id="order_quantity")
    assert validation =~ ~s(name="order[quantity]")
    assert validation =~ ~s(value="3")
    assert validation =~ ~s(aria-describedby="additional-help order_quantity-errors")
    assert validation =~ ~s(data-slot="field-error")

    assert_raise ArgumentError, ~r/bounds/, fn ->
      render_component(&HeroUI.number_field/1, %{id: "bad", label: "Bad", min: 10, max: 5})
    end
  end

  test "alert supports status, accessible custom indicators, and actions" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <HeroUI.alert
        status="warning"
        color="success"
        role="alert"
        id="payment-alert"
        aria-describedby="help"
      >
        <:title_content>Payment <strong>expires soon</strong></:title_content>
        <:indicator><span role="img" aria-label="Warning">!</span></:indicator>
        <:description>Update your billing details.</:description>
        <:actions><button type="button">Update</button></:actions>
      </HeroUI.alert>
      """)

    assert html =~ "alert--warning"
    assert html =~ ~s(role="alert")
    assert html =~ ~s(id="payment-alert")
    assert html =~ ~s(aria-describedby="help")
    assert html =~ ~s(data-slot="alert-indicator")
    assert html =~ ~s(role="img")
    assert html =~ ~s(data-slot="alert-title")
    assert html =~ ~s(data-slot="alert-description")
    assert length(Regex.scan(~r/data-slot="alert-description"/, html)) == 1
    assert html =~ "Update your billing details."
    assert html =~ "<button type=\"button\">Update</button>"
    refute html =~ ~s(data-slot="alert-default-icon")

    legacy =
      render_component(&HeroUI.alert/1, %{
        title: "Saved",
        color: "success",
        inner_block: [%{inner_block: fn _, _ -> "Your changes are saved." end}]
      })

    assert legacy =~ "alert--success"
    assert legacy =~ ~s(role="status")
    assert legacy =~ ~s(data-slot="alert-default-icon")
    assert legacy =~ "Your changes are saved."
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
    assert avatar =~ ~s(x-data="heroAvatarImage")
    assert avatar =~ "x-on:error"
    assert avatar =~ "x-on:load"
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

  test "selectable tables expose labelled native controls and stable selected state" do
    cols = [%{label: "Name", inner_block: fn _, row -> row.name end}]

    attrs = %{
      id: "people",
      label: "People",
      rows: [%{id: "a", name: "Alice"}, %{id: "b", name: "Bob"}],
      col: cols,
      row_id: & &1.id,
      row_label: & &1.name,
      selection_mode: "multiple",
      selected_keys: ["a"],
      disabled_keys: ["b"],
      on_selection_change: "select"
    }

    html = render_component(&HeroUI.data_table/1, attrs)
    assert html =~ ~s(x-data="heroTable")
    assert html =~ ~s(data-controlled="true")
    assert html =~ ~s(aria-label="Select all rows")
    assert html =~ ~s(aria-label="Select Alice")
    assert html =~ ~s(aria-label="Select Bob")
    assert html =~ ~s(data-key="a")
    assert html =~ ~s(aria-selected="true")
    assert html =~ ~s(phx-click="select")
    assert html =~ ~r/aria-label="Select Bob"[^>]*disabled/s
    assert html =~ ~r/aria-label="Select Alice"[^>]*checked/s
    assert html =~ ~s(data-hero-table-select-all)
    single = render_component(&HeroUI.data_table/1, %{attrs | selection_mode: "single"})
    refute single =~ ~s(data-hero-table-select-all)
  end

  test "table empty content and footer support composable content" do
    cols = [%{label: "Name", inner_block: fn _, row -> row.name end}]
    empty = [%{inner_block: fn _, _ -> "No matching people" end}]
    footer = [%{inner_block: fn _, _ -> "Page 1 of 3" end}]
    attrs = %{label: "People", rows: [], col: cols, empty: empty, footer: footer}

    html = render_component(&HeroUI.data_table/1, attrs)
    assert html =~ "No matching people"
    refute html =~ "No results found."
    assert html =~ ~r/<\/table>[\s\S]*class="table__footer"[^>]*>[\s\S]*Page 1 of 3/

    populated = render_component(&HeroUI.data_table/1, %{attrs | rows: [%{name: "Jane"}]})
    refute populated =~ "No matching people"
    assert populated =~ "Page 1 of 3"
  end

  test "resizable table columns expose bounded accessible controls" do
    cols = [
      %{
        label: "Name",
        key: "name",
        resizable: true,
        width: 220,
        min_width: 100,
        max_width: 400,
        sort_key: "name",
        inner_block: fn _, row -> row.name end
      },
      %{label: "Role", key: "role", inner_block: fn _, row -> row.role end}
    ]

    attrs = %{
      id: "people",
      label: "People",
      rows: [%{name: "Alex", role: "Designer"}],
      col: cols,
      sort_event: "sort",
      on_column_resize: "resize"
    }

    html = render_component(&HeroUI.data_table/1, attrs)
    assert html =~ ~s(data-table-column-key="name")
    assert html =~ ~s(data-table-resizer="name")
    assert html =~ ~s(aria-label="Resize Name column")
    assert html =~ ~s(aria-valuemin="100")
    assert html =~ ~s(aria-valuemax="400")
    assert html =~ ~s(aria-valuenow="220")
    assert html =~ ~s(phx-click="resize")
    assert html =~ "table__resizable-container"
    assert html =~ "table__column-resizer"
    assert html =~ ~s(phx-value-sort="name")
    refute html =~ ~s(data-table-resizer="role")

    invalid = [
      %{
        label: "Name",
        resizable: true,
        width: 20,
        min_width: 100,
        inner_block: fn _, row -> row.name end
      }
    ]

    assert_raise ArgumentError, ~r/table column widths/, fn ->
      render_component(&HeroUI.data_table/1, %{attrs | col: invalid})
    end

    duplicate = [
      %{label: "One", key: "same", inner_block: fn _, _ -> "one" end},
      %{label: "Two", key: "same", inner_block: fn _, _ -> "two" end}
    ]

    assert_raise ArgumentError, ~r/column keys must be unique/, fn ->
      render_component(&HeroUI.data_table/1, %{attrs | col: duplicate})
    end
  end

  test "tables expose Alpine grid navigation even without selection" do
    cols = [%{label: "Name", inner_block: fn _, row -> row.name end}]

    html =
      render_component(&HeroUI.data_table/1, %{
        id: "people",
        label: "People",
        rows: [%{name: "Alice"}],
        col: cols
      })

    assert html =~ ~s(x-data="heroTable")
    assert html =~ ~s|x-on:keydown="keyDown($event)"|
    assert html =~ ~s|x-on:focusin="focusIn($event)"|
    assert html =~ ~s(data-hero-table-row="true")
    assert html =~ ~s|x-bind:role="'grid'"|
    refute html =~ ~s(aria-selected=)
  end

  test "table load-more uses LiveView viewport events and reflects loading state" do
    cols = [%{label: "Name", inner_block: fn _, row -> row.name end}]

    attrs = %{
      id: "people",
      label: "People",
      rows: [%{name: "Jane"}],
      col: cols,
      on_load_more: "load_more",
      has_more: true
    }

    html = render_component(&HeroUI.data_table/1, attrs)
    assert html =~ ~s(id="people-scroll")
    assert html =~ ~s(phx-viewport-bottom="load_more")
    assert html =~ ~s(id="people-load-more")
    assert html =~ "Scroll for more"

    loading = render_component(&HeroUI.data_table/1, Map.put(attrs, :loading, true))
    refute loading =~ "phx-viewport-bottom"
    assert loading =~ "Loading more"

    done = render_component(&HeroUI.data_table/1, %{attrs | has_more: false})
    refute done =~ "phx-viewport-bottom"
    refute done =~ "people-load-more"

    assert_raise ArgumentError, ~r/table id is required for load-more/, fn ->
      render_component(&HeroUI.data_table/1, Map.delete(attrs, :id))
    end
  end

  test "selectable tables reject ambiguous state and missing row keys" do
    cols = [%{label: "Name", inner_block: fn _, row -> row.name end}]

    attrs = %{
      id: "people",
      label: "People",
      rows: [%{id: "a", name: "Alice"}],
      col: cols,
      row_id: & &1.id,
      selection_mode: "single"
    }

    assert_raise ArgumentError, ~r/at most one/, fn ->
      render_component(&HeroUI.data_table/1, Map.put(attrs, :selected_keys, ["a", "b"]))
    end

    assert_raise ArgumentError, ~r/row ids/, fn ->
      render_component(&HeroUI.data_table/1, %{
        attrs
        | rows: [%{id: "a", name: "One"}, %{id: "a", name: "Two"}]
      })
    end

    assert_raise ArgumentError, ~r/row_id/, fn ->
      render_component(&HeroUI.data_table/1, Map.delete(attrs, :row_id))
    end
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

  test "pagination supports simple layouts, custom icons and JS commands" do
    html =
      render_component(&HeroUI.pagination/1, %{
        page: 2,
        total_pages: 5,
        on_change: Phoenix.LiveView.JS.push("change_page"),
        show_pages: false,
        previous_icon: [%{inner_block: fn _, _ -> "BACK_ICON" end}],
        next_icon: [%{inner_block: fn _, _ -> "NEXT_ICON" end}]
      })

    assert html =~ "BACK_ICON"
    assert html =~ "NEXT_ICON"
    assert html =~ "change_page"
    assert html =~ ~s(phx-value-page="1")
    assert html =~ ~s(phx-value-page="3")
    refute html =~ ~s(aria-label="Page 2")
    refute html =~ "pagination__ellipsis"
  end

  test "pagination supports patch navigation, localised page labels and disabled state" do
    attrs = %{
      page: 2,
      total_pages: 3,
      patch: fn page -> "/people?page=#{page}" end,
      page_label: fn page -> "Seite #{page}" end,
      show_controls: false
    }

    html = render_component(&HeroUI.pagination/1, attrs)
    assert html =~ ~s(data-phx-link="patch")
    assert html =~ ~s(href="/people?page=3")
    assert html =~ ~s(aria-label="Seite 2")
    assert html =~ ~s(aria-current="page")
    refute html =~ ~s(aria-label="Previous")

    disabled = render_component(&HeroUI.pagination/1, Map.put(attrs, :disabled, true))
    assert disabled =~ ~s(aria-disabled="true")
    assert disabled =~ ~s(aria-current="page")
    assert disabled =~ ~s(data-active="true")
    refute disabled =~ "<a "

    assert_raise ArgumentError, ~r/exactly one/, fn ->
      render_component(&HeroUI.pagination/1, Map.put(attrs, :on_change, "page"))
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
    assert {description_pos, _} = :binary.match(html, ~s(id="topics-description"))
    assert {option_pos, _} = :binary.match(html, ~s(id="topics-option-bmV3cw"))
    assert description_pos < option_pos

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
    refute toggle =~ ~s(x-data=)

    local = render_component(&HeroUI.toggle_button/1, %{default_pressed: true, inner_block: slot})
    assert local =~ ~s(aria-pressed="true")
    assert local =~ "selected.toString()"
    assert local =~ "selected = !selected"

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

  test "toggle button group disables descendants natively and marks inherited sizes" do
    slot = [%{inner_block: fn _, _ -> "Buttons" end}]

    group =
      render_component(&HeroUI.toggle_button_group/1, %{
        label: "Formatting",
        size: "sm",
        disabled: true,
        inner_block: slot
      })

    assert group =~ ~r/<fieldset[^>]*\sdisabled(?:\s|>|=)/
    assert group =~ ~s(aria-disabled="true")
    assert group =~ ~s(data-hero-toggle-size="sm")
    assert group =~ ~s(x-data="heroToggleButtonGroup")
    default = render_component(&HeroUI.toggle_button/1, %{inner_block: slot})
    assert default =~ "toggle-button--md"
    refute default =~ ~s(data-hero-toggle-size=)
    explicit = render_component(&HeroUI.toggle_button/1, %{size: "lg", inner_block: slot})
    assert explicit =~ "toggle-button--lg"
    assert explicit =~ ~s(data-hero-toggle-size="lg")
  end

  test "toggle button groups opt into controlled and uncontrolled selection" do
    slot = [%{inner_block: fn _, _ -> "Buttons" end}]

    single =
      render_component(&HeroUI.toggle_button_group/1, %{
        label: "Alignment",
        selection_mode: "single",
        selected_keys: ["left"],
        inner_block: slot
      })

    assert single =~ ~s(role="group")
    assert single =~ ~s(data-selection-mode="single")
    assert single =~ ~s(data-controlled="true")
    assert single =~ ~s(x-data="heroToggleButtonGroup")

    multiple =
      render_component(&HeroUI.toggle_button_group/1, %{
        label: "Style",
        selection_mode: "multiple",
        default_selected_keys: ["bold"],
        on_selection_change: "style",
        inner_block: slot
      })

    assert multiple =~ ~s(role="group")
    assert multiple =~ ~s(data-selection-mode="multiple")
    assert multiple =~ ~s(data-controlled="false")
    assert multiple =~ ~s(phx-click="style")

    assert_raise ArgumentError, ~r/at most one key/, fn ->
      render_component(&HeroUI.toggle_button_group/1, %{
        label: "Bad",
        selection_mode: "single",
        selected_keys: ["a", "b"],
        inner_block: slot
      })
    end
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
    assert html =~ ~s(x-data="heroListbox")
    assert html =~ ~s|x-on:keydown="keydown($event)"|
    assert html =~ ~s|x-on:phx:update.window="sync()"|
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

  test "listbox supports sections, local defaults, controlled state, actions and custom content" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <HeroUI.listbox
        id="choices"
        label="Choices"
        selection_mode="multiple"
        default_selected_keys={["one"]}
        on_selection_change="selection"
        on_action="action"
      >
        <:option value="one" label="One" text_value="First"><strong>Custom One</strong></:option>
        <:section
          label="Other"
          items={[
            %{value: "two", label: "Two", description: "Second"},
            %{value: "three", label: "Delete", variant: "danger", disabled: true}
          ]}
        />
      </HeroUI.listbox>
      """)

    assert html =~ ~s(role="group")
    assert html =~ ~s(aria-labelledby="choices-section-0")
    assert html =~ ~s(data-controlled="false")
    assert html =~ ~s(data-selection-mode="multiple")
    assert html =~ ~s(data-text-value="First")
    assert html =~ "<strong>Custom One</strong>"
    assert html =~ "list-box-item--danger"
    assert html =~ ~s(phx-click="selection")
    assert html =~ ~s(phx-click="action")

    none =
      render_component(&HeroUI.listbox/1, %{
        id: "actions",
        label: "Actions",
        selection_mode: "none",
        on_action: "action",
        option: [%{value: "run", label: "Run"}]
      })

    assert none =~ ~s(data-selection-mode="none")
    refute none =~ "aria-selected="
    refute none =~ "list-box-item__indicator"

    assert_raise ArgumentError, ~r/unique string values/, fn ->
      render_component(&HeroUI.listbox/1, %{
        id: "dup",
        label: "Dup",
        option: [%{value: "a", label: "A"}],
        section: [%{label: "Section", items: [%{value: "a", label: "Again"}]}]
      })
    end

    assert_raise ArgumentError, ~r/cannot combine/, fn ->
      render_component(&HeroUI.listbox/1, %{
        id: "dup",
        label: "Dup",
        selected_keys: [],
        default_selected_keys: [],
        option: [%{value: "a", label: "A"}]
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

  test "standalone header and empty state use HeroUI markup and preserve native semantics" do
    header =
      render_component(&HeroUI.header/1, %{
        as: "h2",
        rest: %{"data-slot" => "custom-header", id: "results-title"},
        inner_block: [%{inner_block: fn _, _ -> "Results" end}]
      })

    assert header =~ "<h2 "
    assert header =~ ~s(id="results-title")
    assert header =~ ~s(data-slot="custom-header")
    assert header =~ ~s(class="header")
    assert header =~ "Results"

    default = render_component(&HeroUI.empty_state/1, %{})
    assert default =~ ~s(data-slot="empty-state")
    assert default =~ ~s(class="empty-state")
    assert default =~ "No results found"

    custom =
      render_component(&HeroUI.empty_state/1, %{
        as: "p",
        message: "Nothing yet",
        rest: %{"aria-live" => "polite", role: "status"}
      })

    assert custom =~ "<p "
    assert custom =~ ~s(role="status")
    assert custom =~ ~s(aria-live="polite")
    assert custom =~ "Nothing yet"

    content =
      render_component(&HeroUI.empty_state/1, %{
        message: "Hidden default",
        inner_block: [%{inner_block: fn _, _ -> "No projects" end}]
      })

    assert content =~ "No projects"
    refute content =~ "Hidden default"
  end
end
