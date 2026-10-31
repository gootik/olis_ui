import { readFile } from "node:fs/promises";
import { expect, test } from "@playwright/test";

test.beforeEach(async ({ page }) => {
  await page.goto("/");
  await expect(page.locator("[data-phx-main].phx-connected")).toBeVisible();
});

test("searches products and validates inventory edits", async ({ page }) => {
  await page.getByRole("button", { name: "Products", exact: true }).first().click();
  await page.getByRole("searchbox", { name: "Search products" }).fill("mug");
  await expect(page.getByRole("main").getByText("Studio Mug Set", { exact: true })).toBeVisible();
  await expect(page.getByRole("main").getByText("Everyday Tote", { exact: true })).toHaveCount(0);

  await page.getByRole("button", { name: "Edit inventory for Studio Mug Set" }).click();
  const modal = page.getByRole("dialog", { name: "Edit Studio Mug Set stock" });
  const stock = modal.getByLabel("Available units");
  await stock.fill("-1");
  await modal.locator("form").evaluate((form) => {
    form.noValidate = true;
  });
  await modal.getByRole("button", { name: "Save inventory" }).click();
  await expect(modal.getByText("Enter a whole number between 0 and 1,000,000.")).toBeVisible();

  await stock.fill("0");
  await modal.getByRole("button", { name: "Save inventory" }).click();
  await expect(modal).toBeHidden();
  await expect(page.getByText("0 in stock")).toBeVisible();
  await expect(page.getByText("Out of stock")).toBeVisible();
  await page.getByRole("searchbox", { name: "Search products" }).fill("not-a-product");
  await expect(page.getByText("No products match your search.")).toBeVisible();
});

test("ships eligible selected orders and leaves pending orders unchanged", async ({ page }) => {
  await page.getByRole("button", { name: "Orders", exact: true }).first().click();
  const paid = page.locator('#orders-table [data-key="NS-3209"]');
  const pending = page.locator('#orders-table [data-key="NS-3208"]');
  await paid.getByRole("checkbox", { name: "Select Jackson Lee" }).click();
  await expect(paid).toHaveAttribute("aria-selected", "true");
  await pending.getByRole("checkbox", { name: "Select Isabella Nguyen" }).click();
  await expect(pending).toHaveAttribute("aria-selected", "true");
  await page.getByRole("button", { name: "Mark as shipped" }).click();
  await expect(page.getByText("Marked 1 order as shipped.")).toBeVisible();
  await expect(paid).toContainText("Shipped");
  await expect(pending).toContainText("Unfulfilled");
  await expect(paid).toHaveAttribute("aria-selected", "false");
});

test("finds customers and shows their order history", async ({ page }) => {
  await page.getByRole("button", { name: "Customers", exact: true }).first().click();
  const search = page.getByRole("searchbox", { name: "Search customers" });
  await search.fill("olivia@example.com");
  await expect(page.getByText("1 of 8 customers")).toBeVisible();
  await page.getByRole("button", { name: /Olivia Martin/ }).click();
  await expect(page.getByRole("heading", { name: "Olivia Martin" })).toBeVisible();
  await expect(page.getByText("NS-3210 · Everyday Tote")).toBeVisible();
  await expect(page.getByText("Order value", { exact: true })).toBeVisible();
  await search.fill("no-such-customer");
  await expect(page.getByText("No customers match your search.")).toBeVisible();
});

test("groups customer orders by email and updates the totals", async ({ page }) => {
  await page.getByRole("button", { name: "New order" }).click();
  const modal = page.getByRole("dialog", { name: "Create order" });
  await modal.getByLabel("Customer name").fill("Olivia Martin");
  await modal.getByLabel("Email address").fill("OLIVIA@example.com");
  await modal.getByLabel("Amount (USD)").fill("50");
  await modal.getByRole("button", { name: "Create order" }).click();
  await expect(modal).toBeHidden();

  await page.getByRole("button", { name: "Customers", exact: true }).first().click();
  await page.getByRole("searchbox", { name: "Search customers" }).fill("olivia@example.com");
  await expect(page.getByText("1 of 8 customers")).toBeVisible();
  await page.getByRole("button", { name: /Olivia Martin/ }).click();
  const totals = page.locator("dl");
  await expect(totals).toContainText("$178.00");
  await expect(totals).toContainText("$128.00");
  await expect(page.getByText("NS-3210 · Everyday Tote")).toBeVisible();
  await expect(page.getByText("NS-3211 · Everyday Tote")).toBeVisible();
});

test("reports settings errors without losing the entered values", async ({ page }) => {
  await page.getByRole("button", { name: "Settings", exact: true }).first().click();
  const name = page.getByLabel("Store name");
  await name.fill("   ");
  await page.getByRole("button", { name: "Save changes" }).click();
  await expect(page.locator(".alert--danger")).toContainText(
    "Enter a store name and valid email address.",
  );
  await expect(name).toHaveValue("   ");
  await name.fill("Northstar Updated");
  await page.getByRole("button", { name: "Save changes" }).click();
  await expect(page.locator(".alert--success")).toContainText("Store settings saved.");
});

test("exports orders safely when a customer name begins with a formula", async ({ page }) => {
  await page.getByRole("button", { name: "New order" }).click();
  const modal = page.getByRole("dialog", { name: "Create order" });
  await modal.getByLabel("Customer name").fill("=1+1");
  await modal.getByLabel("Email address").fill("formula@example.com");
  await modal.getByRole("button", { name: "Create order" }).click();
  await expect(modal).toBeHidden();

  const downloadPromise = page.waitForEvent("download");
  await page.getByRole("button", { name: "Export orders CSV" }).click();
  const download = await downloadPromise;
  const csv = await readFile(await download.path(), "utf8");
  expect(csv).toContain(`"'=1+1"`);
  expect(csv).toContain("formula@example.com");
});

test("interacts with the component kit's pagination, search, and note editor", async ({ page }) => {
  await page.getByRole("button", { name: "UI kit", exact: true }).first().click();
  const table = page.locator("#kit-inventory");
  const catalogCard = page
    .locator(".card")
    .filter({ has: page.getByRole("heading", { name: "Catalog table" }) });
  await expect(table.getByText("Everyday Tote")).toBeVisible();
  await catalogCard.getByRole("button", { name: "Page 2" }).click();
  await expect(table.getByText("Studio Mug Set")).toBeVisible();
  await expect(catalogCard.getByText("Page 2 of 3")).toBeVisible();

  await page
    .getByRole("group", { name: "View options" })
    .getByRole("button", { name: "Month" })
    .click();
  await expect(page.getByText("Selected view: Month")).toBeVisible();
  await page.getByRole("searchbox", { name: "Search teams" }).fill("retail");
  await expect(page.getByText("Retail Operations")).toBeVisible();
  await expect(page.getByText("Creative Team")).toBeHidden();

  await page.getByRole("button", { name: "Edit note" }).click();
  const modal = page.getByRole("dialog", { name: "Edit order note" });
  await modal.getByLabel("Note").fill("Please use recycled wrapping");
  await modal.getByRole("button", { name: "Save note" }).click();
  await expect(
    modal.getByText("Saved in this example: Please use recycled wrapping"),
  ).toBeVisible();
});
