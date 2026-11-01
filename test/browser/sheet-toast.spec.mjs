import { expect, test } from "@playwright/test";

test.beforeEach(async ({ page }) => {
  await page.goto("/live-preview");
  await expect(page.locator("[data-phx-main].phx-connected")).toBeVisible();
});

test("sheet close control stays in the corner and expanded content scrolls", async ({ page }) => {
  await page.getByRole("button", { name: "Bottom sheet" }).click();
  const sheet = page.locator("#preview-sheet");
  const close = sheet.locator('[data-slot="sheet-close-trigger"]').first();
  const body = sheet.locator('[data-slot="sheet-body"]').first();
  await expect(sheet).toBeVisible();
  await expect(close).toHaveCSS("position", "absolute");
  await expect(body).toHaveCSS("overflow-y", "auto");
  await close.click();
  await expect(sheet).toBeHidden();
});

test("toast indicator, content and close control keep their layout", async ({ page }) => {
  await page.getByRole("button", { name: "Success toast" }).click();
  const toast = page.locator('#preview-toasts [data-slot="toast"]').first();
  const indicator = toast.locator('[data-slot="toast-indicator"]');
  const content = toast.locator('[data-slot="toast-content"]');
  const close = toast.locator('[data-slot="toast-close"]');
  await expect(indicator).toBeVisible();
  await expect(content).toHaveCSS("grid-column-start", "2");
  await expect(close).toHaveCSS("position", "absolute");
  await toast.hover();
  await expect(close).toHaveCSS("opacity", "1");
  await close.click();
  await expect(toast).toHaveCount(0);
});
