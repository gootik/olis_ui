import { test, expect } from "@playwright/test";

test.beforeEach(async ({ page }) => {
  await page.goto("/live-preview");
  await expect(page.locator("[data-phx-main].phx-connected")).toBeVisible();
});

test("serves compiled Tailwind and component styles", async ({ request }) => {
  const response = await request.get("/olis_ui.css");
  expect(response.ok()).toBeTruthy();
  const css = await response.text();
  expect(css).toContain(".olis-button");
  expect(css).toContain(".search-field");
  expect(css).not.toMatch(/@import\s+(?:url\()?\s*["'](?:@heroui|\.\/olis_ui)/);
});

test("uses dark styles by default and respects an explicit light theme", async ({ page }) => {
  const body = page.locator("body");
  const primaryAction = page.getByRole("link", { name: "Explore components" });
  const accentChip = page.locator(".chip--accent.chip--primary");

  await page.evaluate(() => document.documentElement.removeAttribute("data-theme"));
  await expect(body).toHaveCSS("background-color", "rgb(8, 9, 10)");
  await expect(primaryAction).toHaveCSS("background-color", "rgb(212, 58, 44)");
  await expect(primaryAction).toHaveCSS("color", "rgb(255, 255, 255)");
  await expect(accentChip).toHaveCSS("background-color", "rgb(212, 58, 44)");
  await expect(accentChip).toHaveCSS("color", "rgb(255, 255, 255)");

  await page.evaluate(() => document.documentElement.setAttribute("data-theme", "light"));
  await expect(body).toHaveCSS("background-color", "rgb(250, 250, 250)");
  await expect(primaryAction).toHaveCSS("background-color", "rgb(212, 58, 44)");
  await expect(primaryAction).toHaveCSS("color", "rgb(255, 255, 255)");
  await expect(accentChip).toHaveCSS("color", "rgb(255, 255, 255)");
});

test("uses white indicators and slider knobs with the accent", async ({ page }) => {
  const checkbox = page
    .locator('[data-slot="checkbox"]')
    .filter({ has: page.locator("#live-terms") });
  await checkbox.click();
  await expect(page.locator("#live-terms")).toBeChecked();
  await expect(checkbox.locator('[data-slot="checkbox-default-indicator--checkmark"]')).toHaveCSS(
    "color",
    "rgb(255, 255, 255)",
  );

  for (const id of [
    "live-volume",
    "preview-price-range-0",
    "preview-price-range-1",
    "preview-brightness",
  ]) {
    const thumb = page
      .locator("[data-olis-slider]")
      .filter({ has: page.locator(`[id="${id}"]`) })
      .locator("[data-olis-slider-thumb]");
    const matchedThumb = id.startsWith("preview-price-range")
      ? thumb.nth(id.endsWith("-0") ? 0 : 1)
      : thumb;
    await expect(matchedThumb).toHaveCSS("background-color", "rgb(255, 255, 255)");
    await expect
      .poll(() =>
        matchedThumb.evaluate((element) => getComputedStyle(element, "::after").backgroundColor),
      )
      .toBe("rgb(255, 255, 255)");
  }
});

test("popover opens and completes its exit animation", async ({ page }) => {
  const trigger = page.getByRole("button", { name: "Open popover" });
  const popover = page.locator("#preview-popover-content");

  await trigger.click();
  await expect(popover).toBeVisible();
  await expect(trigger).toHaveAttribute("aria-expanded", "true");
  await page.keyboard.press("Escape");
  await expect(popover).toBeHidden();
  await expect(trigger).toHaveAttribute("aria-expanded", "false");
  await expect(trigger).toBeFocused();
});

test("search field propagates input and clear actions to LiveView", async ({ page }) => {
  const input = page.locator("#preview-search");
  const status = page.locator("#search-state");
  const clear = page.locator("#preview-search-search-field [data-olis-search-clear]");

  await input.fill("Phoenix");
  await expect(status).toContainText("Query: Phoenix");
  await expect(clear).toBeEnabled();
  await clear.click();
  await expect(input).toHaveValue("");
  await expect(status).toHaveText(/^\s*Query:\s*$/);
  await expect(clear).toBeDisabled();
});

test("pending buttons suppress actions and submissions until pending clears", async ({ page }) => {
  const status = page.locator("#button-state");
  const toggle = page.locator("#preview-toggle-pending");
  const action = page.locator("#preview-pending-button");
  const submit = page.locator("#preview-pending-submit");

  await toggle.click();
  await expect(action).toHaveAttribute("aria-busy", "true");
  await expect(action).toHaveAttribute("aria-disabled", "true");
  await action.focus();
  await expect(action).toBeFocused();
  await page.keyboard.press("Enter");
  await page.locator("#pending-button-input").fill("example");
  await page.locator("#pending-button-input").press("Enter");
  await expect(status).toContainText("Pending: true; Actions: 0; Submissions: 0");

  await toggle.click();
  await expect(action).not.toHaveAttribute("aria-busy", "true");
  await action.click();
  await expect(status).toContainText("Actions: 1");
  await submit.click();
  await expect(status).toContainText("Submissions: 1");
});

test("listbox local selection and actions survive LiveView patches", async ({ page }) => {
  const list = page.locator("#notification-list");
  const email = list.getByRole("option", { name: "Email" });
  const push = list.getByRole("option", { name: "Push notifications" });
  const sms = list.getByRole("option", { name: "SMS" });
  const state = page.locator("#listbox-selection-state");

  await expect(list.getByRole("group", { name: "Delivery" })).toBeVisible();
  await expect(sms).toHaveAttribute("aria-disabled", "true");
  await expect(email).toHaveAttribute("aria-selected", "true");
  await expect(push).toHaveAttribute("aria-selected", "false");
  await push.click();
  await expect(push).toHaveAttribute("aria-selected", "true");
  await expect(state).toContainText("Selected: email, push");
  await expect(state).toContainText("Action: push");

  await list.focus();
  await list.press("Home");
  await list.press("ArrowDown");
  await expect(list).toHaveAttribute("aria-activedescendant", await push.getAttribute("id"));
  await list.press("Space");
  await expect(push).toHaveAttribute("aria-selected", "false");
  await expect(email).toHaveAttribute("aria-selected", "true");
  await expect(state).toContainText("Selected: email");
});

test("dropdown selection and nested menu keyboard focus", async ({ page }) => {
  const dropdown = page.locator("#view-menu");
  const trigger = dropdown.locator("[data-olis-dropdown-trigger]");
  const menu = page.locator("#view-menu-menu");

  await trigger.focus();
  await trigger.press("ArrowDown");
  await expect(menu).toBeVisible();
  const oldest = menu.getByRole("menuitemradio", { name: "Oldest first" });
  await oldest.click();
  await expect(page.locator("#dropdown-state")).toContainText("Sort: oldest");
  await expect(menu).toBeHidden();

  await trigger.focus();
  await trigger.press("ArrowDown");
  const share = menu.getByRole("menuitem", { name: "Share project" });
  await share.focus();
  await share.press("ArrowRight");
  const email = dropdown.getByRole("menuitem", { name: "Email", exact: true });
  await expect(email).toBeFocused();
  await page.keyboard.press("Escape");
  await expect(share).toBeFocused();
  await page.keyboard.press("Escape");
  await expect(menu).toBeHidden();
  await expect(trigger).toBeFocused();
});

test("manual tabs move focus without selection until activated", async ({ page }) => {
  const tabs = page.locator("#controlled-tabs");
  const overview = tabs.getByRole("tab", { name: "Overview" });
  const analytics = tabs.getByRole("tab", { name: "Analytics" });
  const selection = page.locator("#tabs-selection-state");

  await expect(overview).toHaveAttribute("aria-selected", "true");
  await overview.focus();
  await overview.press("ArrowRight");
  await expect(analytics).toBeFocused();
  await expect(overview).toHaveAttribute("aria-selected", "true");
  await expect(analytics).toHaveAttribute("aria-selected", "false");
  await analytics.press("Enter");
  await expect(selection).toContainText("Selected: analytics");
  await expect(analytics).toHaveAttribute("aria-selected", "true");
  await expect(page.locator("#controlled-tabs-panel-analytics")).toBeVisible();
});
