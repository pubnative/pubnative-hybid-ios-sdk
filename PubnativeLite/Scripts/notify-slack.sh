#!/bin/bash
set -euo pipefail

# ==========================================================
# 🔔 Slack Notification Script — HyBid release pipelines
# ==========================================================
# Inputs (env):
#   - SLACK_BOT_TOKEN                 (required always)
#   - SLACK_IOS_RELEASES_CHANNEL      (required for SDK / adapter / failure paths)
#   - SLACK_CHANNEL                   (required for legacy private-pods path only)
#   - STATUS                          (optional) "success" (default) or "failure"
#   - HYBID_PRIVATE_REPO_RELEASE_TAG  (required for success; optional for failure)
#   - HYBID_VERSION                   (optional) set for adapter releases
#   - RELEASE_TITLE                   (optional) set for SDK / adapter releases
#                                               if unset and HYBID_VERSION unset →
#                                               legacy private-pods branch logic applies
#   - RELEASE_URL                     (optional) overrides default private-pods URL
#   - FAILURE_CONTEXT                 (optional) description of failure
#
# Path routing:
#   STATUS=failure                    → failure msg  → SLACK_IOS_RELEASES_CHANNEL
#   HYBID_VERSION set                 → adapter msg  → SLACK_IOS_RELEASES_CHANNEL
#   RELEASE_TITLE set (no HYBID_VER)  → SDK msg      → SLACK_IOS_RELEASES_CHANNEL
#   neither set                       → private pods → SLACK_CHANNEL (different channel)
#
# GitHub Actions vars used automatically:
#   GITHUB_REF_NAME, GITHUB_SHA, GITHUB_RUN_NUMBER,
#   GITHUB_RUN_ID, GITHUB_REPOSITORY, GITHUB_SERVER_URL, GITHUB_ACTOR
# ==========================================================

STATUS="${STATUS:-success}"

if [ -z "${SLACK_BOT_TOKEN:-}" ]; then
  echo "⚠️  Missing SLACK_BOT_TOKEN — skipping Slack notification."
  exit 0
fi

# jq is required for JSON-safe payload construction.
if ! command -v jq &>/dev/null; then
  echo "⚠️  jq not found — skipping Slack notification."
  exit 0
fi

# SLACK_IOS_RELEASES_CHANNEL is required for all non-legacy paths.
# Check early so set -u doesn't cause an opaque "unbound variable" crash.
if [ "$STATUS" = "failure" ] || [ -n "${HYBID_VERSION:-}" ] || [ -n "${RELEASE_TITLE:-}" ]; then
  if [ -z "${SLACK_IOS_RELEASES_CHANNEL:-}" ]; then
    echo "⚠️  Missing SLACK_IOS_RELEASES_CHANNEL — skipping Slack notification."
    exit 0
  fi
fi

RUN_ID="${GITHUB_RUN_ID:-0}"
REPO_FULL="${GITHUB_REPOSITORY:-vervegroup/pubnative-hybid-ios-sdk-private}"
SERVER_URL="${GITHUB_SERVER_URL:-https://github.com}"
BUILD_URL="${SERVER_URL}/${REPO_FULL}/actions/runs/${RUN_ID}"

# Helper: POST payload to Slack and validate the response.
# Uses --max-time 10 to avoid hanging GHA jobs if Slack is slow/unreachable.
# jq is guaranteed to be available (checked above).
# Slack notifications are best-effort: log failures but do not fail the calling job.
# A transient Slack outage should never mark an otherwise-successful release as failed.
slack_post() {
  local payload="$1"
  local resp ok err

  if ! resp=$(printf '%s' "$payload" | curl -sS --max-time 10 \
    -X POST "https://slack.com/api/chat.postMessage" \
    -H "Authorization: Bearer $SLACK_BOT_TOKEN" \
    -H "Content-Type: application/json; charset=utf-8" \
    --data @-); then
    echo "⚠️  Slack notification failed: curl request to Slack API was unsuccessful."
    return 1
  fi

  ok=$(echo "$resp" | jq -r '.ok' 2>/dev/null || echo "parse_error")
  if [ "$ok" != "true" ]; then
    err=$(echo "$resp" | jq -r '.error // "unknown_error"' 2>/dev/null || echo "unknown_error")
    echo "⚠️  Slack notification failed: $err"
    echo "$resp"
    return 1
  fi
}

