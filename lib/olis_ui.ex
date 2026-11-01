defmodule OlisUI do
  @moduledoc """
  OlisUI function components for Phoenix LiveView.

  Import this module in your HTML helpers and include the required component styles and `assets/css/olis_ui.css` in your Tailwind v4 application stylesheet. See the README for setup and examples.
  """
  use Phoenix.Component, global_prefixes: ~w(x-)

  @doc """
  A Phoenix form with native submission, validation and LiveView support.

  Uses the same options and slot form value as `Phoenix.Component.form/1`. Named
  `ui_form` to avoid an import conflict with Phoenix's built-in `form` component.
  """
  attr(:for, :any, required: true)
  attr(:action, :string)
  attr(:as, :atom)
  attr(:csrf_token, :any)
  attr(:errors, :list)
  attr(:method, :string)
  attr(:multipart, :boolean, default: false)
  attr(:rest, :global, include: ~w(autocomplete name rel enctype novalidate target))
  slot(:inner_block, required: true)

  def ui_form(assigns), do: Phoenix.Component.form(assigns)

  @doc "Supplementary text for a form field or other component."
  attr(:class, :any, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def description(assigns) do
    ~H"""
    <span
      class={["description text-xs text-wrap wrap-break-word text-muted", @class]}
      data-slot="description"
      {@rest}
    >
      {render_slot(@inner_block)}
    </span>
    """
  end

  @doc "A field validation message. Control visibility explicitly with `visible`."
  attr(:visible, :boolean, default: true)
  attr(:class, :any, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def field_error(assigns) do
    ~H"""
    <span
      class={[field_error_classes(), @class]}
      data-slot="field-error"
      data-visible={if @visible, do: "true"}
      hidden={!@visible}
      {@rest}
    >{render_slot(@inner_block)}</span>
    """
  end

  @doc "An error message for a non-form component such as a tag group."
  attr(:class, :any, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def error_message(assigns) do
    ~H"""
    <span
      class={[
        "error-message h-auto text-xs wrap-break-word text-danger [transition:opacity_150ms_var(--ease-out),height_350ms_var(--ease-smooth)]",
        @class
      ]}
      data-slot="error-message"
      {@rest}
    >
      {render_slot(@inner_block)}
    </span>
    """
  end

  @doc "A native button with OlisUI variants and an optional focusable pending state."
  attr(:variant, :string,
    default: "primary",
    values: ~w(primary secondary tertiary outline ghost danger danger-soft)
  )

  attr(:size, :string, default: "md", values: ~w(sm md lg))
  attr(:type, :string, default: "button", values: ~w(button submit reset))
  attr(:disabled, :boolean, default: false)
  attr(:pending, :boolean, default: false)
  attr(:full_width, :boolean, default: false)
  attr(:icon_only, :boolean, default: false)
  attr(:class, :any, default: nil)
  attr(:rest, :global, include: ~w(form name value))
  slot(:inner_block, required: true)

  def button(assigns) do
    rest = assigns.rest
    data_slot = Map.get(rest, :"data-slot") || Map.get(rest, "data-slot") || "button"
    aria_disabled = Map.get(rest, :"aria-disabled", Map.get(rest, "aria-disabled"))
    aria_busy = Map.get(rest, :"aria-busy", Map.get(rest, "aria-busy"))
    alpine_data = Map.get(rest, :"x-data") || Map.get(rest, "x-data")
    capture = Map.get(rest, :"x-on:click.capture") || Map.get(rest, "x-on:click.capture")

    submit_capture =
      Map.get(rest, :"x-on:submit.document.capture") ||
        Map.get(rest, "x-on:submit.document.capture")

    rest =
      Map.drop(rest, [
        :"data-slot",
        "data-slot",
        :"aria-disabled",
        "aria-disabled",
        :"aria-busy",
        "aria-busy",
        :"x-data",
        "x-data",
        :"x-on:click.capture",
        "x-on:click.capture",
        :"x-on:submit.document.capture",
        "x-on:submit.document.capture"
      ])

    assigns =
      assign(assigns,
        rest: rest,
        data_slot: data_slot,
        aria_disabled: if(assigns.pending, do: "true", else: aria_disabled),
        aria_busy: if(assigns.pending, do: "true", else: aria_busy),
        alpine_data: if(assigns.pending, do: alpine_data || "{}", else: alpine_data),
        capture:
          if(assigns.pending,
            do: "$event.preventDefault(); $event.stopImmediatePropagation()",
            else: capture
          ),
        submit_capture:
          if(assigns.pending && assigns.type == "submit",
            do:
              "if ($event.target === $el.form && !$event.submitter) { $event.preventDefault(); $event.stopImmediatePropagation() }",
            else: submit_capture
          )
      )

    ~H"""
    <button
      type={if @pending && @type == "submit", do: "button", else: @type}
      disabled={@disabled}
      aria-disabled={@aria_disabled}
      aria-busy={@aria_busy}
      data-pending={if @pending, do: "true"}
      data-slot={@data_slot}
      x-data={@alpine_data}
      x-on:click.capture={@capture}
      x-on:submit.document.capture={@submit_capture}
      class={[
        button_classes(@variant, @size, @full_width, @icon_only),
        @class
      ]}
      {@rest}
    >{render_slot(@inner_block)}</button>
    """
  end

  defp button_classes(variant, size, full_width \\ false, icon_only \\ false) do
    palette =
      %{
        "primary" =>
          "[--button-bg:var(--accent)] [--button-bg-hover:var(--accent-hover)] [--button-bg-pressed:var(--accent-hover)] [--button-fg:var(--accent-foreground)]",
        "secondary" =>
          "[--button-bg:var(--default)] [--button-bg-hover:var(--default-hover)] [--button-bg-pressed:var(--default-hover)] [--button-fg:var(--default-foreground)]",
        "tertiary" =>
          "[--button-bg:var(--default)] [--button-bg-hover:var(--default-hover)] [--button-bg-pressed:var(--default-hover)] [--button-fg:currentColor]",
        "ghost" =>
          "[--button-bg:transparent] [--button-bg-hover:var(--default)] [--button-bg-pressed:var(--default)] [--button-fg:var(--default-foreground)]",
        "outline" =>
          "border border-border [--button-bg:transparent] [--button-bg-hover:color-mix(in_srgb,var(--default)_60%,transparent)] [--button-bg-pressed:var(--default)] [--button-fg:var(--default-foreground)]",
        "danger" =>
          "[--button-bg:var(--danger)] [--button-bg-hover:var(--danger-hover)] [--button-bg-pressed:var(--danger-hover)] [--button-fg:var(--danger-foreground)]",
        "danger-soft" =>
          "[--button-bg:var(--danger-soft)] [--button-bg-hover:var(--danger-soft-hover)] [--button-bg-pressed:var(--danger-soft-hover)] [--button-fg:var(--danger-soft-foreground)]"
      }[variant]

    [
      "button button--#{variant} button--#{size} relative isolate inline-flex origin-center items-center justify-center gap-2 rounded-[6px] font-[510] whitespace-nowrap outline-none select-none no-highlight transform-gpu tracking-[-0.011em] cursor-(--cursor-interactive) bg-(--button-bg) text-(--button-fg) [transition:transform_250ms_var(--ease-smooth),background-color_100ms_var(--ease-out),box-shadow_100ms_var(--ease-out)] [&:focus-visible:not([data-focused])]:status-focused data-[focus-visible=true]:status-focused disabled:status-disabled aria-disabled:status-disabled data-[pending=true]:status-pending active:will-change-transform active:bg-(--button-bg-pressed) data-[pressed=true]:will-change-transform data-[pressed=true]:bg-(--button-bg-pressed) hover:bg-(--button-bg-hover) [@media(hover:hover)]:data-[hovered=true]:bg-(--button-bg-hover)",
      "[&_svg:not([data-slot=spinner]_svg,[data-slot=link-icon]_svg)]:pointer-events-none [&_svg:not([data-slot=spinner]_svg,[data-slot=link-icon]_svg)]:-mx-0.5 [&_svg:not([data-slot=spinner]_svg,[data-slot=link-icon]_svg)]:my-0.5 [&_svg:not([data-slot=spinner]_svg,[data-slot=link-icon]_svg)]:shrink-0 [&_svg:not([data-slot=spinner]_svg,[data-slot=link-icon]_svg)]:self-center sm:[&_svg:not([data-slot=spinner]_svg,[data-slot=link-icon]_svg)]:my-1",
      palette,
      size == "sm" &&
        "h-9 text-sm md:h-8 active:[transform:scale(.98)] data-[pressed=true]:[transform:scale(.98)] [&_svg:not([data-slot=spinner]_svg,[data-slot=link-icon]_svg)]:size-4",
      size == "md" &&
        "h-10 text-sm md:h-9 active:[transform:scale(.97)] data-[pressed=true]:[transform:scale(.97)] [&_svg:not([data-slot=spinner]_svg,[data-slot=link-icon]_svg)]:size-5 sm:[&_svg:not([data-slot=spinner]_svg,[data-slot=link-icon]_svg)]:size-4",
      size == "lg" &&
        "h-11 text-base md:h-10 active:[transform:scale(.96)] data-[pressed=true]:[transform:scale(.96)] [&_svg:not([data-slot=spinner]_svg,[data-slot=link-icon]_svg)]:size-5 sm:[&_svg:not([data-slot=spinner]_svg,[data-slot=link-icon]_svg)]:size-4",
      !icon_only && size == "sm" && "px-3",
      !icon_only && size in ["md", "lg"] && "px-4",
      !icon_only && !full_width && "w-fit",
      full_width && "button--full-width",
      full_width && !icon_only && "w-full",
      icon_only && size == "sm" && "button--icon-only w-9 p-0 md:w-8",
      icon_only && size == "md" && "button--icon-only w-10 p-0 md:w-9",
      icon_only && size == "lg" && "button--icon-only w-11 p-0 md:w-10"
    ]
  end

  @doc "An accessible icon button for closing or dismissing content."
  attr(:label, :string, default: "Close")
  attr(:disabled, :boolean, default: false)
  attr(:type, :string, default: "button", values: ~w(button submit reset))
  attr(:class, :any, default: nil)
  attr(:rest, :global, include: ~w(form name value hidden slot))
  slot(:inner_block)

  def close_button(assigns) do
    label =
      Map.get(assigns.rest, :"aria-label") || Map.get(assigns.rest, "aria-label") || assigns.label

    data_slot =
      Map.get(assigns.rest, :"data-slot") || Map.get(assigns.rest, "data-slot") || "close-button"

    rest = Map.drop(assigns.rest, [:"aria-label", "aria-label", :"data-slot", "data-slot"])
    assigns = assign(assigns, label: label, data_slot: data_slot, rest: rest)

    ~H"""
    <button
      type={@type}
      disabled={@disabled}
      aria-label={@label}
      class={[close_button_classes(), @class]}
      data-slot={@data_slot}
      {@rest}
    >
      <%= if @inner_block == [] do %>
        <svg
          aria-hidden="true"
          role="presentation"
          fill="none"
          height="16"
          width="16"
          viewBox="0 0 16 16"
          data-slot="close-button-icon"
        ><path
          d="M3.47 3.47a.75.75 0 0 1 1.06 0L8 6.94l3.47-3.47a.75.75 0 1 1 1.06 1.06L9.06 8l3.47 3.47a.75.75 0 1 1-1.06 1.06L8 9.06l-3.47 3.47a.75.75 0 0 1-1.06-1.06L6.94 8 3.47 4.53a.75.75 0 0 1 0-1.06Z"
          fill="currentColor"
          fill-rule="evenodd"
          clip-rule="evenodd"
        /></svg>
      <% else %>
        {render_slot(@inner_block)}
      <% end %>
    </button>
    """
  end

  defp label_classes do
    "label text-sm font-medium text-foreground [&.label--required]:after:ms-0.5 [&.label--required]:after:text-danger [&.label--required]:after:content-['*'] [[data-required=true]:not([role=group]):not([role=radiogroup]):not([role=checkboxgroup])>&]:after:ms-0.5 [[data-required=true]:not([role=group]):not([role=radiogroup]):not([role=checkboxgroup])>&]:after:text-danger [[data-required=true]:not([role=group]):not([role=radiogroup]):not([role=checkboxgroup])>&]:after:content-['*'] [[data-required=true]:not([data-slot=radio]):not([data-slot=checkbox])>&]:after:ms-0.5 [[data-required=true]:not([data-slot=radio]):not([data-slot=checkbox])>&]:after:text-danger [[data-required=true]:not([data-slot=radio]):not([data-slot=checkbox])>&]:after:content-['*'] [&.label--disabled]:status-disabled [[data-disabled=true]_&]:status-disabled [&.label--invalid]:text-danger [[data-invalid=true]_&]:text-danger [[aria-invalid=true]_&]:text-danger"
  end

  defp calendar_native_classes do
    "olis-calendar-native [.olis-calendar-root[data-enhanced=true]_&]:pointer-events-none [.olis-calendar-root[data-enhanced=true]_&]:absolute [.olis-calendar-root[data-enhanced=true]_&]:size-px [.olis-calendar-root[data-enhanced=true]_&]:opacity-0"
  end

  defp search_field_classes do
    "search-field flex flex-col gap-1 [&:is([data-invalid=true],[aria-invalid=true])_[data-slot=description]]:hidden [&_[data-slot=label]]:w-fit [&[data-empty=true]_[data-slot=search-field-clear-button]]:pointer-events-none [&[data-empty=true]_[data-slot=search-field-clear-button]]:opacity-0"
  end

  defp search_group_classes do
    "search-field__group relative inline-flex h-9 items-center overflow-hidden rounded-field border border-[length:var(--border-width-field)] border-field-border bg-(--search-field-group-bg) text-sm text-field-foreground shadow-field outline-none [--search-field-group-bg:var(--field-background,var(--default))] [--search-field-group-bg-hover:var(--field-hover)] [--search-field-group-bg-focus:var(--field-focus)] [transition:background-color_150ms_var(--ease-smooth),border-color_150ms_var(--ease-smooth),box-shadow_150ms_var(--ease-out)] [@media(hover:hover)]:[&:hover:not(:focus-within)]:[--search-field-group-bg:var(--search-field-group-bg-hover)] [@media(hover:hover)]:[&:hover:not(:focus-within)]:border-field-border-hover [@media(hover:hover)]:[&[data-hovered=true]:not([data-focus-within=true])]:[--search-field-group-bg:var(--search-field-group-bg-hover)] [@media(hover:hover)]:[&[data-hovered=true]:not([data-focus-within=true])]:border-field-border-hover focus-within:status-focused-field data-[focus-within=true]:status-focused-field data-[invalid=true]:status-invalid-field data-[invalid=true]:[--search-field-group-bg:var(--search-field-group-bg-focus)] data-[invalid=true]:border-[color:var(--color-field-border-invalid)] data-[disabled=true]:status-disabled aria-disabled:status-disabled [.search-field--secondary_&]:shadow-none [.search-field--secondary_&]:[--search-field-group-bg:var(--default)] [.search-field--secondary_&]:[--search-field-group-bg-hover:var(--default-hover)] [.search-field--secondary_&]:[--search-field-group-bg-focus:var(--default)] [.search-field--secondary_&:focus-within]:[--search-field-group-bg:var(--search-field-group-bg-focus)] [.search-field--secondary_&[data-focus-within=true]]:[--search-field-group-bg:var(--search-field-group-bg-focus)]"
  end

  defp search_input_classes do
    "search-field__input flex-1 rounded-none border-0 bg-transparent px-3 py-2 text-base shadow-none outline-none sm:text-sm [.search-field__group:has([data-slot=search-field-search-icon])_&]:rounded-s-none [.search-field__group:has([data-slot=search-field-search-icon])_&]:ps-2 [.search-field__group:has([slot=clear])_&]:rounded-e-none [.search-field__group:has([slot=clear])_&]:pe-2 [&::-webkit-search-cancel-button]:appearance-none [&::-webkit-search-cancel-button]:[-webkit-appearance:none] [&::-webkit-search-decoration]:appearance-none [&::-webkit-search-decoration]:[-webkit-appearance:none] [[data-olis-search-field]:not([data-olis-search-ready])_&::-webkit-search-cancel-button]:[-webkit-appearance:auto] [&:is(:-webkit-autofill,:autofill)]:[box-shadow:0_0_0_1000px_var(--search-field-group-bg)_inset] [&:is(:-webkit-autofill,:autofill)]:[-webkit-box-shadow:0_0_0_1000px_var(--search-field-group-bg)_inset] [&:is(:-webkit-autofill,:autofill)]:[-webkit-text-fill-color:var(--field-foreground)] [&:is(:-webkit-autofill,:autofill)]:[caret-color:var(--field-foreground)] [&:is(:-webkit-autofill,:autofill)]:[transition:background-color_9999s_ease-in-out_0s]"
  end

  defp search_clear_classes do
    "search-field__clear-button me-2 size-5! shrink-0 [&_[data-slot=close-button-icon]]:size-3!"
  end

  defp date_input_group_classes do
    "date-input-group inline-flex h-9 items-center overflow-hidden rounded-field border border-[length:var(--border-width-field)] border-field-border text-sm text-field-foreground outline-none [transition:background-color_150ms_var(--ease-smooth),border-color_150ms_var(--ease-smooth),box-shadow_150ms_var(--ease-out)] [&:not(.date-input-group--secondary)]:bg-field [&:not(.date-input-group--secondary)]:shadow-field [&.date-input-group--secondary]:bg-default [&.date-input-group--secondary]:shadow-none [&.date-input-group--full-width]:w-full [@media(hover:hover)]:[&:not(.date-input-group--secondary):hover:not(:focus-within)]:bg-field-hover [@media(hover:hover)]:[&:not(.date-input-group--secondary)[data-hovered=true]:not([data-focus-within=true])]:bg-field-hover [@media(hover:hover)]:[&:is(:hover,[data-hovered=true]):not(:focus-within)]:border-field-border-hover [@media(hover:hover)]:[&.date-input-group--secondary:hover:not(:focus-within)]:bg-default-hover [@media(hover:hover)]:[&.date-input-group--secondary[data-hovered=true]:not([data-focus-within=true])]:bg-default-hover [&:focus-within:not(:has([data-slot=date-picker-trigger]:focus,[data-slot=date-picker-trigger][data-focused=true],[data-slot=date-range-picker-trigger]:focus,[data-slot=date-range-picker-trigger][data-focused=true]))]:status-focused-field [&[data-focus-within=true]:not(:has([data-slot=date-picker-trigger]:focus,[data-slot=date-picker-trigger][data-focused=true],[data-slot=date-range-picker-trigger]:focus,[data-slot=date-range-picker-trigger][data-focused=true]))]:status-focused-field data-[invalid=true]:status-invalid-field data-[invalid=true]:border-[color:var(--color-field-border-invalid)] [&:not(.date-input-group--secondary)[data-invalid=true]]:bg-field-focus data-[disabled=true]:status-disabled aria-disabled:status-disabled"
  end

  defp date_input_classes do
    "date-input-group__input flex flex-1 cursor-text items-center gap-px rounded-none border-0 bg-transparent px-3 py-2 text-base shadow-none outline-none sm:text-sm [.date-input-group:has([data-slot=date-input-group-prefix])_&]:rounded-s-none [.date-input-group:has([data-slot=date-input-group-prefix])_&]:ps-2 [.date-input-group:has([data-slot=date-input-group-suffix])_&]:rounded-e-none [.date-input-group:has([data-slot=date-input-group-suffix])_&]:pe-2"
  end

  defp select_trigger_classes do
    "select__trigger relative isolate inline-flex min-h-9 rounded-field border border-[length:var(--border-width-field)] border-field-border bg-field px-3 py-2 text-sm text-field-foreground shadow-field outline-none select-none no-highlight cursor-(--cursor-interactive) [transition:background-color_150ms_var(--ease-smooth),border-color_150ms_var(--ease-smooth),box-shadow_150ms_var(--ease-out)] has-[.select__indicator]:pe-7 [@media(hover:hover)]:[&:hover:not(:has(.select__clear-button:hover))]:bg-field-hover [@media(hover:hover)]:[&:hover:not(:has(.select__clear-button:hover))]:border-field-border-hover [@media(hover:hover)]:[&[data-hovered=true]:not(:has(.select__clear-button:hover))]:bg-field-hover [@media(hover:hover)]:[&[data-hovered=true]:not(:has(.select__clear-button:hover))]:border-field-border-hover [&:focus-visible:not([data-focused])]:status-focused [&:focus-visible:not([data-focused])]:border-field-border-focus [&:focus-visible:not([data-focused])]:bg-field-focus data-[focus-visible=true]:status-focused data-[focus-visible=true]:border-field-border-focus data-[focus-visible=true]:bg-field-focus [.select:is([data-invalid=true],[aria-invalid=true])_&]:status-invalid-field [.select:is([data-invalid=true],[aria-invalid=true])_&]:bg-field-focus disabled:status-disabled data-[disabled=true]:status-disabled aria-disabled:status-disabled [.select--secondary_&]:shadow-none [.select--secondary_&]:bg-default [@media(hover:hover)]:[.select--secondary_&:hover:not(:has(.select__clear-button:hover))]:bg-default-hover [@media(hover:hover)]:[.select--secondary_&[data-hovered=true]:not(:has(.select__clear-button:hover))]:bg-default-hover [.select--secondary_&:focus-visible:not([data-focused])]:bg-default [.select--secondary_&[data-focus-visible=true]]:bg-default [.select--secondary.select:is([data-invalid=true],[aria-invalid=true])_&]:bg-default [&.select__trigger--full-width]:w-full"
  end

  defp autocomplete_trigger_classes do
    "autocomplete__trigger relative isolate inline-flex min-h-9 rounded-field border border-[length:var(--border-width-field)] border-field-border bg-field px-3 py-2 text-sm text-field-foreground shadow-field outline-none select-none no-highlight cursor-(--cursor-interactive) [transition:background-color_150ms_var(--ease-smooth),border-color_150ms_var(--ease-smooth),box-shadow_150ms_var(--ease-out)] has-[.autocomplete__indicator]:pe-7 [@media(hover:hover)]:[&:hover:not(:has(.autocomplete__clear-button:hover))]:bg-field-hover [@media(hover:hover)]:[&:hover:not(:has(.autocomplete__clear-button:hover))]:border-field-border-hover [@media(hover:hover)]:[&[data-hovered=true]:not(:has(.autocomplete__clear-button:hover))]:bg-field-hover [@media(hover:hover)]:[&[data-hovered=true]:not(:has(.autocomplete__clear-button:hover))]:border-field-border-hover [&:focus-visible:not([data-focused])]:status-focused [&:focus-visible:not([data-focused])]:border-field-border-focus [&:focus-visible:not([data-focused])]:bg-field-focus data-[focus-visible=true]:status-focused data-[focus-visible=true]:border-field-border-focus data-[focus-visible=true]:bg-field-focus [.autocomplete:is([data-invalid=true],[aria-invalid=true])_&]:status-invalid-field [.autocomplete:is([data-invalid=true],[aria-invalid=true])_&]:bg-field-focus disabled:status-disabled data-[disabled=true]:status-disabled aria-disabled:status-disabled [.autocomplete--secondary_&]:shadow-none [.autocomplete--secondary_&]:bg-default [@media(hover:hover)]:[.autocomplete--secondary_&:hover:not(:has(.autocomplete__clear-button:hover))]:bg-default-hover [@media(hover:hover)]:[.autocomplete--secondary_&[data-hovered=true]:not(:has(.autocomplete__clear-button:hover))]:bg-default-hover [.autocomplete--secondary_&:focus-visible:not([data-focused])]:bg-default [.autocomplete--secondary_&[data-focus-visible=true]]:bg-default [.autocomplete--secondary.autocomplete:is([data-invalid=true],[aria-invalid=true])_&]:bg-default [&.autocomplete__trigger--full-width]:w-full"
  end

  defp select_indicator_classes do
    "select__indicator absolute inset-y-0 end-2 my-auto flex shrink-0 items-center justify-center text-field-placeholder transition duration-150 data-[open=true]:rotate-180 data-[slot=select-default-indicator]:size-4"
  end

  defp overlay95_motion_classes do
    "origin-(--trigger-anchor-point) [box-shadow:var(--overlay-shadow)] data-[entering=true]:[animation:olis-overlay-enter-98_150ms_var(--ease-smooth)] [&[data-entering=true][data-placement=top]]:[animation-name:olis-overlay-enter-98-y] [&[data-entering=true][data-placement=bottom]]:[animation-name:olis-overlay-enter-98-ny] [&[data-entering=true][data-placement=left]]:[animation-name:olis-overlay-enter-98-x] [&[data-entering=true][data-placement=right]]:[animation-name:olis-overlay-enter-98-nx] data-[exiting=true]:pointer-events-none data-[exiting=true]:[animation:olis-overlay-exit_100ms_var(--ease-smooth)] [&[data-exiting=true][data-placement]]:[animation:olis-overlay-exit_100ms_var(--ease-smooth)]"
  end

  defp select_popover_classes do
    "select__popover scrollbar min-w-(--trigger-width) origin-(--trigger-anchor-point) scroll-py-1 overflow-y-auto overscroll-contain rounded-[12px] bg-overlay p-0 text-sm [box-shadow:var(--overlay-shadow)] [&:focus-visible:not([data-focused])]:outline-none data-[focus-visible=true]:outline-none data-[entering=true]:[animation:olis-overlay-enter-98_150ms_var(--ease-smooth)] [&[data-entering=true][data-placement=top]]:[animation-name:olis-overlay-enter-98-y] [&[data-entering=true][data-placement=bottom]]:[animation-name:olis-overlay-enter-98-ny] [&[data-entering=true][data-placement=left]]:[animation-name:olis-overlay-enter-98-x] [&[data-entering=true][data-placement=right]]:[animation-name:olis-overlay-enter-98-nx] data-[exiting=true]:pointer-events-none data-[exiting=true]:[animation:olis-overlay-exit_100ms_var(--ease-smooth)] [&[data-exiting=true][data-placement]]:[animation:olis-overlay-exit_100ms_var(--ease-smooth)] [&_[data-slot=popover-overlay-arrow]]:fill-overlay [&[data-placement=bottom]_[data-slot=popover-overlay-arrow]]:rotate-180 [&[data-placement=left]_[data-slot=popover-overlay-arrow]]:-rotate-90 [&[data-placement=right]_[data-slot=popover-overlay-arrow]]:rotate-90 [&_[data-slot=list-box]]:p-1.5 [&_[data-slot=list-box]]:outline-none [&_[data-slot=list-box-item]]:px-2.5 [&_[data-slot=list-box-item]:has(.list-box-item__indicator)]:pe-7 [&_[data-slot=list-box]:not([aria-multiselectable=true])_[data-slot=list-box-item-indicator]]:transition-none [&_[data-slot=list-box]:not([aria-multiselectable=true])_[data-slot=list-box-item-indicator--checkmark]]:transition-none"
  end

  defp dropdown_popover_classes do
    [
      "dropdown__popover olis-dropdown-popover scrollbar fixed inset-auto m-0 max-h-[min(24rem,calc(100dvh-2rem))] w-max min-w-[min(13.75rem,calc(100vw-2rem))] max-w-[calc(100vw-2rem)] scroll-py-1 overflow-y-auto overscroll-contain rounded-[12px] border-0 bg-overlay p-0 text-sm [&:focus-visible:not([data-focused])]:outline-none data-[focus-visible=true]:outline-none [&_[data-slot=menu-item]]:px-2.5 [&_[role=menuitem]:disabled]:cursor-not-allowed [&_[role=menuitem]:disabled]:opacity-50 [@media(hover:none)_and_(pointer:coarse)]:[&[data-placement]:not([data-exiting=true])]:opacity-100! [@media(hover:none)_and_(pointer:coarse)]:[&[data-placement]:not([data-exiting=true])]:[clip:auto]! [@media(hover:none)_and_(pointer:coarse)]:[&[data-placement]:not([data-exiting=true])]:[clip-path:none]! [@media(hover:none)_and_(pointer:coarse)]:[&[data-placement]:not([data-exiting=true])]:[mask-image:none]!",
      overlay_motion_classes()
    ]
  end

  defp overlay_motion_classes do
    "origin-(--trigger-anchor-point) [box-shadow:var(--overlay-shadow)] data-[entering=true]:[animation:olis-overlay-enter-98_150ms_var(--ease-smooth)] [&[data-entering=true][data-placement=top]]:[animation-name:olis-overlay-enter-98-y] [&[data-entering=true][data-placement=bottom]]:[animation-name:olis-overlay-enter-98-ny] [&[data-entering=true][data-placement=left]]:[animation-name:olis-overlay-enter-98-x] [&[data-entering=true][data-placement=right]]:[animation-name:olis-overlay-enter-98-nx] data-[exiting=true]:pointer-events-none data-[exiting=true]:[animation:olis-overlay-exit_100ms_var(--ease-smooth)] [&[data-exiting=true][data-placement]]:[animation:olis-overlay-exit_100ms_var(--ease-smooth)]"
  end

  defp field_error_classes do
    "field-error h-0 px-1 text-xs wrap-break-word text-danger opacity-0 data-visible:h-auto data-visible:opacity-100 [transition:opacity_150ms_var(--ease-out),height_350ms_var(--ease-smooth)] [:is(.checkbox,.switch,.radio)>&]:m-0 [:is(.checkbox,.switch,.radio)>&]:h-auto [:is(.checkbox,.switch,.radio)>&]:min-h-0 [:is(.checkbox,.switch,.radio)>&]:p-0 [:is(.checkbox,.switch,.radio)>&]:text-muted [:is(.checkbox,.switch,.radio)>&]:opacity-100 [:is(.checkbox,.switch,.radio)>&]:transition-none"
  end

  defp close_button_classes(compact \\ false) do
    [
      if(compact,
        do: "size-5 hover:bg-default [@media(hover:hover)]:data-[hovered=true]:bg-default",
        else:
          "size-6 hover:bg-default-hover [@media(hover:hover)]:data-[hovered=true]:bg-default-hover"
      ),
      "close-button close-button--default relative isolate inline-flex shrink-0 origin-center items-center justify-center rounded-xl bg-default p-1 text-muted select-none no-highlight transform-gpu cursor-(--cursor-interactive) [transition:transform_250ms_var(--ease-out-quart),color_150ms_var(--ease-out),background-color_100ms_var(--ease-out),box-shadow_150ms_var(--ease-out)] [&:focus-visible:not([data-focused])]:status-focused data-[focus-visible=true]:status-focused disabled:status-disabled aria-disabled:status-disabled data-[pending=true]:status-pending active:[transform:scale(.93)] data-[pressed=true]:[transform:scale(.93)] [&_svg]:pointer-events-none [&_svg]:size-4 [&_svg]:shrink-0 [&_svg]:self-center [&_svg]:-mx-0.5 [&_svg]:my-0.5"
    ]
  end

  defp input_classes(variant) do
    [
      "input rounded-[6px] border border-[length:var(--border-width-field)] border-field-border bg-(--input-bg) px-3 py-2 text-base text-field-foreground outline-none placeholder:text-field-placeholder sm:text-sm [transition:background-color_150ms_var(--ease-smooth),border-color_150ms_var(--ease-smooth),box-shadow_150ms_var(--ease-out)] [@media(hover:hover)]:[&:hover:not(:focus):not(:focus-visible)]:[--input-bg:var(--input-bg-hover)] [@media(hover:hover)]:[&:hover:not(:focus):not(:focus-visible)]:border-field-border-hover [@media(hover:hover)]:[&[data-hovered=true]:not([data-focused=true]):not([data-focus-visible=true])]:[--input-bg:var(--input-bg-hover)] [@media(hover:hover)]:[&[data-hovered=true]:not([data-focused=true]):not([data-focus-visible=true])]:border-field-border-hover focus:status-focused-field focus:border-field-border-focus focus:[--input-bg:var(--input-bg-focus)] data-[focused=true]:status-focused-field data-[focused=true]:border-field-border-focus data-[focused=true]:[--input-bg:var(--input-bg-focus)] data-[invalid=true]:status-invalid-field data-[invalid=true]:[--input-bg:var(--input-bg-focus)] disabled:status-disabled data-[disabled=true]:status-disabled aria-disabled:status-disabled [--input-autofill-shadow:0_0_0_1000px_var(--input-bg)_inset,var(--tw-inset-shadow,0_0_#0000),var(--tw-inset-ring-shadow,0_0_#0000),var(--tw-ring-offset-shadow,0_0_#0000),var(--tw-ring-shadow,0_0_#0000),var(--tw-shadow,0_0_#0000)] [&:is(:-webkit-autofill,:autofill)]:[background-color:var(--input-bg)] [&:is(:-webkit-autofill,:autofill)]:[box-shadow:var(--input-autofill-shadow)] [&:is(:-webkit-autofill,:autofill)]:[-webkit-box-shadow:var(--input-autofill-shadow)] [&:is(:-webkit-autofill,:autofill)]:[-webkit-text-fill-color:var(--field-foreground)] [&:is(:-webkit-autofill,:autofill)]:[caret-color:var(--field-foreground)] [&:is(:-webkit-autofill,:autofill)]:[transition:background-color_9999s_ease-in-out_0s,border-color_150ms_var(--ease-smooth)] [@media(prefers-reduced-motion:reduce)]:[&:is(:-webkit-autofill,:autofill)]:[transition:background-color_9999s_ease-in-out_0s]",
      "input--#{variant}",
      variant == "primary" &&
        "[--input-bg:var(--field-background,var(--default))] [--input-bg-hover:var(--field-hover)] [--input-bg-focus:var(--field-focus)] shadow-field",
      variant == "secondary" &&
        "[--input-bg:var(--default)] [--input-bg-hover:var(--default-hover)] [--input-bg-focus:var(--default)] shadow-none"
    ]
  end

  defp textarea_classes(variant) do
    [
      "textarea rounded-[6px] border border-[length:var(--border-width-field)] border-field-border bg-(--textarea-bg) px-3 py-2 text-base text-field-foreground outline-none placeholder:text-field-placeholder sm:text-sm [transition:background-color_150ms_var(--ease-smooth),border-color_150ms_var(--ease-smooth),box-shadow_150ms_var(--ease-out)] [@media(hover:hover)]:[&:hover:not(:focus):not(:focus-visible)]:[--textarea-bg:var(--textarea-bg-hover)] [@media(hover:hover)]:[&:hover:not(:focus):not(:focus-visible)]:border-field-border-hover [@media(hover:hover)]:[&[data-hovered=true]:not([data-focused=true]):not([data-focus-visible=true])]:[--textarea-bg:var(--textarea-bg-hover)] [@media(hover:hover)]:[&[data-hovered=true]:not([data-focused=true]):not([data-focus-visible=true])]:border-field-border-hover focus:status-focused-field focus:border-field-border-focus focus:[--textarea-bg:var(--textarea-bg-focus)] data-[focused=true]:status-focused-field data-[focused=true]:border-field-border-focus data-[focused=true]:[--textarea-bg:var(--textarea-bg-focus)] data-[invalid=true]:status-invalid-field data-[invalid=true]:[--textarea-bg:var(--textarea-bg-focus)] disabled:status-disabled data-[disabled=true]:status-disabled aria-disabled:status-disabled [--textarea-autofill-shadow:0_0_0_1000px_var(--textarea-bg)_inset,var(--tw-inset-shadow,0_0_#0000),var(--tw-inset-ring-shadow,0_0_#0000),var(--tw-ring-offset-shadow,0_0_#0000),var(--tw-ring-shadow,0_0_#0000),var(--tw-shadow,0_0_#0000)] [&:is(:-webkit-autofill,:autofill)]:[background-color:var(--textarea-bg)] [&:is(:-webkit-autofill,:autofill)]:[box-shadow:var(--textarea-autofill-shadow)] [&:is(:-webkit-autofill,:autofill)]:[-webkit-box-shadow:var(--textarea-autofill-shadow)] [&:is(:-webkit-autofill,:autofill)]:[-webkit-text-fill-color:var(--field-foreground)] [&:is(:-webkit-autofill,:autofill)]:[caret-color:var(--field-foreground)] [&:is(:-webkit-autofill,:autofill)]:[transition:background-color_9999s_ease-in-out_0s,border-color_150ms_var(--ease-smooth)] [@media(prefers-reduced-motion:reduce)]:[&:is(:-webkit-autofill,:autofill)]:[transition:background-color_9999s_ease-in-out_0s] min-h-[38px] [&.textarea--full-width]:w-full",
      "textarea--#{variant}",
      variant == "primary" &&
        "[--textarea-bg:var(--field-background,var(--default))] [--textarea-bg-hover:var(--field-hover)] [--textarea-bg-focus:var(--field-focus)] shadow-field",
      variant == "secondary" &&
        "[--textarea-bg:var(--default)] [--textarea-bg-hover:var(--default-hover)] [--textarea-bg-focus:var(--default)] shadow-none"
    ]
  end

  @doc "A styled native input. Supply an accessible label or aria-label."
  attr(:id, :string, default: nil)
  attr(:name, :string, default: nil)
  attr(:value, :any, default: nil)
  attr(:type, :string, default: "text")
  attr(:variant, :string, default: "primary", values: ~w(primary secondary))
  attr(:invalid, :boolean, default: false)
  attr(:full_width, :boolean, default: false)
  attr(:class, :any, default: nil)

  attr(:rest, :global,
    include:
      ~w(autocomplete autofocus disabled form max maxlength min minlength pattern placeholder readonly required step multiple)
  )

  def input(assigns) do
    ~H"""
    <input
      id={@id}
      name={@name}
      type={@type}
      value={@value}
      aria-invalid={to_string(@invalid)}
      data-invalid={if @invalid, do: "true"}
      class={[input_classes(@variant), @full_width && "input--full-width w-full", @class]}
      {@rest}
    />
    """
  end

  @doc "A labelled input or textarea with optional description and errors. Accepts a Phoenix form field."
  attr(:field, Phoenix.HTML.FormField, default: nil)
  attr(:id, :string, default: nil)
  attr(:name, :string, default: nil)
  attr(:value, :any, default: nil)
  attr(:label, :string, default: nil)
  attr(:description, :string, default: nil)
  attr(:errors, :list, default: [])
  attr(:type, :string, default: "text")
  attr(:multiline, :boolean, default: false)
  attr(:invalid, :boolean, default: false)
  attr(:variant, :string, default: "primary", values: ~w(primary secondary))
  attr(:class, :any, default: nil)
  attr(:input_class, :any, default: nil)

  attr(:rest, :global,
    include:
      ~w(autocomplete autofocus cols disabled form max maxlength min minlength pattern placeholder readonly required rows step wrap)
  )

  def text_field(assigns) do
    field = assigns.field

    assigns =
      assigns
      |> assign(:id, assigns.id || (field && field.id))
      |> assign(:name, assigns.name || (field && field.name))
      |> assign(:value, if(is_nil(assigns.value) && field, do: field.value, else: assigns.value))

    if is_nil(assigns.id), do: raise(ArgumentError, "text_field requires an id or field")

    invalid = assigns.invalid || assigns.errors != []
    {external_description, rest} = Map.pop(assigns.rest, :"aria-describedby")
    {external_description_string, rest} = Map.pop(rest, "aria-describedby")

    if (is_nil(assigns.label) or assigns.label == "") and
         !(rest[:"aria-label"] || rest["aria-label"] || rest[:"aria-labelledby"] ||
             rest["aria-labelledby"]),
       do: raise(ArgumentError, "text_field requires a label, aria-label, or aria-labelledby")

    describedby =
      [
        external_description,
        external_description_string,
        !invalid && assigns.description && "#{assigns.id}-description",
        assigns.errors != [] && "#{assigns.id}-errors"
      ]
      |> Enum.filter(& &1)
      |> Enum.join(" ")

    assigns = assign(assigns, rest: rest, describedby: describedby, invalid_state: invalid)

    ~H"""
    <div
      class={[
        "textfield flex flex-col gap-1 [&:is([data-invalid=true],[aria-invalid=true])_[data-slot=description]]:hidden [&.textfield--full-width]:w-full [&.textfield--full-width_[data-slot=input]]:w-full [&.textfield--full-width_[data-slot=textarea]]:w-full",
        "textfield--full-width",
        @class
      ]}
      data-slot="textfield"
      data-invalid={if @invalid_state, do: "true"}
      data-disabled={if @rest[:disabled] || @rest["disabled"], do: "true"}
      data-required={if @rest[:required] || @rest["required"], do: "true"}
      data-readonly={if @rest[:readonly] || @rest["readonly"], do: "true"}
    >
      <label :if={@label && @label != ""} class={label_classes()} data-slot="label" for={@id}>{@label}</label>
      <.input
        :if={!@multiline}
        id={@id}
        name={@name}
        value={@value}
        type={@type}
        variant={@variant}
        invalid={@invalid_state}
        full_width
        class={@input_class}
        data-slot="input"
        aria-describedby={if @describedby != "", do: @describedby}
        {@rest}
      />
      <.textarea
        :if={@multiline}
        id={@id}
        name={@name}
        value={@value}
        variant={@variant}
        invalid={@invalid_state}
        class={@input_class}
        data-slot="textarea"
        aria-describedby={if @describedby != "", do: @describedby}
        {@rest}
      />
      <span
        :if={@description}
        class="description text-xs text-wrap wrap-break-word text-muted"
        data-slot="description"
        id={"#{@id}-description"}
      >{@description}</span>
      <div
        :if={@errors != []}
        class={field_error_classes()}
        data-visible="true"
        data-slot="field-error"
        id={"#{@id}-errors"}
      >
        <p :for={error <- @errors}>{error}</p>
      </div>
    </div>
    """
  end

  @doc "Groups related form controls with a native legend, description, and optional actions."
  attr(:id, :string, required: true)
  attr(:legend, :string, default: nil)
  attr(:description, :string, default: nil)
  attr(:disabled, :boolean, default: false)
  attr(:class, :any, default: nil)
  attr(:group_class, :any, default: nil)
  attr(:actions_class, :any, default: nil)
  attr(:rest, :global, include: ~w(form name))
  slot(:inner_block, required: true)
  slot(:legend_content)
  slot(:actions)

  def fieldset(assigns) do
    if (is_nil(assigns.legend) or assigns.legend == "") and assigns.legend_content == [],
      do: raise(ArgumentError, "fieldset requires a legend")

    if assigns.legend && assigns.legend_content != [],
      do: raise(ArgumentError, "fieldset accepts either legend or legend_content")

    rest_description =
      Map.get(assigns.rest, :"aria-describedby") || Map.get(assigns.rest, "aria-describedby")

    describedby =
      Enum.reject(
        [rest_description, assigns.description && "#{assigns.id}-description"],
        &is_nil/1
      )
      |> Enum.join(" ")

    rest = assigns.rest |> Map.delete(:"aria-describedby") |> Map.delete("aria-describedby")

    assigns =
      assign(assigns, rest: rest, describedby: if(describedby == "", do: nil, else: describedby))

    ~H"""
    <fieldset
      id={@id}
      disabled={@disabled}
      class={["fieldset flex flex-col gap-6 shrink grow basis-0", @class]}
      data-slot="fieldset"
      aria-describedby={@describedby}
      {@rest}
    >
      <legend
        class="fieldset__legend text-base font-medium text-foreground"
        data-slot="fieldset-legend"
      >
        {if @legend_content == [], do: @legend, else: render_slot(@legend_content)}
      </legend>
      <span
        :if={@description}
        id={"#{@id}-description"}
        class="description text-xs text-wrap wrap-break-word text-muted"
        data-slot="description"
      >{@description}</span>
      <div
        class={["fieldset__field-group w-full space-y-4", @group_class]}
        data-slot="fieldset-field-group"
      >
        {render_slot(@inner_block)}
      </div>
      <div
        :if={@actions != []}
        class={["fieldset__actions flex items-center gap-2 pt-1", @actions_class]}
        data-slot="fieldset-actions"
      >
        {render_slot(@actions)}
      </div>
    </fieldset>
    """
  end

  @doc "A labelled input or textarea with optional prefix and suffix content."
  attr(:field, Phoenix.HTML.FormField, default: nil)
  attr(:id, :string, default: nil)
  attr(:name, :string, default: nil)
  attr(:value, :any, default: nil)
  attr(:label, :string, default: nil)
  attr(:description, :string, default: nil)
  attr(:errors, :list, default: [])
  attr(:invalid, :boolean, default: false)
  attr(:disabled, :boolean, default: false)
  attr(:type, :string, default: "text")
  attr(:multiline, :boolean, default: false)
  attr(:variant, :string, default: "primary", values: ~w(primary secondary))
  attr(:full_width, :boolean, default: false)
  attr(:class, :any, default: nil)
  attr(:group_class, :any, default: nil)
  attr(:input_class, :any, default: nil)

  attr(:rest, :global,
    include:
      ~w(autocomplete autofocus cols form max maxlength min minlength pattern placeholder readonly required rows step)
  )

  slot :prefix do
    attr(:class, :any)
  end

  slot :suffix do
    attr(:class, :any)
  end

  def input_group(assigns) do
    field = assigns.field
    id = assigns.id || (field && field.id)
    if is_nil(id), do: raise(ArgumentError, "input_group requires an id or field")
    value = if is_nil(assigns.value) && field, do: field.value, else: assigns.value
    invalid = assigns.invalid || assigns.errors != []
    {external_description, rest} = Map.pop(assigns.rest, :"aria-describedby")
    {external_description_string, rest} = Map.pop(rest, "aria-describedby")

    describedby =
      [
        external_description,
        external_description_string,
        !invalid && assigns.description && "#{id}-description",
        assigns.errors != [] && "#{id}-errors"
      ]
      |> Enum.filter(& &1)
      |> Enum.join(" ")

    assigns =
      assigns
      |> assign(:id, id)
      |> assign(:name, assigns.name || (field && field.name))
      |> assign(:value, value)
      |> assign(:invalid, invalid)
      |> assign(:rest, rest)
      |> assign(:describedby, describedby)

    ~H"""
    <div
      class={[
        "textfield flex flex-col gap-1 [&:is([data-invalid=true],[aria-invalid=true])_[data-slot=description]]:hidden [&.textfield--full-width]:w-full [&.textfield--full-width_[data-slot=input]]:w-full [&.textfield--full-width_[data-slot=textarea]]:w-full",
        @full_width && "textfield--full-width",
        @class
      ]}
      data-invalid={if @invalid, do: "true"}
    >
      <label :if={@label} class={label_classes()} for={@id}>{@label}</label>
      <div
        class={[
          "input-group input-group--#{@variant} has-[>.input-group__input:disabled]:status-disabled inline-flex min-h-9 rounded-field border border-[length:var(--border-width-field)] border-field-border bg-(--input-group-bg) text-sm text-field-foreground outline-none [transition:background-color_150ms_var(--ease-smooth),border-color_150ms_var(--ease-smooth),box-shadow_150ms_var(--ease-out)] [@media(hover:hover)]:[&:hover:not(:focus-within)]:[--input-group-bg:var(--input-group-bg-hover)] [@media(hover:hover)]:[&:hover:not(:focus-within)]:border-field-border-hover [@media(hover:hover)]:[&[data-hovered=true]:not([data-focus-within=true])]:[--input-group-bg:var(--input-group-bg-hover)] [@media(hover:hover)]:[&[data-hovered=true]:not([data-focus-within=true])]:border-field-border-hover has-[[data-slot=input-group-input]:focus]:status-focused-field has-[[data-slot=input-group-input]:focus]:border-field-border-focus has-[[data-slot=input-group-input]:focus]:[--input-group-bg:var(--input-group-bg-focus)] has-[[data-slot=input-group-textarea]:focus]:status-focused-field has-[[data-slot=input-group-textarea]:focus]:border-field-border-focus has-[[data-slot=input-group-textarea]:focus]:[--input-group-bg:var(--input-group-bg-focus)] data-[invalid=true]:status-invalid-field data-[invalid=true]:border-[color:var(--color-field-border-invalid)] data-[invalid=true]:[--input-group-bg:var(--input-group-bg-focus)] data-[disabled=true]:status-disabled aria-disabled:status-disabled",
          @variant == "primary" &&
            "[--input-group-bg:var(--field-background,var(--default))] [--input-group-bg-hover:var(--field-hover)] [--input-group-bg-focus:var(--field-focus)] shadow-field",
          @variant == "secondary" &&
            "[--input-group-bg:var(--default)] [--input-group-bg-hover:var(--default-hover)] [--input-group-bg-focus:var(--default)] shadow-none",
          @multiline && "h-auto flex-wrap items-start",
          !@multiline && "items-center",
          @multiline && @suffix != [] && "after:order-1 after:h-0 after:basis-full after:content-['']",
          @full_width && "input-group--full-width w-full",
          @group_class
        ]}
        data-slot="input-group"
        data-olis-input-group
        x-data="olisInputGroup"
        x-on:click="focusInput($event)"
        data-invalid={if @invalid, do: "true"}
        data-disabled={if @disabled, do: "true"}
      >
        <div
          :for={prefix <- @prefix}
          class={[
            "input-group__prefix flex justify-center rounded-s-field rounded-e-none bg-transparent px-3 text-field-placeholder [transition:background-color_150ms_var(--ease-smooth),border-color_150ms_var(--ease-smooth)]",
            @multiline && "h-auto items-start self-stretch border-0 pt-3",
            !@multiline &&
              "h-full items-center border-e-[length:var(--border-width-field)] border-e-field-border",
            prefix[:class]
          ]}
          data-slot="input-group-prefix"
        >
          {render_slot(prefix)}
        </div>
        <textarea
          :if={@multiline}
          id={@id}
          name={@name}
          disabled={@disabled}
          class={[
            "input-group__input flex-1 rounded-field border-0 bg-transparent px-3 py-2 text-base shadow-none outline-none placeholder:text-field-placeholder sm:text-sm focus:outline-none focus-visible:outline-none [&:is(:-webkit-autofill,:autofill)]:appearance-none [&:is(:-webkit-autofill,:autofill)]:[-webkit-appearance:none] [&:is(:-webkit-autofill,:autofill)]:[clip-path:inset(0_round_var(--radius-field))] [&:is(:-webkit-autofill,:autofill)]:[box-shadow:0_0_0_1000px_var(--input-group-bg)_inset] [&:is(:-webkit-autofill,:autofill)]:[-webkit-box-shadow:0_0_0_1000px_var(--input-group-bg)_inset] [&:is(:-webkit-autofill,:autofill)]:[-webkit-text-fill-color:var(--field-foreground)] [&:is(:-webkit-autofill,:autofill)]:[caret-color:var(--field-foreground)] [&:is(:-webkit-autofill,:autofill)]:[transition:background-color_9999s_ease-in-out_0s]",
            @prefix != [] && "rounded-s-none ps-0",
            @suffix != [] && "rounded-e-none",
            "min-h-[38px] min-w-0 resize-y py-3 pe-3",
            @input_class
          ]}
          data-slot="input-group-textarea"
          aria-invalid={if @invalid, do: "true"}
          aria-describedby={if @describedby != "", do: @describedby}
          {@rest}
        >{@value}</textarea>
        <input
          :if={!@multiline}
          id={@id}
          name={@name}
          type={@type}
          value={@value}
          disabled={@disabled}
          class={[
            "input-group__input flex-1 rounded-field border-0 bg-transparent px-3 py-2 text-base shadow-none outline-none placeholder:text-field-placeholder sm:text-sm focus:outline-none focus-visible:outline-none [&:is(:-webkit-autofill,:autofill)]:appearance-none [&:is(:-webkit-autofill,:autofill)]:[-webkit-appearance:none] [&:is(:-webkit-autofill,:autofill)]:[clip-path:inset(0_round_var(--radius-field))] [&:is(:-webkit-autofill,:autofill)]:[box-shadow:0_0_0_1000px_var(--input-group-bg)_inset] [&:is(:-webkit-autofill,:autofill)]:[-webkit-box-shadow:0_0_0_1000px_var(--input-group-bg)_inset] [&:is(:-webkit-autofill,:autofill)]:[-webkit-text-fill-color:var(--field-foreground)] [&:is(:-webkit-autofill,:autofill)]:[caret-color:var(--field-foreground)] [&:is(:-webkit-autofill,:autofill)]:[transition:background-color_9999s_ease-in-out_0s]",
            @prefix != [] && "rounded-s-none ps-0",
            @suffix != [] && "rounded-e-none pe-0",
            @input_class
          ]}
          data-slot="input-group-input"
          aria-invalid={if @invalid, do: "true"}
          aria-describedby={if @describedby != "", do: @describedby}
          {@rest}
        />
        <div
          :for={suffix <- @suffix}
          class={[
            "input-group__suffix flex items-center justify-center rounded-s-none rounded-e-field bg-transparent text-field-placeholder [transition:background-color_150ms_var(--ease-smooth),border-color_150ms_var(--ease-smooth)]",
            @multiline && "order-2 ms-auto h-auto border-0 px-2 pt-1 pb-2",
            !@multiline &&
              "h-full border-s-[length:var(--border-width-field)] border-s-field-border px-3",
            suffix[:class]
          ]}
          data-slot="input-group-suffix"
        >
          {render_slot(suffix)}
        </div>
      </div>
      <p
        :if={@description}
        id={"#{@id}-description"}
        class="description text-xs text-wrap wrap-break-word text-muted"
        data-slot="description"
      >
        {@description}
      </p>
      <div
        :if={@errors != []}
        id={"#{@id}-errors"}
        class={field_error_classes()}
        data-visible="true"
        data-slot="field-error"
      >
        <p :for={error <- @errors}>{error}</p>
      </div>
    </div>
    """
  end

  @doc "A search input with a clear button, form-field support, and OlisUI styles."
  attr(:field, Phoenix.HTML.FormField, default: nil)
  attr(:id, :string, default: nil)
  attr(:name, :string, default: nil)
  attr(:value, :any, default: nil)
  attr(:label, :string, default: nil)
  attr(:description, :string, default: nil)
  attr(:errors, :list, default: [])
  attr(:variant, :string, default: "primary", values: ~w(primary secondary))
  attr(:full_width, :boolean, default: false)
  attr(:class, :any, default: nil)

  attr(:rest, :global,
    include:
      ~w(autocomplete autofocus disabled form maxlength minlength pattern placeholder readonly required)
  )

  def search_field(assigns) do
    field = assigns.field
    id = assigns.id || (field && field.id)
    if is_nil(id), do: raise(ArgumentError, "search_field requires an id or field")

    value = if is_nil(assigns.value) && field, do: field.value, else: assigns.value
    {external_description, rest} = Map.pop(assigns.rest, :"aria-describedby")
    {external_description_string, rest} = Map.pop(rest, "aria-describedby")

    describedby =
      [
        external_description,
        external_description_string,
        assigns.errors == [] && assigns.description && "#{id}-description",
        assigns.errors != [] && "#{id}-errors"
      ]
      |> Enum.filter(& &1)
      |> Enum.join(" ")

    assigns =
      assigns
      |> assign(:id, id)
      |> assign(:name, assigns.name || (field && field.name))
      |> assign(:value, value)
      |> assign(:rest, rest)
      |> assign(:describedby, describedby)

    ~H"""
    <div
      id={"#{@id}-search-field"}
      class={[
        search_field_classes(),
        "search-field--#{@variant}",
        @full_width && "search-field--full-width w-full",
        @class
      ]}
      data-olis-search-field
      data-slot="search-field"
      data-empty={to_string(is_nil(@value) || @value == "")}
      data-invalid={if @errors != [], do: "true"}
      x-data="olisSearchField"
      x-init="$nextTick(() => sync())"
      x-on:input="sync()"
      x-on:phx:update.window="sync()"
      x-on:reset.window="$nextTick(() => sync())"
      x-bind:data-empty="empty.toString()"
      x-bind:data-olis-search-ready="'true'"
      phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["data-empty", "data-olis-search-ready"])}
    >
      <label :if={@label} class={label_classes()} data-slot="label" for={@id}>{@label}</label>
      <div
        class={[search_group_classes(), @full_width && "search-field__group--full-width w-full"]}
        data-slot="search-field-group"
        data-invalid={if @errors != [], do: "true"}
        data-disabled={if @rest[:disabled] || @rest["disabled"], do: "true"}
      >
        <svg
          aria-hidden="true"
          role="presentation"
          viewBox="0 0 16 16"
          class="search-field__search-icon pointer-events-none shrink-0 text-field-placeholder ms-3 me-0 size-4"
          data-slot="search-field-search-icon"
        ><path
          fill="currentColor"
          fill-rule="evenodd"
          clip-rule="evenodd"
          d="M11.5 7a4.5 4.5 0 1 1-9 0a4.5 4.5 0 0 1 9 0m-.82 4.74a6 6 0 1 1 1.06-1.06l2.79 2.79a.75.75 0 1 1-1.06 1.06z"
        /></svg>
        <input
          id={@id}
          name={@name}
          value={@value}
          type="search"
          x-ref="input"
          class={search_input_classes()}
          data-slot="search-field-input"
          aria-invalid={if @errors != [], do: "true"}
          aria-describedby={if @describedby != "", do: @describedby}
          {@rest}
        />
        <.close_button
          label="Clear search"
          class={search_clear_classes()}
          data-slot="search-field-clear-button"
          data-olis-search-clear
          slot="clear"
          hidden
          x-bind:hidden="false"
          x-bind:disabled="empty || locked"
          x-bind:aria-hidden="empty.toString()"
          x-on:click="clear()"
        />
      </div>
      <p
        :if={@description}
        id={"#{@id}-description"}
        class="description text-xs text-wrap wrap-break-word text-muted"
        data-slot="description"
      >
        {@description}
      </p>
      <div
        :if={@errors != []}
        id={"#{@id}-errors"}
        class={field_error_classes()}
        data-visible="true"
        data-slot="field-error"
      >
        <p :for={error <- @errors}>{error}</p>
      </div>
    </div>
    """
  end

  @doc "A one-time-code field backed by a single native form input."
  attr(:field, Phoenix.HTML.FormField, default: nil)
  attr(:id, :string, default: nil)
  attr(:name, :string, default: nil)
  attr(:value, :any, default: nil)
  attr(:label, :string, default: nil)
  attr(:description, :string, default: nil)
  attr(:errors, :list, default: [])
  attr(:length, :integer, default: 6)
  attr(:groups, :list, default: nil)
  attr(:variant, :string, default: "primary", values: ~w(primary secondary))
  attr(:allowed_pattern, :string, default: nil)
  attr(:autocomplete, :string, default: "one-time-code")
  attr(:inputmode, :string, default: "numeric")
  attr(:spellcheck, :string, default: "false")
  attr(:class, :any, default: nil)

  attr(:rest, :global, include: ~w(autofocus disabled form pattern placeholder readonly required))

  def input_otp(assigns) do
    field = assigns.field
    id = assigns.id || (field && field.id)
    if is_nil(id), do: raise(ArgumentError, "input_otp requires an id or field")
    length = assigns.length
    groups = assigns.groups || if(length == 6, do: [3, 3], else: [length])

    unless length > 0 and groups != [] and Enum.all?(groups, &(is_integer(&1) and &1 > 0)) and
             Enum.sum(groups) == length do
      raise ArgumentError, "input_otp groups must contain positive sizes adding up to length"
    end

    {slot_groups, _} =
      Enum.map_reduce(groups, 0, fn size, start ->
        {Enum.to_list(start..(start + size - 1)), start + size}
      end)

    value = if is_nil(assigns.value) && field, do: field.value, else: assigns.value
    {external_description, rest} = Map.pop(assigns.rest, :"aria-describedby")
    {external_description_string, rest} = Map.pop(rest, "aria-describedby")

    describedby =
      [
        external_description,
        external_description_string,
        assigns.description && "#{id}-description",
        assigns.errors != [] && "#{id}-errors"
      ]
      |> Enum.filter(& &1)
      |> Enum.join(" ")

    assigns =
      assigns
      |> assign(:id, id)
      |> assign(:name, assigns.name || (field && field.name))
      |> assign(:value, value)
      |> assign(:slot_groups, slot_groups)
      |> assign(:rest, rest)
      |> assign(:describedby, describedby)

    ~H"""
    <div class={@class}>
      <label :if={@label} class={label_classes()} for={@id}>{@label}</label>
      <p
        :if={@description}
        id={"#{@id}-description"}
        class="description text-xs text-wrap wrap-break-word text-muted"
      >
        {@description}
      </p>
      <div
        id={"#{@id}-otp"}
        class={[
          "input-otp input-otp--#{@variant} relative flex w-full items-center gap-2 data-[disabled=true]:cursor-not-allowed data-[disabled=true]:opacity-50"
        ]}
        data-olis-otp
        x-data="olisInputOTP"
        x-on:input="onInput($event)"
        x-on:compositionend="onInput($event)"
        x-on:pointerdown="onPointerDown($event)"
        x-on:focusin="onFocus()"
        x-on:focusout="onFocus()"
        x-on:selectionchange.document="onSelection()"
        x-on:phx:update.document="sync()"
        x-on:reset.document="onReset($event)"
        data-invalid={if @errors != [], do: "true"}
        data-allowed-pattern={@allowed_pattern}
        phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["data-olis-otp-ready"])}
      >
        <div
          id={"#{@id}-slots"}
          class="olis-otp-slots hidden [[data-olis-otp-ready]_&]:contents"
          aria-hidden="true"
        >
          <%= for {group, index} <- Enum.with_index(@slot_groups) do %>
            <div
              :if={index > 0}
              class="input-otp__separator h-[2px] w-[6px] shrink-0 rounded-sm bg-separator"
              data-slot="input-otp-separator"
            >
            </div>
            <div class="input-otp__group flex min-w-0 items-center gap-2" data-slot="input-otp-group">
              <div
                :for={slot <- group}
                class={[
                  "input-otp__slot relative flex h-10 w-9.5 min-w-0 flex-1 items-center justify-center rounded-field border border-[length:var(--border-width-field)] border-field-border text-sm font-[590] text-field-foreground outline-none [transition:background-color_150ms_var(--ease-smooth),border-color_150ms_var(--ease-smooth),box-shadow_150ms_var(--ease-out)] data-[active=true]:z-10 data-[active=true]:status-focused-field data-[disabled=true]:status-disabled data-[invalid=true]:status-invalid-field",
                  @variant == "primary" &&
                    "bg-field shadow-field data-[invalid=true]:bg-field-focus hover:border-field-border-hover hover:bg-field-hover [@media(hover:hover)]:data-[hovered=true]:border-field-border-hover [@media(hover:hover)]:data-[hovered=true]:bg-field-hover data-[active=true]:bg-field-focus data-[filled=true]:bg-field-focus",
                  @variant == "secondary" &&
                    "bg-default shadow-none [&[data-invalid=true]:not([data-active=true]):not([data-filled=true])]:bg-field-focus hover:border-field-border-hover hover:bg-default-hover [@media(hover:hover)]:data-[hovered=true]:border-field-border-hover [@media(hover:hover)]:data-[hovered=true]:bg-default-hover data-[active=true]:bg-default data-[filled=true]:bg-default"
                ]}
                data-slot="input-otp-slot"
                data-olis-otp-index={slot}
              >
                <span
                  class="input-otp__slot-value origin-bottom animate-slot-value-in text-lg leading-6 tracking-[-0.27px]"
                  data-olis-otp-value
                  hidden
                ></span><span
                  class="input-otp__caret absolute h-4 w-[2px] animate-caret-blink rounded-sm bg-field-placeholder"
                  data-olis-otp-caret
                  hidden
                ></span>
              </div>
            </div>
          <% end %>
        </div>
        <input
          id={@id}
          name={@name}
          value={@value}
          type="text"
          maxlength={@length}
          inputmode={@inputmode}
          autocomplete={@autocomplete}
          spellcheck={@spellcheck}
          class={[
            input_classes("primary"),
            "input-otp__input [[data-olis-otp-ready]_&]:absolute [[data-olis-otp-ready]_&]:inset-0 [[data-olis-otp-ready]_&]:z-1 [[data-olis-otp-ready]_&]:size-full [[data-olis-otp-ready]_&]:cursor-text [[data-olis-otp-ready]_&]:border-0 [[data-olis-otp-ready]_&]:bg-transparent [[data-olis-otp-ready]_&]:p-0 [[data-olis-otp-ready]_&]:text-transparent [[data-olis-otp-ready]_&]:caret-transparent [[data-olis-otp-ready]_&]:shadow-none [[data-olis-otp-ready]_&]:outline-none"
          ]}
          data-olis-otp-input
          x-ref="input"
          aria-invalid={if @errors != [], do: "true"}
          aria-describedby={if @describedby != "", do: @describedby}
          {@rest}
        />
      </div>
      <div :if={@errors != []} id={"#{@id}-errors"} class={field_error_classes()} data-visible="true">
        <p :for={error <- @errors}>{error}</p>
      </div>
    </div>
    """
  end

  @doc "An OlisUI-styled section header. Use `as` to select an appropriate semantic tag."
  attr(:as, :string, default: "header", values: ~w(header div span h1 h2 h3 h4 h5 h6))
  attr(:class, :any, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def header(assigns) do
    data_slot =
      Map.get(assigns.rest, :"data-slot") || Map.get(assigns.rest, "data-slot") || "header"

    rest = Map.drop(assigns.rest, [:"data-slot", "data-slot"])
    assigns = assign(assigns, data_slot: data_slot, rest: rest)

    ~H"""
    <.dynamic_tag
      tag_name={@as}
      class={["header w-full px-2 pt-1.5 pb-1 text-start text-xs font-medium text-muted", @class]}
      data-slot={@data_slot}
      {@rest}
    >
      {render_slot(@inner_block)}
    </.dynamic_tag>
    """
  end

  @doc "A styled empty result message, with customizable content and semantic tag."
  attr(:as, :string, default: "div", values: ~w(div p span))
  attr(:message, :string, default: "No results found")
  attr(:class, :any, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  def empty_state(assigns) do
    data_slot =
      Map.get(assigns.rest, :"data-slot") || Map.get(assigns.rest, "data-slot") || "empty-state"

    rest = Map.drop(assigns.rest, [:"data-slot", "data-slot"])
    assigns = assign(assigns, data_slot: data_slot, rest: rest)

    ~H"""
    <.dynamic_tag
      tag_name={@as}
      class={["empty-state p-2 text-sm text-muted", @class]}
      data-slot={@data_slot}
      {@rest}
    >
      <%= if @inner_block == [] do %>
        {@message}
      <% else %>
        {render_slot(@inner_block)}
      <% end %>
    </.dynamic_tag>
    """
  end

  @doc """
  A card surface with optional header, title, description, content, and footer slots.
  Unslotted content remains a direct child of the card for backwards compatibility.
  """
  attr(:variant, :string, default: "default", values: ~w(default secondary tertiary transparent))
  attr(:heading_level, :integer, default: 3, values: [1, 2, 3, 4, 5, 6])
  attr(:header_class, :any, default: nil)
  attr(:class, :any, default: nil)
  attr(:rest, :global)
  slot(:inner_block)
  slot(:header)

  slot :title do
    attr(:class, :any)
    attr(:id, :string)
  end

  slot :description do
    attr(:class, :any)
    attr(:id, :string)
  end

  slot :content do
    attr(:class, :any)
    attr(:id, :string)
  end

  slot :footer do
    attr(:class, :any)
    attr(:id, :string)
  end

  def card(assigns) do
    data_slot =
      Map.get(assigns.rest, :"data-slot") || Map.get(assigns.rest, "data-slot") || "card"

    rest = Map.drop(assigns.rest, [:"data-slot", "data-slot"])
    assigns = assign(assigns, data_slot: data_slot, rest: rest)

    ~H"""
    <div
      class={[
        "card card--#{@variant} relative flex flex-col gap-3 overflow-visible rounded-[12px] border-[0.5px] border-border p-6",
        @variant == "transparent" && "border-none bg-transparent shadow-none",
        @variant == "default" && "bg-surface",
        @variant == "secondary" && "bg-surface-secondary",
        @variant == "tertiary" && "bg-surface-tertiary",
        @class
      ]}
      data-slot={@data_slot}
      {@rest}
    >
      <div
        :if={@header != [] || @title != [] || @description != []}
        class={["card__header flex flex-col", @header_class]}
        data-slot="card-header"
      >
        {render_slot(@header)}
        <.dynamic_tag
          :for={title <- @title}
          tag_name={"h#{@heading_level}"}
          id={title[:id]}
          class={["card__title text-sm leading-6 font-medium text-foreground", title[:class]]}
          data-slot="card-title"
        >
          {render_slot(title)}
        </.dynamic_tag>
        <p
          :for={description <- @description}
          id={description[:id]}
          class={["card__description text-sm leading-5 text-muted", description[:class]]}
          data-slot="card-description"
        >
          {render_slot(description)}
        </p>
      </div>
      {render_slot(@inner_block)}
      <div
        :for={content <- @content}
        id={content[:id]}
        class={["card__content flex flex-1 flex-col gap-1", content[:class]]}
        data-slot="card-content"
      >
        {render_slot(content)}
      </div>
      <div
        :for={footer <- @footer}
        id={footer[:id]}
        class={["card__footer flex flex-row items-center", footer[:class]]}
        data-slot="card-footer"
      >
        {render_slot(footer)}
      </div>
    </div>
    """
  end

  @doc "A compact label with OlisUI color, variant, and size options."
  attr(:variant, :string, default: "secondary", values: ~w(primary secondary tertiary soft))
  attr(:color, :string, default: "default", values: ~w(default accent success warning danger))
  attr(:size, :string, default: "md", values: ~w(sm md lg))
  attr(:class, :any, default: nil)
  attr(:label_class, :any, default: nil)
  attr(:wrap_label, :boolean, default: true)
  attr(:rest, :global)
  slot(:inner_block, required: true)
  slot(:prefix)
  slot(:suffix)

  def chip(assigns) do
    data_slot =
      Map.get(assigns.rest, :"data-slot") || Map.get(assigns.rest, "data-slot") || "chip"

    colors = %{
      "default" =>
        {"bg-default", "text-default-foreground", "bg-default-soft text-default-soft-foreground"},
      "accent" =>
        {"bg-accent text-accent-foreground", "text-accent-soft-foreground",
         "bg-accent-soft text-accent-soft-foreground"},
      "success" =>
        {"bg-success text-success-foreground", "text-success-soft-foreground",
         "bg-success-soft text-success-soft-foreground"},
      "warning" =>
        {"bg-warning text-warning-foreground", "text-warning-soft-foreground",
         "bg-warning-soft text-warning-soft-foreground"},
      "danger" =>
        {"bg-danger text-danger-foreground", "text-danger-soft-foreground",
         "bg-danger-soft text-danger-soft-foreground"}
    }

    {solid, foreground, soft} = colors[assigns.color]

    palette =
      case assigns.variant do
        "primary" -> if assigns.color == "default", do: "bg-default " <> foreground, else: solid
        "soft" -> soft
        "tertiary" -> "bg-transparent " <> foreground
        _ -> "bg-default " <> foreground
      end

    assigns =
      assign(assigns,
        data_slot: data_slot,
        palette: palette,
        rest: Map.drop(assigns.rest, [:"data-slot", "data-slot"])
      )

    ~H"""
    <span
      class={[
        "chip chip--#{@variant} chip--#{@color} chip--#{@size} inline-flex w-fit shrink-0 items-center gap-0.5 rounded-full leading-4 font-normal",
        @palette,
        @size == "sm" && "px-1 py-0 text-xs",
        @size == "md" && "px-3 py-1 text-xs",
        @size == "lg" && "px-3 py-1 text-sm",
        @class
      ]}
      data-slot={@data_slot}
      {@rest}
    >
      {render_slot(@prefix)}
      <%= if @wrap_label do %>
        <.chip_label class={@label_class}>{render_slot(@inner_block)}</.chip_label>
      <% else %>
        {render_slot(@inner_block)}
      <% end %>
      {render_slot(@suffix)}
    </span>
    """
  end

  @doc "A styled label for a composed chip."
  attr(:class, :any, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def chip_label(assigns) do
    data_slot =
      Map.get(assigns.rest, :"data-slot") || Map.get(assigns.rest, "data-slot") || "chip-label"

    assigns =
      assign(assigns,
        data_slot: data_slot,
        rest: Map.drop(assigns.rest, [:"data-slot", "data-slot"])
      )

    ~H"""
    <span class={["chip__label px-0.5", @class]} data-slot={@data_slot} {@rest}>{render_slot(
      @inner_block
    )}</span>
    """
  end

  @doc "An accessible OlisUI loading indicator."
  attr(:id, :string, default: nil)
  attr(:size, :string, default: "md", values: ~w(sm md lg xl))
  attr(:color, :string, default: "accent", values: ~w(current accent danger success warning))
  attr(:label, :string, default: "Loading")
  attr(:decorative, :boolean, default: false)
  attr(:class, :any, default: nil)
  attr(:rest, :global)

  def spinner(assigns) do
    assigns =
      assign(
        assigns,
        :gradient_id,
        assigns.id || "olis-spinner-#{System.unique_integer([:positive, :monotonic])}"
      )

    ~H"""
    <span
      id={@id}
      class={[
        "spinner spinner--#{@size} spinner--#{@color} pointer-events-none inline-flex shrink-0 animate-spin-fast",
        @size == "sm" && "size-4",
        @size == "md" && "size-6",
        @size == "lg" && "size-8",
        @size == "xl" && "size-10",
        @color == "current" && "text-inherit",
        @color == "accent" && "text-accent",
        @color == "danger" && "text-danger",
        @color == "success" && "text-success",
        @color == "warning" && "text-warning",
        @class
      ]}
      role={if !@decorative, do: "status"}
      aria-label={if !@decorative, do: @label}
      aria-hidden={if @decorative, do: "true"}
      data-slot="spinner"
      {@rest}
    >
      <svg data-slot="spinner-icon" viewBox="0 0 24 24" aria-hidden="true">
        <defs>
          <linearGradient id={"#{@gradient_id}-1"} x1="50%" x2="50%" y1="5.271%" y2="91.793%">
            <stop offset="0%" stop-color="currentColor" /><stop
              offset="100%"
              stop-color="currentColor"
              stop-opacity="0.55"
            />
          </linearGradient>
          <linearGradient id={"#{@gradient_id}-2"} x1="50%" x2="50%" y1="15.24%" y2="87.15%">
            <stop offset="0%" stop-color="currentColor" stop-opacity="0" /><stop
              offset="100%"
              stop-color="currentColor"
              stop-opacity="0.55"
            />
          </linearGradient>
        </defs>
        <g fill="none">
          <path
            d="M8.749.021a1.5 1.5 0 0 1 .497 2.958A7.5 7.5 0 0 0 3 10.375a7.5 7.5 0 0 0 7.5 7.5v3c-5.799 0-10.5-4.7-10.5-10.5C0 5.23 3.726.865 8.749.021"
            fill={"url(##{@gradient_id}-1)"}
            transform="translate(1.5 1.625)"
          />
          <path
            d="M15.392 2.673a1.5 1.5 0 0 1 2.119-.115A10.48 10.48 0 0 1 21 10.375c0 5.8-4.701 10.5-10.5 10.5v-3a7.5 7.5 0 0 0 5.007-13.084a1.5 1.5 0 0 1-.115-2.118"
            fill={"url(##{@gradient_id}-2)"}
            transform="translate(1.5 1.625)"
          />
        </g>
      </svg>
    </span>
    """
  end

  @doc "A decorative or semantic divider."
  attr(:orientation, :string, default: "horizontal", values: ~w(horizontal vertical))
  attr(:decorative, :boolean, default: true)
  attr(:class, :any, default: nil)

  def separator(assigns) do
    ~H"""
    <div
      class={[
        "separator separator--#{@orientation} separator--default shrink-0 rounded-sm border-t-0 border-b-0 bg-separator",
        @orientation == "horizontal" &&
          "h-px w-full [.toolbar_&]:w-1/2 [.toolbar_&]:justify-center [.toolbar_&]:justify-self-center",
        @orientation == "vertical" &&
          "h-auto min-h-2 w-px self-stretch [.toolbar_&]:h-1/2 [.toolbar_&]:self-center",
        @class
      ]}
      role={if @decorative, do: "none", else: "separator"}
      aria-orientation={if !@decorative && @orientation == "vertical", do: "vertical"}
    >
    </div>
    """
  end

  @doc """
  A placeholder for content that is loading. Set its dimensions with CSS.

  Set `animation_type` to `"shimmer"`, `"pulse"`, or `"none"`. When omitted,
  the `--skeleton-animation` CSS variable on the document root sets the default;
  shimmer is used when the variable is unset or Alpine has not initialized.
  """
  attr(:animation_type, :string, default: nil, values: [nil | ~w(shimmer pulse none)])
  attr(:class, :any, default: nil)
  attr(:rest, :global)

  def skeleton(assigns) do
    ~H"""
    <div
      class={[
        "skeleton skeleton--#{@animation_type || "shimmer"} pointer-events-none relative overflow-hidden rounded-sm bg-surface-tertiary/70",
        "[&.skeleton--pulse]:animate-pulse",
        "[&.skeleton--shimmer]:after:absolute [&.skeleton--shimmer]:after:inset-0 [&.skeleton--shimmer]:after:-translate-x-full [&.skeleton--shimmer]:after:animate-skeleton [&.skeleton--shimmer]:after:bg-linear-to-r [&.skeleton--shimmer]:after:from-transparent [&.skeleton--shimmer]:after:via-surface-tertiary [&.skeleton--shimmer]:after:to-transparent [&.skeleton--shimmer]:after:content-['']",
        "[&.skeleton--shimmer:has(.skeleton)]:after:content-none [&.skeleton--shimmer:has(.skeleton)_.skeleton]:after:content-none",
        "[&.skeleton--shimmer:has(.skeleton)]:before:pointer-events-none [&.skeleton--shimmer:has(.skeleton)]:before:absolute [&.skeleton--shimmer:has(.skeleton)]:before:inset-0 [&.skeleton--shimmer:has(.skeleton)]:before:z-10 [&.skeleton--shimmer:has(.skeleton)]:before:-translate-x-full [&.skeleton--shimmer:has(.skeleton)]:before:animate-skeleton [&.skeleton--shimmer:has(.skeleton)]:before:bg-[linear-gradient(90deg,transparent_0%,rgba(255,255,255,0.5)_50%,transparent_100%)] [&.skeleton--shimmer:has(.skeleton)]:before:mix-blend-overlay [&.skeleton--shimmer:has(.skeleton)]:before:content-['']",
        @class
      ]}
      x-data={
        if is_nil(@animation_type),
          do:
            "{ animation: getComputedStyle(document.documentElement).getPropertyValue('--skeleton-animation').trim() }"
      }
      x-bind:class={
        if is_nil(@animation_type),
          do:
            "{ 'skeleton--shimmer': !['pulse', 'none'].includes(animation), 'skeleton--pulse': animation === 'pulse', 'skeleton--none': animation === 'none' }"
      }
      aria-hidden="true"
      {@rest}
    >
    </div>
    """
  end

  defp checkbox_root_classes(variant) do
    [
      "checkbox flex flex-col items-start gap-1 outline-none no-highlight cursor-(--cursor-interactive) data-[disabled=true]:status-disabled [&>[data-slot=description]]:w-full [&>[data-slot=description]]:min-w-0 [&>[data-slot=description]]:cursor-default [&>[data-slot=description]]:ps-7 [&>[data-slot=description]]:text-xs [&>[data-slot=description]]:text-wrap [&>[data-slot=description]]:wrap-break-word [&>[data-slot=description]]:text-muted [&>[data-slot=description]]:select-none [&>[data-slot=field-error]]:w-full [&>[data-slot=field-error]]:min-w-0 [&>[data-slot=field-error]]:cursor-default [&>[data-slot=field-error]]:ps-7 [&>[data-slot=field-error]]:text-xs [&>[data-slot=field-error]]:text-wrap [&>[data-slot=field-error]]:wrap-break-word [&>[data-slot=field-error]]:text-muted [&>[data-slot=field-error]]:select-none [&_[data-slot=label]]:select-none [&_.checkbox__content_[data-slot=label]]:cursor-(--cursor-interactive) [&[data-disabled=true]_[data-slot=description]]:status-disabled [&[data-disabled=true]_[data-slot=field-error]]:status-disabled [&_[data-slot=checkbox-default-indicator--checkmark]]:size-2.5 [&_[data-slot=checkbox-default-indicator--checkmark]]:stroke-[2.5px] [&_[data-slot=checkbox-default-indicator--checkmark]]:text-accent-foreground [&_[data-slot=checkbox-default-indicator--checkmark]]:transition-all [&_[data-slot=checkbox-default-indicator--checkmark]]:duration-200 [&[data-selected=true]_[data-slot=checkbox-default-indicator--checkmark]]:[transition:stroke-dashoffset_150ms_linear_15ms] [&:is([data-invalid=true],[aria-invalid=true]):is([data-selected=true],[aria-checked=true])_[data-slot=checkbox-default-indicator--checkmark]]:text-danger-foreground [&[data-indeterminate=true]_[data-slot=checkbox-default-indicator--indeterminate]]:absolute [&[data-indeterminate=true]_[data-slot=checkbox-default-indicator--indeterminate]]:size-3 [&[data-indeterminate=true]:is([data-invalid=true],[aria-invalid=true])_[data-slot=checkbox-default-indicator--indeterminate]]:text-danger-foreground",
      "checkbox--#{variant}",
      "olis-native-checkbox"
    ]
  end

  defp checkbox_control_classes do
    "checkbox__control pointer-events-none relative inline-flex size-4 shrink-0 items-center justify-center overflow-hidden rounded-md border border-[length:var(--border-width-field)] border-field-border bg-field shadow-field outline-none no-highlight cursor-(--cursor-interactive) [transition:background-color_200ms_var(--ease-out),border-color_200ms_var(--ease-out),transform_100ms_var(--ease-out)] before:pointer-events-none before:absolute before:inset-0 before:z-0 before:origin-center before:scale-70 before:rounded-md before:bg-accent before:opacity-0 before:content-[''] before:[transition:scale_100ms_var(--ease-linear),opacity_200ms_var(--ease-linear),background-color_200ms_var(--ease-out)] [.checkbox:focus-visible_&]:status-focused [.checkbox:has([data-slot=checkbox-content][data-focus-visible=true])_&]:status-focused [.checkbox_[data-slot=checkbox-content][data-focus-visible=true]_&]:status-focused [.olis-native-checkbox:has(input:focus-visible)_&]:outline-2 [.olis-native-checkbox:has(input:focus-visible)_&]:outline-focus [.olis-native-checkbox:has(input:focus-visible)_&]:outline-offset-2 [.checkbox:hover_&]:border-field-border-hover [.checkbox:hover_&]:before:bg-accent-hover [.checkbox:has([data-slot=checkbox-content][data-hovered=true])_&]:border-field-border-hover [.checkbox:has([data-slot=checkbox-content][data-hovered=true])_&]:before:bg-accent-hover [.checkbox[aria-checked=true]_&]:border-transparent [.checkbox[data-selected=true]_&]:border-transparent [.checkbox[aria-checked=true]_&]:text-accent-foreground [.checkbox[data-selected=true]_&]:text-accent-foreground [.checkbox[aria-checked=true]_&]:before:scale-100 [.checkbox[aria-checked=true]_&]:before:opacity-100 [.checkbox[data-selected=true]_&]:before:scale-100 [.checkbox[data-selected=true]_&]:before:opacity-100 [.olis-native-checkbox:not([data-indeterminate=true]):has(input:checked)_&]:before:scale-100 [.olis-native-checkbox:not([data-indeterminate=true]):has(input:checked)_&]:before:opacity-100 [.checkbox[data-indeterminate=true]_&]:bg-accent [.checkbox[data-indeterminate=true]_&]:text-accent-foreground [.checkbox[data-indeterminate=true]:active_&]:bg-accent-hover [.checkbox[data-indeterminate=true][data-pressed=true]_&]:bg-accent-hover [.checkbox[data-indeterminate=true]:has([data-slot=checkbox-content][data-pressed=true])_&]:bg-accent-hover [.checkbox:is([data-invalid=true],[aria-invalid=true]):not([aria-checked=true]):not([data-selected=true]):not([data-indeterminate=true])_&]:status-invalid-field [.checkbox:is([data-invalid=true],[aria-invalid=true]):is([aria-checked=true],[data-selected=true])_&]:border-transparent [.checkbox:is([data-invalid=true],[aria-invalid=true]):is([aria-checked=true],[data-selected=true])_&]:bg-danger [.checkbox:is([data-invalid=true],[aria-invalid=true]):is([aria-checked=true],[data-selected=true])_&]:text-danger-foreground [.checkbox:is([data-invalid=true],[aria-invalid=true]):is([aria-checked=true],[data-selected=true])_&]:before:scale-100 [.checkbox:is([data-invalid=true],[aria-invalid=true]):is([aria-checked=true],[data-selected=true])_&]:before:bg-danger [.checkbox:is([data-invalid=true],[aria-invalid=true]):is([aria-checked=true],[data-selected=true])_&]:before:opacity-100 [.checkbox[data-indeterminate=true]:is([data-invalid=true],[aria-invalid=true])_&]:bg-danger [.checkbox[data-indeterminate=true]:is([data-invalid=true],[aria-invalid=true])_&]:text-danger-foreground [.olis-native-checkbox[data-invalid=true]:has(input:checked)_&]:before:bg-danger [.olis-native-checkbox[data-invalid=true]:not([data-indeterminate=true],:has(input:checked))_&]:outline-2 [.olis-native-checkbox[data-invalid=true]:not([data-indeterminate=true],:has(input:checked))_&]:outline-danger [.checkbox--secondary_&]:bg-default [.checkbox--secondary_&]:shadow-none [.checkbox--secondary[data-indeterminate=true]_&]:bg-accent [.checkbox--secondary[data-indeterminate=true]_&]:before:bg-accent [.checkbox--secondary:is([aria-checked=true],[data-selected=true])_&]:before:bg-accent"
  end

  defp checkbox_content_classes do
    "checkbox__content relative inline-flex cursor-[inherit] items-center gap-3 text-sm font-medium text-foreground outline-none select-none no-highlight"
  end

  defp checkbox_indicator_classes do
    "checkbox__indicator relative z-10 flex size-3 items-center justify-center [&_svg]:size-full [&_svg]:transform-gpu [.olis-native-checkbox_&]:invisible [.olis-native-checkbox:has(input:checked)_&]:visible [.olis-native-checkbox[data-indeterminate=true]_&]:visible [.checkbox:is([data-selected=true],[data-indeterminate=true])_&]:border-accent-foreground"
  end

  @doc """
  A labelled native checkbox, with OlisUI styling.

  `indeterminate` displays a mixed state while leaving the native checked value
  independently controlled. Keep it set until your application clears it.
  """
  attr(:id, :string, required: true)
  attr(:name, :string, default: nil)
  attr(:value, :string, default: "true")
  attr(:checked, :boolean, default: false)
  attr(:indeterminate, :boolean, default: false)
  attr(:disabled, :boolean, default: false)
  attr(:invalid, :boolean, default: false)
  attr(:description, :string, default: nil)
  attr(:variant, :string, default: "primary", values: ~w(primary secondary))
  attr(:class, :any, default: nil)
  attr(:rest, :global, include: ~w(required form))
  slot(:inner_block, required: true)

  def checkbox(assigns) do
    ~H"""
    <label
      class={[checkbox_root_classes(@variant), @class]}
      for={@id}
      data-slot="checkbox"
      data-disabled={if @disabled, do: "true"}
      data-invalid={if @invalid, do: "true"}
      data-indeterminate={if @indeterminate, do: "true"}
      x-data="{}"
      x-init="$el.querySelector('input').indeterminate = $el.dataset.indeterminate === 'true'"
      x-on:change="$el.querySelector('input').indeterminate = $el.dataset.indeterminate === 'true'"
      x-on:phx:update.window="$el.querySelector('input').indeterminate = $el.dataset.indeterminate === 'true'"
    >
      <span class={checkbox_content_classes()} data-slot="checkbox-content">
        <input
          id={@id}
          type="checkbox"
          name={@name}
          value={@value}
          checked={@checked}
          disabled={@disabled}
          aria-checked={if @indeterminate, do: "mixed"}
          aria-labelledby={"#{@id}-label"}
          aria-describedby={if @description, do: "#{@id}-description"}
          aria-invalid={if @invalid, do: "true"}
          class="olis-visually-hidden-input absolute [inset-block-start:0] start-0 z-[2] m-0 size-4 cursor-inherit opacity-0"
          {@rest}
        />
        <span class={checkbox_control_classes()} aria-hidden="true"><span class={
          checkbox_indicator_classes()
        }><svg
          :if={!@indeterminate}
          data-slot="checkbox-default-indicator--checkmark"
          viewBox="0 0 16 16"
          fill="none"
        ><path
          d="M3.5 8l3 3 6-6"
          stroke="currentColor"
          stroke-width="2.5"
          stroke-linecap="round"
          stroke-linejoin="round"
        /></svg><svg
          :if={@indeterminate}
          data-slot="checkbox-default-indicator--indeterminate"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="3"
          stroke-linecap="round"
        ><line x1="21" x2="3" y1="12" y2="12" /></svg></span></span>
        <span id={"#{@id}-label"} data-slot="label">{render_slot(@inner_block)}</span>
      </span>
      <span
        :if={@description}
        id={"#{@id}-description"}
        class="description text-xs text-wrap wrap-break-word text-muted"
        data-slot="description"
      >{@description}</span>
    </label>
    """
  end

  @doc """
  A labelled group of native checkboxes. The input name is suffixed with `[]`.
  When none are checked, the form omits the key; treat an absent key as `[]`.
  Group-level required validation must be performed by the application.
  """
  attr(:id, :string, required: true)
  attr(:name, :string, required: true)
  attr(:label, :string, required: true)
  attr(:value, :list, default: [])
  attr(:description, :string, default: nil)
  attr(:errors, :list, default: [])
  attr(:disabled, :boolean, default: false)
  attr(:required, :boolean, default: false)
  attr(:required_message, :string, default: "Choose at least one option.")
  attr(:variant, :string, default: "primary", values: ~w(primary secondary))
  attr(:class, :any, default: nil)

  slot :option, required: true do
    attr(:value, :string, required: true)
    attr(:label, :string, required: true)
    attr(:description, :string)
    attr(:disabled, :boolean)
  end

  def checkbox_group(assigns) do
    values = Enum.map(assigns.option, & &1.value)

    if length(values) != length(Enum.uniq(values)),
      do: raise(ArgumentError, "checkbox option values must be unique")

    name = if String.ends_with?(assigns.name, "[]"), do: assigns.name, else: assigns.name <> "[]"

    describedby =
      Enum.join(
        Enum.filter(
          [
            assigns.description && "#{assigns.id}-description",
            assigns.required && "#{assigns.id}-required",
            assigns.errors != [] && "#{assigns.id}-errors"
          ],
          & &1
        ),
        " "
      )

    assigns =
      assign(assigns,
        input_name: name,
        describedby: if(describedby == "", do: nil, else: describedby)
      )

    ~H"""
    <fieldset id={@id} class={@class} disabled={@disabled} aria-describedby={@describedby}>
      <legend class={label_classes()}>
        {@label}<span :if={@required} aria-hidden="true"> *</span>
      </legend>
      <span :if={@required} id={"#{@id}-required"} class="sr-only">{@required_message}</span>
      <span
        :if={@description}
        id={"#{@id}-description"}
        class="description text-xs text-wrap wrap-break-word text-muted block"
      >{@description}</span>
      <div class="checkbox-group flex flex-col [&_[data-slot=checkbox]]:mt-4">
        <.checkbox
          :for={option <- @option}
          id={"#{@id}-option-#{Base.url_encode64(option.value, padding: false)}"}
          name={@input_name}
          value={option.value}
          checked={option.value in @value}
          disabled={@disabled || Map.get(option, :disabled, false)}
          invalid={@errors != []}
          variant={@variant}
          description={Map.get(option, :description)}
        >
          {option.label}
        </.checkbox>
      </div>
      <div :if={@errors != []} id={"#{@id}-errors"} class={field_error_classes()} data-visible="true">
        <p :for={error <- @errors}>{error}</p>
      </div>
    </fieldset>
    """
  end

  @doc """
  A native checkbox presented as an OlisUI switch.

  Supply an `id` or Phoenix `field`. When omitting the visible label, provide
  `aria-label` or `aria-labelledby`. An unchecked switch submits no value;
  add a hidden input if your form needs an explicit false value. `read_only`
  preserves focus and form submission but prevents user changes with Alpine.
  """
  attr(:field, Phoenix.HTML.FormField, default: nil)
  attr(:id, :string, default: nil)
  attr(:name, :string, default: nil)
  attr(:value, :string, default: "true")
  attr(:checked, :boolean, default: nil)
  attr(:disabled, :boolean, default: false)
  attr(:read_only, :boolean, default: false)
  attr(:size, :string, default: "md", values: ~w(sm md lg))
  attr(:description, :string, default: nil)
  attr(:errors, :list, default: [])
  attr(:invalid, :boolean, default: false)
  attr(:label_position, :string, default: "end", values: ~w(start end))
  attr(:class, :any, default: nil)
  attr(:rest, :global, include: ~w(required form))
  slot(:inner_block)
  slot(:icon)

  def switch(assigns) do
    field = assigns.field

    assigns =
      assigns
      |> assign(:id, assigns.id || (field && field.id))
      |> assign(:name, assigns.name || (field && field.name))
      |> assign(
        :checked,
        if(is_nil(assigns.checked) && field,
          do: Phoenix.HTML.Form.normalize_value("checkbox", field.value),
          else: assigns.checked || false
        )
      )

    if is_nil(assigns.id), do: raise(ArgumentError, "switch requires an id or field")

    explicit_label =
      assigns.rest[:"aria-label"] || assigns.rest["aria-label"] ||
        assigns.rest[:"aria-labelledby"] || assigns.rest["aria-labelledby"]

    if assigns.inner_block == [] && !explicit_label,
      do: raise(ArgumentError, "switch requires a label, aria-label, or aria-labelledby")

    {external_description, rest} = Map.pop(assigns.rest, :"aria-describedby")
    {external_description_string, rest} = Map.pop(rest, "aria-describedby")
    {external_readonly, rest} = Map.pop(rest, :"aria-readonly")
    {external_readonly_string, rest} = Map.pop(rest, "aria-readonly")

    effective_readonly =
      assigns.read_only || external_readonly in [true, "true"] ||
        external_readonly_string in [true, "true"]

    describedby =
      [
        external_description,
        external_description_string,
        assigns.description && "#{assigns.id}-description",
        assigns.errors != [] && "#{assigns.id}-errors"
      ]
      |> Enum.filter(& &1)
      |> Enum.join(" ")

    assigns =
      assigns
      |> assign(:rest, rest)
      |> assign(:describedby, describedby)
      |> assign(:explicit_label, explicit_label)
      |> assign(:effective_readonly, effective_readonly)
      |> assign(
        :aria_readonly,
        if(effective_readonly, do: "true", else: external_readonly || external_readonly_string)
      )

    ~H"""
    <label
      class={[
        "switch switch--#{@size} flex flex-col items-start gap-1 no-highlight cursor-(--cursor-interactive) [--switch-control-bg:var(--default)] [--switch-control-bg-hover:color-mix(in_oklab,var(--switch-control-bg),transparent_20%)] [--switch-control-bg-pressed:var(--switch-control-bg-hover)] [--switch-control-bg-checked:var(--accent)] [--switch-control-bg-checked-hover:var(--accent-hover)] data-[disabled=true]:status-disabled [&_[data-slot=label]]:select-none [&_.switch__content_[data-slot=label]]:cursor-(--cursor-interactive) [&>[data-slot=description]]:w-full [&>[data-slot=description]]:min-w-0 [&>[data-slot=description]]:cursor-default [&>[data-slot=description]]:select-none [&>[data-slot=field-error]]:w-full [&>[data-slot=field-error]]:min-w-0 [&>[data-slot=field-error]]:text-xs [&>[data-slot=field-error]]:text-muted [&[data-disabled=true]_[data-slot=description]]:status-disabled [&[data-disabled=true]_[data-slot=field-error]]:status-disabled [&[data-disabled=true]_.switch__thumb]:bg-default-foreground/20 [&:is(:disabled,[data-disabled=true],[aria-disabled=true]):is([aria-checked=true],[data-selected=true])_.switch__thumb]:opacity-40",
        @size == "sm" &&
          "[&>[data-slot=description]]:ps-[calc(2rem_+_0.75rem)] [&>[data-slot=field-error]]:ps-[calc(2rem_+_0.75rem)]",
        @size == "md" &&
          "[&>[data-slot=description]]:ps-[calc(2.5rem_+_0.75rem)] [&>[data-slot=field-error]]:ps-[calc(2.5rem_+_0.75rem)]",
        @size == "lg" &&
          "[&>[data-slot=description]]:ps-[calc(3rem_+_0.75rem)] [&>[data-slot=field-error]]:ps-[calc(3rem_+_0.75rem)]",
        "group/switch has-[:disabled]:pointer-events-none",
        @class
      ]}
      for={@id}
      data-slot="switch"
      data-disabled={if @disabled, do: "true"}
      data-invalid={if @invalid || @errors != [], do: "true"}
      data-readonly={if @effective_readonly, do: "true"}
      x-data="{}"
      x-on:click.capture="if ($el.dataset.readonly === 'true' && $event.target === $el.control) { $event.preventDefault(); $event.stopPropagation() }"
    >
      <span
        class="switch__content relative inline-flex cursor-[inherit] items-center gap-3 text-sm font-medium text-foreground outline-none select-none no-highlight"
        data-slot="switch-content"
      >
        <input
          id={@id}
          type="checkbox"
          role="switch"
          name={@name}
          value={@value}
          checked={@checked}
          disabled={@disabled}
          aria-labelledby={if !@explicit_label, do: "#{@id}-label"}
          aria-invalid={if @invalid || @errors != [], do: "true"}
          aria-readonly={@aria_readonly}
          aria-describedby={if @describedby != "", do: @describedby}
          class="peer sr-only"
          {@rest}
        />
        <span
          class={[
            "switch__control relative flex shrink-0 items-center overflow-hidden bg-(--switch-control-bg) [transition:background-color_250ms_var(--ease-smooth),box-shadow_150ms_var(--ease-out)] [.switch:focus-visible_&]:status-focused [.switch:has([data-slot=switch-content][data-focus-visible=true])_&]:status-focused [.switch:hover_&]:bg-(--switch-control-bg-hover) [.switch:has([data-slot=switch-content][data-hovered=true])_&]:bg-(--switch-control-bg-hover) [.switch:active_&]:bg-(--switch-control-bg-pressed) [.switch:has([data-slot=switch-content][data-pressed=true])_&]:bg-(--switch-control-bg-pressed) [.switch:is([aria-checked=true],[data-selected=true])_&]:bg-(--switch-control-bg-checked) [.switch:is([aria-checked=true],[data-selected=true]):is(:hover,:active,[data-hovered=true],[data-pressed=true])_&]:bg-(--switch-control-bg-checked-hover)",
            @size == "sm" && "h-4 w-8 rounded-lg",
            @size == "md" && "h-5 w-10 rounded-xl",
            @size == "lg" && "h-6 w-12 rounded-xl",
            "pointer-events-none peer-focus-visible:outline-2 peer-focus-visible:outline-offset-2 peer-focus-visible:outline-[var(--focus)] peer-checked:bg-[var(--switch-control-bg-checked)] group-hover/switch:peer-checked:bg-[var(--switch-control-bg-checked-hover)] group-active/switch:peer-checked:bg-[var(--switch-control-bg-checked-hover)] peer-checked:[&_[data-slot=switch-thumb]]:[inset-inline-start:var(--switch-thumb-offset)] peer-checked:[&_[data-slot=switch-thumb]]:bg-accent-foreground peer-checked:[&_[data-slot=switch-thumb]]:text-accent peer-disabled:peer-checked:[&_[data-slot=switch-thumb]]:opacity-40"
          ]}
          data-slot="switch-control"
          aria-hidden="true"
        ><span
          class={[
            "switch__thumb relative ms-0.5 flex origin-center transform-gpu bg-white text-black shadow-field [inset-inline-start:0] [transition:inset-inline-start_300ms_var(--ease-out-fluid),background-color_200ms_var(--ease-out)] [.switch:is([aria-checked=true],[data-selected=true])_&]:bg-accent-foreground [.switch:is([aria-checked=true],[data-selected=true])_&]:text-accent [.switch:is([aria-checked=true],[data-selected=true])_&]:[inset-inline-start:var(--switch-thumb-offset)] [.switch:is([aria-checked=true],[data-selected=true])_&]:[box-shadow:0_0_5px_0_rgb(0_0_0/0.02),0_2px_10px_0_rgb(0_0_0/0.06),0_0_1px_0_rgb(0_0_0/0.3)] [&>*]:flex [&>*]:size-full [&>*]:items-center [&>*]:justify-center",
            @size == "sm" &&
              "h-3 w-[1.03125rem] rounded-md [--switch-thumb-offset:calc(100%_-_1.03125rem_-_var(--spacing))]",
            @size == "md" &&
              "h-4 w-[1.375rem] rounded-lg [--switch-thumb-offset:calc(100%_-_1.375rem_-_var(--spacing))]",
            @size == "lg" &&
              "h-5 w-[1.71875rem] rounded-xl [--switch-thumb-offset:calc(100%_-_1.71875rem_-_var(--spacing))]"
          ]}
          data-slot="switch-thumb"
        ><span
          :if={@icon != []}
          class="switch__icon"
          data-slot="switch-icon"
        >{render_slot(@icon)}</span></span></span>
        <span
          :if={@inner_block != []}
          id={"#{@id}-label"}
          data-slot="label"
          class={@label_position == "start" && "-order-1"}
        >{render_slot(@inner_block)}</span>
      </span>
      <span
        :if={@description}
        id={"#{@id}-description"}
        class="description text-xs text-wrap wrap-break-word text-muted"
        data-slot="description"
      >{@description}</span>
      <span
        :if={@errors != []}
        id={"#{@id}-errors"}
        class={field_error_classes()}
        data-slot="field-error"
        data-visible="true"
      ><span :for={error <- @errors} class="block">{error}</span></span>
    </label>
    """
  end

  @doc "A group of independent switches with vertical or horizontal layout."
  attr(:id, :string, default: nil)
  attr(:label, :string, default: nil)
  attr(:description, :string, default: nil)
  attr(:orientation, :string, default: "vertical", values: ~w(vertical horizontal))
  attr(:disabled, :boolean, default: false)
  attr(:class, :any, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def switch_group(assigns) do
    if assigns.description && is_nil(assigns.id),
      do: raise(ArgumentError, "switch_group requires an id when description is provided")

    {external_description, rest} = Map.pop(assigns.rest, :"aria-describedby")
    {external_description_string, rest} = Map.pop(rest, "aria-describedby")

    describedby =
      [
        external_description,
        external_description_string,
        assigns.description && "#{assigns.id}-description"
      ]
      |> Enum.filter(& &1)
      |> Enum.join(" ")

    assigns = assigns |> assign(:rest, rest) |> assign(:describedby, describedby)

    ~H"""
    <fieldset
      id={@id}
      class={[
        "switch-group flex flex-col gap-6",
        "switch-group--#{@orientation}",
        "disabled:[&_.switch]:opacity-50",
        @class
      ]}
      disabled={@disabled}
      aria-describedby={if @describedby != "", do: @describedby}
      data-slot="switch-group"
      data-orientation={@orientation}
      {@rest}
    >
      <legend :if={@label} class={label_classes()}>{@label}</legend>
      <div
        class={[
          "switch-group__items flex gap-4",
          @orientation == "horizontal" && "flex-row",
          @orientation == "vertical" && "flex-col"
        ]}
        data-slot="switch-group-items"
      >
        {render_slot(@inner_block)}
      </div>
      <p
        :if={@description}
        id={"#{@id}-description"}
        class="description text-xs text-wrap wrap-break-word text-muted"
      >
        {@description}
      </p>
    </fieldset>
    """
  end

  @doc "A progress bar. Pass `indeterminate` for ongoing work with no known completion value."
  attr(:value, :any, default: 0)
  attr(:min, :any, default: 0)
  attr(:max, :any, default: 100)
  attr(:label, :string, default: nil)
  attr(:value_text, :string, default: nil)
  attr(:show_value, :boolean, default: true)
  attr(:indeterminate, :boolean, default: false)
  attr(:size, :string, default: "md", values: ~w(sm md lg))
  attr(:color, :string, default: "accent", values: ~w(default accent success warning danger))
  attr(:class, :any, default: nil)
  attr(:rest, :global)

  def progress_bar(assigns) do
    value = if assigns.indeterminate, do: nil, else: assigns.value

    assigns =
      assigns
      |> assign(:current_value, value)
      |> assign(:percent, range_percent!(value, assigns.min, assigns.max, true))
      |> progress_accessible_name!("progress-bar")

    ~H"""
    <div
      class={[
        "progress-bar progress-bar--#{@size} progress-bar--#{@color} grid w-full grid-cols-[1fr_auto] gap-1 [grid-template-areas:'label_output'_'track_track'] disabled:status-disabled data-[disabled=true]:status-disabled aria-disabled:status-disabled",
        @class
      ]}
      data-slot={@data_slot}
      role="progressbar"
      aria-label={@accessible_label}
      aria-valuemin={@min}
      aria-valuemax={@max}
      aria-valuenow={@current_value}
      aria-valuetext={if !is_nil(@percent), do: @value_text || "#{round(@percent)}%"}
      {@rest}
    >
      <span
        :if={@label}
        class={[label_classes(), "w-fit text-sm font-medium [grid-area:label]"]}
        data-slot="label"
      >{@label}</span><span
        :if={@show_value && !is_nil(@percent)}
        class="progress-bar__output text-sm font-medium tabular-nums [grid-area:output]"
        data-slot="progress-bar-output"
      >{@value_text || "#{round(@percent)}%"}</span>
      <div
        class={[
          "progress-bar__track relative overflow-hidden bg-default [grid-area:track]",
          @size == "sm" && "h-1 rounded-xs",
          @size == "md" && "h-2 rounded-sm",
          @size == "lg" && "h-3 rounded-md"
        ]}
        data-slot="progress-bar-track"
      >
        <div
          class={[
            "progress-bar__fill absolute start-0 top-0 h-full transition-[width] duration-300 ease-(--ease-out)",
            progress_fill_color(@color),
            @size == "sm" && "rounded-xs",
            @size == "md" && "rounded-sm",
            @size == "lg" && "rounded-md",
            is_nil(@current_value) && "w-2/5 animate-progress-bar-indeterminate"
          ]}
          data-slot="progress-bar-fill"
          style={if !is_nil(@percent), do: "width: #{@percent}%"}
        >
        </div>
      </div>
    </div>
    """
  end

  @doc "A circular progress indicator. Pass `indeterminate` when progress is unknown."
  attr(:value, :any, default: 0)
  attr(:min, :any, default: 0)
  attr(:max, :any, default: 100)
  attr(:label, :string, default: nil)
  attr(:show_label, :boolean, default: false)
  attr(:value_text, :string, default: nil)
  attr(:indeterminate, :boolean, default: false)
  attr(:size, :string, default: "md", values: ~w(sm md lg))
  attr(:color, :string, default: "accent", values: ~w(default accent success warning danger))
  attr(:class, :any, default: nil)
  attr(:rest, :global)

  def progress_circle(assigns) do
    value = if assigns.indeterminate, do: nil, else: assigns.value
    percent = range_percent!(value, assigns.min, assigns.max, true)
    circumference = 2 * :math.pi() * 16

    offset =
      if is_nil(percent), do: circumference * 0.75, else: circumference * (1 - percent / 100)

    assigns =
      assigns
      |> assign(
        circumference: circumference,
        offset: offset,
        current_value: value,
        percent: percent
      )
      |> progress_accessible_name!("progress-circle")

    ~H"""
    <div
      class={[
        "progress-circle inline-flex items-center justify-center disabled:status-disabled data-[disabled=true]:status-disabled aria-disabled:status-disabled",
        "progress-circle--#{@size}",
        "progress-circle--#{@color}",
        @class
      ]}
      data-slot={@data_slot}
      role="progressbar"
      aria-label={@accessible_label}
      aria-valuemin={@min}
      aria-valuemax={@max}
      aria-valuenow={@current_value}
      aria-valuetext={if !is_nil(@percent), do: @value_text || "#{round(@percent)}%"}
      {@rest}
    >
      <svg
        class={[
          "progress-circle__track",
          @size == "sm" && "size-5",
          @size == "md" && "size-7",
          @size == "lg" && "size-9",
          is_nil(@current_value) && "animate-spin"
        ]}
        data-slot="progress-circle-track"
        viewBox="0 0 36 36"
        fill="none"
        aria-hidden="true"
      >
        <circle
          class="progress-circle__track-circle stroke-default"
          data-slot="progress-circle-track-circle"
          cx="18"
          cy="18"
          r="16"
          stroke-width="4"
        />
        <circle
          class={[
            "progress-circle__fill-circle transition-[stroke-dashoffset] duration-300 ease-(--ease-out)",
            progress_stroke_color(@color)
          ]}
          data-slot="progress-circle-fill-circle"
          cx="18"
          cy="18"
          r="16"
          stroke-width="4"
          stroke-linecap="round"
          stroke-dasharray={@circumference}
          stroke-dashoffset={@offset}
          transform="rotate(-90 18 18)"
        />
      </svg>
      <span :if={@show_label && @label} data-slot="label" class="ms-3">{@label}</span>
    </div>
    """
  end

  @doc "A labelled measurement within a known range."
  attr(:value, :any, default: 0)
  attr(:min, :any, default: 0)
  attr(:max, :any, default: 100)
  attr(:label, :string, default: nil)
  attr(:value_text, :string, default: nil)
  attr(:show_value, :boolean, default: true)
  attr(:size, :string, default: "md", values: ~w(sm md lg))
  attr(:color, :string, default: "accent", values: ~w(default accent success warning danger))
  attr(:class, :any, default: nil)
  attr(:rest, :global)

  def meter(assigns) do
    assigns =
      assigns
      |> assign(:percent, range_percent!(assigns.value, assigns.min, assigns.max, false))
      |> progress_accessible_name!("meter")

    ~H"""
    <div
      class={[
        "meter meter--#{@size} meter--#{@color} grid w-full grid-cols-[1fr_auto] gap-1 [grid-template-areas:'label_output'_'track_track'] disabled:status-disabled data-[disabled=true]:status-disabled aria-disabled:status-disabled",
        @class
      ]}
      data-slot={@data_slot}
      role="meter"
      aria-label={@accessible_label}
      aria-valuemin={@min}
      aria-valuemax={@max}
      aria-valuenow={@value}
      aria-valuetext={@value_text || "#{round(@percent)}%"}
      {@rest}
    >
      <span
        :if={@label}
        class={[label_classes(), "w-fit text-sm font-medium [grid-area:label]"]}
        data-slot="label"
      >{@label}</span><span
        :if={@show_value}
        class="meter__output text-sm font-medium tabular-nums [grid-area:output]"
        data-slot="meter-output"
      >{@value_text ||
        "#{round(@percent)}%"}</span>
      <div
        class={[
          "meter__track relative overflow-hidden bg-default [grid-area:track]",
          @size == "sm" && "h-1 rounded-xs",
          @size == "md" && "h-2 rounded-sm",
          @size == "lg" && "h-3 rounded-md"
        ]}
        data-slot="meter-track"
      >
        <div
          class={[
            "meter__fill absolute start-0 top-0 h-full transition-[width] duration-300 ease-(--ease-out)",
            progress_fill_color(@color),
            @size == "sm" && "rounded-xs",
            @size == "md" && "rounded-sm",
            @size == "lg" && "rounded-md"
          ]}
          data-slot="meter-fill"
          style={"width: #{@percent}%"}
        >
        </div>
      </div>
    </div>
    """
  end

  defp progress_fill_color(color) do
    %{
      "default" => "bg-default-foreground",
      "accent" => "bg-accent",
      "success" => "bg-success",
      "warning" => "bg-warning",
      "danger" => "bg-danger"
    }[color]
  end

  defp progress_stroke_color(color) do
    %{
      "default" => "stroke-default-foreground",
      "accent" => "stroke-accent",
      "success" => "stroke-success",
      "warning" => "stroke-warning",
      "danger" => "stroke-danger"
    }[color]
  end

  defp progress_accessible_name!(assigns, default_slot) do
    rest = assigns.rest
    explicit_label = Map.get(rest, :"aria-label") || Map.get(rest, "aria-label")
    labelledby = Map.get(rest, :"aria-labelledby") || Map.get(rest, "aria-labelledby")

    unless assigns.label || explicit_label || labelledby do
      raise ArgumentError, "provide label, aria-label, or aria-labelledby"
    end

    assign(assigns,
      accessible_label: explicit_label || if(!labelledby, do: assigns.label),
      data_slot: Map.get(rest, :"data-slot") || Map.get(rest, "data-slot") || default_slot,
      rest: Map.drop(rest, [:"aria-label", "aria-label", :"data-slot", "data-slot"])
    )
  end

  defp range_percent!(value, min, max, allow_nil?) do
    valid_range = is_number(min) and is_number(max) and min < max

    valid_value =
      (allow_nil? and is_nil(value)) or
        (is_number(value) and valid_range and value >= min and value <= max)

    if not (valid_range and valid_value),
      do:
        raise(
          ArgumentError,
          "value must be within a numeric min/max range, with min less than max"
        )

    if is_nil(value), do: nil, else: (value - min) / (max - min) * 100
  end

  @doc "A scrollable region with fading edges that reflect its scroll position."
  attr(:id, :string, default: nil)
  attr(:orientation, :string, default: "vertical", values: ~w(vertical horizontal))
  attr(:size, :integer, default: 40)
  attr(:offset, :integer, default: 0)
  attr(:hide_scrollbar, :boolean, default: false)
  attr(:enabled, :boolean, default: true)
  attr(:visibility, :string, default: "auto", values: ~w(auto both top bottom left right none))
  attr(:on_visibility_change, :string, default: nil)
  attr(:target, :any, default: nil)
  attr(:class, :any, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def scroll_shadow(assigns) do
    if !is_integer(assigns.size) || assigns.size < 0 || !is_integer(assigns.offset) ||
         assigns.offset < 0,
       do: raise(ArgumentError, "scroll shadow size and offset must be non-negative integers")

    auto = assigns.enabled && assigns.visibility == "auto"
    visibility = if assigns.enabled, do: assigns.visibility, else: "none"

    style =
      [
        assigns.size != 40 && "--scroll-shadow-size: #{assigns.size}px",
        assigns.offset != 0 && "--scroll-shadow-offset: #{assigns.offset}px"
      ]
      |> Enum.filter(& &1)
      |> Enum.join("; ")

    assigns =
      assigns
      |> assign(:auto, auto)
      |> assign(:effective_visibility, visibility)
      |> assign(:variable_style, if(style == "", do: nil, else: style))

    ~H"""
    <div
      id={@id}
      class={[
        "scroll-shadow relative scroll-shadow--#{@orientation} scroll-shadow--fade",
        @orientation == "vertical" && "overflow-y-auto",
        @orientation == "horizontal" && "overflow-x-auto",
        @hide_scrollbar && "scroll-shadow--hide-scrollbar scrollbar-none",
        !@hide_scrollbar && "scrollbar",
        @class
      ]}
      data-slot="scroll-shadow"
      data-olis-scroll-shadow
      x-data="olisScrollShadow"
      x-on:scroll="schedule()"
      x-on:load.capture="schedule()"
      x-on:resize.window="schedule()"
      x-on:phx:update.window="schedule()"
      data-orientation={@orientation}
      data-scroll-shadow-mode={if @auto, do: "auto", else: "manual"}
      data-scroll-shadow-size={@size}
      data-scroll-shadow-offset={@offset}
      data-scroll-shadow-visibility={@effective_visibility}
      data-top-scroll={
        if !@auto && @orientation == "vertical" && @effective_visibility == "top", do: "true"
      }
      data-bottom-scroll={
        if !@auto && @orientation == "vertical" && @effective_visibility == "bottom", do: "true"
      }
      data-top-bottom-scroll={
        if !@auto && @orientation == "vertical" && @effective_visibility == "both", do: "true"
      }
      data-left-scroll={
        if !@auto && @orientation == "horizontal" && @effective_visibility == "left", do: "true"
      }
      data-right-scroll={
        if !@auto && @orientation == "horizontal" && @effective_visibility == "right", do: "true"
      }
      data-left-right-scroll={
        if !@auto && @orientation == "horizontal" && @effective_visibility == "both", do: "true"
      }
      {if @variable_style, do: %{style: @variable_style}, else: %{}}
      {@rest}
    >
      {render_slot(@inner_block)}
      <button
        :if={@on_visibility_change}
        type="button"
        hidden
        data-olis-scroll-shadow-event
        phx-click={@on_visibility_change}
        phx-target={@target}
      ></button>
    </div>
    """
  end

  @doc "A person or entity represented by an image or fallback initials."
  attr(:src, :string, default: nil)
  attr(:name, :string, required: true)
  attr(:fallback, :string, default: nil)
  attr(:size, :string, default: "md", values: ~w(sm md lg))
  attr(:color, :string, default: "default", values: ~w(default accent success warning danger))
  attr(:variant, :string, default: "default", values: ~w(default soft))
  attr(:class, :any, default: nil)

  def avatar(assigns) do
    initials =
      assigns.name
      |> String.split()
      |> Enum.take(2)
      |> Enum.map_join(&String.first/1)
      |> String.upcase()

    palette =
      %{
        "default" => {"text-default-soft-foreground", "bg-default-soft"},
        "accent" => {"text-accent-soft-foreground", "bg-accent-soft"},
        "success" => {"text-success-soft-foreground", "bg-success-soft"},
        "warning" => {"text-warning-soft-foreground", "bg-warning-soft"},
        "danger" => {"text-danger-soft-foreground", "bg-danger-soft"}
      }[assigns.color]

    assigns = assign(assigns, initials: assigns.fallback || initials, palette: palette)

    ~H"""
    <span
      class={[
        "avatar avatar--#{@size} relative flex shrink-0 items-center justify-center overflow-hidden rounded-(--avatar-radius)",
        @size == "sm" && "size-8 [--avatar-size:2rem] [--avatar-radius:calc(var(--radius)*2)]",
        @size == "md" && "size-10 [--avatar-size:2.5rem] [--avatar-radius:calc(var(--radius)*3)]",
        @size == "lg" && "size-12 [--avatar-size:3rem] [--avatar-radius:calc(var(--radius)*3)]",
        @variant == "soft" && "avatar--soft bg-transparent",
        @variant != "soft" && "bg-default",
        @class
      ]}
      role="img"
      aria-label={@name}
    >
      <span
        class={[
          "avatar__fallback avatar__fallback--#{@color} flex size-full items-center justify-center font-medium",
          elem(@palette, 0),
          @variant == "soft" && elem(@palette, 1),
          @variant != "soft" && "bg-default",
          @size == "sm" && "text-xs",
          @size == "md" && "text-sm",
          @size == "lg" && "text-base"
        ]}
        aria-hidden="true"
      >{@initials}</span>
      <img
        :if={@src}
        src={@src}
        alt=""
        aria-hidden="true"
        class="avatar__image olis-avatar-image absolute inset-0 aspect-square size-full object-cover transition-opacity duration-250 data-[failed=true]:hidden"
        data-olis-avatar-image
        x-data="olisAvatarImage"
        x-on:phx:update.window="sync()"
        x-on:load="$el.removeAttribute('data-failed')"
        x-on:error="$el.dataset.failed = 'true'"
        phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["data-failed"])}
      />
    </span>
    """
  end

  @doc "A stacked or grid group of avatars with an optional overflow count."
  attr(:size, :string, default: "md", values: ~w(sm md lg))
  attr(:color, :string, default: "default", values: ~w(default accent success warning danger))
  attr(:variant, :string, default: "default", values: ~w(default soft))
  attr(:max, :integer, default: nil)
  attr(:grid, :boolean, default: false)
  attr(:overlap, :string, default: "clip", values: ~w(clip ring))
  attr(:class, :any, default: nil)
  attr(:rest, :global)

  slot :avatar do
    attr(:name, :string, required: true)
    attr(:src, :string)
    attr(:fallback, :string)
    attr(:size, :string)
    attr(:color, :string)
    attr(:variant, :string)
    attr(:class, :any)
  end

  slot :count do
    attr(:label, :string, required: true)
    attr(:size, :string)
    attr(:color, :string)
    attr(:variant, :string)
    attr(:class, :any)
  end

  def avatar_group(assigns) do
    if !is_nil(assigns.max) && (!is_integer(assigns.max) || assigns.max < 0),
      do: raise(ArgumentError, "avatar group max must be a non-negative integer")

    if length(assigns.count) > 1,
      do: raise(ArgumentError, "avatar group accepts at most one count slot")

    {visible, hidden} = Enum.split(assigns.avatar, assigns.max || length(assigns.avatar))
    count = List.first(assigns.count)
    count_size = (count && Map.get(count, :size)) || assigns.size
    count_color = (count && Map.get(count, :color)) || assigns.color
    count_variant = (count && Map.get(count, :variant)) || assigns.variant

    count_palette =
      %{
        "default" => {"text-default-soft-foreground", "bg-default-soft"},
        "accent" => {"text-accent-soft-foreground", "bg-accent-soft"},
        "success" => {"text-success-soft-foreground", "bg-success-soft"},
        "warning" => {"text-warning-soft-foreground", "bg-warning-soft"},
        "danger" => {"text-danger-soft-foreground", "bg-danger-soft"}
      }[count_color]

    assigns =
      assigns
      |> assign(:visible, visible)
      |> assign(:hidden_count, length(hidden))
      |> assign(:count_slot, count)
      |> assign(:count_size, count_size)
      |> assign(:count_variant, count_variant)
      |> assign(:count_color, count_color)
      |> assign(:count_palette, count_palette)

    ~H"""
    <div
      class={[
        "avatar-group inline-flex items-center [--avatar-group-overlap:0.5rem] [--avatar-group-seam:2px]",
        @grid && "avatar-group--grid flex-wrap gap-3",
        !@grid && "avatar-group--#{@overlap}",
        @class
      ]}
      data-slot="avatar-group"
      {@rest}
    >
      <.avatar
        :for={person <- @visible}
        name={person.name}
        src={Map.get(person, :src)}
        fallback={Map.get(person, :fallback)}
        size={Map.get(person, :size) || @size}
        color={Map.get(person, :color) || @color}
        variant={Map.get(person, :variant) || @variant}
        class={Map.get(person, :class)}
      />
      <span
        :if={@count_slot || @hidden_count > 0}
        class={[
          "avatar avatar-group__count avatar--#{@count_size} relative flex shrink-0 items-center justify-center overflow-hidden rounded-(--avatar-radius)",
          @count_size == "sm" && "size-8 [--avatar-size:2rem] [--avatar-radius:calc(var(--radius)*2)]",
          @count_size == "md" &&
            "size-10 [--avatar-size:2.5rem] [--avatar-radius:calc(var(--radius)*3)]",
          @count_size == "lg" &&
            "size-12 [--avatar-size:3rem] [--avatar-radius:calc(var(--radius)*3)]",
          @count_variant == "soft" && "avatar--soft bg-transparent",
          @count_variant != "soft" && "bg-default",
          @count_slot && Map.get(@count_slot, :class)
        ]}
        role="img"
        aria-label={if @count_slot, do: @count_slot.label, else: "#{@hidden_count} more"}
        data-slot="avatar-group-count"
      >
        <span
          class={[
            "avatar__fallback avatar__fallback--#{@count_color} flex size-full items-center justify-center font-medium",
            elem(@count_palette, 0),
            @count_variant == "soft" && elem(@count_palette, 1),
            @count_variant != "soft" && "bg-default",
            @count_size == "sm" && "text-xs",
            @count_size == "md" && "text-sm",
            @count_size == "lg" && "text-base"
          ]}
          aria-hidden="true"
        ><%= if @count_slot do %>
          {render_slot(@count_slot)}
        <% else %>
          +{@hidden_count}
        <% end %></span>
      </span>
    </div>
    """
  end

  @doc "A styled native multiline text input. Provide a label or aria-label."
  attr(:id, :string, default: nil)
  attr(:name, :string, default: nil)
  attr(:value, :any, default: nil)
  attr(:variant, :string, default: "primary", values: ~w(primary secondary))
  attr(:invalid, :boolean, default: false)
  attr(:class, :any, default: nil)

  attr(:rest, :global,
    include:
      ~w(autocomplete autofocus disabled form maxlength minlength placeholder readonly required rows cols)
  )

  def textarea(assigns) do
    ~H"""
    <textarea
      id={@id}
      name={@name}
      aria-invalid={to_string(@invalid)}
      data-invalid={if @invalid, do: "true"}
      class={[textarea_classes(@variant), @class]}
      {@rest}
    >{@value}</textarea>
    """
  end

  defp list_box_item_classes do
    "list-box-item relative flex min-h-9 w-full items-center justify-start gap-3 rounded-[6px] px-2 py-1.5 outline-none no-highlight cursor-(--cursor-interactive) [transition:background-color_120ms_var(--ease-out),color_120ms_var(--ease-out),box-shadow_120ms_var(--ease-out)] [&_[data-slot=label]]:pointer-events-none [&_[data-slot=label]]:w-fit [&_[data-slot=label]]:select-none [&_[data-slot=description]]:pointer-events-none [&_[data-slot=description]]:text-wrap [&_[data-slot=description]]:select-none [&:focus-visible:not([data-focused])]:status-focused data-[focus-visible=true]:status-focused hover:bg-default [@media(hover:hover)]:data-[hovered=true]:bg-default data-[disabled=true]:status-disabled has-[.list-box-item__indicator]:pe-7 [&.list-box-item--danger_[data-slot=label]]:text-danger [.olis-listbox:focus-visible_&[data-active=true]]:bg-default [.olis-listbox:focus-visible_&[data-active=true]]:outline-2 [.olis-listbox:focus-visible_&[data-active=true]]:outline-focus [.olis-listbox:focus-visible_&[data-active=true]]:-outline-offset-2"
  end

  defp list_box_indicator_classes do
    "list-box-item__indicator absolute end-2 top-1/2 flex size-4 shrink-0 -translate-y-1/2 items-center justify-center text-default-foreground transition duration-250 [&_[data-slot=list-box-item-indicator--checkmark]]:size-2.5 [&_[data-slot=list-box-item-indicator--checkmark]]:transition-all [&_[data-slot=list-box-item-indicator--checkmark]]:duration-300 [.list-box-item--danger_&]:text-danger [.list-box-item:is([aria-selected=true],[data-selected=true])_&_[data-slot=list-box-item-indicator--checkmark]]:[transition:stroke-dashoffset_250ms_linear]"
  end

  defp menu_item_classes do
    "menu-item relative flex min-h-9 w-full items-center justify-start gap-3 rounded-[6px] px-2 py-1.5 outline-none no-highlight cursor-(--cursor-interactive) [transition:background-color_120ms_var(--ease-out),color_120ms_var(--ease-out),box-shadow_120ms_var(--ease-out)] [&_[data-slot=label]]:pointer-events-none [&_[data-slot=label]]:w-fit [&_[data-slot=label]]:select-none [&_[data-slot=description]]:pointer-events-none [&_[data-slot=description]]:text-wrap [&_[data-slot=description]]:select-none [&:focus-visible:not([data-focused])]:status-focused data-[focus-visible=true]:status-focused hover:bg-default [@media(hover:hover)]:data-[hovered=true]:bg-default data-[disabled=true]:status-disabled active:will-change-transform data-[pressed=true]:will-change-transform has-[.menu-item__indicator:not(.menu-item__indicator--submenu)]:ps-7 [&[data-has-submenu=true]:has(.menu-item__indicator--submenu)]:pe-7 [&_[data-slot=submenu-indicator]_svg]:size-3.5 [&.menu-item--danger_[data-slot=label]]:text-danger [&:is([aria-checked=true],[aria-selected=true],[data-selected=true])_[data-slot=menu-item-indicator--checkmark]]:[transition:stroke-dashoffset_100ms_linear] [&:is([aria-checked=true],[aria-selected=true],[data-selected=true])_[data-slot=menu-item-indicator--dot]]:scale-100 [&:is([aria-checked=true],[aria-selected=true],[data-selected=true])_[data-slot=menu-item-indicator--dot]]:opacity-100"
  end

  defp menu_indicator_classes do
    "menu-item__indicator absolute start-2 top-1/2 flex size-4 shrink-0 -translate-y-1/2 items-center justify-center text-muted transition duration-250 [&_[data-slot=menu-item-indicator--checkmark]]:size-2.5 [&_[data-slot=menu-item-indicator--dot]]:size-2 [&_[data-slot=menu-item-indicator--dot]]:scale-70 [&_[data-slot=menu-item-indicator--dot]]:opacity-0 [.menu-item[data-selection-mode=multiple]_&_[data-slot=menu-item-indicator--checkmark]]:transition-all [.menu-item[data-selection-mode=multiple]_&_[data-slot=menu-item-indicator--checkmark]]:duration-300 [.menu-item[data-selection-mode=multiple]_&_[data-slot=menu-item-indicator--dot]]:transition-all [.menu-item[data-selection-mode=multiple]_&_[data-slot=menu-item-indicator--dot]]:duration-250 [.menu-item--danger_&]:text-danger"
  end

  defp radio_root_classes do
    "radio olis-native-radio flex flex-col items-start gap-1 outline-none no-highlight cursor-(--cursor-interactive) disabled:status-disabled data-[disabled=true]:status-disabled aria-disabled:status-disabled [&_[data-slot=label]]:select-none [&_.radio__content_[data-slot=label]]:cursor-(--cursor-interactive) [&>[data-slot=description]]:w-full [&>[data-slot=description]]:min-w-0 [&>[data-slot=description]]:cursor-default [&>[data-slot=description]]:ps-7 [&>[data-slot=description]]:text-xs [&>[data-slot=description]]:text-wrap [&>[data-slot=description]]:wrap-break-word [&>[data-slot=description]]:text-muted [&>[data-slot=description]]:select-none [&>[data-slot=field-error]]:w-full [&>[data-slot=field-error]]:min-w-0 [&>[data-slot=field-error]]:cursor-default [&>[data-slot=field-error]]:ps-7 [&>[data-slot=field-error]]:text-xs [&>[data-slot=field-error]]:text-wrap [&>[data-slot=field-error]]:wrap-break-word [&>[data-slot=field-error]]:text-muted [&>[data-slot=field-error]]:select-none [&[data-disabled=true]_[data-slot=description]]:status-disabled [&[data-disabled=true]_[data-slot=field-error]]:status-disabled"
  end

  defp radio_control_classes do
    "radio__control pointer-events-none relative inline-flex size-4 shrink-0 items-center justify-center rounded-lg border border-[length:var(--border-width-field)] border-field-border bg-field shadow-field outline-none no-highlight cursor-(--cursor-interactive) [transition:background-color_200ms_var(--ease-out),border-color_200ms_var(--ease-out),transform_100ms_var(--ease-out)] [.radio:has([data-slot=radio-content]:focus-visible)_&]:status-focused [.radio:has([data-slot=radio-content][data-focus-visible=true])_&]:status-focused [.olis-native-radio:has(input:focus-visible)_&]:outline-2 [.olis-native-radio:has(input:focus-visible)_&]:outline-focus [.olis-native-radio:has(input:focus-visible)_&]:outline-offset-2 [@media(hover:hover)]:[.radio:has([data-slot=radio-content]:hover)_&]:border-field-border-hover [@media(hover:hover)]:[.radio:has([data-slot=radio-content][data-hovered=true])_&]:border-field-border-hover [.radio:has([data-slot=radio-content]:active)_&]:scale-95 [.radio:has([data-slot=radio-content][data-pressed=true])_&]:scale-95 [.radio[data-selected]_&]:border-transparent [.radio[data-selected]_&]:bg-accent [.radio:has([data-slot=radio-content][aria-checked=true])_&]:border-transparent [.radio:has([data-slot=radio-content][aria-checked=true])_&]:bg-accent [.radio:has(input:checked)_&]:border-transparent [.radio:has(input:checked)_&]:bg-accent [.radio[data-selected]:has([data-slot=radio-content]:active)_&]:bg-accent-hover [.radio:has(input:checked):has([data-slot=radio-content]:active)_&]:bg-accent-hover [.radio[data-selected]:has([data-slot=radio-content][data-pressed=true])_&]:bg-accent-hover [.radio:has([data-slot=radio-content][data-pressed=true][aria-checked=true])_&]:bg-accent-hover [.radio:has(input:checked):has([data-slot=radio-content][data-pressed=true])_&]:bg-accent-hover [.radio:is([data-invalid=true],[aria-invalid=true])_&]:status-invalid-field [.radio-group--secondary_&]:shadow-none [.radio-group--secondary_&]:bg-default [@media(hover:hover)]:[.radio-group--secondary_.radio:has([data-slot=radio-content][data-hovered=true])_&]:border-field-border-hover"
  end

  defp radio_indicator_classes do
    "radio__indicator pointer-events-none absolute inset-0 flex items-center justify-center [&:empty]:before:size-full [&:empty]:before:rounded-lg [&:empty]:before:bg-field [&:empty]:before:scale-100 [&:empty]:before:content-[''] [&:empty]:before:[transition:scale_200ms_var(--ease-out),background-color_200ms_var(--ease-out)] [.radio-group--secondary_.radio:not([data-selected]):not(:has(input:checked))_&:empty]:before:bg-default [@media(hover:hover)]:[.radio:has([data-slot=radio-content]:hover):not([data-selected]):not(:has(input:checked))_&:empty]:before:bg-field-hover [@media(hover:hover)]:[.radio:has([data-slot=radio-content][data-hovered=true]):not([data-selected]):not(:has(input:checked))_&:empty]:before:bg-field-hover [@media(hover:hover)]:[.radio-group--secondary_.radio:has([data-slot=radio-content][data-hovered=true]):not([data-selected]):not(:has(input:checked))_&:empty]:before:bg-default-hover [.radio[data-selected]_&:empty]:before:bg-accent-foreground [.radio[data-selected]_&:empty]:before:scale-[.4286] [.radio:has([data-slot=radio-content][aria-checked=true])_&:empty]:before:bg-accent-foreground [.radio:has([data-slot=radio-content][aria-checked=true])_&:empty]:before:scale-[.4286] [.radio:has(input:checked)_&:empty]:before:bg-accent-foreground [.radio:has(input:checked)_&:empty]:before:scale-[.4286] [.radio[data-selected]:has([data-slot=radio-content]:active)_&:empty]:before:scale-[.5714] [.radio:has(input:checked):has([data-slot=radio-content]:active)_&:empty]:before:scale-[.5714] [.radio[data-selected]:has([data-slot=radio-content][data-pressed=true])_&:empty]:before:scale-[.5714] [.radio:has([data-slot=radio-content][data-pressed=true][aria-checked=true])_&:empty]:before:scale-[.5714] [.radio:has(input:checked):has([data-slot=radio-content][data-pressed=true])_&:empty]:before:scale-[.5714]"
  end

  @doc "A native radio input with OlisUI styling. Radios sharing a name form a group."
  attr(:id, :string, required: true)
  attr(:name, :string, required: true)
  attr(:value, :string, required: true)
  attr(:checked, :boolean, default: false)
  attr(:disabled, :boolean, default: false)
  attr(:invalid, :boolean, default: false)
  attr(:description, :string, default: nil)
  attr(:class, :any, default: nil)
  attr(:rest, :global, include: ~w(required form))
  slot(:inner_block, required: true)

  def radio(assigns) do
    ~H"""
    <label
      class={[radio_root_classes(), @class]}
      for={@id}
      data-slot="radio"
      data-disabled={if @disabled, do: "true"}
      data-invalid={if @invalid, do: "true"}
    >
      <span
        class="radio__content relative inline-flex cursor-[inherit] items-center gap-3 text-sm font-medium text-foreground outline-none select-none no-highlight"
        data-slot="radio-content"
      >
        <input
          id={@id}
          type="radio"
          name={@name}
          value={@value}
          checked={@checked}
          disabled={@disabled}
          aria-labelledby={"#{@id}-label"}
          aria-invalid={if @invalid, do: "true"}
          aria-describedby={if @description, do: "#{@id}-description"}
          class="olis-visually-hidden-input absolute [inset-block-start:0] start-0 z-[2] m-0 size-4 cursor-inherit opacity-0"
          {@rest}
        />
        <span class={radio_control_classes()} aria-hidden="true"><span class={
          radio_indicator_classes()
        }></span></span>
        <span id={"#{@id}-label"} data-slot="label">{render_slot(@inner_block)}</span>
      </span>
      <span
        :if={@description}
        id={"#{@id}-description"}
        class="description text-xs text-wrap wrap-break-word text-muted"
        data-slot="description"
      >{@description}</span>
    </label>
    """
  end

  @doc "A labelled, native radio group with descriptions and validation messages."
  attr(:id, :string, required: true)
  attr(:name, :string, required: true)
  attr(:label, :string, required: true)
  attr(:value, :string, default: nil)
  attr(:description, :string, default: nil)
  attr(:errors, :list, default: [])
  attr(:disabled, :boolean, default: false)
  attr(:required, :boolean, default: false)
  attr(:variant, :string, default: "primary", values: ~w(primary secondary))
  attr(:orientation, :string, default: "vertical", values: ~w(vertical horizontal))
  attr(:class, :any, default: nil)

  slot :option, required: true do
    attr(:value, :string, required: true)
    attr(:label, :string, required: true)
    attr(:description, :string)
    attr(:disabled, :boolean)
  end

  def radio_group(assigns) do
    values = Enum.map(assigns.option, & &1.value)

    if length(values) != length(Enum.uniq(values)),
      do: raise(ArgumentError, "radio option values must be unique")

    describedby =
      Enum.join(
        Enum.filter(
          [
            assigns.description && "#{assigns.id}-description",
            assigns.errors != [] && "#{assigns.id}-errors"
          ],
          & &1
        ),
        " "
      )

    assigns = assign(assigns, :describedby, if(describedby == "", do: nil, else: describedby))

    ~H"""
    <fieldset id={@id} class={@class} disabled={@disabled} aria-describedby={@describedby}>
      <legend class={label_classes()}>{@label}</legend>
      <div
        class={[
          "radio-group radio-group--#{@variant} flex",
          @orientation == "vertical" && "flex-col [&_[data-slot=radio]]:mt-4",
          @orientation == "horizontal" && "flex-row flex-wrap gap-4"
        ]}
        data-orientation={@orientation}
      >
        <.radio
          :for={option <- @option}
          id={"#{@id}-option-#{Base.url_encode64(option.value, padding: false)}"}
          name={@name}
          value={option.value}
          checked={option.value == @value}
          disabled={@disabled || Map.get(option, :disabled, false)}
          invalid={@errors != []}
          description={Map.get(option, :description)}
          required={@required}
        >
          {option.label}
        </.radio>
      </div>
      <p
        :if={@description}
        id={"#{@id}-description"}
        class="description text-xs text-wrap wrap-break-word text-muted"
      >
        {@description}
      </p>
      <div :if={@errors != []} id={"#{@id}-errors"} class={field_error_classes()} data-visible="true">
        <p :for={error <- @errors}>{error}</p>
      </div>
    </fieldset>
    """
  end

  @doc "A keyboard key or shortcut."
  attr(:class, :any, default: nil)
  slot(:inner_block, required: true)

  def kbd(assigns) do
    ~H"""
    <kbd class={[
      "kbd [&.kbd--light]:bg-transparent inline-flex h-6 items-center space-x-0.5 rounded-lg bg-default px-2 text-center font-sans text-sm font-medium whitespace-nowrap text-muted rtl:space-x-reverse [word-spacing:-0.25rem]",
      @class
    ]}>{render_slot(@inner_block)}</kbd>
    """
  end

  @doc "A form label with OlisUI required, disabled, and invalid states."
  attr(:for, :string, default: nil)
  attr(:required, :boolean, default: false)
  attr(:disabled, :boolean, default: false)
  attr(:invalid, :boolean, default: false)
  attr(:class, :any, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def label(assigns) do
    ~H"""
    <label
      for={@for}
      class={[
        label_classes(),
        @required && "label--required",
        @disabled && "label--disabled",
        @invalid && "label--invalid",
        @class
      ]}
      data-slot="label"
      {@rest}
    >{render_slot(@inner_block)}</label>
    """
  end

  @doc "An OlisUI link for ordinary navigation, LiveView navigation, or patches."
  attr(:href, :string, default: nil)
  attr(:navigate, :string, default: nil)
  attr(:patch, :string, default: nil)
  attr(:replace, :boolean, default: false)
  attr(:disabled, :boolean, default: false)
  attr(:class, :any, default: nil)
  attr(:rest, :global, include: ~w(download hreflang media ping referrerpolicy rel target type))
  slot(:inner_block, required: true)

  def ui_link(assigns) do
    destinations = Enum.reject([assigns.href, assigns.navigate, assigns.patch], &is_nil/1)

    if length(destinations) != 1,
      do: raise(ArgumentError, "ui_link requires exactly one of href, navigate, or patch")

    # A disabled link must not retain click bindings or an active destination.
    rest =
      if assigns.disabled do
        assigns.rest
        |> Enum.reject(fn {key, _} ->
          key = to_string(key)

          key in ~w(phx-click tabindex role aria-disabled) ||
            String.starts_with?(key, "x-on:click")
        end)
        |> Map.new()
      else
        assigns.rest
      end

    assigns = assign(assigns, :rest, rest)

    ~H"""
    <.link
      :if={!@disabled}
      href={@href}
      navigate={@navigate}
      patch={@patch}
      replace={@replace}
      class={[
        "link relative inline-flex h-fit w-fit items-center rounded-xl font-medium text-link no-underline decoration-separator-tertiary decoration-[1.5px] underline-offset-4 no-highlight cursor-(--cursor-interactive) [transition:color_100ms_var(--ease-smooth),background-color_150ms_var(--ease-smooth),box-shadow_150ms_var(--ease-out),opacity_100ms_var(--ease-out)] hover:underline hover:decoration-muted/50 [@media(hover:hover)]:data-[hovered=true]:underline [@media(hover:hover)]:data-[hovered=true]:decoration-muted/50 active:underline active:decoration-muted data-[pressed=true]:underline data-[pressed=true]:decoration-muted [&:focus-visible:not([data-focused])]:status-focused data-[focus-visible=true]:status-focused aria-disabled:status-disabled [&.button]:gap-0 [&.button]:no-underline",
        @class
      ]}
      data-slot="link"
      {@rest}
    >{render_slot(@inner_block)}</.link>
    <a
      :if={@disabled}
      role="link"
      aria-disabled="true"
      tabindex="-1"
      class={[
        "link relative inline-flex h-fit w-fit items-center rounded-xl font-medium text-link no-underline decoration-separator-tertiary decoration-[1.5px] underline-offset-4 no-highlight cursor-(--cursor-interactive) [transition:color_100ms_var(--ease-smooth),background-color_150ms_var(--ease-smooth),box-shadow_150ms_var(--ease-out),opacity_100ms_var(--ease-out)] hover:underline hover:decoration-muted/50 [@media(hover:hover)]:data-[hovered=true]:underline [@media(hover:hover)]:data-[hovered=true]:decoration-muted/50 active:underline active:decoration-muted data-[pressed=true]:underline data-[pressed=true]:decoration-muted [&:focus-visible:not([data-focused])]:status-focused data-[focus-visible=true]:status-focused aria-disabled:status-disabled [&.button]:gap-0 [&.button]:no-underline",
        @class
      ]}
      data-slot="link"
      {@rest}
    >{render_slot(@inner_block)}</a>
    """
  end

  @doc "An optional external-link icon for use inside `ui_link`."
  attr(:class, :any, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  def link_icon(assigns) do
    ~H"""
    <span
      class={[
        "link__icon pointer-events-none inline-flex size-[0.75em] shrink-0 items-center justify-center text-current opacity-60 transition-opacity duration-150 ease-(--ease-out) [&_svg]:transform-gpu data-[default-icon=true]:ms-1 data-[default-icon=true]:pb-1.5 [@media(hover:hover)]:[.link:hover_&]:opacity-100 [@media(hover:hover)]:[.link[data-hovered=true]_&]:opacity-100 [.link:active_&]:opacity-100 [.link[data-pressed=true]_&]:opacity-100 [.link:focus-visible:not([data-focused])_&]:opacity-100 [.link[data-focus-visible=true]_&]:opacity-100",
        @class
      ]}
      data-slot="link-icon"
      data-default-icon={if @inner_block == [], do: "true"}
      aria-hidden="true"
      {@rest}
    >
      <%= if @inner_block == [] do %>
        <svg
          data-slot="link-default-icon"
          viewBox="0 0 7 7"
          width="9"
          height="9"
          fill="none"
          aria-hidden="true"
          role="presentation"
        ><path
          d="M1.20592 6.84333L0.379822 6.01723L4.52594 1.8672H1.37819L1.38601 0.731812H6.48742V5.83714H5.34421L5.35203 2.6933L1.20592 6.84333Z"
          fill="currentColor"
        /></svg>
      <% else %>
        {render_slot(@inner_block)}
      <% end %>
    </span>
    """
  end

  @doc "Semantic OlisUI typography with a visual type, color, alignment, and weight."
  attr(:type, :string, default: "body", values: ~w(h1 h2 h3 h4 h5 h6 body body-sm body-xs code))
  attr(:as, :string, default: nil)
  attr(:align, :string, default: "start", values: ~w(start center end justify))
  attr(:color, :string, default: "default", values: ~w(default muted))
  attr(:weight, :string, default: nil)
  attr(:truncate, :boolean, default: false)
  attr(:class, :any, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def typography(assigns) do
    if assigns.type not in ~w(h1 h2 h3 h4 h5 h6 body body-sm body-xs code) or
         (!is_nil(assigns.weight) and assigns.weight not in ~w(normal medium semibold bold)) or
         (!is_nil(assigns.as) and
            assigns.as not in ~w(h1 h2 h3 h4 h5 h6 p span div code blockquote)),
       do: raise(ArgumentError, "invalid typography type or element")

    default_tag = if assigns.type in ~w(body body-sm body-xs), do: "p", else: assigns.type

    assigns =
      assign(assigns,
        tag: assigns.as || default_tag,
        type_style:
          %{
            "h1" => "text-4xl tracking-tight",
            "h2" => "text-3xl tracking-tight",
            "h3" => "text-2xl tracking-tight",
            "h4" => "text-xl tracking-tight",
            "h5" => "text-lg tracking-tight",
            "h6" => "text-base tracking-tight",
            "body" => "text-base leading-7",
            "body-sm" => "text-sm leading-6",
            "body-xs" => "text-xs leading-5",
            "code" => "rounded-md bg-default px-1.5 py-0.5 font-mono text-sm"
          }[assigns.type],
        align_style:
          %{
            "start" => "text-start",
            "center" => "text-center",
            "end" => "text-end",
            "justify" => "text-justify"
          }[assigns.align],
        weight_style:
          %{
            "normal" => "font-normal",
            "medium" => "font-medium",
            "semibold" => "font-[590]",
            "bold" => "font-[590]"
          }[assigns.weight]
      )

    ~H"""
    <.dynamic_tag
      tag_name={@tag}
      class={[
        "typography",
        @type_style,
        @align_style,
        @color == "default" && "text-foreground",
        @color == "muted" && "text-muted",
        @weight_style,
        is_nil(@weight) && @type in ~w(h1 h2 h3 h4 h5 h6) && "font-[510]",
        @truncate && "block truncate",
        "typography--#{@type}",
        "typography--align-#{@align}",
        "typography--color-#{@color}",
        @weight && "typography--weight-#{@weight}",
        @truncate && "typography--truncate",
        @class
      ]}
      data-slot="typography"
      data-type={@type}
      {@rest}
    >
      {render_slot(@inner_block)}
    </.dynamic_tag>
    """
  end

  @doc "Applies OlisUI's prose styles to rich content."
  attr(:class, :any, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def typography_prose(assigns) do
    ~H"""
    <div
      class={[
        "typography-prose text-foreground [&_h1]:text-4xl [&_h1]:font-[510] [&_h1]:tracking-tight [&_h2]:text-3xl [&_h2]:font-[510] [&_h2]:tracking-tight [&_h3]:text-2xl [&_h3]:font-[510] [&_h3]:tracking-tight [&_h4]:text-xl [&_h4]:font-[510] [&_h4]:tracking-tight [&_h5]:text-lg [&_h5]:font-[510] [&_h5]:tracking-tight [&_h6]:text-base [&_h6]:font-[510] [&_h6]:tracking-tight [&_p]:text-base [&_p]:leading-7 [&_code]:rounded-md [&_code]:bg-default [&_code]:px-1.5 [&_code]:py-0.5 [&_code]:font-mono [&_code]:text-sm [&_code]:text-foreground [&_a]:font-medium [&_a]:text-link [&_a]:underline [&_a]:underline-offset-4 [&_blockquote]:mt-4 [&_blockquote]:border-s-4 [&_blockquote]:border-border [&_blockquote]:ps-4 [&_blockquote]:text-muted [&_blockquote]:italic [&_ul]:my-4 [&_ul]:list-disc [&_ul]:space-y-2 [&_ul]:ps-6 [&_ol]:my-4 [&_ol]:list-decimal [&_ol]:space-y-2 [&_ol]:ps-6 [&_li]:text-base [&_li]:leading-7 [&_hr]:my-8 [&_hr]:border-separator [&_pre]:my-4 [&_pre]:overflow-x-auto [&_pre]:rounded-xl [&_pre]:bg-default [&_pre]:p-4 [&_pre]:font-mono [&_pre]:text-sm [&_pre]:leading-relaxed [&_strong]:font-[590] [&_strong]:text-foreground [&_em]:italic [&_img]:my-4 [&_img]:rounded-xl",
        @class
      ]}
      data-slot="prose"
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc "An OlisUI surface; use Tailwind classes to add spacing, borders, or rounding."
  attr(:variant, :string, default: "default", values: ~w(default secondary tertiary transparent))
  attr(:class, :any, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def surface(assigns) do
    data_slot =
      Map.get(assigns.rest, :"data-slot") || Map.get(assigns.rest, "data-slot") || "surface"

    rest = Map.drop(assigns.rest, [:"data-slot", "data-slot"])
    assigns = assign(assigns, data_slot: data_slot, rest: rest)

    ~H"""
    <div
      class={[
        "surface surface--#{@variant} relative",
        @variant == "transparent" && "bg-transparent text-foreground",
        @variant == "default" && "bg-surface text-surface-foreground",
        @variant == "secondary" && "bg-surface-secondary text-surface-secondary-foreground",
        @variant == "tertiary" && "bg-surface-tertiary text-surface-tertiary-foreground",
        @class
      ]}
      data-slot={@data_slot}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc "An editable hex color or numeric color channel with OlisUI input styling."
  attr(:field, Phoenix.HTML.FormField, default: nil)
  attr(:id, :string, default: nil)
  attr(:name, :string, default: nil)
  attr(:value, :any, default: nil)
  attr(:label, :string, required: true)
  attr(:description, :string, default: nil)
  attr(:errors, :list, default: [])

  attr(:channel, :string,
    default: "hex",
    values: ~w(hex red green blue hue saturation lightness brightness alpha)
  )

  attr(:allow_alpha, :boolean, default: false)
  attr(:show_swatch, :boolean, default: nil)
  attr(:swatch_color, :string, default: nil)
  attr(:placeholder, :string, default: nil)
  attr(:min, :any, default: nil)
  attr(:max, :any, default: nil)
  attr(:step, :any, default: nil)
  attr(:variant, :string, default: "primary", values: ~w(primary secondary))
  attr(:disabled, :boolean, default: false)
  attr(:read_only, :boolean, default: false)
  attr(:required, :boolean, default: false)
  attr(:full_width, :boolean, default: false)
  attr(:class, :any, default: nil)
  attr(:rest, :global, include: ~w(autocomplete autofocus form))
  slot(:prefix)
  slot(:suffix)

  def color_field(assigns) do
    field = assigns.field
    id = assigns.id || (field && field.id)
    if is_nil(id), do: raise(ArgumentError, "color_field requires an id or field")
    value = if is_nil(assigns.value) && field, do: field.value, else: assigns.value

    normalized =
      if assigns.channel == "hex", do: normalize_color_field(value, assigns.allow_alpha)

    value = normalized || value
    preview_color = assigns.swatch_color || normalized || "#E4E4E7"
    preview_color = safe_swatch_color(preview_color)
    {external_description, rest} = Map.pop(assigns.rest, :"aria-describedby")
    {external_description_string, rest} = Map.pop(rest, "aria-describedby")
    {autocomplete, rest} = Map.pop(rest, :autocomplete)
    {autocomplete_string, rest} = Map.pop(rest, "autocomplete")

    describedby =
      [
        external_description,
        external_description_string,
        assigns.errors == [] && assigns.description && "#{id}-description",
        assigns.errors != [] && "#{id}-errors"
      ]
      |> Enum.filter(& &1)
      |> Enum.join(" ")

    channel_max =
      case assigns.channel do
        channel when channel in ~w(red green blue) -> 255
        "hue" -> 360
        _ -> 100
      end

    show_swatch =
      if is_nil(assigns.show_swatch), do: assigns.channel == "hex", else: assigns.show_swatch

    assigns =
      assigns
      |> assign(:show_swatch, show_swatch)
      |> assign(:id, id)
      |> assign(:name, assigns.name || (field && field.name))
      |> assign(:value, value)
      |> assign(:preview_color, preview_color)
      |> assign(:rest, rest)
      |> assign(:autocomplete, autocomplete || autocomplete_string || "off")
      |> assign(:describedby, describedby)
      |> assign(:channel_max, channel_max)

    ~H"""
    <div
      id={"#{@id}-color-field"}
      class={[
        "color-field flex flex-col gap-1 [&:is([data-invalid=true],[aria-invalid=true])_[data-slot=description]]:hidden [&_[data-slot=label]]:w-fit",
        @full_width && "color-field--full-width w-full",
        @class
      ]}
      data-slot="color-field"
      data-olis-color-field
      x-data="olisColorField"
      x-on:focusout="focusout($event)"
      x-on:change="change($event)"
      x-on:submit.window.capture="submit($event)"
      x-on:reset.window="reset($event)"
      x-on:phx:update.window="sync()"
      data-channel={@channel}
      data-allow-alpha={to_string(@allow_alpha)}
      data-preview-color={@preview_color}
      data-preview-override={to_string(!is_nil(@swatch_color))}
      data-invalid={if @errors != [], do: "true"}
      data-disabled={if @disabled, do: "true"}
      data-required={if @required, do: "true"}
    >
      <label class={label_classes()} data-slot="label" for={@id}>{@label}</label>
      <div
        class={[
          "color-input-group color-input-group--#{@variant} inline-flex h-9 items-center overflow-hidden rounded-field border border-[length:var(--border-width-field)] border-field-border bg-(--color-input-group-bg) text-sm text-field-foreground outline-none [transition:background-color_150ms_var(--ease-smooth),border-color_150ms_var(--ease-smooth),box-shadow_150ms_var(--ease-out)] [@media(hover:hover)]:[&:hover:not(:focus-within)]:[--color-input-group-bg:var(--color-input-group-bg-hover)] [@media(hover:hover)]:[&:hover:not(:focus-within)]:border-field-border-hover [@media(hover:hover)]:[&[data-hovered=true]:not([data-focus-within=true])]:[--color-input-group-bg:var(--color-input-group-bg-hover)] [@media(hover:hover)]:[&[data-hovered=true]:not([data-focus-within=true])]:border-field-border-hover focus-within:status-focused-field data-[focus-within=true]:status-focused-field data-[invalid=true]:status-invalid-field data-[invalid=true]:border-[color:var(--color-field-border-invalid)] data-[invalid=true]:[--color-input-group-bg:var(--color-input-group-bg-focus)] data-[disabled=true]:status-disabled aria-disabled:status-disabled has-[.color-input-group__input:disabled]:opacity-50",
          @variant == "primary" &&
            "[--color-input-group-bg:var(--field-background,var(--default))] [--color-input-group-bg-hover:var(--field-hover)] [--color-input-group-bg-focus:var(--field-focus)] shadow-field",
          @variant == "secondary" &&
            "[--color-input-group-bg:var(--default)] [--color-input-group-bg-hover:var(--default-hover)] [--color-input-group-bg-focus:var(--default)] shadow-none focus-within:[--color-input-group-bg:var(--color-input-group-bg-focus)] data-[focus-within=true]:[--color-input-group-bg:var(--color-input-group-bg-focus)]",
          @full_width && "color-input-group--full-width w-full"
        ]}
        role="presentation"
        data-slot="color-input-group"
        data-invalid={if @errors != [], do: "true"}
        data-disabled={if @disabled, do: "true"}
      >
        <div
          :if={@prefix != [] || @show_swatch}
          class="color-input-group__prefix shrink-0 text-field-placeholder ms-3 me-0 flex items-center [&_[data-olis-color-preview]]:flex"
          data-slot="color-input-group-prefix"
        >
          <%= if @prefix != [] do %>
            {render_slot(@prefix)}
          <% else %>
            <span id={"#{@id}-color-preview"} data-olis-color-preview phx-update="ignore">
              <.color_swatch
                color={@preview_color}
                label={"Color preview: #{@preview_color}"}
                size="xs"
              />
            </span>
          <% end %>
        </div>
        <input
          id={@id}
          name={@name}
          type={if @channel == "hex", do: "text", else: "number"}
          value={@value}
          class="color-input-group__input flex h-full min-w-0 flex-1 cursor-text items-center rounded-none border-0 bg-transparent px-3 py-2 text-base shadow-none outline-none placeholder:text-field-placeholder sm:text-sm [.color-input-group:has([data-slot=color-input-group-prefix])_&]:rounded-s-none [.color-input-group:has([data-slot=color-input-group-prefix])_&]:ps-2 [.color-input-group:has([data-slot=color-input-group-suffix])_&]:rounded-e-none [.color-input-group:has([data-slot=color-input-group-suffix])_&]:pe-2 [&[type=number]]:[appearance:textfield] [&[type=number]]:[-moz-appearance:textfield] [&[type=number]::-webkit-inner-spin-button]:m-0 [&[type=number]::-webkit-inner-spin-button]:[-webkit-appearance:none] [&[type=number]::-webkit-outer-spin-button]:m-0 [&[type=number]::-webkit-outer-spin-button]:[-webkit-appearance:none] [&:is(:-webkit-autofill,:autofill)]:[box-shadow:0_0_0_1000px_var(--color-input-group-bg)_inset] [&:is(:-webkit-autofill,:autofill)]:[-webkit-box-shadow:0_0_0_1000px_var(--color-input-group-bg)_inset] [&:is(:-webkit-autofill,:autofill)]:[-webkit-text-fill-color:var(--field-foreground)] [&:is(:-webkit-autofill,:autofill)]:[caret-color:var(--field-foreground)] [&:is(:-webkit-autofill,:autofill)]:[transition:background-color_9999s_ease-in-out_0s]"
          data-slot="color-input-group-input"
          data-olis-color-input
          autocomplete={@autocomplete}
          autocorrect="off"
          spellcheck="false"
          inputmode={if @channel == "hex", do: "text", else: "numeric"}
          placeholder={@placeholder}
          disabled={@disabled}
          readonly={@read_only}
          required={@required}
          pattern={
            if @channel == "hex",
              do:
                if(@allow_alpha,
                  do: "#?([0-9A-Fa-f]{3}|[0-9A-Fa-f]{4}|[0-9A-Fa-f]{6}|[0-9A-Fa-f]{8})",
                  else: "#?([0-9A-Fa-f]{3}|[0-9A-Fa-f]{6})"
                )
          }
          min={if @channel != "hex", do: @min || 0}
          max={if @channel != "hex", do: @max || @channel_max}
          step={if @channel != "hex", do: @step || 1}
          aria-invalid={if @errors != [], do: "true"}
          aria-describedby={if @describedby != "", do: @describedby}
          {@rest}
        />
        <div
          :if={@suffix != []}
          class="color-input-group__suffix shrink-0 text-field-placeholder me-3 flex items-center"
          data-slot="color-input-group-suffix"
        >
          {render_slot(@suffix)}
        </div>
      </div>
      <p
        :if={@description}
        id={"#{@id}-description"}
        class="description text-xs text-wrap wrap-break-word text-muted"
        data-slot="description"
      >
        {@description}
      </p>
      <div
        :if={@errors != []}
        id={"#{@id}-errors"}
        class={field_error_classes()}
        data-visible="true"
        data-slot="field-error"
      >
        <p :for={error <- @errors}>{error}</p>
      </div>
    </div>
    """
  end

  defp normalize_color_field(value, allow_alpha) when is_binary(value) do
    value = String.trim(value)
    hex = if String.starts_with?(value, "#"), do: String.slice(value, 1..-1//1), else: value
    allowed = if allow_alpha, do: [3, 4, 6, 8], else: [3, 6]

    if byte_size(hex) in allowed && Regex.match?(~r/\A[0-9a-fA-F]+\z/, hex) do
      hex =
        if byte_size(hex) in [3, 4],
          do: hex |> String.graphemes() |> Enum.map_join(&(&1 <> &1)),
          else: hex

      "#" <> String.upcase(hex)
    end
  end

  defp normalize_color_field(_, _), do: nil

  @doc "A color preview with OlisUI sizes, shapes, and transparency pattern."
  attr(:color, :string, required: true)
  attr(:label, :string, default: nil)
  attr(:size, :string, default: "md", values: ~w(xs sm md lg xl))
  attr(:shape, :string, default: "circle", values: ~w(circle square))
  attr(:class, :any, default: nil)
  attr(:rest, :global)

  def color_swatch(assigns) do
    color = safe_swatch_color(assigns.color)

    assigns =
      assigns |> assign(:color, color) |> assign(:accessible_label, assigns.label || color)

    ~H"""
    <span
      class={[
        "color-swatch color-swatch--#{@shape} color-swatch--#{@size} relative inline-block box-border shrink-0 [background:linear-gradient(var(--color-swatch-current),var(--color-swatch-current)),repeating-conic-gradient(#efefef_0%_25%,#f7f7f7_0%_50%)_50%/16px_16px] [box-shadow:inset_0_0_0_1px_rgba(0,0,0,0.1)]",
        @size == "xs" && "size-4",
        @size == "sm" && "size-6",
        @size == "md" && "size-8",
        @size == "lg" && "size-9",
        @size == "xl" && "size-10",
        @shape == "square" && "rounded-md",
        @shape == "circle" && @size == "xs" && "rounded-lg",
        @shape == "circle" && @size == "sm" && "rounded-xl",
        @shape == "circle" && @size == "md" && "rounded-2xl",
        @shape == "circle" && @size in ["lg", "xl"] && "rounded-3xl",
        @class
      ]}
      data-slot="color-swatch"
      role="img"
      aria-label={@accessible_label}
      style={"--color-swatch-current: #{@color}"}
      {@rest}
    ></span>
    """
  end

  @doc "A single-selection palette backed by native radio inputs."
  attr(:field, Phoenix.HTML.FormField, default: nil)
  attr(:id, :string, default: nil)
  attr(:name, :string, default: nil)
  attr(:value, :string, default: nil)
  attr(:label, :string, required: true)
  attr(:description, :string, default: nil)
  attr(:errors, :list, default: [])
  attr(:size, :string, default: "md", values: ~w(xs sm md lg xl))
  attr(:shape, :string, default: "circle", values: ~w(circle square))
  attr(:layout, :string, default: "grid", values: ~w(grid stack))
  attr(:disabled, :boolean, default: false)
  attr(:required, :boolean, default: false)
  attr(:class, :any, default: nil)
  attr(:rest, :global, include: ~w(form))

  slot :option, required: true do
    attr(:value, :string, required: true)
    attr(:label, :string, required: true)
    attr(:disabled, :boolean)
  end

  def color_swatch_picker(assigns) do
    field = assigns.field
    id = assigns.id || (field && field.id)
    if is_nil(id), do: raise(ArgumentError, "color_swatch_picker requires an id or field")
    name = assigns.name || (field && field.name) || id
    value = if is_nil(assigns.value) && field, do: field.value, else: assigns.value

    options =
      Enum.map(assigns.option, fn option ->
        color = safe_swatch_color(option.value)
        option |> Map.put(:value, color) |> Map.put(:light, light_swatch_color?(color))
      end)

    values = Enum.map(options, &canonical_swatch_color(&1.value))

    if length(values) != length(Enum.uniq(values)),
      do: raise(ArgumentError, "swatch values must be unique")

    {external_description, rest} = Map.pop(assigns.rest, :"aria-describedby")
    {external_description_string, rest} = Map.pop(rest, "aria-describedby")

    describedby =
      [
        external_description,
        external_description_string,
        assigns.description && "#{id}-description",
        assigns.errors != [] && "#{id}-errors"
      ]
      |> Enum.filter(& &1)
      |> Enum.join(" ")

    assigns =
      assigns
      |> assign(:id, id)
      |> assign(:name, name)
      |> assign(:value, value)
      |> assign(:options, options)
      |> assign(:describedby, describedby)
      |> assign(:rest, rest)

    ~H"""
    <fieldset
      id={@id}
      class={@class}
      disabled={@disabled}
      aria-describedby={if @describedby != "", do: @describedby}
    >
      <legend class={label_classes()}>{@label}</legend>
      <div
        class={[
          "color-swatch-picker flex flex-wrap items-center gap-2",
          @layout == "stack" && "flex-col",
          "color-swatch-picker--#{@layout}",
          "color-swatch-picker--#{@size}",
          "color-swatch-picker--#{@shape}"
        ]}
        data-slot="color-swatch-picker"
        data-layout={@layout}
      >
        <label
          :for={option <- @options}
          class={[
            "color-swatch-picker__item olis-swatch-picker__option relative flex items-center justify-center border-transparent outline-none no-highlight transform-gpu cursor-(--cursor-interactive) [transition:border-color_100ms_var(--ease-out),box-shadow_100ms_var(--ease-out)] focus-visible:status-focused data-[focus-visible=true]:status-focused data-[disabled=true]:status-disabled data-[selected=true]:[border-color:var(--color-swatch-current)] data-[selected=true]:shadow-field has-[:checked]:[border-color:var(--color-swatch-current)] has-[:checked]:shadow-field has-[:focus-visible]:outline-2 has-[:focus-visible]:outline-focus has-[:focus-visible]:outline-offset-2 has-[:disabled]:opacity-50 has-[:disabled]:cursor-not-allowed",
            @size == "xs" && "size-4 border",
            @size == "sm" && "size-6 border-2",
            @size == "md" && "size-8 border-2",
            @size == "lg" && "size-9 border-3",
            @size == "xl" && "size-10 border-3",
            @shape == "circle" && @size == "xs" && "rounded-lg",
            @shape == "circle" && @size == "sm" && "rounded-xl",
            @shape == "circle" && @size == "md" && "rounded-2xl",
            @shape == "circle" && @size in ["lg", "xl"] && "rounded-3xl",
            @shape == "square" && @size == "xs" && "rounded-md",
            @shape == "square" && @size == "sm" && "rounded-lg",
            @shape == "square" && @size in ["md", "lg", "xl"] && "rounded-xl"
          ]}
          data-slot="color-swatch-picker-item"
          data-disabled={if @disabled || Map.get(option, :disabled, false), do: "true"}
          style={"--color-swatch-current: #{option.value}"}
        >
          <input
            type="radio"
            class="olis-visually-hidden-input absolute [inset-block-start:0] start-0 z-[2] m-0 size-4 cursor-inherit opacity-0"
            name={@name}
            value={option.value}
            checked={canonical_swatch_color(option.value) == canonical_swatch_color(@value)}
            disabled={@disabled || Map.get(option, :disabled, false)}
            required={@required}
            aria-label={option.label}
            aria-invalid={if @errors != [], do: "true"}
            {@rest}
          />
          <span
            class={[
              "color-swatch-picker__swatch block size-full rounded-[inherit] transition-transform duration-100 ease-(--ease-out) transform-gpu hover:[transform:scale(1.1)] [.color-swatch-picker__item[data-selected=true]_&]:[transform:scale(.77)] [.olis-swatch-picker__option:has(input:checked)_&]:[transform:scale(.77)]",
              @shape == "square" && @size == "xs" && "rounded-md",
              @shape == "square" && @size in ["sm", "md", "lg", "xl"] && "rounded-lg",
              @shape == "square" && @size == "sm" &&
                "[.color-swatch-picker__item[data-selected=true]_&]:rounded-md"
            ]}
            data-slot="color-swatch-picker-swatch"
            aria-hidden="true"
            style={"background-color: #{option.value}"}
          ></span>
          <span
            class="color-swatch-picker__indicator pointer-events-none absolute inset-0 z-10 flex items-center justify-center"
            data-slot="color-swatch-picker-indicator"
            aria-hidden="true"
            data-light-color={if option.light, do: "true"}
          >
            <svg
              data-slot="color-swatch-picker-checkmark"
              class="size-1/3 text-white [transform:scale(0)_translateZ(0)] transition-transform duration-150 ease-(--ease-out) [.color-swatch-picker__indicator[data-light-color=true]_&]:text-black [.color-swatch-picker__item[data-selected=true]_&]:[transform:scale(1)_translateZ(0)] [.olis-swatch-picker__option:has(input:checked)_&]:[transform:scale(1)_translateZ(0)]"
              viewBox="0 0 12 12"
              fill="none"
              stroke="currentColor"
              stroke-width="1.5"
              stroke-linecap="round"
              stroke-linejoin="round"
              aria-hidden="true"
            >
              <polyline points="2.5 6 5 8.5 9.5 3"></polyline>
            </svg>
          </span>
        </label>
      </div>
      <p
        :if={@description}
        id={"#{@id}-description"}
        class="description text-xs text-wrap wrap-break-word text-muted"
      >
        {@description}
      </p>
      <div :if={@errors != []} id={"#{@id}-errors"} class={field_error_classes()} data-visible="true">
        <p :for={error <- @errors}>{error}</p>
      </div>
    </fieldset>
    """
  end

  defp safe_swatch_color(color) when is_binary(color) do
    value = String.trim(color)

    if value == "" || byte_size(value) > 160 ||
         !Regex.match?(~r/\A[a-zA-Z0-9#.,()%+\-\/\s]+\z/, value),
       do: raise(ArgumentError, "invalid color value")

    value
  end

  defp canonical_swatch_color("#" <> hex = original) when byte_size(hex) in [3, 4, 6, 8] do
    hex = String.downcase(hex)

    if Regex.match?(~r/\A[0-9a-f]+\z/, hex) do
      hex =
        if byte_size(hex) in [3, 4],
          do: hex |> String.graphemes() |> Enum.map_join(&(&1 <> &1)),
          else: hex

      if byte_size(hex) == 6, do: "#" <> hex <> "ff", else: "#" <> hex
    else
      original
    end
  end

  defp canonical_swatch_color(value), do: value

  defp light_swatch_color?("#" <> hex) when byte_size(hex) in [3, 4, 6, 8] do
    hex =
      if byte_size(hex) in [3, 4],
        do: hex |> String.graphemes() |> Enum.map_join(&(&1 <> &1)),
        else: hex

    case Base.decode16(hex, case: :mixed) do
      {:ok, <<red, green, blue, _rest::binary>>} ->
        (0.2126 * red + 0.7152 * green + 0.0722 * blue) / 255 > 0.5

      _ ->
        false
    end
  end

  defp light_swatch_color?(_), do: false

  @doc "A notification region for client and LiveView toast events."
  attr(:id, :string, required: true)

  attr(:placement, :string,
    default: "bottom",
    values: ~w(top top-start top-end bottom bottom-start bottom-end)
  )

  attr(:label, :string, default: "Notifications")
  attr(:width, :integer, default: 460)
  attr(:gap, :integer, default: 12)
  attr(:max_visible, :integer, default: 3)
  attr(:timeout, :integer, default: 4000)
  attr(:expanded, :boolean, default: false)
  attr(:class, :any, default: nil)

  slot :indicator do
    attr(:name, :string, required: true)
  end

  def toast_region(assigns) do
    names = Enum.map(assigns.indicator, & &1.name)

    if length(names) != length(Enum.uniq(names)) ||
         Enum.any?(names, &(not is_binary(&1) || not Regex.match?(~r/\A[a-zA-Z0-9_-]+\z/, &1))),
       do: raise(ArgumentError, "toast indicator names must be unique alphanumeric identifiers")

    assigns = assign(assigns, :indicator_names, names)

    if assigns.width <= 0 || assigns.gap < 0 || assigns.max_visible < 1 || assigns.timeout < 0,
      do:
        raise(
          ArgumentError,
          "toast width and max_visible must be positive; gap and timeout must be non-negative"
        )

    ~H"""
    <div
      id={@id}
      class={[
        "toast-region toast-region--#{@placement} pointer-events-none fixed z-(--z-index-toast) block w-[calc(100vw-2rem)] outline-none focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-focus data-[focus-visible=true]:outline-2 data-[focus-visible=true]:outline-offset-2 data-[focus-visible=true]:outline-focus sm:w-auto sm:min-w-(--toast-width)",
        @placement == "bottom" && "bottom-4 left-1/2 -translate-x-1/2",
        @placement == "bottom-start" && "start-4 bottom-4",
        @placement == "bottom-end" && "end-4 bottom-4",
        @placement == "top" && "top-4 left-1/2 -translate-x-1/2",
        @placement == "top-start" && "start-4 top-4",
        @placement == "top-end" && "end-4 top-4",
        @placement in ["bottom", "bottom-start", "bottom-end"] &&
          "[@supports(-webkit-touch-callout:none)]:w-0 [@supports(-webkit-touch-callout:none)]:min-w-0 [@supports(-webkit-touch-callout:none)]:sm:min-w-0 [@supports(-webkit-touch-callout:none)]:focus-visible:outline-none [@supports(-webkit-touch-callout:none)]:data-[focus-visible=true]:outline-none [@supports(-webkit-touch-callout:none)]:[&:focus-visible_.toast[data-frontmost=true]]:outline-2 [@supports(-webkit-touch-callout:none)]:[&:focus-visible_.toast[data-frontmost=true]]:outline-offset-2 [@supports(-webkit-touch-callout:none)]:[&:focus-visible_.toast[data-frontmost=true]]:outline-focus [@supports(-webkit-touch-callout:none)]:[&[data-focus-visible=true]_.toast[data-frontmost=true]]:outline-2 [@supports(-webkit-touch-callout:none)]:[&[data-focus-visible=true]_.toast[data-frontmost=true]]:outline-offset-2 [@supports(-webkit-touch-callout:none)]:[&[data-focus-visible=true]_.toast[data-frontmost=true]]:outline-focus",
        @class
      ]}
      data-slot="toast-region"
      data-olis-toast-region
      x-data="olisToastRegion"
      x-on:olis:toast.window="show($event.detail)"
      x-on:phx:olis:toast.window="show($event.detail)"
      x-on:olis:toast-update.window="update($event.detail)"
      x-on:phx:olis:toast-update.window="update($event.detail)"
      x-on:olis:toast-close.window="closeEvent($event.detail)"
      x-on:phx:olis:toast-close.window="closeEvent($event.detail)"
      x-on:olis:toast-clear.window="clearEvent($event.detail)"
      x-on:phx:olis:toast-clear.window="clearEvent($event.detail)"
      x-on:pointerenter="pointerEnter($event)"
      x-on:pointermove="pointerEnter($event)"
      x-on:pointerleave="pointerLeave($event)"
      x-on:focusin="focusIn($event)"
      x-on:focusout="focusOut($event)"
      x-on:keydown.document="keydown($event)"
      x-on:visibilitychange.document="reconcile()"
      x-on:focus.window="reconcile()"
      x-on:blur.window="reconcile()"
      x-on:resize.window="layout()"
      data-placement={@placement}
      data-gap={@gap}
      data-max-visible={@max_visible}
      data-timeout={@timeout}
      data-indicators={Jason.encode!(@indicator_names)}
      data-expanded={to_string(@expanded)}
      style={"--toast-width: #{@width}px; --gap: #{@gap}px"}
      role="region"
      aria-label={@label}
      tabindex="-1"
      phx-update="ignore"
    >
      <ol data-olis-toast-list class="contents">
        <template x-for="item in items" x-bind:key="item.uid">
          <li class="contents">
            <div
              class={[
                "toast pointer-events-auto absolute inset-x-0 grid h-[var(--toast-height,auto)] grid-cols-[auto_minmax(0,1fr)] items-start justify-start gap-x-1.5 gap-y-2 rounded-[12px] border-[0.5px] border-border bg-surface px-4 py-3 shadow-overlay [--toast-y:var(--offset-collapsed,0px)] [--toast-enter:0%] [--toast-scale:var(--scale-collapsed,1)] [--toast-ease:var(--ease-out-fluid)] [--toast-enter-duration:350ms] [--toast-exit-duration:250ms] [--toast-translate-duration:var(--toast-enter-duration)] [--toast-height-duration:var(--toast-enter-duration)] [--toast-opacity-duration:150ms] [transform:translateY(calc(var(--dir,1)_*_(var(--toast-y)_+_var(--toast-enter))))_scale(var(--toast-scale))] [transition:transform_var(--toast-translate-duration)_var(--toast-ease),height_var(--toast-height-duration)_var(--toast-ease),opacity_var(--toast-opacity-duration)_var(--toast-ease)] sm:grid-cols-[auto_minmax(0,1fr)_auto] sm:gap-y-0 data-[entering=true]:[--toast-enter:-100%] data-[expanded=true]:[--toast-y:var(--offset-expanded,0px)] data-[expanded=true]:[--toast-scale:1] data-[expanded=true]:h-[var(--toast-height,auto)] data-[exiting=true]:opacity-0 data-[hidden=true]:pointer-events-none data-[hidden=true]:grid data-[hidden=true]:opacity-0 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-focus data-[focus-visible=true]:outline-2 data-[focus-visible=true]:outline-offset-2 data-[focus-visible=true]:outline-focus",
                "[&:not(:has([data-slot=toast-indicator]))]:grid-cols-1 sm:[&:not(:has([data-slot=toast-indicator]))]:grid-cols-[minmax(0,1fr)_auto] [&>:not([data-slot=toast-close])]:transition-opacity [&>:not([data-slot=toast-close])]:duration-200 [&>:not([data-slot=toast-close])]:ease-(--toast-ease) [&:not([data-frontmost=true]):not([data-expanded=true])]:h-[var(--front-height,0px)] [&:not([data-frontmost=true]):not([data-expanded=true])]:overflow-hidden [&:not([data-frontmost=true]):not([data-expanded=true])>:not([data-slot=toast-close])]:opacity-0",
                "data-[expanded=true]:after:absolute data-[expanded=true]:after:-z-1 data-[expanded=true]:after:inset-x-0 data-[expanded=true]:after:content-[''] [&[data-exiting=true][data-frontmost=true]]:[--toast-translate-duration:var(--toast-exit-duration)] [&[data-exiting=true][data-frontmost=true]]:[--toast-opacity-duration:150ms] [&[data-exiting=true][data-frontmost=true]]:[--toast-enter:-100%] [&[data-exiting=true][data-frontmost=true]]:[--toast-scale:1] [&[data-exiting=true][data-expanded=true]:not([data-frontmost=true])]:[--toast-translate-duration:200ms] [&[data-exiting=true][data-expanded=true]:not([data-frontmost=true])]:[--toast-opacity-duration:150ms] [&[data-exiting=true][data-expanded=true]:not([data-frontmost=true])]:[--toast-scale:0.96] [&[data-exiting=true]:not([data-expanded=true]):not([data-frontmost=true])]:[--toast-translate-duration:200ms] [&[data-exiting=true]:not([data-expanded=true]):not([data-frontmost=true])]:[--toast-opacity-duration:150ms] [&[data-exiting=true]:not([data-expanded=true]):not([data-frontmost=true])]:[--toast-scale:calc(var(--scale-collapsed,1)*0.96)]",
                @placement in ["bottom", "bottom-start", "bottom-end"] &&
                  "bottom-0 origin-bottom [--dir:-1] data-[expanded=true]:after:top-[calc(-1_*_var(--gap,12px)_-_1px)] data-[expanded=true]:after:bottom-0 [@supports(-webkit-touch-callout:none)]:w-[min(var(--toast-width),calc(100vw-2rem))]",
                @placement in ["top", "top-start", "top-end"] &&
                  "top-0 origin-top [--dir:1] data-[expanded=true]:after:top-0 data-[expanded=true]:after:bottom-[calc(-1_*_var(--gap,12px)_-_1px)]",
                @placement == "bottom" &&
                  "[@supports(-webkit-touch-callout:none)]:end-auto [@supports(-webkit-touch-callout:none)]:-translate-x-1/2 [@supports(-webkit-touch-callout:none)]:rtl:translate-x-1/2",
                @placement == "bottom-start" && "[@supports(-webkit-touch-callout:none)]:end-auto",
                @placement == "bottom-end" && "[@supports(-webkit-touch-callout:none)]:start-auto"
              ]}
              x-bind:class="`toast--${$root.dataset.placement} toast--${variant(item.data.variant)}`"
              data-slot="toast"
              data-olis-toast
              x-bind:data-toast-uid="item.uid"
              x-bind:data-index="item.index"
              x-bind:data-frontmost="String(item.index === 0)"
              x-bind:data-placement="$root.dataset.placement"
              x-bind:data-expanded="item.expanded ? 'true' : null"
              x-bind:data-hidden="item.hidden ? 'true' : null"
              x-bind:data-entering="item.entering ? 'true' : null"
              x-bind:data-exiting="item.exiting ? 'true' : null"
              x-bind:aria-hidden="item.hidden || item.exiting ? 'true' : null"
              x-bind:inert="item.hidden || item.exiting"
              x-bind:tabindex="!item.hidden && (item.index === 0 || item.expanded) ? 0 : -1"
              x-bind:style="style(item)"
              role="alertdialog"
              aria-modal="false"
              x-bind:aria-labelledby="`${item.uid}-title`"
              x-bind:aria-describedby="item.data.description ? `${item.uid}-description` : null"
            >
              <template x-if="loading(item)">
                <div
                  class="toast__indicator col-start-1 row-start-1 flex shrink-0 items-center justify-center p-1 text-overlay-foreground select-none [&_[data-slot=toast-default-icon]]:box-content [&_[data-slot=toast-default-icon]]:size-4 [&_[data-slot=spinner]]:size-4 [&_[data-slot=spinner-icon]]:size-4 [.toast--success_&]:text-success-soft-foreground [.toast--warning_&]:text-warning-soft-foreground [.toast--danger_&]:text-danger-soft-foreground [&[data-swapped=true]>*:not([data-slot=spinner])]:[animation:toast-indicator-fade_150ms_var(--toast-ease),toast-indicator-scale_200ms_var(--toast-ease)]"
                  data-slot="toast-indicator"
                  aria-hidden="true"
                >
                  <span
                    class="spinner spinner--sm spinner--current pointer-events-none inline-flex size-4 shrink-0 animate-spin-fast text-inherit"
                    data-slot="spinner"
                  >
                    <svg data-slot="spinner-icon" viewBox="0 0 24 24" aria-hidden="true">
                      <defs>
                        <linearGradient
                          x-bind:id="`${item.uid}-spinner-1`"
                          x1="50%"
                          x2="50%"
                          y1="5.271%"
                          y2="91.793%"
                        >
                          <stop offset="0%" stop-color="currentColor" /><stop
                            offset="100%"
                            stop-color="currentColor"
                            stop-opacity="0.55"
                          />
                        </linearGradient>
                        <linearGradient
                          x-bind:id="`${item.uid}-spinner-2`"
                          x1="50%"
                          x2="50%"
                          y1="15.24%"
                          y2="87.15%"
                        >
                          <stop offset="0%" stop-color="currentColor" stop-opacity="0" /><stop
                            offset="100%"
                            stop-color="currentColor"
                            stop-opacity="0.55"
                          />
                        </linearGradient>
                      </defs>
                      <g fill="none">
                        <path
                          d="M8.749.021a1.5 1.5 0 0 1 .497 2.958A7.5 7.5 0 0 0 3 10.375a7.5 7.5 0 0 0 7.5 7.5v3c-5.799 0-10.5-4.7-10.5-10.5C0 5.23 3.726.865 8.749.021"
                          x-bind:fill="`url(#${item.uid}-spinner-1)`"
                          transform="translate(1.5 1.625)"
                        />
                        <path
                          d="M15.392 2.673a1.5 1.5 0 0 1 2.119-.115A10.48 10.48 0 0 1 21 10.375c0 5.8-4.701 10.5-10.5 10.5v-3a7.5 7.5 0 0 0 5.007-13.084a1.5 1.5 0 0 1-.115-2.118"
                          x-bind:fill="`url(#${item.uid}-spinner-2)`"
                          transform="translate(1.5 1.625)"
                        />
                      </g>
                    </svg>
                  </span>
                </div>
              </template>
              <template
                :for={indicator <- @indicator}
                x-if={"!loading(item) && item.data.indicator === #{Jason.encode!(indicator.name)}"}
              >
                <div
                  class="toast__indicator col-start-1 row-start-1 flex shrink-0 items-center justify-center p-1 text-overlay-foreground select-none [&_[data-slot=toast-default-icon]]:box-content [&_[data-slot=toast-default-icon]]:size-4 [&_[data-slot=spinner]]:size-4 [&_[data-slot=spinner-icon]]:size-4 [.toast--success_&]:text-success-soft-foreground [.toast--warning_&]:text-warning-soft-foreground [.toast--danger_&]:text-danger-soft-foreground [&[data-swapped=true]>*:not([data-slot=spinner])]:[animation:toast-indicator-fade_150ms_var(--toast-ease),toast-indicator-scale_200ms_var(--toast-ease)]"
                  data-slot="toast-indicator"
                  aria-hidden="true"
                >
                  {render_slot(indicator)}
                </div>
              </template>
              <template x-if="!loading(item) && item.data.indicator !== false && !customIndicator(item)">
                <div
                  class="toast__indicator col-start-1 row-start-1 flex shrink-0 items-center justify-center p-1 text-overlay-foreground select-none [&_[data-slot=toast-default-icon]]:box-content [&_[data-slot=toast-default-icon]]:size-4 [&_[data-slot=spinner]]:size-4 [&_[data-slot=spinner-icon]]:size-4 [.toast--success_&]:text-success-soft-foreground [.toast--warning_&]:text-warning-soft-foreground [.toast--danger_&]:text-danger-soft-foreground [&[data-swapped=true]>*:not([data-slot=spinner])]:[animation:toast-indicator-fade_150ms_var(--toast-ease),toast-indicator-scale_200ms_var(--toast-ease)]"
                  data-slot="toast-indicator"
                >
                  <svg
                    data-slot="toast-default-icon"
                    viewBox="0 0 16 16"
                    width="16"
                    height="16"
                    aria-hidden="true"
                  ><path
                    x-bind:d="iconPath(item.data.variant)"
                    fill="currentColor"
                    fill-rule="evenodd"
                    clip-rule="evenodd"
                  /></svg>
                </div>
              </template>
              <div
                class="toast__content col-start-2 row-start-1 flex min-w-0 flex-col items-start self-center [.toast:not(:has([data-slot=toast-indicator]))_&]:col-start-1"
                data-slot="toast-content"
                role="alert"
                aria-atomic="true"
              >
                <span
                  class="toast__title text-sm leading-5 font-medium text-overlay-foreground [.toast--accent_&]:text-accent-soft-foreground [.toast--success_&]:text-success-soft-foreground [.toast--warning_&]:text-warning-soft-foreground [.toast--danger_&]:text-danger-soft-foreground"
                  data-slot="toast-title"
                  x-bind:id="`${item.uid}-title`"
                  x-text="item.data.title"
                ></span>
                <template x-if="item.data.description">
                  <span
                    class="toast__description text-sm text-muted"
                    data-slot="toast-description"
                    x-bind:id="`${item.uid}-description`"
                    x-text="item.data.description"
                  ></span>
                </template>
              </div>
              <template x-if="item.data.action && item.data.action.label">
                <button
                  type="button"
                  class={[
                    button_classes("tertiary", "md"),
                    "toast__action col-start-2 row-start-2 justify-self-start sm:col-start-3 sm:row-start-1 [.toast:not(:has([data-slot=toast-indicator]))_&]:col-start-1 sm:[.toast:not(:has([data-slot=toast-indicator]))_&]:col-start-2"
                  ]}
                  data-slot="toast-action-button"
                  data-olis-toast-action
                  x-bind:phx-click="actionCommand(item)"
                  x-on:click="action(item)"
                  x-text="item.data.action.label"
                ></button>
              </template>
              <button
                type="button"
                class={[
                  close_button_classes(true),
                  "toast__close-button focus-visible:pointer-events-auto focus-visible:opacity-100 pointer-events-none absolute! -end-1 -top-1 border-border bg-default opacity-0 transition-opacity duration-150 ease-(--ease-smooth) sm:border sm:bg-overlay [&_[data-slot=close-button-icon]]:size-3.5 sm:[&_[data-slot=close-button-icon]]:size-3 [.toast[data-frontmost=true]:not([data-exiting=true]):hover_&]:pointer-events-auto [.toast[data-frontmost=true]:not([data-exiting=true]):hover_&]:opacity-100 [.toast[data-expanded=true]:not([data-exiting=true]):hover_&]:pointer-events-auto [.toast[data-expanded=true]:not([data-exiting=true]):hover_&]:opacity-100 [.toast[data-frontmost=true][data-hovered=true]:not([data-exiting=true])_&]:pointer-events-auto [.toast[data-frontmost=true][data-hovered=true]:not([data-exiting=true])_&]:opacity-100 [.toast[data-expanded=true][data-hovered=true]:not([data-exiting=true])_&]:pointer-events-auto [.toast[data-expanded=true][data-hovered=true]:not([data-exiting=true])_&]:opacity-100"
                ]}
                data-slot="toast-close"
                data-olis-toast-close
                aria-label="Close"
                x-on:click="close(item)"
              >
                <svg
                  data-slot="close-button-icon"
                  viewBox="0 0 16 16"
                  width="16"
                  height="16"
                  aria-hidden="true"
                ><path
                  d="M3.47 3.47a.75.75 0 0 1 1.06 0L8 6.94l3.47-3.47a.75.75 0 1 1 1.06 1.06L9.06 8l3.47 3.47a.75.75 0 1 1-1.06 1.06L8 9.06l-3.47 3.47a.75.75 0 0 1-1.06-1.06L6.94 8 3.47 4.53a.75.75 0 0 1 0-1.06Z"
                  fill="currentColor"
                  fill-rule="evenodd"
                  clip-rule="evenodd"
                /></svg>
              </button>
            </div>
          </li>
        </template>
      </ol>
    </div>
    """
  end

  @doc "A segmented Gregorian date field backed by a native date input."
  attr(:field, Phoenix.HTML.FormField, default: nil)
  attr(:id, :string, default: nil)
  attr(:name, :string, default: nil)
  attr(:value, :any, default: nil)
  attr(:label, :string, required: true)
  attr(:description, :string, default: nil)
  attr(:errors, :list, default: [])
  attr(:min, :any, default: nil)
  attr(:max, :any, default: nil)
  attr(:locale, :string, default: nil)
  attr(:unavailable_dates, :list, default: [])
  attr(:variant, :string, default: "primary", values: ~w(primary secondary))
  attr(:disabled, :boolean, default: false)
  attr(:read_only, :boolean, default: false)
  attr(:required, :boolean, default: false)
  attr(:full_width, :boolean, default: false)
  attr(:class, :any, default: nil)
  attr(:rest, :global, include: ~w(autocomplete autofocus form))
  slot(:prefix)
  slot(:suffix)

  def date_field(assigns) do
    field = assigns.field
    id = assigns.id || (field && field.id)
    if is_nil(id), do: raise(ArgumentError, "date_field requires an id or field")
    value = if is_nil(assigns.value) && field, do: field.value, else: assigns.value
    min = calendar_iso(assigns.min)
    max = calendar_iso(assigns.max)
    if min && max && min > max, do: raise(ArgumentError, "date_field min must not exceed max")
    {external_description, rest} = Map.pop(assigns.rest, :"aria-describedby")
    {external_description_string, rest} = Map.pop(rest, "aria-describedby")

    describedby =
      [
        external_description,
        external_description_string,
        assigns.description && "#{id}-description",
        assigns.errors != [] && "#{id}-errors"
      ]
      |> Enum.filter(& &1)
      |> Enum.join(" ")

    assigns =
      assigns
      |> assign(:id, id)
      |> assign(:name, assigns.name || (field && field.name))
      |> assign(:value, calendar_value(value))
      |> assign(:min, min)
      |> assign(:max, max)
      |> assign(
        :unavailable_json,
        Jason.encode!(Enum.map(assigns.unavailable_dates, &calendar_iso/1))
      )
      |> assign(:rest, rest)
      |> assign(:describedby, describedby)

    ~H"""
    <div
      id={"#{@id}-date-field"}
      class={[
        "date-field flex flex-col gap-1 [&:is([data-invalid=true],[aria-invalid=true])_[data-slot=description]]:hidden [&_[data-slot=label]]:w-fit",
        @full_width && "date-field--full-width w-full",
        @class
      ]}
      data-olis-date-field
      data-locale={@locale}
      data-variant={@variant}
      data-unavailable={@unavailable_json}
      data-invalid={if @errors != [], do: "true"}
      data-disabled={if @disabled, do: "true"}
      data-required={if @required, do: "true"}
      phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["data-enhanced"])}
    >
      <label id={"#{@id}-label"} class={label_classes()} data-slot="label" for={@id}>{@label}</label>
      <input
        id={@id}
        name={@name}
        type="date"
        value={@value}
        min={@min}
        max={@max}
        class={[
          input_classes(@variant),
          @full_width && "input--full-width w-full",
          "olis-date-field-native aria-hidden:pointer-events-none aria-hidden:absolute aria-hidden:size-px aria-hidden:opacity-0"
        ]}
        disabled={@disabled}
        readonly={@read_only}
        required={@required}
        aria-invalid={if @errors != [], do: "true"}
        aria-describedby={if @describedby != "", do: @describedby}
        data-olis-date-native
        phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["aria-hidden", "tabindex"])}
        {@rest}
      />
      <div id={"#{@id}-date-enhanced"} data-olis-date-ui phx-update="ignore" hidden>
        <div
          class={[
            date_input_group_classes(),
            "date-input-group--#{@variant}",
            @full_width && "date-input-group--full-width w-full"
          ]}
          data-slot="date-input-group"
          data-olis-date-group
          role="group"
          aria-labelledby={"#{@id}-label"}
          aria-describedby={if @describedby != "", do: @describedby}
          data-invalid={if @errors != [], do: "true"}
          data-disabled={if @disabled, do: "true"}
        >
          <span
            :if={@prefix != []}
            class="date-input-group__prefix pointer-events-none [.date-picker_&]:pointer-events-auto ms-3 me-0 flex shrink-0 items-center text-field-placeholder"
            data-slot="date-input-group-prefix"
          >{render_slot(@prefix)}</span>
          <div
            class={date_input_classes()}
            data-slot="date-input-group-input"
            data-olis-date-segments
          >
          </div>
          <span
            :if={@suffix != []}
            class="date-input-group__suffix pointer-events-none [.date-picker_&]:pointer-events-auto me-3 flex shrink-0 items-center text-field-placeholder"
            data-slot="date-input-group-suffix"
          >{render_slot(@suffix)}</span>
        </div>
        <p
          id={"#{@id}-native-error"}
          class={field_error_classes()}
          data-visible="true"
          data-olis-date-error
          hidden
        >
        </p>
      </div>
      <p
        :if={@description}
        id={"#{@id}-description"}
        class="description text-xs text-wrap wrap-break-word text-muted"
        data-slot="description"
      >
        {@description}
      </p>
      <div :if={@errors != []} id={"#{@id}-errors"} class={field_error_classes()} data-visible="true">
        <p :for={error <- @errors}>{error}</p>
      </div>
    </div>
    """
  end

  @doc "A segmented time field backed by a native time input."
  attr(:field, Phoenix.HTML.FormField, default: nil)
  attr(:id, :string, default: nil)
  attr(:name, :string, default: nil)
  attr(:value, :any, default: nil)
  attr(:label, :string, required: true)
  attr(:description, :string, default: nil)
  attr(:errors, :list, default: [])
  attr(:min, :any, default: nil)
  attr(:max, :any, default: nil)
  attr(:locale, :string, default: nil)
  attr(:hour_cycle, :integer, default: nil, values: [nil, 12, 24])
  attr(:granularity, :string, default: "minute", values: ~w(hour minute second))
  attr(:variant, :string, default: "primary", values: ~w(primary secondary))
  attr(:disabled, :boolean, default: false)
  attr(:read_only, :boolean, default: false)
  attr(:required, :boolean, default: false)
  attr(:full_width, :boolean, default: false)
  attr(:class, :any, default: nil)
  attr(:rest, :global, include: ~w(autocomplete autofocus form))
  slot(:prefix)
  slot(:suffix)

  def time_field(assigns) do
    field = assigns.field
    id = assigns.id || (field && field.id)
    if is_nil(id), do: raise(ArgumentError, "time_field requires an id or field")
    value = if is_nil(assigns.value) && field, do: field.value, else: assigns.value
    min = time_field_bound!(assigns.min)
    max = time_field_bound!(assigns.max)

    if min && max && Time.compare(min, max) == :gt,
      do: raise(ArgumentError, "time_field min must not exceed max")

    {external_description, rest} = Map.pop(assigns.rest, :"aria-describedby")
    {external_description_string, rest} = Map.pop(rest, "aria-describedby")

    describedby =
      [
        external_description,
        external_description_string,
        assigns.description && "#{id}-description",
        assigns.errors != [] && "#{id}-errors"
      ]
      |> Enum.filter(& &1)
      |> Enum.join(" ")

    assigns =
      assigns
      |> assign(:id, id)
      |> assign(:name, assigns.name || (field && field.name))
      |> assign(:value, if(match?(%Time{}, value), do: Time.to_iso8601(value), else: value))
      |> assign(:min, min && Time.to_iso8601(min))
      |> assign(:max, max && Time.to_iso8601(max))
      |> assign(:step, %{"hour" => 3600, "minute" => 60, "second" => 1}[assigns.granularity])
      |> assign(:rest, rest)
      |> assign(:describedby, describedby)

    ~H"""
    <div
      id={"#{@id}-time-field"}
      class={[
        "time-field flex flex-col gap-1 [&:is([data-invalid=true],[aria-invalid=true])_[data-slot=description]]:hidden [&_[data-slot=label]]:w-fit",
        @full_width && "time-field--full-width w-full",
        @class
      ]}
      data-slot="time-field"
      data-olis-time-field
      x-data="olisTimeField"
      x-on:keydown="keydown($event)"
      x-on:beforeinput="beforeinput($event)"
      x-on:paste="paste($event)"
      x-on:focusin="focusin($event)"
      x-on:click="click($event)"
      x-on:invalid.capture="invalid($event)"
      x-on:change="change($event)"
      x-on:reset.document="reset($event)"
      x-on:phx:update.document="update()"
      data-locale={@locale}
      data-hour-cycle={@hour_cycle}
      data-granularity={@granularity}
      data-variant={@variant}
      data-invalid={if @errors != [], do: "true"}
      data-disabled={if @disabled, do: "true"}
      phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["data-enhanced"])}
    >
      <label id={"#{@id}-label"} class={label_classes()} data-slot="label" for={@id}>{@label}</label>
      <input
        id={@id}
        name={@name}
        type="time"
        value={@value}
        min={@min}
        max={@max}
        step={@step}
        class={[
          input_classes(@variant),
          @full_width && "input--full-width w-full",
          "aria-hidden:pointer-events-none aria-hidden:absolute aria-hidden:size-px aria-hidden:opacity-0"
        ]}
        disabled={@disabled}
        readonly={@read_only}
        required={@required}
        aria-invalid={if @errors != [], do: "true"}
        aria-describedby={if @describedby != "", do: @describedby}
        data-olis-time-native
        phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["aria-hidden", "tabindex"])}
        {@rest}
      />
      <div id={"#{@id}-time-enhanced"} data-olis-time-ui phx-update="ignore" hidden>
        <div
          class={[
            date_input_group_classes(),
            "date-input-group--#{@variant}",
            @full_width && "date-input-group--full-width w-full"
          ]}
          data-slot="date-input-group"
          data-olis-time-group
          role="group"
          aria-labelledby={"#{@id}-label"}
        >
          <span
            :if={@prefix != []}
            class="date-input-group__prefix pointer-events-none [.date-picker_&]:pointer-events-auto ms-3 me-0 flex shrink-0 items-center text-field-placeholder"
            data-slot="date-input-group-prefix"
          >{render_slot(@prefix)}</span>
          <div
            class={date_input_classes()}
            data-slot="date-input-group-input"
            data-olis-time-segments
          >
          </div>
          <span
            :if={@suffix != []}
            class="date-input-group__suffix pointer-events-none [.date-picker_&]:pointer-events-auto me-3 flex shrink-0 items-center text-field-placeholder"
            data-slot="date-input-group-suffix"
          >{render_slot(@suffix)}</span>
        </div>
        <p
          id={"#{@id}-native-error"}
          class={field_error_classes()}
          data-visible="true"
          data-olis-time-error
          hidden
        >
        </p>
      </div>
      <p
        :if={@description}
        id={"#{@id}-description"}
        class="description text-xs text-wrap wrap-break-word text-muted"
        data-slot="description"
      >
        {@description}
      </p>
      <div :if={@errors != []} id={"#{@id}-errors"} class={field_error_classes()} data-visible="true">
        <p :for={error <- @errors}>{error}</p>
      </div>
    </div>
    """
  end

  defp time_field_bound!(nil), do: nil
  defp time_field_bound!(%Time{} = time), do: time

  defp time_field_bound!(value) when is_binary(value) do
    value = if Regex.match?(~r/\A\d{2}:\d{2}\z/, value), do: value <> ":00", else: value

    case Time.from_iso8601(value) do
      {:ok, time} -> time
      _ -> raise ArgumentError, "time_field bounds must be ISO 8601 times"
    end
  end

  defp time_field_bound!(_), do: raise(ArgumentError, "time_field bounds must be ISO 8601 times")

  @doc "A segmented date field with a calendar popover."
  attr(:field, Phoenix.HTML.FormField, default: nil)
  attr(:id, :string, default: nil)
  attr(:name, :string, default: nil)
  attr(:value, :any, default: nil)
  attr(:label, :string, required: true)
  attr(:description, :string, default: nil)
  attr(:errors, :list, default: [])
  attr(:min, :any, default: nil)
  attr(:max, :any, default: nil)
  attr(:today, :any, default: nil)
  attr(:focused_date, :any, default: nil)
  attr(:unavailable_dates, :list, default: [])
  attr(:locale, :string, default: nil)
  attr(:week_starts_on, :integer, default: nil)
  attr(:weeks_in_month, :integer, default: nil)
  attr(:year_picker, :boolean, default: true)
  attr(:variant, :string, default: "primary", values: ~w(primary secondary))
  attr(:disabled, :boolean, default: false)
  attr(:read_only, :boolean, default: false)
  attr(:required, :boolean, default: false)
  attr(:full_width, :boolean, default: false)
  attr(:class, :any, default: nil)
  attr(:rest, :global, include: ~w(autocomplete autofocus form))
  slot(:indicator)

  def date_picker(assigns) do
    field = assigns.field
    id = assigns.id || (field && field.id)
    if is_nil(id), do: raise(ArgumentError, "date_picker requires an id or field")
    value = if is_nil(assigns.value) && field, do: field.value, else: assigns.value
    assigns = assigns |> assign(:id, id) |> assign(:value, value)

    ~H"""
    <div
      id={"#{@id}-picker"}
      class={["date-picker inline-flex flex-col gap-1", @full_width && "w-full", @class]}
      data-olis-date-picker
    >
      <.date_field
        field={@field}
        id={@id}
        name={@name}
        value={@value}
        label={@label}
        description={@description}
        errors={@errors}
        min={@min}
        max={@max}
        locale={@locale}
        unavailable_dates={@unavailable_dates}
        variant={@variant}
        disabled={@disabled}
        read_only={@read_only}
        required={@required}
        full_width={@full_width}
        {@rest}
      >
        <:suffix>
          <button
            type="button"
            class="date-picker__trigger inline-flex w-full items-center rounded-field p-1 text-sm no-highlight cursor-(--cursor-interactive) [transition:box-shadow_150ms_var(--ease-out)] [&:focus-visible:not([data-focused])]:status-focused data-[focus-visible=true]:status-focused disabled:status-disabled data-[disabled=true]:status-disabled aria-disabled:status-disabled"
            data-slot="date-picker-trigger"
            data-olis-date-picker-trigger
            aria-label="Calendar"
            aria-labelledby={"#{@id}-picker-trigger #{@id}-label"}
            id={"#{@id}-picker-trigger"}
            aria-haspopup="dialog"
            aria-expanded="false"
            aria-controls={"#{@id}-picker-popover"}
            disabled={@disabled}
          >
            <span
              class="date-picker__trigger-indicator inline-flex size-4 items-center justify-center text-field-placeholder"
              data-slot="date-picker-trigger-indicator"
              aria-hidden="true"
            >
              <%= if @indicator != [] do %>
                {render_slot(@indicator)}
              <% else %>
                <svg viewBox="0 0 13 14" width="1em" height="1em" fill="none" aria-hidden="true">
                  <path
                    fill="currentColor"
                    fill-rule="evenodd"
                    clip-rule="evenodd"
                    d="M3.75 4.5A.75.75 0 0 1 3 3.75v-.748a1.5 1.5 0 0 0-1.5 1.5v1h10v-1a1.5 1.5 0 0 0-1.5-1.5v.75a.75.75 0 1 1-1.5 0v-.75h-4v.747a.75.75 0 0 1-.75.75ZM8.5 1.501h-4V.75a.75.75 0 0 0-1.5 0v.752a3 3 0 0 0-3 3v6a3 3 0 0 0 3 3h7a3 3 0 0 0 3-3v-6a3 3 0 0 0-3-3v-.75a.75.75 0 0 0-1.5 0v.75Zm-7 5.5v3.5a1.5 1.5 0 0 0 1.5 1.5h7a1.5 1.5 0 0 0 1.5-1.5v-3.5h-10Z"
                  />
                </svg>
              <% end %>
            </span>
          </button>
        </:suffix>
      </.date_field>
      <div
        id={"#{@id}-picker-popover"}
        class="date-picker__popover olis-date-picker-popover scrollbar-none fixed inset-auto m-0 w-fit origin-(--trigger-anchor-point) overflow-y-auto overscroll-contain rounded-[12px] border-0 bg-overlay p-3 [box-shadow:var(--overlay-shadow)] [&:focus-visible:not([data-focused])]:outline-none data-[focus-visible=true]:outline-none data-[entering=true]:[animation:olis-overlay-enter-95_150ms_var(--ease-smooth)] [&[data-entering=true][data-placement^=top]]:[animation-name:olis-overlay-enter-95-y] [&[data-entering=true][data-placement^=bottom]]:[animation-name:olis-overlay-enter-95-ny] [&[data-entering=true][data-placement^=left]]:[animation-name:olis-overlay-enter-95-x] [&[data-entering=true][data-placement^=right]]:[animation-name:olis-overlay-enter-95-nx] data-[exiting=true]:pointer-events-none data-[exiting=true]:[animation:olis-overlay-exit_100ms_var(--ease-smooth)] [&[data-exiting=true][data-placement]]:[animation:olis-overlay-exit_100ms_var(--ease-smooth)]"
        data-slot="date-picker-popover"
        data-olis-date-picker-popover
        popover="auto"
        role="dialog"
        tabindex="-1"
        aria-labelledby={"#{@id}-label"}
        phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["style", "data-placement"])}
      >
        <.calendar
          id={"#{@id}-picker-calendar"}
          label={@label}
          value={@value}
          min={@min}
          max={@max}
          today={@today}
          focused_date={@focused_date}
          unavailable_dates={@unavailable_dates}
          locale={@locale}
          week_starts_on={@week_starts_on}
          weeks_in_month={@weeks_in_month}
          year_picker={@year_picker}
          disabled={@disabled}
          read_only={@read_only}
          form={"#{@id}-picker-detached"}
        />
      </div>
    </div>
    """
  end

  @doc "A single-date calendar backed by a native date input."
  attr(:field, Phoenix.HTML.FormField, default: nil)
  attr(:id, :string, default: nil)
  attr(:name, :string, default: nil)
  attr(:value, :any, default: nil)
  attr(:label, :string, required: true)
  attr(:show_label, :boolean, default: false)
  attr(:description, :string, default: nil)
  attr(:errors, :list, default: [])
  attr(:min, :any, default: nil)
  attr(:max, :any, default: nil)
  attr(:focused_date, :any, default: nil)
  attr(:today, :any, default: nil)
  attr(:unavailable_dates, :list, default: [])
  attr(:locale, :string, default: nil)
  attr(:week_starts_on, :integer, default: nil)
  attr(:weeks_in_month, :integer, default: nil)
  attr(:year_picker, :boolean, default: false)
  attr(:disabled, :boolean, default: false)
  attr(:read_only, :boolean, default: false)
  attr(:required, :boolean, default: false)
  attr(:class, :any, default: nil)
  attr(:rest, :global, include: ~w(autocomplete autofocus form))

  def calendar(assigns) do
    field = assigns.field
    id = assigns.id || (field && field.id)
    if is_nil(id), do: raise(ArgumentError, "calendar requires an id or field")
    value = if is_nil(assigns.value) && field, do: field.value, else: assigns.value
    min = calendar_iso(assigns.min)
    max = calendar_iso(assigns.max)
    if min && max && min > max, do: raise(ArgumentError, "calendar min must not exceed max")

    if assigns.week_starts_on && assigns.week_starts_on not in 0..6,
      do: raise(ArgumentError, "calendar week_starts_on must be between 0 and 6")

    if assigns.weeks_in_month && assigns.weeks_in_month not in 4..6,
      do: raise(ArgumentError, "calendar weeks_in_month must be between 4 and 6")

    {external_description, rest} = Map.pop(assigns.rest, :"aria-describedby")
    {external_description_string, rest} = Map.pop(rest, "aria-describedby")

    describedby =
      [
        external_description,
        external_description_string,
        assigns.description && "#{id}-description",
        assigns.errors != [] && "#{id}-errors"
      ]
      |> Enum.filter(& &1)
      |> Enum.join(" ")

    assigns =
      assigns
      |> assign(:id, id)
      |> assign(:name, assigns.name || (field && field.name))
      |> assign(:value, calendar_value(value))
      |> assign(:min, min)
      |> assign(:max, max)
      |> assign(:focused_date, calendar_iso(assigns.focused_date))
      |> assign(:today, calendar_iso(assigns.today))
      |> assign(
        :unavailable_json,
        Jason.encode!(Enum.map(assigns.unavailable_dates, &calendar_iso/1))
      )
      |> assign(:rest, rest)
      |> assign(:describedby, describedby)

    ~H"""
    <div
      id={"#{@id}-calendar-root"}
      class={["olis-calendar-root relative", @class]}
      data-olis-calendar
      data-locale={@locale}
      data-week-start={@week_starts_on}
      data-weeks={@weeks_in_month}
      data-year-picker={to_string(@year_picker)}
      data-focused-date={@focused_date}
      data-today={@today}
      data-unavailable={@unavailable_json}
      data-read-only={to_string(@read_only)}
      phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["data-enhanced"])}
    >
      <label for={@id} class={if @show_label, do: label_classes(), else: "sr-only"}>{@label}</label>
      <input
        id={@id}
        name={@name}
        type="date"
        value={@value}
        min={@min}
        max={@max}
        disabled={@disabled}
        readonly={@read_only}
        required={@required}
        class={[input_classes("primary"), calendar_native_classes()]}
        aria-invalid={if @errors != [], do: "true"}
        aria-describedby={if @describedby != "", do: @describedby}
        data-olis-calendar-native
        phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["aria-hidden", "tabindex"])}
        {@rest}
      />
      <div id={"#{@id}-calendar-enhanced"} data-olis-calendar-ui phx-update="ignore" hidden>
        <div
          class="calendar w-63 max-w-63 [container-type:inline-size] has-[.calendar-year-picker__year-grid]:relative"
          data-olis-calendar-view
          data-slot="calendar"
          role="group"
          aria-label={@label}
        >
        </div>
        <p
          id={"#{@id}-calendar-native-error"}
          class={field_error_classes()}
          data-visible="true"
          data-olis-calendar-error
          hidden
        >
        </p>
      </div>
      <p
        :if={@description}
        id={"#{@id}-description"}
        class="description text-xs text-wrap wrap-break-word text-muted"
      >
        {@description}
      </p>
      <div :if={@errors != []} id={"#{@id}-errors"} class={field_error_classes()} data-visible="true">
        <p :for={error <- @errors}>{error}</p>
      </div>
    </div>
    """
  end

  @doc "A date range calendar backed by two native date inputs."
  attr(:start_field, Phoenix.HTML.FormField, default: nil)
  attr(:end_field, Phoenix.HTML.FormField, default: nil)
  attr(:id, :string, required: true)
  attr(:start_name, :string, default: nil)
  attr(:end_name, :string, default: nil)
  attr(:start_value, :any, default: nil)
  attr(:end_value, :any, default: nil)
  attr(:label, :string, required: true)
  attr(:start_label, :string, default: "Start date")
  attr(:end_label, :string, default: "End date")
  attr(:description, :string, default: nil)
  attr(:errors, :list, default: [])
  attr(:min, :any, default: nil)
  attr(:max, :any, default: nil)
  attr(:focused_date, :any, default: nil)
  attr(:today, :any, default: nil)
  attr(:unavailable_dates, :list, default: [])
  attr(:allows_non_contiguous_ranges, :boolean, default: false)
  attr(:locale, :string, default: nil)
  attr(:week_starts_on, :integer, default: nil)
  attr(:weeks_in_month, :integer, default: nil)
  attr(:year_picker, :boolean, default: false)
  attr(:disabled, :boolean, default: false)
  attr(:read_only, :boolean, default: false)
  attr(:required, :boolean, default: false)
  attr(:class, :any, default: nil)
  attr(:rest, :global, include: ~w(form))

  def range_calendar(assigns) do
    min = calendar_iso(assigns.min)
    max = calendar_iso(assigns.max)
    if min && max && min > max, do: raise(ArgumentError, "range calendar min must not exceed max")

    if assigns.week_starts_on && assigns.week_starts_on not in 0..6,
      do: raise(ArgumentError, "range calendar week_starts_on must be between 0 and 6")

    if assigns.weeks_in_month && assigns.weeks_in_month not in 4..6,
      do: raise(ArgumentError, "range calendar weeks_in_month must be between 4 and 6")

    start_field = assigns.start_field
    end_field = assigns.end_field
    {external_description, rest} = Map.pop(assigns.rest, :"aria-describedby")
    {external_description_string, rest} = Map.pop(rest, "aria-describedby")

    describedby =
      [
        external_description,
        external_description_string,
        assigns.description && "#{assigns.id}-description",
        assigns.errors != [] && "#{assigns.id}-errors"
      ]
      |> Enum.filter(& &1)
      |> Enum.join(" ")

    assigns =
      assigns
      |> assign(:start_id, (start_field && start_field.id) || "#{assigns.id}-start")
      |> assign(:end_id, (end_field && end_field.id) || "#{assigns.id}-end")
      |> assign(:start_name, assigns.start_name || (start_field && start_field.name))
      |> assign(:end_name, assigns.end_name || (end_field && end_field.name))
      |> assign(
        :start_value,
        calendar_value(
          if is_nil(assigns.start_value) && start_field,
            do: start_field.value,
            else: assigns.start_value
        )
      )
      |> assign(
        :end_value,
        calendar_value(
          if is_nil(assigns.end_value) && end_field, do: end_field.value, else: assigns.end_value
        )
      )
      |> assign(:min, min)
      |> assign(:max, max)
      |> assign(:focused_date, calendar_iso(assigns.focused_date))
      |> assign(:today, calendar_iso(assigns.today))
      |> assign(
        :unavailable_json,
        Jason.encode!(Enum.map(assigns.unavailable_dates, &calendar_iso/1))
      )
      |> assign(:describedby, describedby)
      |> assign(:rest, rest)

    ~H"""
    <div
      id={"#{@id}-calendar-root"}
      class={["olis-calendar-root relative", @class]}
      data-olis-calendar
      data-range="true"
      data-label={@label}
      data-locale={@locale}
      data-week-start={@week_starts_on}
      data-weeks={@weeks_in_month}
      data-year-picker={to_string(@year_picker)}
      data-focused-date={@focused_date}
      data-today={@today}
      data-unavailable={@unavailable_json}
      data-allows-non-contiguous-ranges={to_string(@allows_non_contiguous_ranges)}
      phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["data-enhanced"])}
    >
      <div
        class={calendar_native_classes()}
        data-olis-calendar-native-group
        phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["aria-hidden"])}
      >
        <label for={@start_id} class={label_classes()}>{@label}: {@start_label}</label>
        <input
          id={@start_id}
          name={@start_name}
          type="date"
          value={@start_value}
          min={@min}
          max={@max}
          disabled={@disabled}
          readonly={@read_only}
          required={@required}
          class={input_classes("primary")}
          aria-invalid={if @errors != [], do: "true"}
          aria-describedby={if @describedby != "", do: @describedby}
          data-olis-calendar-native
          phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["aria-hidden", "tabindex"])}
          {@rest}
        />
        <label for={@end_id} class={label_classes()}>{@label}: {@end_label}</label>
        <input
          id={@end_id}
          name={@end_name}
          type="date"
          value={@end_value}
          min={@min}
          max={@max}
          disabled={@disabled}
          readonly={@read_only}
          required={@required}
          class={input_classes("primary")}
          aria-invalid={if @errors != [], do: "true"}
          aria-describedby={if @describedby != "", do: @describedby}
          data-olis-calendar-end
          phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["aria-hidden", "tabindex"])}
          {@rest}
        />
      </div>
      <div id={"#{@id}-calendar-enhanced"} data-olis-calendar-ui phx-update="ignore" hidden>
        <div
          class="range-calendar w-63 max-w-63 [container-type:inline-size] has-[.calendar-year-picker__year-grid]:relative"
          data-olis-calendar-view
          data-slot="range-calendar"
          role="group"
          aria-label={@label}
        >
        </div>
        <p
          id={"#{@id}-calendar-native-error"}
          class={field_error_classes()}
          data-visible="true"
          data-olis-calendar-error
          hidden
        >
        </p>
      </div>
      <p
        :if={@description}
        id={"#{@id}-description"}
        class="description text-xs text-wrap wrap-break-word text-muted"
      >
        {@description}
      </p>
      <div :if={@errors != []} id={"#{@id}-errors"} class={field_error_classes()} data-visible="true">
        <p :for={error <- @errors}>{error}</p>
      </div>
    </div>
    """
  end

  defp calendar_iso(nil), do: nil
  defp calendar_iso(""), do: nil

  defp calendar_iso(%Date{year: year, calendar: Calendar.ISO} = date) when year in 1..9999,
    do: Date.to_iso8601(date)

  defp calendar_iso(%Date{}),
    do:
      raise(
        ArgumentError,
        "calendar dates must use the ISO calendar with years between 1 and 9999"
      )

  defp calendar_iso(value) when is_binary(value),
    do: value |> Date.from_iso8601!() |> calendar_iso()

  defp calendar_value(value) when is_binary(value) do
    case Date.from_iso8601(value) do
      {:ok, %Date{year: year} = date} when year in 1..9999 -> Date.to_iso8601(date)
      _ -> nil
    end
  end

  defp calendar_value(value), do: calendar_iso(value)

  @doc "A select with a searchable popover, backed by a native form control."
  attr(:field, Phoenix.HTML.FormField, default: nil)
  attr(:id, :string, default: nil)
  attr(:name, :string, default: nil)
  attr(:value, :any, default: nil)
  attr(:label, :string, required: true)
  attr(:options, :list, required: true)
  attr(:placeholder, :string, default: "Select an item")
  attr(:search_placeholder, :string, default: "Search...")
  attr(:empty_message, :string, default: "No matching options")
  attr(:description, :string, default: nil)
  attr(:errors, :list, default: [])
  attr(:variant, :string, default: "primary", values: ~w(primary secondary))
  attr(:selection_mode, :string, default: "single", values: ~w(single multiple))
  attr(:disabled, :boolean, default: false)
  attr(:required, :boolean, default: false)
  attr(:clearable, :boolean, default: false)
  attr(:allows_empty_collection, :boolean, default: false)
  attr(:full_width, :boolean, default: false)
  attr(:class, :any, default: nil)
  attr(:rest, :global, include: ~w(form))

  def autocomplete(assigns) do
    field = assigns.field
    id = assigns.id || (field && field.id)
    if is_nil(id), do: raise(ArgumentError, "autocomplete requires an id or field")
    value = if is_nil(assigns.value) && field, do: field.value, else: assigns.value

    if assigns.selection_mode == "multiple" && !is_nil(value) && !is_list(value),
      do: raise(ArgumentError, "multiple-selection autocomplete requires a list value")

    name = assigns.name || (field && field.name)

    name =
      if assigns.selection_mode == "multiple" && name && !String.ends_with?(name, "[]"),
        do: name <> "[]",
        else: name

    {external_description, rest} = Map.pop(assigns.rest, :"aria-describedby")
    {external_description_string, rest} = Map.pop(rest, "aria-describedby")

    describedby =
      [
        external_description,
        external_description_string,
        assigns.description && assigns.errors == [] && "#{id}-description",
        assigns.errors != [] && "#{id}-errors"
      ]
      |> Enum.filter(& &1)
      |> Enum.join(" ")

    assigns =
      assigns
      |> assign(:id, id)
      |> assign(:name, name)
      |> assign(:value, value)
      |> assign(:rest, rest)
      |> assign(:describedby, describedby)

    ~H"""
    <div
      id={"#{@id}-autocomplete"}
      class={[
        "autocomplete flex flex-col gap-1",
        "autocomplete--#{@variant}",
        @full_width && "autocomplete--full-width w-full",
        @class
      ]}
      data-slot="autocomplete"
      data-olis-autocomplete
      x-data="olisAutocomplete"
      x-on:input="input($event)"
      x-on:change="change($event)"
      x-on:keydown="keydown($event)"
      x-on:pointerdown="pointerdown($event)"
      x-on:click="click($event)"
      x-on:focusout="focusout($event)"
      x-on:toggle.capture="toggle($event)"
      x-on:invalid.capture="invalid($event)"
      x-on:reset.document="reset($event)"
      x-on:phx:update.document="update()"
      x-on:resize.window="reposition()"
      x-on:scroll.window.capture="reposition()"
      data-variant={@variant}
      data-full-width={to_string(@full_width)}
      data-placeholder={@placeholder}
      data-search-placeholder={@search_placeholder}
      data-empty-message={@empty_message}
      data-clearable={to_string(@clearable)}
      data-allows-empty={to_string(@allows_empty_collection)}
      data-invalid={if @errors != [], do: "true"}
      phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["data-enhanced"])}
    >
      <label id={"#{@id}-label"} class={label_classes()} data-slot="label" for={@id}>{@label}</label>
      <select
        id={@id}
        name={@name}
        class={[
          select_trigger_classes(),
          "aria-hidden:pointer-events-none aria-hidden:absolute aria-hidden:size-px aria-hidden:opacity-0",
          @full_width && "w-full"
        ]}
        multiple={@selection_mode == "multiple"}
        disabled={@disabled}
        required={@required}
        aria-invalid={if @errors != [], do: "true"}
        aria-describedby={if @describedby != "", do: @describedby}
        data-olis-autocomplete-native
        phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["aria-hidden", "tabindex"])}
        {@rest}
      >
        <option :if={@selection_mode == "single"} value="">{@placeholder}</option>
        {Phoenix.HTML.Form.options_for_select(@options, @value)}
      </select>
      <span :if={@required} id={"#{@id}-required-hint"} class="sr-only">Required</span>
      <div id={"#{@id}-enhanced"} data-olis-autocomplete-ui phx-update="ignore" hidden>
        <div
          class={[
            autocomplete_trigger_classes(),
            @full_width && "autocomplete__trigger--full-width w-full"
          ]}
          data-slot="autocomplete-trigger"
          data-olis-autocomplete-group
          role="group"
        >
          <span
            id={"#{@id}-value"}
            class="autocomplete__value pointer-events-none flex-1 text-start text-base wrap-break-word text-current sm:text-sm data-[placeholder=true]:text-field-placeholder [&_[data-slot=list-box-item-indicator]]:hidden"
            data-slot="autocomplete-value"
            data-olis-autocomplete-value
            data-placeholder="true"
          >{@placeholder}</span>
          <button
            type="button"
            class="autocomplete__clear-button relative isolate z-10 me-0 inline-flex size-5 shrink-0 origin-center transform-gpu items-center justify-center self-center rounded-xl bg-transparent p-1 text-muted select-none no-highlight cursor-(--cursor-interactive) [&:not([data-empty=true])]:transition-opacity [&:not([data-empty=true])]:duration-150 [&:not([data-empty=true])]:ease-(--ease-smooth) data-[empty=true]:pointer-events-none data-[empty=true]:opacity-0 [&_[data-slot=autocomplete-clear-button-icon]]:size-3.5 hover:bg-default-hover [@media(hover:hover)]:data-[hovered=true]:bg-default-hover active:[transform:scale(.93)] data-[pressed=true]:[transform:scale(.93)] [&[hidden]]:hidden!"
            data-slot="autocomplete-clear-button"
            data-olis-autocomplete-clear
            data-empty="true"
            aria-label={"Clear #{@label}"}
            hidden={!@clearable}
          >
            <svg
              data-slot="autocomplete-clear-button-icon"
              aria-hidden="true"
              viewBox="0 0 16 16"
              fill="none"
            ><path
              d="M4 4l8 8M12 4l-8 8"
              stroke="currentColor"
              stroke-width="1.5"
              stroke-linecap="round"
            /></svg>
          </button>
          <button
            type="button"
            class="absolute inset-0 rounded-[inherit]"
            data-olis-autocomplete-trigger
            aria-labelledby={"#{@id}-label #{@id}-value"}
            aria-haspopup="listbox"
            aria-expanded="false"
            aria-controls={"#{@id}-listbox"}
          >
            <svg
              class="autocomplete__indicator absolute inset-y-0 end-2 my-auto flex shrink-0 cursor-(--cursor-interactive) items-center justify-center text-field-placeholder transition duration-150 data-[open=true]:rotate-180 data-[slot=autocomplete-default-indicator]:size-4"
              data-slot="autocomplete-default-indicator"
              aria-hidden="true"
              viewBox="0 0 16 16"
              fill="none"
            ><path
              d="M2.97 5.47a.75.75 0 0 1 1.06 0L8 9.44l3.97-3.97a.75.75 0 1 1 1.06 1.06l-4.5 4.5a.75.75 0 0 1-1.06 0l-4.5-4.5a.75.75 0 0 1 0-1.06"
              fill="currentColor"
              fill-rule="evenodd"
              clip-rule="evenodd"
            /></svg>
          </button>
        </div>
        <div
          id={"#{@id}-popup"}
          class="autocomplete__popover fixed m-0 flex max-h-[calc(100dvh-1rem)] w-(--trigger-width) max-w-[calc(100vw-1rem)] origin-(--trigger-anchor-point) scroll-py-1 flex-col overflow-hidden overscroll-contain rounded-[12px] border-0 bg-overlay p-0 pt-2 text-sm outline-none [box-shadow:var(--overlay-shadow)] [inset:auto] [&:not(:popover-open)]:hidden data-[entering=true]:[animation:olis-overlay-enter-95_250ms_var(--ease-out-fluid)] [&[data-entering=true][data-placement=top]]:[animation-name:olis-overlay-enter-95-y] [&[data-entering=true][data-placement=bottom]]:[animation-name:olis-overlay-enter-95-ny] [&[data-entering=true][data-placement=left]]:[animation-name:olis-overlay-enter-95-x] [&[data-entering=true][data-placement=right]]:[animation-name:olis-overlay-enter-95-nx] data-[exiting=true]:pointer-events-none data-[exiting=true]:[animation:olis-overlay-exit_100ms_var(--ease-out-quad)] [&[data-exiting=true][data-placement]]:[animation:olis-overlay-exit_100ms_var(--ease-out-quad)] [&_[data-slot=popover-overlay-arrow]]:fill-overlay [&[data-placement=bottom]_[data-slot=popover-overlay-arrow]]:rotate-180 [&[data-placement=left]_[data-slot=popover-overlay-arrow]]:-rotate-90 [&[data-placement=right]_[data-slot=popover-overlay-arrow]]:rotate-90 [&_[data-slot=list-box]]:max-h-[320px] [&_[data-slot=list-box]]:min-h-0 [&_[data-slot=list-box]]:scrollbar [&_[data-slot=list-box]]:overflow-y-auto [&_[data-slot=list-box]]:p-1.5 [&_[data-slot=list-box]]:outline-none [&_[data-slot=list-box-item]]:px-2.5 [&_[data-slot=list-box-item]:has(.list-box-item__indicator)]:pe-7 [&_[role=presentation]>[data-slot=list-box-item]]:w-[calc(100%-var(--spacing)*3)] [&_[data-slot=list-box]:not([aria-multiselectable=true])_[data-slot=list-box-item-indicator]]:transition-none [&_[data-slot=list-box]:not([aria-multiselectable=true])_[data-slot=list-box-item-indicator--checkmark]]:transition-none [&_[data-slot=search-field]]:shrink-0 [&_[data-slot=search-field]]:px-3 [&_[data-slot=search-field]]:py-1 [&_[data-slot=search-field]]:outline-none [&_[data-slot=empty-state]]:text-center [&_[data-slot=empty-state]]:text-sm [&_[data-slot=empty-state]]:text-overlay-foreground/60"
          data-slot="autocomplete-popover"
          data-olis-autocomplete-popup
          popover="auto"
          role="dialog"
          aria-labelledby={"#{@id}-label"}
          tabindex="-1"
        >
          <div class="autocomplete__filter flex min-h-0 flex-col" data-slot="autocomplete-filter">
            <div
              class={[search_field_classes(), "search-field--secondary"]}
              data-slot="search-field"
              data-olis-autocomplete-search-field
              data-empty="true"
            >
              <div class={search_group_classes()} data-slot="search-field-group">
                <svg
                  class="search-field__search-icon pointer-events-none shrink-0 text-field-placeholder ms-3 me-0 size-4"
                  data-slot="search-field-search-icon"
                  aria-hidden="true"
                  viewBox="0 0 16 16"
                  fill="none"
                ><circle cx="7" cy="7" r="4.5" stroke="currentColor" stroke-width="1.5" /><path
                  d="m10.5 10.5 3 3"
                  stroke="currentColor"
                  stroke-width="1.5"
                  stroke-linecap="round"
                /></svg>
                <input
                  type="search"
                  class={search_input_classes()}
                  data-slot="search-field-input"
                  data-olis-autocomplete-search
                  placeholder={@search_placeholder}
                  aria-label={"Search #{@label}"}
                  role="combobox"
                  aria-autocomplete="list"
                  aria-expanded="false"
                  aria-controls={"#{@id}-listbox"}
                  autocomplete="off"
                />
                <button
                  type="button"
                  class={[close_button_classes(), search_clear_classes()]}
                  data-slot="search-field-clear-button"
                  data-olis-autocomplete-search-clear
                  slot="clear"
                  aria-label="Clear search"
                  tabindex="-1"
                >
                  <svg
                    data-slot="close-button-icon"
                    aria-hidden="true"
                    viewBox="0 0 16 16"
                    fill="none"
                  ><path
                    d="M4 4l8 8M12 4l-8 8"
                    stroke="currentColor"
                    stroke-width="1.5"
                    stroke-linecap="round"
                  /></svg>
                </button>
              </div>
            </div>
            <div
              id={"#{@id}-listbox"}
              class="list-box relative w-full overflow-clip p-1 [&>*+*]:mt-1 [&_[data-slot=separator][data-orientation=horizontal]]:ms-[3%] [&_[data-slot=separator][data-orientation=horizontal]]:w-[94%]"
              role="listbox"
              data-slot="list-box"
              data-olis-autocomplete-list
              aria-labelledby={"#{@id}-label"}
              aria-multiselectable={if @selection_mode == "multiple", do: "true"}
            >
            </div>
            <div
              class="empty-state p-2 text-sm text-muted"
              data-slot="empty-state"
              data-olis-autocomplete-empty
              role="status"
              hidden
            >
              {@empty_message}
            </div>
          </div>
        </div>
        <p
          id={"#{@id}-native-error"}
          class={field_error_classes()}
          data-visible="true"
          data-olis-autocomplete-error
          hidden
        >
        </p>
      </div>
      <p
        :if={@description}
        id={"#{@id}-description"}
        class="description text-xs text-wrap wrap-break-word text-muted"
        data-slot="description"
      >
        {@description}
      </p>
      <div :if={@errors != []} id={"#{@id}-errors"} class={field_error_classes()} data-visible="true">
        <p :for={error <- @errors}>{error}</p>
      </div>
    </div>
    """
  end

  @doc "A searchable combo box backed by a native form control."
  attr(:field, Phoenix.HTML.FormField, default: nil)
  attr(:id, :string, default: nil)
  attr(:name, :string, default: nil)
  attr(:value, :any, default: nil)
  attr(:label, :string, required: true)
  attr(:options, :list, required: true)
  attr(:placeholder, :string, default: "Select an option...")
  attr(:description, :string, default: nil)
  attr(:errors, :list, default: [])
  attr(:variant, :string, default: "primary", values: ~w(primary secondary))
  attr(:disabled, :boolean, default: false)
  attr(:required, :boolean, default: false)
  attr(:allows_custom_value, :boolean, default: false)
  attr(:selection_mode, :string, default: "single", values: ~w(single multiple))
  attr(:selected_placeholder, :string, default: nil)
  attr(:full_width, :boolean, default: false)
  attr(:class, :any, default: nil)
  attr(:rest, :global, include: ~w(form))

  def combo_box(assigns) do
    field = assigns.field
    id = assigns.id || (field && field.id)
    if is_nil(id), do: raise(ArgumentError, "combo_box requires an id or field")
    value = if is_nil(assigns.value) && field, do: field.value, else: assigns.value

    if assigns.selection_mode == "multiple" && assigns.allows_custom_value,
      do:
        raise(
          ArgumentError,
          "combo_box does not yet support custom values with multiple selection"
        )

    if assigns.selection_mode == "multiple" && !is_nil(value) && !is_list(value),
      do: raise(ArgumentError, "multiple-selection combo_box requires a list value")

    name = assigns.name || (field && field.name)

    name =
      if assigns.selection_mode == "multiple" && name && !String.ends_with?(name, "[]"),
        do: name <> "[]",
        else: name

    {external_description, rest} = Map.pop(assigns.rest, :"aria-describedby")
    {external_description_string, rest} = Map.pop(rest, "aria-describedby")

    describedby =
      [
        external_description,
        external_description_string,
        assigns.description && assigns.errors == [] && "#{id}-description",
        assigns.errors != [] && "#{id}-errors"
      ]
      |> Enum.filter(& &1)
      |> Enum.join(" ")

    assigns =
      assigns
      |> assign(:id, id)
      |> assign(:name, name)
      |> assign(:value, value)
      |> assign(:rest, rest)
      |> assign(:describedby, describedby)
      |> assign(
        :custom_labels,
        if(assigns.allows_custom_value, do: combo_option_labels(assigns.options), else: [])
      )

    ~H"""
    <div
      id={"#{@id}-combo"}
      class={[
        "combo-box relative flex flex-col gap-1 [&:is([data-invalid=true],[aria-invalid=true])_[data-slot=description]]:hidden [&_[data-slot=label]]:w-fit",
        @full_width && "combo-box--full-width w-full",
        @class
      ]}
      data-olis-combo
      x-data="olisComboBox"
      x-on:input="input($event)"
      x-on:change="change($event)"
      x-on:keydown="keydown($event)"
      x-on:click="click($event)"
      x-on:pointerdown="pointerdown($event)"
      x-on:focusin="focusin($event)"
      x-on:focusout="focusout($event)"
      x-on:toggle.capture="toggle($event)"
      x-on:invalid.capture="invalid($event)"
      x-on:reset.window="reset($event)"
      x-on:phx:update.window="sync()"
      x-on:resize.window="position()"
      x-on:scroll.window.capture="position()"
      data-custom={to_string(@allows_custom_value)}
      data-selection-mode={@selection_mode}
      data-selected-order={if @selection_mode == "multiple", do: Jason.encode!(@value || [])}
      data-variant={@variant}
      data-full-width={to_string(@full_width)}
      data-placeholder={@placeholder}
      data-selected-placeholder={@selected_placeholder}
      data-invalid={if @errors != [], do: "true"}
      phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["data-enhanced"])}
    >
      <label id={"#{@id}-label"} class={label_classes()} data-slot="label" for={@id}>{@label}</label>
      <select
        id={if @allows_custom_value, do: "#{@id}-source", else: @id}
        name={if !@allows_custom_value, do: @name}
        class={[
          select_trigger_classes(),
          "olis-combo-native w-full [&[hidden]]:hidden! [.combo-box[data-enhanced=true]_&]:pointer-events-none [.combo-box[data-enhanced=true]_&]:absolute [.combo-box[data-enhanced=true]_&]:inset-0 [.combo-box[data-enhanced=true]_&]:opacity-0"
        ]}
        disabled={@disabled}
        required={@required && !@allows_custom_value}
        multiple={@selection_mode == "multiple"}
        hidden={@allows_custom_value}
        aria-invalid={if @errors != [], do: "true"}
        aria-describedby={if @describedby != "", do: @describedby}
        data-olis-combo-native
        phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["aria-hidden", "tabindex"])}
        {if @allows_custom_value, do: %{}, else: @rest}
      >
        <option :if={@selection_mode == "single"} value="">{@placeholder}</option>
        {Phoenix.HTML.Form.options_for_select(@options, @value)}
      </select>
      <datalist :if={@allows_custom_value} id={"#{@id}-suggestions"}>
        <option :for={label <- @custom_labels} value={label}></option>
      </datalist>
      <div
        id={"#{@id}-enhanced"}
        data-olis-combo-ui
        phx-update={if !@allows_custom_value, do: "ignore"}
        hidden={!@allows_custom_value}
      >
        <div class={[
          "combo-box__input-group relative isolate inline-flex items-center",
          @full_width && "combo-box__input-group--full-width w-full"
        ]}>
          <input
            id={if @allows_custom_value, do: @id, else: "#{@id}-input"}
            name={if @allows_custom_value, do: @name}
            value={if @allows_custom_value, do: @value}
            disabled={@disabled && @allows_custom_value}
            required={@required && @allows_custom_value}
            list={if @allows_custom_value, do: "#{@id}-suggestions"}
            class={[
              input_classes(@variant),
              "min-w-0 flex-1 has-[+.combo-box__trigger]:pe-7 data-[focus]:status-focused-field data-[focus]:border-field-border-focus data-[focus]:[--input-bg:var(--input-bg-focus)] data-[disabled]:status-disabled",
              @full_width && "input--full-width w-full"
            ]}
            data-slot="input"
            data-olis-combo-input
            type="text"
            role={if !@allows_custom_value, do: "combobox"}
            aria-labelledby={"#{@id}-label"}
            aria-autocomplete={if !@allows_custom_value, do: "list"}
            aria-expanded={if !@allows_custom_value, do: "false"}
            aria-controls={if !@allows_custom_value, do: "#{@id}-listbox"}
            aria-invalid={if @allows_custom_value && @errors != [], do: "true"}
            aria-describedby={if @allows_custom_value && @describedby != "", do: @describedby}
            autocomplete="off"
            autocorrect="off"
            spellcheck="false"
            placeholder={@placeholder}
            phx-mounted={
              if @allows_custom_value,
                do:
                  Phoenix.LiveView.JS.ignore_attributes([
                    "role",
                    "list",
                    "aria-controls",
                    "aria-autocomplete",
                    "aria-expanded",
                    "aria-activedescendant"
                  ])
            }
            {if @allows_custom_value, do: @rest, else: %{}}
          />
          <button
            type="button"
            class="combo-box__trigger absolute end-0 top-1/2 flex h-full shrink-0 -translate-y-1/2 cursor-pointer items-center justify-center border-none bg-transparent pe-2 text-field-placeholder outline-none transition duration-150 no-highlight hover:text-field-foreground [@media(hover:hover)]:data-[hovered=true]:text-field-foreground [&:focus-visible:not([data-focused])]:rounded [&:focus-visible:not([data-focused])]:ring-2 [&:focus-visible:not([data-focused])]:ring-focus [&:focus-visible:not([data-focused])]:ring-offset-2 [&:focus-visible:not([data-focused])]:ring-offset-background data-[focus-visible=true]:rounded data-[focus-visible=true]:ring-2 data-[focus-visible=true]:ring-focus data-[focus-visible=true]:ring-offset-2 data-[focus-visible=true]:ring-offset-background data-[pressed=true]:opacity-70 disabled:cursor-not-allowed disabled:opacity-50 data-[disabled]:cursor-not-allowed data-[disabled]:opacity-50 aria-disabled:cursor-not-allowed aria-disabled:opacity-50 [&[hidden]]:hidden! [&_[data-slot=combo-box-trigger-default-icon]]:size-4 [&_[data-slot=combo-box-trigger-default-icon]]:transition-transform [&_[data-slot=combo-box-trigger-default-icon]]:duration-150 [&[data-open=true]_[data-slot=combo-box-trigger-default-icon]]:rotate-180"
            data-olis-combo-trigger
            aria-label={"Show #{@label} options"}
            aria-haspopup="listbox"
            aria-expanded="false"
            tabindex="-1"
            hidden={@allows_custom_value}
            phx-mounted={
              if @allows_custom_value,
                do: Phoenix.LiveView.JS.ignore_attributes(["hidden", "aria-expanded", "data-open"])
            }
          ><svg
            data-slot="combo-box-trigger-default-icon"
            aria-hidden="true"
            viewBox="0 0 16 16"
            fill="none"
          ><path
            d="M2.97 5.47a.75.75 0 0 1 1.06 0L8 9.44l3.97-3.97a.75.75 0 1 1 1.06 1.06l-4.5 4.5a.75.75 0 0 1-1.06 0l-4.5-4.5a.75.75 0 0 1 0-1.06"
            fill="currentColor"
            fill-rule="evenodd"
            clip-rule="evenodd"
          /></svg></button>
        </div>
        <div
          :if={@selection_mode == "multiple"}
          id={"#{@id}-value"}
          class="combo-box__value text-sm wrap-break-word text-field-foreground empty:hidden data-[placeholder=true]:text-field-placeholder [&_[data-slot=list-box-item-indicator]]:hidden"
          data-slot="combo-box-value"
          data-olis-combo-value
          data-placeholder="true"
        >
          {@selected_placeholder}
        </div>
        <div
          id={"#{@id}-popup"}
          class={[
            overlay95_motion_classes(),
            "combo-box__popover olis-combo-popup min-w-(--trigger-width) rounded-[12px] bg-overlay p-0 text-sm [&:focus-visible:not([data-focused])]:outline-none data-[focus-visible=true]:outline-none [&_[data-slot=list-box]]:p-1.5 [&_[data-slot=list-box]]:outline-none [&_[data-slot=list-box-item]]:px-2.5 [&_[data-slot=list-box-item]:has(.list-box-item__indicator)]:pe-7 [&_[data-slot=popover-overlay-arrow]]:fill-overlay [&[data-placement=bottom]_[data-slot=popover-overlay-arrow]]:rotate-180 [&[data-placement=left]_[data-slot=popover-overlay-arrow]]:-rotate-90 [&[data-placement=right]_[data-slot=popover-overlay-arrow]]:rotate-90 fixed inset-auto m-0 flex max-h-[min(20rem,calc(100dvh-1rem))] max-w-[calc(100vw-1rem)] flex-col overflow-hidden border-0 [&:not(:popover-open)]:hidden [&_[data-slot=list-box]]:min-h-0 [&_[data-slot=list-box]]:scroll-py-1 [&_[data-slot=list-box]]:scrollbar [&_[data-slot=list-box]]:overflow-y-auto [&_[data-slot=list-box]]:overscroll-contain [&_[data-slot=list-box-item-indicator--checkmark]]:transition-none [&_[role=option][data-active=true]]:bg-default [&_[role=option][aria-disabled=true]]:cursor-not-allowed [&_[role=option][aria-disabled=true]]:opacity-50"
          ]}
          data-olis-combo-popup
          popover="auto"
          phx-update={if @allows_custom_value, do: "ignore"}
        >
          <div
            id={"#{@id}-listbox"}
            role="listbox"
            aria-multiselectable={if @selection_mode == "multiple", do: "true"}
            aria-labelledby={"#{@id}-label"}
            class="list-box relative w-full overflow-clip p-1 [&>*+*]:mt-1 [&_[data-slot=separator][data-orientation=horizontal]]:ms-[3%] [&_[data-slot=separator][data-orientation=horizontal]]:w-[94%]"
            data-slot="list-box"
            data-olis-combo-list
          >
          </div>
          <div class="olis-combo-empty p-3 text-muted" data-olis-combo-empty role="status" hidden>
            No matching options
          </div>
        </div>
        <p
          id={"#{@id}-native-error"}
          class={field_error_classes()}
          data-visible="true"
          data-olis-combo-error
          hidden
        >
        </p>
      </div>
      <p
        :if={@description}
        id={"#{@id}-description"}
        class="description text-xs text-wrap wrap-break-word text-muted"
        data-slot="description"
      >
        {@description}
      </p>
      <div :if={@errors != []} id={"#{@id}-errors"} class={field_error_classes()} data-visible="true">
        <p :for={error <- @errors}>{error}</p>
      </div>
    </div>
    """
  end

  defp combo_option_labels(options) do
    Enum.flat_map(options, fn
      :hr ->
        []

      {:hr, nil} ->
        []

      {_label, children} when is_list(children) ->
        combo_option_labels(children)

      {_label, children} when is_map(children) and not is_struct(children) ->
        combo_option_labels(children)

      option when is_list(option) ->
        if Keyword.get(option, :disabled), do: [], else: [Keyword.fetch!(option, :key)]

      {label, _value} ->
        [label]

      label ->
        [label]
    end)
  end

  @doc """
  A native single or multiple select with OlisUI field styling.

  Options use the same formats as `Phoenix.HTML.Form.options_for_select/2`.
  The browser provides the options popup and keyboard interaction.
  """
  attr(:id, :string, required: true)
  attr(:name, :string, default: nil)
  attr(:value, :any, default: nil)
  attr(:options, :list, required: true)
  attr(:prompt, :string, default: nil)
  attr(:variant, :string, default: "primary", values: ~w(primary secondary))
  attr(:invalid, :boolean, default: false)
  attr(:class, :any, default: nil)
  attr(:rest, :global, include: ~w(autocomplete autofocus disabled form multiple required size))

  def select(assigns) do
    ~H"""
    <div
      class={[
        "select select--#{@variant} olis-native-select flex flex-col gap-1 [&.select--full-width]:w-full [&:is([data-invalid=true],[aria-invalid=true])_[data-slot=description]]:hidden [&_[data-slot=label]]:w-fit",
        @class
      ]}
      data-invalid={if @invalid, do: "true"}
      data-olis-select-root
      x-data="olisSelect"
      x-on:click.window="click($event)"
      x-on:keydown="keydown($event)"
      x-on:toggle.capture="toggle($event)"
      x-on:invalid.capture="invalid($event)"
      x-on:change="change($event)"
      x-on:reset.window="reset($event)"
      x-on:resize.window="position()"
      x-on:scroll.window.capture="position()"
      x-on:phx:update.window="sync()"
      phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["data-enhanced"])}
    >
      <div class="olis-native-select-field relative w-full">
        <select
          id={@id}
          name={@name}
          class={[
            select_trigger_classes(),
            "olis-native-select-input block! w-full appearance-none pe-7 [font-family:inherit] [font-style:inherit] [font-weight:inherit] text-sm leading-5 has-[option[value='']:checked]:text-field-placeholder [&[multiple]]:appearance-auto [&[multiple]]:pe-3 [&[size]:not([size='1'])]:appearance-auto [&[size]:not([size='1'])]:pe-3 [.olis-native-select[data-enhanced=true]_&]:pointer-events-none [.olis-native-select[data-enhanced=true]_&]:absolute [.olis-native-select[data-enhanced=true]_&]:inset-0 [.olis-native-select[data-enhanced=true]_&]:opacity-0"
          ]}
          aria-invalid={if @invalid, do: "true"}
          data-olis-native-select
          phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["aria-hidden", "tabindex"])}
          {@rest}
        >
          <option :if={@prompt} value="">{@prompt}</option>
          {Phoenix.HTML.Form.options_for_select(@options, @value)}
        </select>
        <svg
          class={[
            select_indicator_classes(),
            "olis-native-select-indicator size-4 pointer-events-none [.olis-native-select[data-enhanced=true]_&]:hidden [.olis-native-select-field:has(select[multiple])>&]:hidden [.olis-native-select-field:has(select[size]:not([size='1']))>&]:hidden"
          ]}
          aria-hidden="true"
          viewBox="0 0 16 16"
          fill="none"
        ><path
          d="m4 6 4 4 4-4"
          stroke="currentColor"
          stroke-width="1.5"
          stroke-linecap="round"
          stroke-linejoin="round"
        /></svg>
        <div id={"#{@id}-enhanced"} data-olis-select-ui phx-update="ignore" hidden>
          <button
            id={"#{@id}-trigger"}
            type="button"
            class={[select_trigger_classes(), "olis-enhanced-select-trigger w-full items-center pe-7"]}
            role="combobox"
            aria-haspopup="listbox"
            aria-expanded="false"
            aria-controls={"#{@id}-listbox"}
            popovertarget={"#{@id}-popup"}
            data-olis-select-trigger
          >
            <span
              class="select__value flex-1 text-start text-base wrap-break-word text-current sm:text-sm data-[placeholder=true]:text-field-placeholder [&_[data-slot=list-box-item-indicator]]:hidden"
              data-olis-select-value
            ></span><svg
              class={[select_indicator_classes(), "size-4"]}
              aria-hidden="true"
              viewBox="0 0 16 16"
              fill="none"
            ><path
              d="m4 6 4 4 4-4"
              stroke="currentColor"
              stroke-width="1.5"
              stroke-linecap="round"
              stroke-linejoin="round"
            /></svg>
          </button>
          <div
            id={"#{@id}-popup"}
            popover="auto"
            class={[
              select_popover_classes(),
              "olis-enhanced-select-popup fixed inset-auto m-0 max-h-[min(20rem,calc(100dvh-1rem))] max-w-[calc(100vw-1rem)] border-0 [&_[role=option][data-active=true]]:bg-default [&_[role=option][aria-disabled=true]]:cursor-not-allowed [&_[role=option][aria-disabled=true]]:opacity-50"
            ]}
            data-olis-select-popup
          >
            <div
              id={"#{@id}-listbox"}
              role="listbox"
              aria-labelledby={"#{@id}-trigger"}
              class="list-box relative w-full overflow-clip p-1 [&>*+*]:mt-1 [&_[data-slot=separator][data-orientation=horizontal]]:ms-[3%] [&_[data-slot=separator][data-orientation=horizontal]]:w-[94%]"
              data-olis-select-list
            >
            </div>
          </div>
          <span
            id={"#{@id}-validation"}
            class={field_error_classes()}
            data-visible="true"
            role="alert"
            data-olis-select-error
            hidden
          ></span>
        </div>
      </div>
    </div>
    """
  end

  @doc "An accordion group, or a single native disclosure when given a title and body."
  attr(:id, :string, default: nil)
  attr(:title, :string, default: nil)
  attr(:open, :boolean, default: false)
  attr(:name, :string, default: nil)
  attr(:expanded_keys, :list, default: nil)
  attr(:default_expanded_keys, :list, default: [])
  attr(:allows_multiple_expanded, :boolean, default: false)
  attr(:disabled, :boolean, default: false)
  attr(:variant, :string, default: "default", values: ~w(default surface))
  attr(:hide_separator, :boolean, default: false)
  attr(:heading_level, :integer, default: 3, values: 2..6)
  attr(:on_expanded_change, :string, default: nil)
  attr(:target, :any, default: nil)
  attr(:class, :any, default: nil)
  slot(:inner_block)
  slot(:indicator)

  slot :item do
    attr(:key, :string, required: true)
    attr(:title, :string, required: true)
    attr(:disabled, :boolean)
    attr(:class, :any)
  end

  def accordion(assigns) do
    grouped = assigns.item != []

    if grouped && (is_nil(assigns.id) || assigns.id == ""),
      do: raise(ArgumentError, "accordion groups require an id")

    if grouped && assigns.title,
      do: raise(ArgumentError, "accordion accepts either item slots or a single title and body")

    if !grouped && (is_nil(assigns.title) || assigns.title == ""),
      do: raise(ArgumentError, "accordion requires item slots or a title")

    keys = Enum.map(assigns.item, & &1.key)

    if Enum.any?(keys, &(not is_binary(&1) or &1 == "")) or
         length(keys) != length(Enum.uniq(keys)),
       do: raise(ArgumentError, "accordion item keys must be unique nonempty strings")

    expanded = assigns.expanded_keys || assigns.default_expanded_keys

    if !is_list(expanded) or Enum.any?(expanded, &(&1 not in keys)) or
         length(expanded) != length(Enum.uniq(expanded)),
       do: raise(ArgumentError, "accordion expanded keys must be distinct item keys")

    if !assigns.allows_multiple_expanded && length(expanded) > 1,
      do: raise(ArgumentError, "single accordion groups allow at most one expanded key")

    assigns =
      assign(assigns,
        grouped: grouped,
        expanded: expanded,
        expanded_set: MapSet.new(expanded),
        controlled: !is_nil(assigns.expanded_keys)
      )

    ~H"""
    <details
      :if={!@grouped}
      id={@id}
      class={[
        "accordion w-full [contain:layout_style]",
        "accordion__item relative border-none after:absolute after:start-0 after:bottom-0 after:h-px after:w-full after:rounded-xs after:bg-separator after:content-[''] last:after:content-none data-[hide-separator=true]:after:hidden",
        "olis-native-accordion",
        @variant == "surface" &&
          "accordion--surface rounded-[12px] bg-surface [&_.accordion__item]:after:start-[3%] [&_.accordion__item]:after:w-[94%] [&_.accordion__item]:after:bg-surface-foreground/6 [&_.accordion__item:first-child_[data-slot=accordion-trigger]]:[border-start-start-radius:12px] [&_.accordion__item:first-child_[data-slot=accordion-trigger]]:[border-start-end-radius:12px] [&_.accordion__item:last-child:not(:has([data-slot=accordion-trigger][aria-expanded=true]))_[data-slot=accordion-trigger]]:[border-end-start-radius:12px] [&_.accordion__item:last-child:not(:has([data-slot=accordion-trigger][aria-expanded=true]))_[data-slot=accordion-trigger]]:[border-end-end-radius:12px]",
        @class
      ]}
      open={@open}
      name={@name}
      x-data={if @disabled, do: "{}"}
    >
      <summary
        class={[
          "accordion__trigger list-none [&::-webkit-details-marker]:hidden flex flex-1 items-center justify-between px-4 py-4 text-start text-sm font-medium no-highlight cursor-(--cursor-interactive) [transition:opacity_150ms_var(--ease-out),box-shadow_150ms_var(--ease-out)] [&:focus-visible:not([data-focused])]:status-focused data-[focus-visible=true]:status-focused disabled:status-disabled aria-disabled:status-disabled [@media(hover:hover)]:[&:hover:not([aria-expanded=true])]:bg-[color-mix(in_oklab,var(--foreground)_3%,transparent_90%)] [@media(hover:hover)]:[.accordion--surface_&:hover:not([aria-expanded=true])]:bg-default",
          @disabled && "pointer-events-none cursor-not-allowed opacity-50"
        ]}
        aria-disabled={if @disabled, do: "true"}
        tabindex={if @disabled, do: "-1"}
        x-on:click.prevent={if @disabled, do: ""}
      >
        {@title}<svg
          class="accordion__indicator ms-auto size-4 shrink-0 text-muted transition duration-250 data-[expanded=true]:-rotate-180 [.olis-native-accordion[open]_&]:-rotate-180"
          aria-hidden="true"
          viewBox="0 0 16 16"
          fill="none"
        ><path
          d="m4 6 4 4 4-4"
          stroke="currentColor"
          stroke-width="1.5"
          stroke-linecap="round"
          stroke-linejoin="round"
        /></svg>
      </summary>
      <div class="accordion__body text-sm">
        <div class="accordion__body-inner px-4 pt-0 pb-4 text-muted">{render_slot(@inner_block)}</div>
      </div>
    </details>
    <div
      :if={@grouped}
      id={@id}
      class={[
        "accordion w-full [contain:layout_style]",
        @variant == "surface" &&
          "accordion--surface rounded-[12px] bg-surface [&_.accordion__item]:after:start-[3%] [&_.accordion__item]:after:w-[94%] [&_.accordion__item]:after:bg-surface-foreground/6 [&_.accordion__item:first-child_[data-slot=accordion-trigger]]:[border-start-start-radius:12px] [&_.accordion__item:first-child_[data-slot=accordion-trigger]]:[border-start-end-radius:12px] [&_.accordion__item:last-child:not(:has([data-slot=accordion-trigger][aria-expanded=true]))_[data-slot=accordion-trigger]]:[border-end-start-radius:12px] [&_.accordion__item:last-child:not(:has([data-slot=accordion-trigger][aria-expanded=true]))_[data-slot=accordion-trigger]]:[border-end-end-radius:12px]",
        @class
      ]}
      data-slot="accordion"
      data-olis-accordion
      data-controlled={to_string(@controlled)}
      data-multiple={to_string(@allows_multiple_expanded)}
      data-initial-expanded={Jason.encode!(@expanded)}
      data-expanded-keys={Jason.encode!(@expanded)}
      data-disabled={if @disabled, do: "true"}
      x-data="olisAccordion"
      x-on:phx:update.window="sync()"
      x-on:keydown="keydown($event)"
    >
      <div
        :for={item <- @item}
        class={[
          "accordion__item relative border-none after:absolute after:start-0 after:bottom-0 after:h-px after:w-full after:rounded-xs after:bg-separator after:content-[''] last:after:content-none data-[hide-separator=true]:after:hidden",
          Map.get(item, :class)
        ]}
        data-slot="accordion-item"
        data-hide-separator={if @hide_separator, do: "true"}
      >
        <.dynamic_tag
          tag_name={"h#{@heading_level}"}
          class="accordion__heading flex"
          data-slot="accordion-heading"
        >
          <button
            id={"#{@id}-trigger-#{Base.url_encode64(item.key, padding: false)}"}
            type="button"
            class="accordion__trigger list-none [&::-webkit-details-marker]:hidden flex flex-1 items-center justify-between px-4 py-4 text-start text-sm font-medium no-highlight cursor-(--cursor-interactive) [transition:opacity_150ms_var(--ease-out),box-shadow_150ms_var(--ease-out)] [&:focus-visible:not([data-focused])]:status-focused data-[focus-visible=true]:status-focused disabled:status-disabled aria-disabled:status-disabled [@media(hover:hover)]:[&:hover:not([aria-expanded=true])]:bg-[color-mix(in_oklab,var(--foreground)_3%,transparent_90%)] [@media(hover:hover)]:[.accordion--surface_&:hover:not([aria-expanded=true])]:bg-default"
            data-slot="accordion-trigger"
            data-accordion-trigger
            data-key={item.key}
            disabled={@disabled || Map.get(item, :disabled, false)}
            aria-expanded={to_string(MapSet.member?(@expanded_set, item.key))}
            aria-controls={"#{@id}-panel-#{Base.url_encode64(item.key, padding: false)}"}
            x-bind:aria-expanded="expanded.includes($el.dataset.key).toString()"
            x-on:click="toggle($el.dataset.key)"
            phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["aria-expanded"])}
          >
            {item.title}
            <span
              :if={@indicator != []}
              class="accordion__indicator ms-auto size-4 shrink-0 text-muted transition duration-250 data-[expanded=true]:-rotate-180 [.olis-native-accordion[open]_&]:-rotate-180"
              data-slot="accordion-indicator"
              data-key={item.key}
              data-expanded={if MapSet.member?(@expanded_set, item.key), do: "true"}
              x-bind:data-expanded="expanded.includes($el.dataset.key) ? 'true' : null"
              aria-hidden="true"
              phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["data-expanded"])}
            >{render_slot(@indicator, item)}</span>
            <svg
              :if={@indicator == []}
              class="accordion__indicator ms-auto size-4 shrink-0 text-muted transition duration-250 data-[expanded=true]:-rotate-180 [.olis-native-accordion[open]_&]:-rotate-180"
              data-slot="accordion-indicator"
              data-key={item.key}
              data-expanded={if MapSet.member?(@expanded_set, item.key), do: "true"}
              x-bind:data-expanded="expanded.includes($el.dataset.key) ? 'true' : null"
              aria-hidden="true"
              viewBox="0 0 16 16"
              fill="none"
              phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["data-expanded"])}
            ><path
              d="M2.97 5.47a.75.75 0 0 1 1.06 0L8 9.44l3.97-3.97a.75.75 0 1 1 1.06 1.06l-4.5 4.5a.75.75 0 0 1-1.06 0l-4.5-4.5a.75.75 0 0 1 0-1.06"
              fill="currentColor"
              fill-rule="evenodd"
              clip-rule="evenodd"
            /></svg>
          </button>
        </.dynamic_tag>
        <div
          id={"#{@id}-panel-#{Base.url_encode64(item.key, padding: false)}"}
          class="accordion__panel h-(--disclosure-panel-height) overflow-clip opacity-0 [transition:height_200ms_var(--ease-out-quad),opacity_200ms_var(--ease-out)] data-[expanded=true]:opacity-100 data-[expanded=true]:will-change-[height,opacity]"
          data-slot="accordion-panel"
          data-key={item.key}
          data-expanded={if MapSet.member?(@expanded_set, item.key), do: "true"}
          role="group"
          aria-labelledby={"#{@id}-trigger-#{Base.url_encode64(item.key, padding: false)}"}
          aria-hidden={to_string(!MapSet.member?(@expanded_set, item.key))}
          hidden={!MapSet.member?(@expanded_set, item.key)}
          inert={!MapSet.member?(@expanded_set, item.key)}
          x-show="expanded.includes($el.dataset.key)"
          x-collapse.duration.200ms
          x-bind:data-expanded="expanded.includes($el.dataset.key) ? 'true' : null"
          x-bind:aria-hidden="(!expanded.includes($el.dataset.key)).toString()"
          x-bind:inert="!expanded.includes($el.dataset.key)"
          phx-mounted={
            Phoenix.LiveView.JS.ignore_attributes([
              "hidden",
              "inert",
              "style",
              "aria-hidden",
              "data-expanded"
            ])
          }
        >
          <div class="accordion__body text-sm" data-slot="accordion-body">
            <div class="accordion__body-inner px-4 pt-0 pb-4 text-muted">{render_slot(item)}</div>
          </div>
        </div>
      </div>
      <button
        :if={@on_expanded_change}
        type="button"
        hidden
        x-ref="changeEvent"
        phx-click={@on_expanded_change}
        phx-target={@target}
      ></button>
    </div>
    """
  end

  @doc "A disclosure with a native summary and optional LiveView state handling."
  attr(:id, :string, required: true)
  attr(:title, :string, default: nil)
  attr(:open, :boolean, default: false)
  attr(:controlled, :boolean, default: false)
  attr(:disabled, :boolean, default: false)
  attr(:name, :string, default: nil)
  attr(:value, :string, default: nil)
  attr(:on_toggle, :string, default: nil)

  attr(:variant, :string,
    default: "secondary",
    values: ~w(primary secondary tertiary outline ghost danger danger-soft)
  )

  attr(:full_width, :boolean, default: false)
  attr(:class, :any, default: nil)
  attr(:trigger_class, :any, default: nil)
  attr(:content_class, :any, default: nil)
  attr(:rest, :global)
  slot(:trigger)
  slot(:inner_block, required: true)

  def disclosure(assigns) do
    if is_nil(assigns.title) && assigns.trigger == [],
      do: raise(ArgumentError, "disclosure requires a title or trigger slot")

    ~H"""
    <details
      id={@id}
      class={[
        "disclosure relative",
        "olis-disclosure",
        "[&[open]_[data-slot=disclosure-indicator]]:-rotate-180",
        "[interpolate-size:allow-keywords]",
        "[&::details-content]:h-0 [&::details-content]:overflow-clip [&::details-content]:opacity-0",
        "[&::details-content]:transition-[height,opacity,content-visibility] [&::details-content]:duration-200 [&::details-content]:[transition-behavior:allow-discrete]",
        "[&[open]::details-content]:h-auto [&[open]::details-content]:opacity-100",
        @class
      ]}
      data-slot="disclosure"
      data-olis-disclosure
      data-disabled={if @disabled, do: "true"}
      data-expanded={if @open, do: "true"}
      open={@open}
      name={@name}
      x-data="olisDisclosure"
      x-on:toggle.self="sync()"
      x-on:phx:update.window="sync()"
      x-bind:data-expanded="expanded ? 'true' : null"
      phx-mounted={
        Phoenix.LiveView.JS.ignore_attributes(
          if @controlled, do: ["data-expanded"], else: ["open", "data-expanded"]
        )
      }
      {@rest}
    >
      <summary
        id={"#{@id}-trigger"}
        class={[
          "disclosure__trigger",
          "inline-flex list-none [&::-webkit-details-marker]:hidden",
          button_classes(@variant, "md", @full_width),
          @disabled && "pointer-events-none cursor-not-allowed opacity-50",
          @trigger_class
        ]}
        data-slot="disclosure-trigger"
        data-olis-disclosure-trigger
        role="button"
        aria-controls={"#{@id}-content"}
        aria-expanded={to_string(@open)}
        aria-disabled={if @disabled, do: "true"}
        tabindex={if @disabled, do: "-1"}
        phx-click={if !@disabled, do: @on_toggle}
        phx-value-key={@value || @id}
        phx-value-expanded={to_string(!@open)}
        x-on:click="beforeToggle($event)"
        x-bind:aria-expanded="expanded.toString()"
        x-bind:phx-value-expanded="(!expanded).toString()"
        phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["aria-expanded", "phx-value-expanded"])}
      >
        <span class="olis-disclosure-label flex-1 text-start"><%= if @trigger != [] do %>
          {render_slot(@trigger)}
        <% else %>
          {@title}
        <% end %></span>
        <svg
          class="disclosure__indicator ms-auto size-4 shrink-0 text-inherit transition duration-250 data-[expanded=true]:-rotate-180"
          data-slot="disclosure-indicator"
          data-expanded={if @open, do: "true"}
          x-bind:data-expanded="expanded ? 'true' : null"
          phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["data-expanded"])}
          aria-hidden="true"
          viewBox="0 0 16 16"
          fill="none"
        >
          <path
            d="M2.97 5.47a.75.75 0 0 1 1.06 0L8 9.44l3.97-3.97a.75.75 0 1 1 1.06 1.06l-4.5 4.5a.75.75 0 0 1-1.06 0l-4.5-4.5a.75.75 0 0 1 0-1.06"
            fill="currentColor"
            fill-rule="evenodd"
            clip-rule="evenodd"
          />
        </svg>
      </summary>
      <div
        id={"#{@id}-content"}
        class={[
          "disclosure__content h-auto overflow-clip opacity-100 [transition:height_200ms_var(--ease-out-quad),opacity_200ms_var(--ease-out)] data-[expanded=true]:will-change-[height,opacity]",
          @content_class
        ]}
        data-slot="disclosure-content"
        data-olis-disclosure-content
        data-expanded={if @open, do: "true"}
        x-bind:data-expanded="expanded ? 'true' : null"
        phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["data-expanded"])}
        role="group"
        aria-labelledby={"#{@id}-trigger"}
      >
        <div class="disclosure__body p-2" data-slot="disclosure-body">
          <div class="disclosure__body-inner">{render_slot(@inner_block)}</div>
        </div>
      </div>
    </details>
    """
  end

  @doc "A group of disclosures with single or multiple expanded items."
  attr(:id, :string, required: true)
  attr(:expanded_keys, :list, default: nil)
  attr(:default_expanded_keys, :list, default: [])
  attr(:allows_multiple_expanded, :boolean, default: false)
  attr(:disabled, :boolean, default: false)
  attr(:on_toggle, :string, default: nil)

  attr(:variant, :string,
    default: "secondary",
    values: ~w(primary secondary tertiary outline ghost danger danger-soft)
  )

  attr(:class, :any, default: nil)
  attr(:trigger_class, :any, default: nil)
  attr(:rest, :global)

  slot :item, required: true do
    attr(:key, :string, required: true)
    attr(:title, :string, required: true)
    attr(:disabled, :boolean)
  end

  def disclosure_group(assigns) do
    keys = Enum.map(assigns.item, & &1.key)

    if length(keys) != length(Enum.uniq(keys)),
      do: raise(ArgumentError, "disclosure keys must be unique")

    expanded = assigns.expanded_keys || assigns.default_expanded_keys

    if !assigns.allows_multiple_expanded && length(Enum.uniq(expanded)) > 1,
      do: raise(ArgumentError, "single disclosure groups allow at most one expanded key")

    assigns =
      assigns
      |> assign(:expanded, MapSet.new(expanded))
      |> assign(:controlled, !is_nil(assigns.expanded_keys))

    ~H"""
    <div
      id={@id}
      class={["disclosure-group w-full [contain:layout_style]", @class]}
      data-slot="disclosure-group"
      data-olis-disclosure-group
      data-allows-multiple-expanded={to_string(@allows_multiple_expanded)}
      {@rest}
    >
      <.disclosure
        :for={item <- @item}
        id={"#{@id}-#{Base.url_encode64(item.key, padding: false)}"}
        title={item.title}
        value={item.key}
        open={MapSet.member?(@expanded, item.key)}
        controlled={@controlled}
        name={if !@allows_multiple_expanded, do: "#{@id}-disclosure-group"}
        disabled={@disabled || Map.get(item, :disabled, false)}
        on_toggle={@on_toggle}
        variant={@variant}
        full_width
        trigger_class={@trigger_class}
      >
        {render_slot(item)}
      </.disclosure>
    </div>
    """
  end

  @doc """
  Contextual feedback with a status icon, title, description, and optional actions.
  Use `status` for OlisUI naming; the existing `color` attribute remains supported.
  """
  attr(:title, :string, default: nil)
  attr(:color, :string, default: "default", values: ~w(default accent success warning danger))
  attr(:status, :string, default: nil, values: [nil | ~w(default accent success warning danger)])
  attr(:role, :string, default: "status")
  attr(:show_indicator, :boolean, default: true)
  attr(:class, :any, default: nil)
  attr(:rest, :global)
  slot(:inner_block)
  slot(:indicator)
  slot(:title_content)
  slot(:description)
  slot(:content)
  slot(:actions)

  def alert(assigns) do
    status = assigns.status || assigns.color

    data_slot =
      Map.get(assigns.rest, :"data-slot") || Map.get(assigns.rest, "data-slot") || "alert-root"

    rest = Map.drop(assigns.rest, [:"data-slot", "data-slot"])

    assigns =
      assign(assigns,
        status: status,
        data_slot: data_slot,
        rest: rest,
        status_color:
          %{
            "default" => "text-foreground",
            "accent" => "text-accent-soft-foreground",
            "success" => "text-success-soft-foreground",
            "warning" => "text-warning-soft-foreground",
            "danger" => "text-danger-soft-foreground"
          }[status],
        icon_path: alert_icon_path(status)
      )

    ~H"""
    <div
      role={@role}
      class={[
        "alert flex w-full flex-row items-start justify-start gap-2 rounded-[12px] border-[0.5px] border-border bg-surface px-4 py-3",
        "alert--#{@status}",
        @class
      ]}
      data-slot={@data_slot}
      {@rest}
    >
      <div
        :if={@show_indicator}
        class={["alert__indicator flex items-center justify-center p-1 select-none", @status_color]}
        data-slot="alert-indicator"
      >
        <%= if @indicator != [] do %>
          {render_slot(@indicator)}
        <% else %>
          <svg
            data-slot="alert-default-icon"
            class="box-content size-4"
            aria-hidden="true"
            role="presentation"
            viewBox="0 0 16 16"
            fill="none"
          ><path d={@icon_path} fill="currentColor" fill-rule="evenodd" clip-rule="evenodd" /></svg>
        <% end %>
      </div>
      <div class="alert__content flex h-full grow flex-col items-start" data-slot="alert-content">
        <p
          :if={@title || @title_content != []}
          class={["alert__title text-sm leading-6 font-medium", @status_color]}
          data-slot="alert-title"
        >
          <%= if @title_content != [] do %>
            {render_slot(@title_content)}
          <% else %>
            {@title}
          <% end %>
        </p>
        <div
          :if={@inner_block != [] && @description == []}
          class="alert__description text-sm text-muted"
          data-slot="alert-description"
        >
          {render_slot(@inner_block)}
        </div>
        <span
          :for={description <- @description}
          class="alert__description text-sm text-muted"
          data-slot="alert-description"
        >{render_slot(description)}</span>
        {render_slot(@content)}
      </div>
      {render_slot(@actions)}
    </div>
    """
  end

  # Icon paths adapted from upstream, Apache-2.0. See THIRD_PARTY_NOTICES.md.
  defp alert_icon_path("success"),
    do:
      "M13.5 8a5.5 5.5 0 1 1-11 0a5.5 5.5 0 0 1 11 0M15 8A7 7 0 1 1 1 8a7 7 0 0 1 14 0m-3.9-1.55a.75.75 0 1 0-1.2-.9L7.419 8.858L6.03 7.47a.75.75 0 0 0-1.06 1.06l2 2a.75.75 0 0 0 1.13-.08z"

  defp alert_icon_path("warning"),
    do:
      "M7.134 2.994L2.217 11.5a1 1 0 0 0 .866 1.5h9.834a1 1 0 0 0 .866-1.5L8.866 2.993a1 1 0 0 0-1.732 0m3.03-.75c-.962-1.665-3.366-1.665-4.329 0L.918 10.749c-.963 1.666.24 3.751 2.165 3.751h9.834c1.925 0 3.128-2.085 2.164-3.751zM8 5a.75.75 0 0 1 .75.75v2a.75.75 0 0 1-1.5 0v-2A.75.75 0 0 1 8 5m1 5.75a1 1 0 1 1-2 0a1 1 0 0 1 2 0"

  defp alert_icon_path("danger"),
    do:
      "M8 13.5a5.5 5.5 0 1 0 0-11a5.5 5.5 0 0 0 0 11M8 15A7 7 0 1 0 8 1a7 7 0 0 0 0 14m1-4.5a1 1 0 1 1-2 0a1 1 0 0 1 2 0M8.75 5a.75.75 0 0 0-1.5 0v2.5a.75.75 0 0 0 1.5 0z"

  defp alert_icon_path(_),
    do:
      "M8 13.5a5.5 5.5 0 1 0 0-11a5.5 5.5 0 0 0 0 11M8 15A7 7 0 1 0 8 1a7 7 0 0 0 0 14m1-9.5a1 1 0 1 1-2 0a1 1 0 0 1 2 0m-.25 3a.75.75 0 0 0-1.5 0V11a.75.75 0 0 0 1.5 0z"

  @doc "A compact status badge. Use placement inside a badge anchor."
  attr(:color, :string, default: "default", values: ~w(default accent success warning danger))
  attr(:size, :string, default: "md", values: ~w(sm md lg))
  attr(:variant, :string, default: "primary", values: ~w(primary secondary soft))

  attr(:placement, :string,
    default: nil,
    values: [nil | ~w(top-left top-right bottom-left bottom-right)]
  )

  attr(:class, :any, default: nil)
  slot(:inner_block, required: true)

  def badge(assigns) do
    colors = %{
      "default" =>
        {"bg-default text-muted", "text-muted", "bg-default-soft text-default-soft-foreground"},
      "accent" =>
        {"bg-accent text-accent-foreground", "text-accent-soft-foreground",
         "bg-accent-soft text-accent-soft-foreground"},
      "success" =>
        {"bg-success text-success-foreground", "text-success-soft-foreground",
         "bg-success-soft text-success-soft-foreground"},
      "warning" =>
        {"bg-warning text-warning-foreground", "text-warning-soft-foreground",
         "bg-warning-soft text-warning-soft-foreground"},
      "danger" =>
        {"bg-danger text-danger-foreground", "text-danger-soft-foreground",
         "bg-danger-soft text-danger-soft-foreground"}
    }

    {solid, foreground, soft} = colors[assigns.color]

    palette =
      case assigns.variant do
        "primary" -> solid
        "soft" -> soft
        _ -> "bg-default " <> foreground
      end

    assigns = assign(assigns, :palette, palette)

    ~H"""
    <span class={[
      "badge inline-flex shrink-0 items-center justify-center gap-0.5 rounded-[4px] border border-transparent bg-clip-padding font-normal",
      @palette,
      @size == "sm" && "min-h-4 min-w-4 px-1 text-[10px] leading-[1.34]",
      @size == "md" && "min-h-5 min-w-5 px-1.5 text-xs leading-[1.34]",
      @size == "lg" && "min-h-6 min-w-6 px-2 text-sm leading-[1.43]",
      @placement == "top-right" && "absolute top-0 right-0 translate-x-1/4 -translate-y-1/4",
      @placement == "top-left" && "absolute top-0 left-0 -translate-x-1/4 -translate-y-1/4",
      @placement == "bottom-right" && "absolute right-0 bottom-0 translate-x-1/4 translate-y-1/4",
      @placement == "bottom-left" && "absolute bottom-0 left-0 -translate-x-1/4 translate-y-1/4",
      "badge--#{@color}",
      "badge--#{@size}",
      "badge--#{@variant}",
      @placement && "badge--#{@placement}",
      @class
    ]}><span class="badge__label px-0">{render_slot(@inner_block)}</span></span>
    """
  end

  @doc "An anchor for a positioned badge."
  attr(:class, :any, default: nil)
  slot(:inner_block, required: true)

  def badge_anchor(assigns) do
    ~H"""
    <span class={["badge-anchor relative inline-flex shrink-0", @class]}>{render_slot(@inner_block)}</span>
    """
  end

  @doc """
  A semantic, responsive OlisUI table. Column slots receive each row.

  Pass a LiveView stream as `rows` and a unique `id` for incremental updates.
  For server-side sorting, give columns `sort_key` and set `sort_event`; the
  event receives `%{"sort" => key}`. The caller owns the order and sort state.
  Use the `:empty` slot for custom empty content and `:footer` for pagination.
  Set `on_load_more` and `has_more` to request the next page when the end of
  the table reaches the viewport. The application owns loading and pagination.
  """
  attr(:id, :string, default: nil)
  attr(:rows, :any, required: true)
  attr(:label, :string, required: true)
  attr(:variant, :string, default: "primary", values: ~w(primary secondary))
  attr(:row_id, :any, default: nil)
  attr(:sort_event, :string, default: nil)
  attr(:sort_by, :string, default: nil)
  attr(:sort_direction, :string, default: "ascending", values: ~w(ascending descending))
  attr(:empty_message, :string, default: "No results found.")
  attr(:selection_mode, :string, default: "none", values: ~w(none single multiple))
  attr(:selected_keys, :list, default: nil)
  attr(:default_selected_keys, :list, default: [])
  attr(:disabled_keys, :list, default: [])
  attr(:row_label, :any, default: nil)
  attr(:on_selection_change, :string, default: nil)
  attr(:on_column_resize, :string, default: nil)
  attr(:on_load_more, :any, default: nil)
  attr(:has_more, :boolean, default: false)
  attr(:loading, :boolean, default: false)
  attr(:target, :any, default: nil)
  attr(:class, :any, default: nil)

  slot :col, required: true do
    attr(:label, :string, required: true)
    attr(:sort_key, :string)
    attr(:row_header, :boolean)
    attr(:key, :string)
    attr(:resizable, :boolean)
    attr(:width, :integer)
    attr(:min_width, :integer)
    attr(:max_width, :integer)
    attr(:class, :any)
  end

  slot(:empty)
  slot(:footer)
  slot(:load_more)

  def data_table(assigns) do
    stream? = match?(%Phoenix.LiveView.LiveStream{}, assigns.rows)

    if stream? and is_nil(assigns.id),
      do: raise(ArgumentError, "a table id is required for stream rows")

    if assigns.on_load_more && is_nil(assigns.id),
      do: raise(ArgumentError, "a table id is required for load-more events")

    if !stream? and !is_list(assigns.rows),
      do: raise(ArgumentError, "table rows must be a list or LiveView stream")

    selected = assigns.selected_keys || assigns.default_selected_keys

    if assigns.selection_mode != "none" and
         (is_nil(assigns.id) or (!stream? and !is_function(assigns.row_id, 1))),
       do:
         raise(
           ArgumentError,
           "selectable tables require an id and a row_id function for list rows"
         )

    if assigns.selection_mode == "none" and
         (assigns.selected_keys != nil or assigns.default_selected_keys != [] or
            assigns.on_selection_change != nil),
       do: raise(ArgumentError, "table selection options require single or multiple selection")

    if assigns.selected_keys != nil and assigns.default_selected_keys != [],
      do: raise(ArgumentError, "selected_keys and default_selected_keys cannot be combined")

    if Enum.any?(selected ++ assigns.disabled_keys, &(not is_binary(&1) or &1 == "")) or
         length(Enum.uniq(selected)) != length(selected),
       do: raise(ArgumentError, "table selection keys must be unique nonempty strings")

    if assigns.selection_mode == "single" and length(selected) > 1,
      do: raise(ArgumentError, "single-selection tables allow at most one selected key")

    if !is_nil(assigns.row_label) and !is_function(assigns.row_label, 1),
      do: raise(ArgumentError, "row_label must be a function")

    if assigns.selection_mode != "none" and !stream? do
      keys = Enum.map(assigns.rows, assigns.row_id)

      if Enum.any?(keys, &(not is_binary(&1) or &1 == "")) or
           length(Enum.uniq(keys)) != length(keys),
         do: raise(ArgumentError, "selectable table row ids must be unique nonempty strings")
    end

    columns =
      assigns.col
      |> Enum.with_index()
      |> Enum.map(fn {col, index} ->
        key = Map.get(col, :key) || Integer.to_string(index)
        min_width = Map.get(col, :min_width) || 48
        max_width = Map.get(col, :max_width) || 2000
        width = Map.get(col, :width)

        unless is_binary(key) and key != "" and key != "__selection__" and
                 is_integer(min_width) and min_width > 0 and
                 is_integer(max_width) and max_width >= min_width and
                 (is_nil(width) or
                    (is_integer(width) and width >= min_width and width <= max_width)) do
          raise ArgumentError,
                "table column widths must be positive integer pixels within min_width and max_width"
        end

        Map.merge(col, %{column_key: key, min_width: min_width, max_width: max_width})
      end)

    keys = Enum.map(columns, & &1.column_key)

    if length(Enum.uniq(keys)) != length(keys),
      do: raise(ArgumentError, "table column keys must be unique")

    assigns =
      assign(assigns,
        columns: columns,
        resizable?: Enum.any?(columns, &Map.get(&1, :resizable, false)),
        stream?: stream?,
        empty?: !stream? and assigns.rows == [],
        selected_set: MapSet.new(selected),
        disabled_set: MapSet.new(assigns.disabled_keys),
        encoded_selected: Jason.encode!(selected)
      )

    ~H"""
    <div
      class={[
        "table-root table-root--#{@variant} relative grid w-full overflow-clip [grid-template-columns:minmax(0,1fr)]",
        @variant == "primary" && "rounded-[12px] bg-surface-secondary px-1 pb-1",
        @class
      ]}
      data-olis-table="true"
      data-selection-mode={if @selection_mode != "none", do: @selection_mode}
      data-selected-keys={if @selection_mode != "none", do: @encoded_selected}
      data-controlled={if @selection_mode != "none", do: to_string(!is_nil(@selected_keys))}
      x-data="olisTable"
      x-on:keydown="keyDown($event)"
      x-on:focusin="focusIn($event)"
      x-on:focusout="focusOut($event)"
      x-on:pointermove.window={if @resizable?, do: "resizeMove($event)"}
      x-on:pointerup.window={if @resizable?, do: "resizeEnd($event)"}
      x-on:pointercancel.window={if @resizable?, do: "resizeCancel($event)"}
      x-on:change={if @selection_mode != "none", do: "selectionChange($event)"}
      x-on:click={if @selection_mode != "none", do: "rowClick($event)"}
      x-on:phx:update.document="sync()"
    >
      <div
        id={if @on_load_more, do: "#{@id}-scroll"}
        phx-viewport-bottom={if @on_load_more && @has_more && !@loading, do: @on_load_more}
        phx-target={if @on_load_more, do: @target}
      >
        <div class={[
          "table__scroll-container scrollbar overflow-x-auto [scrollbar-gutter:auto]",
          @resizable? && "table__resizable-container relative overflow-auto"
        ]}>
          <table
            id={@id}
            class={[
              "table__content w-full border-separate border-spacing-0 text-sm",
              @variant == "primary" && "overflow-clip"
            ]}
            aria-label={@label}
            x-bind:role="'grid'"
            tabindex="0"
            x-bind:aria-multiselectable="$root.dataset.selectionMode === 'multiple' ? 'true' : null"
            phx-mounted={if @resizable?, do: Phoenix.LiveView.JS.ignore_attributes(["style"])}
          >
            <colgroup :if={@resizable?}>
              <col :if={@selection_mode != "none"} data-table-column-key="__selection__" />
              <col
                :for={col <- @columns}
                data-table-column-key={col.column_key}
                data-min-width={col.min_width}
                data-max-width={col.max_width}
                style={if Map.get(col, :width), do: "width: #{col.width}px"}
                phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["style"])}
              />
            </colgroup>
            <thead class={[
              "table__header",
              @variant == "primary" && "border-b border-separator/50 bg-surface-secondary",
              @variant == "secondary" && "border-b-0 bg-transparent"
            ]}>
              <tr>
                <th :if={@selection_mode != "none"} scope="col" class={table_column_classes(@variant)}>
                  <.table_selection_control
                    :if={@selection_mode == "multiple"}
                    label="Select all rows"
                    select_all
                  />
                  <span :if={@selection_mode == "single"} class="sr-only">Selection</span>
                </th>
                <th
                  :for={{col, index} <- Enum.with_index(@columns)}
                  scope="col"
                  class={[table_column_classes(@variant), Map.get(col, :class)]}
                  data-allows-sorting={if @sort_event && Map.get(col, :sort_key), do: "true"}
                  aria-sort={if @sort_by && @sort_by == Map.get(col, :sort_key), do: @sort_direction}
                >
                  <button
                    :if={@sort_event && Map.get(col, :sort_key)}
                    type="button"
                    class="table__sortable-column-header flex items-center justify-between olis-table-sort w-full gap-2 [text-align:inherit] cursor-pointer focus-visible:rounded-sm focus-visible:outline-2 focus-visible:outline-focus focus-visible:outline-offset-2"
                    phx-click={@sort_event}
                    phx-value-sort={col.sort_key}
                  >
                    {col.label}<svg
                      class="table__sortable-column-indicator inline-grid size-3 transform place-content-center transition-transform duration-100 ease-out data-[direction=descending]:rotate-180"
                      data-direction={if @sort_by == col.sort_key, do: @sort_direction}
                      viewBox="0 0 12 12"
                      fill="none"
                      aria-hidden="true"
                    ><path
                      d="m3 7.5 3-3 3 3"
                      stroke="currentColor"
                      stroke-width="1.5"
                      stroke-linecap="round"
                      stroke-linejoin="round"
                    /></svg>
                  </button>
                  <span :if={!@sort_event || !Map.get(col, :sort_key)}>{col.label}</span>
                  <div
                    :if={Map.get(col, :resizable, false)}
                    class={[
                      "table__column-resizer absolute end-0 top-1/2 z-10 box-content h-4 w-px -translate-y-1/2 cursor-col-resize touch-none rounded-sm border-none bg-separator bg-clip-content px-2 outline-none hover:h-full hover:w-0.5 hover:bg-accent data-[hovered=true]:h-full data-[hovered=true]:w-0.5 data-[hovered=true]:bg-accent data-[resizing=true]:h-full data-[resizing=true]:w-0.5 data-[resizing=true]:bg-accent focus-visible:h-full focus-visible:w-0.5 focus-visible:bg-focus data-[focus-visible=true]:h-full data-[focus-visible=true]:w-0.5 data-[focus-visible=true]:bg-focus",
                      index == length(@columns) - 1 && "translate-x-0",
                      index != length(@columns) - 1 && "translate-x-1/2"
                    ]}
                    role="separator"
                    tabindex="0"
                    aria-label={"Resize #{col.label} column"}
                    aria-orientation="vertical"
                    aria-valuemin={col.min_width}
                    aria-valuemax={col.max_width}
                    aria-valuenow={Map.get(col, :width)}
                    data-table-resizer={col.column_key}
                    x-on:focus="syncWidths()"
                    x-on:pointerdown="resizeStart($event)"
                    x-on:keydown="resizeKey($event)"
                    x-on:click.stop
                    phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["aria-valuenow"])}
                  >
                  </div>
                </th>
              </tr>
            </thead>
            <tbody
              id={if @stream?, do: "#{@id}-body"}
              phx-update={if @stream?, do: "stream"}
              class="table__body"
            >
              <tr
                :for={item <- @rows}
                id={table_row_id(item, @stream?, @row_id)}
                class={table_row_classes()}
                data-olis-table-row="true"
                data-key={if @selection_mode != "none", do: table_row_id(item, @stream?, @row_id)}
                data-selected={
                  if @selection_mode != "none" and
                       MapSet.member?(@selected_set, table_row_id(item, @stream?, @row_id)),
                     do: "true"
                }
                aria-selected={
                  if @selection_mode != "none",
                    do:
                      to_string(MapSet.member?(@selected_set, table_row_id(item, @stream?, @row_id)))
                }
              >
                <td :if={@selection_mode != "none"} class={table_cell_classes(@variant, false)}>
                  <.table_selection_control
                    label={table_selection_label(item, @stream?, @row_id, @row_label)}
                    selected={MapSet.member?(@selected_set, table_row_id(item, @stream?, @row_id))}
                    disabled={MapSet.member?(@disabled_set, table_row_id(item, @stream?, @row_id))}
                  />
                </td>
                <%= for col <- @col do %>
                  <th
                    :if={Map.get(col, :row_header, false)}
                    scope="row"
                    class={table_cell_classes(@variant, true)}
                  >
                    {render_slot(col, table_row_value(item, @stream?))}
                  </th>
                  <td
                    :if={!Map.get(col, :row_header, false)}
                    class={table_cell_classes(@variant, false)}
                  >
                    {render_slot(col, table_row_value(item, @stream?))}
                  </td>
                <% end %>
              </tr>
              <tr
                :if={@empty? || @stream?}
                id={if @stream?, do: "#{@id}-empty"}
                class={[table_row_classes(), @stream? && "hidden only:table-row"]}
              >
                <td
                  class={table_cell_classes(@variant, false)}
                  colspan={length(@col) + if(@selection_mode == "none", do: 0, else: 1)}
                >
                  <%= if @empty == [] do %>
                    {@empty_message}
                  <% else %>
                    {render_slot(@empty)}
                  <% end %>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
        <div
          :if={@on_load_more && @has_more}
          id={"#{@id}-load-more"}
          class="table__load-more-content flex items-center justify-center gap-2 py-2"
          data-slot="table-load-more-content"
          aria-live="polite"
        >
          <%= if @load_more == [] do %>
            <.spinner :if={@loading} size="sm" decorative />
            <span class="text-sm text-muted">{if @loading,
              do: "Loading more…",
              else: "Scroll for more"}</span>
          <% else %>
            {render_slot(@load_more)}
          <% end %>
        </div>
      </div>
      <div
        :if={@footer != []}
        class="table__footer flex items-center px-4 py-2.5"
        data-slot="table-footer"
      >
        {render_slot(@footer)}
      </div>
      <button
        :if={@on_column_resize}
        type="button"
        hidden
        data-olis-table-resize-event
        phx-click={@on_column_resize}
        phx-target={@target}
      ></button>
      <button
        :if={@on_selection_change}
        type="button"
        hidden
        data-olis-table-selection-event
        phx-click={@on_selection_change}
        phx-target={@target}
      ></button>
    </div>
    """
  end

  defp table_column_classes(variant) do
    [
      "table__column relative px-4 py-2.5 text-start text-xs font-medium text-muted after:pointer-events-none after:absolute after:end-0 after:top-1/2 after:h-4 after:w-px after:-translate-y-1/2 after:rounded-sm after:bg-separator after:content-[''] [&:last-child:not(:only-child)]:after:content-none has-[.table__column-resizer]:after:content-none data-[allows-sorting=true]:cursor-(--cursor-interactive) [@media(hover:hover)]:[&[data-allows-sorting=true]:hover]:text-foreground [@media(hover:hover)]:[&[data-allows-sorting=true][data-hovered=true]]:text-foreground focus-visible:rounded-lg focus-visible:outline-none focus-visible:shadow-[inset_0_0_0_2px_var(--focus)] data-[focus-visible=true]:rounded-lg data-[focus-visible=true]:outline-none data-[focus-visible=true]:shadow-[inset_0_0_0_2px_var(--focus)]",
      variant == "secondary" &&
        "bg-surface-secondary first:[border-start-start-radius:12px] first:[border-end-start-radius:12px] last:[border-start-end-radius:12px] last:[border-end-end-radius:12px]"
    ]
  end

  defp table_row_classes do
    "table__row relative h-full border-b border-separator/50 last:border-b-0 aria-disabled:status-disabled data-[disabled=true]:status-disabled focus-visible:outline-none data-[focus-visible=true]:outline-none data-[dragging=true]:opacity-50"
  end

  defp table_cell_classes(variant, row_header?) do
    [
      "table__cell h-full border-b border-separator-tertiary/50 px-4 py-3 align-middle text-sm text-foreground focus-visible:rounded-lg focus-visible:outline-none focus-visible:shadow-[inset_0_0_0_2px_var(--focus)] data-[focus-visible=true]:rounded-lg data-[focus-visible=true]:outline-none data-[focus-visible=true]:shadow-[inset_0_0_0_2px_var(--focus)] [.table__row[data-selected=true]_&]:bg-surface/10 [.table__row[data-drop-target=true]_&]:bg-accent-soft [.table__row:is(:focus-visible,[data-focus-visible=true])_&]:shadow-none [.table__row:is(:focus-visible,[data-focus-visible=true])>&:only-child]:rounded-lg [.table__row:is(:focus-visible,[data-focus-visible=true])>&:only-child]:shadow-[inset_0_0_0_2px_var(--focus)] [.table__row:is(:focus-visible,[data-focus-visible=true])>&:first-child:not(:only-child)]:rounded-s-lg [.table__row:is(:focus-visible,[data-focus-visible=true])>&:first-child:not(:only-child)]:shadow-[inset_2px_0_0_0_var(--focus),inset_0_2px_0_0_var(--focus),inset_0_-2px_0_0_var(--focus)] [.table__row:is(:focus-visible,[data-focus-visible=true])>&:last-child:not(:only-child)]:rounded-e-lg [.table__row:is(:focus-visible,[data-focus-visible=true])>&:last-child:not(:only-child)]:shadow-[inset_-2px_0_0_0_var(--focus),inset_0_2px_0_0_var(--focus),inset_0_-2px_0_0_var(--focus)] [.table__row:is(:focus-visible,[data-focus-visible=true])>&:not(:first-child):not(:last-child)]:shadow-[inset_0_2px_0_0_var(--focus),inset_0_-2px_0_0_var(--focus)]",
      variant == "primary" &&
        "bg-surface [@media(hover:hover)]:[.table__row:hover:not([data-selected=true])_&]:bg-surface/40 [@media(hover:hover)]:[.table__row[data-hovered=true]:not([data-selected=true])_&]:bg-surface/40",
      variant == "secondary" &&
        "bg-transparent [@media(hover:hover)]:[.table__row:hover_&]:bg-default/50 [@media(hover:hover)]:[.table__row[data-hovered=true]_&]:bg-default/50",
      variant == "primary" && !row_header? &&
        "[.table__body_tr:first-child>&:first-child]:[border-start-start-radius:12px] [.table__body_tr:first-child>&:last-child]:[border-start-end-radius:12px] [.table__body_tr:last-child>&:first-child]:[border-end-start-radius:12px] [.table__body_tr:last-child>&:last-child]:[border-end-end-radius:12px]",
      variant == "primary" && row_header? &&
        "[.table__body_tr:first-child>&:first-child]:[border-start-start-radius:min(32px,var(--radius-2xl))] [.table__body_tr:last-child>&:first-child]:[border-end-start-radius:min(32px,var(--radius-2xl))]"
    ]
  end

  attr(:label, :string, required: true)
  attr(:select_all, :boolean, default: false)
  attr(:selected, :boolean, default: false)
  attr(:disabled, :boolean, default: false)

  defp table_selection_control(assigns) do
    ~H"""
    <label
      class={[checkbox_root_classes("primary"), "group"]}
      data-slot="checkbox"
      data-disabled={if @disabled, do: "true"}
    >
      <span class={checkbox_content_classes()} data-slot="checkbox-content">
        <input
          type="checkbox"
          class="olis-visually-hidden-input absolute [inset-block-start:0] start-0 z-[2] m-0 size-4 cursor-inherit opacity-0"
          aria-label={@label}
          checked={@selected}
          disabled={@disabled}
          data-olis-table-select-all={if @select_all, do: "true"}
          data-olis-table-select-row={if !@select_all, do: "true"}
        />
        <span class={checkbox_control_classes()} aria-hidden="true"><span class={
          checkbox_indicator_classes()
        }><svg
          class="group-data-[indeterminate=true]:hidden"
          data-slot="checkbox-default-indicator--checkmark"
          viewBox="0 0 16 16"
          fill="none"
        ><path
          d="M3.5 8l3 3 6-6"
          stroke="currentColor"
          stroke-width="2.5"
          stroke-linecap="round"
          stroke-linejoin="round"
        /></svg><svg
          class="hidden group-data-[indeterminate=true]:block"
          data-slot="checkbox-default-indicator--indeterminate"
          viewBox="0 0 16 16"
          fill="none"
        ><path d="M4 8h8" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" /></svg></span></span>
      </span>
    </label>
    """
  end

  defp table_selection_label(item, stream?, row_id, row_label) do
    value = table_row_value(item, stream?)
    "Select #{if row_label, do: row_label.(value), else: table_row_id(item, stream?, row_id)}"
  end

  defp table_row_value({_id, row}, true), do: row
  defp table_row_value(row, false), do: row
  defp table_row_id({id, _row}, true, _row_id), do: id
  defp table_row_id(row, false, row_id) when is_function(row_id, 1), do: row_id.(row)
  defp table_row_id(_row, false, nil), do: nil

  @doc """
  A modal dialog using the browser's focus containment and Escape behavior.

  Install the OlisUI Alpine providers as described in the README. Open it with a button carrying
  `data-olis-dialog-open={id}`, or pass a trigger slot receiving that attribute. Use `open` and
  `on_open_change` for server-controlled state or `default_open` for client-managed state.
  """
  attr(:id, :string, required: true)
  attr(:title, :string, required: true)
  attr(:size, :string, default: "md", values: ~w(xs sm md lg cover full))
  attr(:placement, :string, default: "auto", values: ~w(auto top center bottom))
  attr(:scroll, :string, default: "inside", values: ~w(inside outside))
  attr(:backdrop, :string, default: "opaque", values: ~w(opaque blur transparent))
  attr(:dismissible, :boolean, default: true)
  attr(:keyboard_dismiss_disabled, :boolean, default: false)
  attr(:description, :string, default: nil)
  attr(:open, :boolean, default: nil)
  attr(:default_open, :boolean, default: false)
  attr(:on_open_change, :any, default: nil)
  attr(:target, :any, default: nil)
  attr(:show_close, :boolean, default: true)
  attr(:close_label, :string, default: "Close")
  attr(:class, :any, default: nil)
  attr(:body_class, :any, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)
  slot(:footer)
  slot(:trigger)
  slot(:close)

  def modal(assigns) do
    if !is_nil(assigns.open) && assigns.default_open,
      do: raise(ArgumentError, "modal cannot use open and default_open together")

    ~H"""
    {render_slot(@trigger, %{"data-olis-dialog-open" => @id})}
    <dialog
      id={@id}
      class={[
        "modal__dialog flex flex-col bg-overlay p-6 outline-none pointer-events-auto [&:not([open])]:hidden",
        @size != "full" && "rounded-[12px] shadow-overlay",
        @size == "xs" && "max-w-xs",
        @size == "sm" && "max-w-sm",
        @size == "md" && "max-w-md",
        @size == "lg" && "max-w-lg",
        @size in ["cover", "full"] && "min-h-full",
        @scroll == "inside" && "min-h-0 overflow-clip",
        @scroll == "outside" && "min-h-0 shrink-0",
        "modal__dialog--#{@size}",
        "modal__dialog--scroll-#{@scroll}",
        "olis-native-modal",
        "olis-olis-modal",
        "fixed inset-0 m-auto w-[calc(100%-2rem)] max-h-[calc(100dvh-2rem)] border-0 text-foreground sm:max-h-[calc(100dvh-5rem)]",
        @scroll == "outside" && "overflow-y-auto",
        @size == "cover" &&
          "h-[calc(100dvh-2rem)] max-w-none sm:h-[calc(100dvh-5rem)] sm:w-[calc(100%-5rem)]",
        @size == "full" && "h-dvh max-h-none w-full max-w-none rounded-none shadow-none sm:max-h-none",
        @size != "full" && @placement == "auto" && "mb-4 sm:my-auto",
        @size != "full" && @placement == "top" && "mt-4 sm:mt-10",
        @size != "full" && @placement == "bottom" && "mb-4 sm:mb-10",
        @backdrop == "opaque" && "backdrop:bg-backdrop",
        @backdrop == "blur" && "backdrop:bg-backdrop backdrop:backdrop-blur-md",
        @backdrop == "transparent" && "backdrop:bg-transparent",
        @class
      ]}
      data-olis-dialog
      data-olis-modal
      data-slot="modal-dialog"
      data-placement={@placement}
      data-backdrop={@backdrop}
      data-scroll={@scroll}
      x-data="olisDialog"
      x-on:click.window="openFromTrigger($event)"
      x-on:click="onClick($event)"
      x-on:cancel="onCancel($event)"
      x-on:close="onNativeClose($event)"
      x-on:phx:update.window="sync()"
      phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["open"])}
      data-dismissible={to_string(@dismissible)}
      data-keyboard-dismiss-disabled={to_string(@keyboard_dismiss_disabled)}
      data-controlled={to_string(!is_nil(@open))}
      data-controlled-open={if !is_nil(@open), do: to_string(@open)}
      data-default-open={to_string(@default_open)}
      aria-labelledby={"#{@id}-title"}
      aria-describedby={if @description, do: "#{@id}-description"}
      {@rest}
    >
      <header
        class="modal__header mb-0 flex flex-col gap-3 [&>.modal__icon]:mb-0"
        data-slot="modal-header"
      >
        <h2
          class="modal__heading align-middle text-base font-medium text-foreground"
          id={"#{@id}-title"}
          data-slot="modal-heading"
        >
          {@title}
        </h2>
      </header>
      <div
        class={[
          "modal__body modal__body--scroll-#{@scroll} -m-[3px] mt-2 mb-0 min-h-0 flex-1 overflow-visible p-[3px] text-sm leading-[1.43] text-muted",
          @scroll == "inside" &&
            "scrollbar overflow-y-auto overscroll-contain [-webkit-overflow-scrolling:touch]",
          @scroll == "outside" && "overflow-y-visible",
          @body_class
        ]}
        data-slot="modal-body"
      >
        <p :if={@description} id={"#{@id}-description"}>{@description}</p>
        {render_slot(@inner_block)}
      </div>
      <div
        class="modal__footer mt-5 flex flex-row items-center justify-end gap-2"
        data-slot="modal-footer"
      >
        {render_slot(@footer)}
        <%= if @close != [] do %>
          {render_slot(@close, %{"data-olis-dialog-close" => true})}
        <% else %>
          <button
            :if={@show_close}
            class={button_classes("tertiary", "md")}
            type="button"
            data-olis-dialog-close
          >{@close_label}</button>
        <% end %>
      </div>
      <button
        :if={@on_open_change}
        type="button"
        hidden
        data-olis-modal-event
        phx-click={@on_open_change}
        phx-target={@target}
      ></button>
    </dialog>
    """
  end

  @doc """
  A swipeable modal sheet. Open it with `data-olis-sheet-open={id}` and install
  the OlisUI Alpine providers. Supply `open` and `on_open_change` for
  server-controlled state, or use `default_open` for client-managed state.
  """
  attr(:id, :string, required: true)
  attr(:title, :string, required: true)
  attr(:description, :string, default: nil)
  attr(:placement, :string, default: "bottom", values: ~w(top bottom left right))
  attr(:backdrop, :string, default: "opaque", values: ~w(opaque blur transparent))
  attr(:dismissible, :boolean, default: true)
  attr(:detached, :boolean, default: false)
  attr(:handle, :boolean, default: true)
  attr(:snap_points, :list, default: [])
  attr(:open, :boolean, default: nil)
  attr(:default_open, :boolean, default: false)
  attr(:on_open_change, :any, default: nil)
  attr(:target, :any, default: nil)
  attr(:class, :any, default: nil)
  attr(:body_class, :any, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)
  slot(:footer)

  def sheet(assigns) do
    if Enum.any?(assigns.snap_points, &(not valid_sheet_snap_point?(&1))),
      do: raise(ArgumentError, "sheet snap points must be positive pixel numbers or CSS lengths")

    if Enum.any?(Enum.drop(assigns.snap_points, -1), &(&1 == "1")),
      do: raise(ArgumentError, "the unitless string snap point 1 may only appear last")

    if !is_nil(assigns.open) && assigns.default_open,
      do: raise(ArgumentError, "sheet cannot use open and default_open together")

    ~H"""
    <dialog
      id={@id}
      class={[
        "sheet__overlay z-50 data-[closed]:pointer-events-none",
        "fixed inset-0 m-0 hidden h-dvh max-h-none w-screen max-w-none border-0 bg-transparent p-0 outline-none open:flex [&:not([open])]:hidden",
        @placement == "bottom" && "items-end justify-center",
        @placement == "top" && "items-start justify-center",
        @placement == "left" && "items-center justify-start",
        @placement == "right" && "items-center justify-end",
        "backdrop:bg-transparent"
      ]}
      data-olis-sheet
      x-data="olisSheet"
      x-on:click.window="openFromTrigger($event)"
      x-on:click="click($event)"
      x-on:cancel="cancel($event)"
      x-on:close="close($event)"
      x-on:pointerdown="pointerdown($event)"
      x-on:pointermove="pointermove($event)"
      x-on:pointerup="pointerup($event)"
      x-on:pointercancel="pointercancel($event)"
      x-on:touchstart.passive="touchstart($event)"
      x-on:touchmove="touchmove($event)"
      x-on:touchend="touchend($event)"
      x-on:touchcancel="touchcancel($event)"
      x-on:resize.window="resize()"
      x-on:phx:update.window="sync()"
      data-slot="sheet-overlay"
      data-placement={@placement}
      data-dismissible={to_string(@dismissible)}
      data-snap-points-json={Jason.encode!(@snap_points)}
      data-controlled={to_string(!is_nil(@open))}
      data-controlled-open={if !is_nil(@open), do: to_string(@open)}
      data-default-open={to_string(@default_open)}
      aria-labelledby={"#{@id}-title"}
      aria-describedby={if @description, do: "#{@id}-description"}
      phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["open", "data-sheet-nested"])}
      {@rest}
    >
      <div
        class={[
          "sheet__backdrop sheet__backdrop--#{@backdrop} fixed inset-0 bg-transparent [@media(prefers-reduced-motion:reduce)]:[animation-duration:1ms]",
          @backdrop == "opaque" && "data-[stack-index='0']:bg-backdrop",
          @backdrop == "blur" &&
            "data-[stack-index='0']:bg-background/[0.01] data-[stack-index='0']:backdrop-blur-sm"
        ]}
        data-slot="sheet-backdrop"
        data-olis-sheet-backdrop
        data-stack-index="0"
        aria-hidden="true"
        phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["data-stack-index", "style"])}
      >
      </div>
      <div
        class={[
          "sheet__content sheet__content--#{@placement} relative z-1 box-content overflow-clip outline-none data-[has-descendants]:[transform:perspective(1000px)] data-[has-descendants]:will-change-transform [@media(prefers-reduced-motion:reduce)]:[animation-duration:1ms]",
          @placement in ["top", "bottom"] && !@detached && "w-full",
          @placement in ["top", "bottom"] && !@detached && @snap_points == [] &&
            "max-h-[calc(100%-2rem)]",
          @placement in ["top", "bottom"] && @detached && "m-2 w-[calc(100%-1rem)] rounded-[12px]",
          @placement in ["top", "bottom"] && @detached && @snap_points == [] &&
            "max-h-[calc(100%-1rem)]",
          @placement in ["top", "bottom"] && @snap_points != [] && "max-h-none",
          @placement in ["top", "bottom"] && @snap_points != [] && !@detached && "h-full",
          @placement in ["top", "bottom"] && @snap_points != [] && @detached && "h-[calc(100%-1rem)]",
          @placement == "bottom" && !@detached && "rounded-t-[12px]",
          @placement == "top" && !@detached && "rounded-b-[12px]",
          @placement in ["left", "right"] && !@detached && "h-full max-h-none",
          @placement in ["left", "right"] && @detached &&
            "m-2 h-[calc(100%-1rem)] max-h-[calc(100%-1rem)] rounded-[12px]",
          @placement in ["left", "right"] && @snap_points == [] && "w-[min(24rem,96vw)]",
          @placement in ["left", "right"] && @snap_points != [] && !@detached && "w-full max-w-none",
          @placement in ["left", "right"] && @snap_points != [] && @detached &&
            "w-[calc(100%-1rem)] max-w-none",
          @placement == "left" && !@detached && "rounded-r-[12px]",
          @placement == "right" && !@detached && "rounded-l-[12px]",
          @class
        ]}
        data-slot="sheet-content"
        data-olis-sheet-content
        data-placement={@placement}
        data-detached={if @detached, do: "true"}
        data-snap-points={if @snap_points != [], do: "true"}
        data-expanded={if @snap_points == [], do: "true"}
        phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["data-expanded", "style"])}
      >
        <section
          class={[
            "sheet__dialog sheet__dialog--#{@placement} relative flex min-h-0 flex-col overflow-hidden bg-overlay text-overlay-foreground shadow-overlay outline-none",
            @detached && "rounded-[12px]",
            !@detached && @placement == "bottom" && "rounded-t-[12px]",
            !@detached && @placement == "top" && "rounded-b-[12px]",
            !@detached && @placement == "left" && "rounded-r-[12px]",
            !@detached && @placement == "right" && "rounded-l-[12px]",
            "max-h-[inherit]",
            (@placement in ["left", "right"] || @snap_points != []) && "h-full"
          ]}
          data-slot="sheet-dialog"
        >
          <div
            :if={@handle}
            class="sheet__handle relative flex shrink-0 cursor-grab touch-none items-center justify-center py-3 select-none data-[dragging]:cursor-grabbing"
            data-slot="sheet-handle"
            data-olis-sheet-handle
            aria-hidden="true"
          >
            <span
              class="sheet__handle-bar block h-[0.3rem] w-8 rounded-full bg-default"
              data-slot="sheet-handle-bar"
            ></span>
          </div>
          <.close_button
            class="sheet__close-trigger absolute! top-3 right-3 z-10 cursor-(--cursor-interactive) text-muted outline-none no-highlight hover:text-foreground [@media(hover:hover)]:data-[hovered=true]:text-foreground"
            data-slot="sheet-close-trigger"
            data-olis-sheet-close
          />
          <header
            class="sheet__header flex shrink-0 flex-col gap-1 px-5 pt-4 pb-2"
            data-slot="sheet-header"
          >
            <h2
              id={"#{@id}-title"}
              class="sheet__heading text-lg font-[590]"
              data-slot="sheet-heading"
            >
              {@title}
            </h2>
          </header>
          <div
            class={[
              "sheet__body scrollbar min-h-0 flex-auto overflow-hidden px-5 py-2 [[data-slot=sheet-content][data-expanded]_&]:overflow-y-auto [[data-slot=sheet-content][data-expanded]_&]:[-webkit-overflow-scrolling:touch]",
              @body_class
            ]}
            data-slot="sheet-body"
            data-olis-sheet-body
          >
            <p :if={@description} id={"#{@id}-description"} class="text-sm text-muted">
              {@description}
            </p>
            {render_slot(@inner_block)}
          </div>
          <footer
            :if={@footer != []}
            class="sheet__footer flex shrink-0 items-center justify-end gap-2 px-5 pt-2 pb-4"
            data-slot="sheet-footer"
          >
            {render_slot(@footer)}
          </footer>
        </section>
      </div>
      <button
        :if={@on_open_change}
        type="button"
        hidden
        data-olis-sheet-event
        phx-click={@on_open_change}
        phx-target={@target}
      ></button>
    </dialog>
    """
  end

  defp valid_sheet_snap_point?(point) when is_number(point), do: point > 0
  defp valid_sheet_snap_point?("1"), do: true

  defp valid_sheet_snap_point?(point) when is_binary(point) do
    with true <- Regex.match?(~r/\A\d+(?:\.\d+)?(?:px|%|vh|vw|rem|em)\z/, point),
         {number, _} <- Float.parse(point),
         do: number > 0
  end

  defp valid_sheet_snap_point?(_), do: false

  @doc """
  A keyboard-accessible tab set. Use `selected_key` and `on_selection_change`
  for LiveView-controlled selection. Requires OlisUI's Alpine components.
  """
  attr(:id, :string, required: true)
  attr(:label, :string, required: true)
  attr(:selected, :string, default: nil)
  attr(:selected_key, :string, default: nil)
  attr(:default_selected_key, :string, default: nil)
  attr(:on_selection_change, :string, default: nil)
  attr(:target, :any, default: nil)
  attr(:variant, :string, default: "primary", values: ~w(primary secondary))
  attr(:orientation, :string, default: "horizontal", values: ~w(horizontal vertical))
  attr(:align, :string, default: "center", values: ~w(start center end))
  attr(:activation_mode, :string, default: "automatic", values: ~w(automatic manual))
  attr(:show_separators, :boolean, default: false)
  attr(:scroll_previous_label, :string, default: "Scroll tabs backward")
  attr(:scroll_next_label, :string, default: "Scroll tabs forward")
  attr(:class, :any, default: nil)

  slot :tab, required: true do
    attr(:id, :string, required: true)
    attr(:label, :string, required: true)
    attr(:disabled, :boolean)
    attr(:class, :any)
  end

  def tabs(assigns) do
    enabled = Enum.reject(assigns.tab, &Map.get(&1, :disabled, false))
    ids = Enum.map(assigns.tab, & &1.id)

    if enabled == [] or Enum.any?(ids, &(not is_binary(&1) or &1 == "")) or
         length(ids) != length(Enum.uniq(ids)),
       do: raise(ArgumentError, "tabs require distinct ids and at least one enabled tab")

    if assigns.selected && assigns.default_selected_key,
      do:
        raise(ArgumentError, "use either selected or default_selected_key for initial selection")

    if assigns.selected_key && (assigns.selected || assigns.default_selected_key),
      do: raise(ArgumentError, "selected_key cannot be combined with an initial selection")

    selected =
      assigns.selected_key || assigns.default_selected_key || assigns.selected || hd(enabled).id

    if not Enum.any?(enabled, &(&1.id == selected)),
      do: raise(ArgumentError, "selected tab must exist and be enabled")

    assigns = assign(assigns, :selected_id, selected)

    ~H"""
    <div
      id={@id}
      class={[
        "tabs tabs--#{@variant} flex gap-2",
        @orientation == "horizontal" && "flex-col",
        @orientation == "vertical" && "flex-row",
        @align != "center" && "tabs--align-#{@align}",
        @class
      ]}
      data-slot="tabs"
      data-orientation={@orientation}
      data-olis-tabs
      data-initial-key={@selected_id}
      data-selected-key={@selected_key}
      data-controlled={to_string(!is_nil(@selected_key))}
      data-activation-mode={@activation_mode}
      x-data="olisTabs"
      x-on:phx:update.window="sync()"
    >
      <div
        class={[
          "tabs__list-container relative min-w-0 max-w-full has-[>[data-left-scroll=true]]:[&>[data-slot=tabs-scroll-prev]]:inline-flex has-[>[data-left-right-scroll=true]]:[&>[data-slot=tabs-scroll-prev]]:inline-flex has-[>[data-top-scroll=true]]:[&>[data-slot=tabs-scroll-prev]]:inline-flex has-[>[data-top-bottom-scroll=true]]:[&>[data-slot=tabs-scroll-prev]]:inline-flex has-[>[data-right-scroll=true]]:[&>[data-slot=tabs-scroll-next]]:inline-flex has-[>[data-left-right-scroll=true]]:[&>[data-slot=tabs-scroll-next]]:inline-flex has-[>[data-bottom-scroll=true]]:[&>[data-slot=tabs-scroll-next]]:inline-flex has-[>[data-top-bottom-scroll=true]]:[&>[data-slot=tabs-scroll-next]]:inline-flex",
          @variant == "primary" && "rounded-[6px] bg-default",
          @variant == "secondary" && @orientation == "horizontal" &&
            "rounded-none border-b border-border bg-transparent",
          @variant == "secondary" && @orientation == "vertical" &&
            "rounded-none border-s border-border bg-transparent"
        ]}
        data-slot="tabs-list-container"
      >
        <div
          class={[
            "scroll-shadow relative scrollbar-none",
            @orientation == "horizontal" && "overflow-x-auto",
            @orientation == "vertical" && "overflow-y-auto",
            "scroll-shadow--hide-scrollbar",
            "scroll-shadow--#{@orientation}",
            "scroll-shadow--fade",
            "tabs__list-container__scroller",
            "max-w-full",
            @orientation == "vertical" && "h-full",
            "[--scroll-shadow-size:64px]"
          ]}
          data-orientation={@orientation}
          data-scroll-shadow-mode="auto"
          x-ref="scroller"
          x-on:scroll="updateScroll()"
          x-bind:data-left-scroll="$el.dataset.orientation === 'horizontal' && before && !after ? 'true' : null"
          x-bind:data-right-scroll="$el.dataset.orientation === 'horizontal' && !before && after ? 'true' : null"
          x-bind:data-left-right-scroll="$el.dataset.orientation === 'horizontal' && before && after ? 'true' : null"
          x-bind:data-top-scroll="$el.dataset.orientation === 'vertical' && before && !after ? 'true' : null"
          x-bind:data-bottom-scroll="$el.dataset.orientation === 'vertical' && !before && after ? 'true' : null"
          x-bind:data-top-bottom-scroll="$el.dataset.orientation === 'vertical' && before && after ? 'true' : null"
          phx-mounted={
            Phoenix.LiveView.JS.ignore_attributes([
              "data-left-scroll",
              "data-right-scroll",
              "data-left-right-scroll",
              "data-top-scroll",
              "data-bottom-scroll",
              "data-top-bottom-scroll"
            ])
          }
        >
          <div
            class={[
              "tabs__list inline-flex",
              @variant == "primary" && "p-1",
              @variant == "secondary" && "p-0",
              @orientation == "horizontal" && "w-max min-w-full flex-row",
              @orientation == "vertical" && "flex-col gap-1"
            ]}
            role="tablist"
            data-slot="tabs-list"
            aria-label={@label}
            aria-orientation={@orientation}
            data-orientation={@orientation}
            x-ref="list"
            x-on:keydown="keydown($event)"
            x-on:focusout="leave($event)"
          >
            <button
              :for={{tab, index} <- Enum.with_index(@tab)}
              id={"#{@id}-tab-#{tab.id}"}
              type="button"
              role="tab"
              class={[
                "tabs__tab relative z-1 flex h-8 w-full items-center px-4 text-sm font-medium whitespace-nowrap text-muted outline-none no-highlight cursor-(--cursor-interactive) [transition:color_150ms_var(--ease-smooth),background-color_150ms_var(--ease-smooth),box-shadow_150ms_var(--ease-out),opacity_150ms_var(--ease-smooth)] disabled:status-disabled data-[disabled=true]:status-disabled aria-disabled:status-disabled [&:focus-visible:not([data-focused])]:status-focused data-[focus-visible=true]:status-focused [@media(hover:hover)]:[&:not([data-selected=true]):not([data-disabled=true]):hover]:opacity-70 [@media(hover:hover)]:[&[data-hovered=true]:not([data-selected=true]):not([data-disabled=true])]:opacity-70",
                @align == "center" && "justify-center text-center",
                @align == "start" && "justify-start text-start",
                @align == "end" && "justify-end text-end",
                @orientation == "vertical" && "min-w-20",
                @variant == "primary" && "rounded-[6px] data-[selected=true]:text-segment-foreground",
                @variant == "secondary" && "rounded-none data-[selected=true]:text-foreground",
                Map.get(tab, :class)
              ]}
              data-slot="tabs-tab"
              data-key={tab.id}
              data-selected={to_string(tab.id == @selected_id)}
              aria-selected={to_string(tab.id == @selected_id)}
              aria-controls={"#{@id}-panel-#{tab.id}"}
              tabindex={if tab.id == @selected_id, do: "0", else: "-1"}
              disabled={Map.get(tab, :disabled, false)}
              data-disabled={if Map.get(tab, :disabled, false), do: "true"}
              x-bind:data-selected="(selected === $el.dataset.key).toString()"
              x-bind:aria-selected="(selected === $el.dataset.key).toString()"
              x-bind:tabindex="focused === $el.dataset.key ? 0 : -1"
              x-on:click="select($el.dataset.key)"
              phx-mounted={
                Phoenix.LiveView.JS.ignore_attributes(["aria-selected", "data-selected", "tabindex"])
              }
            >
              <span
                :if={@show_separators && index > 0}
                class={[
                  "tabs__separator pointer-events-none absolute rounded-sm bg-muted/25 transition-opacity duration-150 ease-(--ease-smooth) [[data-slot=tabs-tab][data-selected=true]_&]:opacity-0 [[data-slot=tabs-tab][data-selected=true]+[data-slot=tabs-tab]_&]:opacity-0",
                  @variant == "secondary" && "hidden",
                  @orientation == "horizontal" && "start-0 top-1/4 h-1/2 w-px",
                  @orientation == "vertical" && "start-[5%] top-0 h-px w-[90%]"
                ]}
                data-slot="tabs-separator"
                aria-hidden="true"
              ></span>
              {tab.label}<span
                class={[
                  "tabs__indicator absolute start-0 -z-1 [transition-property:translate,width,height] duration-250 ease-(--ease-out-fluid) data-[animation-ready=false]:transition-none [[data-slot=tabs-tab]:not([data-selected=true])_&]:hidden",
                  @variant == "primary" && "top-0 size-full rounded-[6px] bg-segment shadow-surface",
                  @variant == "secondary" && @orientation == "horizontal" &&
                    "bottom-0 h-0.5 w-full rounded-none bg-accent shadow-none",
                  @variant == "secondary" && @orientation == "vertical" &&
                    "top-0 h-full w-0.5 rounded-none bg-accent shadow-none"
                ]}
                data-slot="tabs-indicator"
                aria-hidden="true"
              ></span>
            </button>
          </div>
        </div>
        <button
          type="button"
          class={[
            "tabs__list-container__scroll-prev absolute z-2 hidden size-4 cursor-(--cursor-interactive) items-center justify-center rounded-full border-0 bg-transparent p-0 text-foreground outline-none transition-opacity duration-150 ease-(--ease-smooth) hover:opacity-70 focus-visible:status-focused",
            @orientation == "horizontal" && "start-1 top-1/2 -translate-y-1/2 rtl:rotate-180",
            @orientation == "vertical" && "top-1 left-1/2 -translate-x-1/2"
          ]}
          aria-label={@scroll_previous_label}
          data-slot="tabs-scroll-prev"
          tabindex="-1"
          x-on:click="scroll('previous')"
        ><svg aria-hidden="true" viewBox="0 0 16 16" fill="none"><path
          d="M10.53 2.97a.75.75 0 0 1 0 1.06L6.56 8l3.97 3.97a.75.75 0 1 1-1.06 1.06l-4.5-4.5a.75.75 0 0 1 0-1.06l4.5-4.5a.75.75 0 0 1 1.06 0"
          fill="currentColor"
        /></svg></button>
        <button
          type="button"
          class={[
            "tabs__list-container__scroll-next absolute z-2 hidden size-4 cursor-(--cursor-interactive) items-center justify-center rounded-full border-0 bg-transparent p-0 text-foreground outline-none transition-opacity duration-150 ease-(--ease-smooth) hover:opacity-70 focus-visible:status-focused",
            @orientation == "horizontal" && "end-1 top-1/2 -translate-y-1/2 rtl:rotate-180",
            @orientation == "vertical" && "bottom-1 left-1/2 -translate-x-1/2"
          ]}
          aria-label={@scroll_next_label}
          data-slot="tabs-scroll-next"
          tabindex="-1"
          x-on:click="scroll('next')"
        ><svg aria-hidden="true" viewBox="0 0 16 16" fill="none"><path
          d="M5.47 2.97a.75.75 0 0 1 1.06 0l4.5 4.5a.75.75 0 0 1 0 1.06l-4.5 4.5a.75.75 0 1 1-1.06-1.06L9.44 8 5.47 4.03a.75.75 0 0 1 0-1.06Z"
          fill="currentColor"
        /></svg></button>
      </div>
      <div
        :for={tab <- @tab}
        id={"#{@id}-panel-#{tab.id}"}
        role="tabpanel"
        class={[
          "tabs__panel w-full p-2 outline-none data-[exiting=true]:absolute data-[exiting=true]:start-0 data-[exiting=true]:top-0 data-[exiting=true]:w-full",
          @orientation == "horizontal" && "mt-4",
          @orientation == "vertical" && "ms-4"
        ]}
        data-slot="tabs-panel"
        data-key={tab.id}
        data-orientation={@orientation}
        aria-labelledby={"#{@id}-tab-#{tab.id}"}
        hidden={tab.id != @selected_id}
        x-bind:hidden="selected !== $el.dataset.key"
        tabindex="0"
        phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["hidden"])}
      >
        {render_slot(tab)}
      </div>
      <button
        :if={@on_selection_change}
        type="button"
        hidden
        x-ref="changeEvent"
        phx-click={@on_selection_change}
        phx-target={@target}
      ></button>
    </div>
    """
  end

  @doc """
  An action or selection menu with sections and nested submenus.
  Register OlisUI's Alpine providers and use a browser with the Popover API.
  """
  attr(:id, :string, required: true)
  attr(:label, :string, required: true)

  attr(:variant, :string,
    default: "secondary",
    values: ~w(primary secondary tertiary outline ghost danger danger-soft)
  )

  attr(:selection_mode, :string, default: "none", values: ~w(none single multiple))
  attr(:selected_keys, :list, default: nil)
  attr(:default_selected_keys, :list, default: [])
  attr(:on_selection_change, :string, default: nil)
  attr(:on_action, :string, default: nil)
  attr(:target, :any, default: nil)
  attr(:close_on_select, :boolean, default: nil)
  attr(:disabled, :boolean, default: false)
  attr(:class, :any, default: nil)

  slot :item do
    attr(:label, :string, required: true)
    attr(:key, :string)
    attr(:on_click, :any)
    attr(:href, :string)
    attr(:description, :string)
    attr(:shortcut, :string)
    attr(:disabled, :boolean)
    attr(:danger, :boolean)
    attr(:items, :list)
    attr(:selection_mode, :string)
    attr(:selected_keys, :list)
    attr(:default_selected_keys, :list)
    attr(:on_selection_change, :string)
    attr(:close_on_select, :boolean)
  end

  slot :section do
    attr(:label, :string, required: true)
    attr(:items, :list, required: true)
    attr(:selection_mode, :string)
    attr(:selected_keys, :list)
    attr(:default_selected_keys, :list)
    attr(:on_selection_change, :string)
    attr(:close_on_select, :boolean)
  end

  def dropdown(assigns) do
    if assigns.item == [] && assigns.section == [],
      do: raise(ArgumentError, "dropdown requires at least one item or section")

    ~H"""
    <div
      id={@id}
      class={["dropdown olis-dropdown inline-flex flex-col gap-1", @class]}
      data-olis-dropdown
      x-data="olisDropdown"
      x-on:click.capture="click($event)"
      x-on:keydown="keydown($event)"
      x-on:toggle.capture="toggle($event)"
      x-on:focusout="focusout($event)"
      x-on:pointerover="pointerover($event)"
      x-on:pointerout="pointerout($event)"
      x-on:pointermove="pointermove($event)"
      x-on:resize.window="reposition()"
      x-on:scroll.window.capture="reposition()"
      x-on:phx:update.document="reposition()"
    >
      <button
        type="button"
        class={[
          button_classes(@variant, "md"),
          "dropdown__trigger inline-block! [transition:transform_250ms_var(--ease-out-quart),background-color_150ms_var(--ease-smooth),box-shadow_150ms_var(--ease-out)]! active:[transform:scale(.97)]! data-[pressed=true]:[transform:scale(.97)]!"
        ]}
        data-olis-dropdown-trigger
        popovertarget={"#{@id}-menu"}
        aria-haspopup="menu"
        aria-controls={"#{@id}-menu"}
        aria-expanded="false"
        disabled={@disabled}
        phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["aria-expanded"])}
      >{@label}</button>
      <div
        id={"#{@id}-menu"}
        popover="auto"
        class={dropdown_popover_classes()}
        data-olis-dropdown-menu
        aria-label={@label}
        role="menu"
        phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["style"])}
      >
        <div
          class="dropdown__menu relative flex w-full flex-col gap-0.5 overflow-clip p-1.5 outline-none [&_[data-slot=separator]]:ms-[3%] [&_[data-slot=separator]]:w-[94%]"
          data-slot="dropdown-menu"
          data-selection-mode={@selection_mode}
        >
          <.dropdown_group
            :if={@item != []}
            id={"#{@id}-root"}
            entries={@item}
            mode={@selection_mode}
            selected_keys={@selected_keys}
            default_selected_keys={@default_selected_keys}
            on_selection_change={@on_selection_change}
            on_action={@on_action}
            target={@target}
            close_on_select={@close_on_select}
          />
          <%= for {section, index} <- Enum.with_index(@section) do %>
            <.separator :if={@item != [] || index > 0} />
            <.dropdown_group
              id={"#{@id}-section-#{index}"}
              label={section.label}
              entries={section.items}
              mode={Map.get(section, :selection_mode) || @selection_mode}
              selected_keys={Map.get(section, :selected_keys, @selected_keys)}
              default_selected_keys={Map.get(section, :default_selected_keys, @default_selected_keys)}
              on_selection_change={Map.get(section, :on_selection_change) || @on_selection_change}
              on_action={@on_action}
              target={@target}
              close_on_select={Map.get(section, :close_on_select, @close_on_select)}
            />
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  attr(:id, :string, required: true)
  attr(:label, :string, default: nil)
  attr(:entries, :list, required: true)
  attr(:mode, :string, required: true)
  attr(:selected_keys, :list, default: nil)
  attr(:default_selected_keys, :list, default: [])
  attr(:on_selection_change, :string, default: nil)
  attr(:on_action, :string, default: nil)
  attr(:target, :any, default: nil)
  attr(:close_on_select, :boolean, default: nil)

  defp dropdown_group(assigns) do
    unless assigns.mode in ~w(none single multiple),
      do: raise(ArgumentError, "invalid dropdown selection mode")

    keys =
      assigns.entries
      |> Enum.reject(&is_list(Map.get(&1, :items)))
      |> Enum.map(&Map.get(&1, :key))

    if assigns.mode != "none" &&
         (Enum.any?(keys, &(not is_binary(&1) || &1 == "")) ||
            length(keys) != length(Enum.uniq(keys))),
       do: raise(ArgumentError, "selectable dropdown items require unique nonempty string keys")

    selected = assigns.selected_keys || assigns.default_selected_keys || []

    if assigns.mode == "single" && length(Enum.uniq(selected)) > 1,
      do: raise(ArgumentError, "single-selection dropdown groups allow at most one selected key")

    assigns =
      assign(assigns, selected: MapSet.new(selected), controlled: !is_nil(assigns.selected_keys))

    ~H"""
    <div
      class={@label && "menu-section flex flex-col items-start gap-0"}
      role={if @label, do: "group"}
      aria-label={@label}
      data-olis-dropdown-group
      data-selection-mode={@mode}
      data-controlled={to_string(@controlled)}
      data-close-on-select={
        to_string(if is_nil(@close_on_select), do: @mode != "multiple", else: @close_on_select)
      }
    >
      <div
        :if={@label}
        class="header w-full px-2 pt-1.5 pb-1 text-start text-xs font-medium text-muted"
        data-slot="header"
        aria-hidden="true"
      >
        {@label}
      </div>
      <.dropdown_entry
        :for={{entry, index} <- Enum.with_index(@entries)}
        entry={entry}
        id={"#{@id}-#{index}"}
        mode={@mode}
        selected={@selected}
        controlled={@controlled}
        on_action={@on_action}
        target={@target}
      />
      <button
        :if={@on_selection_change && @mode != "none"}
        type="button"
        hidden
        data-olis-dropdown-selection-event
        phx-click={@on_selection_change}
        phx-target={@target}
      ></button>
    </div>
    """
  end

  attr(:entry, :map, required: true)
  attr(:id, :string, required: true)
  attr(:mode, :string, required: true)
  attr(:selected, :any, required: true)
  attr(:controlled, :boolean, required: true)
  attr(:on_action, :string, default: nil)
  attr(:target, :any, default: nil)

  defp dropdown_entry(assigns) do
    entry = assigns.entry

    if !is_binary(Map.get(entry, :label)) || entry.label == "",
      do: raise(ArgumentError, "dropdown items require a label")

    submenu = Map.get(entry, :items)

    if !is_nil(submenu) && (!is_list(submenu) || submenu == []),
      do: raise(ArgumentError, "dropdown submenus require a nonempty items list")

    checked = MapSet.member?(assigns.selected, Map.get(entry, :key))

    assigns =
      assign(assigns,
        submenu: submenu,
        checked: checked,
        role:
          case assigns.mode do
            "single" -> "menuitemradio"
            "multiple" -> "menuitemcheckbox"
            _ -> "menuitem"
          end
      )

    ~H"""
    <div :if={@submenu} class="w-full" role="none" data-olis-dropdown-submenu-root>
      <button
        id={@id}
        type="button"
        role="menuitem"
        tabindex="-1"
        class={[menu_item_classes(), "menu-item--default"]}
        data-slot="menu-item"
        data-olis-dropdown-item
        data-olis-dropdown-submenu-trigger
        data-has-submenu="true"
        disabled={Map.get(@entry, :disabled, false)}
        data-disabled={if Map.get(@entry, :disabled, false), do: "true"}
        aria-label={@entry.label}
        aria-haspopup="menu"
        aria-expanded="false"
        aria-controls={"#{@id}-submenu"}
        phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["aria-expanded"])}
      >
        <.dropdown_item_content entry={@entry} mode="none" checked={false} controlled={true} />
        <span
          class={[
            menu_indicator_classes(),
            "menu-item__indicator--submenu text-muted [.menu-item[data-has-submenu=true]_&]:start-auto [.menu-item[data-has-submenu=true]_&]:end-2 [&_svg]:size-3"
          ]}
          data-slot="submenu-indicator"
          aria-hidden="true"
        ><svg class="rtl:rotate-180" viewBox="0 0 16 16" fill="none"><path
          d="m6 3.5 4.5 4.5L6 12.5"
          stroke="currentColor"
          stroke-width="1.5"
          stroke-linecap="round"
          stroke-linejoin="round"
        /></svg></span>
      </button>
      <div
        id={"#{@id}-submenu"}
        popover="auto"
        role="menu"
        aria-label={@entry.label}
        class={dropdown_popover_classes()}
        data-olis-dropdown-menu
        data-olis-dropdown-submenu
        phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["style"])}
      >
        <div
          class="dropdown__menu relative flex w-full flex-col gap-0.5 overflow-clip p-1.5 outline-none [&_[data-slot=separator]]:ms-[3%] [&_[data-slot=separator]]:w-[94%]"
          data-slot="dropdown-menu"
        >
          <.dropdown_group
            id={"#{@id}-nested"}
            entries={@submenu}
            mode={Map.get(@entry, :selection_mode, "none")}
            selected_keys={Map.get(@entry, :selected_keys)}
            default_selected_keys={Map.get(@entry, :default_selected_keys, [])}
            on_selection_change={Map.get(@entry, :on_selection_change)}
            on_action={@on_action}
            target={@target}
            close_on_select={Map.get(@entry, :close_on_select)}
          />
        </div>
      </div>
    </div>
    <a
      :if={!@submenu && Map.get(@entry, :href) && !Map.get(@entry, :disabled, false)}
      id={@id}
      href={@entry.href}
      role={@role}
      aria-label={@entry.label}
      aria-checked={if @mode != "none", do: to_string(@checked)}
      tabindex="-1"
      class={[
        menu_item_classes(),
        "menu-item--default",
        Map.get(@entry, :danger, false) && "menu-item--danger"
      ]}
      data-slot="menu-item"
      data-olis-dropdown-item
      data-key={Map.get(@entry, :key)}
      data-selected={if @mode != "none", do: to_string(@checked)}
      data-selection-mode={if @mode != "none", do: @mode}
      phx-mounted={
        if @mode != "none" && !@controlled,
          do: Phoenix.LiveView.JS.ignore_attributes(["aria-checked", "data-selected"])
      }
    >
      <.dropdown_item_content entry={@entry} mode={@mode} checked={@checked} controlled={@controlled} />
    </a>
    <button
      :if={!@submenu && (!Map.get(@entry, :href) || Map.get(@entry, :disabled, false))}
      id={@id}
      type="button"
      role={@role}
      tabindex="-1"
      disabled={Map.get(@entry, :disabled, false)}
      data-disabled={if Map.get(@entry, :disabled, false), do: "true"}
      aria-label={@entry.label}
      aria-checked={if @mode != "none", do: to_string(@checked)}
      data-selected={if @mode != "none", do: to_string(@checked)}
      data-selection-mode={if @mode != "none", do: @mode}
      data-key={Map.get(@entry, :key)}
      data-slot="menu-item"
      data-olis-dropdown-item
      phx-click={Map.get(@entry, :on_click) || @on_action}
      phx-value-key={Map.get(@entry, :key)}
      phx-target={@target}
      phx-mounted={
        if @mode != "none" && !@controlled,
          do: Phoenix.LiveView.JS.ignore_attributes(["aria-checked", "data-selected"])
      }
      class={[
        menu_item_classes(),
        "menu-item--default",
        Map.get(@entry, :danger, false) && "menu-item--danger"
      ]}
    >
      <.dropdown_item_content entry={@entry} mode={@mode} checked={@checked} controlled={@controlled} />
    </button>
    """
  end

  attr(:entry, :map, required: true)
  attr(:mode, :string, required: true)
  attr(:checked, :boolean, required: true)
  attr(:controlled, :boolean, required: true)

  defp dropdown_item_content(assigns) do
    ~H"""
    <span :if={@mode != "none"} class={menu_indicator_classes()} aria-hidden="true">
      <svg
        data-slot="menu-item-indicator--checkmark"
        viewBox="0 0 16 16"
        fill="none"
        class={if !@checked, do: "invisible"}
        phx-mounted={if !@controlled, do: Phoenix.LiveView.JS.ignore_attributes(["class"])}
      ><path
        d="M3.5 8l3 3 6-6"
        stroke="currentColor"
        stroke-width="2"
        stroke-linecap="round"
        stroke-linejoin="round"
      /></svg>
    </span>
    <span class="flex min-w-0 flex-1 flex-col items-start">
      <span data-slot="label">{@entry.label}</span>
      <span
        :if={Map.get(@entry, :description)}
        class="description text-xs text-wrap wrap-break-word text-muted"
        data-slot="description"
      >{Map.get(
        @entry,
        :description
      )}</span>
    </span>
    <kbd
      :if={Map.get(@entry, :shortcut)}
      class="kbd [&.kbd--light]:bg-transparent inline-flex h-6 items-center space-x-0.5 rounded-lg bg-default px-2 text-center font-sans text-sm font-medium whitespace-nowrap text-muted rtl:space-x-reverse [word-spacing:-0.25rem] ml-auto"
      data-slot="keyboard"
    >{Map.get(
      @entry,
      :shortcut
    )}</kbd>
    """
  end

  @doc """
  An alert dialog for decisions that require an explicit response.
  Open it with `data-olis-dialog-open` and install the OlisUI Alpine providers.
  The cancel action receives initial focus; confirmation sends `on_confirm` to LiveView.
  """
  attr(:id, :string, required: true)
  attr(:title, :string, required: true)
  attr(:on_confirm, :any, required: true)
  attr(:confirm_label, :string, default: "Confirm")
  attr(:cancel_label, :string, default: "Cancel")
  attr(:size, :string, default: "md", values: ~w(xs sm md lg))

  attr(:confirm_variant, :string,
    default: "danger",
    values: ~w(primary secondary tertiary outline ghost danger danger-soft)
  )

  attr(:class, :any, default: nil)
  slot(:inner_block, required: true)

  def alert_dialog(assigns) do
    ~H"""
    <dialog
      id={@id}
      role="alertdialog"
      aria-labelledby={"#{@id}-title"}
      aria-describedby={"#{@id}-description"}
      class={[
        "alert-dialog__dialog alert-dialog__dialog--#{@size} olis-native-modal fixed inset-0 m-auto flex min-h-0 max-h-[calc(100dvh-2rem)] w-[calc(100%-2rem)] flex-col overflow-auto rounded-[12px] border-0 bg-overlay p-6 text-foreground shadow-overlay outline-none pointer-events-auto backdrop:bg-backdrop [&:not([open])]:hidden",
        @size == "xs" && "max-w-xs",
        @size == "sm" && "max-w-sm",
        @size == "md" && "max-w-md",
        @size == "lg" && "max-w-lg",
        @class
      ]}
      data-olis-dialog
      x-data="olisDialog"
      x-on:click.window="openFromTrigger($event)"
      x-on:click="onClick($event)"
      x-on:cancel="onCancel($event)"
      data-dismissible="false"
      phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["open"])}
    >
      <header class="alert-dialog__header mb-0 flex flex-col gap-3 [&>.modal__icon]:mb-0">
        <h2
          id={"#{@id}-title"}
          class="alert-dialog__heading align-middle text-base font-medium text-foreground"
        >
          {@title}
        </h2>
      </header>
      <div
        id={"#{@id}-description"}
        class="alert-dialog__body scrollbar -m-[3px] mt-2 mb-0 min-h-0 flex-1 overflow-y-auto overscroll-contain p-[3px] text-sm leading-[1.43] text-muted [-webkit-overflow-scrolling:touch]"
      >
        {render_slot(@inner_block)}
      </div>
      <div class="alert-dialog__footer mt-5 flex flex-row items-center justify-end gap-2">
        <button
          type="button"
          class={button_classes("tertiary", "md")}
          data-olis-dialog-close
          autofocus
        >{@cancel_label}</button>
        <button
          type="button"
          class={button_classes(@confirm_variant, "md")}
          phx-click={@on_confirm}
          data-olis-dialog-close
        >{@confirm_label}</button>
      </div>
    </dialog>
    """
  end

  @doc """
  A modal drawer attached to an edge of the viewport.
  Open it with `data-olis-dialog-open={id}`. Requires OlisUI's Alpine providers.
  The backdrop can be `opaque` (default), `blur`, or `transparent`.
  Use `default_open` for initial client state or `open` and `on_open_change`
  for LiveView-controlled state. A `:close` slot can replace the default control.
  """
  attr(:id, :string, required: true)
  attr(:title, :string, required: true)
  attr(:placement, :string, default: "bottom", values: ~w(top bottom left right))
  attr(:dismissible, :boolean, default: true)
  attr(:backdrop, :string, default: "opaque", values: ~w(opaque blur transparent))
  attr(:open, :boolean, default: nil)
  attr(:default_open, :boolean, default: false)
  attr(:on_open_change, :any, default: nil)
  attr(:target, :any, default: nil)
  attr(:show_close, :boolean, default: true)
  attr(:close_label, :string, default: "Close")
  attr(:show_handle, :boolean, default: false)
  attr(:class, :any, default: nil)
  slot(:inner_block, required: true)
  slot(:footer)
  slot(:close)

  def drawer(assigns) do
    if !is_nil(assigns.open) && assigns.default_open,
      do: raise(ArgumentError, "drawer cannot use open and default_open together")

    ~H"""
    <dialog
      id={@id}
      aria-labelledby={"#{@id}-title"}
      class={[
        "drawer__dialog fixed m-0 flex max-h-dvh flex-col overflow-auto border-0 bg-overlay p-6 text-foreground shadow-overlay outline-none pointer-events-auto will-change-[translate] [&:not([open])]:hidden",
        @placement == "bottom" &&
          "inset-x-0 bottom-0 top-auto w-full max-h-[85dvh] [border-start-start-radius:12px] [border-start-end-radius:12px]",
        @placement == "top" &&
          "inset-x-0 top-0 bottom-auto w-full max-h-[85dvh] [border-end-start-radius:12px] [border-end-end-radius:12px]",
        @placement == "left" &&
          "inset-y-0 left-0 right-auto h-dvh w-[min(24rem,85vw)] rounded-none max-sm:w-[min(20rem,85vw)]",
        @placement == "right" &&
          "inset-y-0 right-0 left-auto h-dvh w-[min(24rem,85vw)] rounded-none max-sm:w-[min(20rem,85vw)]",
        "olis-native-modal",
        "olis-native-drawer",
        @backdrop == "opaque" && "backdrop:bg-backdrop",
        @backdrop == "blur" && "backdrop:bg-backdrop backdrop:backdrop-blur-md",
        @backdrop == "transparent" && "backdrop:bg-transparent",
        @class
      ]}
      data-placement={@placement}
      data-backdrop={@backdrop}
      data-olis-drawer
      data-slot="drawer-dialog"
      x-data="olisDrawer"
      x-on:click.window="openFromTrigger($event)"
      x-on:click="onClick($event)"
      x-on:cancel.prevent="onCancel()"
      x-on:close="onNativeClose($event)"
      x-on:phx:update.window="sync()"
      x-on:pointerdown="pointerDown($event)"
      x-on:pointermove="pointerMove($event)"
      x-on:pointerup="pointerUp($event)"
      x-on:pointercancel="pointerCancel($event)"
      x-on:lostpointercapture="lostPointerCapture($event)"
      data-dismissible={to_string(@dismissible)}
      data-controlled={to_string(!is_nil(@open))}
      data-controlled-open={if !is_nil(@open), do: to_string(@open)}
      data-default-open={to_string(@default_open)}
      phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["open", "style"])}
    >
      <div
        :if={@show_handle}
        class={[
          "drawer__handle flex items-center justify-center pb-2 [&>[data-slot=drawer-handle-bar]]:h-1 [&>[data-slot=drawer-handle-bar]]:w-9 [&>[data-slot=drawer-handle-bar]]:rounded-xs [&>[data-slot=drawer-handle-bar]]:bg-separator",
          if(@placement in ["top", "bottom"], do: "touch-pan-x", else: "touch-pan-y")
        ]}
        data-slot="drawer-handle"
        data-olis-drawer-drag
        aria-hidden="true"
      >
        <span data-slot="drawer-handle-bar"></span>
      </div>
      <header
        class={[
          "drawer__header mb-0 flex flex-col gap-3",
          if(@placement in ["top", "bottom"], do: "touch-pan-x", else: "touch-pan-y")
        ]}
        data-slot="drawer-header"
        data-olis-drawer-drag
      >
        <h2
          id={"#{@id}-title"}
          class="drawer__heading align-middle text-base font-medium text-foreground"
          data-slot="drawer-heading"
        >
          {@title}
        </h2>
      </header>
      <div
        class="drawer__body scrollbar -m-[3px] mt-2 mb-0 min-h-0 flex-1 overflow-y-auto overscroll-contain p-[3px] text-sm leading-[1.43] text-muted [-webkit-overflow-scrolling:touch]"
        data-slot="drawer-body"
      >
        {render_slot(@inner_block)}
      </div>
      <div
        class={[
          "drawer__footer mt-5 flex flex-row items-center justify-end gap-2",
          if(@placement in ["top", "bottom"], do: "touch-pan-x", else: "touch-pan-y")
        ]}
        data-slot="drawer-footer"
        data-olis-drawer-drag
      >
        {render_slot(@footer)}
        <%= if @close != [] do %>
          {render_slot(@close, %{"data-olis-dialog-close" => true})}
        <% else %>
          <button
            :if={@show_close}
            type="button"
            class={button_classes("tertiary", "md")}
            data-olis-dialog-close
          >{@close_label}</button>
        <% end %>
      </div>
      <button
        :if={@on_open_change}
        type="button"
        hidden
        data-olis-drawer-event
        phx-click={@on_open_change}
        phx-target={@target}
      ></button>
    </dialog>
    """
  end

  @doc """
  A noninteractive description shown on focus or hover. Requires OlisUI's Alpine providers.
  The default slot labels a built-in button. Use `:trigger` to provide an existing
  interactive element and `:content` for rich, noninteractive inline content.
  """
  attr(:id, :string, required: true)
  attr(:text, :string, default: nil)
  attr(:placement, :string, default: "top", values: ~w(top bottom left right))
  attr(:delay, :integer, default: nil)
  attr(:close_delay, :integer, default: nil)
  attr(:offset, :integer, default: nil)
  attr(:show_arrow, :boolean, default: false)
  attr(:class, :any, default: nil)
  attr(:trigger_class, :any, default: nil)
  slot(:inner_block)
  slot(:trigger)
  slot(:content)

  def tooltip(assigns) do
    if (is_nil(assigns.text) && assigns.content == []) ||
         (!is_nil(assigns.text) && assigns.content != []),
       do: raise(ArgumentError, "tooltip requires either text or a content slot")

    if assigns.inner_block == [] && assigns.trigger == [],
      do: raise(ArgumentError, "tooltip requires a default slot or a trigger slot")

    if assigns.delay && assigns.delay < 0,
      do: raise(ArgumentError, "tooltip delay must be nonnegative")

    if assigns.close_delay && assigns.close_delay < 0,
      do: raise(ArgumentError, "tooltip close delay must be nonnegative")

    assigns =
      assign(assigns, :resolved_offset, assigns.offset || if(assigns.show_arrow, do: 7, else: 3))

    ~H"""
    <span
      class={["olis-tooltip-root inline-block", @class]}
      data-olis-tooltip-root
      data-delay={@delay}
      data-close-delay={@close_delay}
      data-requested-placement={@placement}
      data-offset={@resolved_offset}
      x-data="olisTooltip"
      x-on:pointerenter="enter($event)"
      x-on:pointerleave="leave($event)"
      x-on:focusin="focus()"
      x-on:focusout="blur($event)"
      x-on:keydown.escape.window="escape()"
      x-on:resize.window="position()"
      x-on:scroll.window.capture="position()"
      x-on:phx:update.window="updated()"
    >
      <button
        :if={@trigger == []}
        type="button"
        class={[
          button_classes("tertiary", "md"),
          "tooltip__trigger inline-block! [transition:color_150ms_var(--ease-smooth),background-color_150ms_var(--ease-smooth),box-shadow_150ms_var(--ease-out)]!",
          @trigger_class
        ]}
        aria-describedby={"#{@id}-content"}
        data-olis-tooltip-trigger
        x-ref="trigger"
      >{render_slot(@inner_block)}</button>
      <span
        :if={@trigger != []}
        class={["inline-flex", @trigger_class]}
        data-olis-tooltip-trigger
        data-slot="tooltip-trigger"
        x-ref="trigger"
      >{render_slot(@trigger, %{"aria-describedby" => "#{@id}-content"})}</span>
      <span
        id={"#{@id}-content"}
        role="tooltip"
        popover="manual"
        class={[
          "tooltip olis-tooltip group/tooltip fixed inset-auto m-0 max-w-[min(20rem,calc(100vw-1rem))] overflow-visible rounded-[6px] border-0 bg-overlay p-2 text-xs break-all text-overlay-foreground",
          overlay_motion_classes()
        ]}
        data-olis-tooltip
        data-slot="tooltip-content"
        x-ref="content"
        data-placement={@placement}
        phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["style", "data-placement"])}
      ><svg
        :if={@show_arrow}
        data-slot="overlay-arrow"
        aria-hidden="true"
        viewBox="0 0 12 12"
        width="12"
        height="12"
        fill="none"
        class="pointer-events-none absolute size-3 fill-overlay stroke-border/40 group-data-[placement=bottom]/tooltip:rotate-180 group-data-[placement=left]/tooltip:-rotate-90 group-data-[placement=right]/tooltip:rotate-90 group-data-[placement=top]/tooltip:-bottom-3 group-data-[placement=top]/tooltip:left-1/2 group-data-[placement=top]/tooltip:-translate-x-1/2 group-data-[placement=bottom]/tooltip:-top-3 group-data-[placement=bottom]/tooltip:left-1/2 group-data-[placement=bottom]/tooltip:-translate-x-1/2 group-data-[placement=left]/tooltip:-right-3 group-data-[placement=left]/tooltip:top-1/2 group-data-[placement=left]/tooltip:-translate-y-1/2 group-data-[placement=right]/tooltip:-left-3 group-data-[placement=right]/tooltip:top-1/2 group-data-[placement=right]/tooltip:-translate-y-1/2"
      ><path d="M0 0C5.48483 8 6.5 8 12 0Z" /></svg>
      <%= if @content != [] do %>
        {render_slot(@content)}
      <% else %>
        {@text}
      <% end %></span>
    </span>
    """
  end

  @doc """
  A nonmodal, interactive popover anchored to a button. Requires OlisUI's Alpine components.

  Use `trigger` for a simple button or the `:trigger_content` slot for a custom
  trigger; apply the yielded attributes to its interactive element. `open` and
  `on_open_change` enable LiveView-controlled state. `default_open` sets initial
  client-managed state.
  """
  attr(:id, :string, required: true)
  attr(:trigger, :string, default: nil)
  attr(:title, :string, required: true)

  attr(:placement, :string,
    default: "bottom",
    values: [
      "top",
      "bottom",
      "left",
      "right",
      "top start",
      "top end",
      "bottom start",
      "bottom end",
      "left start",
      "left end",
      "right start",
      "right end"
    ]
  )

  attr(:offset, :integer, default: 8)
  attr(:should_flip, :boolean, default: true)
  attr(:show_arrow, :boolean, default: false)
  attr(:open, :boolean, default: nil)
  attr(:default_open, :boolean, default: false)
  attr(:on_open_change, :any, default: nil)
  attr(:target, :any, default: nil)
  attr(:show_close, :boolean, default: true)
  attr(:close_label, :string, default: "Close")
  attr(:class, :any, default: nil)
  attr(:content_class, :any, default: nil)
  slot(:inner_block, required: true)
  slot(:trigger_content)

  def popover(assigns) do
    if (is_nil(assigns.trigger) and assigns.trigger_content == []) or
         (!is_nil(assigns.trigger) and assigns.trigger_content != []),
       do: raise(ArgumentError, "popover requires either trigger or a trigger_content slot")

    if !is_nil(assigns.open) and assigns.default_open,
      do: raise(ArgumentError, "popover cannot use open and default_open together")

    if assigns.offset < 0,
      do: raise(ArgumentError, "popover offset must be nonnegative")

    ~H"""
    <div
      class={["olis-popover-root inline-block", @class]}
      data-controlled={to_string(!is_nil(@open))}
      data-controlled-open={if !is_nil(@open), do: to_string(@open)}
      data-default-open={to_string(@default_open)}
      data-requested-placement={@placement}
      data-offset={@offset}
      data-should-flip={to_string(@should_flip)}
      x-data="olisPopover"
      x-on:click="onClick($event)"
      x-on:resize.window="position()"
      x-on:scroll.window.capture="position()"
      x-on:phx:update.document="sync()"
    >
      <button
        :if={@trigger_content == []}
        type="button"
        class={[
          button_classes("secondary", "md"),
          "popover__trigger inline-block! [transition:color_150ms_var(--ease-smooth),background-color_150ms_var(--ease-smooth),box-shadow_150ms_var(--ease-out)]!"
        ]}
        x-ref="trigger"
        data-olis-popover-trigger
        popovertarget={"#{@id}-content"}
        aria-controls={"#{@id}-content"}
        aria-expanded="false"
        aria-haspopup="dialog"
        phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["aria-expanded"])}
      >{@trigger}</button>
      <span :if={@trigger_content != []} class="inline-flex" x-ref="trigger">
        {render_slot(@trigger_content, %{
          "data-olis-popover-trigger" => true,
          "popovertarget" => "#{@id}-content",
          "aria-controls" => "#{@id}-content",
          "aria-expanded" => "false",
          "aria-haspopup" => "dialog",
          "phx-mounted" => Phoenix.LiveView.JS.ignore_attributes(["aria-expanded"])
        })}
      </span>
      <div
        id={"#{@id}-content"}
        popover="auto"
        class={[
          "popover rounded-[12px] bg-overlay p-0 text-sm",
          overlay_motion_classes(),
          "olis-popover fixed inset-auto m-0 max-h-[calc(100dvh-1rem)] max-w-[min(20rem,calc(100vw-1rem))] overflow-visible border-0 text-overlay-foreground",
          "group/popover",
          "transition-[display,overlay] duration-100 [transition-behavior:allow-discrete]",
          @content_class
        ]}
        data-olis-popover
        x-ref="content"
        x-on:beforetoggle="beforeToggle($event)"
        x-on:toggle="toggle($event)"
        x-on:animationend="animationEnd($event)"
        data-placement={@placement |> String.split() |> hd()}
        phx-mounted={
          Phoenix.LiveView.JS.ignore_attributes([
            "style",
            "data-placement",
            "data-entering",
            "data-exiting"
          ])
        }
      >
        <svg
          :if={@show_arrow}
          data-slot="popover-overlay-arrow"
          aria-hidden="true"
          viewBox="0 0 12 12"
          width="12"
          height="12"
          class="pointer-events-none absolute size-3 fill-overlay group-data-[placement=bottom]/popover:rotate-180 group-data-[placement=left]/popover:-rotate-90 group-data-[placement=right]/popover:rotate-90 group-data-[placement=top]/popover:-bottom-3 group-data-[placement=top]/popover:left-1/2 group-data-[placement=top]/popover:-translate-x-1/2 group-data-[placement=bottom]/popover:-top-3 group-data-[placement=bottom]/popover:left-1/2 group-data-[placement=bottom]/popover:-translate-x-1/2 group-data-[placement=left]/popover:-right-3 group-data-[placement=left]/popover:top-1/2 group-data-[placement=left]/popover:-translate-y-1/2 group-data-[placement=right]/popover:-left-3 group-data-[placement=right]/popover:top-1/2 group-data-[placement=right]/popover:-translate-y-1/2"
        ><path d="M0 0C5.48483 8 6.5 8 12 0Z" /></svg>
        <section
          role="dialog"
          aria-labelledby={"#{@id}-title"}
          tabindex="-1"
          class="popover__dialog max-h-[calc(100dvh-1rem)] overflow-y-auto p-4 outline-none"
          data-slot="popover-dialog"
          x-ref="dialog"
        >
          <h2 id={"#{@id}-title"} class="popover__heading font-medium" data-slot="popover-heading">
            {@title}
          </h2>
          <div class="mt-2">{render_slot(@inner_block)}</div>
          <button
            :if={@show_close}
            type="button"
            class={[button_classes("tertiary", "sm"), "mt-4"]}
            data-olis-popover-close
          >{@close_label}</button>
        </section>
      </div>
      <button
        :if={@on_open_change}
        type="button"
        hidden
        data-olis-popover-event
        phx-click={@on_open_change}
        phx-target={@target}
      ></button>
    </div>
    """
  end

  @doc "A single-value or multi-thumb slider. Requires OlisUI's Alpine components for pointer interaction and live updates."
  attr(:id, :string, required: true)
  attr(:name, :string, default: nil)
  attr(:label, :string, required: true)
  attr(:value, :any, required: true)
  attr(:min, :any, default: 0)
  attr(:max, :any, default: 100)
  attr(:step, :any, default: 1)
  attr(:orientation, :string, default: "horizontal", values: ~w(horizontal vertical))
  attr(:show_steps, :boolean, default: false)
  attr(:marks, :list, default: [])
  attr(:disabled, :boolean, default: false)
  attr(:class, :any, default: nil)
  attr(:rest, :global, include: ~w(form required))

  def slider(assigns) do
    if not is_number(assigns.step) or assigns.step <= 0,
      do: raise(ArgumentError, "slider step must be a positive number")

    values = if is_list(assigns.value), do: assigns.value, else: [assigns.value]

    if values == [] or Enum.sort(values) != values,
      do: raise(ArgumentError, "slider values must be a nonempty, ascending list")

    percentages = Enum.map(values, &range_percent!(&1, assigns.min, assigns.max, false))
    first = hd(percentages)
    last = List.last(percentages)
    start = if length(values) == 1, do: 0, else: first
    step_count = (assigns.max - assigns.min) / assigns.step
    nearest_step_count = round(step_count)

    count =
      if abs(step_count - nearest_step_count) <= 1.0e-12 * max(1, abs(step_count)),
        do: nearest_step_count + 1,
        else: floor(step_count) + 1

    steps =
      if assigns.show_steps and count <= 1000 do
        for index <- 0..(count - 1), do: min(assigns.max, assigns.min + index * assigns.step)
      else
        []
      end

    marks =
      Enum.flat_map(assigns.marks, fn mark ->
        {value, label} = if is_tuple(mark), do: mark, else: {mark, mark}

        if is_number(value) and value >= assigns.min and value <= assigns.max,
          do: [{value, label}],
          else: []
      end)

    assigns =
      assign(assigns,
        values: values,
        percentages: percentages,
        start: start,
        finish: last,
        steps: steps,
        visible_marks: marks,
        multiple: is_list(assigns.value)
      )

    ~H"""
    <div
      class={[
        "slider grid disabled:status-disabled data-[disabled=true]:status-disabled aria-disabled:status-disabled [&[data-disabled=true]_[data-slot=label]]:opacity-100",
        @orientation == "horizontal" && "w-full flex-col gap-1 grid-cols-[1fr_auto]",
        @orientation == "horizontal" && @visible_marks == [] &&
          "[grid-template-areas:'label_output'_'track_track']",
        @orientation == "horizontal" && @visible_marks != [] &&
          "[grid-template-areas:'label_output'_'track_track'_'marks_marks']",
        @orientation == "vertical" && "h-full w-fit flex-row gap-2 grid-rows-[auto_1fr_auto]",
        @orientation == "vertical" && @visible_marks == [] &&
          "grid-cols-1 [grid-template-areas:'output'_'track'_'label']",
        @orientation == "vertical" && @visible_marks != [] &&
          "grid-cols-[auto_auto] justify-center [grid-template-areas:'output_output'_'track_marks'_'label_label']",
        @class
      ]}
      data-orientation={@orientation}
      data-disabled={if @disabled, do: "true"}
      data-olis-slider
      x-data="olisSlider"
      x-on:input.capture="input($event)"
      x-on:pointerdown="start($event)"
      x-on:pointermove="move($event)"
      x-on:pointerup="end($event)"
      x-on:pointercancel="end($event)"
      x-on:reset.document="reset($event)"
      x-on:phx:update.document="sync()"
    >
      <label
        for={if @multiple, do: "#{@id}-0", else: @id}
        data-slot="label"
        class={[
          "w-fit text-sm font-medium [grid-area:label]",
          @orientation == "vertical" && "text-center"
        ]}
      >{@label}</label>
      <output
        class={[
          "slider__output text-sm font-medium tabular-nums [grid-area:output]",
          @orientation == "vertical" && "text-center"
        ]}
        data-olis-slider-output
      >{Enum.join(@values, " – ")}</output>
      <div
        class={[
          "slider__track relative touch-none rounded-xl bg-default [grid-area:track]",
          @orientation == "horizontal" &&
            "h-5 w-full border-x-[0.75rem] border-x-transparent data-[fill-start=true]:border-s-accent data-[fill-end=true]:border-e-accent",
          @orientation == "vertical" &&
            "h-full w-5 justify-self-center border-y-[0.75rem] border-y-transparent data-[fill-start=true]:border-b-accent data-[fill-end=true]:border-t-accent"
        ]}
        data-olis-slider-track
        data-fill-start={to_string(@start == 0)}
        data-fill-end={to_string(@finish == 100)}
      >
        <div
          class={[
            "slider__fill pointer-events-none absolute bg-accent",
            @orientation == "horizontal" && "h-full",
            @orientation == "vertical" && "w-full"
          ]}
          data-olis-slider-fill
          style={slider_fill_style(@orientation, @start, @finish)}
        >
        </div>
        <div
          :if={@steps != []}
          class="slider__steps pointer-events-none absolute inset-0 z-1"
          data-slot="slider-steps"
          aria-hidden="true"
        >
          <span
            :for={value <- @steps}
            class={[
              "slider__step absolute size-[3px] rounded-full bg-muted/25 data-[filled=true]:bg-accent-foreground/25",
              @orientation == "horizontal" &&
                "top-1/2 -translate-x-1/2 -translate-y-1/2 [.slider__steps[data-direction=rtl]_&]:translate-x-1/2",
              @orientation == "vertical" && "left-1/2 -translate-x-1/2 translate-y-1/2"
            ]}
            data-slot="slider-step"
            data-value={value}
            data-filled={
              to_string(
                value >= if(@multiple, do: hd(@values), else: @min) and value <= List.last(@values)
              )
            }
            style={slider_position_style(@orientation, range_percent!(value, @min, @max, false))}
          ></span>
        </div>
        <div
          :for={{value, index} <- Enum.with_index(@values)}
          class="pointer-events-none absolute inset-0"
        >
          <input
            id={if @multiple, do: "#{@id}-#{index}", else: @id}
            name={if @name && @multiple, do: "#{@name}[]", else: @name}
            type="range"
            value={value}
            min={@min}
            max={@max}
            step={@step}
            disabled={@disabled}
            aria-label={if @multiple, do: "#{@label} #{index + 1}", else: @label}
            aria-orientation={@orientation}
            class="peer sr-only"
            data-olis-slider-input
            {@rest}
          />
          <span
            class={[
              "slider__thumb absolute z-2 flex cursor-grab items-center justify-center rounded-xl bg-accent-foreground no-highlight [transition:background-color_250ms_var(--ease-smooth),transform_250ms_var(--ease-out),box-shadow_150ms_var(--ease-out)] after:relative after:z-10 after:origin-center after:rounded-lg after:bg-accent-foreground after:shadow-field after:transition-all after:content-[''] data-[dragging=true]:cursor-grabbing data-[dragging=true]:after:scale-[0.9] data-[focus-visible=true]:z-10 data-[focus-visible=true]:status-focused data-[disabled=true]:cursor-default peer-focus-visible:z-10 peer-focus-visible:outline-2 peer-focus-visible:outline-offset-2 peer-focus-visible:outline-focus",
              @orientation == "horizontal" &&
                "top-1/2 h-full w-[calc(1.5rem+0.25rem)] after:h-4 after:w-6",
              @orientation == "vertical" &&
                "left-1/2 h-[calc(1.5rem+0.25rem)] w-full after:h-6 after:w-4",
              if(@orientation == "vertical",
                do: "-translate-x-1/2 translate-y-1/2",
                else: "-translate-x-1/2 -translate-y-1/2 rtl:translate-x-1/2"
              )
            ]}
            data-olis-slider-thumb
            data-disabled={if @disabled, do: "true"}
            style={slider_position_style(@orientation, Enum.at(@percentages, index))}
          ></span>
        </div>
      </div>
      <div
        :if={@visible_marks != []}
        class={[
          "slider__marks grid [grid-area:marks]",
          @orientation == "horizontal" && "mx-3 grid-cols-[minmax(0,1fr)]",
          @orientation == "vertical" && "my-3 grid-cols-[max-content] grid-rows-[minmax(0,1fr)]"
        ]}
        data-slot="slider-marks"
      >
        <span
          :for={{value, label} <- @visible_marks}
          class={[
            "slider__mark relative w-max justify-self-start text-xs text-muted tabular-nums [grid-area:1/1] transition-colors duration-200 ease-(--ease-smooth) data-[filled=true]:text-foreground",
            @orientation == "horizontal" &&
              "-translate-x-1/2 [.slider__marks[data-direction=rtl]_&]:translate-x-1/2",
            @orientation == "vertical" && "translate-y-1/2 self-end"
          ]}
          data-slot="slider-mark"
          data-value={value}
          data-filled={
            to_string(
              value >= if(@multiple, do: hd(@values), else: @min) and value <= List.last(@values)
            )
          }
          style={slider_position_style(@orientation, range_percent!(value, @min, @max, false))}
        >{label}</span>
      </div>
    </div>
    """
  end

  defp slider_position_style("vertical", percent), do: "bottom: #{percent}%"
  defp slider_position_style(_, percent), do: "inset-inline-start: #{percent}%"

  defp slider_fill_style("vertical", start, finish),
    do: "bottom: #{start}%; height: #{finish - start}%"

  defp slider_fill_style(_, start, finish),
    do: "inset-inline-start: #{start}%; width: #{finish - start}%"

  @doc "A labelled numeric input with increment and decrement buttons. Requires OlisUI's Alpine components."
  attr(:field, Phoenix.HTML.FormField, default: nil)
  attr(:id, :string, default: nil)
  attr(:name, :string, default: nil)
  attr(:label, :string, required: true)
  attr(:value, :any, default: nil)
  attr(:min, :any, default: nil)
  attr(:max, :any, default: nil)
  attr(:step, :any, default: 1)
  attr(:disabled, :boolean, default: false)
  attr(:readonly, :boolean, default: false)
  attr(:invalid, :boolean, default: false)
  attr(:description, :string, default: nil)
  attr(:errors, :list, default: [])
  attr(:variant, :string, default: "primary", values: ~w(primary secondary))
  attr(:full_width, :boolean, default: false)
  attr(:increment_label, :string, default: "Increase")
  attr(:decrement_label, :string, default: "Decrease")
  attr(:class, :any, default: nil)
  attr(:rest, :global, include: ~w(autocomplete autofocus form placeholder required))
  slot(:increment_icon)
  slot(:decrement_icon)

  def number_field(assigns) do
    if not is_number(assigns.step) or assigns.step <= 0,
      do: raise(ArgumentError, "number field step must be a positive number")

    if (!is_nil(assigns.min) and !is_number(assigns.min)) or
         (!is_nil(assigns.max) and !is_number(assigns.max)) or
         (is_number(assigns.min) and is_number(assigns.max) and assigns.min > assigns.max),
       do: raise(ArgumentError, "number field bounds must be numeric and min must not exceed max")

    field = assigns.field
    id = assigns.id || (field && field.id)
    if is_nil(id), do: raise(ArgumentError, "number_field requires an id or field")
    value = if is_nil(assigns.value) && field, do: field.value, else: assigns.value
    invalid = assigns.invalid || assigns.errors != []
    {external_description, rest} = Map.pop(assigns.rest, :"aria-describedby")
    {external_description_string, rest} = Map.pop(rest, "aria-describedby")

    describedby =
      [
        external_description,
        external_description_string,
        !invalid && assigns.description && "#{id}-description",
        assigns.errors != [] && "#{id}-errors"
      ]
      |> Enum.filter(& &1)
      |> Enum.join(" ")

    assigns =
      assign(assigns,
        id: id,
        name: assigns.name || (field && field.name),
        value: value,
        invalid_state: invalid,
        rest: rest,
        describedby: describedby
      )

    ~H"""
    <div
      class={[
        "number-field number-field--#{@variant} flex flex-col gap-1 [&:is([data-invalid=true],[aria-invalid=true])_[data-slot=description]]:hidden [&_[data-slot=label]]:w-fit",
        @full_width && "number-field--full-width w-full",
        @class
      ]}
      data-slot="number-field"
      data-olis-number
      data-invalid={if @invalid_state, do: "true"}
      data-disabled={if @disabled, do: "true"}
      data-required={if @rest[:required] || @rest["required"], do: "true"}
      x-data="olisNumberField"
      x-bind:data-disabled="disabled ? 'true' : null"
      phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["data-disabled"])}
      x-init="$nextTick(() => sync())"
      x-on:input="sync()"
      x-on:change="sync()"
      x-on:phx:update.window="sync()"
      x-on:reset.window="$nextTick(() => sync())"
    >
      <label for={@id} class={label_classes()} data-slot="label">{@label}</label>
      <div
        class={[
          "number-field__group grid h-9 grid-cols-[40px_1fr_40px] items-center overflow-hidden rounded-field border border-[length:var(--border-width-field)] border-field-border bg-(--number-field-group-bg) text-sm text-field-foreground outline-none [transition:background-color_150ms_var(--ease-smooth),border-color_150ms_var(--ease-smooth),box-shadow_150ms_var(--ease-out)] [@media(hover:hover)]:[&:hover:not(:focus-within)]:[--number-field-group-bg:var(--number-field-group-bg-hover)] [@media(hover:hover)]:[&:hover:not(:focus-within)]:border-field-border-hover [@media(hover:hover)]:[&[data-hovered=true]:not([data-focus-within=true])]:[--number-field-group-bg:var(--number-field-group-bg-hover)] [@media(hover:hover)]:[&[data-hovered=true]:not([data-focus-within=true])]:border-field-border-hover focus-within:status-focused-field focus-within:border-field-border-focus focus-within:[--number-field-group-bg:var(--number-field-group-bg-focus)] data-[focus-within=true]:status-focused-field data-[focus-within=true]:border-field-border-focus data-[focus-within=true]:[--number-field-group-bg:var(--number-field-group-bg-focus)] data-[invalid=true]:status-invalid-field data-[invalid=true]:border-[color:var(--color-field-border-invalid)] data-[invalid=true]:[--number-field-group-bg:var(--number-field-group-bg-focus)] data-[disabled=true]:status-disabled aria-disabled:status-disabled",
          @variant == "primary" &&
            "[--number-field-group-bg:var(--field-background,var(--default))] [--number-field-group-bg-hover:var(--field-hover)] [--number-field-group-bg-focus:var(--field-focus)] shadow-field",
          @variant == "secondary" &&
            "[--number-field-group-bg:var(--default)] [--number-field-group-bg-hover:var(--default-hover)] [--number-field-group-bg-focus:var(--default)] shadow-none",
          @full_width && "number-field__group--full-width w-full"
        ]}
        role="group"
        data-slot="number-field-group"
        data-disabled={if @disabled, do: "true"}
        data-invalid={if @invalid_state, do: "true"}
        x-bind:data-disabled="disabled ? 'true' : null"
        phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["data-disabled"])}
      >
        <button
          type="button"
          slot="decrement"
          class="number-field__decrement-button flex h-full w-10 items-center justify-center border-[length:var(--border-width-field)] border-solid border-field-placeholder/15 bg-transparent text-field-foreground outline-none cursor-(--cursor-interactive) [transition:background-color_150ms_var(--ease-smooth),border-color_150ms_var(--ease-smooth)] active:bg-field-foreground/10 active:[transform:scale(.97)] data-[pressed=true]:bg-field-foreground/10 data-[pressed=true]:[transform:scale(.97)] disabled:status-disabled data-[disabled=true]:status-disabled aria-disabled:status-disabled [&_[data-slot=number-field-increment-button-icon]]:size-4 [&_[data-slot=number-field-decrement-button-icon]]:size-4 rounded-s-field rounded-e-none border-e"
          data-slot="number-field-decrement-button"
          aria-label={"#{@decrement_label} #{@label}"}
          aria-controls={@id}
          tabindex="-1"
          disabled={@disabled || @readonly}
          data-olis-number-step="down"
          x-bind:disabled="locked || cannotDecrease"
          x-on:click="step('down')"
          phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["disabled"])}
        ><%= if @decrement_icon == [] do %>
          <svg
            aria-hidden="true"
            role="presentation"
            viewBox="0 0 16 16"
            fill="none"
            data-slot="number-field-decrement-button-icon"
          ><path
            d="M1.75 8a.75.75 0 0 1 .75-.75h11a.75.75 0 0 1 0 1.5h-11A.75.75 0 0 1 1.75 8"
            fill="currentColor"
            fill-rule="evenodd"
            clip-rule="evenodd"
          /></svg>
        <% else %>
          {render_slot(@decrement_icon)}
        <% end %></button>
        <input
          type="number"
          x-ref="input"
          id={@id}
          name={@name}
          value={@value}
          min={@min}
          max={@max}
          step={@step}
          disabled={@disabled}
          readonly={@readonly}
          aria-invalid={if @invalid_state, do: "true"}
          aria-describedby={if @describedby != "", do: @describedby}
          class="number-field__input min-w-0 rounded-none border-0 bg-transparent px-3 py-2 text-base tabular-nums shadow-none outline-none sm:text-sm [&:is(:-webkit-autofill,:autofill)]:[box-shadow:0_0_0_1000px_var(--number-field-group-bg)_inset] [&:is(:-webkit-autofill,:autofill)]:[-webkit-box-shadow:0_0_0_1000px_var(--number-field-group-bg)_inset] [&:is(:-webkit-autofill,:autofill)]:[-webkit-text-fill-color:var(--field-foreground)] [&:is(:-webkit-autofill,:autofill)]:[caret-color:var(--field-foreground)] [&:is(:-webkit-autofill,:autofill)]:[transition:background-color_9999s_ease-in-out_0s] olis-number-input [appearance:textfield] [&::-webkit-inner-spin-button]:m-0 [&::-webkit-inner-spin-button]:appearance-none [&::-webkit-outer-spin-button]:m-0 [&::-webkit-outer-spin-button]:appearance-none"
          data-slot="number-field-input"
          {@rest}
        />
        <button
          type="button"
          slot="increment"
          class="number-field__increment-button flex h-full w-10 items-center justify-center border-[length:var(--border-width-field)] border-solid border-field-placeholder/15 bg-transparent text-field-foreground outline-none cursor-(--cursor-interactive) [transition:background-color_150ms_var(--ease-smooth),border-color_150ms_var(--ease-smooth)] active:bg-field-foreground/10 active:[transform:scale(.97)] data-[pressed=true]:bg-field-foreground/10 data-[pressed=true]:[transform:scale(.97)] disabled:status-disabled data-[disabled=true]:status-disabled aria-disabled:status-disabled [&_[data-slot=number-field-increment-button-icon]]:size-4 [&_[data-slot=number-field-decrement-button-icon]]:size-4 rounded-s-none rounded-e-field border-s"
          data-slot="number-field-increment-button"
          aria-label={"#{@increment_label} #{@label}"}
          aria-controls={@id}
          tabindex="-1"
          disabled={@disabled || @readonly}
          data-olis-number-step="up"
          x-bind:disabled="locked || cannotIncrease"
          x-on:click="step('up')"
          phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["disabled"])}
        ><%= if @increment_icon == [] do %>
          <svg
            aria-hidden="true"
            role="presentation"
            viewBox="0 0 16 16"
            fill="none"
            data-slot="number-field-increment-button-icon"
          ><path
            d="M8 1.75a.75.75 0 0 1 .75.75v4.75h4.75a.75.75 0 0 1 0 1.5H8.75v4.75a.75.75 0 0 1-1.5 0V8.75H2.5a.75.75 0 0 1 0-1.5h4.75V2.5A.75.75 0 0 1 8 1.75"
            fill="currentColor"
            fill-rule="evenodd"
            clip-rule="evenodd"
          /></svg>
        <% else %>
          {render_slot(@increment_icon)}
        <% end %></button>
      </div>
      <span
        :if={@description}
        id={"#{@id}-description"}
        class="description text-xs text-wrap wrap-break-word text-muted"
        data-slot="description"
      >{@description}</span>
      <div
        :if={@errors != []}
        id={"#{@id}-errors"}
        class={field_error_classes()}
        data-visible="true"
        data-slot="field-error"
      >
        <p :for={error <- @errors}>{error}</p>
      </div>
    </div>
    """
  end

  @doc """
  Page navigation with bounded page links. Provide either `on_change` for a
  LiveView event receiving `%{"page" => "N"}`, `href` as a one-argument URL
  function, or `patch` as a one-argument LiveView patch URL function. The caller
  owns the current page and data loading. `on_change` also accepts a
  `Phoenix.LiveView.JS` command. Use `show_pages={false}` for previous/next only.
  """
  attr(:page, :integer, required: true)
  attr(:total_pages, :integer, required: true)
  attr(:on_change, :any, default: nil)
  attr(:href, :any, default: nil)
  attr(:patch, :any, default: nil)
  attr(:target, :any, default: nil)
  attr(:siblings, :integer, default: 1)
  attr(:show_pages, :boolean, default: true)
  attr(:show_controls, :boolean, default: true)
  attr(:disabled, :boolean, default: false)
  attr(:page_label, :any, default: nil)
  attr(:label, :string, default: "Pagination")
  attr(:previous_label, :string, default: "Previous")
  attr(:next_label, :string, default: "Next")
  attr(:size, :string, default: "md", values: ~w(sm md lg))
  attr(:class, :any, default: nil)
  attr(:rest, :global)
  slot(:summary)
  slot(:previous_icon)
  slot(:next_icon)

  def pagination(assigns) do
    if assigns.total_pages < 0 or assigns.page < 1 or assigns.page > max(assigns.total_pages, 1) or
         assigns.siblings < 0,
       do:
         raise(
           ArgumentError,
           "page must be within the total page count and siblings must be nonnegative"
         )

    if Enum.count([assigns.on_change, assigns.href, assigns.patch], &(!is_nil(&1))) != 1,
      do: raise(ArgumentError, "provide exactly one of on_change, href, or patch")

    for {name, value} <- [
          href: assigns.href,
          patch: assigns.patch,
          page_label: assigns.page_label
        ],
        value && !is_function(value, 1),
        do: raise(ArgumentError, "#{name} must be a one-argument function")

    data_slot =
      Map.get(assigns.rest, :"data-slot") || Map.get(assigns.rest, "data-slot") || "pagination"

    aria_label =
      Map.get(assigns.rest, :"aria-label") || Map.get(assigns.rest, "aria-label") || assigns.label

    rest = Map.drop(assigns.rest, [:"data-slot", "data-slot", :"aria-label", "aria-label"])

    assigns =
      assign(
        assigns,
        :pages,
        pagination_pages(assigns.page, assigns.total_pages, assigns.siblings)
      )
      |> assign(data_slot: data_slot, aria_label: aria_label, rest: rest)

    ~H"""
    <nav
      aria-label={@aria_label}
      class={[
        "pagination flex w-full flex-col items-center justify-between gap-4 sm:flex-row",
        "pagination--#{@size}",
        @class
      ]}
      data-slot={@data_slot}
      {@rest}
    >
      <div
        :if={@summary != []}
        class={[
          "pagination__summary flex items-center gap-2 self-start text-muted sm:self-center",
          @size == "sm" && "text-xs",
          @size == "md" && "text-sm",
          @size == "lg" && "text-base"
        ]}
        data-slot="pagination-summary"
      >
        {render_slot(@summary)}
      </div>
      <ul
        class="pagination__content flex items-center gap-1 self-start sm:self-center"
        data-slot="pagination-content"
      >
        <li :if={@show_controls} class="pagination__item inline-flex">
          <.pagination_control
            size={@size}
            page={max(@page - 1, 1)}
            label={@previous_label}
            disabled={@disabled || @page <= 1 || @total_pages == 0}
            nav
            on_change={@on_change}
            href={@href}
            patch={@patch}
            target={@target}
          >
            <span class="rtl:rotate-180" data-slot="pagination-previous-icon" aria-hidden="true">{render_slot(
              @previous_icon
            )}<svg
              :if={@previous_icon == []}
              width="16"
              height="16"
              viewBox="0 0 16 16"
              fill="none"
            ><path
              d="M10.53 2.97a.75.75 0 0 1 0 1.06L6.56 8l3.97 3.97a.75.75 0 1 1-1.06 1.06l-4.5-4.5a.75.75 0 0 1 0-1.06l4.5-4.5a.75.75 0 0 1 1.06 0"
              fill="currentColor"
              fill-rule="evenodd"
              clip-rule="evenodd"
            /></svg></span><span>{@previous_label}</span>
          </.pagination_control>
        </li>
        <li :for={item <- if(@show_pages, do: @pages, else: [])} class="pagination__item inline-flex">
          <span
            :if={item == :ellipsis}
            class={[
              "pagination__ellipsis inline-flex items-center justify-center text-muted select-none",
              @size == "sm" && "size-8 text-xs md:size-7",
              @size == "md" && "size-9 text-sm md:size-8",
              @size == "lg" && "size-10 text-base md:size-9"
            ]}
            aria-hidden="true"
          >…</span>
          <.pagination_control
            :if={item != :ellipsis}
            size={@size}
            page={item}
            label={if @page_label, do: @page_label.(item), else: "Page #{item}"}
            active={item == @page}
            disabled={@disabled}
            on_change={@on_change}
            href={@href}
            patch={@patch}
            target={@target}
          >
            {item}
          </.pagination_control>
        </li>
        <li :if={@show_controls} class="pagination__item inline-flex">
          <.pagination_control
            size={@size}
            page={min(@page + 1, max(@total_pages, 1))}
            label={@next_label}
            disabled={@disabled || @page >= @total_pages}
            nav
            on_change={@on_change}
            href={@href}
            patch={@patch}
            target={@target}
          >
            <span>{@next_label}</span><span
              class="rtl:rotate-180"
              data-slot="pagination-next-icon"
              aria-hidden="true"
            >{render_slot(@next_icon)}<svg
              :if={@next_icon == []}
              width="16"
              height="16"
              viewBox="0 0 16 16"
              fill="none"
            ><path
              d="M5.47 2.97a.75.75 0 0 1 1.06 0l4.5 4.5a.75.75 0 0 1 0 1.06l-4.5 4.5a.75.75 0 1 1-1.06-1.06L9.44 8 5.47 4.03a.75.75 0 0 1 0-1.06Z"
              fill="currentColor"
              fill-rule="evenodd"
              clip-rule="evenodd"
            /></svg></span>
          </.pagination_control>
        </li>
      </ul>
    </nav>
    """
  end

  attr(:page, :integer, required: true)
  attr(:size, :string, required: true)
  attr(:label, :string, required: true)
  attr(:active, :boolean, default: false)
  attr(:disabled, :boolean, default: false)
  attr(:nav, :boolean, default: false)
  attr(:on_change, :any, default: nil)
  attr(:href, :any, default: nil)
  attr(:patch, :any, default: nil)
  attr(:target, :any, default: nil)
  slot(:inner_block, required: true)

  defp pagination_control(assigns) do
    ~H"""
    <span
      :if={(@href || @patch) && @disabled}
      class={[
        "pagination__link relative isolate inline-flex origin-center items-center justify-center rounded-[6px] font-medium whitespace-nowrap outline-none select-none no-highlight transform-gpu cursor-(--cursor-interactive) text-default-foreground [transition:transform_250ms_var(--ease-smooth),background-color_100ms_var(--ease-out),box-shadow_100ms_var(--ease-out)] focus-visible:status-focused data-[focus-visible=true]:status-focused disabled:status-disabled aria-disabled:status-disabled hover:bg-default-hover [@media(hover:hover)]:data-[hovered=true]:bg-default-hover active:bg-default-hover data-[pressed=true]:bg-default-hover",
        @active && "bg-default",
        !@active && "bg-transparent",
        @size == "sm" &&
          "h-8 text-xs md:h-7 active:[transform:scale(.98)] data-[pressed=true]:[transform:scale(.98)]",
        @size == "md" &&
          "h-9 text-sm md:h-8 active:[transform:scale(.97)] data-[pressed=true]:[transform:scale(.97)]",
        @size == "lg" &&
          "h-10 text-base md:h-9 active:[transform:scale(.96)] data-[pressed=true]:[transform:scale(.96)]",
        !@nav && @size == "sm" && "w-8 md:w-7",
        !@nav && @size == "md" && "w-9 md:w-8",
        !@nav && @size == "lg" && "w-10 md:w-9",
        @nav && "pagination__link--nav w-auto gap-1.5",
        @nav && @size == "sm" && "px-2",
        @nav && @size == "md" && "px-2.5",
        @nav && @size == "lg" && "px-3"
      ]}
      aria-disabled="true"
      aria-label={@label}
      aria-current={if @active, do: "page"}
      data-active={if @active, do: "true"}
    >{render_slot(@inner_block)}</span>
    <a
      :if={@href && !@disabled}
      href={@href.(@page)}
      class={[
        "pagination__link relative isolate inline-flex origin-center items-center justify-center rounded-[6px] font-medium whitespace-nowrap outline-none select-none no-highlight transform-gpu cursor-(--cursor-interactive) text-default-foreground [transition:transform_250ms_var(--ease-smooth),background-color_100ms_var(--ease-out),box-shadow_100ms_var(--ease-out)] focus-visible:status-focused data-[focus-visible=true]:status-focused disabled:status-disabled aria-disabled:status-disabled hover:bg-default-hover [@media(hover:hover)]:data-[hovered=true]:bg-default-hover active:bg-default-hover data-[pressed=true]:bg-default-hover",
        @active && "bg-default",
        !@active && "bg-transparent",
        @size == "sm" &&
          "h-8 text-xs md:h-7 active:[transform:scale(.98)] data-[pressed=true]:[transform:scale(.98)]",
        @size == "md" &&
          "h-9 text-sm md:h-8 active:[transform:scale(.97)] data-[pressed=true]:[transform:scale(.97)]",
        @size == "lg" &&
          "h-10 text-base md:h-9 active:[transform:scale(.96)] data-[pressed=true]:[transform:scale(.96)]",
        !@nav && @size == "sm" && "w-8 md:w-7",
        !@nav && @size == "md" && "w-9 md:w-8",
        !@nav && @size == "lg" && "w-10 md:w-9",
        @nav && "pagination__link--nav w-auto gap-1.5",
        @nav && @size == "sm" && "px-2",
        @nav && @size == "md" && "px-2.5",
        @nav && @size == "lg" && "px-3"
      ]}
      aria-label={@label}
      aria-current={if @active, do: "page"}
      data-active={if @active, do: "true"}
    >{render_slot(@inner_block)}</a>
    <Phoenix.Component.link
      :if={@patch && !@disabled}
      patch={@patch.(@page)}
      class={[
        "pagination__link relative isolate inline-flex origin-center items-center justify-center rounded-[6px] font-medium whitespace-nowrap outline-none select-none no-highlight transform-gpu cursor-(--cursor-interactive) text-default-foreground [transition:transform_250ms_var(--ease-smooth),background-color_100ms_var(--ease-out),box-shadow_100ms_var(--ease-out)] focus-visible:status-focused data-[focus-visible=true]:status-focused disabled:status-disabled aria-disabled:status-disabled hover:bg-default-hover [@media(hover:hover)]:data-[hovered=true]:bg-default-hover active:bg-default-hover data-[pressed=true]:bg-default-hover",
        @active && "bg-default",
        !@active && "bg-transparent",
        @size == "sm" &&
          "h-8 text-xs md:h-7 active:[transform:scale(.98)] data-[pressed=true]:[transform:scale(.98)]",
        @size == "md" &&
          "h-9 text-sm md:h-8 active:[transform:scale(.97)] data-[pressed=true]:[transform:scale(.97)]",
        @size == "lg" &&
          "h-10 text-base md:h-9 active:[transform:scale(.96)] data-[pressed=true]:[transform:scale(.96)]",
        !@nav && @size == "sm" && "w-8 md:w-7",
        !@nav && @size == "md" && "w-9 md:w-8",
        !@nav && @size == "lg" && "w-10 md:w-9",
        @nav && "pagination__link--nav w-auto gap-1.5",
        @nav && @size == "sm" && "px-2",
        @nav && @size == "md" && "px-2.5",
        @nav && @size == "lg" && "px-3"
      ]}
      aria-label={@label}
      aria-current={if @active, do: "page"}
      data-active={if @active, do: "true"}
    >{render_slot(@inner_block)}</Phoenix.Component.link>
    <button
      :if={!@href && !@patch}
      type="button"
      class={[
        "pagination__link relative isolate inline-flex origin-center items-center justify-center rounded-[6px] font-medium whitespace-nowrap outline-none select-none no-highlight transform-gpu cursor-(--cursor-interactive) text-default-foreground [transition:transform_250ms_var(--ease-smooth),background-color_100ms_var(--ease-out),box-shadow_100ms_var(--ease-out)] focus-visible:status-focused data-[focus-visible=true]:status-focused disabled:status-disabled aria-disabled:status-disabled hover:bg-default-hover [@media(hover:hover)]:data-[hovered=true]:bg-default-hover active:bg-default-hover data-[pressed=true]:bg-default-hover",
        @active && "bg-default",
        !@active && "bg-transparent",
        @size == "sm" &&
          "h-8 text-xs md:h-7 active:[transform:scale(.98)] data-[pressed=true]:[transform:scale(.98)]",
        @size == "md" &&
          "h-9 text-sm md:h-8 active:[transform:scale(.97)] data-[pressed=true]:[transform:scale(.97)]",
        @size == "lg" &&
          "h-10 text-base md:h-9 active:[transform:scale(.96)] data-[pressed=true]:[transform:scale(.96)]",
        !@nav && @size == "sm" && "w-8 md:w-7",
        !@nav && @size == "md" && "w-9 md:w-8",
        !@nav && @size == "lg" && "w-10 md:w-9",
        @nav && "pagination__link--nav w-auto gap-1.5",
        @nav && @size == "sm" && "px-2",
        @nav && @size == "md" && "px-2.5",
        @nav && @size == "lg" && "px-3"
      ]}
      aria-label={@label}
      aria-current={if @active, do: "page"}
      data-active={if @active, do: "true"}
      disabled={@disabled}
      phx-click={@on_change}
      phx-value-page={@page}
      phx-target={@target}
    >{render_slot(@inner_block)}</button>
    """
  end

  defp pagination_pages(_page, 0, _siblings), do: []

  defp pagination_pages(page, total, siblings) do
    first = max(2, page - siblings)
    last = min(total - 1, page + siblings)
    middle = if first <= last, do: Enum.to_list(first..last), else: []
    numbers = Enum.uniq([1] ++ middle ++ [total]) |> Enum.sort()

    numbers
    |> Enum.reduce([], fn number, acc ->
      case acc do
        [previous | _] when number - previous == 2 -> [number, previous + 1 | acc]
        [previous | _] when number - previous > 2 -> [number, :ellipsis | acc]
        _ -> [number | acc]
      end
    end)
    |> Enum.reverse()
  end

  @doc "A toolbar of related controls with orientation-aware keyboard navigation."
  attr(:id, :string, default: nil)
  attr(:label, :string, default: nil)
  attr(:orientation, :string, default: "horizontal", values: ~w(horizontal vertical))
  attr(:attached, :boolean, default: false)
  attr(:class, :any, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def toolbar(assigns) do
    if is_nil(assigns.label) && !Map.has_key?(assigns.rest, :"aria-label") &&
         !Map.has_key?(assigns.rest, "aria-label") &&
         !Map.has_key?(assigns.rest, :"aria-labelledby") &&
         !Map.has_key?(assigns.rest, "aria-labelledby"),
       do: raise(ArgumentError, "toolbar requires a label or aria-labelledby")

    ~H"""
    <div
      id={@id}
      role="toolbar"
      aria-label={@label}
      aria-orientation={@orientation}
      class={[
        "toolbar toolbar--#{@orientation} grid w-fit gap-2",
        @orientation == "horizontal" && "grid-flow-col items-center",
        @orientation == "vertical" &&
          "grid-flow-row items-start justify-start [&_.button-group]:justify-start",
        @attached && "toolbar--attached rounded-[6px] bg-surface p-1 shadow-overlay",
        @class
      ]}
      data-slot="toolbar"
      data-olis-toolbar
      data-orientation={@orientation}
      x-data="olisToolbar"
      x-on:focusin="onFocusIn($event)"
      x-on:keydown="onKeyDown($event)"
      x-on:phx:update.window="sync()"
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc "Groups adjacent buttons; named button slots inherit group defaults."
  attr(:label, :string, default: nil)
  attr(:orientation, :string, default: "horizontal", values: ~w(horizontal vertical))

  attr(:variant, :string,
    default: "primary",
    values: ~w(primary secondary tertiary outline ghost danger danger-soft)
  )

  attr(:size, :string, default: "md", values: ~w(sm md lg))
  attr(:disabled, :boolean, default: false)
  attr(:full_width, :boolean, default: false)
  attr(:show_separators, :boolean, default: false)
  attr(:class, :any, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  slot :button do
    attr(:variant, :string)
    attr(:size, :string)
    attr(:disabled, :boolean)
    attr(:pending, :boolean)
    attr(:full_width, :boolean)
    attr(:type, :string)
    attr(:icon_only, :boolean)
    attr(:aria_label, :string)
    attr(:on_click, :any)
    attr(:target, :any)
    attr(:name, :string)
    attr(:value, :any)
    attr(:form, :string)
    attr(:class, :any)
  end

  def button_group(assigns) do
    ~H"""
    <div
      role="group"
      aria-label={@label}
      data-slot="button-group"
      data-orientation={@orientation}
      class={[
        "button-group button-group--#{@orientation} inline-flex h-auto items-center justify-center gap-0 [&_.button]:rounded-none [&_.button:active]:transform-none! [&_.button[data-pressed=true]]:transform-none! [&_.button:focus-visible:not([data-focused])]:z-10 [&_.button[data-focus-visible=true]]:z-10",
        @orientation == "horizontal" &&
          "flex-row [&_.button:first-child]:rounded-s-[6px] [&_.button:last-child]:rounded-e-[6px] [&_.button:only-child]:rounded-[6px] [&_.button--outline:first-child]:border-e-0 [&_.button--outline:last-child]:border-s-0 [&_.button--outline:not(:first-child):not(:last-child)]:border-x-0",
        @orientation == "vertical" &&
          "flex-col [&_.button:first-child]:rounded-t-[6px] [&_.button:last-child]:rounded-b-[6px] [&_.button:only-child]:rounded-[6px] [&_.button--outline:first-child]:border-b-0 [&_.button--outline:last-child]:border-t-0 [&_.button--outline:not(:first-child):not(:last-child)]:border-y-0",
        @full_width && "button-group--full-width w-full",
        @class
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
      <.button
        :for={{button, index} <- Enum.with_index(@button)}
        variant={Map.get(button, :variant) || @variant}
        size={Map.get(button, :size) || @size}
        disabled={if is_nil(Map.get(button, :disabled)), do: @disabled, else: button.disabled}
        pending={Map.get(button, :pending, false)}
        type={Map.get(button, :type) || "button"}
        icon_only={Map.get(button, :icon_only, false)}
        full_width={if is_nil(Map.get(button, :full_width)), do: @full_width, else: button.full_width}
        class={Map.get(button, :class)}
        aria-label={Map.get(button, :aria_label)}
        phx-click={Map.get(button, :on_click)}
        phx-target={Map.get(button, :target)}
        name={Map.get(button, :name)}
        value={Map.get(button, :value)}
        form={Map.get(button, :form)}
      ><.button_group_separator :if={@show_separators && index > 0} />{render_slot(button)}</.button>
    </div>
    """
  end

  @doc "A decorative separator inside an attached button group button."
  attr(:class, :any, default: nil)
  attr(:rest, :global)

  def button_group_separator(assigns) do
    ~H"""
    <span
      class={[
        "button-group__separator pointer-events-none absolute rounded-sm bg-current opacity-15 transition-opacity duration-150 ease-(--ease-smooth) [.button-group--horizontal_&]:start-[-1px] [.button-group--horizontal_&]:top-1/4 [.button-group--horizontal_&]:h-1/2 [.button-group--horizontal_&]:w-px [.button-group--vertical_&]:start-1/4 [.button-group--vertical_&]:top-[-1px] [.button-group--vertical_&]:h-px [.button-group--vertical_&]:w-1/2",
        @class
      ]}
      data-slot="button-group-separator"
      aria-hidden="true"
      {@rest}
    ></span>
    """
  end

  @doc "A toggle button. Set `pressed` for LiveView control, or `default_pressed` for Alpine-managed state."
  attr(:pressed, :boolean, default: nil)
  attr(:default_pressed, :boolean, default: false)
  attr(:disabled, :boolean, default: false)
  attr(:size, :string, default: nil, values: [nil, "sm", "md", "lg"])
  attr(:variant, :string, default: "default", values: ~w(default ghost))
  attr(:icon_only, :boolean, default: false)
  attr(:class, :any, default: nil)
  attr(:rest, :global, include: ~w(name value form))
  slot(:inner_block, required: true)

  def toggle_button(assigns) do
    uncontrolled = is_nil(assigns.pressed)
    selected = if uncontrolled, do: assigns.default_pressed, else: assigns.pressed
    assigns = assign(assigns, uncontrolled: uncontrolled, selected: selected)

    ~H"""
    <button
      type="button"
      disabled={@disabled}
      aria-pressed={to_string(@selected)}
      data-selected={if @selected, do: "true"}
      data-slot="toggle-button"
      data-olis-toggle-size={@size}
      x-data={if @uncontrolled, do: "{ selected: #{to_string(@selected)} }"}
      x-bind:aria-pressed={
        if @uncontrolled,
          do:
            "$el.closest('[data-olis-toggle-group]')?.dataset.olisToggleGroup !== 'managed' ? selected.toString() : null"
      }
      x-bind:data-selected={
        if @uncontrolled,
          do:
            "$el.closest('[data-olis-toggle-group]')?.dataset.olisToggleGroup !== 'managed' && selected ? 'true' : null"
      }
      x-on:click={
        if @uncontrolled,
          do:
            "if ($el.closest('[data-olis-toggle-group]')?.dataset.olisToggleGroup !== 'managed') { selected = !selected }"
      }
      phx-mounted={
        if @uncontrolled, do: Phoenix.LiveView.JS.ignore_attributes(["aria-pressed", "data-selected"])
      }
      class={[
        "toggle-button toggle-button--#{@size || "md"} relative isolate inline-flex origin-center items-center justify-center gap-2 rounded-[6px] text-sm font-medium whitespace-nowrap outline-none select-none no-highlight transform-gpu cursor-(--cursor-interactive) [transition:transform_250ms_var(--ease-smooth),background-color_100ms_var(--ease-out),box-shadow_100ms_var(--ease-out)] [&:focus-visible:not([data-focused])]:status-focused data-[focus-visible=true]:status-focused disabled:status-disabled aria-disabled:status-disabled [&_svg]:pointer-events-none [&_svg]:-mx-0.5 [&_svg]:my-0.5 [&_svg]:shrink-0 [&_svg]:self-center sm:[&_svg]:my-1",
        "[&.toggle-button--sm]:h-9 [&.toggle-button--sm]:text-sm [&.toggle-button--sm]:md:h-8 [&.toggle-button--sm]:active:[transform:scale(.98)] [&.toggle-button--sm][data-pressed=true]:[transform:scale(.98)] [&.toggle-button--sm_svg]:size-4",
        "[&.toggle-button--md]:h-10 [&.toggle-button--md]:text-sm [&.toggle-button--md]:md:h-9 [&.toggle-button--md]:active:[transform:scale(.97)] [&.toggle-button--md][data-pressed=true]:[transform:scale(.97)] [&.toggle-button--md_svg]:size-5 [&.toggle-button--md_svg]:sm:size-4",
        "[&.toggle-button--lg]:h-11 [&.toggle-button--lg]:text-base [&.toggle-button--lg]:md:h-10 [&.toggle-button--lg]:active:[transform:scale(.96)] [&.toggle-button--lg][data-pressed=true]:[transform:scale(.96)] [&.toggle-button--lg_svg]:size-5 [&.toggle-button--lg_svg]:sm:size-4",
        @variant == "default" &&
          "bg-default text-current hover:bg-default-hover [@media(hover:hover)]:data-[hovered=true]:bg-default-hover active:bg-default-hover data-[pressed=true]:bg-default-hover",
        @variant == "ghost" &&
          "bg-transparent text-default-foreground hover:bg-default [@media(hover:hover)]:data-[hovered=true]:bg-default active:bg-default data-[pressed=true]:bg-default",
        "data-[selected=true]:bg-accent-soft data-[selected=true]:text-accent-soft-foreground [@media(hover:hover)]:[&[data-selected=true]:hover]:bg-accent-soft-hover [@media(hover:hover)]:[&[data-selected=true][data-hovered=true]]:bg-accent-soft-hover [&[data-selected=true]:active]:bg-accent-soft-hover [&[data-selected=true][data-pressed=true]]:bg-accent-soft-hover",
        !@icon_only &&
          "w-fit [&.toggle-button--sm]:px-3 [&.toggle-button--md]:px-4 [&.toggle-button--lg]:px-4",
        @icon_only &&
          "p-0 [&.toggle-button--sm]:w-9 [&.toggle-button--sm]:md:w-8 [&.toggle-button--md]:w-10 [&.toggle-button--md]:md:w-9 [&.toggle-button--lg]:w-11 [&.toggle-button--lg]:md:w-10",
        "toggle-button--#{@variant}",
        @icon_only && "toggle-button--icon-only",
        @class
      ]}
      {@rest}
    >{render_slot(@inner_block)}</button>
    """
  end

  @doc """
  Groups toggle buttons. The default retains independently managed buttons.
  Set `selection_mode` to `single` or `multiple` to manage the group. Give each
  child a unique `value`, `data-key`, or `id`. Pass `selected_keys` for LiveView
  control, or `default_selected_keys` for Alpine-managed selection. The
  `on_selection_change` event receives a JSON-encoded `keys` parameter. Group
  `size` is inherited unless a child specifies its own; `disabled` disables all
  descendants using a native fieldset.
  """
  attr(:label, :string, required: true)
  attr(:orientation, :string, default: "horizontal", values: ~w(horizontal vertical))
  attr(:detached, :boolean, default: false)
  attr(:full_width, :boolean, default: false)
  attr(:size, :string, default: nil, values: [nil, "sm", "md", "lg"])
  attr(:disabled, :boolean, default: false)
  attr(:selection_mode, :string, default: nil, values: [nil, "single", "multiple"])
  attr(:selected_keys, :list, default: nil)
  attr(:default_selected_keys, :list, default: [])
  attr(:disallow_empty_selection, :boolean, default: false)
  attr(:on_selection_change, :any, default: nil)
  attr(:target, :any, default: nil)
  attr(:class, :any, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def toggle_button_group(assigns) do
    keys = assigns.selected_keys || assigns.default_selected_keys

    if !is_list(keys) || Enum.any?(keys, &(not is_binary(&1) || &1 == "")) ||
         length(keys) != length(Enum.uniq(keys)),
       do: raise(ArgumentError, "toggle button group keys must be unique nonempty strings")

    if assigns.selection_mode == "single" && length(keys) > 1,
      do: raise(ArgumentError, "single-selection toggle button groups accept at most one key")

    if is_nil(assigns.selection_mode) &&
         (!is_nil(assigns.selected_keys) || assigns.default_selected_keys != [] ||
            assigns.disallow_empty_selection || !is_nil(assigns.on_selection_change)),
       do: raise(ArgumentError, "set selection_mode to manage group selection")

    assigns = assign(assigns, :encoded_keys, Jason.encode!(keys))

    ~H"""
    <fieldset
      role="group"
      aria-label={@label}
      aria-disabled={if @disabled, do: "true"}
      disabled={@disabled}
      data-olis-toggle-size={@size}
      data-olis-toggle-group={if @selection_mode, do: "managed", else: "independent"}
      data-selection-mode={@selection_mode}
      data-orientation={@orientation}
      data-controlled={if @selection_mode, do: to_string(!is_nil(@selected_keys))}
      data-selected-keys={if @selection_mode, do: @encoded_keys}
      data-disallow-empty={if @selection_mode, do: to_string(@disallow_empty_selection)}
      x-data="olisToggleButtonGroup"
      x-on:click={if @selection_mode, do: "click($event)"}
      x-on:focusin={if @selection_mode, do: "focus($event)"}
      x-on:keydown={if @selection_mode, do: "keydown($event)"}
      x-on:phx:update.window="sync()"
      class={[
        "toggle-button-group toggle-button-group--#{@orientation} inline-flex h-auto items-center justify-center [&_.toggle-button:active]:transform-none! [&_.toggle-button[data-pressed=true]]:transform-none! [&_.toggle-button:focus-visible:not([data-focused])]:ring-inset [&_.toggle-button:focus-visible:not([data-focused])]:[--tw-ring-offset-width:0px] [&_.toggle-button[data-focus-visible=true]]:ring-inset [&_.toggle-button[data-focus-visible=true]]:[--tw-ring-offset-width:0px] [&_.toggle-button-group__separator]:pointer-events-none [&_.toggle-button-group__separator]:absolute [&_.toggle-button-group__separator]:rounded-sm [&_.toggle-button-group__separator]:bg-current [&_.toggle-button-group__separator]:opacity-15 [&_.toggle-button-group__separator]:transition-opacity [&_.toggle-button-group__separator]:duration-150 [&_.toggle-button-group__separator]:ease-(--ease-smooth)",
        !@full_width && "w-fit",
        @orientation == "horizontal" &&
          "flex-row [&_.toggle-button-group__separator]:start-[-1px] [&_.toggle-button-group__separator]:top-1/4 [&_.toggle-button-group__separator]:h-1/2 [&_.toggle-button-group__separator]:w-px",
        @orientation == "vertical" &&
          "flex-col [&_.toggle-button-group__separator]:start-1/4 [&_.toggle-button-group__separator]:top-[-1px] [&_.toggle-button-group__separator]:h-px [&_.toggle-button-group__separator]:w-1/2",
        !@detached && "gap-0 [&_.toggle-button]:rounded-none",
        !@detached && @orientation == "horizontal" &&
          "[&_.toggle-button:first-child]:rounded-s-[6px] [&_.toggle-button:last-child]:rounded-e-[6px] [&_.toggle-button:only-child]:rounded-[6px]",
        !@detached && @orientation == "vertical" &&
          "[&_.toggle-button:first-child]:rounded-t-[6px] [&_.toggle-button:last-child]:rounded-b-[6px] [&_.toggle-button:only-child]:rounded-[6px]",
        @detached &&
          "toggle-button-group--detached gap-1 [&_.toggle-button]:rounded-[6px] [&_.toggle-button-group__separator]:hidden",
        @full_width && "[&_.toggle-button]:flex-1",
        @full_width && "toggle-button-group--full-width w-full",
        @class
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
      <button
        :if={@selection_mode && @on_selection_change}
        type="button"
        hidden
        data-olis-toggle-group-event
        phx-click={@on_selection_change}
        phx-target={@target}
      ></button>
    </fieldset>
    """
  end

  @doc "A breadcrumb navigation trail; the last item denotes the current page."
  attr(:label, :string, default: "Breadcrumb")
  attr(:class, :any, default: nil)

  slot :item, required: true do
    attr(:label, :string, required: true)
    attr(:href, :string)
  end

  def breadcrumbs(assigns) do
    assigns = assign(assigns, :last_index, length(assigns.item) - 1)

    ~H"""
    <nav aria-label={@label}>
      <ol class={["breadcrumbs flex items-center gap-1.5", @class]}>
        <li
          :for={{item, index} <- Enum.with_index(@item)}
          class="breadcrumbs__item flex shrink-0 items-center justify-center gap-1"
        >
          <a
            :if={index != @last_index && Map.get(item, :href)}
            href={item.href}
            class="breadcrumbs__link relative text-sm leading-5 font-medium text-muted no-underline opacity-100 hover:underline data-[hovered=true]:underline data-[current=true]:text-link data-[current=true]:opacity-100"
          >{item.label}</a>
          <span
            :if={index == @last_index || !Map.get(item, :href)}
            class="breadcrumbs__link relative text-sm leading-5 font-medium text-muted no-underline opacity-100 hover:underline data-[hovered=true]:underline data-[current=true]:text-link data-[current=true]:opacity-100"
            data-current={if index == @last_index, do: "true"}
            aria-current={if index == @last_index, do: "page"}
          >{item.label}</span>
          <svg
            :if={index != @last_index}
            class="breadcrumbs__separator size-3 text-muted rtl:rotate-180"
            aria-hidden="true"
            viewBox="0 0 16 16"
            fill="none"
          ><path
            d="m6 3 5 5-5 5"
            stroke="currentColor"
            stroke-width="1.5"
            stroke-linecap="round"
            stroke-linejoin="round"
          /></svg>
        </li>
      </ol>
    </nav>
    """
  end

  @doc """
  A selectable listbox with keyboard navigation. Use `selected_keys` for
  LiveView-controlled selection or `default_selected_keys` for local selection.
  The existing `selected` and `on_select` API remains server-controlled.
  `on_selection_change` receives JSON-encoded `keys`, and `on_action` receives
  `value`. Group options with `:section` and its `items` list.
  """
  attr(:id, :string, required: true)
  attr(:label, :string, required: true)
  attr(:on_select, :any, default: nil)
  attr(:on_selection_change, :any, default: nil)
  attr(:on_action, :any, default: nil)
  attr(:selected, :list, default: nil)
  attr(:selected_keys, :list, default: nil)
  attr(:default_selected_keys, :list, default: nil)
  attr(:selection_mode, :string, default: "single", values: ~w(none single multiple))
  attr(:disabled, :boolean, default: false)
  attr(:target, :any, default: nil)
  attr(:class, :any, default: nil)

  slot :option do
    attr(:value, :string, required: true)
    attr(:label, :string, required: true)
    attr(:description, :string)
    attr(:disabled, :boolean)
    attr(:text_value, :string)
    attr(:variant, :string, values: ~w(default danger))
  end

  slot :section do
    attr(:label, :string, required: true)
    attr(:items, :list, required: true)
  end

  def listbox(assigns) do
    options = assigns.option ++ Enum.flat_map(assigns.section, & &1.items)
    values = Enum.map(options, &Map.get(&1, :value))
    selected = assigns.selected_keys || assigns.selected || assigns.default_selected_keys || []

    controlled =
      !is_nil(assigns.selected_keys) || !is_nil(assigns.selected) ||
        (!is_nil(assigns.on_select) && is_nil(assigns.default_selected_keys))

    if Enum.any?(
         options,
         &(not is_binary(Map.get(&1, :value)) or not is_binary(Map.get(&1, :label)))
       ) or
         length(values) != length(Enum.uniq(values)),
       do: raise(ArgumentError, "listbox options require unique string values and labels")

    if !is_nil(assigns.selected_keys) and !is_nil(assigns.selected),
      do: raise(ArgumentError, "listbox cannot combine selected and selected_keys")

    if controlled and !is_nil(assigns.default_selected_keys),
      do: raise(ArgumentError, "listbox cannot combine controlled and default selection")

    if Enum.any?(selected, &(not is_binary(&1))) or
         length(selected) != length(Enum.uniq(selected)),
       do: raise(ArgumentError, "listbox selected keys must be unique strings")

    if assigns.selection_mode == "none" and selected != [],
      do: raise(ArgumentError, "listbox with selection_mode none cannot have selected keys")

    if assigns.selection_mode == "single" and length(selected) > 1,
      do: raise(ArgumentError, "single-selection listbox accepts at most one selected value")

    enabled = Enum.reject(options, &Map.get(&1, :disabled, false))
    active = Enum.find(enabled, &(&1.value in selected)) || List.first(enabled)

    assigns =
      assign(assigns,
        active_id: if(active, do: listbox_option_id(assigns.id, active.value)),
        selected_values: selected,
        controlled: controlled,
        encoded_selected: Jason.encode!(selected)
      )

    ~H"""
    <div
      id={@id}
      class={[
        "list-box relative w-full overflow-clip p-1 [&>*+*]:mt-1 [&_[data-slot=separator][data-orientation=horizontal]]:ms-[3%] [&_[data-slot=separator][data-orientation=horizontal]]:w-[94%]",
        "olis-listbox outline-none",
        @class
      ]}
      role="listbox"
      aria-label={@label}
      aria-multiselectable={if @selection_mode == "multiple", do: "true"}
      aria-disabled={if @disabled, do: "true"}
      tabindex={if @disabled, do: "-1", else: "0"}
      aria-activedescendant={@active_id}
      data-olis-listbox
      data-selection-mode={@selection_mode}
      data-controlled={to_string(@controlled)}
      data-selected-keys={@encoded_selected}
      x-data="olisListbox"
      x-on:click="click($event)"
      x-on:keydown="keydown($event)"
      x-on:phx:update.window="sync()"
      phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["aria-activedescendant"])}
    >
      <.listbox_option
        :for={option <- @option}
        option={option}
        id={@id}
        selected={@selected_values}
        active_id={@active_id}
        disabled={@disabled}
        selection_mode={@selection_mode}
        on_select={@on_select}
        target={@target}
      />
      <div
        :for={{section, index} <- Enum.with_index(@section)}
        class="list-box-section flex flex-col items-start gap-0"
        role="group"
        aria-labelledby={"#{@id}-section-#{index}"}
      >
        <div
          id={"#{@id}-section-#{index}"}
          class="header w-full px-2 pt-1.5 pb-1 text-start text-xs font-medium text-muted"
          data-slot="header"
        >
          {section.label}
        </div>
        <.listbox_option
          :for={option <- section.items}
          option={option}
          id={@id}
          selected={@selected_values}
          active_id={@active_id}
          disabled={@disabled}
          selection_mode={@selection_mode}
          on_select={@on_select}
          target={@target}
        />
      </div>
      <button
        :if={@on_selection_change}
        type="button"
        hidden
        data-olis-listbox-selection-event
        phx-click={@on_selection_change}
        phx-target={@target}
      ></button>
      <button
        :if={@on_action}
        type="button"
        hidden
        data-olis-listbox-action-event
        phx-click={@on_action}
        phx-target={@target}
      ></button>
    </div>
    """
  end

  attr(:option, :map, required: true)
  attr(:id, :string, required: true)
  attr(:selected, :list, required: true)
  attr(:active_id, :string, default: nil)
  attr(:disabled, :boolean, required: true)
  attr(:selection_mode, :string, required: true)
  attr(:on_select, :any, default: nil)
  attr(:target, :any, default: nil)

  defp listbox_option(assigns) do
    ~H"""
    <div
      id={listbox_option_id(@id, @option.value)}
      role="option"
      aria-labelledby={"#{listbox_option_id(@id, @option.value)}-label"}
      aria-describedby={
        if Map.get(@option, :description), do: "#{listbox_option_id(@id, @option.value)}-description"
      }
      aria-selected={if @selection_mode != "none", do: to_string(@option.value in @selected)}
      aria-disabled={if @disabled || Map.get(@option, :disabled, false), do: "true"}
      data-disabled={if @disabled || Map.get(@option, :disabled, false), do: "true"}
      data-active={if listbox_option_id(@id, @option.value) == @active_id, do: "true"}
      data-key={@option.value}
      data-text-value={Map.get(@option, :text_value) || @option.label}
      phx-click={if !@disabled && !Map.get(@option, :disabled, false), do: @on_select}
      phx-value-value={@option.value}
      phx-target={@target}
      phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["data-active"])}
      class={[list_box_item_classes(), "list-box-item--#{Map.get(@option, :variant, "default")}"]}
    >
      <span class="olis-listbox-text flex flex-col min-w-0"><span
        id={"#{listbox_option_id(@id, @option.value)}-label"}
        data-slot="label"
      >
        <%= if Map.get(@option, :inner_block) do %>
          {render_slot(@option)}
        <% else %>
          {@option.label}
        <% end %>
      </span><span
        :if={Map.get(@option, :description)}
        id={"#{listbox_option_id(@id, @option.value)}-description"}
        class="description text-xs text-wrap wrap-break-word text-muted"
        data-slot="description"
      >{@option.description}</span></span>
      <span
        :if={@selection_mode != "none"}
        class={list_box_indicator_classes()}
        aria-hidden="true"
        hidden={@option.value not in @selected}
        data-olis-listbox-indicator
      ><svg data-slot="list-box-item-indicator--checkmark" viewBox="0 0 16 16" fill="none"><path
        d="M3.5 8l3 3 6-6"
        stroke="currentColor"
        stroke-width="2"
        stroke-linecap="round"
        stroke-linejoin="round"
      /></svg></span>
    </div>
    """
  end

  @doc """
  A group of selectable or removable tags. `selected` and `on_select` keep the
  existing server-controlled API; `on_select` receives `%{"value" => value}`.
  Use `selected_keys` for controlled selection, or `default_selected_keys` for
  Alpine-managed selection. `on_selection_change` receives JSON-encoded `keys`.
  The optional `:remove_button` slot customizes a tag's removal button by
  `value`; its content must not include interactive elements.
  """
  attr(:id, :string, required: true)
  attr(:label, :string, required: true)
  attr(:description, :string, default: nil)
  attr(:errors, :list, default: [])
  attr(:selection_mode, :string, default: "none", values: ~w(none single multiple))
  attr(:selected, :list, default: nil)
  attr(:selected_keys, :list, default: nil)
  attr(:default_selected_keys, :list, default: nil)
  attr(:on_select, :any, default: nil)
  attr(:on_selection_change, :any, default: nil)
  attr(:on_remove, :any, default: nil)
  attr(:disabled, :boolean, default: false)
  attr(:target, :any, default: nil)
  attr(:size, :string, default: "md", values: ~w(sm md lg))
  attr(:variant, :string, default: "default", values: ~w(default surface))
  attr(:class, :any, default: nil)

  slot :tag do
    attr(:value, :string, required: true)
    attr(:label, :string, required: true)
    attr(:disabled, :boolean)
  end

  slot :remove_button do
    attr(:value, :string, required: true)
    attr(:label, :string)
    attr(:class, :any)
  end

  slot(:empty)

  def tag_group(assigns) do
    values = Enum.map(assigns.tag, & &1.value)

    if length(values) != length(Enum.uniq(values)),
      do: raise(ArgumentError, "tag values must be unique")

    remove_values = Enum.map(assigns.remove_button, & &1.value)

    if length(remove_values) != length(Enum.uniq(remove_values)),
      do: raise(ArgumentError, "remove button values must be unique")

    invalid_remove_label? =
      Enum.any?(assigns.remove_button, fn slot ->
        label = Map.get(slot, :label)
        !is_nil(label) && (!is_binary(label) || String.trim(label) == "")
      end)

    if invalid_remove_label? do
      raise ArgumentError, "remove button labels must not be empty"
    end

    if !is_nil(assigns.selected) && !is_nil(assigns.selected_keys),
      do: raise(ArgumentError, "provide selected or selected_keys, not both")

    if (!is_nil(assigns.selected) || !is_nil(assigns.selected_keys)) &&
         !is_nil(assigns.default_selected_keys),
       do:
         raise(
           ArgumentError,
           "default_selected_keys cannot be combined with controlled selection"
         )

    selected = assigns.selected || assigns.selected_keys || assigns.default_selected_keys || []

    if Enum.any?(selected, &(not is_binary(&1))) ||
         length(selected) != length(Enum.uniq(selected)),
       do: raise(ArgumentError, "selected tag keys must be unique strings")

    if assigns.selection_mode == "single" and length(selected) > 1,
      do: raise(ArgumentError, "single-selection tag group accepts at most one selected value")

    controlled =
      !is_nil(assigns.selected) || !is_nil(assigns.selected_keys) ||
        (!is_nil(assigns.on_select) && is_nil(assigns.default_selected_keys))

    enabled = Enum.reject(assigns.tag, &Map.get(&1, :disabled, false))
    active = Enum.find(enabled, &(&1.value in selected)) || List.first(enabled)

    describedby =
      [
        assigns.description && "#{assigns.id}-description",
        assigns.errors != [] && "#{assigns.id}-errors"
      ]
      |> Enum.filter(& &1)
      |> Enum.join(" ")

    assigns =
      assigns
      |> assign(:active_value, if(active, do: active.value))
      |> assign(:remove_buttons, Map.new(assigns.remove_button, &{&1.value, &1}))
      |> assign(:selected_values, selected)
      |> assign(:controlled, controlled)
      |> assign(:encoded_selected, Jason.encode!(selected))
      |> assign(:describedby, describedby)

    ~H"""
    <div
      class={[
        "tag-group relative flex flex-col gap-1 [&_[slot=description]]:p-1 [&_[data-slot=description]]:p-1 [&_[slot=errorMessage]]:p-1 [&_[data-slot=error-message]]:p-1",
        @class
      ]}
      data-slot="tag-group"
    >
      <span id={"#{@id}-label"} class={label_classes()}>{@label}</span>
      <div
        id={@id}
        class="tag-group__list relative flex flex-wrap gap-1.5"
        data-slot="tag-group-list"
        data-olis-tag-group
        data-selection-mode={@selection_mode}
        data-controlled={to_string(@controlled)}
        data-selected-keys={@encoded_selected}
        data-selection-event-id={if @on_selection_change, do: "#{@id}-selection-event"}
        x-data="olisTagGroup"
        x-on:focusin="onFocus($event)"
        x-on:click="onClick($event)"
        x-on:keydown="onKeyDown($event)"
        x-on:phx:update.document="sync()"
        role="grid"
        aria-labelledby={"#{@id}-label"}
        aria-describedby={if @describedby != "", do: @describedby}
        aria-multiselectable={if @selection_mode == "multiple", do: "true"}
        aria-disabled={if @disabled, do: "true"}
        tabindex={if @disabled || @active_value, do: "-1", else: "0"}
      >
        <div
          :for={tag <- @tag}
          id={listbox_option_id(@id, tag.value)}
          role="row"
          class={[
            "tag tag--#{@size} tag--#{@variant} relative inline-flex origin-center items-center gap-1 rounded-[4px] font-normal select-none no-highlight transform-gpu cursor-(--cursor-interactive) [--optical-offset:0.031em] [transition:color_100ms_var(--ease-smooth),scale_100ms_var(--ease-smooth),opacity_100ms_var(--ease-smooth),background-color_100ms_var(--ease-smooth),box-shadow_100ms_var(--ease-out)] [&_svg]:pointer-events-none [&_svg]:size-3 [&_svg]:shrink-0 [&_svg]:self-center [&_svg]:text-current data-[disabled=true]:status-disabled aria-disabled:status-disabled focus-visible:status-focused data-[focus-visible]:status-focused [&:is([data-selected=true],[aria-selected=true])]:bg-accent-soft [&:is([data-selected=true],[aria-selected=true])]:text-accent-soft-foreground [@media(hover:hover)]:[&:is([data-selected=true],[aria-selected=true]):is(:hover,[data-hovered=true])]:bg-accent-soft-hover",
            @size == "sm" && "px-2 py-0.5 text-xs",
            @size == "md" && "px-2 py-1 text-xs",
            @size == "lg" && "px-2.5 py-1.5 text-sm",
            @variant == "default" &&
              "bg-default text-default-foreground [@media(hover:hover)]:[&:is(:hover,[data-hovered=true]):not([data-selected=true]):not([data-disabled=true])]:bg-default-hover",
            @variant == "surface" &&
              "bg-surface text-surface-foreground [@media(hover:hover)]:[&:is(:hover,[data-hovered=true]):not([data-selected=true]):not([data-disabled=true])]:bg-surface-hover"
          ]}
          data-slot="tag"
          data-olis-tag
          data-key={tag.value}
          data-selection-mode={@selection_mode}
          data-disabled={if @disabled || Map.get(tag, :disabled, false), do: "true"}
          data-selected={if @selection_mode != "none" && tag.value in @selected_values, do: "true"}
          aria-label={tag.label}
          aria-selected={if @selection_mode != "none", do: to_string(tag.value in @selected_values)}
          aria-disabled={if @disabled || Map.get(tag, :disabled, false), do: "true"}
          aria-keyshortcuts={
            if @on_remove && !@disabled && !Map.get(tag, :disabled, false), do: "Delete Backspace"
          }
          tabindex={if !@disabled && tag.value == @active_value, do: "0", else: "-1"}
          phx-click={
            if !@disabled && !Map.get(tag, :disabled, false) && @selection_mode != "none",
              do: @on_select
          }
          phx-value-value={tag.value}
          phx-target={@target}
        >
          <div role="gridcell" class="contents">
            <%= if Map.get(tag, :inner_block) do %>
              {render_slot(tag)}
            <% else %>
              {tag.label}
            <% end %>
            <button
              :if={@on_remove}
              type="button"
              class={[
                close_button_classes(),
                "tag__remove-button touch-target size-3! text-inherit! [&_svg]:size-[inherit]! [&_svg]:shrink-0 [&_svg]:self-center [&_svg]:text-current",
                get_in(@remove_buttons, [tag.value, :class])
              ]}
              data-slot="tag-remove-button"
              data-olis-tag-remove
              aria-label={get_in(@remove_buttons, [tag.value, :label]) || "Remove #{tag.label}"}
              value={tag.value}
              disabled={@disabled || Map.get(tag, :disabled, false)}
              phx-click={@on_remove}
              phx-value-value={tag.value}
              phx-target={@target}
            >
              <%= if get_in(@remove_buttons, [tag.value, :inner_block]) do %>
                <span aria-hidden="true" class="contents">{render_slot(@remove_buttons[tag.value])}</span>
              <% else %>
                <svg aria-hidden="true" viewBox="0 0 16 16"><path
                  fill="currentColor"
                  fill-rule="evenodd"
                  clip-rule="evenodd"
                  d="M3.47 3.47a.75.75 0 0 1 1.06 0L8 6.94l3.47-3.47a.75.75 0 1 1 1.06 1.06L9.06 8l3.47 3.47a.75.75 0 1 1-1.06 1.06L8 9.06l-3.47 3.47a.75.75 0 0 1-1.06-1.06L6.94 8 3.47 4.53a.75.75 0 0 1 0-1.06Z"
                /></svg>
              <% end %>
            </button>
          </div>
        </div>
        <div :if={@tag == []} role="row">
          <div role="gridcell">{render_slot(@empty)}</div>
        </div>
      </div>
      <button
        :if={@on_selection_change}
        id={"#{@id}-selection-event"}
        type="button"
        hidden
        phx-click={@on_selection_change}
        phx-target={@target}
      ></button>
      <p
        :if={@description}
        id={"#{@id}-description"}
        class="description text-xs text-wrap wrap-break-word text-muted"
        data-slot="description"
      >
        {@description}
      </p>
      <div
        :if={@errors != []}
        id={"#{@id}-errors"}
        class="error-message h-auto text-xs wrap-break-word text-danger [transition:opacity_150ms_var(--ease-out),height_350ms_var(--ease-smooth)]"
        data-slot="error-message"
      >
        <p :for={error <- @errors}>{error}</p>
      </div>
    </div>
    """
  end

  defp listbox_option_id(id, value),
    do: id <> "-option-" <> Base.url_encode64(value, padding: false)
end
