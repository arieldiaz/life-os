#!/usr/bin/env bash
# verify-agents: for each agent machine identity, log in via Universal Auth,
# pull its secrets from Infisical, and make one harmless authenticated call
# per service (Slack auth.test, Notion /v1/users/me). Prints PASS/FAIL per
# agent per integration, plus a least-privilege check that each identity
# CANNOT read the other agents' paths. No secret values are ever printed.
#
# Configure the three vars below (or export them), store each agent's
# universal-auth credentials in the login Keychain as
# <AGENT>_CLIENT_ID / <AGENT>_CLIENT_SECRET (account "life-os"):
#   security add-generic-password -U -a life-os -s LIV_CLIENT_ID -w
set -uo pipefail

INFISICAL_API_URL="${INFISICAL_API_URL:-https://secrets.your-domain.com/api}"
AGENTS_PROJECT_ID="${AGENTS_PROJECT_ID:-TODO}"
AGENTS=(liv max)
KEYCHAIN_ACCOUNT="life-os"

export INFISICAL_API_URL

if [ "$AGENTS_PROJECT_ID" = "TODO" ]; then
  echo "verify-agents: set AGENTS_PROJECT_ID (Project -> Settings -> Project ID) first." >&2
  exit 1
fi

keychain() {
  security find-generic-password -a "$KEYCHAIN_ACCOUNT" -s "$1" -w 2>/dev/null
}

FAILURES=0

check_slack() {
  local agent="$1" token="$2"
  if [ -z "$token" ]; then
    echo "FAIL  $agent slack   (SLACK_BOT_TOKEN missing or placeholder)"
    return 1
  fi
  local ok
  ok=$(curl -s https://slack.com/api/auth.test -H "Authorization: Bearer $token" | jq -r '.ok')
  if [ "$ok" = "true" ]; then
    echo "PASS  $agent slack"
  else
    echo "FAIL  $agent slack   (auth.test rejected the token)"
    return 1
  fi
}

check_notion() {
  local agent="$1" token="$2"
  if [ -z "$token" ]; then
    echo "FAIL  $agent notion  (NOTION_TOKEN missing or placeholder)"
    return 1
  fi
  local obj
  obj=$(curl -s https://api.notion.com/v1/users/me \
    -H "Authorization: Bearer $token" -H "Notion-Version: 2022-06-28" | jq -r '.object')
  if [ "$obj" = "user" ]; then
    echo "PASS  $agent notion"
  else
    echo "FAIL  $agent notion  (users/me rejected the token)"
    return 1
  fi
}

verify_agent() {
  local agent="$1" prefix token client_id client_secret
  prefix="$(printf '%s' "$agent" | tr '[:lower:]' '[:upper:]')"

  client_id="$(keychain "${prefix}_CLIENT_ID")" || true
  client_secret="$(keychain "${prefix}_CLIENT_SECRET")" || true
  if [ -z "${client_id:-}" ] || [ -z "${client_secret:-}" ]; then
    echo "FAIL  $agent identity (${prefix}_CLIENT_ID/_CLIENT_SECRET not in Keychain)"
    FAILURES=$((FAILURES+1))
    return
  fi

  token=$(infisical login --method=universal-auth \
    --client-id="$client_id" --client-secret="$client_secret" --plain --silent 2>/dev/null)
  if [ -z "${token:-}" ]; then
    echo "FAIL  $agent identity (universal-auth login failed)"
    FAILURES=$((FAILURES+1))
    return
  fi
  echo "PASS  $agent identity (universal-auth login ok)"

  # Least-privilege: this identity must NOT read any other agent's path.
  local other
  for other in "${AGENTS[@]}"; do
    [ "$other" = "$agent" ] && continue
    if INFISICAL_TOKEN="$token" infisical secrets --projectId "$AGENTS_PROJECT_ID" \
         --env prod --path "/$other" --plain >/dev/null 2>&1; then
      echo "FAIL  $agent scoping  (identity CAN read /$other — permissions too broad)"
      FAILURES=$((FAILURES+1))
    else
      echo "PASS  $agent scoping  (cannot read /$other)"
    fi
  done

  local dotenv slack_token notion_token
  dotenv=$(INFISICAL_TOKEN="$token" infisical export --projectId "$AGENTS_PROJECT_ID" \
    --env prod --path "/$agent" --format dotenv 2>/dev/null)
  slack_token=$(printf '%s\n' "$dotenv" | grep '^SLACK_BOT_TOKEN=' | cut -d= -f2- | tr -d "'\"")
  notion_token=$(printf '%s\n' "$dotenv" | grep '^NOTION_TOKEN=' | cut -d= -f2- | tr -d "'\"")

  case "$slack_token" in TODO*) slack_token="";; esac
  case "$notion_token" in TODO*) notion_token="";; esac

  check_slack "$agent" "$slack_token" || FAILURES=$((FAILURES+1))
  check_notion "$agent" "$notion_token" || FAILURES=$((FAILURES+1))
}

for a in "${AGENTS[@]}"; do
  verify_agent "$a"
done

echo
if [ "$FAILURES" -eq 0 ]; then
  echo "verify-agents: ALL PASS"
else
  echo "verify-agents: $FAILURES failure(s)"
  exit 1
fi
