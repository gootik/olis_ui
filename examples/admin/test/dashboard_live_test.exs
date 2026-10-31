defmodule OlisAdminWeb.DashboardLiveTest do
  use ExUnit.Case, async: true

  alias OlisAdminWeb.DashboardLive
  import Phoenix.LiveViewTest, only: [rendered_to_string: 1]

  test "payment filters send a distinct value and update the orders" do
    {:ok, socket} = DashboardLive.mount(%{}, %{}, %Phoenix.LiveView.Socket{})
    html = socket.assigns |> DashboardLive.render() |> rendered_to_string()

    assert html =~ ~s(phx-value-status="Paid")
    assert html =~ ~s(phx-value-status="Pending")
    refute html =~ "Revenue overview"
    refute html =~ "Revenue period"

    for status <- ~w(Paid Pending Refunded) do
      {:noreply, filtered} = DashboardLive.handle_event("status", %{"status" => status}, socket)
      assert filtered.assigns.status == status
      assert filtered.assigns.filtered_orders != []
      assert Enum.all?(filtered.assigns.visible_orders, &(&1.status == status))
    end
  end

  test "order links open a blurred drawer with the selected order" do
    {:ok, socket} = DashboardLive.mount(%{}, %{}, %Phoenix.LiveView.Socket{})
    order = hd(socket.assigns.visible_orders)
    html = socket.assigns |> DashboardLive.render() |> rendered_to_string()

    assert html =~ ~s(phx-click="show_order")
    assert html =~ ~s(phx-value-order_id="#{order.id}")
    assert html =~ ~s(data-backdrop="blur")
    assert html =~ ~s(data-open="false")

    {:noreply, opened} =
      DashboardLive.handle_event("show_order", %{"order_id" => order.id}, socket)

    assert opened.assigns.order_drawer_open
    assert opened.assigns.selected_order == order
    html = opened.assigns |> DashboardLive.render() |> rendered_to_string()
    assert html =~ ~s(data-open="true")
    assert html =~ "Order #{order.id}"
    assert html =~ order.name
    assert html =~ order.email
    assert html =~ order.product
    assert html =~ order.fulfillment
    assert html =~ OlisAdmin.Catalog.format_money(order.amount)

    {:noreply, closed} = DashboardLive.handle_event("order_drawer", %{"open" => "false"}, opened)
    refute closed.assigns.order_drawer_open
    assert closed.assigns.selected_order == order

    assert {:noreply, ^socket} =
             DashboardLive.handle_event("show_order", %{"order_id" => "missing"}, socket)
  end

  test "activity sheet reflects pending payments and low inventory" do
    {:ok, socket} = DashboardLive.mount(%{}, %{}, %Phoenix.LiveView.Socket{})
    html = socket.assigns |> DashboardLive.render() |> rendered_to_string()

    assert html =~ ~s(id="activity-sheet")
    assert html =~ "2 pending payments"
    assert html =~ "1 low-stock product"
    assert html =~ ~s(id="admin-notifications")

    clear =
      Phoenix.Component.assign(socket,
        orders: Enum.map(socket.assigns.orders, &Map.put(&1, :status, "Paid")),
        products: Enum.map(socket.assigns.products, &Map.put(&1, :stock, 20))
      )

    assert clear.assigns |> DashboardLive.render() |> rendered_to_string() =~ "All caught up"

    {:noreply, opened} = DashboardLive.handle_event("open_activity", %{}, socket)
    assert opened.assigns.activity_open
    {:noreply, orders} = DashboardLive.handle_event("review_pending", %{}, opened)
    assert orders.assigns.page == "orders"
    assert orders.assigns.status == "Pending"
    refute orders.assigns.activity_open
    assert Enum.all?(orders.assigns.filtered_orders, &(&1.status == "Pending"))

    {:noreply, products} = DashboardLive.handle_event("review_inventory", %{}, opened)
    assert products.assigns.page == "products"
    refute products.assigns.activity_open

    {:noreply, closed} =
      DashboardLive.handle_event("activity_sheet", %{"open" => "false"}, opened)

    refute closed.assigns.activity_open
  end

  test "component examples keep their state in LiveView" do
    {:ok, socket} = DashboardLive.mount(%{}, %{}, %Phoenix.LiveView.Socket{})
    {:noreply, socket} = DashboardLive.handle_event("navigate", %{"page" => "components"}, socket)
    {:noreply, socket} = DashboardLive.handle_event("kit_period", %{"value" => "Month"}, socket)
    {:noreply, socket} = DashboardLive.handle_event("kit_search", %{"query" => "retail"}, socket)

    {:noreply, socket} =
      DashboardLive.handle_event("kit_note_save", %{"note" => "Ship today"}, socket)

    {:noreply, socket} =
      DashboardLive.handle_event(
        "kit_project",
        %{"project_name" => "Spring", "project_plan" => "priority"},
        socket
      )

    {:noreply, socket} =
      DashboardLive.handle_event("kit_popover_alerts", %{"alerts" => "true"}, socket)

    {:noreply, socket} =
      DashboardLive.handle_event(
        "kit_contact_submit",
        %{"contact" => %{"email" => "team@example.com"}},
        socket
      )

    {:noreply, socket} = DashboardLive.handle_event("kit_dismiss_notice", %{}, socket)

    {:noreply, socket} =
      DashboardLive.handle_event(
        "kit_preferences",
        %{"delivery" => "daily", "threshold" => "55", "quantity" => "4"},
        socket
      )

    {:noreply, socket} =
      DashboardLive.handle_event(
        "kit_team_preferences",
        %{"reports" => ["inventory"], "mobile_updates" => "true", "priority" => "normal"},
        socket
      )

    {:noreply, socket} =
      DashboardLive.handle_event(
        "kit_catalog",
        %{"country" => "ca", "category" => "home", "brand" => "#D43A2C", "color" => "#6366F1"},
        socket
      )

    html = socket.assigns |> DashboardLive.render() |> rendered_to_string()
    assert html =~ "Selected view: Month"
    assert html =~ "Retail Operations"
    refute html =~ ">Creative Team</li>"
    assert html =~ "Saved in this example: Ship today"
    assert html =~ "Contact details look good."
    refute html =~ "Your workspace is ready."
    assert socket.assigns.kit_example.threshold == 55
    assert socket.assigns.kit_example.reports == ["inventory"]
    assert socket.assigns.kit_example.country == "ca"
    assert socket.assigns.kit_example.project_name == "Spring"
    assert socket.assigns.kit_example.project_plan == "priority"
    assert socket.assigns.kit_example.popover_alerts
  end

  test "successful inventory and shipping actions send notifications" do
    socket = %Phoenix.LiveView.Socket{private: %{live_temp: %{}}}
    {:ok, socket} = DashboardLive.mount(%{}, %{}, socket)
    product = hd(socket.assigns.products)

    {:noreply, editing} =
      DashboardLive.handle_event("edit_inventory", %{"product" => product.id}, socket)

    {:noreply, saved} =
      DashboardLive.handle_event("save_inventory", %{"inventory" => %{"stock" => "7"}}, editing)

    assert Enum.find(saved.assigns.products, &(&1.id == product.id)).stock == 7

    assert [%{title: "Inventory updated", variant: "success"}] = saved.assigns.toasts

    [toast] = saved.assigns.toasts

    {:noreply, dismissed} =
      DashboardLive.handle_event("dismiss_toast", %{"id" => toast.id}, saved)

    assert dismissed.assigns.toasts == []

    order =
      Enum.find(socket.assigns.orders, &(&1.status == "Paid" && &1.fulfillment == "Processing"))

    selected = Phoenix.Component.assign(socket, :selected_orders, [order.id])
    {:noreply, shipped} = DashboardLive.handle_event("ship_orders", %{}, selected)
    assert Enum.find(shipped.assigns.orders, &(&1.id == order.id)).fulfillment == "Shipped"
    assert [%{variant: "success"}] = shipped.assigns.toasts

    {:noreply, no_change} = DashboardLive.handle_event("ship_orders", %{}, socket)
    assert no_change.assigns.announcement_status == "warning"
    assert no_change.assigns.announcement =~ "No selected orders"
  end
end
