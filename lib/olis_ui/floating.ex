defmodule OlisUI.Floating do
  @moduledoc "Alert dialogs, drawers, tooltips, and popovers."
  use Phoenix.Component, global_prefixes: ~w(x-)
  import OlisUI.Shared

  @doc """
  An alert dialog for decisions that require an explicit response.
  Open it with `data-olis-dialog-open` and install the OlisUI Alpine providers.
  Manage `open` with `on_open_change`. The cancel action receives initial focus;
  confirmation sends `on_confirm` to LiveView.
  """
  attr(:id, :string, required: true)
  attr(:title, :string, required: true)
  attr(:on_confirm, :any, required: true)
  attr(:open, :boolean, default: false)
  attr(:on_open_change, :any, default: nil)
  attr(:target, :any, default: nil)
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
      class={[
        "alert-dialog__dialog alert-dialog__dialog--#{@size} olis-native-modal fixed inset-0 m-auto flex min-h-0 max-h-[calc(100dvh-2rem)] w-[calc(100%-2rem)] flex-col overflow-auto rounded-[12px] border-0 bg-overlay p-6 text-foreground shadow-overlay outline-none pointer-events-auto backdrop:bg-backdrop [&:not([open])]:hidden",
        @size == "xs" && "max-w-xs",
        @size == "sm" && "max-w-sm",
        @size == "md" && "max-w-md",
        @size == "lg" && "max-w-lg",
        @class
      ]}
      data-olis-dialog
      data-olis-modal
      data-open={to_string(@open)}
      data-keyboard-dismiss-disabled="true"
      x-data="olisDialog"
      x-on:click.window="openFromTrigger($event)"
      x-on:click="onClick($event)"
      x-on:cancel="onCancel($event)"
      x-on:close="onNativeClose($event)"
      x-on:phx:update.window="sync()"
      data-dismissible="false"
      phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["open"])}
    >
      <header class="alert-dialog__header mb-0 flex flex-col gap-3 [&>.modal__icon]:mb-0">
        <h2
          id={"#{@id}-title"}
          class="alert-dialog__heading align-middle text-base font-medium text-foreground"
        >
          {@title}
        </h2>
      </header>
      <div
        id={"#{@id}-description"}
        class="alert-dialog__body olis-dialog-body scrollbar"
      >
        {render_slot(@inner_block)}
      </div>
      <div class="alert-dialog__footer mt-5 flex flex-row items-center justify-end gap-2">
        <button
          type="button"
          class={button_classes("tertiary", "md")}
          data-olis-dialog-close
          autofocus
        >{@cancel_label}</button>
        <button
          type="button"
          class={button_classes(@confirm_variant, "md")}
          phx-click={@on_confirm}
          data-olis-dialog-close
        >{@confirm_label}</button>
      </div>
      <button
        :if={@on_open_change}
        type="button"
        hidden
        data-olis-modal-event
        phx-value-id={@id}
        phx-click={@on_open_change}
        phx-target={@target}
      ></button>
    </dialog>
    """
  end

  @doc """
  A modal drawer attached to an edge of the viewport.
  Open it with `data-olis-dialog-open={id}`. Requires OlisUI's Alpine providers.
  The backdrop can be `opaque` (default), `blur`, or `transparent`.
  Use `open` and `on_open_change` for LiveView-controlled state. A `:close` slot can replace the default control.
  """
  attr(:id, :string, required: true)
  attr(:title, :string, required: true)
  attr(:placement, :string, default: "bottom", values: ~w(top bottom left right))
  attr(:dismissible, :boolean, default: true)
  attr(:backdrop, :string, default: "opaque", values: ~w(opaque blur transparent))
  attr(:open, :boolean, default: false)
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
    ~H"""
    <dialog
      id={@id}
      aria-labelledby={"#{@id}-title"}
      class={[
        "drawer__dialog fixed m-0 flex max-h-dvh flex-col overflow-auto border-0 bg-overlay p-6 text-foreground shadow-overlay outline-none pointer-events-auto will-change-[translate] [&:not([open])]:hidden",
        @placement == "bottom" &&
          "inset-x-0 bottom-0 top-auto w-full max-h-[85dvh] [border-start-start-radius:12px] [border-start-end-radius:12px]",
        @placement == "top" &&
          "inset-x-0 top-0 bottom-auto w-full max-h-[85dvh] [border-end-start-radius:12px] [border-end-end-radius:12px]",
        @placement == "left" &&
          "inset-y-0 left-0 right-auto h-dvh w-[min(24rem,85vw)] rounded-none max-sm:w-[min(20rem,85vw)]",
        @placement == "right" &&
          "inset-y-0 right-0 left-auto h-dvh w-[min(24rem,85vw)] rounded-none max-sm:w-[min(20rem,85vw)]",
        "olis-native-modal",
        "olis-native-drawer",
        @backdrop == "opaque" && "backdrop:bg-backdrop",
        @backdrop == "blur" && "backdrop:bg-backdrop backdrop:backdrop-blur-md",
        @backdrop == "transparent" && "backdrop:bg-transparent",
        @class
      ]}
      data-placement={@placement}
      data-backdrop={@backdrop}
      data-olis-drawer
      data-slot="drawer-dialog"
      x-data="olisDrawer"
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
      data-open={to_string(@open)}
      phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["open", "style"])}
    >
      <div
        :if={@show_handle}
        class={[
          "drawer__handle olis-drawer-grip",
          if(@placement in ["top", "bottom"], do: "touch-pan-x", else: "touch-pan-y")
        ]}
        data-slot="drawer-handle"
        data-olis-drawer-drag
        aria-hidden="true"
      >
        <span data-slot="drawer-handle-bar"></span>
      </div>
      <header
        class={[
          "drawer__header mb-0 flex flex-col gap-3",
          if(@placement in ["top", "bottom"], do: "touch-pan-x", else: "touch-pan-y")
        ]}
        data-slot="drawer-header"
        data-olis-drawer-drag
      >
        <h2
          id={"#{@id}-title"}
          class="drawer__heading align-middle text-base font-medium text-foreground"
          data-slot="drawer-heading"
        >
          {@title}
        </h2>
      </header>
      <div
        class="drawer__body olis-dialog-body scrollbar"
        data-slot="drawer-body"
      >
        {render_slot(@inner_block)}
      </div>
      <div
        class={[
          "drawer__footer mt-5 flex flex-row items-center justify-end gap-2",
          if(@placement in ["top", "bottom"], do: "touch-pan-x", else: "touch-pan-y")
        ]}
        data-slot="drawer-footer"
        data-olis-drawer-drag
      >
        {render_slot(@footer)}
        <%= if @close != [] do %>
          {render_slot(@close, %{"data-olis-dialog-close" => true})}
        <% else %>
          <button
            :if={@show_close}
            type="button"
            class={button_classes("tertiary", "md")}
            data-olis-dialog-close
          >{@close_label}</button>
        <% end %>
      </div>
      <button
        :if={@on_open_change}
        type="button"
        hidden
        data-olis-drawer-event
        phx-value-id={@id}
        phx-click={@on_open_change}
        phx-target={@target}
      ></button>
    </dialog>
    """
  end

  @doc """
  A noninteractive description shown on focus or hover. Requires OlisUI's Alpine providers.
  The default slot labels a built-in button. Use `:trigger` to provide an existing
  interactive element and `:content` for rich, noninteractive inline content.
  """
  attr(:id, :string, required: true)
  attr(:open, :boolean, default: false)
  attr(:on_open_change, :string, default: nil)
  attr(:target, :any, default: nil)
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
    assigns =
      assign(assigns, :resolved_offset, assigns.offset || if(assigns.show_arrow, do: 7, else: 3))

    ~H"""
    <span
      class={["olis-tooltip-root inline-block", @class]}
      data-olis-tooltip-root
      data-open={to_string(@open)}
      data-delay={@delay}
      data-close-delay={@close_delay}
      data-requested-placement={@placement}
      data-offset={@resolved_offset}
      x-data="olisTooltip"
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
        class={[
          button_classes("tertiary", "md"),
          "tooltip__trigger olis-overlay-trigger",
          @trigger_class
        ]}
        aria-describedby={"#{@id}-content"}
        data-olis-tooltip-trigger
        x-ref="trigger"
      >{render_slot(@inner_block)}</button>
      <span
        :if={@trigger != []}
        class={["inline-flex", @trigger_class]}
        data-olis-tooltip-trigger
        data-slot="tooltip-trigger"
        x-ref="trigger"
      >{render_slot(@trigger, %{"aria-describedby" => "#{@id}-content"})}</span>
      <span
        id={"#{@id}-content"}
        role="tooltip"
        popover="manual"
        class={[
          "tooltip olis-tooltip group/tooltip olis-tooltip-bubble",
          overlay_motion_classes()
        ]}
        data-olis-tooltip
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
        class="pointer-events-none absolute size-3 fill-overlay stroke-border/40 group-data-[placement=bottom]/tooltip:rotate-180 group-data-[placement=left]/tooltip:-rotate-90 group-data-[placement=right]/tooltip:rotate-90 group-data-[placement=top]/tooltip:-bottom-3 group-data-[placement=top]/tooltip:left-1/2 group-data-[placement=top]/tooltip:-translate-x-1/2 group-data-[placement=bottom]/tooltip:-top-3 group-data-[placement=bottom]/tooltip:left-1/2 group-data-[placement=bottom]/tooltip:-translate-x-1/2 group-data-[placement=left]/tooltip:-right-3 group-data-[placement=left]/tooltip:top-1/2 group-data-[placement=left]/tooltip:-translate-y-1/2 group-data-[placement=right]/tooltip:-left-3 group-data-[placement=right]/tooltip:top-1/2 group-data-[placement=right]/tooltip:-translate-y-1/2"
      ><polygon points="1,0 11,0 6,6" /></svg>
      <%= if @content != [] do %>
        {render_slot(@content)}
      <% else %>
        {@text}
      <% end %></span>
      <button
        :if={@on_open_change}
        type="button"
        hidden
        data-olis-tooltip-event
        phx-value-id={@id}
        phx-click={@on_open_change}
        phx-target={@target}
      ></button>
    </span>
    """
  end

  @doc """
  A nonmodal, interactive popover anchored to a button. Requires OlisUI's Alpine components.

  Use `trigger` for a simple button or the `:trigger_content` slot for a custom
  trigger; apply the yielded attributes to its interactive element. `open` and
  `on_open_change` enable LiveView-controlled state.
  """
  attr(:id, :string, required: true)
  attr(:trigger, :string, default: nil)
  attr(:title, :string, required: true)

  attr(:placement, :string,
    default: "bottom",
    values: [
      "top",
      "bottom",
      "left",
      "right",
      "top start",
      "top end",
      "bottom start",
      "bottom end",
      "left start",
      "left end",
      "right start",
      "right end"
    ]
  )

  attr(:offset, :integer, default: 8)
  attr(:should_flip, :boolean, default: true)
  attr(:show_arrow, :boolean, default: false)
  attr(:open, :boolean, default: false)
  attr(:on_open_change, :any, default: nil)
  attr(:target, :any, default: nil)
  attr(:show_close, :boolean, default: true)
  attr(:close_label, :string, default: "Close")
  attr(:class, :any, default: nil)
  attr(:content_class, :any, default: nil)
  slot(:inner_block, required: true)
  slot(:trigger_content)

  def popover(assigns) do
    ~H"""
    <div
      class={["olis-popover-root inline-block", @class]}
      data-open={to_string(@open)}
      data-requested-placement={@placement}
      data-offset={@offset}
      data-should-flip={to_string(@should_flip)}
      x-data="olisPopover"
      x-on:click="onClick($event)"
      x-on:resize.window="position()"
      x-on:scroll.window.capture="position()"
      x-on:phx:update.document="sync()"
    >
      <button
        :if={@trigger_content == []}
        type="button"
        class={[
          button_classes("secondary", "md"),
          "popover__trigger olis-overlay-trigger"
        ]}
        x-ref="trigger"
        data-olis-popover-trigger
        popovertarget={"#{@id}-content"}
        aria-controls={"#{@id}-content"}
        aria-expanded="false"
        aria-haspopup="dialog"
        phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["aria-expanded"])}
      >{@trigger}</button>
      <span :if={@trigger_content != []} class="inline-flex" x-ref="trigger">
        {render_slot(@trigger_content, %{
          "data-olis-popover-trigger" => true,
          "popovertarget" => "#{@id}-content",
          "aria-controls" => "#{@id}-content",
          "aria-expanded" => "false",
          "aria-haspopup" => "dialog",
          "phx-mounted" => Phoenix.LiveView.JS.ignore_attributes(["aria-expanded"])
        })}
      </span>
      <div
        id={"#{@id}-content"}
        popover="auto"
        class={[
          "popover rounded-[12px] bg-overlay p-0 text-sm",
          overlay_motion_classes(),
          "olis-popover fixed inset-auto m-0 max-h-[calc(100dvh-1rem)] max-w-[min(20rem,calc(100vw-1rem))] overflow-visible border-0 text-overlay-foreground",
          "group/popover",
          "transition-[display,overlay] duration-100 [transition-behavior:allow-discrete]",
          @content_class
        ]}
        data-olis-popover
        x-ref="content"
        x-on:beforetoggle="beforeToggle($event)"
        x-on:toggle="toggle($event)"
        x-on:animationend="animationEnd($event)"
        data-placement={@placement |> String.split() |> hd()}
        phx-mounted={
          Phoenix.LiveView.JS.ignore_attributes([
            "style",
            "data-placement",
            "data-entering",
            "data-exiting"
          ])
        }
      >
        <svg
          :if={@show_arrow}
          data-slot="popover-overlay-arrow"
          aria-hidden="true"
          viewBox="0 0 12 12"
          width="12"
          height="12"
          class="pointer-events-none absolute size-3 fill-overlay group-data-[placement=bottom]/popover:rotate-180 group-data-[placement=left]/popover:-rotate-90 group-data-[placement=right]/popover:rotate-90 group-data-[placement=top]/popover:-bottom-3 group-data-[placement=top]/popover:left-1/2 group-data-[placement=top]/popover:-translate-x-1/2 group-data-[placement=bottom]/popover:-top-3 group-data-[placement=bottom]/popover:left-1/2 group-data-[placement=bottom]/popover:-translate-x-1/2 group-data-[placement=left]/popover:-right-3 group-data-[placement=left]/popover:top-1/2 group-data-[placement=left]/popover:-translate-y-1/2 group-data-[placement=right]/popover:-left-3 group-data-[placement=right]/popover:top-1/2 group-data-[placement=right]/popover:-translate-y-1/2"
        ><polygon points="1,0 11,0 6,6" /></svg>
        <section
          role="dialog"
          aria-labelledby={"#{@id}-title"}
          tabindex="-1"
          class="popover__dialog max-h-[calc(100dvh-1rem)] overflow-y-auto p-4 outline-none"
          data-slot="popover-dialog"
          x-ref="dialog"
        >
          <h2 id={"#{@id}-title"} class="popover__heading font-medium" data-slot="popover-heading">
            {@title}
          </h2>
          <div class="mt-2">{render_slot(@inner_block)}</div>
          <button
            :if={@show_close}
            type="button"
            class={[button_classes("tertiary", "sm"), "mt-4"]}
            data-olis-popover-close
          >{@close_label}</button>
        </section>
      </div>
      <button
        :if={@on_open_change}
        type="button"
        hidden
        data-olis-popover-event
        phx-value-id={@id}
        phx-click={@on_open_change}
        phx-target={@target}
      ></button>
    </div>
    """
  end
end
