import { defineConfig } from "vitest/config";
import FnReporter from "./tests/fnReporter";

export default defineConfig({
  test: {
    globals: false,
    environment: "node",
    include: ["tests/**/*.test.ts"],
    testTimeout: 10000,
    reporters: ["default", new FnReporter()],
  },
});