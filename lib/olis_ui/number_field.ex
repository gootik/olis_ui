defmodule OlisUI.NumberField do
  @moduledoc "Number inputs with step controls."
  use Phoenix.Component, global_prefixes: ~w(x-)
  import OlisUI.Shared

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
  attr(:read_only, :boolean, default: false)
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
    field = assigns.field
    id = assigns.id || (field && field.id)
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
        "number-field number-field--#{@variant} olis-field",
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
        class={"number-field__group number-field__group--#{@variant} olis-field-frame"}
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
          class="number-field__decrement-button olis-step-control"
          data-slot="number-field-decrement-button"
          aria-label={"#{@decrement_label} #{@label}"}
          aria-controls={@id}
          tabindex="-1"
          disabled={@disabled || @read_only}
          data-olis-number-step="down"
          x-bind:disabled="locked || cannotDecrease"
          x-on:click="step('down')"
          phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["disabled"])}
        ><%= if @decrement_icon == [] do %>
          <OlisUI.Icon.icon
            name="minus"
            data-slot="number-field-decrement-button-icon"
          />
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
          readonly={@read_only}
          aria-invalid={if @invalid_state, do: "true"}
          aria-describedby={if @describedby != "", do: @describedby}
          class="number-field__input olis-field-entry"
          data-slot="number-field-input"
          {@rest}
        />
        <button
          type="button"
          slot="increment"
          class="number-field__increment-button olis-step-control"
          data-slot="number-field-increment-button"
          aria-label={"#{@increment_label} #{@label}"}
          aria-controls={@id}
          tabindex="-1"
          disabled={@disabled || @read_only}
          data-olis-number-step="up"
          x-bind:disabled="locked || cannotIncrease"
          x-on:click="step('up')"
          phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["disabled"])}
        ><%= if @increment_icon == [] do %>
          <OlisUI.Icon.icon
            name="plus"
            data-slot="number-field-increment-button-icon"
          />
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
end
