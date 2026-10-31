import { expect, test } from "@playwright/test";

test.beforeEach(async ({ page }) => {
  await page.goto("/live-preview");
  await expect(page.locator("[data-phx-main].phx-connected")).toBeVisible();
});

test("multiline input keeps its action aligned as the field resizes", async ({ page }) => {
  const group = page.locator('#feedback-preview [data-slot="input-group"]');
  const textarea = page.getByRole("textbox", { name: "Feedback" });
  const action = group.getByRole("button", { name: "Clear" });
  const state = page.locator("#feedback-state");

  await expect(textarea).toHaveAttribute("placeholder", "Share your feedback...");
  await expect(textarea).toHaveCSS("resize", "vertical");

  for (const width of [1280, 320]) {
    await page.setViewportSize({ width, height: 900 });
    await textarea.evaluate((element) => {
      element.style.height = "180px";
    });

    const layout = await group.evaluate((element) => {
      const field = element.querySelector("textarea").getBoundingClientRect();
      const button = element.querySelector("button").getBoundingClientRect();
      const bounds = element.getBoundingClientRect();
      return {
        actionBelowField: button.top >= field.bottom - 1,
        insideGroup: button.right <= bounds.right + 1 && button.bottom <= bounds.bottom + 1,
        fieldInsideGroup: field.left >= bounds.left - 1 && field.right <= bounds.right + 1,
        noHorizontalOverflow: element.scrollWidth <= element.clientWidth + 1,
      };
    });

    expect(layout).toEqual({
      actionBelowField: true,
      insideGroup: true,
      fieldInsideGroup: true,
      noHorizontalOverflow: true,
    });
  }

  await textarea.fill("Thoughtful, useful components");
  await expect(state).toContainText("Thoughtful, useful components");
  await action.click();
  await expect(textarea).toHaveValue("");
  await expect(state).toHaveText(/^\s*Feedback:\s*$/);
});

test("single-line input groups keep their prefix and suffix beside the input", async ({ page }) => {
  const group = page.locator('#price-preview [data-slot="input-group"]');
  const layout = await group.evaluate((element) => {
    const prefix = element
      .querySelector('[data-slot="input-group-prefix"]')
      .getBoundingClientRect();
    const input = element.querySelector("input").getBoundingClientRect();
    const suffix = element
      .querySelector('[data-slot="input-group-suffix"]')
      .getBoundingClientRect();
    return prefix.right <= input.left + 1 && input.right <= suffix.left + 1;
  });

  expect(layout).toBe(true);
});
