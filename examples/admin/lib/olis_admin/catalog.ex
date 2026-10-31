defmodule OlisAdmin.Catalog do
  @moduledoc "Sample commerce data for the local dashboard."

  def orders do
    [
      %{
        id: "NS-3210",
        name: "Olivia Martin",
        email: "olivia@example.com",
        date: "Oct 30, 2026",
        sort_date: ~D[2026-10-30],
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
        sort_date: ~D[2026-10-30],
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
        sort_date: ~D[2026-10-29],
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
        sort_date: ~D[2026-10-29],
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
        sort_date: ~D[2026-10-28],
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
        sort_date: ~D[2026-10-28],
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
        sort_date: ~D[2026-10-27],
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
        sort_date: ~D[2026-10-27],
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
        id: "NS-TOTE",
        name: "Everyday Tote",
        category: "Accessories",
        stock: 124,
        sold: 342,
        revenue: "$43,776",
        initial: "T"
      },
      %{
        id: "NS-THROW",
        name: "Linen Throw",
        category: "Home",
        stock: 48,
        sold: 209,
        revenue: "$33,858",
        initial: "L"
      },
      %{
        id: "NS-MUG",
        name: "Studio Mug Set",
        category: "Home",
        stock: 16,
        sold: 186,
        revenue: "$15,624",
        initial: "M"
      },
      %{
        id: "NS-BOTTLE",
        name: "Travel Bottle",
        category: "Accessories",
        stock: 82,
        sold: 154,
        revenue: "$7,392",
        initial: "B"
      }
    ]
  end

  @doc "Filters products by name, category, or SKU, ignoring case and outer whitespace."
  def search_products(products, query) do
    query = query |> String.trim() |> String.downcase()

    Enum.filter(products, fn product ->
      query == "" or
        Enum.any?([product.id, product.name, product.category], fn value ->
          value |> String.downcase() |> String.contains?(query)
        end)
    end)
  end

  @doc "Updates one product's stock in the current workspace data."
  def update_stock(products, product_id, stock) when is_integer(stock) and stock >= 0 do
    if Enum.any?(products, &(&1.id == product_id)) do
      {:ok,
       Enum.map(products, fn product ->
         if product.id == product_id do
           %{product | stock: stock}
         else
           product
         end
       end)}
    else
      :error
    end
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
