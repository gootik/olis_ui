defmodule OlisAdminWeb.DashboardLive do
  use Phoenix.LiveView, layout: false

  import OlisUI
  import OlisAdminWeb.ComponentKit

  alias OlisAdmin.Catalog

  @pages ~w(overview orders customers products settings components)
  @page_size 5

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(
        page: "overview",
        orders: Catalog.orders(),
        products: Catalog.products(),
        product_query: "",
        editing_product: nil,
        stock_input: "",
        stock_error: nil,
        kit_page: 1,
        query: "",
        status: "All",
        sort_by: "date",
        sort_direction: "descending",
        selected_orders: [],
        current_page: 1,
        period: "30 days",
        order_modal_open: false,
        order_form: %{
          "name" => "",
          "email" => "",
          "product" => "Everyday Tote",
          "amount" => "128"
        },
        form_error: nil,
        announcement: nil,
        announcement_status: "success",
        store_name: "Northstar Studio",
        contact_email: "hello@northstar.example",
        settings_form: %{"name" => "Northstar Studio", "email" => "hello@northstar.example"},
        notifications: true,
        dark_mode: true
      )
      |> refresh_orders()

    {:ok, socket}
  end

  @impl true
  def handle_event("navigate", %{"page" => page}, socket) when page in @pages do
    {:noreply, assign(socket, page: page, announcement: nil)}
  end

  def handle_event("kit_page", %{"page" => page}, socket) do
    case Integer.parse(to_string(page)) do
      {number, ""} when number in 1..3 -> {:noreply, assign(socket, :kit_page, number)}
      _ -> {:noreply, socket}
    end
  end

  def handle_event("filter_products", %{"query" => query}, socket) do
    {:noreply, assign(socket, :product_query, query)}
  end

  def handle_event("edit_inventory", %{"product" => product_id}, socket) do
    case Enum.find(socket.assigns.products, &(&1.id == product_id)) do
      nil ->
        {:noreply, socket}

      product ->
        {:noreply,
         assign(socket,
           editing_product: product,
           stock_input: Integer.to_string(product.stock),
           stock_error: nil
         )}
    end
  end

  def handle_event("close_inventory", _, socket) do
    {:noreply, assign(socket, editing_product: nil, stock_error: nil)}
  end

  def handle_event("validate_inventory", %{"inventory" => form}, socket) do
    {:noreply, assign(socket, stock_input: Map.get(form, "stock", ""), stock_error: nil)}
  end

  def handle_event("save_inventory", %{"inventory" => form}, socket) do
    input = Map.get(form, "stock", "")

    with %{id: id, name: name} <- socket.assigns.editing_product,
         {stock, ""} when stock >= 0 and stock <= 1_000_000 <- Integer.parse(input),
         {:ok, products} <- Catalog.update_stock(socket.assigns.products, id, stock) do
      {:noreply,
       assign(socket,
         products: products,
         editing_product: nil,
         stock_error: nil,
         announcement: "Inventory for #{name} updated to #{stock} units.",
         announcement_status: "success"
       )}
    else
      _ ->
        {:noreply,
         assign(socket,
           stock_input: input,
           stock_error: "Enter a whole number between 0 and 1,000,000."
         )}
    end
  end

  def handle_event("ship_orders", _, socket) do
    selected = MapSet.new(socket.assigns.selected_orders)

    {orders, shipped} =
      Enum.map_reduce(socket.assigns.orders, 0, fn order, count ->
        if MapSet.member?(selected, order.id) and order.status == "Paid" and
             order.fulfillment in ["Processing", "Unfulfilled"] do
          {%{order | fulfillment: "Shipped"}, count + 1}
        else
          {order, count}
        end
      end)

    {message, status} =
      if shipped == 0 do
        {"No selected orders can be shipped. Only paid, unshipped orders are eligible.",
         "warning"}
      else
        {"Marked #{shipped} #{if shipped == 1, do: "order", else: "orders"} as shipped.",
         "success"}
      end

    {:noreply,
     socket
     |> assign(
       orders: orders,
       selected_orders: [],
       announcement: message,
       announcement_status: status
     )
     |> refresh_orders()}
  end

  def handle_event("filter", params, socket) do
    socket =
      socket
      |> assign(query: Map.get(params, "query", ""), current_page: 1)
      |> refresh_orders()

    {:noreply, socket}
  end

  def handle_event("status", %{"value" => status}, socket)
      when status in ~w(All Paid Pending Refunded) do
    {:noreply, socket |> assign(status: status, current_page: 1) |> refresh_orders()}
  end

  def handle_event("sort", %{"sort" => key}, socket) when key in ~w(date customer amount) do
    direction =
      if socket.assigns.sort_by == key and socket.assigns.sort_direction == "ascending" do
        "descending"
      else
        "ascending"
      end

    {:noreply, socket |> assign(sort_by: key, sort_direction: direction) |> refresh_orders()}
  end

  def handle_event("select_orders", %{"keys" => keys}, socket) do
    case Jason.decode(keys) do
      {:ok, values} when is_list(values) -> {:noreply, assign(socket, :selected_orders, values)}
      _ -> {:noreply, socket}
    end
  end

  def handle_event("change_page", %{"page" => page}, socket) do
    case Integer.parse(page) do
      {number, ""} -> {:noreply, socket |> assign(:current_page, number) |> refresh_orders()}
      _ -> {:noreply, socket}
    end
  end

  def handle_event("period", %{"value" => period}, socket)
      when period in ["7 days", "30 days", "90 days"] do
    {:noreply, assign(socket, :period, period)}
  end

  def handle_event("open_order", _, socket) do
    {:noreply, assign(socket, order_modal_open: true, form_error: nil)}
  end

  def handle_event("order_modal", %{"open" => open}, socket) do
    {:noreply, assign(socket, :order_modal_open, open == "true")}
  end

  def handle_event("validate_order", %{"order" => form}, socket) do
    {:noreply, assign(socket, order_form: form, form_error: nil)}
  end

  def handle_event("create_order", %{"order" => form}, socket) do
    name = String.trim(Map.get(form, "name", ""))
    email = String.trim(Map.get(form, "email", ""))

    with true <- name != "",
         true <- String.contains?(email, "@"),
         {amount, ""} when amount > 0 <- Float.parse(Map.get(form, "amount", "")) do
      order = %{
        id: "NS-#{3211 + length(socket.assigns.orders) - length(Catalog.orders())}",
        name: name,
        email: email,
        product: Map.get(form, "product", "Everyday Tote"),
        amount: amount,
        status: "Pending",
        fulfillment: "Unfulfilled",
        date: "Today",
        sort_date: Date.utc_today()
      }

      socket =
        socket
        |> assign(
          orders: [order | socket.assigns.orders],
          order_modal_open: false,
          order_form: %{
            "name" => "",
            "email" => "",
            "product" => "Everyday Tote",
            "amount" => "128"
          },
          form_error: nil,
          announcement: "Order #{order.id} was created.",
          announcement_status: "success",
          page: "orders",
          status: "All",
          query: "",
          current_page: 1
        )
        |> refresh_orders()

      {:noreply, socket}
    else
      _ ->
        {:noreply,
         assign(socket,
           order_form: form,
           form_error: "Enter a name, valid email, and amount greater than zero."
         )}
    end
  end

  def handle_event("dismiss_announcement", _, socket) do
    {:noreply, assign(socket, :announcement, nil)}
  end

  def handle_event("edit_settings", %{"store" => settings}, socket) do
    {:noreply, assign(socket, :settings_form, settings)}
  end

  def handle_event("save_settings", %{"store" => settings}, socket) do
    name = String.trim(Map.get(settings, "name", ""))
    email = String.trim(Map.get(settings, "email", ""))

    if name != "" and String.contains?(email, "@") do
      {:noreply,
       assign(socket,
         store_name: name,
         contact_email: email,
         settings_form: %{"name" => name, "email" => email},
         announcement: "Store settings saved.",
         announcement_status: "success"
       )}
    else
      {:noreply,
       assign(socket,
         settings_form: settings,
         announcement: "Enter a store name and valid email address.",
         announcement_status: "danger"
       )}
    end
  end

  def handle_event("notifications", %{"notifications" => value}, socket) do
    {:noreply, assign(socket, :notifications, value == "true")}
  end

  def handle_event("theme", _, socket) do
    {:noreply, update(socket, :dark_mode, &(!&1))}
  end

  def handle_event("kit_toast", _, socket) do
    {:noreply,
     push_event(socket, "olis:toast", %{
       title: "Changes saved",
       description: "Your workspace is up to date.",
       variant: "success"
     })}
  end

  def handle_event("export", _, socket) do
    header = "Order,Customer,Email,Product,Amount,Payment,Fulfillment\n"

    rows =
      Enum.map_join(socket.assigns.filtered_orders, "\n", fn order ->
        [
          order.id,
          order.name,
          order.email,
          order.product,
          Catalog.format_money(order.amount),
          order.status,
          order.fulfillment
        ]
        |> Enum.map_join(",", &csv_field/1)
      end)

    {:noreply, push_event(socket, "download-csv", %{csv: header <> rows <> "\n"})}
  end

  defp csv_field(value) do
    value = to_string(value)

    # Spreadsheet applications interpret these prefixes as formulas, even in quoted CSV cells.
    value =
      if Regex.match?(~r/^[\s\x00-\x1f]*[=+@-]/u, value) or
           String.starts_with?(value, ["\t", "\r", "\n"]) do
        "'" <> value
      else
        value
      end

    escaped = String.replace(value, "\"", "\"\"")
    "\"#{escaped}\""
  end

  defp refresh_orders(socket) do
    %{orders: orders, query: query, status: status, sort_by: sort_by, sort_direction: direction} =
      socket.assigns

    query = query |> String.trim() |> String.downcase()

    filtered =
      orders
      |> Enum.filter(fn order ->
        matches_query =
          query == "" or
            Enum.any?(
              [order.id, order.name, order.email, order.product],
              &String.contains?(String.downcase(&1), query)
            )

        matches_query and (status == "All" or order.status == status)
      end)
      |> Enum.sort_by(
        fn order ->
          case sort_by do
            "customer" -> String.downcase(order.name)
            "amount" -> order.amount
            _ -> {Date.to_gregorian_days(order.sort_date), order.id}
          end
        end,
        if(direction == "ascending", do: :asc, else: :desc)
      )

    total_pages = max(ceil(length(filtered) / @page_size), 1)
    page = socket.assigns.current_page |> max(1) |> min(total_pages)

    assign(socket,
      filtered_orders: filtered,
      visible_orders: Enum.slice(filtered, (page - 1) * @page_size, @page_size),
      total_pages: total_pages,
      current_page: page
    )
  end

  defp chart_labels("7 days"), do: ["6 days ago", "4 days ago", "2 days ago", "Today"]
  defp chart_labels("30 days"), do: ["29 days ago", "20 days ago", "10 days ago", "Today"]
  defp chart_labels("90 days"), do: ["89 days ago", "60 days ago", "30 days ago", "Today"]

  defp chart_class(value) do
    case value do
      25 -> "h-[25%]"
      27 -> "h-[27%]"
      30 -> "h-[30%]"
      31 -> "h-[31%]"
      32 -> "h-[32%]"
      35 -> "h-[35%]"
      37 -> "h-[37%]"
      38 -> "h-[38%]"
      42 -> "h-[42%]"
      45 -> "h-[45%]"
      46 -> "h-[46%]"
      48 -> "h-[48%]"
      52 -> "h-[52%]"
      57 -> "h-[57%]"
      61 -> "h-[61%]"
      62 -> "h-[62%]"
      63 -> "h-[63%]"
      68 -> "h-[68%]"
      71 -> "h-[71%]"
      72 -> "h-[72%]"
      75 -> "h-[75%]"
      77 -> "h-[77%]"
      78 -> "h-[78%]"
      80 -> "h-[80%]"
      88 -> "h-[88%]"
      89 -> "h-[89%]"
      90 -> "h-[90%]"
      96 -> "h-[96%]"
      98 -> "h-[98%]"
      _ -> "h-[50%]"
    end
  end

  defp icon(assigns) do
    ~H"""
    <svg
      aria-hidden="true"
      class={@class}
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      stroke-width="1.7"
      stroke-linecap="round"
      stroke-linejoin="round"
    >
      <path d={@path} />
    </svg>
    """
  end

  defp navigation do
    [
      {"overview", "Overview", "M3 3h8v8H3z M13 3h8v5h-8z M13 10h8v11h-8z M3 13h8v8H3z"},
      {"orders", "Orders", "M4 5h16v14H4z M8 3v4 M16 3v4 M4 9h16"},
      {"customers", "Customers",
       "M16 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2 M10 11a4 4 0 1 0 0-8 4 4 0 0 0 0 8z M20 21v-2a4 4 0 0 0-3-3.87"},
      {"products", "Products", "M12 3 3 7.5v9L12 21l9-4.5v-9L12 3z M3 7.5 12 12l9-4.5 M12 12v9"},
      {"components", "UI kit", "M4 4h7v7H4z M13 4h7v7h-7z M4 13h7v7H4z M13 13h7v7h-7z"},
      {"settings", "Settings",
       "M12 8a4 4 0 1 0 0 8 4 4 0 0 0 0-8z M12 2v2 M12 20v2 M4.93 4.93l1.42 1.42 M17.65 17.65l1.42 1.42 M2 12h2 M20 12h2 M4.93 19.07l1.42-1.42 M17.65 6.35l1.42-1.42"}
    ]
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen" data-theme={if @dark_mode, do: "dark", else: "light"}>
      <div class="min-h-screen bg-background text-foreground">
        <aside class="fixed inset-y-0 left-0 z-20 hidden w-60 flex-col border-r border-border bg-surface px-4 py-6 lg:flex">
          <div class="mb-10 flex items-center gap-3 px-2">
            <span class="grid size-9 place-items-center rounded-md bg-foreground text-lg font-medium text-background">✦</span>
            <div>
              <p class="m-0 text-sm font-medium tracking-tight">Northstar</p><p class="m-0 text-xs text-muted">
                Commerce workspace
              </p>
            </div>
          </div>
          <p class="mb-2 px-3 text-[10px] font-medium uppercase tracking-[0.12em] text-muted">
            Workspace
          </p>
          <nav aria-label="Main navigation" class="space-y-1">
            <button
              :for={{key, label, path} <- navigation()}
              type="button"
              phx-click="navigate"
              phx-value-page={key}
              aria-current={if @page == key, do: "page"}
              class={[
                "flex w-full items-center gap-3 rounded-md px-3 py-2.5 text-left text-sm font-medium transition-colors",
                if(@page == key,
                  do: "bg-default text-foreground",
                  else: "text-muted hover:bg-default/60 hover:text-foreground"
                )
              ]}
            >
              <.icon path={path} class="size-[18px] shrink-0" />{label}
            </button>
          </nav>
          <div class="mt-auto rounded-xl border border-border bg-surface-secondary p-4">
            <p class="m-0 text-sm font-medium">Your workspace</p>
            <p class="mt-1 mb-3 text-xs leading-5 text-muted">
              A realistic sample built with OlisUI and LiveView.
            </p>
            <.chip variant="soft" color="success" size="sm">All systems operational</.chip>
          </div>
          <div class="mt-5 flex items-center gap-3 border-t border-border px-2 pt-5">
            <.avatar name="Alex Morgan" size="sm" color="accent" variant="soft" />
            <div class="min-w-0">
              <p class="m-0 text-sm font-medium">Alex Morgan</p><p class="m-0 truncate text-xs text-muted">
                Store owner
              </p>
            </div>
          </div>
        </aside>

        <div class="lg:pl-60">
          <header class="sticky top-0 z-10 border-b border-border bg-surface/95 backdrop-blur">
            <div class="flex h-16 items-center justify-between gap-4 px-5 sm:px-8 lg:px-10">
              <div class="flex items-center gap-3 text-sm text-muted">
                <span class="font-medium text-foreground lg:hidden">✦ Northstar</span>
                <span class="hidden sm:inline">Workspace</span><span class="hidden text-border sm:inline">/</span>
                <span class="hidden font-medium capitalize text-foreground sm:inline">{@page}</span>
              </div>
              <div class="flex items-center gap-2">
                <.chip size="sm" variant="soft" color="success" class="hidden sm:inline-flex">
                  Live demo
                </.chip>
                <.tooltip
                  id="theme-tip"
                  text={if @dark_mode, do: "Switch to light mode", else: "Switch to dark mode"}
                  delay={0}
                >
                  <:trigger :let={attrs}>
                    <.button
                      variant="ghost"
                      icon_only
                      phx-click="theme"
                      aria-label={
                        if @dark_mode, do: "Switch to light mode", else: "Switch to dark mode"
                      }
                      {attrs}
                    >
                      <.icon
                        path="M12 3v2 M12 19v2 M4.93 4.93l1.42 1.42 M17.65 17.65l1.42 1.42 M3 12h2 M19 12h2 M4.93 19.07l1.42-1.42 M17.65 6.35l1.42-1.42 M12 8a4 4 0 1 0 0 8 4 4 0 0 0 0-8z"
                        class="size-4"
                      />
                    </.button>
                  </:trigger>
                </.tooltip>
                <.avatar name="Alex Morgan" size="sm" color="accent" variant="soft" />
              </div>
            </div>
            <nav aria-label="Mobile navigation" class="flex gap-1 overflow-x-auto px-4 pb-2 lg:hidden">
              <button
                :for={{key, label, _} <- navigation()}
                type="button"
                phx-click="navigate"
                phx-value-page={key}
                aria-current={if @page == key, do: "page"}
                class={[
                  "shrink-0 rounded-lg px-3 py-2 text-xs font-medium",
                  if(@page == key, do: "bg-default text-foreground", else: "text-muted")
                ]}
              >{label}</button>
            </nav>
          </header>

          <main class="mx-auto max-w-[1200px] px-5 py-8 sm:px-8 lg:px-10 lg:py-10">
            <div class="mb-8 flex flex-wrap items-end justify-between gap-4">
              <div>
                <p class="mb-1 text-sm text-muted">
                  {if @page == "overview", do: "Friday, October 30, 2026", else: "Northstar workspace"}
                </p>
                <h1 class="m-0 text-2xl font-medium tracking-tight sm:text-[28px]">
                  {page_title(@page)}
                </h1>
                <p class="mt-1 mb-0 text-sm text-muted">{page_description(@page)}</p>
              </div>
              <div class="flex flex-wrap gap-2">
                <.button variant="secondary" phx-click="export"><.icon
                  path="M12 3v12 M8 11l4 4 4-4 M4 17v3h16v-3"
                  class="size-4"
                />Export orders CSV</.button>
                <.button phx-click="open_order"><.icon path="M12 5v14 M5 12h14" class="size-4" />New order</.button>
              </div>
            </div>

            <.alert
              :if={@announcement}
              status={@announcement_status}
              title={@announcement}
              class="mb-6"
            >
              <:actions>
                <.close_button label="Dismiss message" phx-click="dismiss_announcement" />
              </:actions>
            </.alert>

            <%= if @page in ["overview", "orders"] do %>
              <div :if={@page == "overview"} class="space-y-5">
                <div class="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
                  <.metric
                    label="Total revenue"
                    value="$48,294"
                    change="+12.8%"
                    note="vs. last month"
                    path="M12 3v18 M17 7c0-2-2-3-5-3S7 5 7 7s2 3 5 4 5 2 5 4-2 4-5 4-5-2-5-4"
                  />
                  <.metric
                    label="Orders"
                    value={to_string(length(@orders) + 1239)}
                    change="+8.2%"
                    note="vs. last month"
                    path="M4 5h16v14H4z M8 3v4 M16 3v4 M4 9h16"
                  />
                  <.metric
                    label="Customers"
                    value="2,386"
                    change="+6.4%"
                    note="vs. last month"
                    path="M16 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2 M10 11a4 4 0 1 0 0-8 4 4 0 0 0 0 8z"
                  />
                  <.metric
                    label="Conversion rate"
                    value="3.24%"
                    change="+0.6%"
                    note="vs. last month"
                    path="M4 17l5-5 4 4 7-8 M15 8h5v5"
                  />
                </div>

                <div class="grid gap-5 xl:grid-cols-[minmax(0,1.8fr)_minmax(280px,1fr)]">
                  <.card class="min-w-0 border border-border shadow-none">
                    <:content>
                      <div class="mb-5 flex flex-wrap items-start justify-between gap-3">
                        <div>
                          <p class="m-0 text-base font-medium">Revenue overview</p><p class="mt-1 mb-0 text-sm text-muted">
                            Illustrative sales trend for the selected period
                          </p>
                        </div>
                        <div
                          role="group"
                          aria-label="Revenue period"
                          class="flex rounded-md bg-surface-secondary p-1"
                        >
                          <button
                            :for={period <- ["7 days", "30 days", "90 days"]}
                            type="button"
                            phx-click="period"
                            phx-value-value={period}
                            aria-pressed={to_string(@period == period)}
                            class={[
                              "rounded-lg px-2.5 py-1.5 text-xs font-medium",
                              if(@period == period,
                                do: "bg-surface text-foreground",
                                else: "text-muted"
                              )
                            ]}
                          >{period}</button>
                        </div>
                      </div>
                      <div class="mb-4 flex items-baseline gap-3">
                        <span class="text-[28px] font-medium tracking-tight">$48,294.00</span><.chip
                          size="sm"
                          color="success"
                          variant="soft"
                        >
                          +12.8%
                        </.chip>
                      </div>
                      <div
                        class="relative h-52"
                        role="img"
                        aria-label={"Revenue trend for the last #{@period}"}
                      >
                        <div class="absolute inset-0 flex flex-col justify-between text-xs text-muted">
                          <div class="border-b border-dashed border-border pb-1">$50k</div><div class="border-b border-dashed border-border pb-1">
                            $35k
                          </div><div class="border-b border-dashed border-border pb-1">$20k</div><div class="border-b border-dashed border-border pb-1">
                            $5k
                          </div>
                        </div>
                        <div class="absolute inset-y-0 right-0 left-11 flex items-end justify-between gap-2 pt-1">
                          <div
                            :for={{height, index} <- Enum.with_index(Catalog.chart(@period))}
                            class={[
                              "w-full max-w-8 rounded-t-md transition-all",
                              chart_class(height),
                              if(index == 11, do: "bg-[#d0d6e0]", else: "bg-[#383b3f]")
                            ]}
                          >
                          </div>
                        </div>
                      </div>
                      <div class="mt-3 flex justify-between pl-11 text-xs text-muted">
                        <span :for={label <- chart_labels(@period)}>{label}</span>
                      </div>
                    </:content>
                  </.card>

                  <.card class="border border-border shadow-none">
                    <:content>
                      <div class="mb-5">
                        <p class="m-0 text-base font-medium">Sales by category</p><p class="mt-1 mb-0 text-sm text-muted">
                          Where your revenue comes from
                        </p>
                      </div>
                      <div class="space-y-5">
                        <.progress_bar label="Accessories" value={48} value_text="48%" />
                        <.progress_bar
                          label="Home & living"
                          value={32}
                          value_text="32%"
                          color="success"
                        />
                        <.progress_bar label="Stationery" value={14} value_text="14%" color="warning" />
                        <.progress_bar label="Other" value={6} value_text="6%" color="default" />
                      </div>
                      <div class="mt-7 rounded-xl bg-surface-secondary p-4">
                        <p class="m-0 text-sm font-medium">A strong month so far</p><p class="mt-1 mb-0 text-xs leading-5 text-muted">
                          Accessories are your top-performing category.
                        </p>
                      </div>
                    </:content>
                  </.card>
                </div>
              </div>

              <div class={if @page == "overview", do: "mt-5"}>
                <.orders_panel
                  orders={@visible_orders}
                  count={length(@filtered_orders)}
                  page={@current_page}
                  total_pages={@total_pages}
                  query={@query}
                  status={@status}
                  selected={@selected_orders}
                  sort_by={@sort_by}
                  sort_direction={@sort_direction}
                  compact={@page == "overview"}
                />
              </div>
            <% end %>

            <%= if @page == "customers" do %>
              <.live_component
                module={OlisAdminWeb.CustomerDirectory}
                id="customers"
                orders={@orders}
              />
            <% end %>

            <%= if @page == "products" do %>
              <.card class="border border-border shadow-none">
                <:content>
                  <div class="mb-5 flex flex-wrap items-start justify-between gap-4">
                    <div>
                      <p class="m-0 text-base font-medium">Products</p><p class="mt-1 mb-0 text-sm text-muted">
                        Search your catalog and update available stock.
                      </p>
                    </div>
                    <form phx-change="filter_products" class="w-full sm:w-60">
                      <.search_field
                        id="product-search"
                        name="query"
                        value={@product_query}
                        aria-label="Search products"
                        placeholder="Search name, category or SKU"
                        full_width
                      />
                    </form>
                  </div>
                  <div class="divide-y divide-border">
                    <div
                      :for={product <- Catalog.search_products(@products, @product_query)}
                      class="flex flex-wrap items-center gap-4 py-4 first:pt-0 last:pb-0"
                    >
                      <div class="grid size-12 place-items-center rounded-xl bg-default text-base font-medium text-default-foreground">
                        {product.initial}
                      </div>
                      <div class="min-w-32 flex-1">
                        <p class="m-0 text-sm font-medium">{product.name}</p><p class="m-0 text-xs text-muted">
                          {product.category} · {product.id}
                        </p>
                      </div>
                      <div class="w-24">
                        <p class="m-0 text-xs text-muted">Inventory</p><p class="m-0 text-sm font-medium">
                          {product.stock} in stock
                        </p>
                      </div>
                      <div class="w-20 text-right">
                        <p class="m-0 text-xs text-muted">Revenue</p><p class="m-0 text-sm font-medium">
                          {product.revenue}
                        </p>
                      </div>
                      <.chip
                        size="sm"
                        color={if product.stock < 20, do: "warning", else: "success"}
                        variant="soft"
                      >
                        {cond do
                          product.stock == 0 -> "Out of stock"
                          product.stock < 20 -> "Low stock"
                          true -> "Active"
                        end}
                      </.chip>
                      <.button
                        variant="outline"
                        size="sm"
                        phx-click="edit_inventory"
                        phx-value-product={product.id}
                        aria-label={"Edit inventory for #{product.name}"}
                      >
                        Edit stock
                      </.button>
                    </div>
                    <p
                      :if={Catalog.search_products(@products, @product_query) == []}
                      class="py-6 text-sm text-muted"
                    >
                      No products match your search.
                    </p>
                  </div>
                  <p class="mt-4 mb-0 text-xs text-muted">
                    Inventory changes last for this demo session.
                  </p>
                </:content>
              </.card>
            <% end %>

            <%= if @page == "settings" do %>
              <div class="grid gap-5 xl:grid-cols-[minmax(0,1.5fr)_minmax(260px,1fr)]">
                <.card class="border border-border shadow-none">
                  <:content>
                    <p class="m-0 text-base font-medium">Store details</p><p class="mt-1 mb-5 text-sm text-muted">
                      Manage the details shown to your customers.
                    </p>
                    <form phx-change="edit_settings" phx-submit="save_settings" class="space-y-4">
                      <.text_field
                        id="store-name"
                        name="store[name]"
                        label="Store name"
                        value={@settings_form["name"]}
                        required
                      />
                      <.text_field
                        id="store-email"
                        name="store[email]"
                        label="Contact email"
                        type="email"
                        value={@settings_form["email"]}
                        required
                      />
                      <.button type="submit">Save changes</.button>
                    </form>
                  </:content>
                </.card>
                <.card class="border border-border shadow-none">
                  <:content>
                    <p class="m-0 text-base font-medium">Notifications</p><p class="mt-1 mb-5 text-sm text-muted">
                      Choose how your workspace keeps you informed.
                    </p>
                    <form phx-change="notifications">
                      <input type="hidden" name="notifications" value="false" />
                      <.switch
                        id="notification-setting"
                        name="notifications"
                        checked={@notifications}
                        description="Get an update when an order is placed."
                      >
                        Order updates
                      </.switch>
                    </form>
                  </:content>
                </.card>
              </div>
            <% end %>
            <.component_kit :if={@page == "components"} page={@kit_page} />
            <footer class="mt-10 border-t border-border pt-5 text-xs text-muted">
              Northstar is a sample workspace · Built with OlisUI
            </footer>
          </main>
        </div>
      </div>

      <.modal
        :if={@editing_product}
        id="inventory-modal"
        title={"Edit #{@editing_product.name} stock"}
        description={"Update available units for #{@editing_product.id}."}
        open={true}
        on_open_change="close_inventory"
        show_close={false}
      >
        <form phx-change="validate_inventory" phx-submit="save_inventory" class="space-y-4">
          <.text_field
            id="inventory-stock"
            name="inventory[stock]"
            label="Available units"
            type="number"
            min="0"
            max="1000000"
            step="1"
            value={@stock_input}
            errors={if @stock_error, do: [@stock_error], else: []}
            required
          />
          <div class="flex flex-wrap justify-end gap-2 pt-2">
            <.button type="button" variant="secondary" phx-click="close_inventory">Cancel</.button>
            <.button type="submit">Save inventory</.button>
          </div>
        </form>
      </.modal>

      <.modal
        id="new-order-modal"
        title="Create order"
        description="Add a sample order to the workspace."
        open={@order_modal_open}
        on_open_change="order_modal"
        show_close={false}
      >
        <form
          id="new-order-form"
          phx-change="validate_order"
          phx-submit="create_order"
          class="space-y-4"
        >
          <.alert :if={@form_error} status="danger" title={@form_error} />
          <.text_field
            id="order-name"
            name="order[name]"
            label="Customer name"
            value={@order_form["name"]}
            required
          />
          <.text_field
            id="order-email"
            name="order[email]"
            label="Email address"
            type="email"
            value={@order_form["email"]}
            required
          />
          <div class="grid gap-4 sm:grid-cols-2">
            <div class="space-y-1">
              <.label for="order-product">Product</.label><.select
                id="order-product"
                name="order[product]"
                value={@order_form["product"]}
                options={Enum.map(@products, & &1.name)}
              />
            </div>
            <.text_field
              id="order-amount"
              name="order[amount]"
              label="Amount (USD)"
              type="number"
              value={@order_form["amount"]}
              min="0.01"
              step="0.01"
              required
            />
          </div>
          <div class="flex justify-end gap-2 pt-2">
            <.button variant="secondary" phx-click="order_modal" phx-value-open="false">Cancel</.button><.button type="submit">Create order</.button>
          </div>
        </form>
      </.modal>
    </div>
    """
  end

  defp page_title("overview"), do: "Overview"
  defp page_title("orders"), do: "Orders"
  defp page_title("customers"), do: "Customers"
  defp page_title("products"), do: "Products"
  defp page_title("settings"), do: "Settings"
  defp page_title("components"), do: "Workspace UI kit"

  defp page_description("overview"), do: "Your store at a glance."
  defp page_description("orders"), do: "Manage and track your customer orders."
  defp page_description("customers"), do: "Get to know the people shopping with you."
  defp page_description("products"), do: "Keep an eye on your catalog and inventory."
  defp page_description("settings"), do: "Manage your workspace preferences."
  defp page_description("components"), do: "Explore the controls used throughout your workspace."

  attr(:label, :string, required: true)
  attr(:value, :string, required: true)
  attr(:change, :string, required: true)
  attr(:note, :string, required: true)
  attr(:path, :string, required: true)

  defp metric(assigns) do
    ~H"""
    <.card class="border border-border shadow-none">
      <:content>
        <div class="flex items-center justify-between gap-2">
          <p class="m-0 text-sm font-medium text-muted">{@label}</p>
          <.icon class="size-4 text-muted" path={@path} />
        </div>
        <p class="mt-3 mb-1 text-2xl font-medium tracking-tight">{@value}</p>
        <p class="m-0 text-xs text-muted">
          <span class="font-medium text-success">{@change}</span> {@note}
        </p>
      </:content>
    </.card>
    """
  end

  attr(:orders, :list, required: true)
  attr(:count, :integer, required: true)
  attr(:page, :integer, required: true)
  attr(:total_pages, :integer, required: true)
  attr(:query, :string, required: true)
  attr(:status, :string, required: true)
  attr(:selected, :list, required: true)
  attr(:sort_by, :string, required: true)
  attr(:sort_direction, :string, required: true)
  attr(:compact, :boolean, default: false)

  defp orders_panel(assigns) do
    ~H"""
    <.card class="border border-border shadow-none">
      <:content>
        <div class="flex flex-wrap items-start justify-between gap-4">
          <div>
            <h2 class="m-0 text-base font-medium">
              {if @compact, do: "Recent orders", else: "All orders"}
            </h2>
            <p class="mt-1 mb-0 text-sm text-muted">{@count} orders match your filters.</p>
          </div>
          <form phx-change="filter" class="w-full sm:w-60">
            <.search_field
              id="order-search"
              name="query"
              value={@query}
              aria-label="Search orders"
              placeholder="Search orders..."
            />
          </form>
        </div>
        <div class="mt-5 mb-4 flex flex-wrap gap-1" aria-label="Filter by payment status">
          <button
            :for={status <- ~w(All Paid Pending Refunded)}
            type="button"
            phx-click="status"
            phx-value-value={status}
            aria-pressed={to_string(@status == status)}
            class={[
              "rounded-lg px-3 py-1.5 text-sm font-medium",
              if(@status == status,
                do: "bg-default text-foreground",
                else: "text-muted hover:text-foreground"
              )
            ]}
          >{status}</button>
        </div>
        <div :if={@selected != []} class="mb-4 flex flex-wrap items-center gap-3">
          <span class="text-sm text-muted">{length(@selected)} selected</span>
          <.button variant="outline" size="sm" phx-click="ship_orders">Mark as shipped</.button>
          <span class="text-xs text-muted">Only paid, unshipped orders are eligible.</span>
        </div>
        <.data_table
          id="orders-table"
          label="Orders"
          rows={@orders}
          row_id={& &1.id}
          row_label={& &1.name}
          selection_mode="multiple"
          selected_keys={@selected}
          on_selection_change="select_orders"
          sort_event="sort"
          sort_by={@sort_by}
          sort_direction={@sort_direction}
        >
          <:col :let={order} label="Order" row_header>
            <span class="font-medium">{order.id}</span>
          </:col>
          <:col :let={order} label="Customer" sort_key="customer">
            <div>
              <span class="font-medium">{order.name}</span><p class="m-0 text-xs text-muted">
                {order.email}
              </p>
            </div>
          </:col>
          <:col :let={order} label="Date" sort_key="date">{order.date}</:col>
          <:col :let={order} label="Payment">
            <.chip color={Catalog.status_color(order.status)} variant="soft" size="sm">
              {order.status}
            </.chip>
          </:col>
          <:col :let={order} label="Fulfillment">{order.fulfillment}</:col>
          <:col :let={order} label="Total" sort_key="amount">
            <span class="font-medium">{Catalog.format_money(order.amount)}</span>
          </:col>
          <:empty>No orders match these filters.</:empty>
          <:footer>
            <.pagination page={@page} total_pages={@total_pages} on_change="change_page" size="sm">
              <:summary>Page {@page} of {@total_pages}</:summary>
            </.pagination>
          </:footer>
        </.data_table>
      </:content>
    </.card>
    """
  end
end
