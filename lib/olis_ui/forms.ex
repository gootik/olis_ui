defmodule OlisUI.Forms do
  @moduledoc "Inputs and form fields."
  use Phoenix.Component, global_prefixes: ~w(x-)
  import OlisUI.Shared

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

    invalid = assigns.invalid || assigns.errors != []
    {external_description, rest} = Map.pop(assigns.rest, :"aria-describedby")
    {external_description_string, rest} = Map.pop(rest, "aria-describedby")

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
        "textfield olis-field",
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
      <OlisUI.Controls.textarea
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
        "textfield olis-field",
        @full_width && "textfield--full-width",
        @class
      ]}
      data-invalid={if @invalid, do: "true"}
    >
      <label :if={@label} class={label_classes()} for={@id}>{@label}</label>
      <div
        class={[
          "input-group input-group--#{@variant} olis-field-frame",
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
            "input-group__prefix olis-field-affix",
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
            "input-group__input olis-field-entry",
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
            "input-group__input olis-field-entry",
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
            "input-group__suffix olis-field-affix",
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
        <OlisUI.Icon.icon
          name="magnifier"
          class="search-field__search-icon olis-field-symbol"
          data-slot="search-field-search-icon"
        />
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
        <OlisUI.Button.close_button
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
    length = assigns.length
    groups = assigns.groups || if(length == 6, do: [3, 3], else: [length])

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
          "input-otp input-otp--#{@variant} olis-code-input"
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
            <div class="input-otp__group olis-code-group" data-slot="input-otp-group">
              <div
                :for={slot <- group}
                class={[
                  "input-otp__slot olis-code-cell"
                ]}
                data-slot="input-otp-slot"
                data-olis-otp-index={slot}
              >
                <span
                  class="input-otp__slot-value olis-code-value"
                  data-olis-otp-value
                  hidden
                ></span><span
                  class="input-otp__caret olis-code-caret"
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
            "input-otp__input [[data-olis-otp-ready]_&]:absolute [[data-olis-otp-ready]_&]:inset-0 [[data-olis-otp-ready]_&]:z-1 [[data-olis-otp-ready]_&]:size-full [[data-olis-otp-ready]_&]:cursor-text [[data-olis-otp-ready]_&]:border-0 [[data-olis-otp-ready]_&]:bg-transparent [[data-olis-otp-ready]_&]:p-0 [[data-olis-otp-ready]_&]:text-transparent [[data-olis-otp-ready]_&]:caret-transparent [[data-olis-otp-ready]_&]:shadow-none [[data-olis-otp-ready]_&]:outline-none [[data-olis-otp-ready]_&:focus]:ring-0"
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
end
