import { expect, test } from "@playwright/test";

test.beforeEach(async ({ page }) => {
  await page.goto("/");
  await expect(page.locator("[data-phx-main].phx-connected")).toBeVisible();
});

test("serves compiled dashboard and component styles", async ({ request }) => {
  const response = await request.get("/assets/app.css");
  expect(response.ok()).toBeTruthy();
  const css = await response.text();
  expect(css).toContain(".olis-button");
  expect(css).toContain(".search-field");
  expect(css).not.toMatch(/@import\s+(?:url\()?\s*["'](?:@heroui|\.\.\/)/);
});

test("creates an order and filters the live table", async ({ page }) => {
  await page.getByRole("button", { name: "New order" }).click();
  const modal = page.getByRole("dialog", { name: "Create order" });
  await expect(modal).toBeVisible();
  await modal.getByLabel("Customer name").fill("Jamie Rivera");
  await modal.getByLabel("Email address").fill("jamie@example.com");
  await modal.getByLabel("Amount (USD)").fill("249");
  await modal.getByRole("button", { name: "Create order" }).click();
  await expect(modal).toBeHidden();
  await expect(page.getByText("Jamie Rivera", { exact: true })).toBeVisible();
  await page.getByRole("searchbox", { name: "Search orders" }).fill("Jamie Rivera");
  await expect(page.getByText("1 orders match your filters.")).toBeVisible();
});

test("opens the component kit and switches themes", async ({ page }) => {
  await page.getByRole("button", { name: "UI kit" }).first().click();
  await expect(page.getByRole("heading", { name: "Workspace UI kit" })).toBeVisible();
  await page.getByRole("button", { name: "Switch to dark mode" }).click();
  await expect(page.locator('[data-theme="dark"]')).toBeVisible();
  await expect(page.locator("#orders-table")).toHaveCount(0);
});
