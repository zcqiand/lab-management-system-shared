// Vitest reporter: collects function IDs from test names and writes .state/trace.json.

import type { Reporter } from "vitest/reporters";

interface TraceEntry {
  test: string;
  fns: string[];
  inert: boolean;
}

const TRACE_FILE = ".state/trace.json";

export default class FnReporter implements Partial<Reporter> {
  private entries: TraceEntry[] = [];

  onCollected(files?: any[]) {
    if (!files || files.length === 0) return;
    for (const file of files) {
      const tasks = file.tasks || [];
      if (process.env.TRACE_DEBUG === "1" && tasks[0]) {
        const top = tasks[0];
        process.stderr.write(`[fnReporter] top=${top.type}/${top.name} keys=${Object.keys(top).join(',')} sub=${JSON.stringify(top.tasks?.map((s:any) => `${s.type}:${s.name}`) ?? [])}\n`);
      }
      collectTests(tasks).forEach((t) => this.addEntry(t));
    }
  }

  async onFinished() {
    if (process.env.TRACE_MAP !== "1") return;
    const fs = await import("node:fs");
    const path = await import("node:path");
    fs.mkdirSync(".state", { recursive: true });
    fs.writeFileSync(
      path.resolve(TRACE_FILE),
      JSON.stringify({ schema: 1, tests: this.entries }, null, 2) + "\n",
      "utf-8",
    );
  }

  private addEntry(t: any) {
    const name = t.name || "";
    const fns = extractFns(name);
    const state = t.result?.state ?? "pass";
    const isInert = state === "skip" || state === "todo";
    if (fns.length === 0 && !isInert) return;
    this.entries.push({
      test: name,
      fns: isInert ? [] : fns.sort(),
      inert: isInert,
    });
  }
}

function collectTests(tasks: any[], out: any[] = []): any[] {
  for (const t of tasks) {
    if (!t) continue;
    if (t.type === "test") {
      out.push(t);
    } else if (t.type === "suite" && t.tasks) {
      collectTests(t.tasks, out);
    }
  }
  return out;
}

function extractFns(text: string): string[] {
  if (!text) return [];
  const ids: string[] = [];
  const re = /\bM\d{2}(?:\.F\d{2}(?:\.I\d{2})?)?\b/g;
  let m;
  while ((m = re.exec(text)) !== null) {
    if (!ids.includes(m[0])) ids.push(m[0]);
  }
  return ids;
}