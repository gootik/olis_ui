defmodule OlisUI.Groups do
  @moduledoc "Toolbars, button groups, toggles, and breadcrumbs."
  use Phoenix.Component, global_prefixes: ~w(x-)

  @doc "A toolbar of related controls with orientation-aware keyboard navigation."
  attr(:id, :string, default: nil)
  attr(:label, :string, default: nil)
  attr(:orientation, :string, default: "horizontal", values: ~w(horizontal vertical))
  attr(:attached, :boolean, default: false)
  attr(:class, :any, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def toolbar(assigns) do
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
        "button-group button-group--#{@orientation} inline-flex h-auto justify-center gap-0 [&_.button]:rounded-none [&_.button:active]:transform-none! [&_.button[data-pressed=true]]:transform-none! [&_.button:focus-visible:not([data-focused])]:z-10 [&_.button[data-focus-visible=true]]:z-10",
        @orientation == "horizontal" &&
          "flex-row items-center [&_.button:first-child]:rounded-s-[6px] [&_.button:last-child]:rounded-e-[6px] [&_.button:only-child]:rounded-[6px] [&_.button--outline:first-child]:border-e-0 [&_.button--outline:last-child]:border-s-0 [&_.button--outline:not(:first-child):not(:last-child)]:border-x-0",
        @orientation == "vertical" &&
          "flex-col items-stretch [&>.button]:w-full [&_.button:first-child]:rounded-t-[6px] [&_.button:last-child]:rounded-b-[6px] [&_.button:only-child]:rounded-[6px] [&_.button--outline:first-child]:border-b-0 [&_.button--outline:last-child]:border-t-0 [&_.button--outline:not(:first-child):not(:last-child)]:border-y-0",
        @full_width && "button-group--full-width w-full",
        @class
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
      <OlisUI.Button.button
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
      ><.button_group_separator :if={@show_separators && index > 0} />{render_slot(button)}</OlisUI.Button.button>
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
        "button-group__separator olis-action-rule",
        @class
      ]}
      data-slot="button-group-separator"
      aria-hidden="true"
      {@rest}
    ></span>
    """
  end

  @doc "A toggle button whose pressed state is managed by LiveView."
  attr(:pressed, :boolean, default: false)
  attr(:disabled, :boolean, default: false)
  attr(:size, :string, default: nil, values: [nil, "sm", "md", "lg"])
  attr(:variant, :string, default: "default", values: ~w(default ghost))
  attr(:icon_only, :boolean, default: false)
  attr(:class, :any, default: nil)
  attr(:rest, :global, include: ~w(name value form))
  slot(:inner_block, required: true)

  def toggle_button(assigns) do
    ~H"""
    <button
      type="button"
      disabled={@disabled}
      aria-pressed={to_string(@pressed)}
      data-selected={if @pressed, do: "true"}
      data-slot="toggle-button"
      data-olis-toggle-size={@size}
      class={[
        "toggle-button toggle-button--#{@size || "md"} olis-action",
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
  control. The
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
  attr(:selected_keys, :list, default: [])
  attr(:disallow_empty_selection, :boolean, default: false)
  attr(:on_selection_change, :any, default: nil)
  attr(:target, :any, default: nil)
  attr(:class, :any, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def toggle_button_group(assigns) do
    keys = assigns.selected_keys

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
      data-selected-keys={if @selection_mode, do: @encoded_keys}
      data-disallow-empty={if @selection_mode, do: to_string(@disallow_empty_selection)}
      x-data="olisToggleButtonGroup"
      x-on:click={if @selection_mode, do: "click($event)"}
      x-on:focusin={if @selection_mode, do: "focus($event)"}
      x-on:keydown={if @selection_mode, do: "keydown($event)"}
      x-on:phx:update.window="sync()"
      class={[
        "toggle-button-group toggle-button-group--#{@orientation} olis-toggle-group",
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
            class="breadcrumbs__link olis-crumb"
          >{item.label}</a>
          <span
            :if={index == @last_index || !Map.get(item, :href)}
            class="breadcrumbs__link olis-crumb"
            data-current={if index == @last_index, do: "true"}
            aria-current={if index == @last_index, do: "page"}
          >{item.label}</span>
          <OlisUI.Icon.icon
            :if={index != @last_index}
            name="chevron-right"
            class="breadcrumbs__separator size-3 text-muted rtl:rotate-180"
          />
        </li>
      </ol>
    </nav>
    """
  end
end
