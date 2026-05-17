# GitLab CI (nix-gitlab-ci). Imported from the root flake via flake-parts.
{ ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      ci = {
        config = { };

        pipelines.default = {
          stages = [
            "verify"
            "maintain"
          ];

          jobs = {
            build-nixos-toplevel = {
              stage = "verify";
              interruptible = true;
              rules = [
                { "if" = ''$CI_PIPELINE_SOURCE == "merge_request_event"''; }
                {
                  "if" = ''$CI_COMMIT_BRANCH == "master" && $CI_PIPELINE_SOURCE == "push"'';
                }
              ];
              script = [
                "nix build .#nixosConfigurations.los-t14.config.system.build.toplevel --print-build-logs"
              ];
            };

            tag-master = {
              stage = "maintain";
              rules = [
                {
                  "if" = ''$CI_COMMIT_BRANCH == "master" && $CI_PIPELINE_SOURCE == "push"'';
                }
              ];
              needs = [ "build-nixos-toplevel" ];
              nix.deps = [
                pkgs.git
                pkgs.coreutils
              ];
              variables = {
                GIT_DEPTH = "0";
              };
              script = [
                ''
                  set -euo pipefail
                  TAG="master-$(date +%Y-%m-%d)-''${CI_COMMIT_SHORT_SHA:?}"
                  git remote set-url origin "https://gitlab-ci-token:''${LOS_GITLAB_WRITE_TOKEN:?}@''${CI_SERVER_HOST:?}/''${CI_PROJECT_PATH:?}.git"
                  if git rev-parse "refs/tags/$TAG" >/dev/null 2>&1; then
                    echo "Tag $TAG already exists; skipping."
                    exit 0
                  fi
                  git tag "$TAG" "$CI_COMMIT_SHA"
                  git push origin "refs/tags/$TAG"
                ''
              ];
            };
          };
        };

        # Only used for CI_PIPELINE_SOURCE=schedule (see NIX_CI_DEFAULT_SOURCES in .gitlab-ci.yml).
        pipelines.schedule = {
          stages = [ "maintain" ];

          jobs.flake-lock-bump = {
            stage = "maintain";
            nix.deps = [
              pkgs.git
              pkgs.curl
              pkgs.coreutils
              pkgs.jq
            ];
            variables = {
              GIT_DEPTH = "0";
            };
            script = [
              ''
                set -euo pipefail
                nix flake update --print-build-logs
                if git diff --quiet flake.lock; then
                  echo "flake.lock unchanged; nothing to push."
                  exit 0
                fi
                TARGET_BRANCH="''${CI_DEFAULT_BRANCH:-master}"
                BRANCH="ci/flake-lock-''${CI_PIPELINE_ID:?}"
                git config user.email "gitlab-ci@gitlab.com"
                git config user.name "GitLab CI"
                git checkout -b "$BRANCH"
                git add flake.lock
                git commit -m "chore: flake.lock update"
                git remote set-url origin "https://gitlab-ci-token:''${LOS_GITLAB_WRITE_TOKEN:?}@''${CI_SERVER_HOST:?}/''${CI_PROJECT_PATH:?}.git"
                git push --set-upstream origin "$BRANCH"
                curl -sS --fail-with-body \
                  --request POST \
                  --header "PRIVATE-TOKEN: ''${LOS_GITLAB_WRITE_TOKEN:?}" \
                  --header "Content-Type: application/json" \
                  --data "$(jq -cn --arg s "$BRANCH" --arg t "$TARGET_BRANCH" \
                    '{source_branch:$s,target_branch:$t,title:"chore: automated flake.lock update",remove_source_branch:true}')" \
                  "''${CI_API_V4_URL:?}/projects/''${CI_PROJECT_ID:?}/merge_requests"
              ''
            ];
          };
        };
      };
    };
}
