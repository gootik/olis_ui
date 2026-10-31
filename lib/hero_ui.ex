defmodule HeroUI do
  @moduledoc """
  HeroUI-inspired function components for Phoenix LiveView.

  Import this module in your HTML helpers and include the official HeroUI v3 styles and `assets/css/hero_ui.css` in your Tailwind v4 application stylesheet. See the README for setup and examples.
  """
  use Phoenix.Component

  @doc "A native button with HeroUI v3 variants. Defaults to type=button."
  attr(:variant, :string,
    default: "primary",
    values: ~w(primary secondary tertiary outline ghost danger danger-soft)
  )

  attr(:size, :string, default: "md", values: ~w(sm md lg))
  attr(:type, :string, default: "button", values: ~w(button submit reset))
  attr(:disabled, :boolean, default: false)
  attr(:full_width, :boolean, default: false)
  attr(:icon_only, :boolean, default: false)
  attr(:class, :any, default: nil)
  attr(:rest, :global, include: ~w(form name value))
  slot(:inner_block, required: true)

  def button(assigns) do
    ~H"""
    <button
      type={@type}
      disabled={@disabled}
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

  @doc "A labelled input with optional description and errors. Accepts a Phoenix form field."
  attr(:field, Phoenix.HTML.FormField, default: nil)
  attr(:id, :string, default: nil)
  attr(:name, :string, default: nil)
  attr(:value, :any, default: nil)
  attr(:label, :string, required: true)
  attr(:description, :string, default: nil)
  attr(:errors, :list, default: [])
  attr(:type, :string, default: "text")
  attr(:variant, :string, default: "primary", values: ~w(primary secondary))
  attr(:class, :any, default: nil)

  attr(:rest, :global,
    include:
      ~w(autocomplete autofocus disabled form max maxlength min minlength pattern placeholder readonly required step)
  )

  def text_field(assigns) do
    field = assigns.field

    assigns =
      assigns
      |> assign(:id, assigns.id || (field && field.id))
      |> assign(:name, assigns.name || (field && field.name))
      |> assign(:value, if(is_nil(assigns.value) && field, do: field.value, else: assigns.value))

    if is_nil(assigns.id), do: raise(ArgumentError, "text_field requires an id or field")

    assigns =
      assign(
        assigns,
        :describedby,
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
      )

    ~H"""
    <div class={["hui-field", @class]}>
      <label class="hui-label" for={@id}>{@label}</label>
      <.input
        id={@id}
        name={@name}
        value={@value}
        type={@type}
        variant={@variant}
        invalid={@errors != []}
        full_width
        aria-describedby={if @describedby != "", do: @describedby}
        {@rest}
      />
      <p :if={@description} class="hui-description" id={"#{@id}-description"}>{@description}</p>
      <div :if={@errors != []} class="hui-errors" id={"#{@id}-errors"}>
        <p :for={error <- @errors}>{error}</p>
      </div>
    </div>
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
      phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["data-empty"])}
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
          class="search-field__input"
          data-slot="search-field-input"
          aria-invalid={if @errors != [], do: "true"}
          aria-describedby={if @describedby != "", do: @describedby}
          {@rest}
        />
        <button
          type="button"
          class="close-button close-button--default search-field__clear-button"
          data-slot="search-field-clear-button"
          data-hero-search-clear
          slot="clear"
          aria-label="Clear search"
          hidden
        ><svg aria-hidden="true" data-slot="close-button-icon" viewBox="0 0 16 16" fill="none"><path
          d="M3.47 3.47a.75.75 0 0 1 1.06 0L8 6.94l3.47-3.47a.75.75 0 1 1 1.06 1.06L9.06 8l3.47 3.47a.75.75 0 1 1-1.06 1.06L8 9.06l-3.47 3.47a.75.75 0 0 1-1.06-1.06L6.94 8 3.47 4.53a.75.75 0 0 1 0-1.06Z"
          fill="currentColor"
          fill-rule="evenodd"
          clip-rule="evenodd"
        /></svg></button>
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

  @doc "A surface for grouped content."
  attr(:class, :any, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def card(assigns) do
    ~H"""
    <div class={["card", "card--default", @class]} {@rest}>{render_slot(@inner_block)}</div>
    """
  end

  @doc "A compact label with HeroUI v3 color, variant, and size options."
  attr(:variant, :string, default: "primary", values: ~w(primary secondary tertiary soft))
  attr(:color, :string, default: "default", values: ~w(default accent success warning danger))
  attr(:size, :string, default: "md", values: ~w(sm md lg))
  attr(:class, :any, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def chip(assigns) do
    ~H"""
    <span class={["chip", "chip--#{@variant}", "chip--#{@color}", "chip--#{@size}", @class]} {@rest}><span class="chip__label">{render_slot(
      @inner_block
    )}</span></span>
    """
  end

  @doc "An accessible loading indicator."
  attr(:size, :string, default: "md", values: ~w(sm md lg xl))
  attr(:label, :string, default: "Loading")
  attr(:class, :any, default: nil)

  def spinner(assigns) do
    ~H"""
    <svg
      class={["hui-spinner", "hui-spinner--#{@size}", @class]}
      role="status"
      aria-label={@label}
      viewBox="0 0 24 24"
      fill="none"
    >
      <circle cx="12" cy="12" r="9" stroke="currentColor" stroke-width="3" opacity="0.2" />
      <path d="M12 3a9 9 0 0 1 9 9" stroke="currentColor" stroke-width="3" stroke-linecap="round" />
    </svg>
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

  @doc "A placeholder for content that is loading. Set its dimensions with CSS."
  attr(:class, :any, default: nil)
  attr(:rest, :global)

  def skeleton(assigns) do
    ~H"""
    <div class={["skeleton", "skeleton--shimmer", @class]} aria-hidden="true" {@rest}></div>
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

  @doc "A native checkbox presented as a HeroUI switch."
  attr(:id, :string, required: true)
  attr(:name, :string, default: nil)
  attr(:value, :string, default: "true")
  attr(:checked, :boolean, default: false)
  attr(:disabled, :boolean, default: false)
  attr(:size, :string, default: "md", values: ~w(sm md lg))
  attr(:class, :any, default: nil)
  attr(:rest, :global, include: ~w(required form))
  slot(:inner_block, required: true)

  def switch(assigns) do
    ~H"""
    <label
      class={["switch", "switch--#{@size}", "hui-native-switch", @class]}
      for={@id}
      data-disabled={if @disabled, do: "true"}
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
          class="hui-visually-hidden-input"
          {@rest}
        />
        <span class="switch__control" aria-hidden="true"><span class="switch__thumb"></span></span>
        <span data-slot="label">{render_slot(@inner_block)}</span>
      </span>
    </label>
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
        phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["data-failed"])}
      />
    </span>
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

  @doc "A native link."
  attr(:href, :string, required: true)
  attr(:class, :any, default: nil)
  attr(:rest, :global, include: ~w(download hreflang media ping referrerpolicy rel target type))
  slot(:inner_block, required: true)

  def ui_link(assigns) do
    ~H"""
    <a href={@href} class={["hui-link", @class]} {@rest}>{render_slot(@inner_block)}</a>
    """
  end

  @doc "A semantic surface for grouped content."
  attr(:variant, :string, default: "default", values: ~w(default secondary tertiary transparent))
  attr(:class, :any, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def surface(assigns) do
    ~H"""
    <div class={["hui-surface", "hui-surface--#{@variant}", @class]} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

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

  def toast_region(assigns) do
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
      data-placement={@placement}
      data-gap={@gap}
      data-max-visible={@max_visible}
      data-timeout={@timeout}
      data-expanded={to_string(@expanded)}
      style={"--toast-width: #{@width}px; --gap: #{@gap}px"}
      role="region"
      aria-label={@label}
      tabindex="-1"
      phx-update="ignore"
    >
      <ol data-hero-toast-list style="display:contents"></ol>
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

  @doc "A native disclosure. Supply a shared name to make a group exclusive."
  attr(:title, :string, required: true)
  attr(:open, :boolean, default: false)
  attr(:name, :string, default: nil)
  attr(:class, :any, default: nil)
  slot(:inner_block, required: true)

  def accordion(assigns) do
    ~H"""
    <details
      class={["accordion", "accordion__item", "hui-native-accordion", @class]}
      open={@open}
      name={@name}
    >
      <summary class="accordion__trigger">
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
    """
  end

  @doc "A message for contextual feedback. Set role to alert for urgent messages."
  attr(:title, :string, required: true)
  attr(:color, :string, default: "default", values: ~w(default accent success warning danger))
  attr(:role, :string, default: "status", values: ~w(status alert))
  attr(:class, :any, default: nil)
  slot(:inner_block)

  def alert(assigns) do
    assigns = assign(assigns, :icon_path, alert_icon_path(assigns.color))

    ~H"""
    <div role={@role} class={["alert", "alert--#{@color}", @class]}>
      <span class="alert__indicator" aria-hidden="true"><svg
        data-slot="alert-default-icon"
        viewBox="0 0 16 16"
        fill="none"
      ><path d={@icon_path} fill="currentColor" fill-rule="evenodd" clip-rule="evenodd" /></svg></span>
      <div class="alert__content">
        <div class="alert__title">{@title}</div><div
          :if={@inner_block != []}
          class="alert__description"
        >
          {render_slot(@inner_block)}
        </div>
      </div>
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

  Load `installHeroUI` as described in the README. Open it with a button carrying
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
  A keyboard-accessible tab set. The first enabled tab is selected by default.
  Tab ids must be unique within the set. Requires `installHeroUI` in the browser.
  """
  attr(:id, :string, required: true)
  attr(:label, :string, required: true)
  attr(:selected, :string, default: nil)
  attr(:variant, :string, default: "primary", values: ~w(primary secondary))
  attr(:orientation, :string, default: "horizontal", values: ~w(horizontal vertical))
  attr(:class, :any, default: nil)

  slot :tab, required: true do
    attr(:id, :string, required: true)
    attr(:label, :string, required: true)
    attr(:disabled, :boolean)
  end

  def tabs(assigns) do
    enabled = Enum.reject(assigns.tab, &Map.get(&1, :disabled, false))
    ids = Enum.map(assigns.tab, & &1.id)

    if enabled == [] or length(ids) != length(Enum.uniq(ids)),
      do: raise(ArgumentError, "tabs require distinct ids and at least one enabled tab")

    selected = assigns.selected || hd(enabled).id

    if not Enum.any?(enabled, &(&1.id == selected)),
      do: raise(ArgumentError, "selected tab must exist and be enabled")

    assigns = assign(assigns, :selected_id, selected)

    ~H"""
    <div
      id={@id}
      class={["tabs", "tabs--#{@variant}", @class]}
      data-orientation={@orientation}
      data-hero-tabs
    >
      <div class="tabs__list-container">
        <div
          class="tabs__list"
          role="tablist"
          aria-label={@label}
          aria-orientation={@orientation}
          data-orientation={@orientation}
        >
          <button
            :for={tab <- @tab}
            id={"#{@id}-tab-#{tab.id}"}
            type="button"
            role="tab"
            class="tabs__tab"
            data-selected={to_string(tab.id == @selected_id)}
            aria-selected={to_string(tab.id == @selected_id)}
            aria-controls={"#{@id}-panel-#{tab.id}"}
            tabindex={if tab.id == @selected_id, do: "0", else: "-1"}
            disabled={Map.get(tab, :disabled, false)}
            phx-mounted={
              Phoenix.LiveView.JS.ignore_attributes(["aria-selected", "data-selected", "tabindex"])
            }
          >
            {tab.label}<span class="tabs__indicator" aria-hidden="true"></span>
          </button>
        </div>
      </div>
      <div
        :for={tab <- @tab}
        id={"#{@id}-panel-#{tab.id}"}
        role="tabpanel"
        class="tabs__panel"
        data-orientation={@orientation}
        aria-labelledby={"#{@id}-tab-#{tab.id}"}
        hidden={tab.id != @selected_id}
        tabindex="0"
        phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["hidden"])}
      >
        {render_slot(tab)}
      </div>
    </div>
    """
  end

  @doc """
  An action menu using the native Popover API. Requires `installHeroUI`.
  Each item accepts a label and either `on_click` for a LiveView event or `href`.
  """
  attr(:id, :string, required: true)
  attr(:label, :string, required: true)

  attr(:variant, :string,
    default: "secondary",
    values: ~w(primary secondary tertiary outline ghost danger danger-soft)
  )

  attr(:class, :any, default: nil)

  slot :item, required: true do
    attr(:label, :string, required: true)
    attr(:on_click, :any)
    attr(:href, :string)
    attr(:disabled, :boolean)
    attr(:danger, :boolean)
  end

  def dropdown(assigns) do
    ~H"""
    <div class={["dropdown", "hui-dropdown", @class]} data-hero-dropdown>
      <button
        type="button"
        class={["button", "button--md", "button--#{@variant}", "dropdown__trigger"]}
        popovertarget={"#{@id}-menu"}
        aria-haspopup="menu"
        aria-controls={"#{@id}-menu"}
        aria-expanded="false"
        phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["aria-expanded"])}
      >{@label}</button>
      <div
        id={"#{@id}-menu"}
        popover="auto"
        class="dropdown__popover hui-dropdown-popover"
        data-hero-menu
        aria-label={@label}
        role="menu"
        phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["style"])}
      >
        <div class="dropdown__menu" data-slot="dropdown-menu">
          <%= for item <- @item do %>
            <a
              :if={Map.get(item, :href) && !Map.get(item, :disabled, false)}
              href={item.href}
              role="menuitem"
              tabindex="-1"
              class={[
                "menu-item",
                "menu-item--default",
                Map.get(item, :danger, false) && "menu-item--danger"
              ]}
              data-slot="menu-item"
            ><span data-slot="label">{item.label}</span></a>
            <button
              :if={!Map.get(item, :href) || Map.get(item, :disabled, false)}
              type="button"
              role="menuitem"
              tabindex="-1"
              disabled={Map.get(item, :disabled, false)}
              phx-click={Map.get(item, :on_click)}
              class={[
                "menu-item",
                "menu-item--default",
                Map.get(item, :danger, false) && "menu-item--danger"
              ]}
              data-slot="menu-item"
            ><span data-slot="label">{item.label}</span></button>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  @doc """
  An alert dialog for decisions that require an explicit response.
  Open it with `data-hero-dialog-open` and install the HeroUI JavaScript module.
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
  Open it with `data-hero-dialog-open` and install the HeroUI JavaScript module.
  """
  attr(:id, :string, required: true)
  attr(:title, :string, required: true)
  attr(:placement, :string, default: "right", values: ~w(top bottom left right))
  attr(:dismissible, :boolean, default: true)
  attr(:class, :any, default: nil)
  slot(:inner_block, required: true)
  slot(:footer)

  def drawer(assigns) do
    ~H"""
    <dialog
      id={@id}
      aria-labelledby={"#{@id}-title"}
      class={["drawer__dialog", "hui-native-modal", "hui-native-drawer", @class]}
      data-placement={@placement}
      data-hero-dialog
      data-dismissible={to_string(@dismissible)}
      phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["open"])}
    >
      <header class="drawer__header">
        <h2 id={"#{@id}-title"} class="drawer__heading">{@title}</h2>
      </header>
      <div class="drawer__body">{render_slot(@inner_block)}</div>
      <div class="drawer__footer">
        {render_slot(@footer)}<button
          type="button"
          class="button button--md button--tertiary"
          data-hero-dialog-close
        >Close</button>
      </div>
    </dialog>
    """
  end

  @doc """
  A noninteractive description shown on focus or hover. Requires `installHeroUI`.
  The slot is the content of the trigger button; do not nest interactive elements inside it.
  """
  attr(:id, :string, required: true)
  attr(:text, :string, required: true)
  attr(:placement, :string, default: "top", values: ~w(top bottom))
  attr(:delay, :integer, default: 1500)
  attr(:class, :any, default: nil)
  attr(:trigger_class, :any, default: nil)
  slot(:inner_block, required: true)

  def tooltip(assigns) do
    if assigns.delay < 0, do: raise(ArgumentError, "tooltip delay must be nonnegative")

    ~H"""
    <span class={["hui-tooltip-root", @class]} data-hero-tooltip-root data-delay={@delay}>
      <button
        type="button"
        class={["button", "button--md", "button--tertiary", "tooltip__trigger", @trigger_class]}
        aria-describedby={"#{@id}-content"}
        data-hero-tooltip-trigger
      >{render_slot(@inner_block)}</button>
      <span
        id={"#{@id}-content"}
        role="tooltip"
        popover="manual"
        class="tooltip hui-tooltip"
        data-hero-tooltip
        data-placement={@placement}
        phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["style"])}
      >{@text}</span>
    </span>
    """
  end

  @doc """
  A nonmodal, interactive popover anchored to a button. Requires `installHeroUI`.
  """
  attr(:id, :string, required: true)
  attr(:trigger, :string, required: true)
  attr(:title, :string, required: true)
  attr(:class, :any, default: nil)
  slot(:inner_block, required: true)

  def popover(assigns) do
    ~H"""
    <div class={["hui-popover-root", @class]}>
      <button
        type="button"
        class="button button--md button--secondary popover__trigger"
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
        phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["style"])}
      >
        <span id={"#{@id}-title"} class="popover__heading">{@title}</span>
        <div class="hui-popover-content">{render_slot(@inner_block)}</div>
        <button type="button" class="button button--sm button--tertiary" data-hero-popover-close>Close</button>
      </div>
    </div>
    """
  end

  @doc "A native range input with a HeroUI-style track. Requires `installHeroUI` for live output updates."
  attr(:id, :string, required: true)
  attr(:name, :string, default: nil)
  attr(:label, :string, required: true)
  attr(:value, :any, required: true)
  attr(:min, :any, default: 0)
  attr(:max, :any, default: 100)
  attr(:step, :any, default: 1)
  attr(:disabled, :boolean, default: false)
  attr(:class, :any, default: nil)
  attr(:rest, :global, include: ~w(form required))

  def slider(assigns) do
    percent = range_percent!(assigns.value, assigns.min, assigns.max, false)

    if not is_number(assigns.step) or assigns.step <= 0,
      do: raise(ArgumentError, "slider step must be a positive number")

    assigns = assign(assigns, :percent, percent)

    ~H"""
    <div
      class={["slider", "hui-native-slider", @class]}
      data-orientation="horizontal"
      data-disabled={if @disabled, do: "true"}
      data-hero-slider
    >
      <label for={@id} data-slot="label">{@label}</label>
      <output class="slider__output" for={@id} data-hero-slider-output>{@value}</output>
      <input
        id={@id}
        name={@name}
        type="range"
        value={@value}
        min={@min}
        max={@max}
        step={@step}
        disabled={@disabled}
        class="hui-slider-input"
        style={"--hui-slider-percent: #{@percent}%"}
        data-hero-slider-input
        {@rest}
      />
    </div>
    """
  end

  @doc "A labelled numeric input with increment and decrement buttons. Requires `installHeroUI`."
  attr(:id, :string, required: true)
  attr(:name, :string, default: nil)
  attr(:label, :string, required: true)
  attr(:value, :any, default: nil)
  attr(:min, :any, default: nil)
  attr(:max, :any, default: nil)
  attr(:step, :any, default: 1)
  attr(:disabled, :boolean, default: false)
  attr(:readonly, :boolean, default: false)
  attr(:invalid, :boolean, default: false)
  attr(:variant, :string, default: "primary", values: ~w(primary secondary))
  attr(:increment_label, :string, default: "Increase")
  attr(:decrement_label, :string, default: "Decrease")
  attr(:class, :any, default: nil)
  attr(:rest, :global, include: ~w(autocomplete autofocus form placeholder required))

  def number_field(assigns) do
    if not is_number(assigns.step) or assigns.step <= 0,
      do: raise(ArgumentError, "number field step must be a positive number")

    ~H"""
    <div
      class={["number-field", "number-field--#{@variant}", @class]}
      data-hero-number
      data-invalid={if @invalid, do: "true"}
    >
      <label for={@id} class="label" data-slot="label">{@label}</label>
      <div
        class="number-field__group"
        data-disabled={if @disabled, do: "true"}
        data-invalid={if @invalid, do: "true"}
      >
        <button
          type="button"
          slot="decrement"
          class="number-field__decrement-button"
          aria-label={"#{@decrement_label} #{@label}"}
          disabled={@disabled || @readonly}
          data-hero-number-step="down"
        >−</button>
        <input
          type="number"
          id={@id}
          name={@name}
          value={@value}
          min={@min}
          max={@max}
          step={@step}
          disabled={@disabled}
          readonly={@readonly}
          aria-invalid={if @invalid, do: "true"}
          class="number-field__input hui-number-input"
          data-slot="number-field-input"
          {@rest}
        />
        <button
          type="button"
          slot="increment"
          class="number-field__increment-button"
          aria-label={"#{@increment_label} #{@label}"}
          disabled={@disabled || @readonly}
          data-hero-number-step="up"
        >+</button>
      </div>
    </div>
    """
  end

  @doc """
  Page navigation with bounded page links. Provide either `on_change` for a
  LiveView event receiving `%{"page" => "N"}`, or `href` as a one-argument
  function returning a URL. The caller owns the current page and data loading.
  """
  attr(:page, :integer, required: true)
  attr(:total_pages, :integer, required: true)
  attr(:on_change, :string, default: nil)
  attr(:href, :any, default: nil)
  attr(:target, :any, default: nil)
  attr(:siblings, :integer, default: 1)
  attr(:label, :string, default: "Pagination")
  attr(:previous_label, :string, default: "Previous")
  attr(:next_label, :string, default: "Next")
  attr(:size, :string, default: "md", values: ~w(sm md lg))
  attr(:class, :any, default: nil)
  slot(:summary)

  def pagination(assigns) do
    if assigns.total_pages < 0 or assigns.page < 1 or assigns.page > max(assigns.total_pages, 1) or
         assigns.siblings < 0,
       do:
         raise(
           ArgumentError,
           "page must be within the total page count and siblings must be nonnegative"
         )

    if is_nil(assigns.on_change) == is_nil(assigns.href),
      do: raise(ArgumentError, "provide exactly one of on_change or href")

    if assigns.href && !is_function(assigns.href, 1),
      do: raise(ArgumentError, "href must be a one-argument function")

    assigns =
      assign(
        assigns,
        :pages,
        pagination_pages(assigns.page, assigns.total_pages, assigns.siblings)
      )

    ~H"""
    <nav aria-label={@label} class={["pagination", "pagination--#{@size}", @class]}>
      <div :if={@summary != []} class="pagination__summary">{render_slot(@summary)}</div>
      <ul class="pagination__content">
        <li class="pagination__item">
          <.pagination_control
            page={max(@page - 1, 1)}
            label={@previous_label}
            disabled={@page <= 1 || @total_pages == 0}
            nav
            on_change={@on_change}
            href={@href}
            target={@target}
          >
            <span data-slot="pagination-previous-icon" aria-hidden="true"><svg
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
        <li :for={item <- @pages} class="pagination__item">
          <span :if={item == :ellipsis} class="pagination__ellipsis" aria-hidden="true">…</span>
          <.pagination_control
            :if={item != :ellipsis}
            page={item}
            label={"Page #{item}"}
            active={item == @page}
            on_change={@on_change}
            href={@href}
            target={@target}
          >
            {item}
          </.pagination_control>
        </li>
        <li class="pagination__item">
          <.pagination_control
            page={min(@page + 1, max(@total_pages, 1))}
            label={@next_label}
            disabled={@page >= @total_pages}
            nav
            on_change={@on_change}
            href={@href}
            target={@target}
          >
            <span>{@next_label}</span><span data-slot="pagination-next-icon" aria-hidden="true"><svg
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
  attr(:on_change, :string, default: nil)
  attr(:href, :any, default: nil)
  attr(:target, :any, default: nil)
  slot(:inner_block, required: true)

  defp pagination_control(assigns) do
    ~H"""
    <span
      :if={@href && @disabled}
      class={["pagination__link", @nav && "pagination__link--nav"]}
      aria-disabled="true"
      aria-label={@label}
    >{render_slot(@inner_block)}</span>
    <a
      :if={@href && !@disabled}
      href={@href.(@page)}
      class={["pagination__link", @nav && "pagination__link--nav"]}
      aria-label={@label}
      aria-current={if @active, do: "page"}
      data-active={if @active, do: "true"}
    >{render_slot(@inner_block)}</a>
    <button
      :if={!@href}
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

  @doc "Groups adjacent buttons using HeroUI's attached button styles."
  attr(:label, :string, default: nil)
  attr(:orientation, :string, default: "horizontal", values: ~w(horizontal vertical))
  attr(:full_width, :boolean, default: false)
  attr(:class, :any, default: nil)
  slot(:inner_block, required: true)

  def button_group(assigns) do
    ~H"""
    <div
      role="group"
      aria-label={@label}
      class={[
        "button-group",
        "button-group--#{@orientation}",
        @full_width && "button-group--full-width",
        @class
      ]}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc "A server-controlled toggle button. Handle `phx-click` and update `pressed` in LiveView."
  attr(:pressed, :boolean, default: false)
  attr(:disabled, :boolean, default: false)
  attr(:size, :string, default: "md", values: ~w(sm md lg))
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
      class={[
        "toggle-button",
        "toggle-button--#{@size}",
        "toggle-button--#{@variant}",
        @icon_only && "toggle-button--icon-only",
        @class
      ]}
      {@rest}
    >{render_slot(@inner_block)}</button>
    """
  end

  @doc "Groups related toggle buttons; each button's pressed state is managed by the caller."
  attr(:label, :string, required: true)
  attr(:orientation, :string, default: "horizontal", values: ~w(horizontal vertical))
  attr(:detached, :boolean, default: false)
  attr(:full_width, :boolean, default: false)
  attr(:class, :any, default: nil)
  slot(:inner_block, required: true)

  def toggle_button_group(assigns) do
    ~H"""
    <div
      role="group"
      aria-label={@label}
      class={[
        "toggle-button-group",
        "toggle-button-group--#{@orientation}",
        @detached && "toggle-button-group--detached",
        @full_width && "toggle-button-group--full-width",
        @class
      ]}
    >
      {render_slot(@inner_block)}
    </div>
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
  the caller updates `selected`. Keyboard navigation requires `installHeroUI`.
  """
  attr(:id, :string, required: true)
  attr(:label, :string, required: true)
  attr(:on_select, :string, required: true)
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
  A server-controlled group of selectable or removable tags. Events receive
  `%{"value" => value}`; update `selected` or the tag slots in the LiveView.
  """
  attr(:id, :string, required: true)
  attr(:label, :string, required: true)
  attr(:description, :string, default: nil)
  attr(:errors, :list, default: [])
  attr(:selection_mode, :string, default: "none", values: ~w(none single multiple))
  attr(:selected, :list, default: [])
  attr(:on_select, :string, default: nil)
  attr(:on_remove, :string, default: nil)
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

  slot(:empty)

  def tag_group(assigns) do
    values = Enum.map(assigns.tag, & &1.value)

    if length(values) != length(Enum.uniq(values)),
      do: raise(ArgumentError, "tag values must be unique")

    if assigns.selection_mode == "single" and length(assigns.selected) > 1,
      do: raise(ArgumentError, "single-selection tag group accepts at most one selected value")

    if assigns.selection_mode != "none" and is_nil(assigns.on_select),
      do: raise(ArgumentError, "selectable tag groups require on_select")

    enabled = Enum.reject(assigns.tag, &Map.get(&1, :disabled, false))
    active = Enum.find(enabled, &(&1.value in assigns.selected)) || List.first(enabled)

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
      |> assign(:describedby, describedby)

    ~H"""
    <div class={["tag-group", @class]} data-slot="tag-group">
      <span id={"#{@id}-label"} class="label">{@label}</span>
      <div
        id={@id}
        class="tag-group__list"
        data-slot="tag-group-list"
        data-hero-tag-group
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
          data-selection-mode={@selection_mode}
          data-disabled={if @disabled || Map.get(tag, :disabled, false), do: "true"}
          data-selected={if @selection_mode != "none" && tag.value in @selected, do: "true"}
          aria-label={tag.label}
          aria-selected={if @selection_mode != "none", do: to_string(tag.value in @selected)}
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
          <div role="gridcell" style="display:contents">
            <%= if Map.get(tag, :inner_block) do %>
              {render_slot(tag)}
            <% else %>
              {tag.label}
            <% end %>
            <button
              :if={@on_remove}
              type="button"
              class="close-button close-button--default tag__remove-button"
              data-slot="tag-remove-button"
              data-hero-tag-remove
              aria-label={"Remove #{tag.label}"}
              value={tag.value}
              disabled={@disabled || Map.get(tag, :disabled, false)}
              phx-click={@on_remove}
              phx-value-value={tag.value}
              phx-target={@target}
            >
              <svg aria-hidden="true" viewBox="0 0 16 16"><path
                fill="currentColor"
                fill-rule="evenodd"
                clip-rule="evenodd"
                d="M3.47 3.47a.75.75 0 0 1 1.06 0L8 6.94l3.47-3.47a.75.75 0 1 1 1.06 1.06L9.06 8l3.47 3.47a.75.75 0 1 1-1.06 1.06L8 9.06l-3.47 3.47a.75.75 0 0 1-1.06-1.06L6.94 8 3.47 4.53a.75.75 0 0 1 0-1.06Z"
              /></svg>
            </button>
          </div>
        </div>
        <div :if={@tag == []} role="row">
          <div role="gridcell">{render_slot(@empty)}</div>
        </div>
      </div>
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
