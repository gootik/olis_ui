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

  test "product search accepts names, categories, and SKUs without regard to case" do
    products = Catalog.products()
    product = Enum.find(products, &(&1.name == "Studio Mug Set"))

    assert Catalog.search_products(products, "  STUDIO MUG  ") == [product]
    assert Catalog.search_products(products, String.downcase(product.id)) == [product]
    assert product in Catalog.search_products(products, "home")
    assert Catalog.search_products(products, "no such product") == []
  end

  test "stock updates affect only the requested product" do
    products = Catalog.products()
    [product | others] = products

    assert {:ok, [updated | unchanged]} = Catalog.update_stock(products, product.id, 0)
    assert updated.stock == 0
    assert unchanged == others
    assert :error = Catalog.update_stock(products, "unknown", 1)
  end
end
