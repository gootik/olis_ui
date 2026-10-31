defmodule OlisAdmin.Catalog do
  @moduledoc "Sample commerce data for the local dashboard."

  def orders do
    [
      %{
        id: "NS-3210",
        name: "Olivia Martin",
        email: "olivia@example.com",
        date: "Oct 30, 2026",
        product: "Everyday Tote",
        amount: 128.00,
        status: "Paid",
        fulfillment: "Shipped"
      },
      %{
        id: "NS-3209",
        name: "Jackson Lee",
        email: "jackson@example.com",
        date: "Oct 30, 2026",
        product: "Studio Mug Set",
        amount: 84.00,
        status: "Paid",
        fulfillment: "Processing"
      },
      %{
        id: "NS-3208",
        name: "Isabella Nguyen",
        email: "isabella@example.com",
        date: "Oct 29, 2026",
        product: "Linen Throw",
        amount: 162.00,
        status: "Pending",
        fulfillment: "Unfulfilled"
      },
      %{
        id: "NS-3207",
        name: "William Kim",
        email: "william@example.com",
        date: "Oct 29, 2026",
        product: "Travel Bottle",
        amount: 48.00,
        status: "Paid",
        fulfillment: "Shipped"
      },
      %{
        id: "NS-3206",
        name: "Sofia Davis",
        email: "sofia@example.com",
        date: "Oct 28, 2026",
        product: "Everyday Tote",
        amount: 128.00,
        status: "Refunded",
        fulfillment: "Returned"
      },
      %{
        id: "NS-3205",
        name: "Noah Robinson",
        email: "noah@example.com",
        date: "Oct 28, 2026",
        product: "Linen Throw",
        amount: 162.00,
        status: "Paid",
        fulfillment: "Shipped"
      },
      %{
        id: "NS-3204",
        name: "Mia Chen",
        email: "mia@example.com",
        date: "Oct 27, 2026",
        product: "Ceramic Pour Over",
        amount: 72.00,
        status: "Paid",
        fulfillment: "Processing"
      },
      %{
        id: "NS-3203",
        name: "Liam Wilson",
        email: "liam@example.com",
        date: "Oct 27, 2026",
        product: "Travel Bottle",
        amount: 48.00,
        status: "Pending",
        fulfillment: "Unfulfilled"
      }
    ]
  end

  def products do
    [
      %{
        name: "Everyday Tote",
        category: "Accessories",
        stock: 124,
        sold: 342,
        revenue: "$43,776",
        color: "bg-[#e8ded1]",
        initial: "T"
      },
      %{
        name: "Linen Throw",
        category: "Home",
        stock: 48,
        sold: 209,
        revenue: "$33,858",
        color: "bg-[#dfe5d8]",
        initial: "L"
      },
      %{
        name: "Studio Mug Set",
        category: "Home",
        stock: 16,
        sold: 186,
        revenue: "$15,624",
        color: "bg-[#e4ddda]",
        initial: "M"
      },
      %{
        name: "Travel Bottle",
        category: "Accessories",
        stock: 82,
        sold: 154,
        revenue: "$7,392",
        color: "bg-[#dce6ea]",
        initial: "B"
      }
    ]
  end

  def chart("7 days") do
    [25, 38, 30, 52, 46, 63, 80, 71, 90, 78, 98, 88]
  end

  def chart("90 days") do
    [32, 25, 42, 37, 45, 57, 48, 61, 68, 75, 89, 96]
  end

  def chart(_) do
    [27, 35, 31, 46, 42, 57, 52, 68, 62, 77, 72, 90]
  end

  def format_money(amount) do
    :erlang.float_to_binary(amount / 1, decimals: 2)
    |> then(&("$" <> &1))
  end

  def status_color("Paid"), do: "success"
  def status_color("Pending"), do: "warning"
  def status_color("Refunded"), do: "default"
  def status_color(_), do: "default"
end
