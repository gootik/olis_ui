defmodule OlisAdmin.CatalogTest do
  use ExUnit.Case, async: true

  alias OlisAdmin.Catalog

  test "orders have unique identifiers and valid totals" do
    orders = Catalog.orders()
    ids = Enum.map(orders, & &1.id)

    assert length(ids) == length(Enum.uniq(ids))
    assert Enum.all?(orders, &(&1.amount > 0))
    assert Catalog.format_money(128) == "$128.00"
  end

  test "reporting periods provide chart data" do
    for period <- ["7 days", "30 days", "90 days"] do
      assert length(Catalog.chart(period)) == 12
      assert Enum.all?(Catalog.chart(period), &(&1 in 0..100))
    end
  end
end
