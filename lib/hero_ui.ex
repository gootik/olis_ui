defmodule HeroUI do
  @moduledoc """
  HeroUI-inspired function components for Phoenix LiveView.

  Import this module in your HTML helpers and include the official HeroUI v3 styles and `assets/css/hero_ui.css` in your Tailwind v4 application stylesheet. See the README for setup and examples.
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
    <span class={["description", @class]} data-slot="description" {@rest}>
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
      class={["field-error", @class]}
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
    <span class={["error-message", @class]} data-slot="error-message" {@rest}>
      {render_slot(@inner_block)}
    </span>
    """
  end

  @doc "A native button with HeroUI variants and an optional focusable pending state."
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
        "button",
        "button--#{@variant}",
        "button--#{@size}",
        @full_width && "button--full-width",
        @icon_only && "button--icon-only",
        @class
      ]}
      {@rest}
    >{render_slot(@inner_block)}</button>
    """
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
      class={["close-button", "close-button--default", @class]}
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
      class={["input", "input--#{@variant}", @full_width && "input--full-width", @class]}
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
      class={["textfield", "textfield--full-width", @class]}
      data-slot="textfield"
      data-invalid={if @invalid_state, do: "true"}
      data-disabled={if @rest[:disabled] || @rest["disabled"], do: "true"}
      data-required={if @rest[:required] || @rest["required"], do: "true"}
      data-readonly={if @rest[:readonly] || @rest["readonly"], do: "true"}
    >
      <label :if={@label && @label != ""} class="label" data-slot="label" for={@id}>{@label}</label>
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
        class="description"
        data-slot="description"
        id={"#{@id}-description"}
      >{@description}</span>
      <div
        :if={@errors != []}
        class="field-error"
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
      class={["fieldset", @class]}
      data-slot="fieldset"
      aria-describedby={@describedby}
      {@rest}
    >
      <legend class="fieldset__legend" data-slot="fieldset-legend">
        {if @legend_content == [], do: @legend, else: render_slot(@legend_content)}
      </legend>
      <span :if={@description} id={"#{@id}-description"} class="description" data-slot="description">{@description}</span>
      <div class={["fieldset__field-group", @group_class]} data-slot="fieldset-field-group">
        {render_slot(@inner_block)}
      </div>
      <div
        :if={@actions != []}
        class={["fieldset__actions", @actions_class]}
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
      class={["textfield", @full_width && "textfield--full-width", @class]}
      data-invalid={if @invalid, do: "true"}
    >
      <label :if={@label} class="label" for={@id}>{@label}</label>
      <div
        class={[
          "input-group",
          "input-group--#{@variant}",
          @full_width && "input-group--full-width",
          @group_class
        ]}
        data-slot="input-group"
        data-hero-input-group
        x-data="heroInputGroup"
        x-on:click="focusInput($event)"
        data-invalid={if @invalid, do: "true"}
        data-disabled={if @disabled, do: "true"}
      >
        <div
          :for={prefix <- @prefix}
          class={["input-group__prefix", prefix[:class]]}
          data-slot="input-group-prefix"
        >
          {render_slot(prefix)}
        </div>
        <textarea
          :if={@multiline}
          id={@id}
          name={@name}
          disabled={@disabled}
          class={["input-group__input", @input_class]}
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
          class={["input-group__input", @input_class]}
          data-slot="input-group-input"
          aria-invalid={if @invalid, do: "true"}
          aria-describedby={if @describedby != "", do: @describedby}
          {@rest}
        />
        <div
          :for={suffix <- @suffix}
          class={["input-group__suffix", suffix[:class]]}
          data-slot="input-group-suffix"
        >
          {render_slot(suffix)}
        </div>
      </div>
      <p :if={@description} id={"#{@id}-description"} class="description" data-slot="description">
        {@description}
      </p>
      <div
        :if={@errors != []}
        id={"#{@id}-errors"}
        class="field-error"
        data-visible="true"
        data-slot="field-error"
      >
        <p :for={error <- @errors}>{error}</p>
      </div>
    </div>
    """
  end

  @doc "A search input with a clear button, form-field support, and HeroUI styles."
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
        "search-field",
        "search-field--#{@variant}",
        @full_width && "search-field--full-width",
        @class
      ]}
      data-hero-search-field
      data-slot="search-field"
      data-empty={to_string(is_nil(@value) || @value == "")}
      data-invalid={if @errors != [], do: "true"}
      x-data="heroSearchField"
      x-init="$nextTick(() => sync())"
      x-on:input="sync()"
      x-on:phx:update.window="sync()"
      x-on:reset.window="$nextTick(() => sync())"
      x-bind:data-empty="empty.toString()"
      x-bind:data-hero-search-ready="'true'"
      phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["data-empty", "data-hero-search-ready"])}
    >
      <label :if={@label} class="label" data-slot="label" for={@id}>{@label}</label>
      <div
        class={["search-field__group", @full_width && "search-field__group--full-width"]}
        data-slot="search-field-group"
        data-invalid={if @errors != [], do: "true"}
        data-disabled={if @rest[:disabled] || @rest["disabled"], do: "true"}
      >
        <svg
          aria-hidden="true"
          role="presentation"
          viewBox="0 0 16 16"
          class="search-field__search-icon"
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
          class="search-field__input"
          data-slot="search-field-input"
          aria-invalid={if @errors != [], do: "true"}
          aria-describedby={if @describedby != "", do: @describedby}
          {@rest}
        />
        <.close_button
          label="Clear search"
          class="search-field__clear-button"
          data-slot="search-field-clear-button"
          data-hero-search-clear
          slot="clear"
          hidden
          x-bind:hidden="false"
          x-bind:disabled="empty || locked"
          x-bind:aria-hidden="empty.toString()"
          x-on:click="clear()"
        />
      </div>
      <p :if={@description} id={"#{@id}-description"} class="description" data-slot="description">
        {@description}
      </p>
      <div
        :if={@errors != []}
        id={"#{@id}-errors"}
        class="field-error"
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
      <label :if={@label} class="label" for={@id}>{@label}</label>
      <p :if={@description} id={"#{@id}-description"} class="description">{@description}</p>
      <div
        id={"#{@id}-otp"}
        class={["input-otp", "input-otp--#{@variant}"]}
        data-hero-otp
        x-data="heroInputOTP"
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
        phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["data-hero-otp-ready"])}
      >
        <div id={"#{@id}-slots"} class="hui-otp-slots" aria-hidden="true">
          <%= for {group, index} <- Enum.with_index(@slot_groups) do %>
            <div :if={index > 0} class="input-otp__separator" data-slot="input-otp-separator"></div>
            <div class="input-otp__group" data-slot="input-otp-group">
              <div
                :for={slot <- group}
                class="input-otp__slot"
                data-slot="input-otp-slot"
                data-hero-otp-index={slot}
              >
                <span class="input-otp__slot-value" data-hero-otp-value hidden></span><span
                  class="input-otp__caret"
                  data-hero-otp-caret
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
          class="input input--primary input-otp__input"
          data-hero-otp-input
          x-ref="input"
          aria-invalid={if @errors != [], do: "true"}
          aria-describedby={if @describedby != "", do: @describedby}
          {@rest}
        />
      </div>
      <div :if={@errors != []} id={"#{@id}-errors"} class="field-error" data-visible="true">
        <p :for={error <- @errors}>{error}</p>
      </div>
    </div>
    """
  end

  @doc "A HeroUI-styled section header. Use `as` to select an appropriate semantic tag."
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
    <.dynamic_tag tag_name={@as} class={["header", @class]} data-slot={@data_slot} {@rest}>
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
    <.dynamic_tag tag_name={@as} class={["empty-state", @class]} data-slot={@data_slot} {@rest}>
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
    <div class={["card", "card--#{@variant}", @class]} data-slot={@data_slot} {@rest}>
      <div
        :if={@header != [] || @title != [] || @description != []}
        class={["card__header", @header_class]}
        data-slot="card-header"
      >
        {render_slot(@header)}
        <.dynamic_tag
          :for={title <- @title}
          tag_name={"h#{@heading_level}"}
          id={title[:id]}
          class={["card__title", title[:class]]}
          data-slot="card-title"
        >
          {render_slot(title)}
        </.dynamic_tag>
        <p
          :for={description <- @description}
          id={description[:id]}
          class={["card__description", description[:class]]}
          data-slot="card-description"
        >
          {render_slot(description)}
        </p>
      </div>
      {render_slot(@inner_block)}
      <div
        :for={content <- @content}
        id={content[:id]}
        class={["card__content", content[:class]]}
        data-slot="card-content"
      >
        {render_slot(content)}
      </div>
      <div
        :for={footer <- @footer}
        id={footer[:id]}
        class={["card__footer", footer[:class]]}
        data-slot="card-footer"
      >
        {render_slot(footer)}
      </div>
    </div>
    """
  end

  @doc "A compact label with HeroUI v3 color, variant, and size options."
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

    assigns =
      assign(assigns,
        data_slot: data_slot,
        rest: Map.drop(assigns.rest, [:"data-slot", "data-slot"])
      )

    ~H"""
    <span
      class={["chip", "chip--#{@variant}", "chip--#{@color}", "chip--#{@size}", @class]}
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
    <span class={["chip__label", @class]} data-slot={@data_slot} {@rest}>{render_slot(@inner_block)}</span>
    """
  end

  @doc "An accessible HeroUI loading indicator."
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
        assigns.id || "hui-spinner-#{System.unique_integer([:positive, :monotonic])}"
      )

    ~H"""
    <span
      id={@id}
      class={["spinner", "spinner--#{@size}", "spinner--#{@color}", @class]}
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
      class={["separator", "separator--#{@orientation}", "separator--default", @class]}
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
      class={["skeleton", "skeleton--#{@animation_type || "shimmer"}", @class]}
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

  @doc "A labelled native checkbox, with HeroUI styling."
  attr(:id, :string, required: true)
  attr(:name, :string, default: nil)
  attr(:value, :string, default: "true")
  attr(:checked, :boolean, default: false)
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
      class={["checkbox", "checkbox--#{@variant}", "hui-native-checkbox", @class]}
      for={@id}
      data-slot="checkbox"
      data-disabled={if @disabled, do: "true"}
      data-invalid={if @invalid, do: "true"}
    >
      <span class="checkbox__content" data-slot="checkbox-content">
        <input
          id={@id}
          type="checkbox"
          name={@name}
          value={@value}
          checked={@checked}
          disabled={@disabled}
          aria-labelledby={"#{@id}-label"}
          aria-describedby={if @description, do: "#{@id}-description"}
          aria-invalid={if @invalid, do: "true"}
          class="hui-visually-hidden-input"
          {@rest}
        />
        <span class="checkbox__control" aria-hidden="true"><span class="checkbox__indicator"><svg
          data-slot="checkbox-default-indicator--checkmark"
          viewBox="0 0 16 16"
          fill="none"
        ><path
          d="M3.5 8l3 3 6-6"
          stroke="currentColor"
          stroke-width="2.5"
          stroke-linecap="round"
          stroke-linejoin="round"
        /></svg></span></span>
        <span id={"#{@id}-label"} data-slot="label">{render_slot(@inner_block)}</span>
      </span>
      <span :if={@description} id={"#{@id}-description"} class="description" data-slot="description">{@description}</span>
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
      <legend class="label">{@label}<span :if={@required} aria-hidden="true"> *</span></legend>
      <span :if={@required} id={"#{@id}-required"} class="sr-only">{@required_message}</span>
      <div class="checkbox-group">
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
      <p :if={@description} id={"#{@id}-description"} class="description">{@description}</p>
      <div :if={@errors != []} id={"#{@id}-errors"} class="field-error" data-visible="true">
        <p :for={error <- @errors}>{error}</p>
      </div>
    </fieldset>
    """
  end

  @doc """
  A native checkbox presented as a HeroUI switch.

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
        "switch",
        "switch--#{@size}",
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
      <span class="switch__content" data-slot="switch-content">
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
          class="switch__control pointer-events-none peer-focus-visible:outline-2 peer-focus-visible:outline-offset-2 peer-focus-visible:outline-[var(--focus)] peer-checked:bg-[var(--switch-control-bg-checked)] group-hover/switch:peer-checked:bg-[var(--switch-control-bg-checked-hover)] group-active/switch:peer-checked:bg-[var(--switch-control-bg-checked-hover)] peer-checked:[&_[data-slot=switch-thumb]]:[inset-inline-start:var(--switch-thumb-offset)] peer-checked:[&_[data-slot=switch-thumb]]:bg-accent-foreground peer-checked:[&_[data-slot=switch-thumb]]:text-accent peer-disabled:peer-checked:[&_[data-slot=switch-thumb]]:opacity-40"
          data-slot="switch-control"
          aria-hidden="true"
        ><span class="switch__thumb" data-slot="switch-thumb"><span
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
      <span :if={@description} id={"#{@id}-description"} class="description" data-slot="description">{@description}</span>
      <span
        :if={@errors != []}
        id={"#{@id}-errors"}
        class="field-error"
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
        "switch-group",
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
      <legend :if={@label} class="label">{@label}</legend>
      <div class="switch-group__items" data-slot="switch-group-items">
        {render_slot(@inner_block)}
      </div>
      <p :if={@description} id={"#{@id}-description"} class="description">{@description}</p>
    </fieldset>
    """
  end

  @doc "A labelled progress bar. Omit value for indeterminate progress."
  attr(:value, :any, default: nil)
  attr(:min, :any, default: 0)
  attr(:max, :any, default: 100)
  attr(:label, :string, required: true)
  attr(:size, :string, default: "md", values: ~w(sm md lg))
  attr(:color, :string, default: "accent", values: ~w(default accent success warning danger))
  attr(:class, :any, default: nil)

  def progress_bar(assigns) do
    assigns =
      assign(assigns, :percent, range_percent!(assigns.value, assigns.min, assigns.max, true))

    ~H"""
    <div
      class={["progress-bar", "progress-bar--#{@size}", "progress-bar--#{@color}", @class]}
      role="progressbar"
      aria-label={@label}
      aria-valuemin={@min}
      aria-valuemax={@max}
      aria-valuenow={@value}
    >
      <span data-slot="label">{@label}</span><span
        :if={!is_nil(@percent)}
        class="progress-bar__output"
      >{round(@percent)}%</span>
      <div class="progress-bar__track">
        <div class="progress-bar__fill" style={if !is_nil(@percent), do: "width: #{@percent}%"}></div>
      </div>
    </div>
    """
  end

  @doc "A circular progress indicator. Omit value for indeterminate progress."
  attr(:value, :any, default: nil)
  attr(:min, :any, default: 0)
  attr(:max, :any, default: 100)
  attr(:label, :string, required: true)
  attr(:size, :string, default: "md", values: ~w(sm md lg))
  attr(:color, :string, default: "accent", values: ~w(default accent success warning danger))
  attr(:class, :any, default: nil)

  def progress_circle(assigns) do
    percent = range_percent!(assigns.value, assigns.min, assigns.max, true)
    circumference = 2 * :math.pi() * 16

    offset =
      if is_nil(percent), do: circumference * 0.75, else: circumference * (1 - percent / 100)

    assigns = assign(assigns, circumference: circumference, offset: offset)

    ~H"""
    <div
      class={["progress-circle", "progress-circle--#{@size}", "progress-circle--#{@color}", @class]}
      role="progressbar"
      aria-label={@label}
      aria-valuemin={@min}
      aria-valuemax={@max}
      aria-valuenow={@value}
    >
      <svg class="progress-circle__track" viewBox="0 0 36 36" fill="none" aria-hidden="true">
        <circle class="progress-circle__track-circle" cx="18" cy="18" r="16" stroke-width="4" />
        <circle
          class="progress-circle__fill-circle"
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
    </div>
    """
  end

  @doc "A labelled measurement within a known range."
  attr(:value, :any, required: true)
  attr(:min, :any, default: 0)
  attr(:max, :any, default: 100)
  attr(:label, :string, required: true)
  attr(:value_text, :string, default: nil)
  attr(:size, :string, default: "md", values: ~w(sm md lg))
  attr(:color, :string, default: "accent", values: ~w(default accent success warning danger))
  attr(:class, :any, default: nil)

  def meter(assigns) do
    assigns =
      assign(assigns, :percent, range_percent!(assigns.value, assigns.min, assigns.max, false))

    ~H"""
    <div
      class={["meter", "meter--#{@size}", "meter--#{@color}", @class]}
      role="meter"
      aria-label={@label}
      aria-valuemin={@min}
      aria-valuemax={@max}
      aria-valuenow={@value}
      aria-valuetext={@value_text}
    >
      <span data-slot="label">{@label}</span><span class="meter__output">{@value_text ||
        "#{round(@percent)}%"}</span>
      <div class="meter__track">
        <div class="meter__fill" style={"width: #{@percent}%"}></div>
      </div>
    </div>
    """
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
        "scroll-shadow",
        "scroll-shadow--#{@orientation}",
        "scroll-shadow--fade",
        @hide_scrollbar && "scroll-shadow--hide-scrollbar",
        @class
      ]}
      data-slot="scroll-shadow"
      data-hero-scroll-shadow
      x-data="heroScrollShadow"
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
        data-hero-scroll-shadow-event
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

    assigns = assign(assigns, :initials, assigns.fallback || initials)

    ~H"""
    <span
      class={["avatar", "avatar--#{@size}", @variant == "soft" && "avatar--soft", @class]}
      role="img"
      aria-label={@name}
    >
      <span class={["avatar__fallback", "avatar__fallback--#{@color}"]} aria-hidden="true">{@initials}</span>
      <img
        :if={@src}
        src={@src}
        alt=""
        aria-hidden="true"
        class="avatar__image hui-avatar-image"
        data-hero-avatar-image
        x-data="heroAvatarImage"
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

    assigns =
      assigns
      |> assign(:visible, visible)
      |> assign(:hidden_count, length(hidden))
      |> assign(:count_slot, List.first(assigns.count))

    ~H"""
    <div
      class={[
        "avatar-group",
        @grid && "avatar-group--grid",
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
          "avatar",
          "avatar-group__count",
          "avatar--#{(@count_slot && Map.get(@count_slot, :size)) || @size}",
          ((@count_slot && Map.get(@count_slot, :variant)) || @variant) == "soft" && "avatar--soft",
          @count_slot && Map.get(@count_slot, :class)
        ]}
        role="img"
        aria-label={if @count_slot, do: @count_slot.label, else: "#{@hidden_count} more"}
        data-slot="avatar-group-count"
      >
        <span
          class={[
            "avatar__fallback",
            "avatar__fallback--#{(@count_slot && Map.get(@count_slot, :color)) || @color}"
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
      class={["textarea", "textarea--#{@variant}", @class]}
      {@rest}
    >{@value}</textarea>
    """
  end

  @doc "A native radio input with HeroUI styling. Radios sharing a name form a group."
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
      class={["radio", "hui-native-radio", @class]}
      for={@id}
      data-slot="radio"
      data-disabled={if @disabled, do: "true"}
      data-invalid={if @invalid, do: "true"}
    >
      <span class="radio__content" data-slot="radio-content">
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
          class="hui-visually-hidden-input"
          {@rest}
        />
        <span class="radio__control" aria-hidden="true"><span class="radio__indicator"></span></span>
        <span id={"#{@id}-label"} data-slot="label">{render_slot(@inner_block)}</span>
      </span>
      <span :if={@description} id={"#{@id}-description"} class="description" data-slot="description">{@description}</span>
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
      <legend class="label">{@label}</legend>
      <div class={["radio-group", "radio-group--#{@variant}"]} data-orientation={@orientation}>
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
      <p :if={@description} id={"#{@id}-description"} class="description">{@description}</p>
      <div :if={@errors != []} id={"#{@id}-errors"} class="field-error" data-visible="true">
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
    <kbd class={["kbd", @class]}>{render_slot(@inner_block)}</kbd>
    """
  end

  @doc "A form label with HeroUI required, disabled, and invalid states."
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
        "label",
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

  @doc "A HeroUI link for ordinary navigation, LiveView navigation, or patches."
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
      class={["link", @class]}
      data-slot="link"
      {@rest}
    >{render_slot(@inner_block)}</.link>
    <a
      :if={@disabled}
      role="link"
      aria-disabled="true"
      tabindex="-1"
      class={["link", @class]}
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
      class={["link__icon", @class]}
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

  @doc "Semantic HeroUI typography with a visual type, color, alignment, and weight."
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
    assigns = assign(assigns, :tag, assigns.as || default_tag)

    ~H"""
    <.dynamic_tag
      tag_name={@tag}
      class={[
        "typography",
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

  @doc "Applies HeroUI's prose styles to rich content."
  attr(:class, :any, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def typography_prose(assigns) do
    ~H"""
    <div class={["typography-prose", @class]} data-slot="prose" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc "A HeroUI surface; use Tailwind classes to add spacing, borders, or rounding."
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
    <div class={["surface", "surface--#{@variant}", @class]} data-slot={@data_slot} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc "An editable hex color or numeric color channel with HeroUI input styling."
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
      class={["color-field", @full_width && "color-field--full-width", @class]}
      data-slot="color-field"
      data-hero-color-field
      x-data="heroColorField"
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
      <label class="label" data-slot="label" for={@id}>{@label}</label>
      <div
        class={[
          "color-input-group",
          "color-input-group--#{@variant}",
          @full_width && "color-input-group--full-width"
        ]}
        role="presentation"
        data-slot="color-input-group"
        data-invalid={if @errors != [], do: "true"}
        data-disabled={if @disabled, do: "true"}
      >
        <div
          :if={@prefix != [] || @show_swatch}
          class="color-input-group__prefix"
          data-slot="color-input-group-prefix"
        >
          <%= if @prefix != [] do %>
            {render_slot(@prefix)}
          <% else %>
            <span id={"#{@id}-color-preview"} data-hero-color-preview phx-update="ignore">
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
          class="color-input-group__input"
          data-slot="color-input-group-input"
          data-hero-color-input
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
          class="color-input-group__suffix"
          data-slot="color-input-group-suffix"
        >
          {render_slot(@suffix)}
        </div>
      </div>
      <p :if={@description} id={"#{@id}-description"} class="description" data-slot="description">
        {@description}
      </p>
      <div
        :if={@errors != []}
        id={"#{@id}-errors"}
        class="field-error"
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

  @doc "A color preview with HeroUI sizes, shapes, and transparency pattern."
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
      class={["color-swatch", "color-swatch--#{@shape}", "color-swatch--#{@size}", @class]}
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
      <legend class="label">{@label}</legend>
      <div
        class={[
          "color-swatch-picker",
          "color-swatch-picker--#{@layout}",
          "color-swatch-picker--#{@size}",
          "color-swatch-picker--#{@shape}"
        ]}
        data-slot="color-swatch-picker"
        data-layout={@layout}
      >
        <label
          :for={option <- @options}
          class="color-swatch-picker__item hui-swatch-picker__option"
          data-slot="color-swatch-picker-item"
          data-disabled={if @disabled || Map.get(option, :disabled, false), do: "true"}
          style={"--color-swatch-current: #{option.value}"}
        >
          <input
            type="radio"
            class="hui-visually-hidden-input"
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
            class="color-swatch-picker__swatch"
            data-slot="color-swatch-picker-swatch"
            aria-hidden="true"
            style={"background-color: #{option.value}"}
          ></span>
          <span
            class="color-swatch-picker__indicator"
            data-slot="color-swatch-picker-indicator"
            aria-hidden="true"
            data-light-color={if option.light, do: "true"}
          >
            <svg
              data-slot="color-swatch-picker-checkmark"
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
      <p :if={@description} id={"#{@id}-description"} class="description">{@description}</p>
      <div :if={@errors != []} id={"#{@id}-errors"} class="field-error" data-visible="true">
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
      class={["toast-region", "toast-region--#{@placement}", @class]}
      data-slot="toast-region"
      data-hero-toast-region
      x-data="heroToastRegion"
      x-on:hero:toast.window="show($event.detail)"
      x-on:phx:hero:toast.window="show($event.detail)"
      x-on:hero:toast-update.window="update($event.detail)"
      x-on:phx:hero:toast-update.window="update($event.detail)"
      x-on:hero:toast-close.window="closeEvent($event.detail)"
      x-on:phx:hero:toast-close.window="closeEvent($event.detail)"
      x-on:hero:toast-clear.window="clearEvent($event.detail)"
      x-on:phx:hero:toast-clear.window="clearEvent($event.detail)"
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
      <ol data-hero-toast-list class="contents">
        <template x-for="item in items" x-bind:key="item.uid">
          <li class="contents">
            <div
              class="toast"
              x-bind:class="`toast--${$root.dataset.placement} toast--${variant(item.data.variant)}`"
              data-slot="toast"
              data-hero-toast
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
                <div class="toast__indicator" data-slot="toast-indicator" aria-hidden="true">
                  <span class="spinner spinner--sm spinner--current" data-slot="spinner">
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
                <div class="toast__indicator" data-slot="toast-indicator" aria-hidden="true">
                  {render_slot(indicator)}
                </div>
              </template>
              <template x-if="!loading(item) && item.data.indicator !== false && !customIndicator(item)">
                <div class="toast__indicator" data-slot="toast-indicator">
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
              <div class="toast__content" data-slot="toast-content" role="alert" aria-atomic="true">
                <span
                  class="toast__title"
                  data-slot="toast-title"
                  x-bind:id="`${item.uid}-title`"
                  x-text="item.data.title"
                ></span>
                <template x-if="item.data.description">
                  <span
                    class="toast__description"
                    data-slot="toast-description"
                    x-bind:id="`${item.uid}-description`"
                    x-text="item.data.description"
                  ></span>
                </template>
              </div>
              <template x-if="item.data.action && item.data.action.label">
                <button
                  type="button"
                  class="button button--md button--tertiary toast__action"
                  data-slot="toast-action-button"
                  data-hero-toast-action
                  x-bind:phx-click="actionCommand(item)"
                  x-on:click="action(item)"
                  x-text="item.data.action.label"
                ></button>
              </template>
              <button
                type="button"
                class="close-button close-button--default toast__close-button"
                data-slot="toast-close"
                data-hero-toast-close
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
      class={["date-field", @full_width && "date-field--full-width", @class]}
      data-hero-date-field
      data-locale={@locale}
      data-variant={@variant}
      data-unavailable={@unavailable_json}
      data-invalid={if @errors != [], do: "true"}
      data-disabled={if @disabled, do: "true"}
      data-required={if @required, do: "true"}
      phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["data-enhanced"])}
    >
      <label id={"#{@id}-label"} class="label" data-slot="label" for={@id}>{@label}</label>
      <input
        id={@id}
        name={@name}
        type="date"
        value={@value}
        min={@min}
        max={@max}
        class={[
          "input",
          "input--#{@variant}",
          @full_width && "input--full-width",
          "hui-date-field-native"
        ]}
        disabled={@disabled}
        readonly={@read_only}
        required={@required}
        aria-invalid={if @errors != [], do: "true"}
        aria-describedby={if @describedby != "", do: @describedby}
        data-hero-date-native
        phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["aria-hidden", "tabindex"])}
        {@rest}
      />
      <div id={"#{@id}-date-enhanced"} data-hero-date-ui phx-update="ignore" hidden>
        <div
          class={[
            "date-input-group",
            "date-input-group--#{@variant}",
            @full_width && "date-input-group--full-width"
          ]}
          data-slot="date-input-group"
          data-hero-date-group
          role="group"
          aria-labelledby={"#{@id}-label"}
          aria-describedby={if @describedby != "", do: @describedby}
          data-invalid={if @errors != [], do: "true"}
          data-disabled={if @disabled, do: "true"}
        >
          <span
            :if={@prefix != []}
            class="date-input-group__prefix"
            data-slot="date-input-group-prefix"
          >{render_slot(@prefix)}</span>
          <div
            class="date-input-group__input"
            data-slot="date-input-group-input"
            data-hero-date-segments
          >
          </div>
          <span
            :if={@suffix != []}
            class="date-input-group__suffix"
            data-slot="date-input-group-suffix"
          >{render_slot(@suffix)}</span>
        </div>
        <p
          id={"#{@id}-native-error"}
          class="field-error"
          data-visible="true"
          data-hero-date-error
          hidden
        >
        </p>
      </div>
      <p :if={@description} id={"#{@id}-description"} class="description" data-slot="description">
        {@description}
      </p>
      <div :if={@errors != []} id={"#{@id}-errors"} class="field-error" data-visible="true">
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
      class={["time-field", @full_width && "time-field--full-width", @class]}
      data-slot="time-field"
      data-hero-time-field
      x-data="heroTimeField"
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
      <label id={"#{@id}-label"} class="label" data-slot="label" for={@id}>{@label}</label>
      <input
        id={@id}
        name={@name}
        type="time"
        value={@value}
        min={@min}
        max={@max}
        step={@step}
        class={[
          "input",
          "input--#{@variant}",
          @full_width && "input--full-width",
          "aria-hidden:pointer-events-none aria-hidden:absolute aria-hidden:size-px aria-hidden:opacity-0"
        ]}
        disabled={@disabled}
        readonly={@read_only}
        required={@required}
        aria-invalid={if @errors != [], do: "true"}
        aria-describedby={if @describedby != "", do: @describedby}
        data-hero-time-native
        phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["aria-hidden", "tabindex"])}
        {@rest}
      />
      <div id={"#{@id}-time-enhanced"} data-hero-time-ui phx-update="ignore" hidden>
        <div
          class={[
            "date-input-group",
            "date-input-group--#{@variant}",
            @full_width && "date-input-group--full-width"
          ]}
          data-slot="date-input-group"
          data-hero-time-group
          role="group"
          aria-labelledby={"#{@id}-label"}
        >
          <span
            :if={@prefix != []}
            class="date-input-group__prefix"
            data-slot="date-input-group-prefix"
          >{render_slot(@prefix)}</span>
          <div
            class="date-input-group__input"
            data-slot="date-input-group-input"
            data-hero-time-segments
          >
          </div>
          <span
            :if={@suffix != []}
            class="date-input-group__suffix"
            data-slot="date-input-group-suffix"
          >{render_slot(@suffix)}</span>
        </div>
        <p
          id={"#{@id}-native-error"}
          class="field-error"
          data-visible="true"
          data-hero-time-error
          hidden
        >
        </p>
      </div>
      <p :if={@description} id={"#{@id}-description"} class="description" data-slot="description">
        {@description}
      </p>
      <div :if={@errors != []} id={"#{@id}-errors"} class="field-error" data-visible="true">
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
      class={["date-picker", @full_width && "w-full", @class]}
      data-hero-date-picker
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
            class="date-picker__trigger"
            data-slot="date-picker-trigger"
            data-hero-date-picker-trigger
            aria-label="Calendar"
            aria-labelledby={"#{@id}-picker-trigger #{@id}-label"}
            id={"#{@id}-picker-trigger"}
            aria-haspopup="dialog"
            aria-expanded="false"
            aria-controls={"#{@id}-picker-popover"}
            disabled={@disabled}
          >
            <span
              class="date-picker__trigger-indicator"
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
        class="date-picker__popover hui-date-picker-popover"
        data-slot="date-picker-popover"
        data-hero-date-picker-popover
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
      class={["hui-calendar-root", @class]}
      data-hero-calendar
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
      <label for={@id} class={if @show_label, do: "label", else: "sr-only"}>{@label}</label>
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
        class="input input--primary hui-calendar-native"
        aria-invalid={if @errors != [], do: "true"}
        aria-describedby={if @describedby != "", do: @describedby}
        data-hero-calendar-native
        phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["aria-hidden", "tabindex"])}
        {@rest}
      />
      <div id={"#{@id}-calendar-enhanced"} data-hero-calendar-ui phx-update="ignore" hidden>
        <div
          class="calendar"
          data-hero-calendar-view
          data-slot="calendar"
          role="group"
          aria-label={@label}
        >
        </div>
        <p
          id={"#{@id}-calendar-native-error"}
          class="field-error"
          data-visible="true"
          data-hero-calendar-error
          hidden
        >
        </p>
      </div>
      <p :if={@description} id={"#{@id}-description"} class="description">{@description}</p>
      <div :if={@errors != []} id={"#{@id}-errors"} class="field-error" data-visible="true">
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
      class={["hui-calendar-root", @class]}
      data-hero-calendar
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
        class="hui-calendar-native"
        data-hero-calendar-native-group
        phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["aria-hidden"])}
      >
        <label for={@start_id} class="label">{@label}: {@start_label}</label>
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
          class="input input--primary"
          aria-invalid={if @errors != [], do: "true"}
          aria-describedby={if @describedby != "", do: @describedby}
          data-hero-calendar-native
          phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["aria-hidden", "tabindex"])}
          {@rest}
        />
        <label for={@end_id} class="label">{@label}: {@end_label}</label>
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
          class="input input--primary"
          aria-invalid={if @errors != [], do: "true"}
          aria-describedby={if @describedby != "", do: @describedby}
          data-hero-calendar-end
          phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["aria-hidden", "tabindex"])}
          {@rest}
        />
      </div>
      <div id={"#{@id}-calendar-enhanced"} data-hero-calendar-ui phx-update="ignore" hidden>
        <div
          class="range-calendar"
          data-hero-calendar-view
          data-slot="range-calendar"
          role="group"
          aria-label={@label}
        >
        </div>
        <p
          id={"#{@id}-calendar-native-error"}
          class="field-error"
          data-visible="true"
          data-hero-calendar-error
          hidden
        >
        </p>
      </div>
      <p :if={@description} id={"#{@id}-description"} class="description">{@description}</p>
      <div :if={@errors != []} id={"#{@id}-errors"} class="field-error" data-visible="true">
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
        "autocomplete",
        "autocomplete--#{@variant}",
        @full_width && "autocomplete--full-width",
        @class
      ]}
      data-slot="autocomplete"
      data-hero-autocomplete
      x-data="heroAutocomplete"
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
      <label id={"#{@id}-label"} class="label" data-slot="label" for={@id}>{@label}</label>
      <select
        id={@id}
        name={@name}
        class={[
          "select__trigger",
          "aria-hidden:pointer-events-none aria-hidden:absolute aria-hidden:size-px aria-hidden:opacity-0",
          @full_width && "w-full"
        ]}
        multiple={@selection_mode == "multiple"}
        disabled={@disabled}
        required={@required}
        aria-invalid={if @errors != [], do: "true"}
        aria-describedby={if @describedby != "", do: @describedby}
        data-hero-autocomplete-native
        phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["aria-hidden", "tabindex"])}
        {@rest}
      >
        <option :if={@selection_mode == "single"} value="">{@placeholder}</option>
        {Phoenix.HTML.Form.options_for_select(@options, @value)}
      </select>
      <span :if={@required} id={"#{@id}-required-hint"} class="sr-only">Required</span>
      <div id={"#{@id}-enhanced"} data-hero-autocomplete-ui phx-update="ignore" hidden>
        <div
          class={["autocomplete__trigger", @full_width && "autocomplete__trigger--full-width"]}
          data-slot="autocomplete-trigger"
          data-hero-autocomplete-group
          role="group"
        >
          <span
            id={"#{@id}-value"}
            class="autocomplete__value pointer-events-none"
            data-slot="autocomplete-value"
            data-hero-autocomplete-value
            data-placeholder="true"
          >{@placeholder}</span>
          <button
            type="button"
            class="autocomplete__clear-button z-10"
            data-slot="autocomplete-clear-button"
            data-hero-autocomplete-clear
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
            data-hero-autocomplete-trigger
            aria-labelledby={"#{@id}-label #{@id}-value"}
            aria-haspopup="listbox"
            aria-expanded="false"
            aria-controls={"#{@id}-listbox"}
          >
            <svg
              class="autocomplete__indicator"
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
          class="autocomplete__popover fixed m-0 max-h-[calc(100dvh-1rem)] max-w-[calc(100vw-1rem)] border-0 [inset:auto] [&:not(:popover-open)]:hidden"
          data-slot="autocomplete-popover"
          data-hero-autocomplete-popup
          popover="auto"
          role="dialog"
          aria-labelledby={"#{@id}-label"}
          tabindex="-1"
        >
          <div class="autocomplete__filter flex min-h-0 flex-col" data-slot="autocomplete-filter">
            <div
              class="search-field search-field--secondary"
              data-slot="search-field"
              data-hero-autocomplete-search-field
              data-empty="true"
            >
              <div class="search-field__group" data-slot="search-field-group">
                <svg
                  class="search-field__search-icon"
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
                  class="search-field__input"
                  data-slot="search-field-input"
                  data-hero-autocomplete-search
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
                  class="close-button close-button--default search-field__clear-button"
                  data-slot="search-field-clear-button"
                  data-hero-autocomplete-search-clear
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
              class="list-box"
              role="listbox"
              data-slot="list-box"
              data-hero-autocomplete-list
              aria-labelledby={"#{@id}-label"}
              aria-multiselectable={if @selection_mode == "multiple", do: "true"}
            >
            </div>
            <div
              class="empty-state"
              data-slot="empty-state"
              data-hero-autocomplete-empty
              role="status"
              hidden
            >
              {@empty_message}
            </div>
          </div>
        </div>
        <p
          id={"#{@id}-native-error"}
          class="field-error"
          data-visible="true"
          data-hero-autocomplete-error
          hidden
        >
        </p>
      </div>
      <p :if={@description} id={"#{@id}-description"} class="description" data-slot="description">
        {@description}
      </p>
      <div :if={@errors != []} id={"#{@id}-errors"} class="field-error" data-visible="true">
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
      class={["combo-box", @full_width && "combo-box--full-width", @class]}
      data-hero-combo
      x-data="heroComboBox"
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
      <label id={"#{@id}-label"} class="label" data-slot="label" for={@id}>{@label}</label>
      <select
        id={if @allows_custom_value, do: "#{@id}-source", else: @id}
        name={if !@allows_custom_value, do: @name}
        class="select__trigger hui-combo-native"
        disabled={@disabled}
        required={@required && !@allows_custom_value}
        multiple={@selection_mode == "multiple"}
        hidden={@allows_custom_value}
        aria-invalid={if @errors != [], do: "true"}
        aria-describedby={if @describedby != "", do: @describedby}
        data-hero-combo-native
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
        data-hero-combo-ui
        phx-update={if !@allows_custom_value, do: "ignore"}
        hidden={!@allows_custom_value}
      >
        <div class={["combo-box__input-group", @full_width && "combo-box__input-group--full-width"]}>
          <input
            id={if @allows_custom_value, do: @id, else: "#{@id}-input"}
            name={if @allows_custom_value, do: @name}
            value={if @allows_custom_value, do: @value}
            disabled={@disabled && @allows_custom_value}
            required={@required && @allows_custom_value}
            list={if @allows_custom_value, do: "#{@id}-suggestions"}
            class={["input", "input--#{@variant}", @full_width && "input--full-width"]}
            data-slot="input"
            data-hero-combo-input
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
            class="combo-box__trigger"
            data-hero-combo-trigger
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
          class="combo-box__value"
          data-slot="combo-box-value"
          data-hero-combo-value
          data-placeholder="true"
        >
          {@selected_placeholder}
        </div>
        <div
          id={"#{@id}-popup"}
          class="combo-box__popover hui-combo-popup"
          data-hero-combo-popup
          popover="auto"
          phx-update={if @allows_custom_value, do: "ignore"}
        >
          <div
            id={"#{@id}-listbox"}
            role="listbox"
            aria-multiselectable={if @selection_mode == "multiple", do: "true"}
            aria-labelledby={"#{@id}-label"}
            class="list-box"
            data-slot="list-box"
            data-hero-combo-list
          >
          </div>
          <div class="hui-combo-empty" data-hero-combo-empty role="status" hidden>
            No matching options
          </div>
        </div>
        <p
          id={"#{@id}-native-error"}
          class="field-error"
          data-visible="true"
          data-hero-combo-error
          hidden
        >
        </p>
      </div>
      <p :if={@description} id={"#{@id}-description"} class="description" data-slot="description">
        {@description}
      </p>
      <div :if={@errors != []} id={"#{@id}-errors"} class="field-error" data-visible="true">
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
  A native single or multiple select with HeroUI field styling.

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
      class={["select", "select--#{@variant}", "hui-native-select", @class]}
      data-invalid={if @invalid, do: "true"}
      data-hero-select-root
      x-data="heroSelect"
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
      <div class="hui-native-select-field">
        <select
          id={@id}
          name={@name}
          class="select__trigger hui-native-select-input"
          aria-invalid={if @invalid, do: "true"}
          data-hero-native-select
          phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["aria-hidden", "tabindex"])}
          {@rest}
        >
          <option :if={@prompt} value="">{@prompt}</option>
          {Phoenix.HTML.Form.options_for_select(@options, @value)}
        </select>
        <svg
          class="select__indicator hui-native-select-indicator"
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
        <div id={"#{@id}-enhanced"} data-hero-select-ui phx-update="ignore" hidden>
          <button
            id={"#{@id}-trigger"}
            type="button"
            class="select__trigger hui-enhanced-select-trigger"
            role="combobox"
            aria-haspopup="listbox"
            aria-expanded="false"
            aria-controls={"#{@id}-listbox"}
            popovertarget={"#{@id}-popup"}
            data-hero-select-trigger
          >
            <span class="select__value" data-hero-select-value></span><svg
              class="select__indicator"
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
            class="select__popover hui-enhanced-select-popup"
            data-hero-select-popup
          >
            <div
              id={"#{@id}-listbox"}
              role="listbox"
              aria-labelledby={"#{@id}-trigger"}
              class="list-box"
              data-hero-select-list
            >
            </div>
          </div>
          <span
            id={"#{@id}-validation"}
            class="field-error"
            data-visible="true"
            role="alert"
            data-hero-select-error
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
        "accordion",
        "accordion__item",
        "hui-native-accordion",
        @variant == "surface" && "accordion--surface",
        @class
      ]}
      open={@open}
      name={@name}
      x-data={if @disabled, do: "{}"}
    >
      <summary
        class={[
          "accordion__trigger",
          @disabled && "pointer-events-none cursor-not-allowed opacity-50"
        ]}
        aria-disabled={if @disabled, do: "true"}
        tabindex={if @disabled, do: "-1"}
        x-on:click.prevent={if @disabled, do: ""}
      >
        {@title}<svg class="accordion__indicator" aria-hidden="true" viewBox="0 0 16 16" fill="none"><path
          d="m4 6 4 4 4-4"
          stroke="currentColor"
          stroke-width="1.5"
          stroke-linecap="round"
          stroke-linejoin="round"
        /></svg>
      </summary>
      <div class="accordion__body">
        <div class="accordion__body-inner">{render_slot(@inner_block)}</div>
      </div>
    </details>
    <div
      :if={@grouped}
      id={@id}
      class={["accordion", @variant == "surface" && "accordion--surface", @class]}
      data-slot="accordion"
      data-hero-accordion
      data-controlled={to_string(@controlled)}
      data-multiple={to_string(@allows_multiple_expanded)}
      data-initial-expanded={Jason.encode!(@expanded)}
      data-expanded-keys={Jason.encode!(@expanded)}
      data-disabled={if @disabled, do: "true"}
      x-data="heroAccordion"
      x-on:phx:update.window="sync()"
      x-on:keydown="keydown($event)"
    >
      <div
        :for={item <- @item}
        class={["accordion__item", Map.get(item, :class)]}
        data-slot="accordion-item"
        data-hide-separator={if @hide_separator, do: "true"}
      >
        <.dynamic_tag
          tag_name={"h#{@heading_level}"}
          class="accordion__heading"
          data-slot="accordion-heading"
        >
          <button
            id={"#{@id}-trigger-#{Base.url_encode64(item.key, padding: false)}"}
            type="button"
            class="accordion__trigger"
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
              class="accordion__indicator"
              data-slot="accordion-indicator"
              data-key={item.key}
              data-expanded={if MapSet.member?(@expanded_set, item.key), do: "true"}
              x-bind:data-expanded="expanded.includes($el.dataset.key) ? 'true' : null"
              aria-hidden="true"
              phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["data-expanded"])}
            >{render_slot(@indicator, item)}</span>
            <svg
              :if={@indicator == []}
              class="accordion__indicator"
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
          class="accordion__panel motion-reduce:!transition-none"
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
          <div class="accordion__body" data-slot="accordion-body">
            <div class="accordion__body-inner">{render_slot(item)}</div>
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
        "disclosure",
        "hui-disclosure",
        "[&[open]_[data-slot=disclosure-indicator]]:-rotate-180",
        "[interpolate-size:allow-keywords]",
        "[&::details-content]:h-0 [&::details-content]:overflow-clip [&::details-content]:opacity-0",
        "[&::details-content]:transition-[height,opacity,content-visibility] [&::details-content]:duration-200 [&::details-content]:[transition-behavior:allow-discrete]",
        "[&[open]::details-content]:h-auto [&[open]::details-content]:opacity-100 motion-reduce:[&::details-content]:transition-none",
        @class
      ]}
      data-slot="disclosure"
      data-hero-disclosure
      data-disabled={if @disabled, do: "true"}
      data-expanded={if @open, do: "true"}
      open={@open}
      name={@name}
      x-data="heroDisclosure"
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
          "button",
          "button--md",
          "button--#{@variant}",
          @full_width && "button--full-width",
          @disabled && "pointer-events-none cursor-not-allowed opacity-50",
          @trigger_class
        ]}
        data-slot="disclosure-trigger"
        data-hero-disclosure-trigger
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
        <span class="hui-disclosure-label flex-1 text-start"><%= if @trigger != [] do %>
          {render_slot(@trigger)}
        <% else %>
          {@title}
        <% end %></span>
        <svg
          class="disclosure__indicator"
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
        class={["disclosure__content", "h-auto opacity-100", @content_class]}
        data-slot="disclosure-content"
        data-hero-disclosure-content
        data-expanded={if @open, do: "true"}
        x-bind:data-expanded="expanded ? 'true' : null"
        phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["data-expanded"])}
        role="group"
        aria-labelledby={"#{@id}-trigger"}
      >
        <div class="disclosure__body" data-slot="disclosure-body">
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
      class={["disclosure-group", @class]}
      data-slot="disclosure-group"
      data-hero-disclosure-group
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
  Use `status` for HeroUI naming; the existing `color` attribute remains supported.
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
        icon_path: alert_icon_path(status)
      )

    ~H"""
    <div role={@role} class={["alert", "alert--#{@status}", @class]} data-slot={@data_slot} {@rest}>
      <div :if={@show_indicator} class="alert__indicator" data-slot="alert-indicator">
        <%= if @indicator != [] do %>
          {render_slot(@indicator)}
        <% else %>
          <svg
            data-slot="alert-default-icon"
            aria-hidden="true"
            role="presentation"
            viewBox="0 0 16 16"
            fill="none"
          ><path d={@icon_path} fill="currentColor" fill-rule="evenodd" clip-rule="evenodd" /></svg>
        <% end %>
      </div>
      <div class="alert__content" data-slot="alert-content">
        <p :if={@title || @title_content != []} class="alert__title" data-slot="alert-title">
          <%= if @title_content != [] do %>
            {render_slot(@title_content)}
          <% else %>
            {@title}
          <% end %>
        </p>
        <div
          :if={@inner_block != [] && @description == []}
          class="alert__description"
          data-slot="alert-description"
        >
          {render_slot(@inner_block)}
        </div>
        <span
          :for={description <- @description}
          class="alert__description"
          data-slot="alert-description"
        >{render_slot(description)}</span>
        {render_slot(@content)}
      </div>
      {render_slot(@actions)}
    </div>
    """
  end

  # Icon paths adapted from HeroUI, Apache-2.0. See THIRD_PARTY_NOTICES.md.
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
    ~H"""
    <span class={[
      "badge",
      "badge--#{@color}",
      "badge--#{@size}",
      "badge--#{@variant}",
      @placement && "badge--#{@placement}",
      @class
    ]}><span class="badge__label">{render_slot(@inner_block)}</span></span>
    """
  end

  @doc "An anchor for a positioned badge."
  attr(:class, :any, default: nil)
  slot(:inner_block, required: true)

  def badge_anchor(assigns) do
    ~H"""
    <span class={["badge-anchor", @class]}>{render_slot(@inner_block)}</span>
    """
  end

  @doc """
  A semantic, responsive HeroUI table. Column slots receive each row.

  Pass a LiveView stream as `rows` and a unique `id` for incremental updates.
  For server-side sorting, give columns `sort_key` and set `sort_event`; the
  event receives `%{"sort" => key}`. The caller owns the order and sort state.
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
  attr(:class, :any, default: nil)

  slot :col, required: true do
    attr(:label, :string, required: true)
    attr(:sort_key, :string)
    attr(:row_header, :boolean)
    attr(:class, :any)
  end

  def data_table(assigns) do
    stream? = match?(%Phoenix.LiveView.LiveStream{}, assigns.rows)

    if stream? and is_nil(assigns.id),
      do: raise(ArgumentError, "a table id is required for stream rows")

    if !stream? and !is_list(assigns.rows),
      do: raise(ArgumentError, "table rows must be a list or LiveView stream")

    assigns = assign(assigns, stream?: stream?, empty?: !stream? and assigns.rows == [])

    ~H"""
    <div class={["table-root", "table-root--#{@variant}", @class]}>
      <div class="table__scroll-container">
        <table id={@id} class="table__content" aria-label={@label}>
          <thead class="table__header">
            <tr>
              <th
                :for={col <- @col}
                scope="col"
                class={["table__column", Map.get(col, :class)]}
                data-allows-sorting={if @sort_event && Map.get(col, :sort_key), do: "true"}
                aria-sort={if @sort_by && @sort_by == Map.get(col, :sort_key), do: @sort_direction}
              >
                <button
                  :if={@sort_event && Map.get(col, :sort_key)}
                  type="button"
                  class="table__sortable-column-header hui-table-sort"
                  phx-click={@sort_event}
                  phx-value-sort={col.sort_key}
                >
                  {col.label}<svg
                    class="table__sortable-column-indicator"
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
              </th>
            </tr>
          </thead>
          <tbody
            id={if @stream?, do: "#{@id}-body"}
            phx-update={if @stream?, do: "stream"}
            class="table__body"
          >
            <tr :for={item <- @rows} id={table_row_id(item, @stream?, @row_id)} class="table__row">
              <%= for col <- @col do %>
                <th :if={Map.get(col, :row_header, false)} scope="row" class="table__cell">
                  {render_slot(col, table_row_value(item, @stream?))}
                </th>
                <td :if={!Map.get(col, :row_header, false)} class="table__cell">
                  {render_slot(col, table_row_value(item, @stream?))}
                </td>
              <% end %>
            </tr>
            <tr :if={@empty?} class="table__row">
              <td class="table__cell" colspan={length(@col)}>{@empty_message}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    """
  end

  defp table_row_value({_id, row}, true), do: row
  defp table_row_value(row, false), do: row
  defp table_row_id({id, _row}, true, _row_id), do: id
  defp table_row_id(row, false, row_id) when is_function(row_id, 1), do: row_id.(row)
  defp table_row_id(_row, false, nil), do: nil

  @doc """
  A modal dialog using the browser's focus containment and Escape behavior.

  Install the HeroUI Alpine providers as described in the README. Open it with a button carrying
  `data-hero-dialog-open={id}`. Provide a unique id and a concise title.
  """
  attr(:id, :string, required: true)
  attr(:title, :string, required: true)
  attr(:size, :string, default: "md", values: ~w(xs sm md lg))
  attr(:dismissible, :boolean, default: true)
  attr(:class, :any, default: nil)
  slot(:inner_block, required: true)
  slot(:footer)

  def modal(assigns) do
    ~H"""
    <dialog
      id={@id}
      class={["modal__dialog", "modal__dialog--#{@size}", "hui-native-modal", @class]}
      data-hero-dialog
      x-data="heroDialog"
      x-on:click.window="openFromTrigger($event)"
      x-on:click="onClick($event)"
      x-on:cancel="onCancel($event)"
      phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["open"])}
      data-dismissible={to_string(@dismissible)}
      aria-labelledby={"#{@id}-title"}
    >
      <header class="modal__header">
        <h2 class="modal__heading" id={"#{@id}-title"}>{@title}</h2>
      </header>
      <div class="modal__body">{render_slot(@inner_block)}</div>
      <div class="modal__footer">
        {render_slot(@footer)}
        <button class="button button--md button--tertiary" type="button" data-hero-dialog-close>Close</button>
      </div>
    </dialog>
    """
  end

  @doc """
  A swipeable modal sheet. Open it with `data-hero-sheet-open={id}` and install
  the HeroUI Alpine providers. Supply `open` and `on_open_change` for
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
        "sheet__overlay",
        "fixed inset-0 m-0 hidden h-dvh max-h-none w-screen max-w-none border-0 bg-transparent p-0 outline-none open:flex [&:not([open])]:hidden",
        @placement == "bottom" && "items-end justify-center",
        @placement == "top" && "items-start justify-center",
        @placement == "left" && "items-center justify-start",
        @placement == "right" && "items-center justify-end",
        "backdrop:bg-transparent"
      ]}
      data-hero-sheet
      x-data="heroSheet"
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
        class={["sheet__backdrop", "sheet__backdrop--#{@backdrop}", "fixed inset-0"]}
        data-slot="sheet-backdrop"
        data-hero-sheet-backdrop
        data-stack-index="0"
        aria-hidden="true"
        phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["data-stack-index", "style"])}
      >
      </div>
      <div
        class={["sheet__content", "sheet__content--#{@placement}", "relative", @class]}
        data-slot="sheet-content"
        data-hero-sheet-content
        data-placement={@placement}
        data-detached={if @detached, do: "true"}
        data-snap-points={if @snap_points != [], do: "true"}
        data-expanded={if @snap_points == [], do: "true"}
        phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["data-expanded", "style"])}
      >
        <section
          class={[
            "sheet__dialog",
            "sheet__dialog--#{@placement}",
            "max-h-[inherit]",
            (@placement in ["left", "right"] || @snap_points != []) && "h-full"
          ]}
          data-slot="sheet-dialog"
        >
          <div
            :if={@handle}
            class="sheet__handle"
            data-slot="sheet-handle"
            data-hero-sheet-handle
            aria-hidden="true"
          >
            <span class="sheet__handle-bar" data-slot="sheet-handle-bar"></span>
          </div>
          <.close_button
            class="sheet__close-trigger"
            data-slot="sheet-close-trigger"
            data-hero-sheet-close
          />
          <header class="sheet__header" data-slot="sheet-header">
            <h2 id={"#{@id}-title"} class="sheet__heading" data-slot="sheet-heading">{@title}</h2>
          </header>
          <div class={["sheet__body", @body_class]} data-slot="sheet-body" data-hero-sheet-body>
            <p :if={@description} id={"#{@id}-description"} class="text-sm text-muted">
              {@description}
            </p>
            {render_slot(@inner_block)}
          </div>
          <footer :if={@footer != []} class="sheet__footer" data-slot="sheet-footer">
            {render_slot(@footer)}
          </footer>
        </section>
      </div>
      <button
        :if={@on_open_change}
        type="button"
        hidden
        data-hero-sheet-event
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
  for LiveView-controlled selection. Requires HeroUI's Alpine components.
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
      class={["tabs", "tabs--#{@variant}", @align != "center" && "tabs--align-#{@align}", @class]}
      data-slot="tabs"
      data-orientation={@orientation}
      data-hero-tabs
      data-initial-key={@selected_id}
      data-selected-key={@selected_key}
      data-controlled={to_string(!is_nil(@selected_key))}
      data-activation-mode={@activation_mode}
      x-data="heroTabs"
      x-on:phx:update.window="sync()"
    >
      <div class="tabs__list-container min-w-0 max-w-full" data-slot="tabs-list-container">
        <div
          class={[
            "scroll-shadow",
            "scroll-shadow--hide-scrollbar",
            "scroll-shadow--#{@orientation}",
            "scroll-shadow--fade",
            "tabs__list-container__scroller",
            "max-w-full",
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
            class="tabs__list"
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
              class={["tabs__tab", "whitespace-nowrap", Map.get(tab, :class)]}
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
                class="tabs__separator"
                data-slot="tabs-separator"
                aria-hidden="true"
              ></span>
              {tab.label}<span class="tabs__indicator" data-slot="tabs-indicator" aria-hidden="true"></span>
            </button>
          </div>
        </div>
        <button
          type="button"
          class="tabs__list-container__scroll-prev"
          aria-label={@scroll_previous_label}
          tabindex="-1"
          x-on:click="scroll('previous')"
        ><svg aria-hidden="true" viewBox="0 0 16 16" fill="none"><path
          d="M10.53 2.97a.75.75 0 0 1 0 1.06L6.56 8l3.97 3.97a.75.75 0 1 1-1.06 1.06l-4.5-4.5a.75.75 0 0 1 0-1.06l4.5-4.5a.75.75 0 0 1 1.06 0"
          fill="currentColor"
        /></svg></button>
        <button
          type="button"
          class="tabs__list-container__scroll-next"
          aria-label={@scroll_next_label}
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
        class="tabs__panel"
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
  Register HeroUI's Alpine providers and use a browser with the Popover API.
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
      class={["dropdown", "hui-dropdown", @class]}
      data-hero-dropdown
      x-data="heroDropdown"
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
        class={["button", "button--md", "button--#{@variant}", "dropdown__trigger"]}
        data-hero-dropdown-trigger
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
        class="dropdown__popover hui-dropdown-popover"
        data-hero-dropdown-menu
        aria-label={@label}
        role="menu"
        phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["style"])}
      >
        <div class="dropdown__menu" data-slot="dropdown-menu" data-selection-mode={@selection_mode}>
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
      class={@label && "menu-section"}
      role={if @label, do: "group"}
      aria-label={@label}
      data-hero-dropdown-group
      data-selection-mode={@mode}
      data-controlled={to_string(@controlled)}
      data-close-on-select={
        to_string(if is_nil(@close_on_select), do: @mode != "multiple", else: @close_on_select)
      }
    >
      <div :if={@label} class="header" data-slot="header" aria-hidden="true">{@label}</div>
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
        data-hero-dropdown-selection-event
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
    <div :if={@submenu} class="w-full" role="none" data-hero-dropdown-submenu-root>
      <button
        id={@id}
        type="button"
        role="menuitem"
        tabindex="-1"
        class="menu-item menu-item--default"
        data-slot="menu-item"
        data-hero-dropdown-item
        data-hero-dropdown-submenu-trigger
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
          class="menu-item__indicator menu-item__indicator--submenu"
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
        class="dropdown__popover hui-dropdown-popover"
        data-hero-dropdown-menu
        data-hero-dropdown-submenu
        phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["style"])}
      >
        <div class="dropdown__menu" data-slot="dropdown-menu">
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
        "menu-item",
        "menu-item--default",
        Map.get(@entry, :danger, false) && "menu-item--danger"
      ]}
      data-slot="menu-item"
      data-hero-dropdown-item
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
      data-hero-dropdown-item
      phx-click={Map.get(@entry, :on_click) || @on_action}
      phx-value-key={Map.get(@entry, :key)}
      phx-target={@target}
      phx-mounted={
        if @mode != "none" && !@controlled,
          do: Phoenix.LiveView.JS.ignore_attributes(["aria-checked", "data-selected"])
      }
      class={[
        "menu-item",
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
    <span :if={@mode != "none"} class="menu-item__indicator" aria-hidden="true">
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
      <span :if={Map.get(@entry, :description)} class="description" data-slot="description">{Map.get(
        @entry,
        :description
      )}</span>
    </span>
    <kbd :if={Map.get(@entry, :shortcut)} class="kbd ml-auto" data-slot="keyboard">{Map.get(
      @entry,
      :shortcut
    )}</kbd>
    """
  end

  @doc """
  An alert dialog for decisions that require an explicit response.
  Open it with `data-hero-dialog-open` and install the HeroUI Alpine providers.
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
      class={["alert-dialog__dialog", "alert-dialog__dialog--#{@size}", "hui-native-modal", @class]}
      data-hero-dialog
      x-data="heroDialog"
      x-on:click.window="openFromTrigger($event)"
      x-on:click="onClick($event)"
      x-on:cancel="onCancel($event)"
      data-dismissible="false"
      phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["open"])}
    >
      <header class="alert-dialog__header">
        <h2 id={"#{@id}-title"} class="alert-dialog__heading">{@title}</h2>
      </header>
      <div id={"#{@id}-description"} class="alert-dialog__body">{render_slot(@inner_block)}</div>
      <div class="alert-dialog__footer">
        <button
          type="button"
          class="button button--md button--tertiary"
          data-hero-dialog-close
          autofocus
        >{@cancel_label}</button>
        <button
          type="button"
          class={["button", "button--md", "button--#{@confirm_variant}"]}
          phx-click={@on_confirm}
          data-hero-dialog-close
        >{@confirm_label}</button>
      </div>
    </dialog>
    """
  end

  @doc """
  A modal drawer attached to an edge of the viewport.
  Open it with `data-hero-dialog-open={id}`. Requires HeroUI's Alpine providers.
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
        "drawer__dialog",
        "hui-native-modal",
        "hui-native-drawer",
        @backdrop == "opaque" && "backdrop:bg-backdrop",
        @backdrop == "blur" && "backdrop:bg-backdrop backdrop:backdrop-blur-md",
        @backdrop == "transparent" && "backdrop:bg-transparent",
        @class
      ]}
      data-placement={@placement}
      data-backdrop={@backdrop}
      data-hero-drawer
      data-slot="drawer-dialog"
      x-data="heroDrawer"
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
          "drawer__handle",
          if(@placement in ["top", "bottom"], do: "touch-pan-x", else: "touch-pan-y")
        ]}
        data-slot="drawer-handle"
        data-hero-drawer-drag
        aria-hidden="true"
      >
        <span data-slot="drawer-handle-bar"></span>
      </div>
      <header
        class={[
          "drawer__header",
          if(@placement in ["top", "bottom"], do: "touch-pan-x", else: "touch-pan-y")
        ]}
        data-slot="drawer-header"
        data-hero-drawer-drag
      >
        <h2 id={"#{@id}-title"} class="drawer__heading" data-slot="drawer-heading">{@title}</h2>
      </header>
      <div class="drawer__body" data-slot="drawer-body">{render_slot(@inner_block)}</div>
      <div
        class={[
          "drawer__footer",
          if(@placement in ["top", "bottom"], do: "touch-pan-x", else: "touch-pan-y")
        ]}
        data-slot="drawer-footer"
        data-hero-drawer-drag
      >
        {render_slot(@footer)}
        <%= if @close != [] do %>
          {render_slot(@close, %{"data-hero-dialog-close" => true})}
        <% else %>
          <button
            :if={@show_close}
            type="button"
            class="button button--md button--tertiary"
            data-hero-dialog-close
          >{@close_label}</button>
        <% end %>
      </div>
      <button
        :if={@on_open_change}
        type="button"
        hidden
        data-hero-drawer-event
        phx-click={@on_open_change}
        phx-target={@target}
      ></button>
    </dialog>
    """
  end

  @doc """
  A noninteractive description shown on focus or hover. Requires HeroUI's Alpine providers.
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
      class={["hui-tooltip-root", @class]}
      data-hero-tooltip-root
      data-delay={@delay}
      data-close-delay={@close_delay}
      data-requested-placement={@placement}
      data-offset={@resolved_offset}
      x-data="heroTooltip"
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
        class={["button", "button--md", "button--tertiary", "tooltip__trigger", @trigger_class]}
        aria-describedby={"#{@id}-content"}
        data-hero-tooltip-trigger
        x-ref="trigger"
      >{render_slot(@inner_block)}</button>
      <span
        :if={@trigger != []}
        class={["inline-flex", @trigger_class]}
        data-hero-tooltip-trigger
        data-slot="tooltip-trigger"
        x-ref="trigger"
      >{render_slot(@trigger, %{"aria-describedby" => "#{@id}-content"})}</span>
      <span
        id={"#{@id}-content"}
        role="tooltip"
        popover="manual"
        class="tooltip hui-tooltip group/tooltip overflow-visible"
        data-hero-tooltip
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
        class="pointer-events-none absolute size-3 group-data-[placement=top]/tooltip:-bottom-3 group-data-[placement=top]/tooltip:left-1/2 group-data-[placement=top]/tooltip:-translate-x-1/2 group-data-[placement=bottom]/tooltip:-top-3 group-data-[placement=bottom]/tooltip:left-1/2 group-data-[placement=bottom]/tooltip:-translate-x-1/2 group-data-[placement=left]/tooltip:-right-3 group-data-[placement=left]/tooltip:top-1/2 group-data-[placement=left]/tooltip:-translate-y-1/2 group-data-[placement=right]/tooltip:-left-3 group-data-[placement=right]/tooltip:top-1/2 group-data-[placement=right]/tooltip:-translate-y-1/2"
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
  A nonmodal, interactive popover anchored to a button. Requires HeroUI's Alpine components.
  """
  attr(:id, :string, required: true)
  attr(:trigger, :string, required: true)
  attr(:title, :string, required: true)
  attr(:class, :any, default: nil)
  slot(:inner_block, required: true)

  def popover(assigns) do
    ~H"""
    <div
      class={["hui-popover-root", @class]}
      x-data="heroPopover"
      x-on:click="close($event)"
      x-on:resize.window="position()"
      x-on:scroll.window.capture="position()"
      x-on:phx:update.document="sync()"
    >
      <button
        type="button"
        class="button button--md button--secondary popover__trigger"
        x-ref="trigger"
        popovertarget={"#{@id}-content"}
        aria-controls={"#{@id}-content"}
        aria-expanded="false"
        aria-haspopup="dialog"
        phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["aria-expanded"])}
      >{@trigger}</button>
      <div
        id={"#{@id}-content"}
        popover="auto"
        role="dialog"
        aria-labelledby={"#{@id}-title"}
        tabindex="-1"
        class="popover popover__dialog hui-popover"
        data-hero-popover
        x-ref="content"
        x-on:toggle="toggle($event)"
        phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["style"])}
      >
        <span id={"#{@id}-title"} class="popover__heading">{@title}</span>
        <div class="hui-popover-content">{render_slot(@inner_block)}</div>
        <button type="button" class="button button--sm button--tertiary" data-hero-popover-close>Close</button>
      </div>
    </div>
    """
  end

  @doc "A single-value or multi-thumb slider. Requires HeroUI's Alpine components for pointer interaction and live updates."
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
      class={["slider", @orientation == "vertical" && "w-fit", @class]}
      data-orientation={@orientation}
      data-disabled={if @disabled, do: "true"}
      data-hero-slider
      x-data="heroSlider"
      x-on:input.capture="input($event)"
      x-on:pointerdown="start($event)"
      x-on:pointermove="move($event)"
      x-on:pointerup="end($event)"
      x-on:pointercancel="end($event)"
      x-on:reset.document="reset($event)"
      x-on:phx:update.document="sync()"
    >
      <label for={if @multiple, do: "#{@id}-0", else: @id} data-slot="label">{@label}</label>
      <output class="slider__output" data-hero-slider-output>{Enum.join(@values, " – ")}</output>
      <div
        class="slider__track touch-none"
        data-hero-slider-track
        data-fill-start={to_string(@start == 0)}
        data-fill-end={to_string(@finish == 100)}
      >
        <div
          class="slider__fill"
          data-hero-slider-fill
          style={slider_fill_style(@orientation, @start, @finish)}
        >
        </div>
        <div :if={@steps != []} class="slider__steps" data-slot="slider-steps" aria-hidden="true">
          <span
            :for={value <- @steps}
            class="slider__step"
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
            data-hero-slider-input
            {@rest}
          />
          <span
            class={[
              "slider__thumb peer-focus-visible:z-10 peer-focus-visible:outline-2 peer-focus-visible:outline-offset-2 peer-focus-visible:outline-focus",
              if(@orientation == "vertical",
                do: "-translate-x-1/2 translate-y-1/2",
                else: "-translate-x-1/2 -translate-y-1/2 rtl:translate-x-1/2"
              )
            ]}
            data-hero-slider-thumb
            data-disabled={if @disabled, do: "true"}
            style={slider_position_style(@orientation, Enum.at(@percentages, index))}
          ></span>
        </div>
      </div>
      <div :if={@visible_marks != []} class="slider__marks" data-slot="slider-marks">
        <span
          :for={{value, label} <- @visible_marks}
          class="slider__mark"
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

  @doc "A labelled numeric input with increment and decrement buttons. Requires HeroUI's Alpine components."
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
        "number-field",
        "number-field--#{@variant}",
        @full_width && "number-field--full-width",
        @class
      ]}
      data-slot="number-field"
      data-hero-number
      data-invalid={if @invalid_state, do: "true"}
      data-disabled={if @disabled, do: "true"}
      data-required={if @rest[:required] || @rest["required"], do: "true"}
      x-data="heroNumberField"
      x-bind:data-disabled="disabled ? 'true' : null"
      phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["data-disabled"])}
      x-init="$nextTick(() => sync())"
      x-on:input="sync()"
      x-on:change="sync()"
      x-on:phx:update.window="sync()"
      x-on:reset.window="$nextTick(() => sync())"
    >
      <label for={@id} class="label" data-slot="label">{@label}</label>
      <div
        class={["number-field__group", @full_width && "number-field__group--full-width"]}
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
          class="number-field__decrement-button"
          data-slot="number-field-decrement-button"
          aria-label={"#{@decrement_label} #{@label}"}
          aria-controls={@id}
          tabindex="-1"
          disabled={@disabled || @readonly}
          data-hero-number-step="down"
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
          class="number-field__input hui-number-input"
          data-slot="number-field-input"
          {@rest}
        />
        <button
          type="button"
          slot="increment"
          class="number-field__increment-button"
          data-slot="number-field-increment-button"
          aria-label={"#{@increment_label} #{@label}"}
          aria-controls={@id}
          tabindex="-1"
          disabled={@disabled || @readonly}
          data-hero-number-step="up"
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
      <span :if={@description} id={"#{@id}-description"} class="description" data-slot="description">{@description}</span>
      <div
        :if={@errors != []}
        id={"#{@id}-errors"}
        class="field-error"
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
      class={["pagination", "pagination--#{@size}", @class]}
      data-slot={@data_slot}
      {@rest}
    >
      <div :if={@summary != []} class="pagination__summary" data-slot="pagination-summary">
        {render_slot(@summary)}
      </div>
      <ul class="pagination__content" data-slot="pagination-content">
        <li :if={@show_controls} class="pagination__item">
          <.pagination_control
            page={max(@page - 1, 1)}
            label={@previous_label}
            disabled={@disabled || @page <= 1 || @total_pages == 0}
            nav
            on_change={@on_change}
            href={@href}
            patch={@patch}
            target={@target}
          >
            <span data-slot="pagination-previous-icon" aria-hidden="true">{render_slot(@previous_icon)}<svg
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
        <li :for={item <- if(@show_pages, do: @pages, else: [])} class="pagination__item">
          <span :if={item == :ellipsis} class="pagination__ellipsis" aria-hidden="true">…</span>
          <.pagination_control
            :if={item != :ellipsis}
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
        <li :if={@show_controls} class="pagination__item">
          <.pagination_control
            page={min(@page + 1, max(@total_pages, 1))}
            label={@next_label}
            disabled={@disabled || @page >= @total_pages}
            nav
            on_change={@on_change}
            href={@href}
            patch={@patch}
            target={@target}
          >
            <span>{@next_label}</span><span data-slot="pagination-next-icon" aria-hidden="true">{render_slot(
              @next_icon
            )}<svg
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
      class={["pagination__link", @nav && "pagination__link--nav"]}
      aria-disabled="true"
      aria-label={@label}
      aria-current={if @active, do: "page"}
      data-active={if @active, do: "true"}
    >{render_slot(@inner_block)}</span>
    <a
      :if={@href && !@disabled}
      href={@href.(@page)}
      class={["pagination__link", @nav && "pagination__link--nav"]}
      aria-label={@label}
      aria-current={if @active, do: "page"}
      data-active={if @active, do: "true"}
    >{render_slot(@inner_block)}</a>
    <Phoenix.Component.link
      :if={@patch && !@disabled}
      patch={@patch.(@page)}
      class={["pagination__link", @nav && "pagination__link--nav"]}
      aria-label={@label}
      aria-current={if @active, do: "page"}
      data-active={if @active, do: "true"}
    >{render_slot(@inner_block)}</Phoenix.Component.link>
    <button
      :if={!@href && !@patch}
      type="button"
      class={["pagination__link", @nav && "pagination__link--nav"]}
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
      class={["toolbar", "toolbar--#{@orientation}", @attached && "toolbar--attached", @class]}
      data-slot="toolbar"
      data-hero-toolbar
      data-orientation={@orientation}
      x-data="heroToolbar"
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
        "button-group",
        "button-group--#{@orientation}",
        @full_width && "button-group--full-width",
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
      class={["button-group__separator", @class]}
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
      data-hero-toggle-size={@size}
      x-data={if @uncontrolled, do: "{ selected: #{to_string(@selected)} }"}
      x-bind:aria-pressed={
        if @uncontrolled,
          do:
            "$el.closest('[data-hero-toggle-group]')?.dataset.heroToggleGroup !== 'managed' ? selected.toString() : null"
      }
      x-bind:data-selected={
        if @uncontrolled,
          do:
            "$el.closest('[data-hero-toggle-group]')?.dataset.heroToggleGroup !== 'managed' && selected ? 'true' : null"
      }
      x-on:click={
        if @uncontrolled,
          do:
            "if ($el.closest('[data-hero-toggle-group]')?.dataset.heroToggleGroup !== 'managed') selected = !selected"
      }
      phx-mounted={
        if @uncontrolled, do: Phoenix.LiveView.JS.ignore_attributes(["aria-pressed", "data-selected"])
      }
      class={[
        "toggle-button",
        "toggle-button--#{@size || "md"}",
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
      data-hero-toggle-size={@size}
      data-hero-toggle-group={if @selection_mode, do: "managed", else: "independent"}
      data-selection-mode={@selection_mode}
      data-orientation={@orientation}
      data-controlled={if @selection_mode, do: to_string(!is_nil(@selected_keys))}
      data-selected-keys={if @selection_mode, do: @encoded_keys}
      data-disallow-empty={if @selection_mode, do: to_string(@disallow_empty_selection)}
      x-data="heroToggleButtonGroup"
      x-on:click={if @selection_mode, do: "click($event)"}
      x-on:focusin={if @selection_mode, do: "focus($event)"}
      x-on:keydown={if @selection_mode, do: "keydown($event)"}
      x-on:phx:update.window="sync()"
      class={[
        "toggle-button-group",
        "toggle-button-group--#{@orientation}",
        @detached && "toggle-button-group--detached",
        @full_width && "toggle-button-group--full-width",
        @class
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
      <button
        :if={@selection_mode && @on_selection_change}
        type="button"
        hidden
        data-hero-toggle-group-event
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
      <ol class={["breadcrumbs", @class]}>
        <li :for={{item, index} <- Enum.with_index(@item)} class="breadcrumbs__item">
          <a
            :if={index != @last_index && Map.get(item, :href)}
            href={item.href}
            class="breadcrumbs__link"
          >{item.label}</a>
          <span
            :if={index == @last_index || !Map.get(item, :href)}
            class="breadcrumbs__link"
            data-current={if index == @last_index, do: "true"}
            aria-current={if index == @last_index, do: "page"}
          >{item.label}</span>
          <svg
            :if={index != @last_index}
            class="breadcrumbs__separator"
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
  A server-controlled listbox. `on_select` receives `%{"value" => value}`;
  the caller updates `selected`. Keyboard navigation requires HeroUI's Alpine providers.
  """
  attr(:id, :string, required: true)
  attr(:label, :string, required: true)
  attr(:on_select, :any, required: true)
  attr(:selected, :list, default: [])
  attr(:selection_mode, :string, default: "single", values: ~w(single multiple))
  attr(:disabled, :boolean, default: false)
  attr(:target, :any, default: nil)
  attr(:class, :any, default: nil)

  slot :option, required: true do
    attr(:value, :string, required: true)
    attr(:label, :string, required: true)
    attr(:description, :string)
    attr(:disabled, :boolean)
  end

  def listbox(assigns) do
    values = Enum.map(assigns.option, & &1.value)

    if length(values) != length(Enum.uniq(values)),
      do: raise(ArgumentError, "listbox option values must be unique")

    if assigns.selection_mode == "single" and length(assigns.selected) > 1,
      do: raise(ArgumentError, "single-selection listbox accepts at most one selected value")

    enabled = Enum.reject(assigns.option, &Map.get(&1, :disabled, false))
    active = Enum.find(enabled, &(&1.value in assigns.selected)) || List.first(enabled)

    assigns =
      assign(assigns, :active_id, if(active, do: listbox_option_id(assigns.id, active.value)))

    ~H"""
    <div
      id={@id}
      class={["list-box", "hui-listbox", @class]}
      role="listbox"
      aria-label={@label}
      aria-multiselectable={if @selection_mode == "multiple", do: "true"}
      aria-disabled={if @disabled, do: "true"}
      tabindex={if @disabled, do: "-1", else: "0"}
      aria-activedescendant={@active_id}
      data-hero-listbox
      x-data="heroListbox"
      x-on:click="click($event)"
      x-on:keydown="keydown($event)"
      x-on:phx:update.window="sync()"
      phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["aria-activedescendant"])}
    >
      <div
        :for={option <- @option}
        id={listbox_option_id(@id, option.value)}
        role="option"
        aria-labelledby={"#{listbox_option_id(@id, option.value)}-label"}
        aria-describedby={
          if Map.get(option, :description), do: "#{listbox_option_id(@id, option.value)}-description"
        }
        aria-selected={to_string(option.value in @selected)}
        aria-disabled={if @disabled || Map.get(option, :disabled, false), do: "true"}
        data-disabled={if @disabled || Map.get(option, :disabled, false), do: "true"}
        data-active={if listbox_option_id(@id, option.value) == @active_id, do: "true"}
        phx-click={if !@disabled && !Map.get(option, :disabled, false), do: @on_select}
        phx-value-value={option.value}
        phx-target={@target}
        phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["data-active"])}
        class="list-box-item list-box-item--default"
      >
        <span class="hui-listbox-text"><span
          id={"#{listbox_option_id(@id, option.value)}-label"}
          data-slot="label"
        >{option.label}</span><span
          :if={Map.get(option, :description)}
          id={"#{listbox_option_id(@id, option.value)}-description"}
          class="description"
          data-slot="description"
        >{option.description}</span></span>
        <span
          class="list-box-item__indicator"
          aria-hidden="true"
          hidden={option.value not in @selected}
        ><svg data-slot="list-box-item-indicator--checkmark" viewBox="0 0 16 16" fill="none"><path
          d="M3.5 8l3 3 6-6"
          stroke="currentColor"
          stroke-width="2"
          stroke-linecap="round"
          stroke-linejoin="round"
        /></svg></span>
      </div>
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

    if Enum.any?(assigns.remove_button, fn slot ->
         label = Map.get(slot, :label)
         !is_nil(label) && (!is_binary(label) || String.trim(label) == "")
       end),
       do: raise(ArgumentError, "remove button labels must not be empty")

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
    <div class={["tag-group", @class]} data-slot="tag-group">
      <span id={"#{@id}-label"} class="label">{@label}</span>
      <div
        id={@id}
        class="tag-group__list"
        data-slot="tag-group-list"
        data-hero-tag-group
        data-selection-mode={@selection_mode}
        data-controlled={to_string(@controlled)}
        data-selected-keys={@encoded_selected}
        data-selection-event-id={if @on_selection_change, do: "#{@id}-selection-event"}
        x-data="heroTagGroup"
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
          class={["tag", "tag--#{@size}", "tag--#{@variant}"]}
          data-slot="tag"
          data-hero-tag
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
                "close-button close-button--default tag__remove-button",
                get_in(@remove_buttons, [tag.value, :class])
              ]}
              data-slot="tag-remove-button"
              data-hero-tag-remove
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
      <p :if={@description} id={"#{@id}-description"} class="description" data-slot="description">
        {@description}
      </p>
      <div :if={@errors != []} id={"#{@id}-errors"} class="error-message" data-slot="error-message">
        <p :for={error <- @errors}>{error}</p>
      </div>
    </div>
    """
  end

  defp listbox_option_id(id, value),
    do: id <> "-option-" <> Base.url_encode64(value, padding: false)
end
