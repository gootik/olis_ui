import { test, expect } from '@playwright/test';

// The caller supplies beforeEach navigation to /live-preview and waits until
// the LiveView root has its phx-connected class. Each test needs a fresh page.

test('search field propagates input and clear actions to LiveView', async ({ page }) => {
  const input = page.locator('#preview-search');
  const status = page.locator('#search-state');
  const clear = page.locator('#preview-search-search-field [data-hero-search-clear]');

  await input.fill('Phoenix');
  await expect(status).toContainText('Query: Phoenix');
  await expect(clear).toBeEnabled();
  await clear.click();
  await expect(input).toHaveValue('');
  await expect(status).toHaveText(/^\s*Query:\s*$/);
  await expect(clear).toBeDisabled();
});

test('pending buttons suppress actions and submissions until pending clears', async ({ page }) => {
  const status = page.locator('#button-state');
  const toggle = page.locator('#preview-toggle-pending');
  const action = page.locator('#preview-pending-button');
  const submit = page.locator('#preview-pending-submit');

  await toggle.click();
  await expect(action).toHaveAttribute('aria-busy', 'true');
  await expect(action).toHaveAttribute('aria-disabled', 'true');
  await action.focus();
  await expect(action).toBeFocused();
  await page.keyboard.press('Enter');
  await page.locator('#pending-button-input').fill('example');
  await page.locator('#pending-button-input').press('Enter');
  await expect(status).toContainText('Pending: true; Actions: 0; Submissions: 0');

  await toggle.click();
  await expect(action).not.toHaveAttribute('aria-busy', 'true');
  await action.click();
  await expect(status).toContainText('Actions: 1');
  await submit.click();
  await expect(status).toContainText('Submissions: 1');
});

test('listbox local selection and actions survive LiveView patches', async ({ page }) => {
  const list = page.locator('#notification-list');
  const email = list.getByRole('option', { name: 'Email' });
  const push = list.getByRole('option', { name: 'Push notifications' });
  const sms = list.getByRole('option', { name: 'SMS' });
  const state = page.locator('#listbox-selection-state');

  await expect(list.getByRole('group', { name: 'Delivery' })).toBeVisible();
  await expect(sms).toHaveAttribute('aria-disabled', 'true');
  await expect(email).toHaveAttribute('aria-selected', 'true');
  await expect(push).toHaveAttribute('aria-selected', 'false');
  await push.click();
  await expect(push).toHaveAttribute('aria-selected', 'true');
  await expect(state).toContainText('Selected: email, push');
  await expect(state).toContainText('Action: push');

  await list.focus();
  await list.press('Home');
  await list.press('ArrowDown');
  await expect(list).toHaveAttribute('aria-activedescendant', await push.getAttribute('id'));
  await list.press('Space');
  await expect(push).toHaveAttribute('aria-selected', 'false');
  await expect(email).toHaveAttribute('aria-selected', 'true');
  await expect(state).toContainText('Selected: email');
});

test('dropdown selection and nested menu keyboard focus', async ({ page }) => {
  const dropdown = page.locator('#view-menu');
  const trigger = dropdown.locator('[data-hero-dropdown-trigger]');
  const menu = page.locator('#view-menu-menu');

  await trigger.focus();
  await trigger.press('ArrowDown');
  await expect(menu).toBeVisible();
  const oldest = menu.getByRole('menuitemradio', { name: 'Oldest first' });
  await oldest.click();
  await expect(page.locator('#dropdown-state')).toContainText('Sort: oldest');
  await expect(menu).toBeHidden();

  await trigger.focus();
  await trigger.press('ArrowDown');
  const share = menu.getByRole('menuitem', { name: 'Share project' });
  await share.focus();
  await share.press('ArrowRight');
  const email = dropdown.getByRole('menuitem', { name: 'Email', exact: true });
  await expect(email).toBeFocused();
  await page.keyboard.press('Escape');
  await expect(share).toBeFocused();
  await page.keyboard.press('Escape');
  await expect(menu).toBeHidden();
  await expect(trigger).toBeFocused();
});

test('manual tabs move focus without selection until activated', async ({ page }) => {
  const tabs = page.locator('#controlled-tabs');
  const overview = tabs.getByRole('tab', { name: 'Overview' });
  const analytics = tabs.getByRole('tab', { name: 'Analytics' });
  const selection = page.locator('#tabs-selection-state');

  await expect(overview).toHaveAttribute('aria-selected', 'true');
  await overview.focus();
  await overview.press('ArrowRight');
  await expect(analytics).toBeFocused();
  await expect(overview).toHaveAttribute('aria-selected', 'true');
  await expect(analytics).toHaveAttribute('aria-selected', 'false');
  await analytics.press('Enter');
  await expect(selection).toContainText('Selected: analytics');
  await expect(analytics).toHaveAttribute('aria-selected', 'true');
  await expect(page.locator('#controlled-tabs-panel-analytics')).toBeVisible();
});
