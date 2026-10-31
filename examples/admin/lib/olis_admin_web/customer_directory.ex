defmodule OlisAdminWeb.CustomerDirectory do
  @moduledoc "A searchable customer directory derived from the dashboard's orders."

  use Phoenix.LiveComponent

  import OlisUI

  alias OlisAdmin.Catalog

  @impl true
  def mount(socket) do
    {:ok, assign(socket, query: "", selected_email: nil)}
  end

  @impl true
  def update(assigns, socket) do
    {:ok, socket |> assign(assigns) |> refresh_directory()}
  end

  @impl true
  def handle_event("search", %{"query" => query}, socket) do
    {:noreply, socket |> assign(query: query) |> refresh_directory()}
  end

  def handle_event("select", %{"email" => email}, socket) do
    if Enum.any?(socket.assigns.customers, &(&1.key == email)) do
      {:noreply, socket |> assign(selected_email: email) |> refresh_directory()}
    else
      {:noreply, socket}
    end
  end

  def handle_event("clear_selection", _params, socket) do
    {:noreply, socket |> assign(selected_email: nil) |> refresh_directory()}
  end

  defp refresh_directory(socket) do
    customers =
      socket.assigns.orders
      |> Enum.group_by(&email_key(&1.email))
      |> Enum.map(fn {key, orders} ->
        latest = hd(orders)

        %{
          key: key,
          name: latest.name,
          email: latest.email,
          orders: orders,
          order_total: Enum.reduce(orders, 0, &(&1.amount + &2)),
          paid_total:
            orders |> Enum.filter(&(&1.status == "Paid")) |> Enum.reduce(0, &(&1.amount + &2))
        }
      end)
      |> Enum.sort_by(&String.downcase(&1.name))

    query = socket.assigns.query |> String.trim() |> String.downcase()

    visible =
      Enum.filter(customers, fn customer ->
        query == "" or String.contains?(String.downcase(customer.name), query) or
          String.contains?(customer.key, query)
      end)

    selected = Enum.find(visible, &(&1.key == socket.assigns.selected_email))

    assign(socket,
      customers: customers,
      visible_customers: visible,
      selected: selected,
      selected_email: if(selected, do: selected.key)
    )
  end

  defp email_key(email), do: email |> String.trim() |> String.downcase()

  @impl true
  def render(assigns) do
    ~H"""
    <div class="grid gap-5 xl:grid-cols-[minmax(0,1fr)_minmax(0,1.25fr)]">
      <.card class="min-w-0 border border-border shadow-none">
        <:content>
          <div class="flex flex-wrap items-start justify-between gap-4">
            <div>
              <h2 class="m-0 text-base font-medium">Customer directory</h2>
              <p class="mt-1 mb-0 text-sm text-muted" aria-live="polite">
                {length(@visible_customers)} of {length(@customers)} customers
              </p>
            </div>
            <form phx-change="search" phx-target={@myself} class="w-full sm:w-60">
              <.search_field
                id={"#{@id}-search"}
                name="query"
                value={@query}
                aria-label="Search customers"
                placeholder="Search name or email..."
                phx-debounce="200"
              />
            </form>
          </div>

          <.empty_state :if={@customers == []} as="p" class="mt-5">
            Customers appear here when an order is created.
          </.empty_state>
          <.empty_state :if={@customers != [] && @visible_customers == []} as="p" class="mt-5">
            No customers match your search.
          </.empty_state>

          <ul :if={@visible_customers != []} class="m-0 mt-5 list-none divide-y divide-border p-0">
            <li :for={customer <- @visible_customers}>
              <button
                type="button"
                phx-click="select"
                phx-value-email={customer.key}
                phx-target={@myself}
                aria-pressed={to_string(@selected_email == customer.key)}
                class={[
                  "flex w-full items-center gap-3 rounded-md px-3 py-3 text-left transition-colors hover:bg-default",
                  @selected_email == customer.key && "bg-default"
                ]}
              >
                <.avatar name={customer.name} size="sm" variant="soft" />
                <span class="min-w-0 flex-1">
                  <span class="block truncate text-sm font-medium">{customer.name}</span>
                  <span class="block truncate text-xs text-muted">{customer.email}</span>
                </span>
                <span class="shrink-0 text-xs text-muted">
                  {length(customer.orders)} {if length(customer.orders) == 1,
                    do: "order",
                    else: "orders"}
                </span>
              </button>
            </li>
          </ul>
        </:content>
      </.card>

      <.card class="min-w-0 border border-border shadow-none">
        <:content>
          <%= if @selected do %>
            <div class="flex items-start justify-between gap-3">
              <div class="flex min-w-0 items-center gap-3">
                <.avatar name={@selected.name} size="md" variant="soft" />
                <div class="min-w-0">
                  <h2 class="m-0 truncate text-base font-medium">{@selected.name}</h2>
                  <p class="mt-1 mb-0 break-all text-sm text-muted">{@selected.email}</p>
                </div>
              </div>
              <.button variant="ghost" size="sm" phx-click="clear_selection" phx-target={@myself}>
                Close
              </.button>
            </div>

            <dl class="mt-6 grid grid-cols-2 gap-4 rounded-md bg-surface-secondary p-4">
              <div>
                <dt class="text-xs text-muted">Order value</dt>
                <dd class="m-0 mt-1 text-base font-medium">
                  {Catalog.format_money(@selected.order_total)}
                </dd>
              </div>
              <div>
                <dt class="text-xs text-muted">Paid orders</dt>
                <dd class="m-0 mt-1 text-base font-medium">
                  {Catalog.format_money(@selected.paid_total)}
                </dd>
              </div>
            </dl>
            <p class="mt-2 text-xs text-muted">Order value includes pending and refunded orders.</p>

            <h3 class="mt-6 mb-1 text-sm font-medium">Order history</h3>
            <ul class="m-0 list-none divide-y divide-border p-0">
              <li :for={order <- @selected.orders} class="flex flex-wrap items-center gap-3 py-3">
                <div class="min-w-0 flex-1">
                  <p class="m-0 text-sm font-medium">{order.id} · {order.product}</p>
                  <p class="mt-1 mb-0 text-xs text-muted">{order.date} · {order.fulfillment}</p>
                </div>
                <.chip size="sm" variant="soft" color={Catalog.status_color(order.status)}>
                  {order.status}
                </.chip>
                <span class="text-sm font-medium">{Catalog.format_money(order.amount)}</span>
              </li>
            </ul>
          <% else %>
            <h2 class="m-0 text-base font-medium">Customer details</h2>
            <.empty_state as="p" class="mt-5">
              Select a customer to view their order history and totals.
            </.empty_state>
          <% end %>
        </:content>
      </.card>
    </div>
    """
  end
end
