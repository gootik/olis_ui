import { test, expect } from "@playwright/test";

test.beforeEach(async ({ page }) => {
  await page.goto("/live-preview");
  await expect(page.locator("[data-phx-main].phx-connected")).toBeVisible();
});

test.describe("Table", () => {
  test("keyboard selection and sorting preserve the selected row and focus", async ({ page }) => {
    const table = page.locator("#people-table");
    const row = table.locator('[data-key="person-2"]');
    const header = table.locator("th").filter({ hasText: "Name" });

    await expect(table).toHaveAttribute("role", "grid");
    await table.focus();
    await expect(table.locator('[data-key="person-1"]')).toBeFocused();
    await page.keyboard.press("ArrowDown");
    await expect(row).toBeFocused();
    await page.keyboard.press("ArrowRight");
    await expect(row.locator("td").first()).toBeFocused();
    await page.keyboard.press("Space");
    await expect(row).toHaveAttribute("aria-selected", "true");
    await expect(page.locator("#table-selection-state")).toContainText("person-2");

    await header.focus();
    await page.keyboard.press("Enter");
    await expect(header).toHaveAttribute("aria-sort", "descending");
    await expect(header).toBeFocused();
    await expect(row).toHaveAttribute("aria-selected", "true");
  });

  test("column resizing works with keyboard and pointer and survives a sort", async ({ page }) => {
    const table = page.locator("#people-table");
    const header = table.locator("th").filter({ hasText: "Name" });
    const nameHandle = table.locator('[data-table-resizer="name"]');
    const roleHandle = table.locator('[data-table-resizer="role"]');

    await header.focus();
    await page.keyboard.press("F2");
    await page.keyboard.press("Tab");
    await expect(nameHandle).toBeFocused();
    const nameWidth = Number(await nameHandle.getAttribute("aria-valuenow"));
    await page.keyboard.press("ArrowRight");
    await expect(nameHandle).toHaveAttribute("aria-valuenow", String(nameWidth + 10));
    await expect(page.locator("#table-resize-state")).toContainText(`name: ${nameWidth + 10}px`);

    await roleHandle.scrollIntoViewIfNeeded();
    const roleWidth = Number(await roleHandle.getAttribute("aria-valuenow"));
    const box = await roleHandle.boundingBox();
    expect(box).not.toBeNull();
    const x = box.x + box.width / 2;
    const y = box.y + box.height / 2;
    await expect
      .poll(() =>
        page.evaluate(
          ({ x, y }) => document.elementFromPoint(x, y)?.getAttribute("data-table-resizer"),
          { x, y },
        ),
      )
      .toBe("role");
    await page.mouse.move(x, y);
    await page.mouse.down();
    await page.mouse.move(x + 35, y, { steps: 5 });
    await page.mouse.up();
    await expect(roleHandle).toHaveAttribute("aria-valuenow", String(roleWidth + 35));
    await expect(page.locator("#table-resize-state")).toContainText(`role: ${roleWidth + 35}px`);

    await header.focus();
    await page.keyboard.press("Enter");
    await expect(header).toHaveAttribute("aria-sort", "descending");
    await expect(roleHandle).toHaveAttribute("aria-valuenow", String(roleWidth + 35));
  });

  test("viewport loading and streamed empty state update together", async ({ page }) => {
    const table = page.locator("#stream-table");
    const sentinel = page.locator("#stream-table-load-more");
    const empty = page.locator("#stream-table-empty");
    const selectAll = table.locator("[data-olis-table-select-all]");

    // Reaching the sentinel triggers the real LiveView viewport binding.
    await page.evaluate(() =>
      document
        .querySelector("#stream-table-load-more")
        ?.scrollIntoView({ block: "center", behavior: "instant" }),
    );
    await expect(table.getByText("Jordan Park", { exact: true })).toBeVisible();
    await expect(sentinel).toHaveCount(0);
    await expect(table.locator("[data-olis-table-row]")).toHaveCount(5);

    await page.getByRole("button", { name: "Clear people" }).click();
    await expect(empty).toBeVisible();
    await expect(empty).toContainText("No people yet");
    await expect(table.locator("[data-olis-table-row]")).toHaveCount(0);
    await expect(selectAll).toBeDisabled();

    await page.getByRole("button", { name: "Add person" }).click();
    await expect(table.locator("[data-olis-table-row]")).toHaveCount(1);
    await expect(empty).toBeHidden();
    await expect(selectAll).toBeEnabled();
  });
});
