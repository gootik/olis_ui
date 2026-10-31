defmodule OlisUI.Color do
  @moduledoc "Color fields, swatches, and palettes."
  use Phoenix.Component, global_prefixes: ~w(x-)
  import OlisUI.Shared

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
        "color-field olis-field",
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
        class={"color-input-group color-input-group--#{@variant} olis-field-frame"}
        role="presentation"
        data-slot="color-input-group"
        data-invalid={if @errors != [], do: "true"}
        data-disabled={if @disabled, do: "true"}
      >
        <div
          :if={@prefix != [] || @show_swatch}
          class="color-input-group__prefix olis-field-affix [&_[data-olis-color-swatch]]:cursor-pointer"
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
          class="color-input-group__input olis-field-entry"
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
    name = assigns.name || (field && field.name) || id
    value = if is_nil(assigns.value) && field, do: field.value, else: assigns.value

    options =
      Enum.map(assigns.option, fn option ->
        color = safe_swatch_color(option.value)
        option |> Map.put(:value, color) |> Map.put(:light, light_swatch_color?(color))
      end)

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
            "color-swatch-picker__item olis-swatch-picker__option olis-swatch-choice",
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
              "color-swatch-picker__swatch olis-swatch-fill",
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
            class="color-swatch-picker__indicator olis-swatch-mark"
            data-slot="color-swatch-picker-indicator"
            aria-hidden="true"
            data-light-color={if option.light, do: "true"}
          >
            <OlisUI.Icon.icon
              name="check"
              data-slot="color-swatch-picker-checkmark"
              class="size-1/3 text-white"
            />
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
end
