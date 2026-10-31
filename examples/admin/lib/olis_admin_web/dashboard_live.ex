defmodule OlisAdminWeb.DashboardLive do
  use Phoenix.LiveView, layout: false

  import OlisUI.Button
  import OlisUI.Checks
  import OlisUI.Controls
  import OlisUI.Display
  import OlisUI.Feedback
  import OlisUI.Floating
  import OlisUI.Forms
  import OlisUI.Overlays
  import OlisUI.Pagination
  import OlisUI.Progress
  import OlisUI.Select
  import OlisUI.Table
  import OlisUI.Toast
  import OlisUI.Typography
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
        kit_example: %{
          period: "Week",
          contact_email: "",
          contact_submitted: false,
          contact_price: "12",
          contact_notes: "",
          contact_code: "",
          project_name: "Autumn launch",
          project_plan: "standard",
          popover_alerts: false,
          query: "",
          notice_visible: true,
          note: "Pack with care",
          saved_note: nil,
          digest: true,
          delivery: "weekly",
          threshold: 40,
          quantity: "10",
          reports: ["sales"],
          email_updates: true,
          mobile_updates: false,
          priority: "normal",
          country: "",
          category: "",
          brand: "#D43A2C",
          color: "#D43A2C"
        },
        kit_tab: "activity",
        kit_channels: ["online"],
        kit_workspace: ["northstar"],
        kit_alignment: ["left"],
        kit_pinned: false,
        kit_overlays: %{},
        toasts: [],
        kit_saved_open: false,
        kit_details_open: false,
        kit_disclosures: [],
        query: "",
        status: "All",
        sort_by: "date",
        sort_direction: "descending",
        selected_orders: [],
        selected_order: nil,
        order_drawer_open: false,
        activity_open: false,
        current_page: 1,
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
        dark_mode: false
      )
      |> refresh_orders()

    {:ok, socket}
  end

  @impl true
  def handle_event("navigate", %{"page" => page}, socket) when page in @pages do
    {:noreply, assign(socket, page: page, announcement: nil)}
  end

  def handle_event("open_activity", _, socket),
    do: {:noreply, assign(socket, :activity_open, true)}

  def handle_event("activity_sheet", %{"open" => "false"}, socket),
    do: {:noreply, assign(socket, :activity_open, false)}

  def handle_event("activity_sheet", _, socket), do: {:noreply, socket}

  def handle_event("review_pending", _, socket) do
    {:noreply,
     socket
     |> assign(
       page: "orders",
       status: "Pending",
       query: "",
       current_page: 1,
       activity_open: false
     )
     |> refresh_orders()}
  end

  def handle_event("review_inventory", _, socket),
    do: {:noreply, assign(socket, page: "products", product_query: "", activity_open: false)}

  def handle_event("kit_period", %{"value" => value}, socket),
    do: {:noreply, update(socket, :kit_example, &Map.put(&1, :period, value))}

  def handle_event("kit_contact_change", %{"contact" => contact}, socket),
    do: {:noreply, update(socket, :kit_example, &update_kit_contact(&1, contact))}

  def handle_event("kit_contact_submit", %{"contact" => contact}, socket),
    do:
      {:noreply,
       update(
         socket,
         :kit_example,
         &(update_kit_contact(&1, contact) |> Map.put(:contact_submitted, true))
       )}

  def handle_event("kit_project", %{"project_name" => name, "project_plan" => plan}, socket),
    do:
      {:noreply,
       update(socket, :kit_example, &Map.merge(&1, %{project_name: name, project_plan: plan}))}

  def handle_event("kit_popover_alerts", params, socket),
    do:
      {:noreply,
       update(socket, :kit_example, &Map.put(&1, :popover_alerts, Map.has_key?(params, "alerts")))}

  def handle_event("kit_search", %{"query" => query}, socket),
    do: {:noreply, update(socket, :kit_example, &Map.put(&1, :query, query))}

  def handle_event("kit_dismiss_notice", _, socket),
    do: {:noreply, update(socket, :kit_example, &Map.put(&1, :notice_visible, false))}

  def handle_event("kit_note_change", %{"note" => note}, socket),
    do: {:noreply, update(socket, :kit_example, &Map.put(&1, :note, note))}

  def handle_event("kit_note_save", %{"note" => note}, socket),
    do: {:noreply, update(socket, :kit_example, &Map.merge(&1, %{note: note, saved_note: note}))}

  def handle_event("kit_preferences", params, socket) do
    values = %{
      digest: Map.has_key?(params, "digest"),
      delivery: params["delivery"],
      threshold: String.to_integer(params["threshold"]),
      quantity: params["quantity"]
    }

    {:noreply, update(socket, :kit_example, &Map.merge(&1, values))}
  end

  def handle_event("kit_team_preferences", params, socket) do
    values = %{
      reports: Map.get(params, "reports", []),
      email_updates: Map.has_key?(params, "email_updates"),
      mobile_updates: Map.has_key?(params, "mobile_updates"),
      priority: params["priority"]
    }

    {:noreply, update(socket, :kit_example, &Map.merge(&1, values))}
  end

  def handle_event("kit_catalog", params, socket) do
    values = %{
      country: params["country"],
      category: params["category"],
      brand: params["brand"],
      color: params["color"]
    }

    {:noreply, update(socket, :kit_example, &Map.merge(&1, values))}
  end

  def handle_event("kit_overlay", %{"id" => id, "open" => open}, socket),
    do: {:noreply, update(socket, :kit_overlays, &Map.put(&1, id, open == "true"))}

  def handle_event("kit_disclosure", %{"key" => key, "expanded" => expanded}, socket) do
    open = expanded == "true"

    case key do
      "kit-saved" -> {:noreply, assign(socket, :kit_saved_open, open)}
      "kit-details" -> {:noreply, assign(socket, :kit_details_open, open)}
      _ -> {:noreply, assign(socket, :kit_disclosures, if(open, do: [key], else: []))}
    end
  end

  def handle_event("kit_alignment", %{"keys" => keys}, socket),
    do: {:noreply, assign(socket, :kit_alignment, Jason.decode!(keys))}

  def handle_event("kit_pin", _, socket),
    do: {:noreply, update(socket, :kit_pinned, &(!&1))}

  def handle_event("kit_channels", %{"keys" => keys}, socket),
    do: {:noreply, assign(socket, :kit_channels, Jason.decode!(keys))}

  def handle_event("kit_workspace", %{"keys" => keys}, socket),
    do: {:noreply, assign(socket, :kit_workspace, Jason.decode!(keys))}

  def handle_event("kit_tab", %{"key" => key}, socket),
    do: {:noreply, assign(socket, :kit_tab, key)}

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
       socket
       |> assign(products: products, editing_product: nil, stock_error: nil, announcement: nil)
       |> add_toast(%{
         title: "Inventory updated",
         description: "#{name} has #{stock} units available.",
         variant: "success"
       })}
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

    socket =
      socket
      |> assign(
        orders: orders,
        selected_orders: [],
        announcement: if(shipped == 0, do: message),
        announcement_status: status
      )
      |> refresh_orders()

    socket =
      if shipped > 0,
        do: add_toast(socket, %{title: message, variant: "success"}),
        else: socket

    {:noreply, socket}
  end

  def handle_event("filter", params, socket) do
    socket =
      socket
      |> assign(query: Map.get(params, "query", ""), current_page: 1)
      |> refresh_orders()

    {:noreply, socket}
  end

  def handle_event("status", %{"status" => status}, socket)
      when status in ~w(All Paid Pending Refunded) do
    {:noreply, socket |> assign(status: status, current_page: 1) |> refresh_orders()}
  end

  def handle_event("show_order", %{"order_id" => id}, socket) do
    case Enum.find(socket.assigns.orders, &(&1.id == id)) do
      nil -> {:noreply, socket}
      order -> {:noreply, assign(socket, selected_order: order, order_drawer_open: true)}
    end
  end

  def handle_event("order_drawer", %{"open" => "false"}, socket),
    do: {:noreply, assign(socket, :order_drawer_open, false)}

  def handle_event("order_drawer", _, socket), do: {:noreply, socket}

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

  def handle_event("dismiss_toast", %{"id" => id}, socket),
    do: {:noreply, update(socket, :toasts, &Enum.reject(&1, fn toast -> toast.id == id end))}

  def handle_event("kit_toast", _, socket) do
    {:noreply,
     add_toast(socket, %{
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

  defp navigation do
    [
      {"overview", "Overview", "house"},
      {"orders", "Orders", "receipt"},
      {"customers", "Customers", "persons"},
      {"products", "Products", "cube"},
      {"components", "UI kit", "layout-cells"},
      {"settings", "Settings", "gear"}
    ]
  end

  @impl true
  def render(assigns) do
    assigns =
      assign(assigns,
        pending_count: Enum.count(assigns.orders, &(&1.status == "Pending")),
        low_stock_count: Enum.count(assigns.products, &(&1.stock < 20))
      )

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
              <OlisUI.Icon.icon name={path} class="size-[18px] shrink-0" />{label}
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
                  open={Map.get(@kit_overlays, "theme-tip", false)}
                  on_open_change="kit_overlay"
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
                      <OlisUI.Icon.icon
                        name="sun"
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
                <.button variant="secondary" phx-click="open_activity">
                  Activity
                  <.badge :if={@pending_count + @low_stock_count > 0} color="warning">
                    {@pending_count + @low_stock_count}
                  </.badge>
                </.button>
                <.button variant="secondary" phx-click="export"><OlisUI.Icon.icon
                  name="arrow-down-to-line"
                  class="size-4"
                />Export orders CSV</.button>
                <.button phx-click="open_order"><OlisUI.Icon.icon name="plus" class="size-4" />New order</.button>
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
                    name="wallet"
                  />
                  <.metric
                    label="Orders"
                    value={to_string(length(@orders) + 1239)}
                    change="+8.2%"
                    note="vs. last month"
                    name="receipt"
                  />
                  <.metric
                    label="Customers"
                    value="2,386"
                    change="+6.4%"
                    note="vs. last month"
                    name="persons"
                  />
                  <.metric
                    label="Conversion rate"
                    value="3.24%"
                    change="+0.6%"
                    note="vs. last month"
                    name="chart-line"
                  />
                </div>

                <div>
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
            <.component_kit
              :if={@page == "components"}
              page={@kit_page}
              state={@kit_example}
              selected_tab={@kit_tab}
              channels={@kit_channels}
              workspace={@kit_workspace}
              alignment={@kit_alignment}
              pinned={@kit_pinned}
              saved_open={@kit_saved_open}
              details_open={@kit_details_open}
              disclosures={@kit_disclosures}
              overlays={@kit_overlays}
            />
            <footer class="mt-10 border-t border-border pt-5 text-xs text-muted">
              Northstar is a sample workspace · Built with OlisUI
            </footer>
          </main>
        </div>
      </div>

      <.toast_region id="admin-notifications" toasts={@toasts} on_dismiss="dismiss_toast" />
      <.sheet
        id="activity-sheet"
        title="Needs attention"
        description="Pending payments and products with fewer than 20 units in stock."
        placement="right"
        backdrop="blur"
        open={@activity_open}
        on_open_change="activity_sheet"
      >
        <div class="space-y-4 py-3">
          <.alert
            :if={@pending_count > 0}
            status="warning"
            title={"#{@pending_count} pending #{if @pending_count == 1, do: "payment", else: "payments"}"}
          >
            <:description>Review orders awaiting payment before fulfillment.</:description>
            <:actions>
              <.button size="sm" variant="secondary" phx-click="review_pending">Review orders</.button>
            </:actions>
          </.alert>
          <.alert
            :if={@low_stock_count > 0}
            status="warning"
            title={"#{@low_stock_count} low-stock #{if @low_stock_count == 1, do: "product", else: "products"}"}
          >
            <:description>Check inventory for products with fewer than 20 units.</:description>
            <:actions>
              <.button size="sm" variant="secondary" phx-click="review_inventory">View inventory</.button>
            </:actions>
          </.alert>
          <.alert
            :if={@pending_count == 0 && @low_stock_count == 0}
            status="success"
            title="All caught up"
          >
            No pending payments or low-stock products need attention.
          </.alert>
        </div>
      </.sheet>

      <.drawer
        id="order-details-drawer"
        title={if @selected_order, do: "Order #{@selected_order.id}", else: "Order details"}
        placement="right"
        backdrop="blur"
        open={@order_drawer_open}
        on_open_change="order_drawer"
        close_label="Close details"
      >
        <div :if={@selected_order} id="order-details" class="space-y-6 pt-4 text-foreground">
          <div>
            <p class="m-0 text-xs font-medium text-muted">Payment</p>
            <.chip
              color={Catalog.status_color(@selected_order.status)}
              variant="soft"
              size="sm"
              class="mt-2"
            >
              {@selected_order.status}
            </.chip>
          </div>
          <dl class="m-0 space-y-4">
            <div>
              <dt class="text-xs font-medium text-muted">Customer</dt><dd class="m-0 mt-1">
                {@selected_order.name}
              </dd>
            </div>
            <div>
              <dt class="text-xs font-medium text-muted">Email</dt><dd class="m-0 mt-1 break-all">
                {@selected_order.email}
              </dd>
            </div>
            <div>
              <dt class="text-xs font-medium text-muted">Date</dt><dd class="m-0 mt-1">
                {@selected_order.date}
              </dd>
            </div>
            <div>
              <dt class="text-xs font-medium text-muted">Product</dt><dd class="m-0 mt-1">
                {@selected_order.product}
              </dd>
            </div>
            <div>
              <dt class="text-xs font-medium text-muted">Fulfillment</dt><dd class="m-0 mt-1">
                {@selected_order.fulfillment}
              </dd>
            </div>
            <div>
              <dt class="text-xs font-medium text-muted">Total</dt><dd class="m-0 mt-1 font-medium">
                {Catalog.format_money(@selected_order.amount)}
              </dd>
            </div>
          </dl>
        </div>
      </.drawer>

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
                open={Map.get(@kit_overlays, "order-product", false)}
                on_open_change="kit_overlay"
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
  attr(:name, :string, required: true)

  defp metric(assigns) do
    ~H"""
    <.card class="border border-border shadow-none">
      <:content>
        <div class="flex items-center justify-between gap-2">
          <p class="m-0 text-sm font-medium text-muted">{@label}</p>
          <OlisUI.Icon.icon class="size-4 text-muted" name={@name} />
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
            phx-value-status={status}
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
            <button
              type="button"
              phx-click="show_order"
              phx-value-order_id={order.id}
              aria-label={"View order #{order.id}"}
              class="cursor-pointer font-medium text-foreground underline decoration-border underline-offset-4 hover:decoration-current focus-visible:status-focused"
            >{order.id}</button>
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

  defp add_toast(socket, attrs) do
    toast = Map.put(attrs, :id, Integer.to_string(System.unique_integer([:positive])))
    update(socket, :toasts, &[toast | &1])
  end

  defp update_kit_contact(state, contact) do
    %{
      state
      | contact_email: Map.get(contact, "email", state.contact_email),
        contact_price: Map.get(contact, "price", state.contact_price),
        contact_notes: Map.get(contact, "notes", state.contact_notes),
        contact_code: Map.get(contact, "code", state.contact_code)
    }
  end
end
