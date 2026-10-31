defmodule OlisUI.Disclosure do
  @moduledoc "Disclosures and disclosure groups."
  use Phoenix.Component, global_prefixes: ~w(x-)
  import OlisUI.Shared

  @doc "A disclosure whose open state is managed by LiveView."
  attr(:id, :string, required: true)
  attr(:title, :string, default: nil)
  attr(:open, :boolean, default: false)
  attr(:disabled, :boolean, default: false)
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
    ~H"""
    <details
      id={@id}
      class={[
        "disclosure relative",
        "olis-disclosure",
        "[&[open]_[data-slot=disclosure-indicator]]:-rotate-180",
        "[interpolate-size:allow-keywords]",
        "[&::details-content]:h-0 [&::details-content]:overflow-clip [&::details-content]:opacity-0",
        "[&::details-content]:transition-[height,opacity,content-visibility] [&::details-content]:duration-200 [&::details-content]:[transition-behavior:allow-discrete]",
        "[&[open]::details-content]:h-auto [&[open]::details-content]:opacity-100",
        @class
      ]}
      data-slot="disclosure"
      data-olis-disclosure
      data-disabled={if @disabled, do: "true"}
      data-expanded={if @open, do: "true"}
      open={@open}
      x-data="{}"
      {@rest}
    >
      <summary
        id={"#{@id}-trigger"}
        class={[
          "disclosure__trigger",
          "inline-flex list-none [&::-webkit-details-marker]:hidden",
          button_classes(@variant, "md", @full_width),
          @disabled && "pointer-events-none cursor-not-allowed opacity-50",
          @trigger_class
        ]}
        data-slot="disclosure-trigger"
        data-olis-disclosure-trigger
        role="button"
        aria-controls={"#{@id}-content"}
        aria-expanded={to_string(@open)}
        aria-disabled={if @disabled, do: "true"}
        tabindex={if @disabled, do: "-1"}
        phx-click={if !@disabled, do: @on_toggle}
        phx-value-key={@value || @id}
        phx-value-expanded={to_string(!@open)}
        x-on:click.prevent
      >
        <span class="olis-disclosure-label flex-1 text-start"><%= if @trigger != [] do %>
          {render_slot(@trigger)}
        <% else %>
          {@title}
        <% end %></span>
        <OlisUI.Icon.icon
          name="chevron-down"
          class="disclosure__indicator olis-disclosure-chevron"
          data-slot="disclosure-indicator"
          data-expanded={if @open, do: "true"}
        />
      </summary>
      <div
        id={"#{@id}-content"}
        class={[
          "disclosure__content overflow-clip",
          @content_class
        ]}
        data-slot="disclosure-content"
        data-olis-disclosure-content
        data-expanded={if @open, do: "true"}
        role="group"
        aria-labelledby={"#{@id}-trigger"}
      >
        <div class="disclosure__body p-2" data-slot="disclosure-body">
          <div class="disclosure__body-inner">{render_slot(@inner_block)}</div>
        </div>
      </div>
    </details>
    """
  end

  @doc "A group of disclosures with single or multiple expanded items."
  attr(:id, :string, required: true)
  attr(:expanded_keys, :list, default: [])
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
    assigns = assign(assigns, :expanded, MapSet.new(assigns.expanded_keys))

    ~H"""
    <div
      id={@id}
      class={["disclosure-group w-full [contain:layout_style]", @class]}
      data-slot="disclosure-group"
      data-olis-disclosure-group
      {@rest}
    >
      <.disclosure
        :for={item <- @item}
        id={"#{@id}-#{Base.url_encode64(item.key, padding: false)}"}
        title={item.title}
        value={item.key}
        open={MapSet.member?(@expanded, item.key)}
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
end
