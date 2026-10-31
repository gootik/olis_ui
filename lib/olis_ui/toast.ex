defmodule OlisUI.Toast do
  @moduledoc "Toast notification regions."
  use Phoenix.Component, global_prefixes: ~w(x-)
  import OlisUI.Shared

  @toast_icons [
    {"info", "circle-info"},
    {"success", "circle-check"},
    {"warning", "triangle-exclamation"},
    {"danger", "circle-exclamation"}
  ]

  @doc "A notification region whose toasts are managed by LiveView."
  attr(:id, :string, required: true)
  attr(:toasts, :list, default: [])
  attr(:on_dismiss, :string, required: true)
  attr(:target, :any, default: nil)

  attr(:placement, :string,
    default: "bottom",
    values: ~w(top top-start top-end bottom bottom-start bottom-end)
  )

  attr(:label, :string, default: "Notifications")
  attr(:width, :integer, default: 460)
  attr(:gap, :integer, default: 12)
  attr(:max_visible, :integer, default: 3)
  attr(:timeout, :integer, default: 4000)
  attr(:expanded, :boolean, default: false)
  attr(:class, :any, default: nil)

  slot :indicator do
    attr(:name, :string, required: true)
  end

  def toast_region(assigns) do
    names = Enum.map(assigns.indicator, & &1.name)

    assigns = assign(assigns, indicator_names: names, toast_icons: @toast_icons)

    ~H"""
    <div
      id={@id}
      class={[
        "toast-region toast-region--#{@placement} olis-toast-region",
        @placement == "bottom" && "bottom-4 left-1/2 -translate-x-1/2",
        @placement == "bottom-start" && "start-4 bottom-4",
        @placement == "bottom-end" && "end-4 bottom-4",
        @placement == "top" && "top-4 left-1/2 -translate-x-1/2",
        @placement == "top-start" && "start-4 top-4",
        @placement == "top-end" && "end-4 top-4",
        @placement in ["bottom", "bottom-start", "bottom-end"] &&
          "[@supports(-webkit-touch-callout:none)]:w-0 [@supports(-webkit-touch-callout:none)]:min-w-0 [@supports(-webkit-touch-callout:none)]:sm:min-w-0 [@supports(-webkit-touch-callout:none)]:focus-visible:outline-none [@supports(-webkit-touch-callout:none)]:data-[focus-visible=true]:outline-none [@supports(-webkit-touch-callout:none)]:[&:focus-visible_.toast[data-frontmost=true]]:outline-2 [@supports(-webkit-touch-callout:none)]:[&:focus-visible_.toast[data-frontmost=true]]:outline-offset-2 [@supports(-webkit-touch-callout:none)]:[&:focus-visible_.toast[data-frontmost=true]]:outline-focus [@supports(-webkit-touch-callout:none)]:[&[data-focus-visible=true]_.toast[data-frontmost=true]]:outline-2 [@supports(-webkit-touch-callout:none)]:[&[data-focus-visible=true]_.toast[data-frontmost=true]]:outline-offset-2 [@supports(-webkit-touch-callout:none)]:[&[data-focus-visible=true]_.toast[data-frontmost=true]]:outline-focus",
        @class
      ]}
      data-slot="toast-region"
      data-olis-toast-region
      x-data="olisToastRegion"
      x-on:phx:update.document="sync()"
      x-on:pointerenter="pointerEnter($event)"
      x-on:pointermove="pointerEnter($event)"
      x-on:pointerleave="pointerLeave($event)"
      x-on:focusin="focusIn($event)"
      x-on:focusout="focusOut($event)"
      x-on:keydown.document="keydown($event)"
      x-on:visibilitychange.document="reconcile()"
      x-on:focus.window="reconcile()"
      x-on:blur.window="reconcile()"
      x-on:resize.window="layout()"
      data-toasts={Jason.encode!(@toasts)}
      data-placement={@placement}
      data-gap={@gap}
      data-max-visible={@max_visible}
      data-timeout={@timeout}
      data-indicators={Jason.encode!(@indicator_names)}
      data-expanded={to_string(@expanded)}
      style={"--toast-width: #{@width}px; --gap: #{@gap}px"}
      role="region"
      aria-label={@label}
      tabindex="-1"
      phx-update="ignore"
    >
      <button
        type="button"
        hidden
        data-olis-toast-dismiss
        phx-click={@on_dismiss}
        phx-target={@target}
      ></button>
      <ol data-olis-toast-list class="contents">
        <template x-for="item in items" x-bind:key="item.uid">
          <li class="contents">
            <div
              class="toast olis-toast-card"
              x-bind:class="`toast--${$root.dataset.placement} toast--${variant(item.data.variant)}`"
              data-slot="toast"
              data-olis-toast
              x-bind:data-toast-uid="item.uid"
              x-bind:data-index="item.index"
              x-bind:data-frontmost="String(item.index === 0)"
              x-bind:data-placement="$root.dataset.placement"
              x-bind:data-expanded="item.expanded ? 'true' : null"
              x-bind:data-hidden="item.hidden ? 'true' : null"
              x-bind:data-entering="item.entering ? 'true' : null"
              x-bind:data-exiting="item.exiting ? 'true' : null"
              x-bind:aria-hidden="item.hidden || item.exiting ? 'true' : null"
              x-bind:inert="item.hidden || item.exiting"
              x-bind:tabindex="!item.hidden && (item.index === 0 || item.expanded) ? 0 : -1"
              x-bind:style="style(item)"
              role="alertdialog"
              aria-modal="false"
              x-bind:aria-labelledby="`${item.uid}-title`"
              x-bind:aria-describedby="item.data.description ? `${item.uid}-description` : null"
            >
              <template x-if="loading(item)">
                <div
                  class="toast__indicator olis-toast-icon"
                  data-slot="toast-indicator"
                  aria-hidden="true"
                >
                  <OlisUI.Display.spinner size="sm" color="current" decorative />
                </div>
              </template>
              <template
                :for={indicator <- @indicator}
                x-if={"!loading(item) && item.data.indicator === #{Jason.encode!(indicator.name)}"}
              >
                <div
                  class="toast__indicator olis-toast-icon"
                  data-slot="toast-indicator"
                  aria-hidden="true"
                >
                  {render_slot(indicator)}
                </div>
              </template>
              <template x-if="!loading(item) && item.data.indicator !== false && !customIndicator(item)">
                <div
                  class="toast__indicator olis-toast-icon"
                  data-slot="toast-indicator"
                >
                  <template
                    :for={{name, icon} <- @toast_icons}
                    x-if={
                      if name == "info",
                        do: "!['success', 'warning', 'danger'].includes(item.data.variant)",
                        else: "item.data.variant === '#{name}'"
                    }
                  >
                    <OlisUI.Icon.icon name={icon} data-slot="toast-default-icon" />
                  </template>
                </div>
              </template>
              <div
                class="toast__content olis-toast-message"
                data-slot="toast-content"
                role="alert"
                aria-atomic="true"
              >
                <span
                  class="toast__title olis-toast-title"
                  data-slot="toast-title"
                  x-bind:id="`${item.uid}-title`"
                  x-text="item.data.title"
                ></span>
                <template x-if="item.data.description">
                  <span
                    class="toast__description text-sm text-muted"
                    data-slot="toast-description"
                    x-bind:id="`${item.uid}-description`"
                    x-text="item.data.description"
                  ></span>
                </template>
              </div>
              <template x-if="item.data.action && item.data.action.label">
                <button
                  type="button"
                  class={[
                    button_classes("tertiary", "md"),
                    "toast__action olis-toast-action"
                  ]}
                  data-slot="toast-action-button"
                  data-olis-toast-action
                  x-bind:phx-click="actionCommand(item)"
                  x-on:click="action(item)"
                  x-text="item.data.action.label"
                ></button>
              </template>
              <button
                type="button"
                class={[
                  close_button_classes(true),
                  "toast__close-button olis-toast-close"
                ]}
                data-slot="toast-close"
                data-olis-toast-close
                aria-label="Close"
                x-on:click="close(item)"
              >
                <OlisUI.Icon.icon
                  name="xmark"
                  data-slot="close-button-icon"
                />
              </button>
            </div>
          </li>
        </template>
      </ol>
    </div>
    """
  end
end
