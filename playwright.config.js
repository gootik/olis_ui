import { defineConfig, devices } from '@playwright/test';

// Keep browser tests isolated from the preview that may be open for review.
const port = process.env.HERO_UI_TEST_PORT || '4100';
const baseURL = `http://localhost:${port}`;

export default defineConfig({
  testDir: './test/browser',
  timeout: 30_000,
  workers: 2,
  use: { baseURL, trace: 'retain-on-failure' },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
    { name: 'firefox', use: { ...devices['Desktop Firefox'] } }
  ],
  webServer: {
    command: 'mix preview',
    env: { PORT: port },
    url: `${baseURL}/live-preview`,
    reuseExistingServer: false,
    timeout: 120_000,
    gracefulShutdown: { signal: 'SIGTERM', timeout: 5_000 }
  }
});
