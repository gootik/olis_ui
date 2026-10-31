defmodule OlisUI.Display do
  @moduledoc "Cards, chips, loading indicators, and other display components."
  use Phoenix.Component, global_prefixes: ~w(x-)

  @doc "An OlisUI-styled section header. Use `as` to select an appropriate semantic tag."
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
    <.dynamic_tag
      tag_name={@as}
      class={["header w-full px-2 pt-1.5 pb-1 text-start text-xs font-medium text-muted", @class]}
      data-slot={@data_slot}
      {@rest}
    >
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
    <.dynamic_tag
      tag_name={@as}
      class={["empty-state p-2 text-sm text-muted", @class]}
      data-slot={@data_slot}
      {@rest}
    >
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
  Unslotted content is rendered directly inside the card.
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
    <div
      class={[
        "card card--#{@variant} olis-card",
        @variant == "transparent" && "border-none bg-transparent shadow-none",
        @variant == "default" && "bg-surface",
        @variant == "secondary" && "bg-surface-secondary",
        @variant == "tertiary" && "bg-surface-tertiary",
        @class
      ]}
      data-slot={@data_slot}
      {@rest}
    >
      <div
        :if={@header != [] || @title != [] || @description != []}
        class={["card__header flex flex-col", @header_class]}
        data-slot="card-header"
      >
        {render_slot(@header)}
        <.dynamic_tag
          :for={title <- @title}
          tag_name={"h#{@heading_level}"}
          id={title[:id]}
          class={["card__title text-sm leading-6 font-medium text-foreground", title[:class]]}
          data-slot="card-title"
        >
          {render_slot(title)}
        </.dynamic_tag>
        <p
          :for={description <- @description}
          id={description[:id]}
          class={["card__description text-sm leading-5 text-muted", description[:class]]}
          data-slot="card-description"
        >
          {render_slot(description)}
        </p>
      </div>
      {render_slot(@inner_block)}
      <div
        :for={content <- @content}
        id={content[:id]}
        class={["card__content flex flex-1 flex-col gap-1", content[:class]]}
        data-slot="card-content"
      >
        {render_slot(content)}
      </div>
      <div
        :for={footer <- @footer}
        id={footer[:id]}
        class={["card__footer flex flex-row items-center", footer[:class]]}
        data-slot="card-footer"
      >
        {render_slot(footer)}
      </div>
    </div>
    """
  end

  @doc "A compact label with OlisUI color, variant, and size options."
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

    colors = %{
      "default" =>
        {"bg-default", "text-default-foreground", "bg-default-soft text-default-soft-foreground"},
      "accent" =>
        {"bg-accent text-accent-foreground", "text-accent-soft-foreground",
         "bg-accent-soft text-accent-soft-foreground"},
      "success" =>
        {"bg-success text-success-foreground", "text-success-soft-foreground",
         "bg-success-soft text-success-soft-foreground"},
      "warning" =>
        {"bg-warning text-warning-foreground", "text-warning-soft-foreground",
         "bg-warning-soft text-warning-soft-foreground"},
      "danger" =>
        {"bg-danger text-danger-foreground", "text-danger-soft-foreground",
         "bg-danger-soft text-danger-soft-foreground"}
    }

    {solid, foreground, soft} = colors[assigns.color]

    palette =
      case assigns.variant do
        "primary" -> if assigns.color == "default", do: "bg-default " <> foreground, else: solid
        "soft" -> soft
        "tertiary" -> "bg-transparent " <> foreground
        _ -> "bg-default " <> foreground
      end

    assigns =
      assign(assigns,
        data_slot: data_slot,
        palette: palette,
        rest: Map.drop(assigns.rest, [:"data-slot", "data-slot"])
      )

    ~H"""
    <span
      class={[
        "chip chip--#{@variant} chip--#{@color} chip--#{@size} olis-chip",
        @palette,
        @size == "sm" && "px-1 py-0 text-xs",
        @size == "md" && "px-3 py-1 text-xs",
        @size == "lg" && "px-3 py-1 text-sm",
        @class
      ]}
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
    <span class={["chip__label px-0.5", @class]} data-slot={@data_slot} {@rest}>{render_slot(
      @inner_block
    )}</span>
    """
  end

  @doc "An accessible OlisUI loading indicator."
  attr(:id, :string, default: nil)
  attr(:size, :string, default: "md", values: ~w(sm md lg xl))
  attr(:color, :string, default: "accent", values: ~w(current accent danger success warning))
  attr(:label, :string, default: "Loading")
  attr(:decorative, :boolean, default: false)
  attr(:class, :any, default: nil)
  attr(:rest, :global)

  def spinner(assigns) do
    ~H"""
    <span
      id={@id}
      class={[
        "spinner spinner--#{@size} spinner--#{@color} olis-spinner",
        @size == "sm" && "size-4",
        @size == "md" && "size-6",
        @size == "lg" && "size-8",
        @size == "xl" && "size-10",
        @color == "current" && "text-inherit",
        @color == "accent" && "text-accent",
        @color == "danger" && "text-danger",
        @color == "success" && "text-success",
        @color == "warning" && "text-warning",
        @class
      ]}
      role={if !@decorative, do: "status"}
      aria-label={if !@decorative, do: @label}
      aria-hidden={if @decorative, do: "true"}
      data-slot="spinner"
      {@rest}
    >
      <svg class="size-full" data-slot="spinner-icon" viewBox="0 0 24 24" aria-hidden="true">
        <circle
          cx="12"
          cy="12"
          r="9"
          fill="none"
          stroke="currentColor"
          stroke-width="2.5"
          opacity="0.22"
        />
        <circle
          cx="12"
          cy="12"
          r="9"
          fill="none"
          stroke="currentColor"
          stroke-width="2.5"
          stroke-linecap="round"
          stroke-dasharray="26 74"
          pathLength="100"
        />
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
      class={[
        "separator separator--#{@orientation} separator--default shrink-0 bg-separator",
        @orientation == "horizontal" &&
          "h-px w-full [.toolbar_&]:w-1/2 [.toolbar_&]:justify-center [.toolbar_&]:justify-self-center",
        @orientation == "vertical" &&
          "h-auto min-h-2 w-px self-stretch [.toolbar_&]:h-1/2 [.toolbar_&]:self-center",
        @class
      ]}
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
      class={[
        "skeleton skeleton--#{@animation_type || "shimmer"} olis-skeleton",
        @class
      ]}
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
end
