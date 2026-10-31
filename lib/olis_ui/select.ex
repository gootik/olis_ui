defmodule OlisUI.Select do
  @moduledoc "Select, autocomplete, and combo box controls."
  use Phoenix.Component, global_prefixes: ~w(x-)
  import OlisUI.Shared

  attr(:name, :string, required: true)

  defp icon_template(assigns) do
    ~H"""
    <template data-olis-icon={@name}><OlisUI.Icon.icon name={@name} /></template>
    """
  end

  @doc "A select with a searchable popover, backed by a native form control."
  attr(:open, :boolean, default: false)
  attr(:on_open_change, :string, default: nil)
  attr(:target, :any, default: nil)
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
    value = if is_nil(assigns.value) && field, do: field.value, else: assigns.value

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
      data-open={to_string(@open)}
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
      <.icon_template name="check" />
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
            class="autocomplete__value olis-choice-value pointer-events-none"
            data-slot="autocomplete-value"
            data-olis-autocomplete-value
            data-placeholder="true"
          >{@placeholder}</span>
          <button
            type="button"
            class="autocomplete__clear-button olis-dismiss olis-dismiss--compact relative z-10"
            data-slot="autocomplete-clear-button"
            data-olis-autocomplete-clear
            data-empty="true"
            aria-label={"Clear #{@label}"}
            hidden={!@clearable}
          >
            <OlisUI.Icon.icon
              name="xmark"
              data-slot="autocomplete-clear-button-icon"
            />
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
            <OlisUI.Icon.icon
              name="chevron-down"
              class="autocomplete__indicator olis-choice-chevron"
              data-slot="autocomplete-default-indicator"
            />
          </button>
        </div>
        <div
          id={"#{@id}-popup"}
          class="autocomplete__popover olis-option-surface olis-overlay-motion"
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
                <OlisUI.Icon.icon
                  name="magnifier"
                  class="search-field__search-icon olis-field-symbol"
                  data-slot="search-field-search-icon"
                />
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
                  <OlisUI.Icon.icon
                    name="xmark"
                    data-slot="close-button-icon"
                  />
                </button>
              </div>
            </div>
            <div
              id={"#{@id}-listbox"}
              class="list-box olis-options"
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
      <button
        :if={@on_open_change}
        type="button"
        hidden
        data-olis-field-open-event
        phx-value-id={@id}
        phx-click={@on_open_change}
        phx-target={@target}
      ></button>
    </div>
    """
  end

  @doc "A searchable combo box backed by a native form control."
  attr(:open, :boolean, default: false)
  attr(:on_open_change, :string, default: nil)
  attr(:target, :any, default: nil)
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
    value = if is_nil(assigns.value) && field, do: field.value, else: assigns.value

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
        "combo-box olis-field",
        @full_width && "combo-box--full-width w-full",
        @class
      ]}
      data-olis-combo
      data-open={to_string(@open)}
      x-data="olisComboBox"
      x-on:input="input($event)"
      x-on:change="change($event)"
      x-on:keydown="keydown($event)"
      x-on:click="click($event)"
      x-on:pointerdown="pointerdown($event)"
      x-on:pointerdown.window="outside($event)"
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
      <.icon_template name="check" />
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
              "min-w-0 flex-1 has-[+.combo-box__trigger]:pe-7 data-[focus]:status-focused-field data-[focus]:border-field-border-focus data-[disabled]:status-disabled",
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
            class="combo-box__trigger olis-combo-trigger"
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
          ><OlisUI.Icon.icon
            name="chevron-down"
            data-slot="combo-box-trigger-default-icon"
          /></button>
        </div>
        <div
          :if={@selection_mode == "multiple"}
          id={"#{@id}-value"}
          class="combo-box__value olis-choice-value"
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
            "combo-box__popover olis-combo-popup olis-option-surface"
          ]}
          data-olis-combo-popup
          popover="manual"
          phx-update={if @allows_custom_value, do: "ignore"}
        >
          <div
            id={"#{@id}-listbox"}
            role="listbox"
            aria-multiselectable={if @selection_mode == "multiple", do: "true"}
            aria-labelledby={"#{@id}-label"}
            class="list-box olis-options"
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
      <button
        :if={@on_open_change}
        type="button"
        hidden
        data-olis-field-open-event
        phx-value-id={@id}
        phx-click={@on_open_change}
        phx-target={@target}
      ></button>
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
  Single-select popup visibility is managed through `open` and `on_open_change`.
  Multiple selects retain the browser's native interaction.
  """
  attr(:id, :string, required: true)
  attr(:open, :boolean, default: false)
  attr(:on_open_change, :string, default: nil)
  attr(:target, :any, default: nil)
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
        "select select--#{@variant} olis-native-select olis-field",
        @class
      ]}
      data-invalid={if @invalid, do: "true"}
      data-olis-select-root
      data-open={to_string(@open)}
      x-data="olisSelect"
      x-on:click.window="click($event)"
      x-on:keydown="keydown($event)"
      x-on:focusout="focusout($event)"
      x-on:toggle.capture="toggle($event)"
      x-on:invalid.capture="invalid($event)"
      x-on:change="change($event)"
      x-on:reset.window="reset($event)"
      x-on:resize.window="position()"
      x-on:scroll.window.capture="position()"
      x-on:phx:update.window="sync()"
      phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["data-enhanced"])}
    >
      <.icon_template name="check" />
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
        <OlisUI.Icon.icon
          name="chevron-down"
          class={[
            select_indicator_classes(),
            "olis-native-select-indicator size-4 pointer-events-none [.olis-native-select[data-enhanced=true]_&]:hidden [.olis-native-select-field:has(select[multiple])>&]:hidden [.olis-native-select-field:has(select[size]:not([size='1']))>&]:hidden"
          ]}
        />
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
              class="select__value olis-choice-value"
              data-olis-select-value
            ></span><OlisUI.Icon.icon
              name="chevron-down"
              class={[select_indicator_classes(), "size-4"]}
            />
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
              class="list-box olis-options"
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
      <button
        :if={@on_open_change}
        type="button"
        hidden
        data-olis-select-event
        phx-value-id={@id}
        phx-click={@on_open_change}
        phx-target={@target}
      ></button>
    </div>
    """
  end
end
