defmodule OlisUI.Selection do
  @moduledoc "Listboxes and tag groups."
  use Phoenix.Component, global_prefixes: ~w(x-)
  import OlisUI.Shared

  @doc """
  A selectable listbox with keyboard navigation. Use `selected_keys` for
  LiveView-controlled selection.
  `on_selection_change` receives JSON-encoded `keys`, and `on_action` receives
  `value`. Group options with `:section` and its `items` list.
  """
  attr(:id, :string, required: true)
  attr(:label, :string, required: true)
  attr(:on_selection_change, :any, default: nil)
  attr(:on_action, :any, default: nil)
  attr(:selected_keys, :list, default: [])
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
    selected = assigns.selected_keys

    enabled = Enum.reject(options, &Map.get(&1, :disabled, false))
    active = Enum.find(enabled, &(&1.value in selected)) || List.first(enabled)

    assigns =
      assign(assigns,
        active_id: if(active, do: listbox_option_id(assigns.id, active.value)),
        selected_values: selected,
        encoded_selected: Jason.encode!(selected)
      )

    ~H"""
    <div
      id={@id}
      class={[
        "list-box olis-options",
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
      ><OlisUI.Icon.icon name="check" data-slot="list-box-item-indicator--checkmark" /></span>
    </div>
    """
  end

  @doc """
  A group of selectable or removable tags.
  Use `selected_keys` for LiveView-controlled selection.
  `on_selection_change` receives JSON-encoded `keys`.
  The optional `:remove_button` slot customizes a tag's removal button by
  `value`; its content must not include interactive elements.
  """
  attr(:id, :string, required: true)
  attr(:label, :string, required: true)
  attr(:description, :string, default: nil)
  attr(:errors, :list, default: [])
  attr(:selection_mode, :string, default: "none", values: ~w(none single multiple))
  attr(:selected_keys, :list, default: [])
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
    selected = assigns.selected_keys

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
      |> assign(:encoded_selected, Jason.encode!(selected))
      |> assign(:describedby, describedby)

    ~H"""
    <div
      class={[
        "tag-group olis-field",
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
            "tag tag--#{@size} tag--#{@variant} olis-tag"
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
                "tag__remove-button touch-target",
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
                <OlisUI.Icon.icon name="xmark" />
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
        class="error-message olis-field-error olis-field-error--visible"
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