# ──────────────────────────────────────────────────────────────────────────────
# FAILURE path — runs regardless of whether VERSION is set
# ──────────────────────────────────────────────────────────────────────────────
if [ "$STATUS" = "failure" ]; then
  VERSION_LABEL="${HYBID_PRIVATE_REPO_RELEASE_TAG:-unknown}"
  TITLE="${RELEASE_TITLE:-HyBid Release}"
  FAILURE_TEXT="${FAILURE_CONTEXT:-Check the GHA run for details.}"

  # Match the category emoji to the type of release that failed
  if [ -n "${HYBID_VERSION:-}" ]; then
    FAIL_EMOJI="📦"   # adapter release
  else
    FAIL_EMOJI="🚀"   # SDK release (default)
  fi

  PAYLOAD=$(jq -n \
    --arg channel  "$SLACK_IOS_RELEASES_CHANNEL" \
    --arg text     "$FAIL_EMOJI $TITLE FAILED — $VERSION_LABEL" \
    --arg header   "❌ $TITLE FAILED" \
    --arg version  "$VERSION_LABEL" \
    --arg build    "$BUILD_URL" \
    --arg context  "$FAILURE_TEXT" \
    '{
      channel: $channel,
      text: $text,
      attachments: [{
        color: "#E01E5A",
        blocks: [
          {type: "header", text: {type: "plain_text", text: $header}},
          {type: "section", fields: [
            {type: "mrkdwn", text: ("*Version:*\n" + $version)},
            {type: "mrkdwn", text: ("*GHA Run:*\n<" + $build + "|View run>")}
          ]},
          {type: "section", text: {type: "mrkdwn", text: ("*Failure context:*\n" + $context)}},
          {type: "context", elements: [
            {type: "mrkdwn", text: "Generated automatically by GitHub Actions 🚀"}
          ]}
        ]
      }]
    }')

  if slack_post "$PAYLOAD"; then
    echo "✅ Slack notification sent: failure — $TITLE ($VERSION_LABEL)"
  fi
  exit 0
fi

# ──────────────────────────────────────────────────────────────────────────────
# SUCCESS paths — require HYBID_PRIVATE_REPO_RELEASE_TAG
# ──────────────────────────────────────────────────────────────────────────────
if [ -z "${HYBID_PRIVATE_REPO_RELEASE_TAG:-}" ]; then
  echo "⚠️  Missing HYBID_PRIVATE_REPO_RELEASE_TAG — skipping Slack notification."
  exit 0
fi

BRANCH="${GITHUB_REF_NAME:-unknown}"
COMMIT_SHA="${GITHUB_SHA:-}"
BUILD_NUM="${GITHUB_RUN_NUMBER:-0}"
AUTHOR="${GITHUB_ACTOR:-unknown}"

RELEASE_URL="${RELEASE_URL:-https://github.com/vervegroup/hybid-ios-sdk-private-pods/releases/tag/${HYBID_PRIVATE_REPO_RELEASE_TAG}}"

if [ -n "${HYBID_VERSION:-}" ]; then
  # ────────────────────────────────────────────────────────────────────────────
  # Adapter release — title/emoji/color fixed, no branch/commit fields
  # ────────────────────────────────────────────────────────────────────────────
  TITLE="${RELEASE_TITLE:-Adapter Release}"

  PAYLOAD=$(jq -n \
    --arg channel  "$SLACK_IOS_RELEASES_CHANNEL" \
    --arg text     "📦 $TITLE — $HYBID_PRIVATE_REPO_RELEASE_TAG" \
    --arg header   "✅ $TITLE" \
    --arg hybid    "$HYBID_VERSION" \
    --arg adapter  "$HYBID_PRIVATE_REPO_RELEASE_TAG" \
    --arg build    "$BUILD_URL" \
    --arg buildnum "#$BUILD_NUM" \
    --arg release  "$RELEASE_URL" \
    --arg author   "👤 *Author:* $AUTHOR" \
    '{
      channel: $channel,
      text: $text,
      attachments: [{
        color: "#2EB67D",
        blocks: [
          {type: "header", text: {type: "plain_text", text: $header}},
          {type: "section", fields: [
            {type: "mrkdwn", text: ("*HyBid SDK:*\n" + $hybid)},
            {type: "mrkdwn", text: ("*Adapter Version:*\n" + $adapter)},
            {type: "mrkdwn", text: ("*Build:*\n<" + $build + "|" + $buildnum + ">")},
            {type: "mrkdwn", text: ("*Release:*\n<" + $release + "|View on GitHub>")}
          ]},
          {type: "context", elements: [
            {type: "mrkdwn", text: $author},
            {type: "mrkdwn", text: "Generated automatically by GitHub Actions 🚀"}
          ]}
        ]
      }]
    }')

