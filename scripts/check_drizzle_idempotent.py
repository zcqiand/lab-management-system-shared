#!/usr/bin/env python3
"""Cross-platform Drizzle schema idempotence check.

The suite gate executes this file directly instead of invoking `sh -c`.
`drizzle-kit generate` must report no schema differences; otherwise the
schema change has not been materialized into the checked-in migration output.
"""

from __future__ import annotations

import os
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def main() -> int:
    required = ("PG_HOST", "PG_PORT", "PG_USER", "PG_PASSWORD", "PG_DATABASE")
    missing = [name for name in required if not os.environ.get(name)]
    if missing:
        print(f"missing required env: {', '.join(missing)}", file=sys.stderr)
        return 2

    result = subprocess.run(
        [
            "npx.cmd" if os.name == "nt" else "npx",
            "--no",
            "drizzle-kit",
            "generate",
            "--config",
            "drizzle.config.ts",
            "--name",
            "__ci_check",
        ],
        cwd=ROOT,
        env=os.environ.copy(),
        capture_output=True,
        text=True,
        check=False,
    )
    output = f"{result.stdout}\n{result.stderr}"
    if result.returncode != 0:
        print(output, file=sys.stderr, end="")
        return result.returncode
    if "No schema changes" not in output:
        print(output, file=sys.stderr, end="")
        print("Drizzle generated a migration; run npm run db:generate and commit it.", file=sys.stderr)
        return 1
    print("Drizzle schema is idempotent.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
