{ inputs, ... }:
{
  imports = [
    inputs.nix-gitlab-ci.flakeModule
  ];

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
                { "if" = ''$CI_COMMIT_BRANCH == "master" && $CI_PIPELINE_SOURCE == "push"''; }
                # Dynamic child pipeline from nix-ci:trigger (source name varies by GitLab version).
                { "if" = ''$CI_PIPELINE_SOURCE == "parent_pipeline"''; }
                { "if" = ''$CI_PIPELINE_SOURCE == "pipeline"''; }
              ];
              script = [
                "nix build .#nixosConfigurations.los-t14.config.system.build.toplevel --print-build-logs"
              ];
            };

            tag-master = {
              stage = "maintain";
              rules = [
                {
                  "if" = ''$CI_COMMIT_BRANCH == "master" && ($CI_PIPELINE_SOURCE == "push" || $CI_PIPELINE_SOURCE == "parent_pipeline" || $CI_PIPELINE_SOURCE == "pipeline")'';
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
                (builtins.readFile ./tag-master.sh)
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
              (builtins.readFile ./flake-lock-bump.sh)
            ];
          };
        };
      };
    };
}
