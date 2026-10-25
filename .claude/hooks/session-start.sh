#!/bin/bash
# SessionStart hook for Claude Code on the web.
#
# Only runs in remote (web) sessions; local sessions are left untouched.
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

cd "${CLAUDE_PROJECT_DIR:-$(pwd)}"

# Install npm dependencies. This is an old (2019-era) devDependency tree
# whose declared peer deps (eslint-plugin-react <-> eslint) conflict under
# npm's modern resolver, so --legacy-peer-deps is required or `npm install`
# fails outright with ERESOLVE. Plain `npm install` (not `ci`) is used on
# purpose: there is no committed package-lock.json, and `install` lets the
# container-caching layer reuse node_modules across sessions.
npm install --legacy-peer-deps

# Tests and eslint's `standard-react`/flow config both expect the
# generated autoprefixer data table at lib/staticPrefixData.js. It's
# git-ignored and normally produced by the "pretest"/"build:prefixes" npm
# lifecycle script, but that only fires under `npm test`, not under a
# direct `mocha` or `eslint` invocation, so generate it explicitly here.
node tools/generate_prefixer_data.js
