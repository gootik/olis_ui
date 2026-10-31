defmodule OlisUI.Dropdown do
  @moduledoc "Action and selection menus."
  use Phoenix.Component, global_prefixes: ~w(x-)
  import OlisUI.Shared

  @doc """
  An action or selection menu with sections and nested submenus.
  Use `open` and `on_open_change` to manage visibility in LiveView.
  Register OlisUI's Alpine providers and use a browser with the Popover API.
  """
  attr(:id, :string, required: true)
  attr(:label, :string, required: true)

  attr(:variant, :string,
    default: "secondary",
    values: ~w(primary secondary tertiary outline ghost danger danger-soft)
  )

  attr(:open, :boolean, default: false)
  attr(:on_open_change, :string, default: nil)
  attr(:open_submenus, :list, default: [])
  attr(:on_submenus_change, :string, default: nil)
  attr(:selection_mode, :string, default: "none", values: ~w(none single multiple))
  attr(:selected_keys, :list, default: [])
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
    attr(:on_selection_change, :string)
    attr(:close_on_select, :boolean)
  end

  slot :section do
    attr(:label, :string, required: true)
    attr(:items, :list, required: true)
    attr(:selection_mode, :string)
    attr(:selected_keys, :list)
    attr(:on_selection_change, :string)
    attr(:close_on_select, :boolean)
  end

  def dropdown(assigns) do
    ~H"""
    <div
      id={@id}
      class={["dropdown olis-dropdown inline-flex flex-col gap-1", @class]}
      data-olis-dropdown
      data-open={to_string(@open)}
      data-open-submenus={Jason.encode!(@open_submenus)}
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
      x-on:phx:update.document="sync()"
    >
      <button
        type="button"
        class={[
          button_classes(@variant, "md"),
          "dropdown__trigger olis-overlay-trigger"
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
          class="dropdown__menu olis-dropdown-menu"
          data-slot="dropdown-menu"
          data-selection-mode={@selection_mode}
        >
          <.dropdown_group
            :if={@item != []}
            id={"#{@id}-root"}
            entries={@item}
            mode={@selection_mode}
            selected_keys={@selected_keys}
            on_selection_change={@on_selection_change}
            on_action={@on_action}
            target={@target}
            close_on_select={@close_on_select}
          />
          <%= for {section, index} <- Enum.with_index(@section) do %>
            <OlisUI.Display.separator :if={@item != [] || index > 0} />
            <.dropdown_group
              id={"#{@id}-section-#{index}"}
              label={section.label}
              entries={section.items}
              mode={Map.get(section, :selection_mode) || @selection_mode}
              selected_keys={Map.get(section, :selected_keys, @selected_keys)}
              on_selection_change={Map.get(section, :on_selection_change) || @on_selection_change}
              on_action={@on_action}
              target={@target}
              close_on_select={Map.get(section, :close_on_select, @close_on_select)}
            />
          <% end %>
        </div>
      </div>
      <button
        :if={@on_open_change}
        type="button"
        hidden
        data-olis-dropdown-open-event
        phx-value-id={@id}
        phx-click={@on_open_change}
        phx-target={@target}
      ></button>
      <button
        :if={@on_submenus_change}
        type="button"
        hidden
        data-olis-dropdown-submenus-event
        phx-value-id={@id}
        phx-click={@on_submenus_change}
        phx-target={@target}
      ></button>
    </div>
    """
  end

  attr(:id, :string, required: true)
  attr(:label, :string, default: nil)
  attr(:entries, :list, required: true)
  attr(:mode, :string, required: true)
  attr(:selected_keys, :list, default: [])
  attr(:on_selection_change, :string, default: nil)
  attr(:on_action, :string, default: nil)
  attr(:target, :any, default: nil)
  attr(:close_on_select, :boolean, default: nil)

  defp dropdown_group(assigns) do
    assigns = assign(assigns, selected: MapSet.new(assigns.selected_keys))

    ~H"""
    <div
      class={@label && "menu-section flex flex-col items-start gap-0"}
      role={if @label, do: "group"}
      aria-label={@label}
      data-olis-dropdown-group
      data-selection-mode={@mode}
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
  attr(:on_action, :string, default: nil)
  attr(:target, :any, default: nil)

  defp dropdown_entry(assigns) do
    entry = assigns.entry

    submenu = Map.get(entry, :items)

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
        <.dropdown_item_content entry={@entry} mode="none" checked={false} />
        <span
          class={[
            menu_indicator_classes(),
            "menu-item__indicator--submenu text-muted [.menu-item[data-has-submenu=true]_&]:start-auto [.menu-item[data-has-submenu=true]_&]:end-2 [&_svg]:size-3"
          ]}
          data-slot="submenu-indicator"
          aria-hidden="true"
        ><OlisUI.Icon.icon name="chevron-right" class="rtl:rotate-180" /></span>
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
          class="dropdown__menu olis-dropdown-menu"
          data-slot="dropdown-menu"
        >
          <.dropdown_group
            id={"#{@id}-nested"}
            entries={@submenu}
            mode={Map.get(@entry, :selection_mode, "none")}
            selected_keys={Map.get(@entry, :selected_keys, [])}
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
    >
      <.dropdown_item_content entry={@entry} mode={@mode} checked={@checked} />
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
      class={[
        menu_item_classes(),
        "menu-item--default",
        Map.get(@entry, :danger, false) && "menu-item--danger"
      ]}
    >
      <.dropdown_item_content entry={@entry} mode={@mode} checked={@checked} />
    </button>
    """
  end

  attr(:entry, :map, required: true)
  attr(:mode, :string, required: true)
  attr(:checked, :boolean, required: true)

  defp dropdown_item_content(assigns) do
    ~H"""
    <span :if={@mode != "none"} class={menu_indicator_classes()} aria-hidden="true">
      <OlisUI.Icon.icon
        name="check"
        data-slot="menu-item-indicator--checkmark"
        class={if !@checked, do: "invisible"}
      />
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
      class="kbd kbd--light olis-keycap"
      data-slot="keyboard"
    >{Map.get(
      @entry,
      :shortcut
    )}</kbd>
    """
  end
end
