{ lib, config, pkgs, ... }:

let
  allUsers = config.los.homev2;

  doasUsers = lib.filterAttrs (_: u: u.doas.enable) allUsers;
  sudoUsers = lib.filterAttrs (_: u: u.sudo.enable) allUsers;

  anyUsesDoas = doasUsers != { };
  anyUsesSudo = sudoUsers != { };

  cfg = config.los.auth;

  validRules = builtins.filter
    (rule: lib.hasAttr rule.username allUsers)
    cfg.noPasswordRules;

  doasNoPassRules = builtins.filter
    (rule: allUsers.${rule.username}.doas.enable)
    validRules;

  sudoNoPassRules = builtins.filter
    (rule: allUsers.${rule.username}.sudo.enable)
    validRules;

  invalidRules = builtins.filter
    (rule: !(lib.hasAttr rule.username allUsers))
    cfg.noPasswordRules;

in
{
  options.los.auth.noPasswordRules = lib.mkOption {
    type = lib.types.listOf (lib.types.submodule {
      options = {
        username = lib.mkOption {
          type = lib.types.str;
          description = "Username this rule applies to";
        };
        cmd = lib.mkOption {
          type = lib.types.str;
          description = "Command (store path) allowed without password";
        };
      };
    });
    default = [ ];
    description = "Commands that specific users can run without a password via their chosen auth method";
  };

  config = {
    assertions =
      (lib.mapAttrsToList (username: userCfg: {
        assertion = userCfg.doas.enable != userCfg.sudo.enable;
        message = "los.homev2.${username}: exactly one of doas.enable or sudo.enable must be true";
      }) allUsers)
      ++
      (map (rule: {
        assertion = false;
        message = "los.auth.noPasswordRules: username '${rule.username}' does not exist in los.homev2";
      }) invalidRules);

    security.doas = lib.mkIf anyUsesDoas {
      enable = true;
      extraRules =
        (lib.mapAttrsToList (username: userCfg: {
          users = [ username ];
          keepEnv = userCfg.doas.keepEnv;
          persist = userCfg.doas.persist;
        }) doasUsers)
        ++
        (map (rule: {
          users = [ rule.username ];
          cmd = rule.cmd;
          noPass = true;
          persist = false;
          keepEnv = allUsers.${rule.username}.doas.keepEnv;
        }) doasNoPassRules);
    };

    security.sudo = {
      enable = anyUsesSudo;
      extraRules = lib.mkIf anyUsesSudo (
        map (rule: {
          users = [ rule.username ];
          commands = [{
            command = rule.cmd;
            options = [ "NOPASSWD" ];
          }];
        }) sudoNoPassRules
      );
    };

    environment.systemPackages = lib.mkIf anyUsesDoas [
      pkgs.doas-sudo-shim
    ];
  };
}
