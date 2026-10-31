defmodule OlisUI.Controls do
  @moduledoc "Avatars, scroll shadows, textareas, and radio controls."
  use Phoenix.Component, global_prefixes: ~w(x-)
  import OlisUI.Shared

  defp textarea_classes(variant), do: "textarea textarea--#{variant} olis-field-frame"

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
        "scroll-shadow relative scroll-shadow--#{@orientation} scroll-shadow--fade",
        @orientation == "vertical" && "overflow-y-auto",
        @orientation == "horizontal" && "overflow-x-auto",
        @hide_scrollbar && "scroll-shadow--hide-scrollbar scrollbar-none",
        !@hide_scrollbar && "scrollbar",
        @class
      ]}
      data-slot="scroll-shadow"
      data-olis-scroll-shadow
      x-data="olisScrollShadow"
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
        data-olis-scroll-shadow-event
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

    palette =
      %{
        "default" => {"text-default-soft-foreground", "bg-default-soft"},
        "accent" => {"text-accent-soft-foreground", "bg-accent-soft"},
        "success" => {"text-success-soft-foreground", "bg-success-soft"},
        "warning" => {"text-warning-soft-foreground", "bg-warning-soft"},
        "danger" => {"text-danger-soft-foreground", "bg-danger-soft"}
      }[assigns.color]

    assigns = assign(assigns, initials: assigns.fallback || initials, palette: palette)

    ~H"""
    <span
      class={[
        "avatar avatar--#{@size} olis-avatar",
        @size == "sm" && "size-8 [--avatar-size:2rem] [--avatar-radius:calc(var(--radius)*2)]",
        @size == "md" && "size-10 [--avatar-size:2.5rem] [--avatar-radius:calc(var(--radius)*3)]",
        @size == "lg" && "size-12 [--avatar-size:3rem] [--avatar-radius:calc(var(--radius)*3)]",
        @variant == "soft" && "avatar--soft bg-transparent",
        @variant != "soft" && "bg-default",
        @class
      ]}
      role="img"
      aria-label={@name}
    >
      <span
        class={[
          "avatar__fallback avatar__fallback--#{@color}",
          elem(@palette, 0),
          @variant == "soft" && elem(@palette, 1),
          @variant != "soft" && "bg-default",
          @size == "sm" && "text-xs",
          @size == "md" && "text-sm",
          @size == "lg" && "text-base"
        ]}
        aria-hidden="true"
      >{@initials}</span>
      <img
        :if={@src}
        src={@src}
        alt=""
        aria-hidden="true"
        class="avatar__image olis-avatar-image"
        data-olis-avatar-image
        x-data="olisAvatarImage"
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
    {visible, hidden} = Enum.split(assigns.avatar, assigns.max || length(assigns.avatar))
    count = List.first(assigns.count)
    count_size = (count && Map.get(count, :size)) || assigns.size
    count_color = (count && Map.get(count, :color)) || assigns.color
    count_variant = (count && Map.get(count, :variant)) || assigns.variant

    count_palette =
      %{
        "default" => {"text-default-soft-foreground", "bg-default-soft"},
        "accent" => {"text-accent-soft-foreground", "bg-accent-soft"},
        "success" => {"text-success-soft-foreground", "bg-success-soft"},
        "warning" => {"text-warning-soft-foreground", "bg-warning-soft"},
        "danger" => {"text-danger-soft-foreground", "bg-danger-soft"}
      }[count_color]

    assigns =
      assigns
      |> assign(:visible, visible)
      |> assign(:hidden_count, length(hidden))
      |> assign(:count_slot, count)
      |> assign(:count_size, count_size)
      |> assign(:count_variant, count_variant)
      |> assign(:count_color, count_color)
      |> assign(:count_palette, count_palette)

    ~H"""
    <div
      class={[
        "avatar-group inline-flex items-center [--avatar-group-overlap:0.5rem] [--avatar-group-seam:2px]",
        @grid && "avatar-group--grid flex-wrap gap-3",
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
          "avatar avatar-group__count avatar--#{@count_size} olis-avatar",
          @count_size == "sm" && "size-8 [--avatar-size:2rem] [--avatar-radius:calc(var(--radius)*2)]",
          @count_size == "md" &&
            "size-10 [--avatar-size:2.5rem] [--avatar-radius:calc(var(--radius)*3)]",
          @count_size == "lg" &&
            "size-12 [--avatar-size:3rem] [--avatar-radius:calc(var(--radius)*3)]",
          @count_variant == "soft" && "avatar--soft bg-transparent",
          @count_variant != "soft" && "bg-default",
          @count_slot && Map.get(@count_slot, :class)
        ]}
        role="img"
        aria-label={if @count_slot, do: @count_slot.label, else: "#{@hidden_count} more"}
        data-slot="avatar-group-count"
      >
        <span
          class={[
            "avatar__fallback avatar__fallback--#{@count_color}",
            elem(@count_palette, 0),
            @count_variant == "soft" && elem(@count_palette, 1),
            @count_variant != "soft" && "bg-default",
            @count_size == "sm" && "text-xs",
            @count_size == "md" && "text-sm",
            @count_size == "lg" && "text-base"
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
      class={[textarea_classes(@variant), @class]}
      {@rest}
    >{@value}</textarea>
    """
  end

  defp radio_root_classes, do: "radio olis-native-radio olis-choice"
  defp radio_control_classes, do: "radio__control olis-choice-box"
  defp radio_indicator_classes, do: "radio__indicator olis-choice-mark"

  @doc "A native radio input with OlisUI styling. Radios sharing a name form a group."
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
      class={[radio_root_classes(), @class]}
      for={@id}
      data-slot="radio"
      data-disabled={if @disabled, do: "true"}
      data-invalid={if @invalid, do: "true"}
    >
      <span
        class="radio__content olis-choice-body"
        data-slot="radio-content"
      >
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
          class="olis-visually-hidden-input absolute [inset-block-start:0] start-0 z-[2] m-0 size-4 cursor-inherit opacity-0"
          {@rest}
        />
        <span class={radio_control_classes()} aria-hidden="true"><span class={
          radio_indicator_classes()
        }></span></span>
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
      <legend class={label_classes()}>{@label}</legend>
      <div
        class={[
          "radio-group radio-group--#{@variant} flex",
          @orientation == "vertical" && "flex-col [&_[data-slot=radio]]:mt-4",
          @orientation == "horizontal" && "flex-row flex-wrap gap-4"
        ]}
        data-orientation={@orientation}
      >
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
end
