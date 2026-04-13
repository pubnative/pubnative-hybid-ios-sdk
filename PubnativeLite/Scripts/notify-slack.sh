#!/bin/bash
set -e

# ==========================================================
# 🔔 Slack Notification Script — HyBid private releases
# ==========================================================
# Inputs (env):
#   - SLACK_WEBHOOK_URL (required)
#   - HYBID_PRIVATE_REPO_RELEASE_TAG (required)
#   - CIRCLE_BRANCH, CIRCLE_SHA1, CIRCLE_BUILD_NUM,
#     CIRCLE_WORKFLOW_ID, CIRCLE_PIPELINE_NUMBER,
#     CIRCLE_PROJECT_USERNAME, CIRCLE_PROJECT_REPONAME,
#     CIRCLE_USERNAME (CircleCI vars)
# ==========================================================

if [ -z "$SLACK_WEBHOOK_URL" ] || [ -z "$HYBID_PRIVATE_REPO_RELEASE_TAG" ]; then
  echo "⚠️ Missing webhook or version — skipping Slack notification."
  exit 0
fi

case "$CIRCLE_BRANCH" in
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

# Dynamic URLs using CircleCI env vars
ORG="${CIRCLE_PROJECT_USERNAME:-vervegroup}"
REPO="${CIRCLE_PROJECT_REPONAME:-pubnative-hybid-ios-sdk-private}"
PIPE_NUM="${CIRCLE_PIPELINE_NUMBER:-$CIRCLE_BUILD_NUM}"

RELEASE_URL="https://github.com/vervegroup/hybid-ios-sdk-private-pods/releases/tag/${HYBID_PRIVATE_REPO_RELEASE_TAG}"
COMMIT_URL="https://github.com/${ORG}/${REPO}/commit/${CIRCLE_SHA1}"
BUILD_URL="https://app.circleci.com/pipelines/github/${ORG}/${REPO}/${PIPE_NUM}/workflows/${CIRCLE_WORKFLOW_ID}/jobs/${CIRCLE_BUILD_NUM}"

cat <<EOF > /tmp/slack_payload.json
{
  "attachments": [{
    "color": "$COLOR",
    "blocks": [
      { "type": "header", "text": { "type": "plain_text", "text": "$EMOJI $TITLE" } },
      { "type": "section", "fields": [
          { "type": "mrkdwn", "text": "*Version:*\n$HYBID_PRIVATE_REPO_RELEASE_TAG" },
          { "type": "mrkdwn", "text": "*Branch:*\n$CIRCLE_BRANCH" },
          { "type": "mrkdwn", "text": "*Commit:*\n<$COMMIT_URL|${CIRCLE_SHA1:0:7}>" },
          { "type": "mrkdwn", "text": "*Build:*\n<$BUILD_URL|#${CIRCLE_BUILD_NUM}>" },
          { "type": "mrkdwn", "text": "*Release:*\n<$RELEASE_URL|View on GitHub>" }
        ]},
      { "type": "context", "elements": [
          { "type": "mrkdwn", "text": "👤 *Author:* $CIRCLE_USERNAME" },
          { "type": "mrkdwn", "text": "Generated automatically by CircleCI 🚀" }
        ]}
    ]
  }]
}
EOF

curl -s -X POST -H 'Content-type: application/json' -d @/tmp/slack_payload.json "$SLACK_WEBHOOK_URL"
echo "✅ Slack notification sent: $TITLE ($CIRCLE_BRANCH → $HYBID_PRIVATE_REPO_RELEASE_TAG)"