elif [ -n "${RELEASE_TITLE:-}" ]; then
  # ────────────────────────────────────────────────────────────────────────────
  # SDK release — RELEASE_TITLE was set by caller
  # Beta/RC → silver; official → gold
  # ────────────────────────────────────────────────────────────────────────────
  if echo "$HYBID_PRIVATE_REPO_RELEASE_TAG" | grep -qiE 'beta|rc|alpha|preview'; then
    COLOR="#C0C0C0"   # silver — pre-release / beta
  else
    COLOR="#E8A838"   # gold — official release
  fi

  TITLE="$RELEASE_TITLE"

  PAYLOAD=$(jq -n \
    --arg channel  "$SLACK_IOS_RELEASES_CHANNEL" \
    --arg text     "🚀 $RELEASE_TITLE — $HYBID_PRIVATE_REPO_RELEASE_TAG" \
    --arg header   "✅ $RELEASE_TITLE" \
    --arg version  "$HYBID_PRIVATE_REPO_RELEASE_TAG" \
    --arg release  "$RELEASE_URL" \
    --arg build    "$BUILD_URL" \
    --arg color    "$COLOR" \
    --arg author   "👤 *Author:* $AUTHOR" \
    '{
      channel: $channel,
      text: $text,
      attachments: [{
        color: $color,
        blocks: [
          {type: "header", text: {type: "plain_text", text: $header}},
          {type: "section", fields: [
            {type: "mrkdwn", text: ("*Version:*\n" + $version)},
            {type: "mrkdwn", text: ("*Release:*\n<" + $release + "|View on GitHub>")},
            {type: "mrkdwn", text: ("*GHA Run:*\n<" + $build + "|View run>")}
          ]},
          {type: "context", elements: [
            {type: "mrkdwn", text: $author},
            {type: "mrkdwn", text: "Generated automatically by GitHub Actions 🚀"}
          ]}
        ]
      }]
    }')

else
  # ────────────────────────────────────────────────────────────────────────────
  # Legacy private-pods release — branch-based title/emoji/color
  # (used by config.yml private pod commit step)
  # Uses SLACK_CHANNEL — a different channel from the release notifications
  # ────────────────────────────────────────────────────────────────────────────
  if [ -z "${SLACK_CHANNEL:-}" ]; then
    echo "⚠️  Missing SLACK_CHANNEL — skipping Slack notification."
    exit 0
  fi

  COMMIT_URL="${SERVER_URL}/${REPO_FULL}/commit/${COMMIT_SHA}"
  SHORT_SHA="${COMMIT_SHA:0:7}"; SHORT_SHA="${SHORT_SHA:-unknown}"

  case "$BRANCH" in
    master|development)
      EMOJI="🚀"
      TITLE="Production Release"
      COLOR="#2EB67D"
      ;;
    beta)
      EMOJI="🧪"
      TITLE="Beta Release"
      COLOR="#ECB22E"
      ;;
    *)
      EMOJI="🔧"
      TITLE="Test / Feature Build"
      COLOR="#808080"
      ;;
  esac

  PAYLOAD=$(jq -n \
    --arg channel  "$SLACK_CHANNEL" \
    --arg text     "$EMOJI $TITLE — $HYBID_PRIVATE_REPO_RELEASE_TAG" \
    --arg header   "$EMOJI $TITLE" \
    --arg version  "$HYBID_PRIVATE_REPO_RELEASE_TAG" \
    --arg branch   "$BRANCH" \
    --arg commit   "$COMMIT_URL" \
    --arg sha      "$SHORT_SHA" \
    --arg build    "$BUILD_URL" \
    --arg buildnum "#$BUILD_NUM" \
    --arg release  "$RELEASE_URL" \
    --arg color    "$COLOR" \
    --arg author   "👤 *Author:* $AUTHOR" \
    '{
      channel: $channel,
      text: $text,
      attachments: [{
        color: $color,
        blocks: [
          {type: "header", text: {type: "plain_text", text: $header}},
          {type: "section", fields: [
            {type: "mrkdwn", text: ("*Version:*\n" + $version)},
            {type: "mrkdwn", text: ("*Branch:*\n" + $branch)},
            {type: "mrkdwn", text: ("*Commit:*\n<" + $commit + "|" + $sha + ">")},
            {type: "mrkdwn", text: ("*Build:*\n<" + $build + "|" + $buildnum + ">")},
            {type: "mrkdwn", text: ("*Release:*\n<" + $release + "|View on GitHub>")}
          ]},
          {type: "context", elements: [
            {type: "mrkdwn", text: $author},
            {type: "mrkdwn", text: "Generated automatically by GitHub Actions 🚀"}
          ]}
        ]
      }]
    }')
fi

if slack_post "$PAYLOAD"; then
  echo "✅ Slack notification sent: $TITLE → $HYBID_PRIVATE_REPO_RELEASE_TAG"
fi
