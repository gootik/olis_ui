import { defineConfig, devices } from "@playwright/test";

const port = process.env.OLIS_ADMIN_TEST_PORT || "4101";
const baseURL = `http://localhost:${port}`;

export default defineConfig({
  testDir: "./test/admin-browser",
  outputDir: "./test-results/admin",
  timeout: 30_000,
  workers: 2,
  use: { baseURL, trace: "retain-on-failure" },
  projects: [
    { name: "chromium", use: { ...devices["Desktop Chrome"] } },
    { name: "firefox", use: { ...devices["Desktop Firefox"] } },
  ],
  webServer: {
    command: "mix admin",
    cwd: "examples/admin",
    env: { PORT: port },
    url: baseURL,
    reuseExistingServer: false,
    timeout: 120_000,
    gracefulShutdown: { signal: "SIGTERM", timeout: 5_000 },
  },
});
