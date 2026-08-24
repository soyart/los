set -euo pipefail

nix flake update --print-build-logs
if git diff --quiet flake.lock; then
  echo "flake.lock unchanged; nothing to push."
  exit 0
fi

TARGET_BRANCH="${CI_DEFAULT_BRANCH:-master}"
BRANCH="ci/flake-lock-${CI_PIPELINE_ID:?}"

git config user.email "gitlab-ci@gitlab.com"
git config user.name "GitLab CI"
git checkout -b "$BRANCH"
git add flake.lock
git commit -m "chore: flake.lock update"
git remote set-url origin "https://gitlab-ci-token:${LOS_GITLAB_WRITE_TOKEN:?}@${CI_SERVER_HOST:?}/${CI_PROJECT_PATH:?}.git"
git push --set-upstream origin "$BRANCH"
curl -sS --fail-with-body \
  --request POST \
  --header "PRIVATE-TOKEN: ${LOS_GITLAB_WRITE_TOKEN:?}" \
  --header "Content-Type: application/json" \
  --data "$(jq -cn --arg s "$BRANCH" --arg t "$TARGET_BRANCH" \
    '{source_branch:$s,target_branch:$t,title:"chore: automated flake.lock update",remove_source_branch:true}')" \
  "${CI_API_V4_URL:?}/projects/${CI_PROJECT_ID:?}/merge_requests"
