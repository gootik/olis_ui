defmodule OlisUI.Feedback do
  @moduledoc "Alerts and badges."
  use Phoenix.Component, global_prefixes: ~w(x-)

  @doc """
  Contextual feedback with a status icon, title, description, and optional actions.
  """
  attr(:title, :string, default: nil)
  attr(:status, :string, default: "default", values: ~w(default accent success warning danger))
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
    status = assigns.status

    data_slot =
      Map.get(assigns.rest, :"data-slot") || Map.get(assigns.rest, "data-slot") || "alert-root"

    rest = Map.drop(assigns.rest, [:"data-slot", "data-slot"])

    assigns =
      assign(assigns,
        status: status,
        data_slot: data_slot,
        rest: rest,
        status_color:
          %{
            "default" => "text-foreground",
            "accent" => "text-accent-soft-foreground",
            "success" => "text-success-soft-foreground",
            "warning" => "text-warning-soft-foreground",
            "danger" => "text-danger-soft-foreground"
          }[status],
        icon_name:
          %{
            "default" => "circle-info",
            "accent" => "circle-info",
            "success" => "circle-check",
            "warning" => "triangle-exclamation",
            "danger" => "circle-exclamation"
          }[status]
      )

    ~H"""
    <div
      role={@role}
      class={[
        "alert olis-alert",
        "alert--#{@status}",
        @class
      ]}
      data-slot={@data_slot}
      {@rest}
    >
      <div
        :if={@show_indicator}
        class={["alert__indicator olis-alert-icon", @status_color]}
        data-slot="alert-indicator"
      >
        <%= if @indicator != [] do %>
          {render_slot(@indicator)}
        <% else %>
          <OlisUI.Icon.icon
            name={@icon_name}
            data-slot="alert-default-icon"
            class="box-content size-4"
          />
        <% end %>
      </div>
      <div class="alert__content flex h-full grow flex-col items-start" data-slot="alert-content">
        <p
          :if={@title || @title_content != []}
          class={["alert__title text-sm leading-6 font-medium", @status_color]}
          data-slot="alert-title"
        >
          <%= if @title_content != [] do %>
            {render_slot(@title_content)}
          <% else %>
            {@title}
          <% end %>
        </p>
        <div
          :if={@inner_block != [] && @description == []}
          class="alert__description text-sm text-muted"
          data-slot="alert-description"
        >
          {render_slot(@inner_block)}
        </div>
        <span
          :for={description <- @description}
          class="alert__description text-sm text-muted"
          data-slot="alert-description"
        >{render_slot(description)}</span>
        {render_slot(@content)}
      </div>
      {render_slot(@actions)}
    </div>
    """
  end

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
    colors = %{
      "default" =>
        {"bg-default text-muted", "text-muted", "bg-default-soft text-default-soft-foreground"},
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
        "primary" -> solid
        "soft" -> soft
        _ -> "bg-default " <> foreground
      end

    assigns = assign(assigns, :palette, palette)

    ~H"""
    <span class={[
      "badge olis-badge",
      @palette,
      @size == "sm" && "min-h-4 min-w-4 px-1 text-[10px] leading-[1.34]",
      @size == "md" && "min-h-5 min-w-5 px-1.5 text-xs leading-[1.34]",
      @size == "lg" && "min-h-6 min-w-6 px-2 text-sm leading-[1.43]",
      @placement == "top-right" && "absolute top-0 right-0 translate-x-1/4 -translate-y-1/4",
      @placement == "top-left" && "absolute top-0 left-0 -translate-x-1/4 -translate-y-1/4",
      @placement == "bottom-right" && "absolute right-0 bottom-0 translate-x-1/4 translate-y-1/4",
      @placement == "bottom-left" && "absolute bottom-0 left-0 -translate-x-1/4 translate-y-1/4",
      "badge--#{@color}",
      "badge--#{@size}",
      "badge--#{@variant}",
      @placement && "badge--#{@placement}",
      @class
    ]}><span class="badge__label px-0">{render_slot(@inner_block)}</span></span>
    """
  end

  @doc "An anchor for a positioned badge."
  attr(:class, :any, default: nil)
  slot(:inner_block, required: true)

  def badge_anchor(assigns) do
    ~H"""
    <span class={["badge-anchor relative inline-flex shrink-0", @class]}>{render_slot(@inner_block)}</span>
    """
  end
end
