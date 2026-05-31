#!/usr/bin/env bash
#
# Configures the `block-main` ruleset so that:
#   - Pushing directly / force-pushing / deleting `main` stays blocked for
#     everyone EXCEPT the repo Admin role (you) — preserved as-is.
#   - The promote GitHub App can write to `main` (bypass always), so the
#     promote_deps cron can merge `deps` -> `main`.
#   - Merging into `main` requires a pull request AND green CI
#     (lint, scan_ruby, build_image).
#
# Idempotent: safe to re-run. It rewrites the ruleset's bypass_actors and
# rules to the desired state.
#
# Usage:
#   PROMOTE_APP_ID=<app id> ./script/setup_main_ruleset.sh
#
# The App ID is the numeric "App ID" shown on the GitHub App's settings page
# (Settings -> Developer settings -> GitHub Apps -> your app).

set -euo pipefail

REPO="iamjosejimenez/clariapp"
RULESET_ID="11899930"            # block-main
ADMIN_ROLE_ID="5"                # RepositoryRole: Admin (you keep full bypass)
GITHUB_ACTIONS_INTEGRATION_ID="15368"  # global id of the GitHub Actions app

if [[ -z "${PROMOTE_APP_ID:-}" ]]; then
  echo "ERROR: set PROMOTE_APP_ID to your promote GitHub App's App ID." >&2
  echo "  PROMOTE_APP_ID=123456 $0" >&2
  exit 1
fi

echo "Updating ruleset $RULESET_ID on $REPO ..."

gh api -X PUT "repos/$REPO/rulesets/$RULESET_ID" --input - <<JSON
{
  "name": "block-main",
  "target": "branch",
  "enforcement": "active",
  "conditions": {
    "ref_name": { "include": ["~DEFAULT_BRANCH"], "exclude": [] }
  },
  "bypass_actors": [
    { "actor_id": $ADMIN_ROLE_ID, "actor_type": "RepositoryRole", "bypass_mode": "always" },
    { "actor_id": $PROMOTE_APP_ID, "actor_type": "Integration", "bypass_mode": "always" }
  ],
  "rules": [
    { "type": "deletion" },
    { "type": "non_fast_forward" },
    { "type": "update" },
    {
      "type": "pull_request",
      "parameters": {
        "required_approving_review_count": 0,
        "dismiss_stale_reviews_on_push": false,
        "require_code_owner_review": false,
        "require_last_push_approval": false,
        "required_review_thread_resolution": false,
        "automatic_copilot_code_review_enabled": false,
        "allowed_merge_methods": ["merge", "squash", "rebase"]
      }
    },
    {
      "type": "required_status_checks",
      "parameters": {
        "strict_required_status_checks_policy": false,
        "do_not_enforce_on_create": false,
        "required_status_checks": [
          { "context": "lint", "integration_id": $GITHUB_ACTIONS_INTEGRATION_ID },
          { "context": "scan_ruby", "integration_id": $GITHUB_ACTIONS_INTEGRATION_ID },
          { "context": "build_image", "integration_id": $GITHUB_ACTIONS_INTEGRATION_ID }
        ]
      }
    }
  ]
}
JSON

echo ""
echo "Done. Verifying ..."
gh api "repos/$REPO/rulesets/$RULESET_ID" \
  --jq '{name, enforcement, rules: [.rules[].type], bypass_actors}'
