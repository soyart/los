set -euo pipefail

TAG="master-$(date +%Y-%m-%d)-${CI_COMMIT_SHORT_SHA:?}"
git remote set-url origin "https://gitlab-ci-token:${LOS_GITLAB_WRITE_TOKEN:?}@${CI_SERVER_HOST:?}/${CI_PROJECT_PATH:?}.git"
if git rev-parse "refs/tags/$TAG" >/dev/null 2>&1; then
  echo "Tag $TAG already exists; skipping."
  exit 0
fi

git tag "$TAG" "$CI_COMMIT_SHA"
git push origin "refs/tags/$TAG"
