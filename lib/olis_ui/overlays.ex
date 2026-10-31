defmodule OlisUI.Overlays do
  @moduledoc "Modal dialogs and sheets."
  use Phoenix.Component, global_prefixes: ~w(x-)
  import OlisUI.Shared

  @doc """
  A modal dialog using the browser's focus containment and Escape behavior.

  Install the OlisUI Alpine providers as described in the README. Open it with a button carrying
  `data-olis-dialog-open={id}`, or pass a trigger slot receiving that attribute. Use `open` and
  `on_open_change` to manage open state in LiveView.
  """
  attr(:id, :string, required: true)
  attr(:title, :string, required: true)
  attr(:size, :string, default: "md", values: ~w(xs sm md lg cover full))
  attr(:placement, :string, default: "auto", values: ~w(auto top center bottom))
  attr(:scroll, :string, default: "inside", values: ~w(inside outside))
  attr(:backdrop, :string, default: "opaque", values: ~w(opaque blur transparent))
  attr(:dismissible, :boolean, default: true)
  attr(:keyboard_dismiss_disabled, :boolean, default: false)
  attr(:description, :string, default: nil)
  attr(:open, :boolean, default: false)
  attr(:on_open_change, :any, default: nil)
  attr(:target, :any, default: nil)
  attr(:show_close, :boolean, default: true)
  attr(:close_label, :string, default: "Close")
  attr(:class, :any, default: nil)
  attr(:body_class, :any, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)
  slot(:footer)
  slot(:trigger)
  slot(:close)

  def modal(assigns) do
    ~H"""
    {render_slot(@trigger, %{"data-olis-dialog-open" => @id})}
    <dialog
      id={@id}
      class={[
        "modal__dialog flex flex-col bg-overlay p-6 outline-none pointer-events-auto [&:not([open])]:hidden",
        @size != "full" && "rounded-[12px] shadow-overlay",
        @size == "xs" && "max-w-xs",
        @size == "sm" && "max-w-sm",
        @size == "md" && "max-w-md",
        @size == "lg" && "max-w-lg",
        @size in ["cover", "full"] && "min-h-full",
        @scroll == "inside" && "min-h-0 overflow-clip",
        @scroll == "outside" && "min-h-0 shrink-0",
        "modal__dialog--#{@size}",
        "modal__dialog--scroll-#{@scroll}",
        "olis-native-modal",
        "olis-olis-modal",
        "fixed inset-0 m-auto w-[calc(100%-2rem)] max-h-[calc(100dvh-2rem)] border-0 text-foreground sm:max-h-[calc(100dvh-5rem)]",
        @scroll == "outside" && "overflow-y-auto",
        @size == "cover" &&
          "h-[calc(100dvh-2rem)] max-w-none sm:h-[calc(100dvh-5rem)] sm:w-[calc(100%-5rem)]",
        @size == "full" && "h-dvh max-h-none w-full max-w-none rounded-none shadow-none sm:max-h-none",
        @size != "full" && @placement == "auto" && "mb-4 sm:my-auto",
        @size != "full" && @placement == "top" && "mt-4 sm:mt-10",
        @size != "full" && @placement == "bottom" && "mb-4 sm:mb-10",
        @backdrop == "opaque" && "backdrop:bg-backdrop",
        @backdrop == "blur" && "backdrop:bg-backdrop backdrop:backdrop-blur-md",
        @backdrop == "transparent" && "backdrop:bg-transparent",
        @class
      ]}
      data-olis-dialog
      data-olis-modal
      data-slot="modal-dialog"
      data-placement={@placement}
      data-backdrop={@backdrop}
      data-scroll={@scroll}
      x-data="olisDialog"
      x-on:click.window="openFromTrigger($event)"
      x-on:click="onClick($event)"
      x-on:cancel="onCancel($event)"
      x-on:close="onNativeClose($event)"
      x-on:phx:update.window="sync()"
      phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["open"])}
      data-dismissible={to_string(@dismissible)}
      data-keyboard-dismiss-disabled={to_string(@keyboard_dismiss_disabled)}
      data-open={to_string(@open)}
      aria-labelledby={"#{@id}-title"}
      aria-describedby={if @description, do: "#{@id}-description"}
      {@rest}
    >
      <header
        class="modal__header mb-0 flex flex-col gap-3 [&>.modal__icon]:mb-0"
        data-slot="modal-header"
      >
        <h2
          class="modal__heading align-middle text-base font-medium text-foreground"
          id={"#{@id}-title"}
          data-slot="modal-heading"
        >
          {@title}
        </h2>
      </header>
      <div
        class={[
          "modal__body modal__body--scroll-#{@scroll} olis-dialog-body",
          @scroll == "inside" &&
            "scrollbar overflow-y-auto overscroll-contain [-webkit-overflow-scrolling:touch]",
          @scroll == "outside" && "overflow-y-visible",
          @body_class
        ]}
        data-slot="modal-body"
      >
        <p :if={@description} id={"#{@id}-description"}>{@description}</p>
        {render_slot(@inner_block)}
      </div>
      <div
        class="modal__footer mt-5 flex flex-row items-center justify-end gap-2"
        data-slot="modal-footer"
      >
        {render_slot(@footer)}
        <%= if @close != [] do %>
          {render_slot(@close, %{"data-olis-dialog-close" => true})}
        <% else %>
          <button
            :if={@show_close}
            class={button_classes("tertiary", "md")}
            type="button"
            data-olis-dialog-close
          >{@close_label}</button>
        <% end %>
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
  A swipeable modal sheet. Open it with `data-olis-sheet-open={id}` and install
  the OlisUI Alpine providers. Supply `open` and `on_open_change` for
  LiveView-controlled state.
  """
  attr(:id, :string, required: true)
  attr(:title, :string, required: true)
  attr(:description, :string, default: nil)
  attr(:placement, :string, default: "bottom", values: ~w(top bottom left right))
  attr(:backdrop, :string, default: "opaque", values: ~w(opaque blur transparent))
  attr(:dismissible, :boolean, default: true)
  attr(:detached, :boolean, default: false)
  attr(:handle, :boolean, default: true)
  attr(:snap_points, :list, default: [])
  attr(:snap_index, :integer, default: 0)
  attr(:on_snap_change, :string, default: nil)
  attr(:open, :boolean, default: false)
  attr(:on_open_change, :any, default: nil)
  attr(:target, :any, default: nil)
  attr(:class, :any, default: nil)
  attr(:body_class, :any, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)
  slot(:footer)

  def sheet(assigns) do
    ~H"""
    <dialog
      id={@id}
      class={[
        "sheet__overlay z-50 data-[closed]:pointer-events-none",
        "fixed inset-0 m-0 hidden h-dvh max-h-none w-screen max-w-none border-0 bg-transparent p-0 outline-none open:flex [&:not([open])]:hidden",
        @placement == "bottom" && "items-end justify-center",
        @placement == "top" && "items-start justify-center",
        @placement == "left" && "items-center justify-start",
        @placement == "right" && "items-center justify-end",
        "backdrop:bg-transparent"
      ]}
      data-olis-sheet
      x-data="olisSheet"
      x-on:click.window="openFromTrigger($event)"
      x-on:click="click($event)"
      x-on:cancel="cancel($event)"
      x-on:close="close($event)"
      x-on:pointerdown="pointerdown($event)"
      x-on:pointermove="pointermove($event)"
      x-on:pointerup="pointerup($event)"
      x-on:pointercancel="pointercancel($event)"
      x-on:touchstart.passive="touchstart($event)"
      x-on:touchmove="touchmove($event)"
      x-on:touchend="touchend($event)"
      x-on:touchcancel="touchcancel($event)"
      x-on:resize.window="resize()"
      x-on:phx:update.window="sync()"
      data-slot="sheet-overlay"
      data-placement={@placement}
      data-dismissible={to_string(@dismissible)}
      data-snap-points-json={Jason.encode!(@snap_points)}
      data-snap-index={@snap_index}
      data-open={to_string(@open)}
      aria-labelledby={"#{@id}-title"}
      aria-describedby={if @description, do: "#{@id}-description"}
      phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["open", "data-sheet-nested"])}
      {@rest}
    >
      <div
        class={[
          "sheet__backdrop sheet__backdrop--#{@backdrop} fixed inset-0 bg-transparent [@media(prefers-reduced-motion:reduce)]:[animation-duration:1ms]",
          @backdrop == "opaque" && "data-[stack-index='0']:bg-backdrop",
          @backdrop == "blur" &&
            "data-[stack-index='0']:bg-background/[0.01] data-[stack-index='0']:backdrop-blur-sm"
        ]}
        data-slot="sheet-backdrop"
        data-olis-sheet-backdrop
        data-stack-index="0"
        aria-hidden="true"
        phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["data-stack-index", "style"])}
      >
      </div>
      <div
        class={[
          "sheet__content sheet__content--#{@placement} olis-sheet-content",
          @placement in ["top", "bottom"] && !@detached && "w-full",
          @placement in ["top", "bottom"] && !@detached && @snap_points == [] &&
            "max-h-[calc(100%-2rem)]",
          @placement in ["top", "bottom"] && @detached && "m-2 w-[calc(100%-1rem)] rounded-[12px]",
          @placement in ["top", "bottom"] && @detached && @snap_points == [] &&
            "max-h-[calc(100%-1rem)]",
          @placement in ["top", "bottom"] && @snap_points != [] && "max-h-none",
          @placement in ["top", "bottom"] && @snap_points != [] && !@detached && "h-full",
          @placement in ["top", "bottom"] && @snap_points != [] && @detached && "h-[calc(100%-1rem)]",
          @placement == "bottom" && !@detached && "rounded-t-[12px]",
          @placement == "top" && !@detached && "rounded-b-[12px]",
          @placement in ["left", "right"] && !@detached && "h-full max-h-none",
          @placement in ["left", "right"] && @detached &&
            "m-2 h-[calc(100%-1rem)] max-h-[calc(100%-1rem)] rounded-[12px]",
          @placement in ["left", "right"] && @snap_points == [] && "w-[min(24rem,96vw)]",
          @placement in ["left", "right"] && @snap_points != [] && !@detached && "w-full max-w-none",
          @placement in ["left", "right"] && @snap_points != [] && @detached &&
            "w-[calc(100%-1rem)] max-w-none",
          @placement == "left" && !@detached && "rounded-r-[12px]",
          @placement == "right" && !@detached && "rounded-l-[12px]",
          @class
        ]}
        data-slot="sheet-content"
        data-olis-sheet-content
        data-placement={@placement}
        data-detached={if @detached, do: "true"}
        data-snap-points={if @snap_points != [], do: "true"}
        data-expanded={if @snap_points == [], do: "true"}
        phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["data-expanded", "style"])}
      >
        <section
          class={[
            "sheet__dialog sheet__dialog--#{@placement} olis-sheet-panel",
            @detached && "rounded-[12px]",
            !@detached && @placement == "bottom" && "rounded-t-[12px]",
            !@detached && @placement == "top" && "rounded-b-[12px]",
            !@detached && @placement == "left" && "rounded-r-[12px]",
            !@detached && @placement == "right" && "rounded-l-[12px]",
            "max-h-[inherit]",
            (@placement in ["left", "right"] || @snap_points != []) && "h-full"
          ]}
          data-slot="sheet-dialog"
        >
          <div
            :if={@handle}
            class="sheet__handle olis-sheet-grip"
            data-slot="sheet-handle"
            data-olis-sheet-handle
            aria-hidden="true"
          >
            <span
              class="sheet__handle-bar block h-[0.3rem] w-8 rounded-full bg-default"
              data-slot="sheet-handle-bar"
            ></span>
          </div>
          <OlisUI.Button.close_button
            class="sheet__close-trigger olis-sheet-close"
            data-slot="sheet-close-trigger"
            data-olis-sheet-close
          />
          <header
            class="sheet__header flex shrink-0 flex-col gap-1 px-5 pt-4 pb-2"
            data-slot="sheet-header"
          >
            <h2
              id={"#{@id}-title"}
              class="sheet__heading text-lg font-[590]"
              data-slot="sheet-heading"
            >
              {@title}
            </h2>
          </header>
          <div
            class={[
              "sheet__body olis-sheet-body scrollbar",
              @body_class
            ]}
            data-slot="sheet-body"
            data-olis-sheet-body
          >
            <p :if={@description} id={"#{@id}-description"} class="text-sm text-muted">
              {@description}
            </p>
            {render_slot(@inner_block)}
          </div>
          <footer
            :if={@footer != []}
            class="sheet__footer flex shrink-0 items-center justify-end gap-2 px-5 pt-2 pb-4"
            data-slot="sheet-footer"
          >
            {render_slot(@footer)}
          </footer>
        </section>
      </div>
      <button
        :if={@on_snap_change}
        type="button"
        hidden
        data-olis-sheet-snap-event
        phx-value-id={@id}
        phx-click={@on_snap_change}
        phx-target={@target}
      ></button>
      <button
        :if={@on_open_change}
        type="button"
        hidden
        data-olis-sheet-event
        phx-value-id={@id}
        phx-click={@on_open_change}
        phx-target={@target}
      ></button>
    </dialog>
    """
  end
end
