username:

{ lib, config, ... }:

let
  cfg = config.los.home."${username}".progs.lf;

in
{
  options.los.home."${username}".progs.lf = {
    enable = lib.mkEnableOption "Enable lf for user ${username}";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users."${username}".programs.lf = {
      enable = true;

      settings = {
        shell = "bash";
        shellopts = "-eu";
        ifs = "\\n";


        info = "size";
        dircounts = true;
        smartcase = true;

        ratios = [ 1 2 3 ];
      };

      extraConfig = ''
        $mkdir -p ~/.trash
      '';

      commands = {
        open = ''
          ''${{
              case $(file --mime-type $f -b) in
                  text/*) $EDITOR $fx;;
                  *) for f in $fx; do setsid $OPENER $f > /dev/null 2> /dev/null & done;;
              esac
          }}
        ''; # Escaping https://discourse.nixos.org/t/need-help-understanding-how-to-escape-special-characters-in-the-list-of-str-type/11389

        trash = ''
          %set -f; mv $fx ~/.trash
        '';
      };

      keybindings = {
        "<enter>" = "shell";

        # Toggle dotfiles       
        "." = "set hidden!";

        "o" = "$mimeopen $f";
        "O" = "$mimeopen --ask $f";
        "i" = "$less $f";
        "U" = "!du -sh";


        # Execute file
        "x" = "$$f";
        "X" = "!$f";

        "p" = "paste";
        "yy" = "copy";
        "dd" = "trash";
        "DD" = "delete";
        "ad" = "push $mkdir<space>";
        "af" = "push $touch<space>";

        # Sort by natural, with size
        "sn" = ":{{ set sortby natural; set info size; }}";
      };
    };
  };
}
