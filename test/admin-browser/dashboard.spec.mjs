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

test("uses the dark OlisUI palette and compact primary action", async ({ page }) => {
  const workspace = page.locator('[data-theme="dark"]');
  const primaryAction = page.getByRole("button", { name: "New order" });

  await expect(workspace).toBeVisible();
  await expect(primaryAction).toHaveCSS("background-color", "rgb(212, 58, 44)");
  await expect(primaryAction).toHaveCSS("color", "rgb(255, 255, 255)");
  await expect(primaryAction.locator("svg")).toHaveCSS("stroke", "rgb(255, 255, 255)");
  await expect(primaryAction).toHaveCSS("border-radius", "6px");
  await expect(page.locator(".card").first()).toHaveCSS("border-radius", "12px");

  const contrast = () =>
    primaryAction.evaluate((button) => {
      const context = document.createElement("canvas").getContext("2d");
      const readColor = (color) => {
        context.clearRect(0, 0, 1, 1);
        context.fillStyle = color;
        context.fillRect(0, 0, 1, 1);
        return Array.from(context.getImageData(0, 0, 1, 1).data).slice(0, 3);
      };
      const luminance = (channels) =>
        channels
          .map((channel) => channel / 255)
          .map((channel) =>
            channel <= 0.04045 ? channel / 12.92 : ((channel + 0.055) / 1.055) ** 2.4,
          )
          .reduce((sum, channel, index) => sum + channel * [0.2126, 0.7152, 0.0722][index], 0);

      const style = getComputedStyle(button);
      const foreground = luminance(readColor(style.color));
      const background = luminance(readColor(style.backgroundColor));
      return (Math.max(foreground, background) + 0.05) / (Math.min(foreground, background) + 0.05);
    });

  expect(await contrast()).toBeGreaterThanOrEqual(4.5);
  await primaryAction.hover();
  await expect(primaryAction).not.toHaveCSS("background-color", "rgb(212, 58, 44)");
  await expect.poll(contrast).toBeGreaterThanOrEqual(4.5);
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
  await page.getByRole("button", { name: "Switch to light mode" }).click();
  await expect(page.locator('[data-theme="light"]')).toBeVisible();
  await expect(page.locator("#orders-table")).toHaveCount(0);
});
