defmodule OlisUI.Button do
  @moduledoc "Buttons and close controls."
  use Phoenix.Component, global_prefixes: ~w(x-)
  import OlisUI.Shared

  @doc "A native button with OlisUI variants and an optional focusable pending state."
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
        button_classes(@variant, @size, @full_width, @icon_only),
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

    assigns =
      assign(assigns, label: label, data_slot: data_slot, rest: rest)

    ~H"""
    <button
      type={@type}
      disabled={@disabled}
      aria-label={@label}
      class={[close_button_classes(), @class]}
      data-slot={@data_slot}
      {@rest}
    >
      <%= if @inner_block == [] do %>
        <OlisUI.Icon.icon name="xmark" data-slot="close-button-icon" class="size-4" />
      <% else %>
        {render_slot(@inner_block)}
      <% end %>
    </button>
    """
  end
end
