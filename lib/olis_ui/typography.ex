defmodule OlisUI.Typography do
  @moduledoc "Text, links, labels, and surfaces."
  use Phoenix.Component, global_prefixes: ~w(x-)
  import OlisUI.Shared

  @doc "A keyboard key or shortcut."
  attr(:class, :any, default: nil)
  slot(:inner_block, required: true)

  def kbd(assigns) do
    ~H"""
    <kbd class={[
      "kbd olis-keycap",
      @class
    ]}>{render_slot(@inner_block)}</kbd>
    """
  end

  @doc "A form label with OlisUI required, disabled, and invalid states."
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
        label_classes(),
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

  @doc "An OlisUI link for ordinary navigation, LiveView navigation, or patches."
  attr(:href, :string, default: nil)
  attr(:navigate, :string, default: nil)
  attr(:patch, :string, default: nil)
  attr(:replace, :boolean, default: false)
  attr(:disabled, :boolean, default: false)
  attr(:class, :any, default: nil)
  attr(:rest, :global, include: ~w(download hreflang media ping referrerpolicy rel target type))
  slot(:inner_block, required: true)

  def ui_link(assigns) do
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
      class={[
        "link olis-link",
        @class
      ]}
      data-slot="link"
      {@rest}
    >{render_slot(@inner_block)}</.link>
    <a
      :if={@disabled}
      role="link"
      aria-disabled="true"
      tabindex="-1"
      class={[
        "link olis-link",
        @class
      ]}
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
      class={[
        "link__icon olis-link-icon",
        @class
      ]}
      data-slot="link-icon"
      data-default-icon={if @inner_block == [], do: "true"}
      aria-hidden="true"
      {@rest}
    >
      <%= if @inner_block == [] do %>
        <OlisUI.Icon.icon
          name="arrow-up-right-from-square"
          data-slot="link-default-icon"
        />
      <% else %>
        {render_slot(@inner_block)}
      <% end %>
    </span>
    """
  end

  @doc "Semantic OlisUI typography with a visual type, color, alignment, and weight."
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
    default_tag = if assigns.type in ~w(body body-sm body-xs), do: "p", else: assigns.type

    assigns =
      assign(assigns,
        tag: assigns.as || default_tag,
        type_style:
          %{
            "h1" => "text-4xl tracking-tight",
            "h2" => "text-3xl tracking-tight",
            "h3" => "text-2xl tracking-tight",
            "h4" => "text-xl tracking-tight",
            "h5" => "text-lg tracking-tight",
            "h6" => "text-base tracking-tight",
            "body" => "text-base leading-7",
            "body-sm" => "text-sm leading-6",
            "body-xs" => "text-xs leading-5",
            "code" => "rounded-md bg-default px-1.5 py-0.5 font-mono text-sm"
          }[assigns.type],
        align_style:
          %{
            "start" => "text-start",
            "center" => "text-center",
            "end" => "text-end",
            "justify" => "text-justify"
          }[assigns.align],
        weight_style:
          %{
            "normal" => "font-normal",
            "medium" => "font-medium",
            "semibold" => "font-[590]",
            "bold" => "font-[590]"
          }[assigns.weight]
      )

    ~H"""
    <.dynamic_tag
      tag_name={@tag}
      class={[
        "typography",
        @type_style,
        @align_style,
        @color == "default" && "text-foreground",
        @color == "muted" && "text-muted",
        @weight_style,
        is_nil(@weight) && @type in ~w(h1 h2 h3 h4 h5 h6) && "font-[510]",
        @truncate && "block truncate",
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

  @doc "Applies OlisUI's prose styles to rich content."
  attr(:class, :any, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def typography_prose(assigns) do
    ~H"""
    <div
      class={[
        "typography-prose text-foreground [&_h1]:text-4xl [&_h1]:font-[510] [&_h1]:tracking-tight [&_h2]:text-3xl [&_h2]:font-[510] [&_h2]:tracking-tight [&_h3]:text-2xl [&_h3]:font-[510] [&_h3]:tracking-tight [&_h4]:text-xl [&_h4]:font-[510] [&_h4]:tracking-tight [&_h5]:text-lg [&_h5]:font-[510] [&_h5]:tracking-tight [&_h6]:text-base [&_h6]:font-[510] [&_h6]:tracking-tight [&_p]:text-base [&_p]:leading-7 [&_code]:rounded-md [&_code]:bg-default [&_code]:px-1.5 [&_code]:py-0.5 [&_code]:font-mono [&_code]:text-sm [&_code]:text-foreground [&_a]:font-medium [&_a]:text-link [&_a]:underline [&_a]:underline-offset-4 [&_blockquote]:mt-4 [&_blockquote]:border-s-4 [&_blockquote]:border-border [&_blockquote]:ps-4 [&_blockquote]:text-muted [&_blockquote]:italic [&_ul]:my-4 [&_ul]:list-disc [&_ul]:space-y-2 [&_ul]:ps-6 [&_ol]:my-4 [&_ol]:list-decimal [&_ol]:space-y-2 [&_ol]:ps-6 [&_li]:text-base [&_li]:leading-7 [&_hr]:my-8 [&_hr]:border-separator [&_pre]:my-4 [&_pre]:overflow-x-auto [&_pre]:rounded-xl [&_pre]:bg-default [&_pre]:p-4 [&_pre]:font-mono [&_pre]:text-sm [&_pre]:leading-relaxed [&_strong]:font-[590] [&_strong]:text-foreground [&_em]:italic [&_img]:my-4 [&_img]:rounded-xl",
        @class
      ]}
      data-slot="prose"
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc "An OlisUI surface; use Tailwind classes to add spacing, borders, or rounding."
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
    <div
      class={[
        "surface surface--#{@variant} relative",
        @variant == "transparent" && "bg-transparent text-foreground",
        @variant == "default" && "bg-surface text-surface-foreground",
        @variant == "secondary" && "bg-surface-secondary text-surface-secondary-foreground",
        @variant == "tertiary" && "bg-surface-tertiary text-surface-tertiary-foreground",
        @class
      ]}
      data-slot={@data_slot}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end
end
