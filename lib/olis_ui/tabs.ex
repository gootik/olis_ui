defmodule OlisUI.Tabs do
  @moduledoc "Tabbed navigation and panels."
  use Phoenix.Component, global_prefixes: ~w(x-)

  @doc """
  A keyboard-accessible tab set. Use `selected_key` and `on_selection_change`
  for LiveView-controlled selection. Requires OlisUI's Alpine components.
  """
  attr(:id, :string, required: true)
  attr(:label, :string, required: true)
  attr(:selected_key, :string, required: true)
  attr(:on_selection_change, :string, required: true)
  attr(:target, :any, default: nil)
  attr(:variant, :string, default: "primary", values: ~w(primary secondary))
  attr(:orientation, :string, default: "horizontal", values: ~w(horizontal vertical))
  attr(:align, :string, default: "center", values: ~w(start center end))
  attr(:activation_mode, :string, default: "automatic", values: ~w(automatic manual))
  attr(:show_separators, :boolean, default: false)
  attr(:scroll_previous_label, :string, default: "Scroll tabs backward")
  attr(:scroll_next_label, :string, default: "Scroll tabs forward")
  attr(:class, :any, default: nil)

  slot :tab, required: true do
    attr(:id, :string, required: true)
    attr(:label, :string, required: true)
    attr(:disabled, :boolean)
    attr(:class, :any)
  end

  def tabs(assigns) do
    assigns = assign(assigns, :selected_id, assigns.selected_key)

    ~H"""
    <div
      id={@id}
      class={[
        "tabs tabs--#{@variant} flex gap-2",
        @orientation == "horizontal" && "flex-col",
        @orientation == "vertical" && "flex-row",
        @align != "center" && "tabs--align-#{@align}",
        @class
      ]}
      data-slot="tabs"
      data-orientation={@orientation}
      data-olis-tabs
      data-selected-key={@selected_key}
      data-activation-mode={@activation_mode}
      x-data="olisTabs"
      x-on:phx:update.window="sync()"
    >
      <div
        class={[
          "tabs__list-container relative min-w-0 max-w-full has-[>[data-left-scroll=true]]:[&>[data-slot=tabs-scroll-prev]]:inline-flex has-[>[data-left-right-scroll=true]]:[&>[data-slot=tabs-scroll-prev]]:inline-flex has-[>[data-top-scroll=true]]:[&>[data-slot=tabs-scroll-prev]]:inline-flex has-[>[data-top-bottom-scroll=true]]:[&>[data-slot=tabs-scroll-prev]]:inline-flex has-[>[data-right-scroll=true]]:[&>[data-slot=tabs-scroll-next]]:inline-flex has-[>[data-left-right-scroll=true]]:[&>[data-slot=tabs-scroll-next]]:inline-flex has-[>[data-bottom-scroll=true]]:[&>[data-slot=tabs-scroll-next]]:inline-flex has-[>[data-top-bottom-scroll=true]]:[&>[data-slot=tabs-scroll-next]]:inline-flex",
          @variant == "primary" && "rounded-[6px] bg-default",
          @variant == "secondary" && @orientation == "horizontal" &&
            "rounded-none border-b border-border bg-transparent",
          @variant == "secondary" && @orientation == "vertical" &&
            "rounded-none border-s border-border bg-transparent"
        ]}
        data-slot="tabs-list-container"
      >
        <div
          class={[
            "scroll-shadow relative scrollbar-none",
            @orientation == "horizontal" && "overflow-x-auto",
            @orientation == "vertical" && "overflow-y-auto",
            "scroll-shadow--hide-scrollbar",
            "scroll-shadow--#{@orientation}",
            "scroll-shadow--fade",
            "tabs__list-container__scroller",
            "max-w-full",
            @orientation == "vertical" && "h-full",
            "[--scroll-shadow-size:64px]"
          ]}
          data-orientation={@orientation}
          data-scroll-shadow-mode="auto"
          x-ref="scroller"
          x-on:scroll="updateScroll()"
          x-bind:data-left-scroll="$el.dataset.orientation === 'horizontal' && before && !after ? 'true' : null"
          x-bind:data-right-scroll="$el.dataset.orientation === 'horizontal' && !before && after ? 'true' : null"
          x-bind:data-left-right-scroll="$el.dataset.orientation === 'horizontal' && before && after ? 'true' : null"
          x-bind:data-top-scroll="$el.dataset.orientation === 'vertical' && before && !after ? 'true' : null"
          x-bind:data-bottom-scroll="$el.dataset.orientation === 'vertical' && !before && after ? 'true' : null"
          x-bind:data-top-bottom-scroll="$el.dataset.orientation === 'vertical' && before && after ? 'true' : null"
          phx-mounted={
            Phoenix.LiveView.JS.ignore_attributes([
              "data-left-scroll",
              "data-right-scroll",
              "data-left-right-scroll",
              "data-top-scroll",
              "data-bottom-scroll",
              "data-top-bottom-scroll"
            ])
          }
        >
          <div
            class={[
              "tabs__list inline-flex",
              @variant == "primary" && "p-1",
              @variant == "secondary" && "p-0",
              @orientation == "horizontal" && "w-max min-w-full flex-row",
              @orientation == "vertical" && "flex-col gap-1"
            ]}
            role="tablist"
            data-slot="tabs-list"
            aria-label={@label}
            aria-orientation={@orientation}
            data-orientation={@orientation}
            x-ref="list"
            x-on:keydown="keydown($event)"
            x-on:focusout="leave($event)"
          >
            <button
              :for={{tab, index} <- Enum.with_index(@tab)}
              id={"#{@id}-tab-#{tab.id}"}
              type="button"
              role="tab"
              class={[
                "tabs__tab olis-tab",
                @align == "center" && "justify-center text-center",
                @align == "start" && "justify-start text-start",
                @align == "end" && "justify-end text-end",
                @orientation == "vertical" && "min-w-20",
                @variant == "primary" && "rounded-[6px] data-[selected=true]:text-segment-foreground",
                @variant == "secondary" && "rounded-none data-[selected=true]:text-foreground",
                Map.get(tab, :class)
              ]}
              data-slot="tabs-tab"
              data-key={tab.id}
              data-selected={to_string(tab.id == @selected_id)}
              aria-selected={to_string(tab.id == @selected_id)}
              aria-controls={"#{@id}-panel-#{tab.id}"}
              tabindex={if tab.id == @selected_id, do: "0", else: "-1"}
              disabled={Map.get(tab, :disabled, false)}
              data-disabled={if Map.get(tab, :disabled, false), do: "true"}
              x-bind:data-selected="(selected === $el.dataset.key).toString()"
              x-bind:aria-selected="(selected === $el.dataset.key).toString()"
              x-bind:tabindex="focused === $el.dataset.key ? 0 : -1"
              x-on:click="select($el.dataset.key)"
              phx-mounted={
                Phoenix.LiveView.JS.ignore_attributes(["aria-selected", "data-selected", "tabindex"])
              }
            >
              <span
                :if={@show_separators && index > 0}
                class={[
                  "tabs__separator olis-tab-rule",
                  @variant == "secondary" && "hidden",
                  @orientation == "horizontal" && "start-0 top-1/4 h-1/2 w-px",
                  @orientation == "vertical" && "start-[5%] top-0 h-px w-[90%]"
                ]}
                data-slot="tabs-separator"
                aria-hidden="true"
              ></span>
              {tab.label}<span
                class={[
                  "tabs__indicator absolute start-0 -z-1 [[data-slot=tabs-tab]:not([data-selected=true])_&]:hidden",
                  @variant == "primary" && "top-0 size-full rounded-[6px] bg-segment shadow-surface",
                  @variant == "secondary" && @orientation == "horizontal" &&
                    "bottom-0 h-0.5 w-full rounded-none bg-accent shadow-none",
                  @variant == "secondary" && @orientation == "vertical" &&
                    "top-0 h-full w-0.5 rounded-none bg-accent shadow-none"
                ]}
                data-slot="tabs-indicator"
                aria-hidden="true"
              ></span>
            </button>
          </div>
        </div>
        <button
          type="button"
          class={[
            "tabs__list-container__scroll-prev olis-tab-scroll",
            @orientation == "horizontal" && "start-1 top-1/2 -translate-y-1/2 rtl:rotate-180",
            @orientation == "vertical" && "top-1 left-1/2 -translate-x-1/2"
          ]}
          aria-label={@scroll_previous_label}
          data-slot="tabs-scroll-prev"
          tabindex="-1"
          x-on:click="scroll('previous')"
        ><OlisUI.Icon.icon name="chevron-left" /></button>
        <button
          type="button"
          class={[
            "tabs__list-container__scroll-next olis-tab-scroll",
            @orientation == "horizontal" && "end-1 top-1/2 -translate-y-1/2 rtl:rotate-180",
            @orientation == "vertical" && "bottom-1 left-1/2 -translate-x-1/2"
          ]}
          aria-label={@scroll_next_label}
          data-slot="tabs-scroll-next"
          tabindex="-1"
          x-on:click="scroll('next')"
        ><OlisUI.Icon.icon name="chevron-right" /></button>
      </div>
      <div
        :for={tab <- @tab}
        id={"#{@id}-panel-#{tab.id}"}
        role="tabpanel"
        class={[
          "tabs__panel olis-tab-panel",
          @orientation == "horizontal" && "mt-4",
          @orientation == "vertical" && "ms-4"
        ]}
        data-slot="tabs-panel"
        data-key={tab.id}
        data-orientation={@orientation}
        aria-labelledby={"#{@id}-tab-#{tab.id}"}
        hidden={tab.id != @selected_id}
        x-bind:hidden="selected !== $el.dataset.key"
        tabindex="0"
        phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["hidden"])}
      >
        {render_slot(tab)}
      </div>
      <button
        :if={@on_selection_change}
        type="button"
        hidden
        x-ref="changeEvent"
        phx-click={@on_selection_change}
        phx-target={@target}
      ></button>
    </div>
    """
  end
end
