defmodule OlisUI.Checks do
  @moduledoc "Checkboxes and switches."
  use Phoenix.Component, global_prefixes: ~w(x-)
  import OlisUI.Shared

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
        }><OlisUI.Icon.icon
          :if={!@indeterminate}
          name="check"
          class="size-full"
          data-slot="checkbox-default-indicator--checkmark"
        /><OlisUI.Icon.icon
          :if={@indeterminate}
          name="minus"
          class="size-full"
          data-slot="checkbox-default-indicator--indeterminate"
        /></span></span>
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

    explicit_label =
      assigns.rest[:"aria-label"] || assigns.rest["aria-label"] ||
        assigns.rest[:"aria-labelledby"] || assigns.rest["aria-labelledby"]

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
        "switch switch--#{@size} olis-choice",
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
        class="switch__content olis-choice-body"
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
          class="switch__control olis-switch-track"
          data-slot="switch-control"
          aria-hidden="true"
        ><span
          class="switch__thumb olis-switch-thumb"
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
end
